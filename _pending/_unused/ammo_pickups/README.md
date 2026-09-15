# Parked: Force Unleashed models on Doom's ammo pickups

The owner, 09-15: "normal doom sprites for world pickups will do just fine for now". Everything that drew Doom's ammo
classes (Clip, ClipBox, Shell, ShellBox, RocketAmmo, RocketBox, Cell, CellPack, Backpack) as 3D models, taken out whole:

- `MODELDEF_ammo_pickups.txt`: the nine blocks, as they were in MODELDEF.txt
- `CVARINFO_ammo_pickups.txt`: the `wm_pu_*` placement sets (90 cvars)
- `MENUDEF_ammo_pickups.txt`: the options-menu door, the hub page and the nine seat pages
- `ammo/`: the meshes and skins (was models/ammo)

To bring them back: move `ammo/` back to models/ammo, paste each text file back where its header says, add the
`wm_pu_*` stems to build.ps1's menu_lint prefix and the meshes to its required list. Design notes: AMMO_MODELS.md.
