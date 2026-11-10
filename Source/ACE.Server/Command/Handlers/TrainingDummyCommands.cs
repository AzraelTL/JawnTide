using System;
using System.Collections.Generic;
using System.Linq;

using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.WorldObjects;

namespace ACE.Server.Command.Handlers
{
    /// <summary>JawnTide Target Drudge (TrainingDummy) setup.</summary>
    public static class TrainingDummyCommands
    {
        private static readonly string[] PvpBuffs8 =
        {
            "Incantation of Armor Self", "Incantation of Acid Protection Self", "Incantation of Blade Protection Self",
            "Incantation of Bludgeoning Protection Self", "Incantation of Cold Protection Self", "Incantation of Fire Protection Self",
            "Incantation of Lightning Protection Self", "Incantation of Piercing Protection Self", "Incantation of Invulnerability Self",
            "Incantation of Impregnability Self", "Incantation of Magic Resistance Self"
        };

        private static readonly string[] PvpBuffs7 =
        {
            "Armor Self VII", "Acid Protection Self VII", "Blade Protection Self VII", "Bludgeoning Protection Self VII", "Cold Protection Self VII",
            "Fire Protection Self VII", "Lightning Protection Self VII", "Piercing Protection Self VII", "Invulnerability Self VII",
            "Impregnability Self VII", "Magic Resistance Self VII"
        };

        private static readonly string[] ArmorBuffs8 =
        {
            nameof(ACE.Entity.Enum.SpellId.Impenetrability8), nameof(ACE.Entity.Enum.SpellId.AcidBane8), nameof(ACE.Entity.Enum.SpellId.BladeBane8),
            nameof(ACE.Entity.Enum.SpellId.BludgeonBane8), nameof(ACE.Entity.Enum.SpellId.FlameBane8), nameof(ACE.Entity.Enum.SpellId.FrostBane8),
            nameof(ACE.Entity.Enum.SpellId.LightningBane8), nameof(ACE.Entity.Enum.SpellId.PiercingBane8)
        };

        private static readonly string[] ArmorBuffs7 =
        {
            nameof(ACE.Entity.Enum.SpellId.Impenetrability7), nameof(ACE.Entity.Enum.SpellId.AcidBane7), nameof(ACE.Entity.Enum.SpellId.BladeBane7),
            nameof(ACE.Entity.Enum.SpellId.BludgeonBane7), nameof(ACE.Entity.Enum.SpellId.FlameBane7), nameof(ACE.Entity.Enum.SpellId.FrostBane7),
            nameof(ACE.Entity.Enum.SpellId.LightningBane7), nameof(ACE.Entity.Enum.SpellId.PiercingBane7)
        };

        /// <summary>The spell names behind a buff preset (pvp7, pvp8, armor7, armor8), or null.</summary>
        public static string[] Preset(string key) => key?.Trim().ToLowerInvariant() switch
        {
            "pvp8" => PvpBuffs8,
            "pvp7" => PvpBuffs7,
            "armor8" => ArmorBuffs8,
            "armor7" => ArmorBuffs7,
            _ => null
        };

