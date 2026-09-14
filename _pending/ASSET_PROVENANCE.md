# RS_VR_Weapons — where every model and sound came from (for the public repo)

2026-09-13, weapons lane. The owner's plan ends in public repos for RS_VR_Weapons and RS_VR_Reload. A repo people
download has to say where its assets came from and on what terms, so this is that list, from what the package's
own records say (MODELDEF comments, SNDINFO comments, the candidate docs, the ModelSwapper lane's set notes).

**Nothing here is a licence decision.** Where a row says "unrecorded", no licence is written anywhere in this
tree; the owner decides what ships.

## Sources, and what is recorded about them

| Source | What it is | Terms recorded | Owner clearance |
|---|---|---|---|
| **Force Unleashed** (`_old/doom-force-unleashed_devbuild`) | Ermac's "Rusted Legacy" VR mod | **MIT**, Copyright (c) 2025 iAmErmac (its LICENSE). Its README credits Brutal Doom for "sfx codes, sprites and sounds" and Sketchfab authors for its 3D models (it lists them) | cleared ("force unleashed is good to use, ermacs mod"; "yes", 09-13) |
| **RS_ModelSwapper**, by prefix (the ModelSwapper lane) | `MS_` / `MS_VR_`: the VanAlek VR set. `MS_BD_`: Brutal Doom v21 imports. `MS_GH_`: RS_Main's curated subset. `MS_MG_`: MeatGrinder. `MS_BW_`: the Brutal Wolfenstein VR pack. `MS_AE_`, `MS_RC_`: not recorded (README: AE = Aliens: Eradication) | unrecorded | the owner allowed copying ModelSwapper meshes into this package |
| **RS_Main's sound pool** (`sounds/combatfx`, `sounds/rs_weapon`) | the RS project's own library | its SNDINFO calls it "licensed" | cleared (the owner named it) |
| **RS_Grenade** | the owner's grenade mod | owner's own | cleared (its resources) |
| **The Doom IWAD** | sounds used **by name only** (`weapons/sshotf` ...) | not redistributed: nothing copied | — |

## Models

| Gun / item | Files (`models/`) | Donor | Terms |
|---|---|---|---|
| M4A3 (main) | `pistols/m4a3.md3`, `m4a3.png`, `wm_m4a3_mag.md3` | RS_ModelSwapper's pistol block (set not recorded) | unrecorded |
| Pistolet (off) | `pistols/pistolet.md3`, `WPN-9mm.png`, `wm_pistolet_mag.md3` | RS_ModelSwapper (RS_Main's 9mm) | unrecorded |
| Loose round | `pistols/bullet.md3`, `bullet.png` | came with the pistols from the reload system; origin not recorded | unrecorded |
| M37A2 pump (main) | `shotguns/AE_Shotgun/m37a2.md3`, `.png` | RS_ModelSwapper `MS_AE_Shotgun` (Aliens: Eradication) | unrecorded |
| Doom shotgun (off) | `shotguns/Shotgun/shotgun.md3`, `WPN-GUNS-k1.png`, `wm_shotshell.md3` | RS_ModelSwapper `MS_Shotgun` (VanAlek) | unrecorded |
| Super shotgun (main) | `shotguns/SuperShotgun/ssg.md3`, `WPN-GUNS-k1.png` | RS_ModelSwapper `MS_SuperShotgun` (VanAlek) | unrecorded |
| Double Barrel (off) | `shotguns/DoubleBarrel/*` | Force Unleashed `ssg.md3` + `ssg_shell.md3` | MIT (Ermac) |
| Assault shotgun | `shotguns/AssaultShotgun/*` — **carried, drawn by nothing** | RS_ModelSwapper `MS_BD_` (Brutal Doom v21) | unrecorded; Brutal Doom |
| Moonlight / Sunset | `revolvers/Revolver/*` | RS_ModelSwapper `MS_Revolver` / `MS_Revolver2` | unrecorded |
| Cola revolver | `revolvers/Cola_Revolver/*` | RS_ModelSwapper `MS_Cola_Revolver` | unrecorded |
| Rifle | `rifles/Rifle/*` | RS_ModelSwapper rifle block | unrecorded |
| M16 | `rifles/M16/*` | RS_ModelSwapper `MS_Rifle` | unrecorded |
| Tec9 | `smgs/Tec9/*` | RS_ModelSwapper `MS_MG_Tec9` (MeatGrinder) | unrecorded |
| SMG | `smgs/SMG/*` | RS_ModelSwapper SMG block | unrecorded |
| Railgun | `railguns/Railgun/*` | RS_ModelSwapper `models/hud/RailGun` | unrecorded |
| Plasma rifle | `plasma/PlasmaRifle/*` | RS_ModelSwapper plasma rifle block | unrecorded |
| Plasma carbine | `plasma/PlasmaCarbine/*` | Force Unleashed plasma rifle + cell | MIT (Ermac) |
| Chaingun, belt link | `chainguns/Chaingun/*` | Force Unleashed chaingun, box, belt, `cg_ammoclip.md3` | MIT (Ermac) |
| Machine gun | `chainguns/MachineGun/*` | RS_ModelSwapper belt-fed machine gun block | unrecorded |
| Launcher grenade | `grenades/nade.md3`, `nade.png` | RS_Grenade | owner's own |
| Rocket launcher | `launchers/RocketLauncher/*` | Force Unleashed | MIT (Ermac) |
| RPG | `launchers/RPG/*` | RS_ModelSwapper `MS_RocketLauncher` | unrecorded |
| BFG, meter, spent cell | `bfg/BFG/*` | Force Unleashed `bfg9000` | MIT (Ermac) |
| Heavy BFG | `bfg/BFGHeavy/*` | RS_ModelSwapper `MS_VR_BFG9000` (VanAlek VR) | unrecorded |
| Chainsaw | `chainsaws/Chainsaw/*` | RS_ModelSwapper `MS_Chainsaw` | unrecorded |
| Heavy chainsaw | `chainsaws/ChainsawHeavy/*` | Force Unleashed chainsaw + blades | MIT (Ermac) |
| Flamer | `flamers/Flamer/*` | RS_ModelSwapper `MS_AE_Flamer` (m260b.md3) | unrecorded |
| Flamethrower | `flamers/Flamethrower/*` | Force Unleashed incinerator + gas can | MIT (Ermac) |
| Shotgun shell | `shell/shell.md3`, `shell.png` | Force Unleashed | MIT (Ermac) |
| Ammo pickups | `ammo/*` | Force Unleashed `modeldefs/ammo.txt` meshes | MIT (Ermac) |
| Hand ammo | `ammo_hand/*` | Force Unleashed | MIT (Ermac) |

## Sounds (`sounds/`)

| Folder | Donor | Terms |
|---|---|---|
| `pistols`, `revolvers`, `rifles`, `chainguns`, `launchers`, `plasma`, `bfg`, `chainsaws`, `magdrops` | RS_Main's pool (combatfx, rs_weapon) — SNDINFO.txt names each | RS_Main's "licensed pool" |
| `shotguns/DoubleBarrel` | Force Unleashed `sounds/weapons/ssg` | MIT (Ermac); FU's README credits Brutal Doom for its sounds |
| IWAD names (`weapons/shotgr`, `weapons/sshotf`, ...) | Doom | referenced, not shipped |

The sound-selection addon (RS_VR_SoundSelection) carries its own `CREDITS.txt` and `licenses/`.

## Before the public repo — the owner's calls

1. **The RS_ModelSwapper meshes** (VanAlek, Aliens: Eradication, MeatGrinder, and the unrecorded sets): no
   licence is written for any of them. They are most of the arsenal: both pistols, both pumps, the SSG, all
   three revolvers, both rifles, both SMGs, the railgun, the plasma rifle, the machine gun, the RPG, the heavy
   BFG, the chainsaw, the flamer.
2. **The Brutal Doom asset** `shotguns/AssaultShotgun` is carried but drawn by nothing — it can simply be left
   out of the release.
3. **Force Unleashed**: MIT, so the release carries its copyright notice (a `licenses/` folder, as the sound
   addon does) and a credit. Its README says some of its sounds and sprites came from Brutal Doom.
4. **README.md is out of date** (it describes the first two pistols and two pumps only) and has no credits
   section; the release needs both rewritten from this sheet once the calls above are made.
