using System.Linq;
using System.Text;

using ACE.Entity;
using ACE.Entity.Enum;
using ACE.Server.Entity;
using ACE.Server.Managers;
using ACE.Server.Network;
using ACE.Server.Network.GameMessages.Messages;

namespace ACE.Server.Command.Handlers
{
    /// <summary>
    /// JawnTide instancing: staff commands to see and test private landblock copies (see Managers/InstanceManager.cs).
    /// </summary>
    public static class InstanceCommands
    {
        [CommandHandler("instance", AccessLevel.Player, CommandHandlerFlag.RequiresWorld, 0,
            "Shows which copy of the landblock you're in, or moves you between copies for testing.",
            "\n@instance - show where you are and the loaded instances\n" +
            "@instance new [content] - make a new private copy of the landblock you're in and move there (content 1 = arena version, 0 = empty)\n" +
            "@instance leave - move to the same spot in the normal world")]
        public static void HandleInstance(Session session, params string[] parameters)
        {
            var player = session.Player;
            var loc = player.Location;

            // players can see which copy they're in; listing and moving between copies is for staff
            if (parameters.Length == 0 && session.AccessLevel < AccessLevel.Developer)
            {
                session.Network.EnqueueSend(new GameMessageSystemChat($"You are in {InstanceManager.GetDescription(loc.Variation)}, landblock 0x{loc.Landblock:X4}.", ChatMessageType.Broadcast));
                return;
            }

            if (session.AccessLevel < AccessLevel.Developer)
            {
                session.Network.EnqueueSend(new GameMessageSystemChat("Usage: /instance", ChatMessageType.Broadcast));
                return;
            }

            if (parameters.Length == 0)
            {
                var sb = new StringBuilder();
                sb.AppendLine($"You are in {InstanceManager.GetDescription(loc.Variation)}, landblock 0x{loc.Landblock:X4}.");

                var instances = LandblockManager.GetLoadedLandblocks().Where(lb => lb.IsInstance).OrderBy(lb => lb.VariationId).ToList();
                sb.AppendLine($"Loaded instances: {instances.Count}");
                foreach (var lb in instances)
                    sb.AppendLine($"  0x{lb.Id.Landblock:X4} {InstanceManager.GetDescription(lb.VariationId)} - {lb.GetCurrentLandblockPlayers().Count} player(s){(lb.IsDormant ? ", dormant" : "")}");

                session.Network.EnqueueSend(new GameMessageSystemChat(sb.ToString(), ChatMessageType.Broadcast));
                return;
            }

            switch (parameters[0].ToLower())
            {
                case "new":
                {
                    if (!loc.Indoors)
                    {
                        session.Network.EnqueueSend(new GameMessageSystemChat("Instances are for dungeons. Go inside a dungeon first.", ChatMessageType.Broadcast));
                        return;
                    }

                    var content = InstanceManager.ArenaContent;
                    if (parameters.Length > 1 && !int.TryParse(parameters[1], out content))
                    {
                        session.Network.EnqueueSend(new GameMessageSystemChat("Usage: @instance new [content number]", ChatMessageType.Broadcast));
                        return;
                    }

                    var variation = InstanceManager.CreateInstance(content, $"@instance by {player.Name}");
                    var dest = new Position(loc).WithVariation(variation);

                    session.Network.EnqueueSend(new GameMessageSystemChat($"Moving you to {InstanceManager.GetDescription(variation)} of 0x{loc.Landblock:X4}.", ChatMessageType.Broadcast));
                    player.Teleport(dest);
                    break;
                }

                case "leave":
                {
                    if (!loc.Variation.HasValue)
                    {
                        session.Network.EnqueueSend(new GameMessageSystemChat("You're already in the normal world.", ChatMessageType.Broadcast));
                        return;
                    }

                    var dest = new Position(loc).WithVariation(null);

                    session.Network.EnqueueSend(new GameMessageSystemChat($"Moving you to the normal world copy of 0x{loc.Landblock:X4}.", ChatMessageType.Broadcast));
                    player.Teleport(dest);
                    break;
                }

                default:
                    session.Network.EnqueueSend(new GameMessageSystemChat("Usage: @instance, @instance new [content], @instance leave", ChatMessageType.Broadcast));
                    break;
            }
        }
    }
}