        [CommandHandler("dummy", AccessLevel.Developer, CommandHandlerFlag.RequiresWorld, 0,
            "Sets up a Target Drudge (select it, or stand within 30 m of one). Place one with @createinst 4290001 (saved) or @create 4290001 (until restart).",
            "/dummy - its setup\n" +
            "/dummy armor <body> [head/hands/feet] - armor level against every damage type: one value for the body (chest, abdomen, arms, legs)\n" +
            "   and one for the head, hands and feet; give one number to use it everywhere (e.g. /dummy armor 650 450)\n" +
            "/dummy defense <melee> <missile> <magic> - unbuffed defense skills (0 = every attack lands)\n" +
            "/dummy ratings <damage resist> <crit damage resist> <pk damage resist>\n" +
            "/dummy buff <spell name or id> - keep this buff on it (recast when it wears off)\n" +
            "/dummy buff pvp7 | pvp8 - armor, the 7 protections, invulnerability, impregnability and magic resistance at level 7 or 8\n" +
            "/dummy unbuff <spell name or id> | all - stop keeping a buff (all also removes every enchantment on it)\n" +
            "/dummy wear - puts copies of everything you're wearing (armor, underclothes, jewelry, cloak) on it, with all their stats and spells\n" +
            "/dummy wear under - copies only your shirt and pants (underclothes AL, resistances and ratings), keeping its other worn items\n" +
            "/dummy strip [under] - takes its worn copies off (all, or just underclothes)\n" +
            "/dummy buff armor8 | armor7 - Impenetrability and the 7 banes, cast on whatever it wears (like on a player's armor)\n" +
            "Worn item AL adds on top of /dummy armor, so set /dummy armor 0 when it wears a full suit.\n" +
            "/dummy clean - removes debuffs players cast on it (keeps its own buffs)\n" +
            "/dummy reset - restarts your damage session on it\n" +
            "Anyone can attack it: a player's attacks take the PvP damage path. Sessions are on the LAN admin page.")]
        public static void HandleDummy(Session session, params string[] parameters)
        {
            void Say(string text) => session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

            var player = session.Player;
            TrainingDummy dummy = null;

            if (player.CurrentAppraisalTarget.HasValue)
                dummy = player.CurrentLandblock?.GetObject(new ObjectGuid(player.CurrentAppraisalTarget.Value)) as TrainingDummy;

            if (dummy == null)
                dummy = player.CurrentLandblock?.GetAllWorldObjectsForDiagnostics().OfType<TrainingDummy>()
                    .Where(d => d.Location != null && d.Location.DistanceTo(player.Location) <= 30)
                    .OrderBy(d => d.Location.DistanceTo(player.Location)).FirstOrDefault();

            if (dummy == null)
            {
                Say("Select a Target Drudge, or stand within 30 m of one. Place one with @createinst 4290001.");
                return;
            }

            bool Ints(int count, out int[] values)
            {
                values = new int[count];
                if (parameters.Length < count + 1)
                    return false;
                for (var i = 0; i < count; i++)
                    if (!int.TryParse(parameters[i + 1], out values[i]) || values[i] < 0)
                        return false;
                return true;
            }

            void Done()
            {
                dummy.ApplySetup();
                dummy.SaveSetup();
                Say($"{dummy.Name} (0x{dummy.Guid.Full:X8}): {dummy.DescribeSetup()}");
            }

            var verb = parameters.Length > 0 ? parameters[0].ToLowerInvariant() : "";
            var rest = string.Join(" ", parameters.Skip(1));

            switch (verb)
            {
                case "":
                case "show":
                    Say($"{dummy.Name} (0x{dummy.Guid.Full:X8}): {dummy.DescribeSetup()}. " +
                        $"Defense now (with buffs): melee {dummy.DefenseCurrent(Skill.MeleeDefense)}, missile {dummy.DefenseCurrent(Skill.MissileDefense)}, magic {dummy.DefenseCurrent(Skill.MagicDefense)}.");
                    return;

                case "armor":
                    if (Ints(2, out var a2))
                        (dummy.Armor, dummy.ArmorExtremities) = (a2[0], a2[1]);
                    else if (Ints(1, out var a1))
                        dummy.Armor = dummy.ArmorExtremities = a1[0];
                    else
                    {
                        Say("/dummy armor <body> [head/hands/feet], e.g. /dummy armor 650 450");
                        return;
                    }
                    Done();
                    return;

                case "defense":
                case "def":
                    if (!Ints(3, out var d)) { Say("/dummy defense <melee> <missile> <magic>"); return; }
                    (dummy.MeleeDef, dummy.MissileDef, dummy.MagicDef) = (d[0], d[1], d[2]);
                    Done();
                    return;

                case "ratings":
                case "rating":
                    if (!Ints(3, out var r)) { Say("/dummy ratings <damage resist> <crit damage resist> <pk damage resist>"); return; }
                    (dummy.Drr, dummy.Cdr, dummy.Pkdr) = (r[0], r[1], r[2]);
                    Done();
                    return;

                case "buff":
                {
                    var names = rest.ToLowerInvariant() switch
                    {
                        "pvp8" => PvpBuffs8,
                        "pvp7" => PvpBuffs7,
                        "armor8" => ArmorBuffs8,
                        "armor7" => ArmorBuffs7,
                        _ => new[] { rest }
                    };
                    if (string.IsNullOrWhiteSpace(rest)) { Say("/dummy buff <spell name or id> | pvp7 | pvp8"); return; }

                    var missing = new List<string>();
                    foreach (var n in names)
                    {
                        var id = TrainingDummy.FindSpell(n);
                        if (id == null) { missing.Add(n); continue; }
                        if (!dummy.Buffs.Contains(id.Value))
                            dummy.Buffs.Add(id.Value);
                    }
                    if (missing.Count > 0)
                        Say($"No spell named: {string.Join(", ", missing)}");
                    Done();
                    return;
                }

                case "unbuff":
                {
                    if (rest.Equals("all", StringComparison.OrdinalIgnoreCase))
                    {
                        dummy.Buffs.Clear();
                        dummy.EnchantmentManager.RemoveAllEnchantments();
                        Done();
                        return;
                    }
                    var id = TrainingDummy.FindSpell(rest);
                    if (id == null || !dummy.Buffs.Remove(id.Value)) { Say($"It isn't keeping a buff called {rest}."); return; }
                    var entry = dummy.EnchantmentManager.GetEnchantment(id.Value);
                    if (entry != null)
                        dummy.EnchantmentManager.Remove(entry);
                    Done();
                    return;
                }

                case "wear":
                {
                    var under = rest.StartsWith("under", StringComparison.OrdinalIgnoreCase);
                    var mine = player.EquippedObjects.Values.Where(i => TrainingDummy.CanCopy(i, under)).ToList();
                    if (mine.Count == 0)
                    {
                        Say(under ? "You aren't wearing a shirt or pants." : "You aren't wearing anything it can copy.");
                        return;
                    }
                    if (!under)
                        dummy.StripAll();
                    var worn = mine.Count(i => dummy.WearCopy(i.Biota, i.BiotaDatabaseLock));
                    Say($"It put on copies of {worn} of your {mine.Count} item(s).");
                    Done();
                    return;
                }

                case "strip":
                {
                    var n = rest.StartsWith("under", StringComparison.OrdinalIgnoreCase) ? dummy.Strip(TrainingDummy.UnderclothesSlots) : dummy.StripAll();
                    Say($"Took off {n} item(s).");
                    Done();
                    return;
                }

                case "clean":
                    dummy.EnchantmentManager.RemoveAllBadEnchantments();
                    Say($"Removed the debuffs on {dummy.Name}.");
                    return;

                case "reset":
                    Say(dummy.ResetSession(player.Guid.Full) ? "Your session on it was cleared." : "You have no session on it.");
                    return;

                default:
                    Say("/dummy [armor | defense | ratings | buff | unbuff | clean | reset] - see /help dummy");
                    return;
            }
        }
    }
}
