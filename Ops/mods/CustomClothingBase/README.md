# CustomClothingBase (JawnTide build)

[CustomClothingBase](https://github.com/OptimShi/CustomClothingBase) by OptimShi is an ACE mod that changes clothing
looks and colors on the server side (players download nothing). The live server loads it from `Mods/CustomClothingBase`
(mounted into the container as `/ace/Mods`). Custom looks go in `Mods/CustomClothingBase/json/` as `<ClothingBaseID>.json`
(hex, e.g. `10000188.json`); see the mod's `Examples` folder. In game: `@clothingbase-export <id>` writes an existing
entry to JSON to start from, `@clear-clothing-cache` reloads after editing.

The mod's source is not copied into this repo. This folder only holds the project that builds it against JawnTide.

## Updating (NEW PC)

1. Build the server once: `dotnet build Source\ACE.Server -c Debug -p:Platform=x64`
2. Get or update the mod source next to JawnTide: `C:\Users\kylei\source\repos\CustomClothingBase`
   (`git clone https://github.com/OptimShi/CustomClothingBase.git`, or `git pull` in it)
3. `dotnet build Ops\mods\CustomClothingBase\CustomClothingBase.csproj -c Release`
4. Commit `Mods/CustomClothingBase` (by file name). `Settings.json` and the `json` folder are kept.
