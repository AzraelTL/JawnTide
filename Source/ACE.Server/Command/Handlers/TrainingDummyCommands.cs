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
        // SpellId names: the spell table's own names for these aren't "Armor Self VII" style, so names didn't resolve
        private static readonly string[] PvpBuffs8 =
        {
            nameof(ACE.Entity.Enum.SpellId.ArmorSelf8), nameof(ACE.Entity.Enum.SpellId.AcidProtectionSelf8), nameof(ACE.Entity.Enum.SpellId.BladeProtectionSelf8),
            nameof(ACE.Entity.Enum.SpellId.BludgeonProtectionSelf8), nameof(ACE.Entity.Enum.SpellId.ColdProtectionSelf8), nameof(ACE.Entity.Enum.SpellId.FireProtectionSelf8),
            nameof(ACE.Entity.Enum.SpellId.LightningProtectionSelf8), nameof(ACE.Entity.Enum.SpellId.PiercingProtectionSelf8), nameof(ACE.Entity.Enum.SpellId.InvulnerabilitySelf8),
            nameof(ACE.Entity.Enum.SpellId.ImpregnabilitySelf8), nameof(ACE.Entity.Enum.SpellId.MagicResistanceSelf8)
        };

        private static readonly string[] PvpBuffs7 =
        {
            nameof(ACE.Entity.Enum.SpellId.ArmorSelf7), nameof(ACE.Entity.Enum.SpellId.AcidProtectionSelf7), nameof(ACE.Entity.Enum.SpellId.BladeProtectionSelf7),
            nameof(ACE.Entity.Enum.SpellId.BludgeonProtectionSelf7), nameof(ACE.Entity.Enum.SpellId.ColdProtectionSelf7), nameof(ACE.Entity.Enum.SpellId.FireProtectionSelf7),
            nameof(ACE.Entity.Enum.SpellId.LightningProtectionSelf7), nameof(ACE.Entity.Enum.SpellId.PiercingProtectionSelf7), nameof(ACE.Entity.Enum.SpellId.InvulnerabilitySelf7),
            nameof(ACE.Entity.Enum.SpellId.ImpregnabilitySelf7), nameof(ACE.Entity.Enum.SpellId.MagicResistanceSelf7)
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
            "Shows a Target Drudge's setup (select it, or stand within 30 m of one). Every drudge uses the one setup set on the admin page. Place one with @createinst 4290001 (saved) or @create 4290001 (until restart).",
            "/dummy - its setup\n" +
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
                case "defense":
                case "def":
                case "ratings":
                case "rating":
                case "buff":
                case "unbuff":
                case "wear":
                case "strip":
                    Say("Target Drudges all use one setup, set on the admin page (Target Drudge setup). It can't be changed in game.");
                    return;

                case "clean":
                    dummy.EnchantmentManager.RemoveAllBadEnchantments();
                    Say($"Removed the debuffs on {dummy.Name}.");
                    return;

                case "reset":
                    Say(dummy.ResetSession(player.Guid.Full) ? "Your session on it was cleared." : "You have no session on it.");
                    return;

                default:
                    Say("/dummy - its setup | /dummy clean - remove debuffs players cast on it | /dummy reset - restart your damage session. The setup itself is set on the admin page.");
                    return;
            }
        }
    }
}
