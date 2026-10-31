# DatFind

Custom clothing looks (CustomClothingBase JSON) swap **0x05 SurfaceTexture** IDs, but ACViewer shows you the
**0x06 texture image**. This finds the 0x05 that wraps an image, from the client's `client_portal.dat`:

    dotnet run --project Ops\tools\DatFind -- "C:\Turbine\Asheron's Call" 0x06007000

Give a 0x05 ID instead to see which image it wraps. Several IDs can be given at once.
