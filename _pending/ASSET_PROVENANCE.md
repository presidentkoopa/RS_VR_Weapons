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
| **RS_ShieldSaw** | Rusted Legacy's shield saw rebuilt on a stock weapon, via RS_ForceUnleashed | MIT (Ermac) | cleared (the owner's fold, 09-14) |
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
| Assault shotgun (old mesh) | `shotguns/AssaultShotgun/*` — **drawn by nothing; moved 09-14 to `_pending/_unused/models/shotguns/AssaultShotgun/`, not packed** (the Assault Shotgun draws `shotguns/AssaultShotgunGH`) | RS_ModelSwapper `MS_BD_` (Brutal Doom v21) | unrecorded; Brutal Doom |
| Moonlight / Sunset | `revolvers/Revolver/*` | RS_ModelSwapper `MS_Revolver` / `MS_Revolver2` | unrecorded |
| Cola revolver | `revolvers/Cola_Revolver/*` | RS_ModelSwapper `MS_Cola_Revolver` | unrecorded |
| Rifle | `rifles/Rifle/*` | RS_ModelSwapper rifle block | unrecorded |
| M16 | `rifles/M16/*` | RS_ModelSwapper `MS_Rifle` | unrecorded |
| Tec9 | `smgs/Tec9/*` | RS_ModelSwapper `MS_MG_Tec9` (MeatGrinder) | unrecorded |
| SMG | `smgs/SMG/*` | RS_ModelSwapper SMG block | unrecorded |
| Railgun | `railguns/Railgun/*` | RS_ModelSwapper `models/hud/RailGun` | unrecorded |
| Plasma rifle | `plasma/PlasmaRifle/*` | RS_ModelSwapper plasma rifle block | unrecorded |
| Blue plasma rifle skin (09-14) | `plasma/PlasmaRifle/PlasmaRifleBlue.png` | the Plasma Rifle's own `PlasmaRifle.png`, every colour turned steel blue (hue 0.60, saturation at least 0.28, brightness kept) by the weapons lane | as the Plasma Rifle's |
| Plasma carbine | `plasma/PlasmaCarbine/*` | Force Unleashed plasma rifle + cell | MIT (Ermac) |
| Chaingun (09-15) | `chainguns/ChaingunGH/*` | RS_Main `models/weapons/hud/RS_GH_Weapon/RS_GH_Minigun/` Minigun.md3 frame 4 (the ready pose) + Minigun.png; the skin unchanged, the mesh's surfaces merged into body / trigger / barrels and re-origined by the reload lane; the same mesh as RS_ModelSwapper `models/hud/Chaingun/Chaingun.md3`, shifted whole | unrecorded |
| Belt link and its skin | `chainguns/Chaingun/cg_ammoclip.md3`, `chaingun_HD.png` | Force Unleashed `cg_ammoclip.md3` (the Machine Gun's and Rotary Gun's links) | MIT (Ermac) |
| Old chaingun and box (retired 09-15) | `_pending/_unused/chainguns/Chaingun/*`, not packed | Force Unleashed chaingun, box, belt | MIT (Ermac) |
| Machine gun | `chainguns/MachineGun/*` | RS_ModelSwapper belt-fed machine gun block | unrecorded |
| Launcher grenade | `grenades/nade.md3`, `nade.png` | RS_Grenade | owner's own |
| Rocket launcher (09-15) | draws `launchers/RPG/rpg_wm.md3`, `rpg.png`, `wm_rocket.md3` (the RPG's) | the RS_ModelSwapper rocket launcher the RPG draws; RS_Main's `RS_GH_RocketLauncher/RPG.md3` is that mesh shifted whole (same triangles and UVs); re-carded by the reload lane | as the RPG's |
| Old rocket launcher (retired 09-15) | `_pending/_unused/launchers/RocketLauncher/*`, not packed | Force Unleashed | MIT (Ermac) |
| RPG | `launchers/RPG/*` | RS_ModelSwapper `MS_RocketLauncher` | unrecorded |
| BFG battery skins (loose cell, spent cell) | `bfg/BFG/bfg9000.png`, `bfg9000_off.png` | Force Unleashed `bfg9000` | MIT (Ermac) |
| Old BFG 9000 gun and meter (retired 09-15) | `_pending/_unused/bfg/BFG/*`, not packed | Force Unleashed `bfg9000` | MIT (Ermac) |
| Heavy BFG | `bfg/BFGHeavy/*` | RS_ModelSwapper `MS_VR_BFG9000` (VanAlek VR) | unrecorded |
| Chainsaw | `chainsaws/Chainsaw/*` | RS_ModelSwapper `MS_Chainsaw` | unrecorded |
| Heavy chainsaw | `chainsaws/ChainsawHeavy/*` | Force Unleashed chainsaw + blades | MIT (Ermac) |
| Flamer | `flamers/Flamer/*` | RS_ModelSwapper `MS_AE_Flamer` (m260b.md3) | unrecorded |
| Flamethrower (09-14) | `flamers/Flamethrower2/*` | RS_Main `models/weapons/hud/RS_GH_Weapon/RS_GH_Flamethrower/` Flamethrower2.md3 + Flamethrower2.png (RS_Main's `Model RS_GH_Flamethrower`); the skin byte-identical, the mesh modified by the reload lane (frame 0 only, split into body / trigger / canister / pilotflame, re-origined) | unrecorded |
| Old flamethrower (retired 09-14) | `_pending/_unused/flamers/Flamethrower/*`, not packed | Force Unleashed incinerator + gas can | MIT (Ermac) |
| Shotgun shell | `shell/shell.md3`, `shell.png` | Force Unleashed | MIT (Ermac) |
| Ammo pickups | `ammo/*` | Force Unleashed `modeldefs/ammo.txt` meshes | MIT (Ermac) |
| Hand ammo | `ammo_hand/*` | Force Unleashed | MIT (Ermac) |
| Grenade (throwable, 09-14) | `grenades/grenade_wm.md3` (skin `grenades/nade.png`) | RS_Grenade `models/grenade/nade.md3` frame 2, re-origined | owner's own (RS_Grenade, public) |
| Assault shotgun (09-14) | `shotguns/AssaultShotgunGH/*` (_wm, loose magazine, skin) | RS_Main `models/weapons/hud/RS_GH_Weapon/RS_GH_AssaultShotgun`, frame 4, re-origined | RS_Main's assets cleared by the owner 09-14 ("RS_Main is fair game"); the RS_GH set's own origin unrecorded |
| Bullpup pump (09-14) | `shotguns/BullpupPump/*` | RS_Main `models/meatgrinder/SSG` (MeatGrinder), frame 0, re-origined | RS_Main cleared 09-14; MeatGrinder's own terms unrecorded |
| Bolter (09-14) | `plasma/Bolter/*` (_wm, loose magazine, skin) | RS_ModelSwapper `MS_MG_Bolter` (RS_Main's MeatGrinder Bolter, re-centred) | as above |
| BFG rifle, rotary gun, rotary launcher, longbar chainsaw (09-14) | `bfg/BFGRifle`, `chainguns/RotaryGun`, `launchers/RotaryLauncher`, `chainsaws/LongbarChainsaw` | RS_Main `models/meatgrinder/BFG`, `ChainGun`, `RPG`, `Saw`, frame 0, re-origined | as above |
| Unmaker (09-14) | `unmaker/Unmaker/unmaker_wm.md3`, `Unmaker.png`, `wm_unmaker_skull.md3` (the skull magazine for its card: flap + lever lifted out of unmaker_wm.md3, re-origined on their centroid) | RS_Main `models/weapons/hud/RS_GH_Weapon/RS_GH_Unmaker` (the same mesh as RS_ModelSwapper's Unmaker), rest frame 0, re-origined | RS_Main cleared 09-14; the RS_GH set's own origin unrecorded |
| RS_Grenade, folded in (09-14) | `models/grenade/*`, `sprites/J*`, `sounds/rs_grenade/*`, `zscript/rs_grenade/*` | RS_Grenade ffff0c6, byte-identical | owner's own |
| RS_ShieldSaw, folded in (09-14) | `models/shieldsaw/*`, `models/hand/*`, `sprites/S*`, its `sounds/*`, `zscript/rs_shieldsaw/*`, `language.txt` | RS_ShieldSaw 4bb43ad, byte-identical | MIT (Ermac), through RS_ShieldSaw |
| ShieldSaw flight (09-14) | `shieldsaw/ShieldSaw/shield_weapon.md3`, `shield_weapon_glow.md3`, `shieldsaw_glow.png` | RS_ShieldSaw, byte-identical | MIT (Ermac), through RS_ShieldSaw |
| ShieldSaw (09-14) | `shieldsaw/ShieldSaw/shieldsaw_wm.md3`, `shieldsaw_HD.png`, `shieldsaw_b_HD.png` | RS_ShieldSaw `shield.md3` + `shieldsaw.md3`; its README: the shield came from Rusted Legacy via RS_ForceUnleashed | MIT (Ermac), through RS_ShieldSaw (public). NOT taken: `shield_saw.md3`, provenance not cleared |

## Sounds (`sounds/`)

| Folder | Donor | Terms |
|---|---|---|
| `pistols`, `revolvers`, `rifles`, `chainguns`, `launchers`, `plasma`, `bfg`, `chainsaws`, `magdrops` | RS_Main's pool (combatfx, rs_weapon) — SNDINFO.txt names each | RS_Main's "licensed pool" |
| `shotguns/DoubleBarrel` | Force Unleashed `sounds/weapons/ssg` | MIT (Ermac); FU's README credits Brutal Doom for its sounds |
| `chainsaws/CSIDLE_HEAVY.wav` (09-14) | RS_Main `sounds/combatfx/foley/CSLOW`: its steady opening, 2.3-133.5 ms, crossfaded 4 ms into a loop, 16-bit wav | RS_Main's pool, cleared 09-14 ("RS_Main is fair game") |
| `shotguns/M37`, `shotguns/DoomPump`, `shotguns/BullpupPump`, `chainguns/MachineGun`, `launchers/UBL`, `launchers/RPG`, `plasma/Carbine`, `bfg/BFGPU.ogg`, `bfg/Heavy`, `unmaker` (09-14, the vanilla sound gaps) | RS_Main's per-weapon folders -- `rs_gh_weapon/gh_pumpshotgun`, `gh_machinegun`, `gh_grenadelauncher`, `gh_plasma`, `gh_unmaker`; `rs_weapon/vr_shotgun`, `vr_rocketlauncher`, `vr_bfg9000`; `rs_st_weapon` -- and `combatfx/foley` (BFGPU); byte-identical, an extensionless lump given its container's extension; SNDINFO.txt's VANILLA SOUND GAPS names each | RS_Main's pool, cleared 09-14 (the owner: "missing sounds can be found in RS Main / sounds / WEAPONNAMESEACH") |
| `chainsaws/DSSAWIDL_LONGBAR.wav` (09-14) | RS_Main `sounds/hq_vanilla/DSSAWIDL`, the DMX lump written out as a 16-bit wav, samples unchanged | RS_Main's pool, cleared 09-14; an HQ remake of Doom's own saw idle |
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
