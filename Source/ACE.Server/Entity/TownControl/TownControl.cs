using ACE.Database;
using ACE.Database.Models.TownControl;
using log4net;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ACE.Server.Entity.TownControl
{
    public static class TownControl
    {
        private static volatile Dictionary<uint, Town> _towns = null;
        private static readonly object _townsLock = new object();

        public static Dictionary<uint, Town> TownsMap
        {
            get
            {
                if (_towns == null)
                {
                    lock (_townsLock)
                    {
                        if (_towns == null)
                        {
                            var dict = new Dictionary<uint, Town>();
                            foreach (var townDb in DatabaseManager.TownControl.GetAllTowns())
                                dict[townDb.TownId] = townDb;

                            _towns = dict;   // published only after a successful, complete load
                        }
                    }
                }

                return _towns;
            }
        }

        public static List<Town> Towns
        {
            get
            {
                return TownsMap.Values?.ToList();
            }
        }        

        public static Town GetTownById(uint id)
        {
            return TownsMap.TryGetValue(id, out var town) ? town : null;
        }

        public static void UpdateTown(Town town)
        {
            if(TownsMap.ContainsKey(town.TownId))
            {
                TownsMap[town.TownId] = town;
                DatabaseManager.TownControl.UpdateTown(town);
            }            
        }

        private static readonly object _eventCacheLock = new object();

        private static volatile Dictionary<uint, TownControlEvent> _latestEventsByTown = null;

        public static Dictionary<uint, TownControlEvent> LatestEventsByTown
        {
            get
            {
                if (_latestEventsByTown == null)
                {
                    lock (_eventCacheLock)
                    {
                        if (_latestEventsByTown == null)
                        {
                            var dict = new Dictionary<uint, TownControlEvent>();
                            foreach (var town in Towns)
                            {
                                var latestEvent = DatabaseManager.TownControl.GetLatestTownControlEventByTownId(town.TownId);
                                if (latestEvent != null)
                                {
                                    dict[town.TownId] = latestEvent;
                                }
                            }

                            _latestEventsByTown = dict;   // published only after a complete load
                        }
                    }
                }

                return _latestEventsByTown;
            }
        }

        /// <summary>
        /// Returns the latest event for the town, or null if the town has never had an event
        /// </summary>
        public static TownControlEvent GetLatestTownControlEventByTownId(uint townId)
        {
            return LatestEventsByTown.TryGetValue(townId, out var tcEvent) ? tcEvent : null;
        }


        private static volatile Dictionary<uint, List<TownControlEvent>> _latestEventsByMonarch = null;

        public static Dictionary<uint, List<TownControlEvent>> LatestEventsByMonarch
        {
            get
            {
                if (_latestEventsByMonarch == null)
                {
                    lock (_eventCacheLock)
                    {
                        if (_latestEventsByMonarch == null)
                        {
                            var dict = new Dictionary<uint, List<TownControlEvent>>();
                            var monarchIds = TownControlAllegiances.AllowedAllegianceList;
                            foreach (var monarchId in monarchIds)
                            {
                                var events = new List<TownControlEvent>();
                                foreach (var town in Towns)
                                {
                                    var latestEvent = DatabaseManager.TownControl.GetLatestTownControlEventByAttackingMonarchId((uint)monarchId, town.TownId);
                                    if (latestEvent != null)
                                    {
                                        events.Add(latestEvent);
                                    }
                                }

                                if (events.Count > 0)
                                {
                                    dict[(uint)monarchId] = events;
                                }
                            }

                            _latestEventsByMonarch = dict;   // published only after a complete load
                        }
                    }
                }

                return _latestEventsByMonarch;
            }
        }

        public static TownControlEvent GetLatestTownControlEventByAttackingMonarchId(uint attackingMonarchId, uint townId)
        {
            if(LatestEventsByMonarch.ContainsKey(attackingMonarchId))
            {
                return LatestEventsByMonarch[attackingMonarchId].FirstOrDefault(x => x.TownId == townId);
            }

            return null;
        }

        public static TownControlEvent StartTownControlEvent(uint townId, uint attackingClanId, string attackingClanName, uint? defendingClanId, string defendingClanName)
        {
            var tcEvent = DatabaseManager.TownControl.StartTownControlEvent(townId, attackingClanId, attackingClanName, defendingClanId, defendingClanName);

            if(tcEvent != null)
            {
                LatestEventsByTown[townId] = tcEvent;

                // A clan that has never attacked before has no entry yet, so create one instead of throwing
                if (LatestEventsByMonarch.TryGetValue(attackingClanId, out var clanEvents) && clanEvents != null)
                {
                    clanEvents.RemoveAll(x => x.TownId == townId);
                    clanEvents.Add(tcEvent);
                }
                else
                {
                    LatestEventsByMonarch[attackingClanId] = new List<TownControlEvent> { tcEvent };
                }
            }

            return tcEvent;
        }

        public static void UpdateTownControlEvent(TownControlEvent tcEvent)
        {
            if (tcEvent != null)
            {
                DatabaseManager.TownControl.UpdateTownControlEvent(tcEvent);

                LatestEventsByTown[tcEvent.TownId] = tcEvent;

                if (LatestEventsByMonarch.ContainsKey(tcEvent.AttackingClanId))
                {
                    LatestEventsByMonarch[tcEvent.AttackingClanId]?.RemoveAll(x => x.TownId == tcEvent.TownId);
                    LatestEventsByMonarch[tcEvent.AttackingClanId]?.Add(tcEvent);
                }
                else
                {
                    LatestEventsByMonarch.Add(tcEvent.AttackingClanId, new List<TownControlEvent> { tcEvent });
                }
            }
        }
    }
}

