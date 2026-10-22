# VRContent patch (Viridian Rise)

Viridian Rise content held back from launch as one patch that can be applied on its own, at any time,
independent of the loot stages (stage2, stage3, ...). Each file here is the version the patch puts back,
with the same relative path as in `Content/sql`.

## What the patch restores

| File | Restores |
|---|---|
| `landblocks/B54A.sql` | Brellegia, Doriathazaar and Doriathazaar's Horde (9), Summercrown, Aangesilus, Dridge, Kervim'telek, Swift and the Temple of the Font (53477) in the Viridian Rise camp, and their generator |
| `landblocks/B349, B34A, B44B, B549, B54B, B649, B64A, B64B.sql` | the 30 Ancient Statues of the Viridian Rise (and the statue generators in B34A, B44B, B54B, B649, B64A); in B349 also Brellegia's and Aangesilus' Markers |
| `landblocks/5966.sql`, `landblocks/B449.sql` | the 16 Ancient Statues of the Viridian Root (10 in the dungeon 5966, 6 in B449) |
| `weenies/Town Control/` (the three Town Treasurers) | the Viridian Rise Deru Portal Sending Gem (53450) and the Temple of the Font Sending Gem (480600) in their shops |
| `weenies/VR/` (Wind Fury, NightBrier, Norshuntyr, Zerzelikyr) | their Deru Portal Sending Gem drops (5 rolls of 20% each) |

The landblock files are ACE's stock versions (ACE-World-16PY-Patches, commit f5edf9b), which matched the live
world database when the patch was made. The Treasurer and creature files are the Content versions from just
before the patch; if those files change later for other reasons, merge by hand instead of copying over them.

Kervim'telek's own reward table still lists the gem and both recall scrolls (Scroll of Viridian Rise
Recall 53302, Scroll of Viridian Rise Tree Recall 72003), but with him out of the world nothing gives them.

## Applying it

On a branch: copy this folder's files over `Content/sql` (same relative paths), commit, test on JawnTest,
merge, deploy, import the changed files on live, then `clearcache weenie` or restart. Move the VRContent
section of DISABLED.md to "Brought back".
