namespace ACE.Server.WorldObjects
{
    partial class Creature
    {
        /// <summary>
        /// JawnTide: set once a world boss that is no longer the active one has been told to despawn (Creature_Tick),
        /// so the removal and its log line happen only once
        /// </summary>
        private bool worldBossRemoving;
    }
}
