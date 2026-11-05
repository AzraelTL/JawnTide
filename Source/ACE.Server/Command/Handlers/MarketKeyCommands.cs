using ACE.Database;
using ACE.Entity.Enum;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide: test listing keys from the house chest without the website (JawnTest has none).
    /// Each one queues a market request exactly like the website does.
    /// </summary>
    public static class MarketKeyCommands
    {
        [CommandHandler("marketkey", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Tests market key listings from your house chest without the website.",
            "\n@marketkey list <mmds> - list the first key in your house chest\n" +
            "@marketkey back <listing id> - take a listing back\n" +
            "@marketkey buy <listing id> [mmd|trophies] - buy a listing (from another account)\n" +
            "@marketkey status - your latest listings and requests")]
        public static void HandleMarketKey(Session session, params string[] parameters)
        {
            var player = session.Player;
            var accountId = session.AccountId;
            var name = player.Name;

            void Say(string text) => session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

            // account access level (like @instance): a character without the admin flag still gets an answer instead of silence
            if (session.AccessLevel < AccessLevel.Developer)
            {
                Say("@marketkey is a staff test command.");
                return;
            }

            if (parameters.Length == 0)
            {
                Say("Usage: @marketkey list <mmds> | back <id> | buy <id> [mmd|trophies] | status");
                return;
            }

            void Queue(MarketRequest req)
            {
                req.AccountId = accountId;
                req.CharacterName = name;
                DatabaseManager.Shard.MarketEnqueue(() =>
                    Say(DatabaseManager.Shard.BaseDatabase.MarketInsertRequest(req)
                        ? $"Sent the {req.Kind} request. Give it a few seconds, then type @marketkey status."
                        : "The request couldn't be saved. See the server log."));
            }

            switch (parameters[0].ToLower())
            {
                case "list":
                {
                    if (parameters.Length < 2 || !uint.TryParse(parameters[1], out var mmd) || mmd == 0)
                    {
                        Say("Usage: @marketkey list <price in MMDs>");
                        return;
                    }
                    MarketManager.FindChestKey(accountId, (guid, text) =>
                    {
                        if (!guid.HasValue)
                        {
                            Say(text);
                            return;
                        }
                        Say($"Listing {text} (0x{guid.Value:X8}) for {mmd:N0} MMDs.");
                        Queue(new MarketRequest { Kind = "list", ItemGuid = guid.Value, PriceMmd = mmd });
                    });
                    return;
                }

                case "back":
                case "buy":
                {
                    if (parameters.Length < 2 || !ulong.TryParse(parameters[1], out var id))
                    {
                        Say($"Usage: @marketkey {parameters[0].ToLower()} <listing id> (see @marketkey status)");
                        return;
                    }
                    if (parameters[0].ToLower() == "back")
                        Queue(new MarketRequest { Kind = "cancel", ListingId = id });
                    else
                        Queue(new MarketRequest { Kind = "buy", ListingId = id, PayWith = parameters.Length > 2 && parameters[2].ToLower() == "trophies" ? "trophies" : "mmd" });
                    return;
                }

                case "status":
                    DatabaseManager.Shard.MarketEnqueue(() =>
                    {
                        var lines = DatabaseManager.Shard.BaseDatabase.MarketGetAccountActivity(accountId, 6);
                        Say(lines == null ? "The market tables couldn't be read." : string.Join("\n", lines));
                    });
                    return;

                default:
                    Say("Usage: @marketkey list <mmds> | back <id> | buy <id> [mmd|trophies] | status");
                    return;
            }
        }
    }
}
