using System;
using System.Threading.Tasks;

namespace ACE.Database
{
    public partial class SerializedShardDatabase
    {
        /// <summary>
        /// JawnTide Marketplace: runs work on the single save queue, after every save queued before it (character and item saves
        /// included), so it always sees their results. Work that queues saves of its own and then calls this again gets a
        /// second step that runs after those saves too.
        /// </summary>
        public void MarketEnqueue(Action work)
        {
            _queue.Add(new Task(() =>
            {
                try
                {
                    work();
                }
                catch (Exception ex)
                {
                    log.Error($"[MARKET] Unhandled exception in a market database step: {ex}");
                }
            }));
        }
    }
}
