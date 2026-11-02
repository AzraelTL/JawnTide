using System;

using ACE.Database;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Entity.Enum.Properties;
using ACE.Server.Entity;
using ACE.Server.Entity.Actions;
using ACE.Server.Factories;
using ACE.Server.Managers;
using ACE.Server.Network.GameEvent.Events;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    /// <summary>
    /// JawnTide: Mule Imprint Tokens and the Ghost of [Mule]. See MuleImprintToken and MuleGhost.
    /// </summary>
    partial class Player
    {
        // ---------------------------------------------------------------------
        // Persistent flags
        // ---------------------------------------------------------------------

        /// <summary>
        /// This character was imprinted as another character's mule. Permanent.
        /// </summary>
        public bool IsMule
        {
            get => GetProperty(PropertyBool.IsMuleCharacter) ?? false;
            set { if (!value) RemoveProperty(PropertyBool.IsMuleCharacter); else SetProperty(PropertyBool.IsMuleCharacter, value); }
        }

        /// <summary>
        /// This character has been given its one Mule Imprint Token. Permanent: a character only ever gets one.
        /// </summary>
        public bool ReceivedMuleImprintToken
        {
            get => GetProperty(PropertyBool.ReceivedMuleImprintToken) ?? false;
            set { if (!value) RemoveProperty(PropertyBool.ReceivedMuleImprintToken); else SetProperty(PropertyBool.ReceivedMuleImprintToken, value); }
        }

        /// <summary>
        /// On an owner: the character imprinted as this character's mule.
        /// </summary>
        public uint? MuleImprintMule
        {
            get => GetProperty(PropertyInstanceId.MuleImprintMule);
            set { if (!value.HasValue) RemoveProperty(PropertyInstanceId.MuleImprintMule); else SetProperty(PropertyInstanceId.MuleImprintMule, value.Value); }
        }

        /// <summary>
        /// On a mule: the character this mule belongs to.
        /// </summary>
        public uint? MuleImprintOwner
        {
            get => GetProperty(PropertyInstanceId.MuleImprintOwner);
            set { if (!value.HasValue) RemoveProperty(PropertyInstanceId.MuleImprintOwner); else SetProperty(PropertyInstanceId.MuleImprintOwner, value.Value); }
        }

        // ---------------------------------------------------------------------
        // Session state
        // ---------------------------------------------------------------------

        public const int MuleImprintPromptSeconds = 60;

        private ObjectGuid? pendingMuleImprintToken;
        private DateTime pendingMuleImprintExpires;

        private bool muleGhostSummonInProgress;
        private DateTime nextMuleGhostSummonTime;

        private void SendMuleImprintMessage(string msg)
        {
            Session.Network.EnqueueSend(new GameMessageSystemChat(msg, ChatMessageType.Broadcast));
        }

        // ---------------------------------------------------------------------
        // The Imprinter NPCs
        // ---------------------------------------------------------------------

        /// <summary>
        /// Called when a player uses one of the three Imprinter NPCs.
        /// </summary>
        public void HandleMuleImprinterNpc(WorldObject npc)
        {
            void Tell(string msg) => Session.Network.EnqueueSend(new GameEventTell(npc, msg, this, ChatMessageType.Tell));

            MuleImprintToken.ImprinterNpcs.TryGetValue(npc.WeenieClassId, out var greeting);

            if (IsMule)
            {
                Tell($"I sense the imprint of another already upon you, {Name}. A mule carries no token of its own.");
                return;
            }

            if (ReceivedMuleImprintToken || GetMuleImprintToken() != null)
            {
                Tell($"You already carry your Mule Imprint Token, {Name}. Each soul is given only one, and it will never leave you.");
                return;
            }

            if (IsOlthoiPlayer)
            {
                Tell("The Olthoi have no use for pack-bearers.");
                return;
            }

            var token = WorldObjectFactory.CreateNewWorldObject(MuleImprintToken.TokenWcid) as MuleImprintToken;

            if (token == null)
            {
                log.Error($"[MuleImprint] {Name}: Mule Imprint Token weenie {MuleImprintToken.TokenWcid} is missing or is not WeenieType.MuleImprintToken");
                Tell("Hmm, my tokens seem to have gone missing. Please let an admin know.");
                return;
            }

            token.TokenOwner = Guid.Full;
            token.UpdateDescription();

            if (!TryCreateInInventoryWithNetworking(token))
            {
                token.Destroy();
                Tell("Your pack is too full to take the token. Make some room and come back to me.");
                return;
            }

            ReceivedMuleImprintToken = true;

            if (!string.IsNullOrEmpty(greeting))
                Tell(greeting);

            Tell("Take this Mule Imprint Token. It is bound to your soul and will never leave you.");
            Tell($"First log in on the companion you want as your mule (level {MuleImprintToken.MaxMuleLevel} or lower, from your own account) and have it type /muleflag. Then come back here, use the token and name it. Both steps are permanent, so choose with care.");
            Tell("Once imprinted, use the token to call your mule's ghost. Hand the ghost anything and it will be waiting in your mule's pack.");

            Session.Network.EnqueueSend(new GameMessageSystemChat($"{npc.Name} gives you {token.Name}.", ChatMessageType.Broadcast));
            npc.EnqueueBroadcast(new GameMessageSound(npc.Guid, Sound.ReceiveItem));

            RushNextPlayerSave(5);

            log.Info($"[MuleImprint] {Name} (0x{Guid}) received Mule Imprint Token 0x{token.Guid} from {npc.Name}");
        }

        // ---------------------------------------------------------------------
        // Using the token
        // ---------------------------------------------------------------------

        public void HandleMuleImprintTokenUse(MuleImprintToken token)
        {
            if (IsBusy || Teleporting || suicideInProgress)
            {
                SendWeenieError(WeenieError.YoureTooBusy);
                return;
            }

            if (IsMule)
            {
                SendMuleImprintMessage("You are a mule yourself. The token stays cold in your hand.");
                return;
            }

            if (IsOlthoiPlayer)
            {
                SendMuleImprintMessage("The token does not respond to you.");
                return;
            }

            if (token.TokenOwner.HasValue && token.TokenOwner.Value != Guid.Full)
            {
                SendMuleImprintMessage("This token is attuned to another soul and does not respond to you.");
                return;
            }

            if (!token.IsBound)
            {
                BeginMuleImprintPrompt(token);
                return;
            }

            var mule = PlayerManager.FindByGuid(token.BoundMule.Value, out var muleOnline);

            if (mule == null || mule.IsDeleted)
            {
                // the mule character no longer exists: the token can be imprinted again
                SendMuleImprintMessage($"The spirit of {token.BoundMuleName} has passed beyond reach. The token is ready to take a new imprint.");

                token.ClearBinding();
                UpdateProperty(token, PropertyString.Name, token.Name);
                MuleImprintMule = null;

                BeginMuleImprintPrompt(token);
                return;
            }

            if (mule.IsPendingDeletion)
            {
                SendMuleImprintMessage($"{mule.Name} is waiting to be deleted. Their ghost cannot be called.");
                return;
            }

            // stow the ghost if it is out
            if (CurrentActivePet is MuleGhost activeGhost)
            {
                var ghostName = activeGhost.Name;
                activeGhost.Destroy();
                SendMuleImprintMessage($"The {ghostName} fades away.");
                return;
            }

            if (muleOnline || mule is not OfflinePlayer)
            {
                SendMuleImprintMessage($"{mule.Name} is in the world right now. Their ghost cannot be called while they walk Dereth.");
                return;
            }

            // no stashing loot mid-fight: the ghost can't be called while PK tagged
            if (PKTimerActive)
            {
                SendWeenieError(WeenieError.YouHaveBeenInPKBattleTooRecently);
                SendMuleImprintMessage($"The spirit of {mule.Name} will not come near the fighting. Wait until you have been out of player combat for a while.");
                return;
            }

            if (CurrentActivePet is CombatPet)
            {
                SendTransientError($"{CurrentActivePet.Name} is already active");
                return;
            }

            if (muleGhostSummonInProgress)
                return;

            if (DateTime.UtcNow < nextMuleGhostSummonTime)
            {
                SendMuleImprintMessage("The token is still gathering its strength. Try again in a moment.");
                return;
            }

            muleGhostSummonInProgress = true;
            nextMuleGhostSummonTime = DateTime.UtcNow.AddSeconds(5);

            var muleGuid = mule.Guid.Full;
            var tokenGuid = token.Guid;

            SendMuleImprintMessage($"You call out to the spirit of {mule.Name}...");

            // read the mule's pack from the database (this also waits for any hand-offs still being saved)
            DatabaseManager.Shard.GetPossessedBiotasInParallel(muleGuid, possessions =>
            {
                EnqueueAction(new ActionEventDelegate(() =>
                {
                    muleGhostSummonInProgress = false;
                    FinishMuleGhostSummon(tokenGuid, muleGuid, possessions);
                }));
            });
        }

        private void FinishMuleGhostSummon(ObjectGuid tokenGuid, uint muleGuid, ACE.Database.Entity.PossessedBiotas possessions)
        {
            if (CurrentLandblock == null || IsLoggingOut || Teleporting || possessions == null)
                return;

            var token = FindObject(tokenGuid.Full, SearchLocations.MyInventory) as MuleImprintToken;
            if (token == null || token.BoundMule != muleGuid)
                return;

            if (CurrentActivePet is MuleGhost)
                return;

            if (PKTimerActive)
            {
                SendWeenieError(WeenieError.YouHaveBeenInPKBattleTooRecently);
                return;
            }

            var mule = PlayerManager.FindByGuid(muleGuid, out var muleOnline) as OfflinePlayer;
            if (mule == null || muleOnline)
            {
                SendMuleImprintMessage("Your mule's spirit could not be reached.");
                return;
            }

            if (CurrentActivePet != null)
            {
                if (CurrentActivePet is CombatPet)
                {
                    SendTransientError($"{CurrentActivePet.Name} is already active");
                    return;
                }

                // stow the current passive pet, as a pet device would
                CurrentActivePet.Destroy();
            }

            // keep the token's description current if the mule was renamed
            if (token.BoundMuleName != mule.Name)
            {
                token.Bind(muleGuid, mule.Name);
                UpdateProperty(token, PropertyString.Name, token.Name);
            }

            var ghost = MuleGhost.Summon(this, token, mule, possessions);

            if (ghost == null)
            {
                SendMuleImprintMessage("The spirit of your mule flickers, but will not take shape.");
                return;
            }

            SendMuleImprintMessage($"The {ghost.Name} rises beside you. Hand it anything you want carried to {mule.Name}. Use the token again to send it away.");
        }

        /// <summary>
        /// Called whenever this player is PK tagged (lands or takes a PvP hit): an active mule ghost is sent away.
        /// </summary>
        public void OnPkTaggedMuleGhost()
        {
            if (CurrentActivePet is not MuleGhost ghost || ghost.IsDestroyed || ghost.FleeQueued)
                return;

            // This runs inside the attacker's combat code, which may be on another landblock's thread.
            // Removing the ghost there directly is unsafe, so it is queued onto the ghost's own landblock.
            ghost.FleeQueued = true;

            ghost.EnqueueAction(new ActionEventDelegate(() =>
            {
                if (ghost.IsDestroyed)
                    return;

                var ghostName = ghost.Name;
                ghost.Destroy();
                SendMuleImprintMessage($"The {ghostName} flees from the fighting.");
            }));
        }

        // ---------------------------------------------------------------------
        // Imprinting (binding the token to a mule)
        // ---------------------------------------------------------------------

        private void BeginMuleImprintPrompt(MuleImprintToken token)
        {
            pendingMuleImprintToken = token.Guid;
            pendingMuleImprintExpires = DateTime.UtcNow.AddSeconds(MuleImprintPromptSeconds);

            Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, "Speak the name of the mule to imprint..."));

            SendMuleImprintMessage(
                "The Mule Imprint Token grows warm in your hand, waiting for a name.\n" +
                $"Say the name of the character on your account you flagged with /muleflag (just type it in chat within {MuleImprintPromptSeconds} seconds), " +
                "or use /muleimprint <character name>.");
        }

        /// <summary>
        /// Called from HandleActionTalk. If the player is being asked for a mule name, the spoken text is taken
        /// as the answer (and is not said out loud). Returns true if the speech was used.
        /// </summary>
        public bool TryHandleMuleImprintSpeech(string message)
        {
            if (!pendingMuleImprintToken.HasValue)
                return false;

            var tokenGuid = pendingMuleImprintToken.Value;
            pendingMuleImprintToken = null;

            if (DateTime.UtcNow > pendingMuleImprintExpires)
                return false;

            var token = FindObject(tokenGuid.Full, SearchLocations.MyInventory) as MuleImprintToken;
            if (token == null || token.IsBound)
                return false;

            var name = message?.Trim() ?? string.Empty;

            SendMuleImprintMessage($"You whisper \"{name}\" to the token...");

            TryMuleImprint(token, name, false);
            return true;
        }

        /// <summary>
        /// Finds the unbound Mule Imprint Token this character carries (for /muleimprint).
        /// </summary>
        public MuleImprintToken GetMuleImprintToken()
        {
            var tokens = GetInventoryItemsOfWCID(MuleImprintToken.TokenWcid);
            if (tokens == null)
                return null;

            foreach (var wo in tokens)
            {
                if (wo is MuleImprintToken token)
                    return token;
            }
            return null;
        }

        /// <summary>
        /// Validates the named character and, after a Yes/No confirmation, permanently imprints it as this character's mule.
        /// </summary>
        public void TryMuleImprint(MuleImprintToken token, string muleName, bool confirmed)
        {
            pendingMuleImprintToken = null;

            if (token == null || FindObject(token.Guid.Full, SearchLocations.MyInventory) != token)
            {
                SendMuleImprintMessage("You need your Mule Imprint Token with you to do that.");
                return;
            }

            if (token.IsBound)
            {
                SendMuleImprintMessage($"Your token already carries the imprint of {token.BoundMuleName}.");
                return;
            }

            if (IsMule)
            {
                SendMuleImprintMessage("You are a mule yourself and cannot imprint a mule of your own.");
                return;
            }

            if (!ValidateMuleCandidate(muleName, out var mule, out var error))
            {
                SendMuleImprintMessage(error);
                return;
            }

            if (!confirmed)
            {
                var msg = $"Imprint {mule.Name} as {Name}'s mule?\n\n" +
                          "This is PERMANENT and cannot be undone.\n\n" +
                          $"{mule.Name} will be flagged as a mule. Your token will call the Ghost of {mule.Name}, and anything you hand the ghost goes straight to {mule.Name}'s pack.\n\n" +
                          $"Only you can hand items to the ghost. {mule.Name} can still log in to collect them.";

                var capturedName = mule.Name;

                if (!ConfirmationManager.EnqueueSend(new Confirmation_Custom(Guid, () => TryMuleImprint(token, capturedName, true)), msg))
                    SendWeenieError(WeenieError.ConfirmationInProgress);

                return;
            }

            var offlineMule = (OfflinePlayer)mule;

            offlineMule.SetProperty(PropertyBool.IsMuleCharacter, true);
            offlineMule.SetProperty(PropertyInstanceId.MuleImprintOwner, Guid.Full);
            offlineMule.SaveBiotaToDatabase();

            MuleImprintMule = offlineMule.Guid.Full;

            token.TokenOwner = Guid.Full;
            token.Bind(offlineMule.Guid.Full, offlineMule.Name);
            UpdateProperty(token, PropertyString.Name, token.Name);

            RushNextPlayerSave(5);

            Session.Network.EnqueueSend(new GameMessageSound(Guid, Sound.UI_EnterPortal));
            SendMuleImprintMessage($"The token flares with light as the spirit of {offlineMule.Name} is imprinted upon it. {offlineMule.Name} is now your mule.");

            log.Info($"[MuleImprint] {Name} (0x{Guid}) imprinted {offlineMule.Name} (0x{offlineMule.Guid}) as a mule with token 0x{token.Guid}");

            // call the ghost right away
            HandleMuleImprintTokenUse(token);
        }

        /// <summary>
        /// A mule must be: another character on the same account, flagged with /muleflag, logged out, not deleted, level MuleImprintToken.MaxMuleLevel or lower,
        /// not already a mule, and not the owner of a mule itself.
        /// </summary>
        private bool ValidateMuleCandidate(string muleName, out IPlayer mule, out string error)
        {
            mule = null;
            error = null;

            muleName = muleName?.Trim().TrimStart('+');

            if (string.IsNullOrWhiteSpace(muleName))
            {
                error = "You must name the character to imprint as your mule.";
                return false;
            }

            mule = PlayerManager.FindByName(muleName, out var isOnline);

            if (mule == null)
            {
                error = $"There is no character named \"{muleName}\".";
                return false;
            }

            if (mule.Guid == Guid)
            {
                error = "You cannot imprint yourself as your own mule.";
                return false;
            }

            if (mule.Account == null || mule.Account.AccountId != Session.AccountId)
            {
                error = $"{mule.Name} is not a character on your account.";
                mule = null;
                return false;
            }

            if (mule.IsDeleted || mule.IsPendingDeletion)
            {
                error = $"{mule.Name} has been deleted or is waiting to be deleted.";
                return false;
            }

            if (isOnline || mule is not OfflinePlayer)
            {
                error = $"{mule.Name} must be logged out to accept the imprint.";
                return false;
            }

            var level = mule.Level ?? 1;
            if (level > MuleImprintToken.MaxMuleLevel)
            {
                error = $"Only a character of level {MuleImprintToken.MaxMuleLevel} or lower can accept a mule imprint. {mule.Name} is level {level}.";
                return false;
            }

            if (mule.IsTinker)
            {
                error = $"{mule.Name} is a Tinker and cannot become a mule.";
                return false;
            }

            if (!(mule.GetProperty(PropertyBool.IsMuleCharacter) ?? false))
            {
                error = $"{mule.Name} isn't flagged as a mule yet. Log in on {mule.Name} and type /muleflag first.";
                return false;
            }

            // a mule stays a mule for good, but if its owner has been deleted another character can claim it
            {
                var ownerGuid = mule.GetProperty(PropertyInstanceId.MuleImprintOwner);
                var owner = ownerGuid.HasValue ? PlayerManager.FindByGuid(ownerGuid.Value) : null;

                if (owner != null && !owner.IsDeleted)
                {
                    error = owner.Guid == Guid ? $"{mule.Name} is already your mule." : $"{mule.Name} is already the mule of {owner.Name}.";
                    return false;
                }
            }

            if (mule.GetProperty(PropertyInstanceId.MuleImprintMule).HasValue)
            {
                error = $"{mule.Name} has imprinted a mule of their own and cannot become one.";
                return false;
            }

            return true;
        }

        // ---------------------------------------------------------------------
        // /muleflag: a character makes itself a mule (before any token is bound to it)
        // ---------------------------------------------------------------------

        /// <summary>
        /// Returns null if this character can be flagged as a mule, otherwise the reason it can't.
        /// </summary>
        public string GetMuleFlagError()
        {
            if (IsMule)
                return $"{Name} is already a mule.";

            if ((Level ?? 1) > MuleImprintToken.MaxMuleLevel)
                return $"Only a character of level {MuleImprintToken.MaxMuleLevel} or lower can become a mule. {Name} is level {Level ?? 1}.";

            if (IsTinker)
                return "A Tinker cannot become a mule.";

            if (MuleImprintMule.HasValue)
                return "You have imprinted a mule of your own, so you cannot become one.";

            if (IsOlthoiPlayer)
                return "The Olthoi cannot become mules.";

            return null;
        }

        /// <summary>
        /// Permanently flags this character as a mule: it stops gaining experience, opens the extra pack slot
        /// (after relogging), and can then be imprinted by a Mule Imprint Token held by another character on the account.
        /// </summary>
        public void FlagAsMule()
        {
            IsMule = true;

            // the extra (8th) pack slot; ContainerCapacity is worked out from this at login
            if (AugmentationExtraPackSlot == 0)
                AugmentationExtraPackSlot = 1;

            RushNextPlayerSave(5);

            SendMuleImprintMessage(
                $"{Name} is now a mule. It will no longer gain experience, and its extra pack slot opens the next time you log in on it.\n" +
                $"{Name} can now be claimed as a Ghost Mule.");

            log.Info($"[MuleImprint] {Name} (0x{Guid}) flagged itself as a mule with /muleflag");
        }

        // ---------------------------------------------------------------------
        // Handing items to the ghost
        // ---------------------------------------------------------------------

        /// <summary>
        /// Called from GiveObjectToNPC when the target is a Ghost of [Mule].
        /// </summary>
        private void GiveObjectToMuleGhost(MuleGhost ghost, WorldObject item, Container itemFoundInContainer, Container itemRootOwner, bool itemWasEquipped, int amount)
        {
            void Fail(string msg = null)
            {
                if (msg != null)
                    Session.Network.EnqueueSend(new GameMessageSystemChat(msg, ChatMessageType.Broadcast));
                Session.Network.EnqueueSend(new GameEventInventoryServerSaveFailed(Session, item.Guid.Full));
            }

            if (ghost.IsDestroyed || ghost.P_PetOwner != this)
            {
                Fail($"The {ghost.Name} looks through you. Only the one who called it can hand it anything.");
                return;
            }

            if (IsArenaObserver)
            {
                Fail("You cannot give items while you are an observer of an arena match!");
                return;
            }

            if (PKTimerActive)
            {
                var ghostName = ghost.Name;
                ghost.Destroy();
                Fail($"The {ghostName} flees from the fighting.");
                return;
            }

            if (ghost.MuleIsOnline())
            {
                ghost.Destroy();
                Fail("Your mule is in the world right now, so the ghost has faded.");
                return;
            }

            if (MuleImprintToken.IsOrContainsToken(item) || item.IsAttunedOrContainsAttuned)
            {
                Session.Network.EnqueueSend(new GameEventInventoryServerSaveFailed(Session, item.Guid.Full, WeenieError.AttunedItem));
                return;
            }

            if (item is PetDevice petDevice && petDevice.Pet is not null)
            {
                Session.Network.EnqueueSend(new GameEventCommunicationTransientString(Session, "You must unsummon your pet before you can transfer this item!"));
                Session.Network.EnqueueSend(new GameEventInventoryServerSaveFailed(Session, item.Guid.Full, WeenieError.AttunedItem));
                return;
            }

            if (IsTrading && item.IsBeingTradedOrContainsItemBeingTraded(ItemsInTradeWindow))
            {
                Session.Network.EnqueueSend(new GameEventInventoryServerSaveFailed(Session, item.Guid.Full, WeenieError.TradeItemBeingTraded));
                return;
            }

            var stackSize = item.StackSize ?? 1;
            if (amount > stackSize)
                amount = stackSize;

            var splitting = stackSize > 1 && amount < stackSize;

            var itemBurden = splitting ? (item.StackUnitEncumbrance ?? 0) * amount : (item.EncumbranceVal ?? 0);

            if (!ghost.TryFindRoom(item, itemBurden, out var containerGuid, out var placement, out var roomError))
            {
                Fail(roomError);
                return;
            }

            if (!ghost.CheckUniques(item, out var uniqueError))
            {
                Fail(uniqueError);
                return;
            }

            if (!RemoveItemForGive(item, itemFoundInContainer, itemWasEquipped, itemRootOwner, amount, out var itemToGive))
                return;

            // move it to the mule right away, so the next hand-off sees the updated pack
            ghost.CommitTransfer(itemToGive, containerGuid, placement);

            // client messages are delayed for equipped items, same as GiveObjectToPlayer
            var actionChain = new ActionChain();
            if (itemWasEquipped)
                actionChain.AddDelaySeconds(0.5f);

            actionChain.AddAction(this, () =>
            {
                if (item == itemToGive)
                {
                    Session.Network.EnqueueSend(new GameEventItemServerSaysContainId(Session, item, ghost));
                    Session.Network.EnqueueSend(new GameMessageDeleteObject(item));
                }

                var givenStack = itemToGive.StackSize ?? 1;
                var stackMsg = givenStack != 1 ? $"{givenStack:N0} " : "";
                var itemName = itemToGive.GetNameWithMaterial(givenStack);

                Session.Network.EnqueueSend(new GameMessageSystemChat($"You give the {ghost.Name} {stackMsg}{itemName}. It is now in {ghost.MuleName}'s pack.", ChatMessageType.Broadcast));
                ghost.EnqueueBroadcast(new GameMessageSound(ghost.Guid, Sound.ReceiveItem));

                if (PropertyManager.GetBool("player_receive_immediate_save").Item)
                    RushNextPlayerSave(5);

                log.Debug($"[MuleImprint] {Name} (0x{Guid}) sent {stackMsg}{itemName} (0x{itemToGive.Guid}) to mule {ghost.MuleName} (0x{ghost.MuleGuid:X8}), container 0x{containerGuid:X8}");
            });

            actionChain.EnqueueChain();
        }
    }
}
