# Arsenal candidates — chaingun, plasma rifle, rocket launcher, BFG, railgun, flamethrower, chainsaw

2026-09-13. The owner's order: at least two of each where the models exist ("if we only have one
chaingun then so be it"). Candidates come from two places, both cleared by the owner:
RS_ModelSwapper (listed read-only by the ModelSwapper lane, rs-modelswapper-b8) and Force
Unleashed (`E:\DOOMWork\_old\doom-force-unleashed_devbuild`).

Nothing below is measured by this lane yet unless it says so. Measurements go in this file as
they're done, with the islands-and-relative-motion method (RIFLE_CANDIDATES.md, "How the parts
were found").

**Licence/credit: unrecorded for all of these.** Flag before anything ships.

---

## Force Unleashed — separate magazine models

Force Unleashed draws each gun as `Model 0` (the gun) plus `Model 1` (its magazine, cell, rockets,
pod, gas can or blade) in the same MODELDEF block, same Scale `-1 1 1` and Offset `0 -24 -10`, so
both meshes share one space. Frame 99 on Model 1 is its hidden frame (the magazine out); its
frames 1-5 are the reload.

| Gun | Folder | Gun mesh | Separate part | Their MODELDEF |
|---|---|---|---|---|
| Chaingun | `models/chaingun` | `chaingun.md3` | `cg_mag.md3` (box), plus `cg_ammo1..10.md3` and `cg_ammoclip.md3` | `modeldefs/weapons/chaingun.txt` |
| Plasma rifle | `models/plasmarifle` | `plasma_rifle.md3` | `plasma_mag.md3`, `plasma_mag2.md3`; digit counter `plasma_d1..3.md3` | `plasmarifle.txt` |
| Rocket launcher | `models/rocketlauncher` | `rocketlauncher.md3` | `rockets.md3`, `rockets2.md3`, `rockets3.md3` | `rocketlauncher.txt` |
| BFG 9000 | `models/bfg9000` | `bfg9000.md3` | `bfg9000_pod.md3`, `bfg9000_pod2.md3`; `bfg9000_meter.md3` | `bfg9000.txt` |
| Incinerator (flamethrower) | `models/incinerator` | `flamethrower.md3` | `gascan.md3`, `gascan2.md3` | `incinerator.txt` |
| Heatwave (flamethrower/energy) | `models/heatwave` | `heatwave.md3` | `heat_mag.md3`, `heat_mag2.md3` | `heatwave.txt` |
| Chainsaw | `models/chainsaw` | `chainsaw.md3` | `saw_blade1.md3`, `saw_blade2.md3` (blade frames swap) | `chainsaw.txt` |

`shieldsaw` is RS_ShieldSaw's already, so not a candidate here.

---

## RS_ModelSwapper — the ModelSwapper lane's list (verbatim facts, not re-measured)

"Current" = in `RS_ModelSwapper\models\hud\...`, MODELDEF block in `RS_ModelSwapper\modeldef`
(block name = the MS_ class). Current meshes were re-origined: the rest-frame centroid is at
0,0,0 and the block's Offset compensates. Clip rows (frame ranges) are in
`zscript\RS_ForeignAnim.zs`. "History" = deleted from the tree but in git; extract binary-safe with
`git -C E:\DOOMWork\RS_ModelSwapper archive <commit> <folder> | tar -x -C <dest>` (never PowerShell
`>`). "isl" = islands per surface after welding seam-split vertices. The lane listed separate
surfaces with an authored reload; it did not measure whether each part moves.

### 1. Chaingun
- **MS_Chaingun** (current): `Chaingun/Chaingun.md3`, 16 frames, rest 4; fire 4-12 spins the
  barrels. Surfaces Runko 111v, Runko 2336v/27isl, Pipe 2568v/37isl (barrels), Runko 62v,
  Trigger 40v, Grip 700v. No magazine.
- **MS_BW_MG42**: the Brutal Wolfenstein VR pack's `mg42.md3`, 98 frames, rest 12, one surface
  8822v/223isl, belt change 18-96. Measured already in RIFLE_CANDIDATES.md (WW2 table). The owner
  said no WW2 guns for now.
- **MS_MG_Chaingun** (history, MeatGrinder): `models/meatgrinder/ChainGun/Chaingun.md3` @3b744a7,
  6 frames, ~20 primitive surfaces of 1 island each — the easiest to split.
- **MS_BD_Minigun** (history): `models/bd21/Minigun/minigun.md3` @6f23e1b. Not measured.
- **MS_BD_Machinegun** (current, M249 belt-fed): `Machinegun/Machinegun.md3`, 36 frames, rest 10;
  surfaces alt-trig-reload 104v, alt-frame, alt-trig, alt-pipe, Trigger, M249_lowpoly 11996v;
  reload 18-35.
