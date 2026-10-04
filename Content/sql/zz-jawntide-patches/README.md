# JawnTide patches

Small SQL files that change stock or custom world data after the rest of the content is imported.

- The folder name starts with `zz-` on purpose. The server runs content SQL in sorted full-path order,
  so these run **after** `Content/sql/weenies/...` and `Content/sql/landblocks/...`.
- Every file is **safe to run repeatedly** (the server re-runs content on startup).
- Files never refer to auto-numbered ids (emote ids and so on), because those differ on every fresh database.

| File | What it does |
|---|---|
| `01-aetheria-stone-from-scarab.sql` | Morgana Le Fay (32000110) gives an Aetheria Mana Stone each time a Platinum Scarab is shown to her |
| `02-luminance-token-fast-respawn.sql` | Luminance tokens respawn about 1 second after pickup (generator 15759, shared by ~200 placements) |

Deliberately NOT included: the Outpost Sewer opened to everyone.
