using System;
using System.Linq;

using log4net;

using ACE.Entity.Enum;
using ACE.Server.Entity;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide Allegiance Mule permissions, set like house storage but kept separate from the mansion's chests:
    /// /amule storage add NAME | remove NAME | remove -all | list | allegiance on | allegiance off. Only the mansion's owner
    /// changes the list; the owner and their account can always use it.
    /// </summary>
    public static class HookMuleCommands
    {
        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private const string Usage = "Usage: /amule storage add NAME | /amule storage remove NAME | /amule storage remove -all | /amule storage list | /amule storage allegiance on | /amule storage allegiance off";

        [CommandHandler("amule", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Sets who may use your mansion's Allegiance Mule (its own list, separate from your storage chests).",
            "storage add <name> | storage remove <name> | storage remove -all | storage list | storage allegiance on | storage allegiance off")]
        public static void HandleAmule(Session session, params string[] parameters)
        {
            var player = session.Player;
            void Say(string text) => session.Network.EnqueueSend(new GameMessageSystemChat(text, ChatMessageType.Broadcast));

            var args = parameters.ToList();
            if (args.Count > 0 && (args[0].Equals("storage", StringComparison.OrdinalIgnoreCase) || args[0].Equals("guest", StringComparison.OrdinalIgnoreCase)))
                args.RemoveAt(0);

            var house = player.House?.RootHouse;
            if (house == null || house.HouseType != HouseType.Mansion || house.HouseOwner != player.Guid.Full)
            {
                Say("Only a mansion's owner can set who may use its Allegiance Mule.");
                return;
            }

            var houseId = house.Guid.Full;
            var ownerId = player.Guid.Full;
            var verb = args.Count > 0 ? args[0].ToLowerInvariant() : "list";
            var name = string.Join(" ", args.Skip(1)).Trim();

            switch (verb)
            {
                case "list":
                {
                    var entries = HookMuleAccess.List(houseId, ownerId);
                    var allegiance = entries.Any(g => g.id == HookMuleAccess.AllegianceId);
                    var guests = entries.Where(g => g.id != HookMuleAccess.AllegianceId).ToList();
                    Say($"Your Allegiance Mule: your allegiance {(allegiance ? "CAN" : "can't")} use it (/amule storage allegiance on|off). " +
                        (guests.Count == 0 ? "No one else is on its list (/amule storage add NAME)."
                                           : $"Also on its list ({guests.Count}/{HookMuleAccess.MaxGuests}): {string.Join(", ", guests.Select(g => g.name))}"));
                    return;
                }

                case "allegiance":
                case "add_allegiance":
                case "remove_allegiance":
                {
                    var on = verb == "add_allegiance" || (verb == "allegiance" && (name.Equals("on", StringComparison.OrdinalIgnoreCase) || name.Equals("add", StringComparison.OrdinalIgnoreCase)));
                    var off = verb == "remove_allegiance" || (verb == "allegiance" && (name.Equals("off", StringComparison.OrdinalIgnoreCase) || name.Equals("remove", StringComparison.OrdinalIgnoreCase)));
                    if (!on && !off) { Say("Usage: /amule storage allegiance on | /amule storage allegiance off"); return; }

                    if (on)
                    {
                        HookMuleAccess.Add(houseId, ownerId, HookMuleAccess.AllegianceId, "(allegiance)", player.Name);
                        Say("Your allegiance can now use your Allegiance Mule.");
                    }
                    else
                    {
                        HookMuleAccess.Remove(houseId, ownerId, HookMuleAccess.AllegianceId);
                        Say("Your allegiance can no longer use your Allegiance Mule (anyone on its list still can).");
                    }
                    log.Info($"[MULE] {player.Name} (0x{player.Guid}) turned Allegiance Mule allegiance access {(on ? "on" : "off")} for mansion 0x{houseId:X8}");
                    return;
                }

                case "add":
                {
                    if (name.Length == 0) { Say("Usage: /amule storage add NAME"); return; }
                    var target = PlayerManager.FindByName(name);
                    if (target == null) { Say($"There's no character named {name}."); return; }
                    if (target.Account != null && target.Account.AccountId == player.Account.AccountId) { Say($"{target.Name} is on your own account and can already use it."); return; }
                    if (!HookMuleAccess.Add(houseId, ownerId, target.Guid.Full, target.Name, player.Name)) { Say($"Its list already has {HookMuleAccess.MaxGuests} people. Remove one first."); return; }
                    Say($"{target.Name} can now use your Allegiance Mule.");
                    log.Info($"[MULE] {player.Name} (0x{player.Guid}) added {target.Name} (0x{target.Guid.Full:X8}) to the Allegiance Mule of mansion 0x{houseId:X8}");
                    return;
                }

                case "remove":
                case "remove_all":
                {
                    if (verb == "remove_all" || name.Equals("-all", StringComparison.OrdinalIgnoreCase) || name.Equals("all", StringComparison.OrdinalIgnoreCase))
                    {
                        Say($"Removed {HookMuleAccess.ClearGuests(houseId, ownerId)} people from your Allegiance Mule's list (the allegiance setting is unchanged).");
                        return;
                    }
                    if (name.Length == 0) { Say("Usage: /amule storage remove NAME (or -all)"); return; }
                    var match = HookMuleAccess.List(houseId, ownerId).FirstOrDefault(g => g.id != HookMuleAccess.AllegianceId
                        && (g.name.Equals(name, StringComparison.OrdinalIgnoreCase) || g.name.TrimStart('+').Equals(name.TrimStart('+'), StringComparison.OrdinalIgnoreCase)));
                    if (match.name == null || !HookMuleAccess.Remove(houseId, ownerId, match.id)) { Say($"{name} isn't on your Allegiance Mule's list."); return; }
                    Say($"{match.name} can no longer use your Allegiance Mule.");
                    log.Info($"[MULE] {player.Name} (0x{player.Guid}) removed {match.name} from the Allegiance Mule of mansion 0x{houseId:X8}");
                    return;
                }

                default:
                    Say(Usage);
                    return;
            }
        }
    }
}