- **Built (2026-09-13): two chainguns.** The chaingun (Force Unleashed, main hand):
  `models/chainguns/Chaingun/chaingun_wm.md3`, gun + seated box + ammo belt merged (body,
  barrels, trigger, magazine, belt; error 0); the box slides 12.1 straight up to seat; the
  barrels turn 60 deg about +x. The machine gun (the belt-fed mesh above, off hand):
  `models/chainguns/MachineGun/machinegun_wm.md3`; its reload frames are the underbarrel
  launcher's, and its ammo box (receiver islands 20, 22, 33) never moves, so the box's axis
  is from its shape. MS_Chaingun and MeatGrinder's have no box. `_pending/CHAINGUN_CARDS.md`.

### 2. Plasma rifle
- **MS_PlasmaRifle** (current, best): `PlasmaRifle/PlasmaRifle.md3`, 30 frames, rest 4, Scale
  -1 1 1. Surfaces Frame 4v, **Battery 34v (a separate cell)**, Trigger 88v, Frame 7467v. Reload
  18-29.
- MS_BD_Plasma (history) is the same mesh, not a second model.
- **MS_BD_Unmaker** (current, a second energy weapon): `Unmaker/Unmaker.md3`, 16 frames, rest 4,
  three surfaces 10931v / 361v / 249v, reload 5-13.
- **Built (2026-09-13): two plasma guns.** The plasma rifle (ModelSwapper, main hand):
  `models/plasma/PlasmaRifle/plasmarifle_wm.md3` (body, cell, trigger; error 0); its battery
  slides out along (0.194, 0, -0.981). The plasma carbine (Force Unleashed's plasma rifle,
  off hand): `models/plasma/PlasmaCarbine/plasmacarbine_wm.md3`, gun and cell merged; the cell
  rocks out, 10.39 of slide with 20.19 deg of twist. The Unmaker was not needed. Cards and
  numbers: `_pending/PLASMA_CARDS.md`.

### 3. Rocket launcher
- **MS_RocketLauncher** (current, best): `RocketLauncher/RPG.md3`, 39 frames, rest 5, reload
  11-38. 13 surfaces: three Frames (3762v, 300v, 48v), Trigger 46v, Cube 151v, Cube 2549v, and
  seven ~230v Cubes (likely rounds).
- **MS_MG_RPG** (history, MeatGrinder): `models/meatgrinder/RPG/RPG.md3` @3b744a7, 7 frames, many
  primitive surfaces.
- Grenade launchers (current): **MS_RC_M32** `RC_M32/m32.md3` (37 frames, rest 0, revolving
  cylinder, `magazine` 484v/1isl, reload 7-36) and **MS_BD_M79** `GrenadeLauncher/M79.md3`
  (33 frames, rest 3, `Shell` 828v, break-open reload 7-15).
- **Built (2026-09-13): two rocket launchers.** The rocket launcher (Force Unleashed, main
  hand): `models/launchers/RocketLauncher/rocketlauncher_wm.md3`, launcher + three-rocket rack
  merged (body, trigger, rack, rocket1-3; error 0); the rack slides 15.72 out +y. The RPG
  (MS_RocketLauncher, off hand): `models/launchers/RPG/rpg_wm.md3`, rest frame 4 (frame 5 has
  the drum mid-index); a seven-chamber drum lifted off along (0, -0.944, 0.329). The first
  survey's default body seed was wrong (it took the drum as body). The M32's six-shot
  cylinder is the natural third launcher. `_pending/ROCKET_CARDS.md`.

### 4. BFG — one shape in several versions
- **MS_VR_BFG9000** (current): `BFG9000/BFG.md3`, 16 frames, rest 6; surfaces Untitled 7121v/49isl,
  Untitled 52v; fire 12-15, select 4-6.
- **MS_BD_BFG_10k** (history): `models/bd21/BFG/BFG_10k.md3` @3b744a7, 21 frames — the same
  surface layout as the 9000 with a different skin and frames. Commit 198c0b1 gave both reload
  frames.
- **MS_MG_BFG** (history): `models/meatgrinder/BFG/BFG.md3` @2f749f8, 11 frames, same geometry.
- The distinct second BFG is Force Unleashed's `bfg9000.md3` above.
- **Built (2026-09-13): two BFGs.** The BFG (Force Unleashed, main hand):
  `models/bfg/BFG/bfg_wm.md3`, gun + pod merged (body, cover, meter, trigger, cell; error 0,
  normals copied raw); the cover hinges +69.05 deg, the cell slides back 9.47 then lifts 8.70
  (the lift's direction is a choice -- the donor rolls it out). The heavy BFG (MS_VR_BFG9000,
  off hand): `models/bfg/BFGHeavy/bfgheavy_wm.md3`; no cell moves in it or any history version
  (only the trigger), so its cell is a hidden ESTIMATE. `_pending/BFG_CARDS.md`.

