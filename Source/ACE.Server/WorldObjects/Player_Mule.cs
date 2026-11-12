using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

using ACE.Common;
using ACE.Database;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Entity.Models;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Network.GameEvent.Events;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    partial class Player
    {
        // -------------------------------------------------------------------------
        // JawnTide: ported from ClassicPvP's feature/my-mule (Supershoff/ClassicPvP). JawnTide changes:
        // summon anywhere the player isn't PK tagged (and not in an arena), owner's account only (no house
        // guests, nobody else can open or search it), no deposits/withdrawals while PK tagged, the mule
        // leaves on PK tag / teleport / landblock change / logout (Player_Tick.MuleTick), and a split
        // deposit saves the player's smaller stack before the mule's copy (debit before credit).
        // -------------------------------------------------------------------------
        // My Mule — a single, unified personal summonable storage vendor. Storage is an
        // overflow-chained sequence of off-world containers (see PropertyInstanceId.
        // MuleContainerId / MuleNextContainerId): deposits always target the tail container,
        // creating and linking a new one whenever the current tail hits its 255-item structural
        // cap (Container.ItemCapacity is byte-backed and enforced unconditionally regardless of
        // burden checks). The whole chain displays together in one vendor window.
        // -------------------------------------------------------------------------

        /// <summary>The currently summoned mule NPC shell, if any. Not persisted -- a relog always starts with no mule out.</summary>
        public Vendor ActiveMule;

        /// <summary>Every container in this player's mule storage chain, head first, in order. Loaded together whenever ActiveMule is set.</summary>
        public List<Container> ActiveMuleContainers;

        /// <summary>
        /// Called from Gem.UseGem() when the My Mule gem is used. Toggles the mule: if you already
        /// have one summoned, using the gem again just dismisses it. Otherwise, validates the
        /// summon location and summons it.
        /// </summary>
        public void SummonMule()
        {
            // No IsBusy check here: this is invoked from Gem.UseGem(), which runs as the
            // callback of ApplyConsumable() -- IsBusy is intentionally still true at this point
            // (it's cleared afterward, once the use animation finishes) and Gem.ActOnUse() already
            // rejected the use up front if the player was busy before the animation even started.
            if (IsDead)
                return;

            if (ActiveMule != null)
            {
                DespawnMule();

                Session.Network.EnqueueSend(new GameMessageSystemChat("You dismiss your mule.", ChatMessageType.Broadcast));
                return;
            }

            // JawnTide: anywhere safe instead of housing landblocks / the Marketplace
            if (CurrentLandblock == null)
                return;

            if (PKTimerActive)
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat("Your mule won't come near the fighting. Wait until you're no longer PK tagged.", ChatMessageType.Broadcast));
                return;
            }

            if (IsArenaObserver || ArenaLocation.IsArenaLocation(Location))
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat("Your mule can't be summoned in an arena.", ChatMessageType.Broadcast));
                return;
            }

            LoadMuleContainerChain(SpawnMuleVendor);
        }

        private bool muleGemLookChecked;

        /// <summary>JawnTide: the gem's glow while the mule is out (it keeps its name). Normal look is MuleInfo.GemIdleUiEffects.</summary>
        private void SetMuleGemLook(bool muleOut)
        {
            var look = (int)(muleOut ? MuleInfo.GemActiveUiEffects : MuleInfo.GemIdleUiEffects);

            foreach (var gem in GetAllPossessions().Where(i => i.WeenieClassId == MuleInfo.GemWeenieClassId))
            {
                if ((gem.GetProperty(PropertyInt.UiEffects) ?? 0) != look)
                    UpdateProperty(gem, PropertyInt.UiEffects, look);
            }
        }

        /// <summary>
        /// JawnTide: called from the player heartbeat. The mule only stays while its owner is on the same landblock,
        /// close by and not PK tagged; it is removed from the owner's own thread here (never from another player's).
        /// </summary>
        public void MuleTick()
        {
            // the gem may have been saved with its "mule out" look (server stopped with a mule out): fix it once per login
            if (!muleGemLookChecked)
            {
                muleGemLookChecked = true;
                SetMuleGemLook(ActiveMule != null);
            }

            if (ActiveMule == null)
                return;

            string why = null;

            if (ActiveMule.IsDestroyed || ActiveMule.CurrentLandblock == null || CurrentLandblock == null || ActiveMule.CurrentLandblock.Id != CurrentLandblock.Id)
                why = "Your mule stays behind.";
            else if (PKTimerActive)
                why = "Your mule bolts from the fighting.";
            else if (Location.DistanceTo(ActiveMule.Location) > MuleInfo.MaxDistance)
                why = "You wander too far from your mule, and it heads home.";

            if (why == null)
                return;

            DespawnMule();
            Session.Network.EnqueueSend(new GameMessageSystemChat(why, ChatMessageType.Broadcast));
        }

        /// <summary>
        /// Destroys the currently active mule NPC shell, if any. Always clears its sale
        /// dictionaries first -- WorldObject.Destroy() cascade-destroys everything in a Vendor's
        /// DefaultItemsForSale/UniqueItemsForSale, and those dictionaries reference the same
        /// live objects backing the player's persistent storage. Never destroy a mule NPC any
        /// other way.
        /// </summary>
        public void DespawnMule()
        {
            if (ActiveMule != null)
            {
                // JawnTide: the mule may be on another landblock (its owner just walked or teleported away), which can
                // run on a different thread, so it is removed on its own landblock's action queue. The sale lists are
                // cleared in the same step, right before Destroy(), since they point at the live storage items.
                var mule = ActiveMule;
                mule.EnqueueAction(new ActionEventDelegate(() =>
                {
                    if (mule.IsDestroyed)
                        return;

                    mule.DefaultItemsForSale.Clear();
                    mule.UniqueItemsForSale.Clear();
                    mule.Destroy();
                }));
            }

            SetMuleZeroValueMask(false);
            BankRestoreCoinDisplay(); // the mule window showed a full coin count

            // ActiveMuleContainers is deliberately NOT cleared here -- see LoadMuleContainerChain.
            // The search filter now lives on the vendor (MuleSearchRegex), which is about to be
            // destroyed above, so there's nothing else to clear for it here.
            ActiveMule = null;
            SetMuleGemLook(false);
        }

        /// <summary>
        /// JawnTide: the client won't put an item worth 0 pyreals (e.g. Imbuer's Crystal and other rare gems), or one marked not
        /// sellable or retained, into a vendor's
        /// sell window. While the mule is open, the client is told those items are worth 1; when the mule leaves, it is told
        /// their real value again. Only the client's copy changes: the item's real Value on the server stays 0, so no vendor
        /// ever pays for it.
        /// </summary>
        public void SetMuleZeroValueMask(bool masked)
        {
            if (Session == null)
                return;

            foreach (var item in GetAllPossessions())
            {
                if ((item.Value ?? 0) <= 0)
                    Session.Network.EnqueueSend(new GameMessagePublicUpdatePropertyInt(item, PropertyInt.Value, masked ? 1 : 0));

                // JawnTide: the client also won't offer items marked not sellable (quest food like Elaborate Field Rations)
                // or retained. Only the client's copy changes; real vendors still check both on the server.
                if (!item.IsSellable)
                    Session.Network.EnqueueSend(new GameMessagePublicUpdatePropertyBool(item, PropertyBool.IsSellable, masked));
                if (item.Retained)
                    Session.Network.EnqueueSend(new GameMessagePublicUpdatePropertyBool(item, PropertyBool.Retained, !masked));
            }
        }

        /// <summary>
        /// Loads every container in the account's shared mule storage chain, head first, creating
        /// a fresh head if no character on the account has ever summoned a mule before. The head
        /// container GUID is stored per-account (shard DB account_mule table), not per-character,
        /// so every character on the account shares the same storage. Container inventory loading
        /// is async for anything already in the DB, so onLoaded is invoked once the whole chain is
        /// confirmed ready rather than assumed synchronous.
        /// <para/>
        /// If this Player already has the chain loaded from an earlier summon this session, it's
        /// reused directly instead of re-querying the DB. This isn't just an optimization --
        /// WorldObject.SaveBiotaToDatabase() has no dirty-check and is fire-and-forget (it enqueues
        /// onto a background worker and returns immediately, with no guarantee the write has landed
        /// yet). Discarding the loaded containers on every despawn and re-reading the DB on every
        /// resummon meant a deposit immediately followed by leaving the landblock and summoning
        /// again could read back pre-deposit state -- items would appear to vanish even though the
        /// save was still just queued, not lost. Keeping the same in-memory objects across
        /// despawn/resummon within a session sidesteps the race entirely, since nothing ever needs
        /// to be re-read while it's still in flight.
        /// </summary>
        private void LoadMuleContainerChain(Action<List<Container>> onLoaded)
        {
            if (ActiveMuleContainers != null)
            {
                onLoaded(ActiveMuleContainers);
                return;
            }

            // JawnTide Marketplace: the market is moving an item in or out of this account's mule in the database right now
            if (ACE.Server.Managers.MarketManager.IsAccountBusy(Account.AccountId))
            {
                SendTransientError("Your mule is busy with a market order. Try again in a few seconds.");
                return;
            }

            var headGuid = DatabaseManager.Shard.BaseDatabase.GetAccountMuleContainerId(Account.AccountId);

            if (!headGuid.HasValue)
            {
                var container = CreateNewMuleContainer();

                if (container == null)
                {
                    SendTransientError("Your mule could not be created.");
                    return;
                }

                DatabaseManager.Shard.BaseDatabase.SetAccountMuleContainerId(Account.AccountId, container.Guid.Full);

                onLoaded(new List<Container> { container });
                return;
            }

            LoadMuleContainerChainStep(headGuid.Value, new List<Container>(), onLoaded);
        }

        private void LoadMuleContainerChainStep(uint containerGuid, List<Container> chain, Action<List<Container>> onLoaded)
        {
            var rawBiota = DatabaseManager.Shard.BaseDatabase.GetBiota(containerGuid);
            var container = rawBiota != null ? WorldObjectFactory.CreateWorldObject(rawBiota) as Container : null;

            if (container == null)
            {
                // Never silently replace a container that fails to load, head or not. This used
                // to treat a failed head load as "must be a fresh account" and create a brand new
                // container, overwriting the account's stored pointer (SetAccountMuleContainerId)
                // -- but a transient DB hiccup (a restart, a dropped connection, anything that
                // isn't actually data loss) looks identical to "doesn't exist" here, and that
                // silently orphaned the account's real mule contents behind an abandoned pointer
                // while an empty container took its place. Fail loudly instead and leave the
                // stored pointer untouched, so a retry can still find the real data.
                log.Error($"[MULE] {Name} (0x{Guid}) mule storage container 0x{containerGuid:X8} (chain position {chain.Count}) couldn't be loaded. Not replacing it -- if this isn't transient, this needs manual investigation before anything new is created for this account.");
                SendTransientError("Your mule's storage couldn't be loaded right now. Please try again in a moment.");
                return;
            }

            WaitForContainerLoad(container, loaded =>
            {
                chain.Add(loaded);

                var nextGuid = loaded.GetProperty(PropertyInstanceId.MuleNextContainerId);

                if (nextGuid.HasValue)
                    LoadMuleContainerChainStep(nextGuid.Value, chain, onLoaded);
                else
                    onLoaded(chain);
            });
        }

        /// <summary>
        /// Creates a fresh, empty mule storage container. Synchronous -- a brand new Container
        /// (built from a weenie, not restored from a biota) has nothing to load, so
        /// InventoryLoaded is already true the moment it's constructed.
        /// </summary>
        private Container CreateNewMuleContainer()
        {
            var container = WorldObjectFactory.CreateNewWorldObject(MuleInfo.StorageContainerWeenieClassId) as Container;

            if (container == null)
            {
                log.Error($"[MULE] Failed to create mule storage container weenie {MuleInfo.StorageContainerWeenieClassId} for {Name} (0x{Guid})");
                return null;
            }

            container.ItemCapacity = byte.MaxValue; // ItemCapacity is byte-backed, 255 is the structural ceiling
            container.ContainerCapacity = 0;

            container.SaveBiotaToDatabase();

            return container;
        }

        /// <summary>
        /// A freshly constructed Container starts an async self-load of its inventory
        /// (Container.cs ctor -> GetInventoryInParallel). Poll InventoryLoaded rather than
        /// racing to enqueue a continuation, since the DB callback firing is what enqueues
        /// the sort step in the first place.
        /// </summary>
        private void WaitForContainerLoad(Container container, Action<Container> onLoaded, int attemptsRemaining = 50)
        {
            if (container.InventoryLoaded)
            {
                onLoaded(container);
                return;
            }

            if (attemptsRemaining <= 0)
            {
                log.Error($"[MULE] Timed out waiting for mule storage container 0x{container.Guid} to finish loading for {Name} (0x{Guid})");
                SendTransientError("Your mule's storage is taking too long to load. Please try again in a moment.");
                return;
            }

            var chain = new ActionChain();
            chain.AddDelaySeconds(0.1f);
            chain.AddAction(this, () => WaitForContainerLoad(container, onLoaded, attemptsRemaining - 1));
            chain.EnqueueChain();
        }

        /// <summary>
        /// The container new deposits should go into: the first container anywhere in the chain
        /// with spare room, not just the tail -- a container can end up hollowed out mid-chain
        /// (e.g. a deposit-heavy-then-withdraw-heavy test cycle can empty out the head while the
        /// tail is still being appended to), and since the chain is a linked list, that freed-up
        /// space is otherwise stranded forever: new deposits would keep growing the tail toward
        /// MuleInfo.MaxContainers and the mule would report "full" while entire containers near
        /// the head sit empty. Only once every existing container is genuinely at ItemCapacity is
        /// a new one created and linked to the end of the chain -- unless the chain is already at
        /// MuleInfo.MaxContainers, in which case null is returned and the caller must reject the
        /// deposit. The old tail's link update is added to touched rather than saved immediately,
        /// so it's included in the caller's single end-of-transaction save batch instead of an
        /// extra one here.
        /// </summary>
        private Container GetOrCreateMuleDepositTarget(List<Container> containers, HashSet<WorldObject> touched)
        {
            foreach (var container in containers)
            {
                if (container.Inventory.Count < (container.ItemCapacity ?? 0))
                    return container;
            }

            // Diagnostic: this should only ever fire when every container in the chain is
            // genuinely at its 255-item structural cap. Logged unconditionally (not just on the
            // unexpected case) so if a new container ever gets created for a mule that clearly
            // isn't full, the exact state that triggered it is on record instead of having to be
            // reconstructed from the DB after the fact.
            log.Info($"[MULE] {Name} (0x{Guid}) mule chain overflow: all {containers.Count} loaded containers are full. Creating a new container.");

            if (containers.Count >= MuleInfo.MaxContainers)
                return null;

            var tail = containers[containers.Count - 1];

            var next = CreateNewMuleContainer();

            if (next == null)
                return null;

            tail.SetProperty(PropertyInstanceId.MuleNextContainerId, next.Guid.Full);
            touched.Add(tail);

            containers.Add(next);

            Session.Network.EnqueueSend(new GameMessageSystemChat(
                "Your mule's storage container filled up, so a new one was added automatically.",
                ChatMessageType.Broadcast));

            return next;
        }

        private void SpawnMuleVendor(List<Container> containers)
        {
            var vendor = WorldObjectFactory.CreateNewWorldObject(MuleInfo.VendorWeenieClassId) as Vendor;

            if (vendor == null)
            {
                log.Error($"[MULE] Failed to create mule vendor weenie {MuleInfo.VendorWeenieClassId} for {Name} (0x{Guid})");
                SendTransientError("Your mule could not be summoned.");
                return;
            }

            ApplyMuleVisual(vendor);

            var playerRadius = PhysicsObj.GetPhysicsRadius();
            var vendorRadius = vendor.PhysicsObj?.GetPhysicsRadius() ?? 0.5f;
            var spawnDist = playerRadius + vendorRadius + 1.0f;

            vendor.Location = Location.InFrontOf(spawnDist, true);
            vendor.Location.LandblockId = new LandblockId(vendor.Location.GetCell());

            vendor.Name = $"{Name}'s Mule";

            vendor.MerchandiseItemTypes = unchecked((int)MuleInfo.AllowedItemTypes);
            vendor.MuleOwnerId = Guid.Full;
            vendor.MuleOwnerAccountId = Account.AccountId;
            vendor.MuleContainers = containers;
            vendor.TimeToRot = -1; // JawnTide: never decay (a dynamic object with no TimeToRot is cleaned up after 5 minutes, which made mules "time out")

            // JawnTide: players and monsters walk through mules, so a mule can't be used to block a passage or a monster.
            // It can still be selected, used and traded with as before.
            vendor.Ethereal = true;

            foreach (var item in SortMuleItems(containers.SelectMany(c => c.Inventory.Values)))
                vendor.UniqueItemsForSale[item.Guid] = item;

            // JawnTide Marketplace: the website shows mule items with their icons
            ACE.Server.Managers.MarketManager.QueueIcons(containers.SelectMany(c => c.Inventory.Values));

            if (!vendor.EnterWorld())
            {
                SendTransientError("Couldn't summon your mule here.");
                vendor.Destroy();
                return;
            }

            ActiveMule = vendor;
            SetMuleGemLook(true);
            ActiveMuleContainers = containers;

            Session.Network.EnqueueSend(new GameMessageSystemChat("You summon your mule.", ChatMessageType.Broadcast));
        }

        /// <summary>
        /// Gives the mule shell the look of one of its assigned monster race's variants. Copies
        /// appearance properties (model, animation table, sound table, clothing base, palette,
        /// shade, scale, creature type) from the chosen source weenie -- never its combat stats,
        /// AI, loot tables, etc., none of which matter for a vendor shell. Must run before
        /// EnterWorld() so the vendor's PhysicsObj initializes from the new model's dimensions,
        /// not the base template's.
        /// <para/>
        /// Which variant an account gets is derived from the account id rather than
        /// ThreadSafeRandom, then stored account-wide (shard DB account_mule table) so it's
        /// consistent for every character on the account and stable for the account's life.
        /// </summary>
        private void ApplyMuleVisual(Vendor vendor)
        {
            var variantIndex = DatabaseManager.Shard.BaseDatabase.GetAccountMuleVisualVariant(Account.AccountId);

            if (!variantIndex.HasValue || variantIndex.Value < 0 || variantIndex.Value >= MuleInfo.VisualVariantSourceWcids.Length)
            {
                // Derived from the account id (not ThreadSafeRandom, and not the character guid --
                // every character on the account must land on the same variant), so two accounts
                // can never end up drawing from a shared/correlated random state and landing on the
                // same variant, and every character on this account gets a consistent look.
                variantIndex = (int)((Account.AccountId * 2654435761u) % (uint)MuleInfo.VisualVariantSourceWcids.Length);
                DatabaseManager.Shard.BaseDatabase.SetAccountMuleVisualVariant(Account.AccountId, variantIndex.Value);
            }

            var sourceWcid = MuleInfo.VisualVariantSourceWcids[variantIndex.Value];
            var sourceWeenie = DatabaseManager.World.GetCachedWeenie(sourceWcid);

            if (sourceWeenie == null)
            {
                log.Error($"[MULE] Visual variant source weenie {sourceWcid} not found, leaving default appearance.");
                return;
            }

            if (sourceWeenie.PropertiesDID != null)
            {
                if (sourceWeenie.PropertiesDID.TryGetValue(PropertyDataId.Setup, out var setup))
                    vendor.SetupTableId = setup;
                if (sourceWeenie.PropertiesDID.TryGetValue(PropertyDataId.MotionTable, out var motionTable))
                    vendor.MotionTableId = motionTable;
                if (sourceWeenie.PropertiesDID.TryGetValue(PropertyDataId.SoundTable, out var soundTable))
                    vendor.SoundTableId = soundTable;
                if (sourceWeenie.PropertiesDID.TryGetValue(PropertyDataId.PaletteBase, out var paletteBase))
                    vendor.PaletteBaseDID = paletteBase;
                if (sourceWeenie.PropertiesDID.TryGetValue(PropertyDataId.ClothingBase, out var clothingBase))
                    vendor.SetProperty(PropertyDataId.ClothingBase, clothingBase);
            }

            if (sourceWeenie.PropertiesInt != null)
            {
                if (sourceWeenie.PropertiesInt.TryGetValue(PropertyInt.PaletteTemplate, out var paletteTemplate))
                    vendor.PaletteTemplate = paletteTemplate;
                if (sourceWeenie.PropertiesInt.TryGetValue(PropertyInt.CreatureType, out var creatureType))
                    vendor.CreatureType = (ACE.Entity.Enum.CreatureType)creatureType;
            }

            if (sourceWeenie.PropertiesFloat != null)
            {
                if (sourceWeenie.PropertiesFloat.TryGetValue(PropertyFloat.Shade, out var shade))
                    vendor.Shade = shade;
                if (sourceWeenie.PropertiesFloat.TryGetValue(PropertyFloat.DefaultScale, out var scale))
                    vendor.ObjScale = (float)scale;
            }

            vendor.CalculateObjDesc();
        }

        /// <summary>
        /// Rebuilds the mule shell's displayed sale list from every container in the chain and
        /// pushes the update to whichever player is looking at it. If a /mule search is active
        /// (vendor.MuleSearchRegex -- shared state on the vendor itself, not the acting player, so
        /// it applies consistently whether the owner or a guest triggers the refresh), this filters
        /// down to just the matches; otherwise it shows the full unified listing. Double-clicking
        /// the mule NPC to reopen it (Vendor.ActOnUse) clears the filter first, so the un-filtered
        /// listing is always one re-approach away.
        /// </summary>
        private void RefreshMuleVendorDisplay(Vendor vendor, VendorType action)
        {
            var allItems = vendor.MuleContainers.SelectMany(c => c.Inventory.Values);

            var display = vendor.MuleSuitGuids != null
                ? allItems.Where(item => vendor.MuleSuitGuids.Contains(item.Guid.Full)).OrderBy(i => i.Name)
                : vendor.MuleSearchRegex != null
                ? allItems.Where(item => MatchesMuleSearch(item, vendor.MuleSearchRegex)).OrderBy(i => i.Name)
                : SortMuleItems(allItems);

            vendor.UniqueItemsForSale.Clear();

            foreach (var item in display)
                vendor.UniqueItemsForSale[item.Guid] = item;

            vendor.ApproachVendor(this, action);
        }

        /// <summary>
        /// Tells this player how full the given mule's storage currently is -- items/stacks used
        /// across every container in the chain vs. the absolute ceiling
        /// (MuleInfo.MaxContainers containers x 255 items each). Called from Vendor.ActOnUse
        /// whenever anyone (owner or a guest with storage access) opens the mule's window, so
        /// worded ownership-agnostically rather than "your mule."
        /// </summary>
        public void SendMuleCapacityStatus(Vendor vendor)
        {
            var used = vendor.MuleContainers.Sum(c => c.Inventory.Count);
            var total = MuleInfo.MaxContainers * 255;

            Session.Network.EnqueueSend(new GameMessageSystemChat(
                $"This mule is using {used} of {total} storage slots.",
                ChatMessageType.Broadcast));
        }

        /// <summary>
        /// Clears an active /mule search on the given mule vendor and rebuilds UniqueItemsForSale
        /// from the full, unfiltered inventory, without sending a network packet itself -- called
        /// from Vendor.ActOnUse right before it sends its own ApproachVendor packet as part of the
        /// normal re-open flow, so double-clicking the mule NPC always resets an active filter
        /// instead of leaving whoever's looking stuck on a stale search.
        /// </summary>
        public void ClearMuleSearchFilter(Vendor vendor)
        {
            if (vendor.MuleSearchRegex == null && vendor.MuleSuitGuids == null)
                return;

            vendor.MuleSearchRegex = null;
            vendor.MuleSuitGuids = null;

            vendor.UniqueItemsForSale.Clear();

            foreach (var item in SortMuleItems(vendor.MuleContainers.SelectMany(c => c.Inventory.Values)))
                vendor.UniqueItemsForSale[item.Guid] = item;
        }

        /// <summary>
        /// Called from the "/mule search &lt;pattern&gt;" command. Operates on whichever mule
        /// vendor window this player currently has open (LastOpenedContainerId -- the same
        /// tracking every vendor/container approach already sets, per Vendor.ApproachVendor), not
        /// just a mule they summoned themselves -- viewing a mule's contents was already
        /// unrestricted, so searching it is too. Compiles pattern as a regex and matches it
        /// against every item across that mule's whole storage chain, filtering the buy window
        /// down to whatever matches -- a stand-in for the spell search Virindi Global Inventory
        /// used to provide. An empty/whitespace pattern clears the search and restores the normal
        /// listing (as does double-clicking the mule NPC to reopen it).
        /// </summary>
        public void SearchMuleInventory(string pattern)
        {
            var vendor = CurrentLandblock?.GetObject(LastOpenedContainerId) as Vendor;

            if (vendor == null || !vendor.MuleOwnerId.HasValue || vendor.MuleContainers == null || !CanAccessMuleStorage(vendor))
            {
                SendTransientError("You must have your mule's window open to search it.");
                return;
            }

            vendor.MuleSuitGuids = null;

            if (string.IsNullOrWhiteSpace(pattern))
            {
                vendor.MuleSearchRegex = null;

                RefreshMuleVendorDisplay(vendor, VendorType.Undef);

                Session.Network.EnqueueSend(new GameMessageSystemChat("Mule search cleared.", ChatMessageType.Broadcast));
                return;
            }

            Regex regex;

            try
            {
                // Timeout guards against a pathological pattern (catastrophic backtracking)
                // stalling the landblock's single-threaded action queue.
                regex = new Regex(pattern, RegexOptions.IgnoreCase | RegexOptions.Singleline, TimeSpan.FromMilliseconds(500));
            }
            catch (ArgumentException ex)
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat($"That search pattern isn't a valid regular expression: {ex.Message}", ChatMessageType.Broadcast));
                return;
            }

            vendor.MuleSearchRegex = regex;

            RefreshMuleVendorDisplay(vendor, VendorType.Undef);

            var matchCount = vendor.UniqueItemsForSale.Count;
            Session.Network.EnqueueSend(new GameMessageSystemChat(
                $"Mule search found {matchCount} matching item{(matchCount == 1 ? "" : "s")}.",
                ChatMessageType.Broadcast));
        }

        /// <summary>
        /// JawnTide Suit Builder: "/mule suit CODE" filters the open mule window to the items of a suit saved on the website
        /// (suit_plan, which belongs to the mule's account). Reopening the mule clears it, like /mule search.
        /// </summary>
        public void ShowMuleSuit(string code, bool take = false)
        {
            var vendor = CurrentLandblock?.GetObject(LastOpenedContainerId) as Vendor;

            if (vendor == null || !vendor.MuleOwnerId.HasValue || vendor.MuleContainers == null || !CanAccessMuleStorage(vendor))
            {
                SendTransientError("Open your mule first, then type /mule suit CODE.");
                return;
            }

            code = (code ?? "").Trim().ToUpperInvariant();
            if (!Regex.IsMatch(code, "^[A-Z0-9]{4,8}$"))
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat("Usage: /mule suit CODE (the code from the Suit Builder page on the website).", ChatMessageType.Broadcast));
                return;
            }

            List<object[]> rows;
            try
            {
                // the mule's account, or (a guest using someone else's mule) this player's own account
                rows = DatabaseManager.Shard.BaseDatabase.PvpToolsQuery("SELECT name, items FROM suit_plan WHERE account_Id IN (@a, @me) AND code = @c ORDER BY account_Id = @me DESC LIMIT 1;",
                    ("@a", vendor.MuleOwnerAccountId.Value), ("@me", Account.AccountId), ("@c", code));
            }
            catch (Exception ex)
            {
                log.Error($"[MULE] /mule suit {code}: {ex.Message}");
                rows = null;
            }

            if (rows == null || rows.Count == 0)
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat($"There's no saved suit {code} for this mule or your account.", ChatMessageType.Broadcast));
                return;
            }

            var guids = new HashSet<uint>();
            foreach (var part in (rows[0][1]?.ToString() ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries))
                if (uint.TryParse(part.Trim(), out var g))
                    guids.Add(g);

            vendor.MuleSearchRegex = null;
            vendor.MuleSuitGuids = guids;

            RefreshMuleVendorDisplay(vendor, VendorType.Undef);

            var found = vendor.UniqueItemsForSale.Count;

            // "/mule suit CODE take": withdraw every item of the suit into this character's pack at once (the normal
            // withdraw: free, and refused as a whole if they don't all fit in the pack)
            if (take)
            {
                if (found == 0)
                {
                    Session.Network.EnqueueSend(new GameMessageSystemChat($"None of suit {code}'s items are in this mule.", ChatMessageType.Broadcast));
                    return;
                }

                var profiles = vendor.UniqueItemsForSale.Values.Select(wo => new ItemProfile(wo.StackSize ?? 1, wo.Guid.Full)).ToList();
                Session.Network.EnqueueSend(new GameMessageSystemChat($"Taking suit {code} ({found} item{(found == 1 ? "" : "s")}) out of the mule.", ChatMessageType.Broadcast));
                HandleMuleWithdraw(vendor, profiles);
                return;
            }
            Session.Network.EnqueueSend(new GameMessageSystemChat(
                $"Suit {code} ({rows[0][0]}): showing {found} of its {guids.Count} items" + (found < guids.Count ? " (the rest aren't in this mule anymore)." : ".") +
                " Reopen the mule to see everything again, or type /mule suit " + code + " take to take them all.", ChatMessageType.Broadcast));
        }

        private bool MatchesMuleSearch(WorldObject item, Regex regex)
        {
            try
            {
                return regex.IsMatch(BuildItemSearchText(item));
            }
            catch (RegexMatchTimeoutException)
            {
                log.Warn($"[MULE] {Name} (0x{Guid}) mule search pattern timed out matching {item.Name} (0x{item.Guid}), skipping.");
                return false;
            }
        }

        /// <summary>
        /// Which container in the chain an item displayed on the active mule actually lives in.
        /// </summary>
        private static Container ResolveMuleItemContainer(List<Container> containers, ObjectGuid itemGuid) =>
            containers.FirstOrDefault(c => c.Inventory.ContainsKey(itemGuid));

        /// <summary>
        /// Whether this player may deposit into / withdraw from the given mule vendor: either
        /// they're the owner, or they currently have storage-chest access to a house owned by any
        /// character on the owner's account (mule storage is account-wide, so this isn't tied to
        /// which specific character summoned it or owns the house). Queried fresh from the DB each
        /// time -- see ShardDatabase.HasHouseStoragePermission for why: the obvious alternative,
        /// HouseManager.FindPlayerHouse()/House.HasPermission(), reads from a House object cached
        /// once at server startup that never sees guest-list changes made afterward through the
        /// live in-game house panel.
        /// </summary>
        private bool CanAccessMuleStorage(Vendor vendor)
        {
            // JawnTide: characters on the owner's account, plus the account's mule guests (/mule storage add NAME)
            return vendor.MuleOwnerId.HasValue && vendor.MuleOwnerAccountId.HasValue && Account != null
                && (Account.AccountId == vendor.MuleOwnerAccountId.Value || ACE.Server.Managers.MuleGuests.IsGuest(vendor.MuleOwnerAccountId.Value, Guid.Full));
        }

        /// <summary>JawnTide: true when this player is using someone else's mule as a guest (not a character on the owner's account).</summary>
        private bool IsMuleGuestOf(Vendor vendor) => vendor.MuleOwnerAccountId.HasValue && Account != null && Account.AccountId != vendor.MuleOwnerAccountId.Value;

        /// <summary>JawnTide: audits a guest's deposit or withdrawal as a transfer and tells the mule's owner.</summary>
        private void ReportMuleGuestUse(Vendor vendor, bool deposit, List<(WorldObject item, int amount)> moved)
        {
            if (moved.Count == 0 || !vendor.MuleOwnerId.HasValue)
                return;

            var owner = ACE.Server.Managers.PlayerManager.GetOnlinePlayer(vendor.MuleOwnerId.Value);

            if (owner != null)
            {
                if (deposit)
                    ACE.Server.Managers.TransferAudit.RecordItemAmounts("mule_guest_deposit", this, owner, moved);
                else
                    ACE.Server.Managers.TransferAudit.RecordItemAmounts("mule_guest_withdraw", owner, this, moved);

                var what = string.Join(", ", moved.Take(5).Select(m => m.amount > 1 ? $"{m.amount} {m.item.Name}" : m.item.Name)) + (moved.Count > 5 ? $" and {moved.Count - 5} more" : "");
                owner.Session.Network.EnqueueSend(new GameMessageSystemChat($"{Name} {(deposit ? "stored" : "took")} {what} {(deposit ? "in" : "from")} your mule.", ChatMessageType.Broadcast));
            }

            log.Info($"[MULE] guest {Name} (0x{Guid}) {(deposit ? "deposited into" : "withdrew from")} account {vendor.MuleOwnerAccountId} mule: {string.Join(", ", moved.Select(m => $"{m.item.Name} x{m.amount} (0x{m.item.Guid})"))}");
        }

        /// <summary>JawnTide: whether this player may open or search the given mule vendor at all (owner's account only).</summary>
        public bool CanUseMule(Vendor vendor) => CanAccessMuleStorage(vendor);

        /// <summary>
        /// Every spell id associated with an item for search purposes: its own bound spells
        /// (PropertiesSpellBook), plus a use-activated SpellDID or ProcSpell if it has one --
        /// mirrors what AppraiseInfo.BuildSpells() surfaces on the identify panel, since that's the
        /// "spells on this item" a player actually sees and would search by.
        /// </summary>
        private static IEnumerable<uint> GetSearchableSpellIds(WorldObject wo)
        {
            var seen = new HashSet<uint>();

            if (wo.SpellDID.HasValue && seen.Add(wo.SpellDID.Value))
                yield return wo.SpellDID.Value;

            if (wo.ProcSpell.HasValue && seen.Add(wo.ProcSpell.Value))
                yield return wo.ProcSpell.Value;

            var woSpellDID = wo.SpellDID;
            var woProcSpell = wo.ProcSpell;

            foreach (var spellId in wo.Biota.GetKnownSpellsIdsWhere(i => i != woSpellDID && i != woProcSpell, wo.BiotaDatabaseLock))
            {
                if (seen.Add((uint)spellId))
                    yield return (uint)spellId;
            }
        }

        /// <summary>
        /// Every PropertyInt whose name ends in "Rating" (CritRating, DamageRating,
        /// GearCreatureSlayerRating, etc.) -- these aren't live/displayed in this version of the
        /// game, but the raw values still sit on the biota, so /mule search can match them even
        /// though nothing in-game shows them as text.
        /// </summary>
        private static readonly PropertyInt[] RatingProperties = Enum.GetValues(typeof(PropertyInt))
            .Cast<PropertyInt>()
            .Where(p => p.ToString().EndsWith("Rating", StringComparison.Ordinal))
            .Distinct()
            .ToArray();

        /// <summary>
        /// The text /mule search matches its regex against for a single item: its spell names, its
        /// equipment set (matched by the raw EquipmentSet enum identifier, e.g. "Adepts" -- the
        /// server has no in-game display-name string for sets, only this internal id), and any
        /// non-zero *Rating property, formatted as "PropertyName +N" so a pattern like
        /// "legendary.*\+1" can match a specific rating value. Everything is one entry per line so
        /// ".*" in a pattern can span from one entry into the next (e.g. "legendary frost.*legendary
        /// acid" matching an item that has both cantrips).
        /// </summary>
        private static string BuildItemSearchText(WorldObject wo)
        {
            var lines = new List<string>();

            lines.AddRange(GetSearchableSpellIds(wo)
                .Select(id => new Spell(id, false))
                .Where(spell => spell._spellBase != null) // NotFound requires the DB-backed _spell, which loadDB:false never populates
                .Select(spell => spell.Name));

            if (wo.EquipmentSetId.HasValue && wo.EquipmentSetId.Value != EquipmentSet.Invalid)
                lines.Add(wo.EquipmentSetId.Value.ToString());

            foreach (var prop in RatingProperties)
            {
                var value = wo.GetProperty(prop);
                if (value.HasValue && value.Value != 0)
                    lines.Add($"{prop} +{value.Value}");
            }

            return string.Join("\n", lines);
        }

        /// <summary>Groups items for display: combat gear, then worn gear, then salvage, then everything else.</summary>
        private static int MuleCategoryRank(WorldObject wo)
        {
            if ((wo.ItemType & ItemType.MeleeWeapon) != 0) return 0;
            if ((wo.ItemType & ItemType.MissileWeapon) != 0) return 1;
            if ((wo.ItemType & ItemType.Caster) != 0) return 2;
            if ((wo.ItemType & ItemType.Armor) != 0) return 3;
            if ((wo.ItemType & ItemType.Clothing) != 0) return 4;
            if ((wo.ItemType & ItemType.Jewelry) != 0) return 5;
            if ((wo.ItemType & ItemType.TinkeringMaterial) != 0) return 6;
            return 7;
        }

        /// <summary>
        /// Orders a mule's items for display. Vendor.UniqueItemsForSale is a Dictionary, but its
        /// insertion order is what the client displays (see the existing precedent in
        /// Vendor.RestockRandomItems(), which rebuilds UniqueItemsForSale from an OrderBy for the
        /// same reason) -- so callers must insert in the order returned here.
        /// <para/>
        /// Primary grouping is MuleCategoryRank (combat gear, worn gear, salvage, everything else).
        /// Within combat gear (melee/missile/casters), the secondary/tertiary keys are the skill
        /// needed to use it, then how hard it is to wield (lower requirement first). Within worn
        /// gear (armor/clothing/jewelry), it's equip slot -- EquipMask's bit values already run
        /// head-to-toe (and neck/wrist/finger for jewelry) in numeric order, so sorting on the raw
        /// mask value alone gives a sensible slot grouping -- then wield requirement. Salvage
        /// groups by material, then workmanship. Everything else just groups by ItemType. All
        /// groups finish with a name sort.
        /// </summary>
        private static IEnumerable<WorldObject> SortMuleItems(IEnumerable<WorldObject> items) =>
            items
                .OrderBy(MuleCategoryRank)
                .ThenBy(i => MuleCategoryRank(i) switch
                {
                    0 or 1 or 2 => i.WeaponSkill.ToString(),
                    3 or 4 or 5 => ((uint)(i.ValidLocations ?? 0)).ToString("D10"),
                    6 => i.MaterialType?.ToString() ?? "",
                    _ => i.ItemType.ToString()
                }, StringComparer.Ordinal)
                .ThenBy(i => MuleCategoryRank(i) == 6 ? (i.Workmanship ?? 0) : (i.WieldDifficulty ?? 0))
                .ThenBy(i => i.Name);

        /// <summary>
        /// Items eligible for the mule's artificial stack-size boost (if they weren't already --
        /// many template items like keys have no MaxStackSize at all normally) up to
        /// MuleBoostedStackSize while sitting in mule storage, so e.g. 1000 trade notes or keys can
        /// live in a single slot. Scoped to MuleInfo.BoostableItemTypes -- template items with no
        /// per-instance random/generated data -- not "is already stackable": unique loot
        /// (weapons/armor/casters/jewelry/clothing) must never be merged, and naturally-Stackable
        /// Salvage is excluded too since its Workmanship varies per batch and an artificial boost
        /// would be meaningless for it (it still merges normally, just at its natural cap).
        /// <para/>
        /// Also excludes anything with per-instance uses-remaining state, the same category of
        /// problem as Workmanship: a Sturdy Iron Keyring holds a limited number of keys
        /// (Structure/MaxStructure -- "32 uses left out of 50"), and merging two keyrings with
        /// different uses remaining into one StackSize would silently discard that distinction (and
        /// worse, for anything that actually holds sub-inventory, orphan whatever's inside). Only
        /// an item at full/untouched uses is safe to merge -- Structure == MaxStructure, or no
        /// Structure concept at all. UnlimitedUse is excluded outright for the same reason: it's a
        /// per-instance override that other instances of the same wcid may not share.
        /// </summary>
        private static bool IsMuleStackBoostable(WorldObject wo) =>
            wo.Workmanship == null
            && !wo.UnlimitedUse
            && (wo.Structure == null || wo.Structure == wo.MaxStructure)
            && (MuleInfo.BoostableItemTypes & wo.ItemType) != 0
            && !IsMuleUniqueItem(wo);

        /// <summary>
        /// JawnTide: true for an item that is no longer the same as every other copy of its weenie, so it must never be merged
        /// into a stack (or handed out as a fresh copy of the weenie). Opened aetheria keeps the coalesced aetheria's wcid but
        /// gets a set, a surge spell and a new icon; a charged mana stone holds mana; a book has its own pages; an inscribed
        /// or renamed item has its own text. Merging any of these by wcid lost their state, or (withdrawing a mixed stack,
        /// which hands out fresh copies) turned an opened aetheria back into an unopened one.
        /// </summary>
        private static bool IsMuleUniqueItem(WorldObject wo)
        {
            if (Aetheria.IsAetheria(wo.WeenieClassId) || wo is Book)
                return true;

            if (!string.IsNullOrEmpty(wo.GetProperty(PropertyString.Inscription)) || (wo.GetProperty(PropertyInt64.ItemTotalXp) ?? 0) > 0)
                return true;

            var weenie = DatabaseManager.World.GetCachedWeenie(wo.WeenieClassId);
            if (weenie == null)
                return true;

            return wo.IconId != (weenie.GetProperty(PropertyDataId.Icon) ?? 0)
                || wo.GetProperty(PropertyDataId.ProcSpell) != weenie.GetProperty(PropertyDataId.ProcSpell)
                || wo.GetProperty(PropertyInt.EquipmentSetId) != weenie.GetProperty(PropertyInt.EquipmentSetId)
                || wo.GetProperty(PropertyInt.ItemCurMana) != weenie.GetProperty(PropertyInt.ItemCurMana)
                || wo.GetProperty(PropertyInt.ItemMaxMana) != weenie.GetProperty(PropertyInt.ItemMaxMana)
                || wo.GetProperty(PropertyInt.ImbuedEffect) != weenie.GetProperty(PropertyInt.ImbuedEffect)
                || wo.GetProperty(PropertyInt.NumTimesTinkered) != weenie.GetProperty(PropertyInt.NumTimesTinkered)
                || wo.Name != weenie.GetProperty(PropertyString.Name)
                || wo.Biota.GetKnownSpellsIds(wo.BiotaDatabaseLock).Count != (weenie.PropertiesSpellBook?.Count ?? 0);
        }

        private const ushort MuleBoostedStackSize = 1000;

        /// <summary>
        /// JawnTide: true for an item whose copies are all the same, so StackSize alone describes it. False for salvage
        /// (TinkeringMaterial: each bag has its own units in Structure and its own Workmanship), anything with
        /// Workmanship, and anything part-used (Structure below MaxStructure).
        /// </summary>
        private static bool IsMulePlainStack(WorldObject wo) =>
            (wo.ItemType & ItemType.TinkeringMaterial) == 0
            && wo.Workmanship == null
            && !wo.UnlimitedUse
            && (wo.Structure == null || wo.Structure == wo.MaxStructure)
            && !IsMuleUniqueItem(wo);

        /// <summary>
        /// Stores a detached, already-removed-from-the-player item into mule storage -- merging
        /// into an existing stack across the whole chain if it's stackable in any sense (boosting
        /// its MaxStackSize first if it's an artificially-boostable template item), or adding it to
        /// the deposit-target container otherwise. Every biota actually mutated (items and/or
        /// containers) is added to touched so the caller can save exactly those, once, instead of
        /// blanket-resaving the whole chain -- WorldObject.SaveBiotaToDatabase() has no dirty-check,
        /// so calling it on every item in a large chain on every transaction is a real cost.
        /// </summary>
        private void StoreDepositedItem(List<Container> containers, WorldObject toDeposit, HashSet<WorldObject> touched)
        {
            var boostable = IsMuleStackBoostable(toDeposit);

            // JawnTide: salvage bags (and anything else with its own workmanship / uses left) never merge. Each bag
            // keeps its own units and workmanship, so "merging" it just bumped the old bag's StackSize and deleted
            // the new bag. They are stored one per slot.
            if (boostable || ((toDeposit.MaxStackSize ?? 0) > 1 && IsMulePlainStack(toDeposit)))
            {
                if (boostable)
                {
                    // WorldObject.SetStackSize() no-ops unless the object's actual C# class is
                    // Stackable (`if (!(this is Stackable)) return;`) -- a Key, for example, is a
                    // WorldObject subclass, not Stackable, so that guard silently blocks it even
                    // though StackSize/MaxStackSize themselves are plain properties with no such
                    // restriction. MergeOrAddAcrossChain sidesteps it via direct property assignment.
                    toDeposit.MaxStackSize = Math.Max(toDeposit.MaxStackSize ?? 0, MuleBoostedStackSize);
                    if (!toDeposit.StackSize.HasValue)
                        toDeposit.StackSize = 1;
                }

                MergeOrAddAcrossChain(containers, toDeposit, touched);
                return;
            }

            AddToMuleStorage(containers, toDeposit, touched);
        }

        /// <summary>
        /// Merges a deposited stackable item into an existing same-wcid stack anywhere in the
        /// player's mule storage chain (whichever has spare room first), adding the leftover via
        /// AddToMuleStorage() if anything remains -- all via direct StackSize property assignment,
        /// not SetStackSize()/Container.MergeAllStackables(), since those silently no-op for
        /// non-Stackable-classed items like keys (see IsMuleStackBoostable's comment). Used for
        /// both artificially-boosted items and naturally-Stackable ones (e.g. Salvage) alike.
        /// </summary>
        private void MergeOrAddAcrossChain(List<Container> containers, WorldObject toDeposit, HashSet<WorldObject> touched)
        {
            var remaining = toDeposit.StackSize ?? 1;

            foreach (var container in containers)
            {
                foreach (var existing in container.Inventory.Values)
                {
                    if (existing.WeenieClassId != toDeposit.WeenieClassId || !IsMulePlainStack(existing))
                        continue;

                    var room = (existing.MaxStackSize ?? 0) - (existing.StackSize ?? 1);
                    if (room <= 0)
                        continue;

                    var moved = Math.Min(remaining, room);
                    existing.StackSize = (existing.StackSize ?? 1) + moved;
                    touched.Add(existing);
                    remaining -= moved;

                    if (remaining <= 0)
                        break;
                }

                if (remaining <= 0)
                    break;
            }

            if (remaining <= 0)
            {
                toDeposit.Destroy(); // handles its own DB removal -- nothing to add to touched
                return;
            }

            toDeposit.StackSize = remaining;
            AddToMuleStorage(containers, toDeposit, touched);
        }

        /// <summary>
        /// Adds a detached item to the mule's deposit-target container. If the whole chain is full
        /// (MuleInfo.MaxContainers containers, all at capacity), the item is returned to the
        /// player's own inventory instead -- it was already removed from them earlier in the
        /// deposit flow, so it must go somewhere rather than be silently destroyed.
        /// </summary>
        private void AddToMuleStorage(List<Container> containers, WorldObject toDeposit, HashSet<WorldObject> touched)
        {
            var target = GetOrCreateMuleDepositTarget(containers, touched);

            if (target != null && target.TryAddToInventory(toDeposit, burdenCheck: false))
            {
                touched.Add(target);
                touched.Add(toDeposit);
                return;
            }

            Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session,
                $"Your mule's storage is completely full ({MuleInfo.MaxContainers * 255} items) -- {toDeposit.Name} couldn't be stored."));

            if (!TryCreateInInventoryWithNetworking(toDeposit, out _))
            {
                log.Error($"[MULE] {Name} (0x{Guid}) deposit of {toDeposit.Name} (0x{toDeposit.Guid}) couldn't be stored (mule full) and failed to return to inventory.");
                toDeposit.Destroy();
            }
        }

        /// <summary>
        /// JawnTide: sets the My Mule gem's description to what it does plus how many of this account's mule slots are used.
        /// Counted from the loaded mule if it's been summoned this session, otherwise from the database.
        /// </summary>
        public void UpdateMuleGemText(WorldObject gem)
        {
            var total = MuleInfo.MaxContainers * 255;
            int? used = null;

            try
            {
                if (ActiveMuleContainers != null)
                    used = ActiveMuleContainers.Sum(c => c.Inventory.Count);
                else if (Account != null)
                {
                    var db = DatabaseManager.Shard.BaseDatabase;
                    used = db.MarketGetMuleChain(Account.AccountId).Sum(c => db.MarketCountContainerItems(c));
                }
            }
            catch (Exception ex)
            {
                log.Warn($"[MULE] {Name} couldn't count mule slots for the gem: {ex.Message}");
            }

            var text = "Summons your account's mule: storage shared by every character on your account, and by any guests you add with /mule storage add NAME. " +
                       "Use it again to send the mule away. Store items by selling them to it and take them back by buying them, free.";

            if (used.HasValue)
                text += $"\n\nMule storage: {used.Value:N0} of {total:N0} slots used ({total - used.Value:N0} free).";

            gem.SetProperty(PropertyString.LongDesc, text);
        }

        /// <summary>
        /// Called from Player_Commerce.HandleActionSellItem when the target vendor is a mule.
        /// Deposits items into the mule's persistent storage at no cost. Allowed for the owner, or
        /// any character the owner's house has granted storage access to (see
        /// CanAccessMuleStorage).
        /// </summary>
        public void HandleMuleDeposit(Vendor vendor, List<ItemProfile> itemProfiles)
        {
            if (!CanAccessMuleStorage(vendor) || vendor.MuleContainers == null)
            {
                SendTransientError("You don't have permission to use this mule.");
                SendUseDoneEvent();
                return;
            }

            if (PKTimerActive)
            {
                SendTransientError("You can't use your mule while you're PK tagged.");
                SendUseDoneEvent();
                return;
            }

            var allPossessions = GetAllPossessions().ToDictionary(i => i.Guid.Full, i => i);
            var processedGuids = new HashSet<uint>();
            var touched = new HashSet<WorldObject>();
            var guestMoved = IsMuleGuestOf(vendor) ? new List<(WorldObject item, int amount)>() : null;

            // JawnTide: say why an item was skipped, so nothing leaves the sell window without a trace (log and player)
            void Skip(string why, uint guid, WorldObject item, int amount)
            {
                log.Warn($"[MULE] {Name} (0x{Guid}) deposit skipped 0x{guid:X8} {item?.Name ?? "?"} x{amount} (StackSize {item?.StackSize}, ItemType {item?.ItemType}): {why}");
                Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, $"{item?.Name ?? "That item"} couldn't be stored ({why})."));
                Session.Network.EnqueueSend(new GameEventInventoryServerSaveFailed(Session, guid));
            }

            log.Info($"[MULE] {Name} (0x{Guid}) deposit request: {string.Join(", ", itemProfiles.Select(p => $"0x{p.ObjectGuid:X8} x{p.Amount}"))}");

            foreach (var itemProfile in itemProfiles)
            {
                if (!processedGuids.Add(itemProfile.ObjectGuid))
                    continue;

                allPossessions.TryGetValue(itemProfile.ObjectGuid, out var wo);

                if (!itemProfile.IsValidAmount)
                {
                    Skip("bad amount", itemProfile.ObjectGuid, wo, itemProfile.Amount);
                    continue;
                }

                if (wo == null)
                {
                    Skip("not in your inventory", itemProfile.ObjectGuid, null, itemProfile.Amount);
                    continue;
                }

                if (itemProfile.Amount > (wo.StackSize ?? 1))
                {
                    Skip($"asked for {itemProfile.Amount}, stack is {wo.StackSize ?? 1}", itemProfile.ObjectGuid, wo, itemProfile.Amount);
                    continue;
                }

                if (wo.ItemType == ItemType.Money || wo.WeenieType == WeenieType.Container)
                {
                    Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, "You cannot store currency or containers in your mule."));
                    continue;
                }

                // Attuned (and Sticky, a stricter attunement) items are tied to whoever they're
                // currently attuned to -- block them specifically, since the mule is now
                // account-wide and shareable with house storage guests (see CanAccessMuleStorage),
                // so an attuned item could otherwise get deposited by one character/guest and
                // withdrawn by another.
                if (wo.Attuned >= AttunedStatus.Attuned)
                {
                    Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, $"{wo.Name} is attuned and cannot be stored in your mule."));
                    continue;
                }

                // JawnTide: Darkbeat, Hera and Shimmering Skeleton keys stay at risk while carried (no bank, no mule)
                if (BankInfo.Currencies.Any(c => c.WithdrawOnly && c.Wcid == wo.WeenieClassId))
                {
                    Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, $"{wo.Name} cannot be stored in your mule."));
                    continue;
                }

                // No Bonded/IsSellable/Retained/item-category checks here: the mule is personal
                // storage that never changes ownership (deposits/withdrawals are always zero-cost,
                // non-transactional moves, even when made by a guest with house storage access
                // rather than the owner), so none of that applies; storing here is no different
                // from putting the item in the owner's own pack or house chest, which the game
                // already allows unrestricted for anyone with storage access.

                WorldObject toDeposit;

                if (itemProfile.Amount < (wo.StackSize ?? 1))
                {
                    toDeposit = WorldObjectFactory.CreateNewWorldObject(wo.WeenieClassId);
                    if (toDeposit == null)
                        continue;

                    toDeposit.SetStackSize(itemProfile.Amount);

                    wo.SetStackSize((wo.StackSize ?? 1) - itemProfile.Amount);
                    Session.Network.EnqueueSend(new GameMessageSetStackSize(wo));

                    // JawnTide: save the player's smaller stack now, before the mule's copy is saved at the end of this
                    // deposit (same save queue, in order), so a crash in between can only lose the part, never duplicate it.
                    wo.SaveBiotaToDatabase();
                }
                else
                {
                    if (!(TryRemoveFromInventoryWithNetworking(wo.Guid, out toDeposit, RemoveFromInventoryAction.SellItem) ||
                          TryDequipObjectWithNetworking(wo.Guid, out toDeposit, DequipObjectAction.SellItem)))
                    {
                        Skip("couldn't be taken from your pack", wo.Guid.Full, wo, itemProfile.Amount);
                        continue;
                    }

                    Session.Network.EnqueueSend(new GameEventItemServerSaysContainId(Session, toDeposit, vendor));
                }

                // Vendor.ApproachVendor() -> RotUniques() runs on every approach and logs a
                // warning for any UniqueItemsForSale entry with no SoldTimestamp; stamping it
                // here avoids that noise. The mule vendor weenie sets VendorStockTimeToRot to
                // ~20 years so this timestamp never actually causes the item to rot/be removed.
                toDeposit.SoldTimestamp = Time.GetUnixTime();

                guestMoved?.Add((toDeposit, toDeposit.StackSize ?? 1));

                StoreDepositedItem(vendor.MuleContainers, toDeposit, touched);
            }

            if (touched.Count > 0)
            {
                foreach (var wo in touched)
                    wo.SaveBiotaToDatabase();

                // JawnTide Marketplace: icons and details of the new items, for the website's My Market page
                ACE.Server.Managers.MarketManager.QueueIcons(touched);

                Session.Network.EnqueueSend(new GameMessageSound(Guid, Sound.PickUpItem));

                RefreshMuleVendorDisplay(vendor, VendorType.Sell);
            }

            if (guestMoved != null)
                ReportMuleGuestUse(vendor, true, guestMoved);

            SendUseDoneEvent();
        }

        /// <summary>
        /// Called from Player_Commerce.HandleActionBuyItem when the target vendor is a mule.
        /// Withdraws items from the mule's persistent storage at no cost. Allowed for the owner, or
        /// any character the owner's house has granted storage access to (see
        /// CanAccessMuleStorage).
        /// </summary>
        public void HandleMuleWithdraw(Vendor vendor, List<ItemProfile> itemProfiles)
        {
            if (!CanAccessMuleStorage(vendor) || vendor.MuleContainers == null)
            {
                SendUseDoneEvent(WeenieError.NoObject);
                return;
            }

            if (PKTimerActive)
            {
                SendTransientError("You can't use your mule while you're PK tagged.");
                SendUseDoneEvent();
                return;
            }

            var itemsToReceive = new ItemsToReceive(this);
            var withdrawals = new List<(WorldObject item, int amount, Container container)>();
            var processedGuids = new HashSet<uint>();

            foreach (var itemProfile in itemProfiles)
            {
                if (!processedGuids.Add(itemProfile.ObjectGuid))
                    continue;

                if (!itemProfile.IsValidAmount)
                    continue;

                var itemGuid = new ObjectGuid(itemProfile.ObjectGuid);
                var container = ResolveMuleItemContainer(vendor.MuleContainers, itemGuid);

                if (container == null || !container.Inventory.TryGetValue(itemGuid, out var item))
                    continue;

                if (itemProfile.Amount > (item.StackSize ?? 1))
                    continue;

                itemsToReceive.Add(item.WeenieClassId, itemProfile.Amount);
                withdrawals.Add((item, itemProfile.Amount, container));
            }

            if (withdrawals.Count == 0)
            {
                SendUseDoneEvent();
                return;
            }

            if (itemsToReceive.PlayerExceedsLimits)
            {
                if (itemsToReceive.PlayerExceedsAvailableBurden)
                    Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, "You are too encumbered to withdraw that!"));
                else if (itemsToReceive.PlayerOutOfInventorySlots)
                    Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, "You do not have enough pack space to withdraw that!"));
                else if (itemsToReceive.PlayerOutOfContainerSlots)
                    Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, "You do not have enough container slots to withdraw that!"));

                SendUseDoneEvent();
                return;
            }

            // JawnTide: a guest's withdrawal is recorded now, while the items still have their names and values
            if (IsMuleGuestOf(vendor))
                ReportMuleGuestUse(vendor, false, withdrawals.Select(w => (w.item, w.amount)).ToList());

            // Every biota actually mutated (items and/or containers) -- saved exactly once at the
            // end instead of blanket-resaving every item in every touched container.
            // WorldObject.SaveBiotaToDatabase() has no dirty-check, so calling it on everything in
            // a large chain on every transaction is a real cost.
            var touched = new HashSet<WorldObject>();

            foreach (var (item, requestedAmount, container) in withdrawals)
            {
                var amount = requestedAmount;

                // JawnTide: a unique item (opened aetheria, charged mana stone, ...) that was wrongly merged into a stack
                // before the fix. The stack is this item plus plain copies that were merged into it: the copies come out
                // as fresh items, and this item itself (with its stats) comes out last, on its own.
                if ((item.StackSize ?? 1) > 1 && IsMuleUniqueItem(item))
                {
                    var stack = item.StackSize ?? 1;
                    var whole = amount >= stack;
                    var copies = whole ? stack - 1 : amount;

                    for (var i = 0; i < copies; i++)
                    {
                        var copy = WorldObjectFactory.CreateNewWorldObject(item.WeenieClassId);
                        if (copy == null || !TryCreateInInventoryWithNetworking(copy, out _))
                        {
                            log.Error($"[MULE] {Name} (0x{Guid}) couldn't withdraw a copy of {item.Name} (0x{item.Guid}) from a merged stack; {stack - i} left in the stack.");
                            copy?.Destroy();
                            copies = i;
                            whole = false;
                            break;
                        }
                    }

                    if (whole)
                    {
                        var weenie = DatabaseManager.World.GetCachedWeenie(item.WeenieClassId);
                        item.StackSize = null;
                        item.MaxStackSize = (ushort?)weenie?.GetProperty(PropertyInt.MaxStackSize);
                        container.TryRemoveFromInventory(item.Guid, out var self);
                        vendor.UniqueItemsForSale.Remove(item.Guid);
                        touched.Add(container);

                        if (self != null && !TryCreateInInventoryWithNetworking(self, out _))
                        {
                            log.Error($"[MULE] {Name} (0x{Guid}) withdrawal of {self.Name} (0x{self.Guid}) failed after passing validation, returning it to storage.");
                            container.TryAddToInventory(self, burdenCheck: false);
                            touched.Add(self);
                        }
                    }
                    else
                    {
                        item.StackSize = stack - copies;
                        touched.Add(item);
                    }

                    continue;
                }

                if (IsMuleStackBoostable(item))
                {
                    // This item's MaxStackSize may be boosted (MuleBoostedStackSize) from sitting in
                    // mule storage -- never hand that instance, or a copy of it, to the player. Shrink
                    // or remove the mule-side stack, then mint fresh stack(s) at the item's normal
                    // (weenie-defined) cap to give out instead.
                    if (amount < (item.StackSize ?? 1))
                    {
                        // Direct property assignment, not SetStackSize() -- see the deposit-site
                        // comment on IsMuleStackBoostable for why that method silently no-ops here.
                        item.StackSize = (item.StackSize ?? 1) - amount;
                        touched.Add(item);
                    }
                    else
                    {
                        // Full stack withdrawn: the mule-side item is fully replaced by the
                        // freshly-minted stack(s) below, so it must be destroyed here, not just
                        // detached in memory. TryRemoveFromInventory() only clears ContainerId on
                        // the live object (forceSave defaults to false) -- its DB row would still
                        // carry the old ContainerId pointing at this mule container, so it would
                        // silently reappear (an effective dupe) the next time the container reloads
                        // from the DB on re-summon.
                        container.TryRemoveFromInventory(item.Guid, out var removedStack);
                        vendor.UniqueItemsForSale.Remove(item.Guid);
                        touched.Add(container); // TryRemoveFromInventory updated its EncumbranceVal/Value
                        removedStack?.Destroy(); // handles its own DB removal -- nothing to add to touched
                    }

                    var remaining = amount;
                    while (remaining > 0)
                    {
                        var freshStack = WorldObjectFactory.CreateNewWorldObject(item.WeenieClassId);
                        if (freshStack == null)
                            break;

                        // Falls back to 1 (not `remaining`), not the whole requested amount: an item
                        // that has no natural MaxStackSize at all (e.g. keys) isn't really stackable
                        // outside the mule, so each fresh stack handed to the player must be a single
                        // instance -- matching what ItemsToReceive already validated slots for above.
                        var cap = freshStack.MaxStackSize.HasValue ? (int)freshStack.MaxStackSize.Value : 1;
                        var stackAmount = Math.Min(remaining, cap);
                        freshStack.SetStackSize(stackAmount);
                        remaining -= stackAmount;

                        if (!TryCreateInInventoryWithNetworking(freshStack, out _))
                        {
                            log.Error($"[MULE] {Name} (0x{Guid}) withdrawal of {freshStack.Name} (0x{freshStack.Guid}) failed after passing validation.");
                            freshStack.Destroy();
                            break;
                        }
                    }

                    continue;
                }

                WorldObject toGive;

                // JawnTide: a salvage bag that was wrongly merged before the fix has StackSize > 1, but only one bag's
                // units. Hand over the whole object as a single bag (never mint a fresh default bag from the weenie).
                if (!IsMulePlainStack(item) && (item.StackSize ?? 1) > 1)
                {
                    log.Warn($"[MULE] {Name} (0x{Guid}) withdrew {item.Name} (0x{item.Guid}) with StackSize {item.StackSize} (merged before the salvage fix); reset to 1.");
                    item.StackSize = 1;
                    amount = 1;
                }

                if (amount < (item.StackSize ?? 1))
                {
                    toGive = WorldObjectFactory.CreateNewWorldObject(item.WeenieClassId);
                    if (toGive == null)
                        continue;

                    toGive.SetStackSize(amount);

                    item.SetStackSize((item.StackSize ?? 1) - amount);
                    touched.Add(item);
                }
                else
                {
                    container.TryRemoveFromInventory(item.Guid, out toGive);
                    vendor.UniqueItemsForSale.Remove(item.Guid);
                    touched.Add(container); // TryRemoveFromInventory updated its EncumbranceVal/Value
                }

                // Pre-validated above via ItemsToReceive, so this shouldn't fail -- but this is
                // persistent storage, so on the off chance it does, put the item back rather
                // than let it fall on the floor (TryCreateInInventoryWithNetworking would
                // otherwise leave an orphaned biota with no owner).
                if (!TryCreateInInventoryWithNetworking(toGive, out _))
                {
                    log.Error($"[MULE] {Name} (0x{Guid}) withdrawal of {toGive.Name} (0x{toGive.Guid}) failed after passing validation, returning it to storage.");
                    container.TryAddToInventory(toGive, burdenCheck: false);
                    touched.Add(container);
                    touched.Add(toGive);
                }
            }

            foreach (var wo in touched)
                wo.SaveBiotaToDatabase();

            Session.Network.EnqueueSend(new GameMessageSound(Guid, Sound.PickUpItem));

            RefreshMuleVendorDisplay(vendor, VendorType.Buy);

            SendUseDoneEvent();
        }
    }
}
