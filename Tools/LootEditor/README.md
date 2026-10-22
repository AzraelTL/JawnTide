# JawnTide Loot Editor (chests, NPC reward tables, loot profiles)

A small Windows app for editing the random item lists inside chests
(Darkbeat's Storage Locker, Empyrean Cache, the Casino chests and so on).

It edits the chest SQL files in `Content/sql/weenies`. It never touches the database.
The server picks up the changes the usual way (import the file, or a restart with
AutoApplyWorldCustomizations on).

It also edits **NPC random reward tables**: a group of emotes that share one name, where the NPC rolls
once and gives one item (for example Aidoneus's `WorldBoss_random_reward`, the Casino gamesmasters, Hera).
Those show in the list as `[NPC] Name - table`. For them the editor also lists the NPC's **fixed rewards**
(Give actions that always happen, such as Aidoneus's PK Trophies and Trade Notes) where you can change the
WCID or stack size. Adding or removing fixed rewards, and other NPC actions (XP, luminance), are not edited here.

It also edits **loot profiles** (`treasure_death` files in `Content/sql`, shown as `[Loot profile] N`):
the tier, quality modifier, and how many magic / non-magic / mundane items drop, for monsters that use the
profile (DeathTreasureType) and containers that roll it. The "Used by" list shows which monsters and containers
in Content use it. Stock profiles that aren't in Content aren't listed. The server's `loot_max_tier` setting still
caps the tier at runtime, whatever the profile says.

## Build and run (Windows)

    cd /d C:\Users\kylei\source\repos\JawnTide
    dotnet build Tools\LootEditor\LootEditor.csproj -c Release
    Tools\LootEditor\bin\Release\net10.0-windows\JawnTideLootEditor.exe

## Using it

- **Repo folder** is found automatically when the exe runs from inside the repo. It is remembered.
- **Chests** (left) are every Chest weenie in `Content/sql/weenies` with a generator list.
- **Always generated** shows rows that are always created (for example the chest's random loot profile).
  These are kept as they are.
- **Random pick items** (grid): each row is one possible item. "Chance per pick %" is a plain percentage;
  the chest rolls once per pick and makes several picks when it fills. The chances must add up to 100%.
  The editor converts these to the cumulative numbers the server expects when it saves.
- **Total** (bottom left) updates while you type. When it isn't 100% it turns red and says how much to
  add or remove. **Scale to 100%** multiplies every chance by the same factor so the list adds up to exactly
  100% and each item keeps the same share (for example after removing items).
- **Stack**: -1 means the item's default stack size.
- **Add item**: type the WCID; the name is looked up from `Content/sql`. Stock items that aren't in
  Content (for example Foolproofs) show "not found" unless another chest already names them; they still work.
- **Edit target**:
  - `Content (current stage)` saves into `Content/sql/weenies/...`, which is what the server loads.
  - A stage (for example `stage2`) saves into `Ops/loot-stages/stage2/weenies/...` instead, so a future stage
    can be prepared without changing the current one. `New stage...` creates a stage folder.
    `Ops/loot-stages` is outside `Content/sql` on purpose, so the server never imports a stage early.

Only the generator list in the file is rewritten; everything else in the file is left exactly as it was.
Commit saved files on a branch like any other change.
