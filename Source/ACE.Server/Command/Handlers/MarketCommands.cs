using System.Linq;
using System.Text.RegularExpressions;

using ACE.Database;
using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide Marketplace: list an item from in game. ID (appraise) an item in your open My Mule window, then type
    /// /market 5 mmd, /market 500 pkt, or both (/market 5 mmd 500 pkt). It queues the same request the website's List
    /// button does, and the usual market message says when it's listed.
    /// </summary>
    public static class MarketCommands
    {
        private static readonly Regex PricePart = new Regex(@"(\d[\d,]*)\s*(mmds?|pkts?|pks?|trophy|trophies)\b", RegexOptions.IgnoreCase);

        [CommandHandler("market", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Lists the item you last identified in your My Mule on the market at a fixed price.",
            "<amount> mmd and/or <amount> pkt\nID an item in your open My Mule window first. Examples: /market 5 mmd, /market 500 pkt, /market 5 mmd 500 pkt")]
        public static void HandleMarket(Session session, params string[] parameters)
        {
            var player = session.Player;
            void Say(string text) => session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

            const string usage = "ID an item in your open My Mule window, then type /market 5 mmd, /market 500 pkt, or /market 5 mmd 500 pkt. It's listed for 30 days, like on the website.";

            var text = string.Join(" ", parameters ?? new string[0]).Trim();
            var matches = PricePart.Matches(text);

            if (matches.Count == 0 || PricePart.Replace(text, "").Trim().Length > 0)
            {
                Say(usage);
                return;
            }

            uint? mmd = null, trophies = null;
            foreach (Match m in matches)
            {
                if (!uint.TryParse(m.Groups[1].Value.Replace(",", ""), out var amount) || amount == 0)
                {
                    Say(usage);
                    return;
                }

                if (m.Groups[2].Value.ToLowerInvariant().StartsWith("mmd"))
                    mmd = amount;
                else
                    trophies = amount;
            }

            if (mmd > MarketManager.MaxPriceMmd || trophies > MarketManager.MaxPriceTrophies)
            {
                Say($"Prices go up to {MarketManager.MaxPriceMmd:N0} MMDs or {MarketManager.MaxPriceTrophies:N0} PK Trophies.");
                return;
            }

            var target = player.CurrentAppraisalTarget;
            var item = target.HasValue ? player.ActiveMuleContainers?.Select(c => c.Inventory.TryGetValue(new ObjectGuid(target.Value), out var wo) ? wo : null).FirstOrDefault(wo => wo != null) : null;

            if (item == null)
            {
                Say("ID the item in your own My Mule window first (summon your mule, open it and identify the item), then type /market again.");
                return;
            }

            if (player.PKTimerActive)
            {
                Say("You can't list items while you're PK tagged.");
                return;
            }

            var why = MarketManager.CheckListable(item);
            if (why != null)
            {
                Say(why);
                return;
            }

            var req = new MarketRequest
            {
                AccountId = session.AccountId,
                CharacterName = player.Name,
                Kind = "list",
                ItemGuid = item.Guid.Full,
                PriceMmd = mmd,
                PriceTrophies = trophies,
            };

            var stack = (item.StackSize ?? 1) > 1 ? $"{item.StackSize:N0} " : "";
            var what = $"{stack}{item.Name}";
            var price = MarketManager.PriceText(mmd, trophies);

            DatabaseManager.Shard.MarketEnqueue(() =>
                Say(DatabaseManager.Shard.BaseDatabase.MarketInsertRequest(req)
                    ? $"Listing {what} for {price}. You'll get a message in a few seconds when it's on the market."
                    : "The market couldn't take that request right now. Try again in a moment."));
        }
    }
}
