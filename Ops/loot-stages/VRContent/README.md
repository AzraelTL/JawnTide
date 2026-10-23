# VRContent patch (Viridian Rise)

Viridian Rise content held back from launch as one patch that can be applied on its own, at any time,
independent of the loot stages (stage2, stage3, ...). Each file here is the version the patch puts back,
with the same relative path as in `Content/sql`.

## What the patch restores

| Files | Restores |
|---|---|
| `landblocks/` (20 outdoor landblocks B349, B34A, B448, B449, B44A, B44B, B548, B549, B54A, B54B, B54C, B648, B649, B64A, B64B, B64C, B749, B74A, B74B, and the Viridian Root dungeon 5966) | everything placed in Viridian Rise: the camp NPCs (Brellegia, Doriathazaar and his Horde, Summercrown, Aangesilus, Dridge, Kervim'telek, Swift), the Temple of the Font portal, the Guardians of the ten trees, the markers and notes, all Ancient Statues of the Viridian Rise and of the Viridian Root, the camp generators (A'nekshen, Zefir, Gromnie and Brier Wasp camps), the Sath'tik Eyestalks, the item generators (Amber Shards and other ground spawns), the Viridian portals (entrance, bridge, Deru and the six Viridian Root portals), and the Root dungeon's generators, statues and its exit portal |
| `weenies/Town Control/` (the three Town Treasurers) | the Viridian Rise Deru Portal Sending Gem (53450) and the Temple of the Font Sending Gem (480600) in their shops |
| `weenies/VR/` (Wind Fury, NightBrier, Norshuntyr, Zerzelikyr) | their Deru Portal Sending Gem drops (5 rolls of 20% each) |

While the patch is out, each of those Content landblock files only deletes everything in its landblock, so
nothing spawns there. Creatures that also spawn elsewhere (the Sath'tik Eyestalks, Tendrils and Tentacles in
8A63 and F81E) still spawn there.

The landblock files are ACE's stock versions (ACE-World-16PY-Patches, commit f5edf9b), which matched the live
world database when the patch was made. The Treasurer and creature files are the Content versions from just
before the patch; if those files change later for other reasons, merge by hand instead of copying over them.

Kervim'telek's own reward table still lists the gem and both recall scrolls (Scroll of Viridian Rise
Recall 53302, Scroll of Viridian Rise Tree Recall 72003), but with him out of the world nothing gives them.

## Applying it

On a branch: copy this folder's files over `Content/sql` (same relative paths), commit, test on JawnTest,
merge, deploy, import the changed files on live, then `clearcache weenie` or restart. Move the VRContent
section of DISABLED.md to "Brought back".
