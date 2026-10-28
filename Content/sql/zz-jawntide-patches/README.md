# JawnTide patches

Small SQL files that change stock or custom world data after the rest of the content is imported.

- The folder name starts with `zz-` on purpose. The server runs content SQL in sorted full-path order,
  so these run **after** `Content/sql/weenies/...` and `Content/sql/landblocks/...`.
- Every file is **safe to run repeatedly** (the server re-runs content on startup).
- Files only change the world database. Never write to `ace_shard` or any other database from Content (see `Ops/archive/README.md`).
- Files never refer to auto-numbered ids (emote ids and so on), because those differ on every fresh database.

| File | What it does |
|---|---|
| `01-aetheria-stone-from-scarab.sql` | Morgana Le Fay (32000110) gives an Aetheria Mana Stone each time a Platinum Scarab is shown to her |
| `02-luminance-token-fast-respawn.sql` | Luminance tokens respawn about 1 second after pickup (generator 15759, shared by ~200 placements) |
| `03-full-coverage-underwear.sql` | Every undershirt covers chest, upper arms and lower arms, and every pair of underpants covers abdomen, upper legs and lower legs (tunics, short sleeves, breeches and so on get the missing parts). Items already in the world need `Ops/sql-snippets/full-coverage-underwear-shard.sql`, run once with the game server stopped |

Deliberately NOT included: the Outpost Sewer opened to everyone.
