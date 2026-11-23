using System;

using ACE.DatLoader;
using ACE.Entity.Enum;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;
using ACE.Server.WorldObjects;

using log4net;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: /testchar turns the admin's own character into a fully built level 275 for damage testing:
    /// every skill specialized and fully raised, all six attributes and the three vitals fully raised.
    /// Attributes keep the innate points the character was created with, so the numbers are a real player's,
    /// unlike /god (which goes far past what a player can reach).
    /// </summary>
    public static class TestCharCommands
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// Total XP of a level 275 character
        /// </summary>
        private const long MaxLevelXp = 191226310247;

        [CommandHandler("testchar", AccessLevel.Admin, CommandHandlerFlag.RequiresWorld, 0,
            "Makes your own character a fully built level 275 for damage testing: every skill specialized and maxed, all attributes and vitals maxed.",
            "No parameters. It changes the character you are on, for good. Attributes keep their innate (creation) points.")]
        public static void HandleTestChar(Session session, params string[] parameters)
        {
            var player = session.Player;

            try
            {
                // level 275 first, so the level and skill credits match a finished character
                var missingXp = MaxLevelXp - (player.TotalExperience ?? 0);
                if (missingXp > 0)
                    player.GrantXP(missingXp, XpType.Admin, ShareType.None, bypassSeasonCap: true);

                var xpTable = DatManager.PortalDat.XpTable;
                var maxSpecXp = xpTable.SpecializedSkillXpList[xpTable.SpecializedSkillXpList.Count - 1];
                var maxAttrXp = xpTable.AttributeXpList[xpTable.AttributeXpList.Count - 1];
                var maxVitalXp = xpTable.VitalXpList[xpTable.VitalXpList.Count - 1];

                var skills = 0;
                foreach (var skill in SkillHelper.ValidSkills)
                {
                    var cs = player.GetCreatureSkill(skill);
                    if (cs == null)
                        continue;

                    cs.AdvancementClass = SkillAdvancementClass.Specialized;
                    cs.InitLevel = 10;
                    cs.ExperienceSpent = maxSpecXp;
                    cs.Ranks = (ushort)Player.CalcSkillRank(SkillAdvancementClass.Specialized, maxSpecXp);

                    session.Network.EnqueueSend(new GameMessagePrivateUpdateSkill(player, cs));
                    skills++;
                }

                foreach (var attr in player.Attributes.Values)
                {
                    attr.ExperienceSpent = maxAttrXp;
                    attr.Ranks = (ushort)Player.CalcAttributeRank(maxAttrXp);

                    session.Network.EnqueueSend(new GameMessagePrivateUpdateAttribute(player, attr));
                }

                foreach (var vital in player.Vitals.Values)
                {
                    vital.ExperienceSpent = maxVitalXp;
                    vital.Ranks = (ushort)Player.CalcVitalRank(maxVitalXp);
                }

                player.SetMaxVitals();

                session.Network.EnqueueSend(
                    new GameMessagePrivateUpdateVital(player, player.Health),
                    new GameMessagePrivateUpdateVital(player, player.Stamina),
                    new GameMessagePrivateUpdateVital(player, player.Mana));

                player.SaveBiotaToDatabase();

                CommandHandlerHelper.WriteOutputInfo(session, $"{player.Name} is now a fully built level {player.Level}: {skills} skills specialized and maxed, all attributes and vitals maxed. Log out and back in if the skill panel looks out of date.");
                log.Info($"[TESTCHAR] {player.Name} used /testchar.");
            }
            catch (Exception ex)
            {
                CommandHandlerHelper.WriteOutputInfo(session, $"testchar failed: {ex.GetType().Name}: {ex.Message}");
            }
        }
    }
}
