using System;
using System.Linq;
using ACE.Entity.Enum.Properties;
using ACE.Server.Entity.TownControl;
using ACE.Server.Managers;
using log4net;
using Newtonsoft.Json;

namespace ACE.Server.Entity
{
    public static class IPlayerExtensions
    {
        private static readonly ILog log =
            LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public static T LoadSerialized<T>(this IPlayer player, PropertyString propertyKey)
            where T : new()
        {
            var serialized = player.GetProperty(propertyKey);

            if (string.IsNullOrEmpty(serialized))
                return new T();

            try
            {
                return JsonConvert.DeserializeObject<T>(serialized) ?? new T();
            }
            catch (Exception ex)
            {
                log.Error($"Failed to deserialize {propertyKey} for player {player.Name} (Guid: {player.Guid.Full}). Exception: {ex}");
                return new T();
            }
        }

        public static void SaveSerialized<T>(this IPlayer player, PropertyString propertyKey, T data)
        {
            try
            {
                player.SetProperty(propertyKey, JsonConvert.SerializeObject(data));
            }
            catch (Exception ex)
            {
                log.Error($"Failed to serialize {propertyKey} for player {player.Name} (Guid: {player.Guid.Full}). Exception: {ex}");
            }
        }

        public static bool IsAllegianceWhitelisted(this IPlayer player)
        {
            var allegiance = AllegianceManager.GetAllegiance(player);
            return allegiance?.MonarchId.HasValue == true && TownControlAllegiances.IsAllowedAllegiance((int)allegiance.MonarchId!.Value);
        }

        public static bool IsSameAllegiance(this IPlayer playerA, IPlayer playerB)
        {
            var playerAMonarch = playerA.MonarchId != null ? playerA.MonarchId : playerA.Guid.Full;
            var playerBMonarch = playerB.MonarchId != null ? playerB.MonarchId : playerB.Guid.Full;

            return playerAMonarch == playerBMonarch;
        }

        /// <summary>
        /// Returns true if a DIFFERENT character on this player's account belongs to the allegiance
        /// led by <paramref name="monarchId"/>. The player's own character is excluded; the monarch
        /// (whose own MonarchId may be null/self) is matched by guid. Uses verified allegiance
        /// membership, matching the account-lock semantics.
        /// </summary>
        public static bool AccountHasAllegianceMember(this IPlayer player, uint monarchId)
        {
            if (monarchId == 0 || player?.Account == null)
                return false;

            var accountPlayers = PlayerManager.GetAccountPlayers(player.Account.AccountId);
            if (accountPlayers == null)
                return false;

            return accountPlayers.Values.Any(p =>
                p.Guid != player.Guid &&
                ((AllegianceManager.GetVerifiedMonarchId(p) ?? p.Guid.Full) == monarchId));
        }

        /// <summary>
        /// Anti-alt-farming rule: returns true when the victim is a throwaway parked on an
        /// allegiance-mate's account - i.e. the victim's account holds another character sworn into
        /// the KILLER's allegiance. Such kills earn no PK rewards. Solo killers never match.
        /// </summary>
        public static bool VictimIsAllegianceMateAlt(this IPlayer killer, IPlayer victim)
        {
            var killerMonarch = AllegianceManager.GetAllegiance(killer)?.MonarchId;
            if (!killerMonarch.HasValue || victim == null)
                return false;

            return victim.AccountHasAllegianceMember(killerMonarch.Value);
        }
    }
}