### 5. Railgun
- **MS_BD_RailGun** (current, best): `RailGun/RailGun.md3`, 37 frames, rest 3. Surfaces Scope 2672v,
  ScopeGlass 18v, Gun 4660v, Trigger 46v, **Mag-Bat 156v/3isl (magazine/battery)**. Reload 11-35.
- **MS_BD_SnipaRG** (history): `models/bd21/Snipa/SnipaRG.md3` @6f23e1b. Not measured; its sibling
  SnipaRPG was two flat planes, so check first.
- Selaco's railgun is a commercial asset — not usable.
- **Built (2026-09-13): the only railgun.** SnipaRG is two flat planes; the history RailGun and
  MS_GH_Railgun are this mesh moved. `models/railguns/Railgun/railgun_wm.md3` (body, scope,
  scopeglass, magazine, trigger; 7552/7552 verts, error 0), `wm_railgun_mag.md3`, `railgun.png`.
  The cell pack drops 29.99 straight down (frames 12-29, fit 0.013); trigger 22.85 deg (sign
  checked); frame 36 is the aim pose, not the reload. Card and numbers: `_pending/RAILGUN_CARDS.md`.

### 6. Flamethrower
- **MS_AE_Flamer** (current, best): `AE_Flamer/m260b.md3`, 20 frames, rest 0; surfaces m260b 3225v,
  **m260b_canister 174v/2isl**, m260b_trigger 37v; reload 5-14 (canister swap).
- **MS_BD_Flamethrower2** (current): `Flamethrower/Flamethrower2.md3`, 6 frames, rest 0; surfaces
  "15.l" 5966v, "13.l" 80v, Cylinder 109v (no shader); fire 0-4 only.
- **MS_BW_Flamethrower**: the WW2 Flammenwerfer (RIFLE_CANDIDATES.md) — WW2, not for now.
- **MS_BD_FlameCannon** (history): `models/bd21/FlameCannon/FlameCannon.md3` @3e9b5bb, 8 frames,
  one surface 5085v/12isl.
- **Built (2026-09-13): two flamethrowers, both reloading (both animate a canister).** The
  flamer (MS_AE_Flamer, main hand): `models/flamers/Flamer/flamer_wm.md3` (body, pilotflame,
  canister, trigger); the canister drops straight down, clear of its collar after 1.03. The
  flamethrower (Force Unleashed's incinerator, off hand): `models/flamers/Flamethrower/
  flamethrower_wm.md3`, gun + gas can merged (body, trigger, lever, canister); the donor twists
  the can 70 deg and draws it back through the valve, the card pulls it straight down (clear at
  4.5). MS_BD_Flamethrower2 animates fire only. `_pending/FLAMER_CARDS.md`.

### 7. Chainsaw
- **MS_RC_Chainsaw** (current, best): `RC_Chainsaw/chainsaw.md3`, `chainsaw.jpg`, 45 frames, rest 0;
  separate `chainsaw_blade` 441v and `chainsaw_hand` 1159v. Ready 0-10, altfire 11-36 (possibly a
  start/rev), fire 37-44.
- **MS_Chainsaw** (current, VanAlek): `Chainsaw/chainsaw.md3`, 16 frames, rest 13, one surface
  Cube.020 1028v/28isl.
- **MS_BD_Chain_saw** (history): `models/bd21/Chain_saw/Chain_saw.md3` @198c0b1, 65 frames, with a
  reload; surfaces Cube.002_Cube 15188v/193isl, a collapsed duplicate, chainsaw 230v / 4233v / 456v.
- **MS_MG_Saw** (history): `models/meatgrinder/Saw/Saw.md3` @2f749f8, 6 frames, 6 surfaces.
- **MS_Jackhammer** (current): `Jackhammer/jackhammer.md3`, 20 frames; jackhammer 777v + a separate
  gas tank `cylinder` 217v.
- **Built (2026-09-13): two chainsaws.** The chainsaw (MS_Chainsaw, main hand):
  `models/chainsaws/Chainsaw/chainsaw_wm.md3` (body, chain, ripcord, cord; error 0). It HAS A
  RIPCORD, render-verified: a T-grip pulled 9.86 along (-0.433, 0, 0.901) turning 16.2 deg in
  the select clip. The heavy chainsaw (Force Unleashed, off hand):
  `models/chainsaws/ChainsawHeavy/chainsaw_heavy_wm.md3`, saw + both chain poses merged; no
  ripcord. MS_RC_Chainsaw is a disc saw, not a chainsaw. `_pending/CHAINSAW_CARDS.md`.

### Set origins by prefix (the ModelSwapper lane's)
MS_ and MS_VR_: the VanAlek VR set. MS_BD_: Brutal Doom v21 imports. MS_GH_: RS_Main's curated
subset. MS_MG_: MeatGrinder. MS_BW_: the Brutal Wolfenstein VR pack. MS_AE_, MS_RC_: not recorded.
Our guns never carry a donor's name (Rifle, SMG, and so on).
