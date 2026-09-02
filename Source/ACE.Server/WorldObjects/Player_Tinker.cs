using System.Collections.Generic;

using ACE.DatLoader;
using ACE.Entity.Enum;
using ACE.Entity.Models;
using ACE.Server.Factories;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.WorldObjects
{
    partial class Player
    {
        // -------------------------------------------------------------------------
        // Tinker designation
        // -------------------------------------------------------------------------

        /// <summary>
        /// Crafting/support skills that a Tinker character has auto-specialized and maxed.
        /// The eight crafting skills plus Arcane Lore (needed to appraise and use high-spellcraft
        /// tinkering gear).
        /// </summary>
        public static readonly List<Skill> TinkerSkills = new List<Skill>
        {
            Skill.ItemTinkering,
            Skill.WeaponTinkering,
            Skill.ArmorTinkering,
            Skill.MagicItemTinkering,
            Skill.Alchemy,
            Skill.Lockpick,
            Skill.Fletching,
            Skill.Cooking,
            Skill.ArcaneLore,
        };

        /// <summary>
        /// Class id of the Tinkering Trinket granted on flagging.
        /// </summary>
        private const uint TinkeringTrinketWcid = 8142017u;

        /// <summary>
        /// Major cantrips added to the Tinkering Trinket: all six attributes and the four
        /// tinkering skills. These stack on top of the trinket's built-in level-7 aptitude buffs.
        /// </summary>
        public static readonly List<SpellId> TinkerTrinketCantrips = new List<SpellId>
        {
            // Major attribute cantrips
            SpellId.CANTRIPSTRENGTH2,
            SpellId.CANTRIPENDURANCE2,
            SpellId.CANTRIPCOORDINATION2,
            SpellId.CANTRIPQUICKNESS2,
            SpellId.CANTRIPFOCUS2,
            SpellId.CANTRIPWILLPOWER2,
            // Major tinkering-skill cantrips (Expertise line)
            SpellId.CANTRIPITEMEXPERTISE2,
            SpellId.CANTRIPMAGICITEMEXPERTISE2,
            SpellId.CANTRIPARMOREXPERTISE2,
            SpellId.CANTRIPWEAPONEXPERTISE2,
        };

        /// <summary>
        /// Offensive / combat skills that are untrained on a Tinker character.
        /// </summary>
        public static readonly List<Skill> TinkerOffensiveSkills = new List<Skill>
        {
            // Pre-consolidation weapon skills
            Skill.Axe,
            Skill.Bow,
            Skill.Crossbow,
            Skill.Dagger,
            Skill.Mace,
            Skill.Spear,
            Skill.Staff,
            Skill.Sword,
            Skill.ThrownWeapon,
            Skill.UnarmedCombat,
            // Modern weapon skills
            Skill.HeavyWeapons,
            Skill.LightWeapons,
            Skill.FinesseWeapons,
            Skill.MissileWeapons,
            Skill.TwoHandedCombat,
            Skill.DualWield,
            // Combat modifiers
            Skill.Recklessness,
            Skill.SneakAttack,
            Skill.DirtyFighting,
            Skill.Shield,
            // Offensive magic
            Skill.WarMagic,
            Skill.VoidMagic,
            Skill.LifeMagic,
            Skill.CreatureEnchantment,
            Skill.ItemEnchantment,
            Skill.Summoning,
        };

        /// <summary>
        /// Flags the character as a Tinker, specializing and maxing all crafting skills,
        /// untraining all offensive combat skills, and maxing all attributes.
        /// This is irreversible.
        /// <para/>
        /// Safe to re-run on an already-flagged Tinker: every step is idempotent, so an existing
        /// Tinker can re-issue /FlagTinker to pick up later additions (e.g. Arcane Lore, the trinket
        /// cantrips) that were introduced after they first flagged.
        /// </summary>
        public void FlagAsTinker()
        {
            var wasAlreadyTinker = IsTinker;

            IsTinker = true;

            var specXpTable = DatManager.PortalDat.XpTable.SpecializedSkillXpList;
            var maxSpecXp   = specXpTable[specXpTable.Count - 1];

            var attrXpTable = DatManager.PortalDat.XpTable.AttributeXpList;
            var maxAttrXp   = attrXpTable[attrXpTable.Count - 1];

            // --- Specialize and fully rank all Tinker crafting skills ---
            foreach (var skill in TinkerSkills)
            {
                var cs = GetCreatureSkill(skill);

                if (cs.AdvancementClass == SkillAdvancementClass.Untrained)
                {
                    cs.AdvancementClass = SkillAdvancementClass.Trained;
                    cs.InitLevel        = 0;
                    cs.ExperienceSpent  = 0;
                    cs.Ranks            = 0;
                }

                if (cs.AdvancementClass == SkillAdvancementClass.Trained)
                {
                    cs.AdvancementClass = SkillAdvancementClass.Specialized;
                    cs.InitLevel        = 10;
                }

                cs.ExperienceSpent = maxSpecXp;
                cs.Ranks           = (ushort)CalcSkillRank(SkillAdvancementClass.Specialized, maxSpecXp);

                Session.Network.EnqueueSend(new GameMessagePrivateUpdateSkill(this, cs));
            }

            // --- Untrain all offensive / combat skills ---
            foreach (var skill in TinkerOffensiveSkills)
            {
                var cs = GetCreatureSkill(skill);

                if (cs.AdvancementClass >= SkillAdvancementClass.Trained)
                {
                    cs.AdvancementClass = SkillAdvancementClass.Untrained;
                    cs.InitLevel        = 0;
                    cs.Ranks            = 0;
                    cs.ExperienceSpent  = 0;

                    Session.Network.EnqueueSend(new GameMessagePrivateUpdateSkill(this, cs));
                }
            }

            // --- Max all base attributes ---
            foreach (var attr in Attributes.Values)
            {
                attr.ExperienceSpent = maxAttrXp;
                attr.Ranks           = (ushort)CalcAttributeRank(maxAttrXp);

                Session.Network.EnqueueSend(new GameMessagePrivateUpdateAttribute(this, attr));
            }

            // Refresh vitals now that Endurance and Self are maxed
            SetMaxVitals();

            Session.Network.EnqueueSend(
                new GameMessagePrivateUpdateVital(this, Health),
                new GameMessagePrivateUpdateVital(this, Stamina),
                new GameMessagePrivateUpdateVital(this, Mana));

            // --- Tinkering Trinket ---
            // Ensure the character has a Tinkering Trinket carrying the Major cantrips and Brilliance.
            // Upgrade any trinkets they already hold (inventory or equipped) in place; only grant a
            // fresh one if none exist. This lets a pre-existing Tinker repair a trinket that predates
            // spells later added to the weenie's spell book (cantrips, Brilliance, etc.) - those items
            // had their spell book baked in at creation and won't pick up weenie template changes on
            // their own.
            var trinkets = GetInventoryItemsOfWCID(TinkeringTrinketWcid) ?? new List<WorldObject>();
            foreach (var equipped in EquippedObjects.Values)
            {
                if (equipped.WeenieClassId == TinkeringTrinketWcid)
                    trinkets.Add(equipped);
            }

            if (trinkets.Count == 0)
            {
                var trinket = WorldObjectFactory.CreateNewWorldObject(TinkeringTrinketWcid);
                if (trinket != null)
                {
                    BackfillTrinketSpells(trinket);
                    TryCreateInInventoryWithNetworking(trinket);
                }
            }
            else
            {
                foreach (var trinket in trinkets)
                {
                    BackfillTrinketSpells(trinket);
                    trinket.SaveBiotaToDatabase();
                }
            }

            if (wasAlreadyTinker)
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat(
                    "Your Tinker designation has been refreshed. Arcane Lore is now specialized and maxed, and your Tinkering Trinket has been upgraded with Major cantrips and Brilliance. " +
                    "If the trinket is equipped, re-equip it (or log out and back in) to apply the new buffs.",
                    ChatMessageType.Broadcast));
            }
            else
            {
                Session.Network.EnqueueSend(new GameMessageSystemChat(
                    "You have been designated as a Tinker. Your crafting skills have been fully specialized and all combat skills have been removed. " +
                    "This character may not train or specialize new skills, and will not suffer a vitae penalty on death.",
                    ChatMessageType.Broadcast));
            }
        }

        /// <summary>
        /// Adds the Major attribute and tinkering-skill cantrips, plus Brilliance, to a Tinkering
        /// Trinket instance. Idempotent: GetOrAddKnownSpell will not create duplicate entries, so this
        /// is safe to call on a trinket that already has some or all of these.
        /// </summary>
        private void BackfillTrinketSpells(WorldObject trinket)
        {
            foreach (var cantrip in TinkerTrinketCantrips)
                trinket.Biota.GetOrAddKnownSpell((int)cantrip, trinket.BiotaDatabaseLock, out _);

            trinket.Biota.GetOrAddKnownSpell((int)SpellId.BrillianceOther, trinket.BiotaDatabaseLock, out _);
        }
    }
}
