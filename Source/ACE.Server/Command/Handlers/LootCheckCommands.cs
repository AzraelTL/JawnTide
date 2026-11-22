using System;
using System.Collections.Generic;

using ACE.Database;
using ACE.Database.Models.World;
using ACE.Entity.Enum;
using ACE.Entity.Models;
using ACE.Server.Entity;
using ACE.Server.Factories;
using ACE.Server.Network;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: /lootcheck rolls random loot with the real loot code and the live settings, and reports how often
    /// the top results came up (Epics, Legendaries, sets, ratings). It works in game, where testlootgen is console
    /// only. Nothing it rolls is kept. A tier is rolled as given, whatever loot_max_tier is, so a new stage can be
    /// checked before it is switched on.
    /// </summary>
    public static class LootCheckCommands
    {
        [CommandHandler("lootcheck", AccessLevel.Admin, CommandHandlerFlag.None, 1,
            "Rolls random loot and reports how often Epics, sets and ratings come up. Nothing is kept.",
            "<tier 1-9, or a loot profile id> [quality 0-1, default 0] [items, default 5000, at most 20000]")]
        public static void HandleLootCheck(Session session, params string[] parameters)
        {
            if (!int.TryParse(parameters[0], out var tierOrProfile) || tierOrProfile < 1)
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Usage: /lootcheck <tier 1-9, or a loot profile id> [quality 0-1] [items]");
                return;
            }

            var quality = 0.0f;
            if (parameters.Length > 1 && (!float.TryParse(parameters[1], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out quality) || quality < 0 || quality > 1))
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Quality must be a number from 0 to 1.");
                return;
            }

            var numItems = 5000;
            if (parameters.Length > 2 && !int.TryParse(parameters[2], out numItems))
            {
                CommandHandlerHelper.WriteOutputInfo(session, "Items must be a whole number.");
                return;
            }
            numItems = Math.Clamp(numItems, 100, 20000);

            TreasureDeath profile = null;
            var what = "";

            if (tierOrProfile > 9)
            {
                profile = DatabaseManager.World.GetCachedDeathTreasure((uint)tierOrProfile);
                if (profile == null)
                {
                    CommandHandlerHelper.WriteOutputInfo(session, $"There is no loot profile {tierOrProfile}.");
                    return;
                }
                what = $"loot profile {tierOrProfile} (Tier {profile.Tier}, quality {profile.LootQualityMod:0.###}), rolled at its own tier";
            }
            else
            {
                profile = new TreasureDeath { Tier = tierOrProfile, LootQualityMod = quality };
                what = $"Tier {tierOrProfile}, quality {quality:0.###}";
            }

            int items = 0, anyCantrip = 0, anyMajor = 0, twoMajors = 0, anyEpic = 0, twoEpics = 0, anyLegendary = 0;
            int armor = 0, armorSet = 0, armorRating = 0, armorSetAndRating = 0, armorAllThree = 0, otherRating = 0;

            for (var i = 0; i < numItems; i++)
            {
                var wo = LootGenerationFactory.CreateRandomLootObjects(profile, true);
                if (wo == null)
                    continue;

                items++;

                int majors = 0, epics = 0, legendaries = 0, cantrips = 0;
                foreach (var spellId in wo.Biota.GetKnownSpellsIds(wo.BiotaDatabaseLock))
                {
                    var name = new ACE.Server.Entity.Spell(spellId, false).Name ?? "";
                    if (name.StartsWith("Minor ")) cantrips++;
                    else if (name.StartsWith("Major ")) { cantrips++; majors++; }
                    else if (name.StartsWith("Epic ")) { cantrips++; epics++; }
                    else if (name.StartsWith("Legendary ")) { cantrips++; legendaries++; }
                }

                if (cantrips > 0) anyCantrip++;
                if (majors > 0) anyMajor++;
                if (majors > 1) twoMajors++;
                if (epics > 0) anyEpic++;
                if (epics > 1) twoEpics++;
                if (legendaries > 0) anyLegendary++;

                var rated = (wo.GearDamage ?? 0) > 0 || (wo.GearDamageResist ?? 0) > 0 || (wo.GearCritDamage ?? 0) > 0 || (wo.GearCritDamageResist ?? 0) > 0
                    || (wo.GearCrit ?? 0) > 0 || (wo.GearCritResist ?? 0) > 0 || (wo.GearHealingBoost ?? 0) > 0 || (wo.GearMaxHealth ?? 0) > 0;

                if ((wo.ArmorLevel ?? 0) > 0 && !wo.IsShield && wo.ItemType != ItemType.Jewelry)
                {
                    armor++;
                    var set = wo.EquipmentSetId != null;
                    if (set) armorSet++;
                    if (rated) armorRating++;
                    if (set && rated) armorSetAndRating++;
                    if (set && rated && epics + legendaries > 0) armorAllThree++;
                }
                else if (rated)
                    otherRating++;

                wo.Destroy();
            }

            string Pct(int count, int of) => of == 0 ? "none rolled" : count == 0 ? "0" : $"{count * 100.0 / of:0.##}% ({count:N0}, 1 in {(double)of / count:N0})";

            var lines = new List<string>
            {
                $"Loot check: {items:N0} magic items, {what}.",
                $"Any cantrip: {Pct(anyCantrip, items)}",
                $"A Major: {Pct(anyMajor, items)}   Two or more Majors: {Pct(twoMajors, items)}",
                $"An Epic: {Pct(anyEpic, items)}   Two or more Epics: {Pct(twoEpics, items)}",
                $"A Legendary: {Pct(anyLegendary, items)}",
                $"Armor pieces: {armor:N0}. With a set: {Pct(armorSet, armor)}   With a rating: {Pct(armorRating, armor)}",
                $"Armor with a set and a rating: {Pct(armorSetAndRating, armor)}   With an Epic too: {Pct(armorAllThree, armor)}",
                $"Ratings on anything else (clothing, cloaks, jewelry): {otherRating:N0}",
            };

            foreach (var line in lines)
                CommandHandlerHelper.WriteOutputInfo(session, line);
        }
    }
}
