using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

using log4net;
using MySqlConnector;

using ACE.Common;
using ACE.Entity.Enum;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: /wiki CODE links this game account to the jawntide.com wiki. The website makes a short code in
    /// ace_wiki.link_code; typing it in game fills in this account and character, which proves the person on the
    /// website owns the account. Any character can register; editing also needs staff to tick it as the account's
    /// contributor (ace_wiki.contributor, on the monitor's Levels page). The game server only reads contributor and
    /// UPDATEs pending, unexpired codes.
    /// </summary>
    public static class WikiCommands
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static readonly Regex CodePattern = new Regex("^[A-Z0-9]{6,10}$", RegexOptions.Compiled);

        [CommandHandler("wiki", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 1,
            "Links your account to the JawnTide wiki.",
            "<code shown on jawntide.com/wiki>")]
        public static void HandleWikiLink(Session session, params string[] parameters)
        {
            var code = parameters[0].Trim().ToUpperInvariant();
            if (!CodePattern.IsMatch(code))
            {
                session.Network.EnqueueSend(new GameMessageSystemChat("That isn't a wiki code. Get one at jawntide.com/wiki, then type /wiki CODE.", ChatMessageType.Broadcast));
                return;
            }

            var accountId = session.AccountId;
            var charName = session.Player.Name;
            var charId = session.Player.Guid.Full;
            var accessLevel = (int)session.AccessLevel;
            var cfg = ConfigManager.Config.MySql.Shard;

            Task.Run(() =>
            {
                string reply;
                try
                {
                    using var conn = new MySqlConnection($"server={cfg.Host};port={cfg.Port};user={cfg.Username};password={cfg.Password};database=ace_wiki;{cfg.ConnectionOptions}");
                    conn.Open();
                    using var check = conn.CreateCommand();
                    check.CommandText = "SELECT COUNT(*) FROM contributor WHERE account_id = @a AND char_id = @i";
                    check.Parameters.AddWithValue("@a", accountId);
                    check.Parameters.AddWithValue("@i", charId);
                    var contributor = Convert.ToInt64(check.ExecuteScalar()) > 0;

                    using var cmd = conn.CreateCommand();
                    cmd.CommandText = "UPDATE link_code SET account_id = @a, char_id = @i, char_name = @n, access_level = @l, confirmed_at = UTC_TIMESTAMP() " +
                                      "WHERE code = @c AND confirmed_at IS NULL AND expires_at > UTC_TIMESTAMP()";
                    cmd.Parameters.AddWithValue("@a", accountId);
                    cmd.Parameters.AddWithValue("@i", charId);
                    cmd.Parameters.AddWithValue("@n", charName);
                    cmd.Parameters.AddWithValue("@l", accessLevel);
                    cmd.Parameters.AddWithValue("@c", code);
                    reply = cmd.ExecuteNonQuery() == 1
                        ? $"Wiki registration for {charName} confirmed. Go back to the website to pick your wiki password. " +
                          (contributor ? "You're already a contributor, so you can edit right away. "
                                       : "After registering your character with the wiki, an admin must flag it as a contributor before you can edit. ") +
                          "(Only type codes you made yourself: whoever made this code can now sign in to the wiki as you.)"
                        : "That wiki code has expired or was already used. Get a new one at jawntide.com/wiki.";
                }
                catch (Exception ex)
                {
                    log.Error($"[WIKI] linking {charName}: {ex.Message}");
                    reply = "The wiki is unavailable right now. Try again in a few minutes.";
                }
                session.Network.EnqueueSend(new GameMessageSystemChat(reply, ChatMessageType.Broadcast));
            });
        }
    }
}
