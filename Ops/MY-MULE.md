# My Mule (staff notes)

Ported from ClassicPvP's `feature/my-mule` (Supershoff/ClassicPvP). Players type `/mule` for the gem (8144001), use it
to summon a personal vendor (8144003) next to them, sell to store and buy to take back, free. Storage is account-wide:
a chain of off-world containers (8144002), head GUID in `ace_shard.account_mule` (created by
`Database/Updates/Shard/2026-11-02-00-Add-Account-Mule.sql` at server start), each next link in
PropertyInstanceId 20003 (MuleNextContainerId). Up to 10 containers x 255 items.

JawnTide rules (differences from ClassicPvP): summon anywhere except while PK tagged or in an arena; owner's account
only (no house guests, nobody else can open or search a mule); no store/take while PK tagged; the mule leaves on PK tag,
landblock change, teleport, 40 m distance or logout (Player.MuleTick in the heartbeat); split deposits save the
player's smaller stack first.

Safety guards in shared code (do not remove):
- `WorldObject.Destroy()`: destroying a mule vendor never destroys its sale-list items (they ARE the stored items).
- `Vendor.RotUniques()`: skipped for mules (JawnTide rots sold items after `vendor_unique_rot_time`, 5 minutes, and
  destroys them, which would delete stored items).

Do not turn on `PurgeOrphanedBiotas` (offline config) without checking it leaves the mule containers alone: they have
no owner or location by design.

Look up an account's storage: `SELECT * FROM ace_shard.account_mule WHERE account_Id = N;` then the items are the biotas
whose Container (PropertyInstanceId 2) is that container GUID (and the next ones in the chain).
