# Rocket launchers — RocketLauncher (main) and RPG (off)

Measured 2026-09-13, read-only from the two donors (nothing edited there). Every surface was split
into islands. Each island was rigid-fit against the body with the body's own motion divided out.
Every part was rendered with `RS_ModelSwapper/tools_md3_render.py` and the PNGs were looked at.
All points are MD3 model space of the `_wm` mesh (x toward the muzzle, y across, z up), in model
units. Grab radii are map units. **ESTIMATE** marks every number that was not measured.

Scratch (scripts, logs, renders):
`C:\Users\Command\AppData\Local\Temp\claude\E--DOOMWork-RS-VR-Weapons\1c739cbc-eb97-4b35-a0d1-aa9c4e697297\scratchpad\rocket\`
— the renders cited below are relative to it.

**Grammar.** Every `firesfrom`, `casing`, `hands` line and every class line below is
**GRAMMAR PENDING (approved, not yet in code)**. There are no verbs: the swap is synthesised from
the `role = feed` part, and neither card has a `role = action` part or a cycle.

**Licence/credit.** Force Unleashed is Ermac's mod, cleared by the owner. RS_ModelSwapper's RPG is
unrecorded; flag it before anything ships.

---

## 1. RocketLauncher — Force Unleashed — MAIN HAND

### Source

| | |
|---|---|
| Meshes | `E:\DOOMWork\_old\doom-force-unleashed_devbuild\models\rocketlauncher\rocketlauncher.md3` (1 frame: `rocketlauncher` 2607v in 22 islands, `rl_trigger` 46v) + `rockets.md3` (5 frames: `rl_rocket`, `rl_rocket2`, `rl_rocket3` 234v each, `rl_rocket.rail` 48v) |
| MODELDEF | `modeldefs/weapons/rocketlauncher.txt`, block `Model RLRocketLauncher` (variants RLWH / RLWP / RL2H / RL2P / RLNH / RLNP) |
| Scale / Offset | `Scale -1.0 1.0 1.0`, `Offset 0.0 -24.0 -10.0` — Model 0 and Model 1 in ONE block, one shared space |
| Rest | Model 0 frame 0 + **rockets.md3 frame 0** (`RLWH A`: Ready, three rockets, rocket 1 in the bore) |
| Skin | `rocketlauncher.png` (what the non-PBR blocks draw; the surfaces' own shader names) |

**Which rack file and frame each state draws** (`zscript/weapons/rocketlauncher.txt`):

| State | Model 1 | What it shows |
|---|---|---|
| Ready `A` (3 loaded) | rockets.md3 f0 | rocket 1 in the bore, 2 and 3 out the +y side |
| Fire → slide `M N O` → Ready2 `B` | rockets2.md3 f0, f1, f2 → f2 | the rack steps -y until rocket 2 is in the bore |
| Fire2 → slide `P Q R` → Ready3 `C` | rockets3.md3 f0, f1, f2 → f2 | the rack steps -y until rocket 3 is in the bore |
| Fire3 → `G` (no rocket) | frame 99 (RLNH: 9) | past the file's frames: no rack drawn |
| Reload `I J K L` | rockets.md3 f1, f2, f3, f4 | the full rack slides in from +y |

- The donor's own magazine is 3 (`RocketPack` maxamount 3).
- The PBR two-hand block (RL2P) draws `B`/`C` at frame 0, not 2. It is the only variant that does,
  so it looks like a donor slip.

### Measurements

| Part | Surface / islands | Motion (relative to the launcher) | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | `rocketlauncher`, 22 islands | 1-frame mesh: nothing can move | — | — | `wm_renders/rocketlauncher_wm_body.png` |
| trigger | `rl_trigger`, 1 island | **never animated.** Top z 6.62 at x 14.82; bottom z 2.83 at x 15.03 | — | — | `wm_renders/rocketlauncher_wm_trigger.png` |
| rack | `rl_rocket.rail`, 2 islands | **pure slide along +y**: 15.717 (f1), 13.336 (f2), 7.458 (f3), 0 (f4); ≤ 0.01° of turn | rockets.md3 1-4 | 0.008-0.012 | `wm_renders/rocketlauncher_wm_rack.png`, `fu_rockets_f0_f1.png`, `fu_rockets_f0_f1_rack.png` |
| rocket1 / 2 / 3 | `rl_rocket` / `rl_rocket2` / `rl_rocket3`, 2 islands each (body + fins) | ride the rack: the same translation to 0.01 on every frame. Centres at rest y -0.08 / 8.77 / 17.81, z 17.69; 21.84 long, noses +x | rockets.md3 1-4 | 0.006-0.010 | `wm_renders/rocketlauncher_wm_rocket1.png` (…2, …3) |
| index per shot | rockets2.md3, rockets3.md3 | the rack steps **-y 8.87** (rocket 2: y 8.77 → -0.10) then **-y 9.04** (rocket 3). Each file's frames 0-2 are the tail of that step (-2.38 / -4.88 and -3.66 / -5.30) | slide M-O, P-R | ≤ 0.012 | `fu_rockets2_f0_f2.png`, `fu_rockets3_f0_f2.png` |
| muzzle | body island 0, front-most ring x 94.55 | inner radii 5.82-6.02 about (y 0.03, z 17.10) | — | — | — |
| which end fires | `rl_mf.md3` (the donor's flash) sits at x 73-98; the rockets' cones point +x | +x is the muzzle | — | — | `fu_rockets_f0_f1_rack.png` |
| rack clearance | triangle samples of the launcher inside the rack's x/z band | the tube is windowed across the rack. The only geometry in its path is two posts (islands 20, 21, y ≤ 0.95), cleared at 5.19. The trailing edge (y -4.23) passes the tube's outer wall (island 1, y 10.39) at **14.62 = 0.93 of 15.72**; at frame 1 it is at 11.49 | — | — | `fu_tube_rack_f0_f1.png` |
| rack grab | `hand2.md3` frames 87-90 (RL2H `I`-`L`: FU's own off hand loading the rack) | the hand rides the rack's +y end, 1.31-1.47 inside the rail's end on every frame. At frame 90 (rack seated) its centroid is **(14.84, 18.90, 16.46)** | 87-90 | — | — |
| support | `hand2.md3` frame 80 (RL2H `A`: FU's own two-handed idle) | hand centroid (28.55, -1.36, 5.54), x 18.58..39.02, z -0.30..12.05 — under the tube ahead of the trigger. The tube's underside is z 6.75 (island 1 min) | 80 | — | — |
| main hand (for reference) | `hand.md3` frame 95 | centroid (3.44, -0.65, -0.67), on the pistol grip (island 3) | 95 | — | — |

Launcher sub-units: the scale is Scale 1.0 x 0.34 = **0.34 map units per model unit**. A rocket
is 21.84 x 0.34 = 7.4 map units long.

### Built

- **`models/launchers/RocketLauncher/rocketlauncher_wm.md3`** — `rocketlauncher.md3` f0 and
  `rockets.md3` f0 merged into one frame (`scratchpad\rocket\fu_build.py`).
  - Surfaces `body`, `trigger`, `rack`, `rocket1`, `rocket2`, `rocket3`.
  - 3403/3403 verts and 3749/3749 tris. Worst vertex error 0.00000; UVs and triangles identical.
  - Each surface rendered alone over the gun (`wm_renders/rocketlauncher_wm_*.png`).
- **`rocketlauncher.png`** — copied.
- **`wm_rocketlauncher_mag.md3`** — the rack and its three rockets (750v).
  - Re-origined on their centroid (9.213, 8.771, 17.508).
  - Stood upright: the out axis +y turned to straight down, so the handle end is down and rocket 1
    up.
  - 21.86 x 8.28 x 26.17 (`wm_renders/wm_rocketlauncher_mag_rocketlauncher.png`).
- **`wm_rocket.md3`** — `rocket1` alone, 234v.
  - Re-origined on (8.880, -0.082, 17.691).
  - Left lying along x, nose +x, as `bullet.md3` and `shell.md3` lie. 21.84 x 8.28 x 8.28.

### Classes and hand

- `WM_RocketLauncher`, prop `WM_PropRocketLauncher`, **main hand**, slot 5 (the lead's call).
- Class lines (the lead writes them) — GRAMMAR PENDING (approved, not yet in code):
  ```
  Weapon.AmmoType1 "RocketAmmo"
  WM_Gun.ShotClass "Rocket"
  WM_Gun.FireTics 20
  ```
  Vanilla: `A_FireMissile` spawns `Rocket`, one RocketAmmo a shot; MISG `B 8` + `B 12` + `B 0` =
  20 tics. No damage or rate set.

### MODELDEF

```
// THE ROCKET LAUNCHER -- MAIN HAND. Force Unleashed's RLRocketLauncher block, Scale and Offset
// verbatim. rocketlauncher_wm.md3 is rocketlauncher.md3 with rockets.md3 frame 0 (the idle
// three-rocket rack, RLWH A) written as one frame in their one shared space, so the Offset
// carries over and the frame is 0 (_pending/ROCKET_CARDS.md).
Model WM_PropRocketLauncher
{
	Path "models/launchers/RocketLauncher"
	Model 0 "rocketlauncher_wm.md3"
	Skin 0 "rocketlauncher.png"
	Scale -1.0 1.0 1.0
	Offset 0.0 -24.0 -10.0
	PlacementCVars wm_rocketlauncher
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

FU's Offset is its HUD placement, not an origin compensation as ModelSwapper's are. If the prop sits
far off the controller, zero it and let the sliders place it — ESTIMATE.

### Cvars — stem `wm_rocketlauncher` (all ESTIMATE)

```
// ---- ROCKET LAUNCHER, MAIN HAND (renderer) ----------------------------------
user float wm_rocketlauncher_ofs_x   = 0.0;
user float wm_rocketlauncher_ofs_y   = 0.0;
user float wm_rocketlauncher_ofs_z   = 0.0;
user float wm_rocketlauncher_yaw     = -90.0;
user float wm_rocketlauncher_pitch   = 0.0;
user float wm_rocketlauncher_roll    = 0.0;
user float wm_rocketlauncher_scale   = 1.0;
user float wm_rocketlauncher_scale_x = 1.0;
user float wm_rocketlauncher_scale_y = 1.0;
user float wm_rocketlauncher_scale_z = 1.0;
```

### Draft card

```
# ============================================================ ROCKET LAUNCHER -- MAIN HAND
# Force Unleashed's rocket launcher as rocketlauncher_wm.md3: the launcher and its three-rocket
# rack (rockets.md3 frame 0, the idle state RLWH A) in one frame, surfaces body, trigger, rack,
# rocket1-3. Every number measured in that mesh's space; _pending/ROCKET_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_RocketLauncher"
  type      = launcher     # its hand-seat profile (the key landed in c688186)
  hand      = main
  prop      = "WM_PropRocketLauncher"
  model     = "models/launchers/RocketLauncher" "rocketlauncher_wm.md3"
  skin      = "models/launchers/RocketLauncher" "rocketlauncher.png"

  # The owner's six-rocket magazine. The rack draws three: see `part rack`.
  capacity  = 6
  # Its own family: a rack seats only here, never the RPG's drum.
  magfamily = "rocketrack"

  # GRAMMAR PENDING (approved, not yet in code): no chamber -- the trigger fires straight
  # from the magazine. No role = action part, no cycle.
  firesfrom = magazine
  # GRAMMAR PENDING (approved, not yet in code): nothing is thrown out, so no ejectport.
  casing    = none
  # GRAMMAR PENDING (approved, not yet in code): two-handed; `part support` below.
  hands     = 2

  # The tube's front ring (x 94.55): inner radii 5.82-6.02 about y 0.03, z 17.10. The donor's
  # own flash (rl_mf.md3) sits at x 73-98, and the rockets' noses point +x.
  muzzle    = 94.55, 0.03, 17.10
  barrel    = 1, 0, 0

  # THE LOOSE RACK: rack + rocket1-3 lifted out, re-origined on their centroid and stood so
  # the out axis (+y) points down -- the handle end down, rocket 1 up. magcenter is that
  # centroid in the gun's space. magscale 0.34 = MODELDEF 1.0 x 0.34.
  magmodel  = "models/launchers/RocketLauncher" "wm_rocketlauncher_mag.md3"
  magskin   = "models/launchers/RocketLauncher" "rocketlauncher.png"
  magscale  = 0.34
  magcenter = 9.213, 8.771, 17.508

  # ONE ROCKET, this rack's own rocket1, lying along x as the package's rounds do.
  # 0.34 keeps it the size it is in the rack: 21.84 units = 7.4 map units.
  roundmodel = "models/launchers/RocketLauncher" "wm_rocket.md3"
  roundskin  = "models/launchers/RocketLauncher" "rocketlauncher.png"
  roundscale = 0.34

  # This package's launcher sounds (SNDINFO wm/rocket/*) and the big-magazine drop.
  firesound    = "wm/rocket/fire"
  drysound     = "wm/dry"
  magoutsound  = "wm/rocket/magout"
  maginsound   = "wm/rocket/magin"
  magdropsound = "wm/magdrop/large"
end

# THE RACK: the rail and its three rockets, one part. rockets.md3 frames 1-4 slide it along
# +y -- 15.717, 13.336, 7.458, 0 -- a pure slide (<= 0.01 degrees, fit 0.008-0.012), the
# rockets riding it to 0.01. Distance is the donor's own out frame 1, where the trailing edge
# (y -4.23 at rest) stands at 11.49, outside the tube's wall (y 10.39). detach 0.93: the edge
# passes that wall at 14.62. The only geometry in its path is two posts it rides on (y 0.95).
# THE RACK STEPS ITS ROCKETS INTO THE BORE (index, below), and they show the count (a roundsurface
# on the counted mag is drawn while it holds MORE than its number). Six rounds on three rockets:
# the rack reads full and still from 6 down to 3; at 2 rocket1 is gone and the rack has stepped
# rocket2 into the bore, at 1 rocket3, and at 0 it is empty, still stepped twice.
part rack
  role    = feed
  subject = magazine
  take    = no          # out by its button, in by the hand carrying one
  surface = rack
  roundsurface = rocket1, mag, 2
  roundsurface = rocket2, mag, 1
  roundsurface = rocket3, mag, 0
  # WHERE YOU PULL IT: FU's own off hand loading the rack (hand2.md3 frames 87-90) rides its
  # +y end; this is that hand's centroid with the rack seated (frame 90). Radius ESTIMATE.
  grab       = 14.84, 18.90, 16.46
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, 1, 0
    distance = 15.72
    detach   = 0.93
  end
  # THE PER-SHOT STEP: the donor's rockets.md3 steps the rack -y 8.87, then 9.04 (rockets at
  # y -0.08 / 8.77 / 17.81); one distance, their mean. Steps = clamp(3 - rounds, 0, 2).
  index
    kind     = slide
    axis     = 0, -1, 0
    distance = 8.955
    from     = 3
    steps    = 2
  end
end

# THE TRIGGER. ESTIMATE: the donor never animates it (1-frame mesh). Pinned at its top
# (x 14.82, z 6.62); +15 about +y carries its bottom (x 15.03, z 2.83) 0.99 back along -x,
# the way every trigger here is pulled. Degrees ESTIMATE.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 15.0
    pivot   = 14.82, 0, 6.62
  end
end

# THE OTHER HAND, under the tube ahead of the trigger. x is FU's own two-handed idle
# (hand2.md3 frame 80, centroid x 28.55); z is the tube's underside (6.75). Radius ESTIMATE.
part support
  role    = support
  subject = support
  grab       = 28.55, 0.0, 6.75
  grabradius = 3.0
end
```

---

## 2. RPG — RS_ModelSwapper MS_RocketLauncher — OFF HAND

### Source

| | |
|---|---|
| Mesh | `E:\DOOMWork\RS_ModelSwapper\models\hud\RocketLauncher\RPG.md3` + `RPG.png`, 39 frames, 13 surfaces (Frame x3, Trigger, Cube x9) |
| MODELDEF | `RS_ModelSwapper\modeldef`, block `MS_RocketLauncher` |
| Scale / Offset | `Scale -1.0 1.0 1.0`, `Offset 3.250 -14.172 8.828` (tools_reorigin_all's origin compensation) |
| Clip rows | `RS_ForeignAnim.zs`: `ready 5@1`; `fire 10@6,10@4,5@1`; `reload 11-38@1` |
| **Rest used** | **frame 4, not 5** — see below |

**Why frame 4.**
- Surfaces 0-4 (body pieces and trigger) are vertex-identical at frames 4 and 5 (max difference
  0.0000).
- Frame 5 catches the drum mid-index: turned -10.87° about +x, and no rocket is in the bore.
- Frames 5, 6, 7 turn the drum -10.87 / -34.13 / -45.00°; frame 8 is vertex-identical to frame 4.
  That turn is the drum indexing one chamber (360/7 = 51.43°).
- At frame 4, rocket s10's centroid (3.278, 3.201, -1.132) sits on the tube's axis (y 3.25, z -1.33):
  ring angle -22.13° against the bore's -23.24°.
- So frame 4 is frame 5 with the drum home.

### Measurements (body = surface 0's largest island)

| Part | Surface / islands | Motion (relative to the body) | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | Frame s0 (3762v, 13 islands: tube, grip, sight, rails); Frame s1 (300v, rear axle plate); Cube s2 (151v: cradle under the drum + front axle plate); Frame s3 (48v, strap) | fixed on every frame. s0 island 4, a sight knob, wanders 0.12 at f12 and f15 | all | — | `wm_renders/rpg_wm_body.png` |
| trigger | Trigger s4 (46v) | **slide 1.397 along (-1.000, 0, -0.011)**, 0.05° of turn | f8 (moves 8-14) | 0.007 | `wm_renders/rpg_wm_trigger.png`, `rpg_trigger_hl.png` |
| drum | Cube s5 (2549v, 1 island) | index turn about **(1, 0, 0) through (y -4.562, z 2.026)**: -10.87 / -34.13 / -45.00° at f5 / 6 / 7 (singular fit, \|t\| from rotation only). **Swap:** out over f17-24 (f24 50.37 away), in over f25-33 | 5-7, 17-33 | 0.010-0.012 | `wm_renders/rpg_wm_drum.png`, `rpg_f4_f24.png`, `ww2_split\RPG_body0\part1.png` |
| rocket1-7 | Cube s10, s11, s12, s6, s7, s8, s9 (228-234v, 1 island each) | rigid with the drum on every frame (the same motion to 0.01). Seven on an 8.4-9.1 ring. Named in **firing order**: the turn is negative about +x, so after s10 come s11, s12, s6, s7, s8, s9. 14.27 long, 5.0 across, noses +x (s10 tapers to r 0.13 at x 10.3-11.8) | all | ≤ 0.015 | `wm_renders/rpg_wm_rocket1.png` … `rocket7.png`, `rpg_rocket10.png` |
| insert axis | drum centroid in body space, frames 29-33 against home | principal direction **(0, -0.944, 0.329)**. The radial line from the bore to the drum axis is (0, -0.919, 0.395), so it slides straight off the bore. The path arcs further out: f26 is (0, -0.999, 0.033) | 29-33 | — | `rpg_drum_out30.png` |
| drum clearance | the drum's footprint (outer radius 12.683 about its axis) against body triangle samples inside its x span (-5.45..12.72), stepped along the insert axis | clear of every body sample at **D = 10.75** | — | — | — |
| tube at the drum | body island 0 within 6 of the bore axis | no geometry from x -16.8 to 11.3: the aligned chamber IS the bore there | — | — | — |
| muzzle | body island 0, front-most ring x 65.875 | centre (y 3.250, z -1.328). The front tube is r 5.11, the rear r 3.17-3.42; the rockets' noses point +x | — | — | `rpg_f5.png` |
| grip | body island 2 (400v) | a raked pistol grip (z -26..-12, x 6.3..24.3) under a rail (x -15.5..29) | — | — | `rpg_s0i2_zoom.png` |
| support | — | **no forward grip on the mesh.** The front tube's underside is z -6.28 from x 45 to 55 (-5.28 at a ring, x 40-45) | — | — | — |

**The first survey was wrong.** Its default seed took the drum and its seven rockets (4175v) as the
body and reported the launcher moving 44 units. Re-seeded on surface 0, the drum and rockets (4175v
in 8 pieces) are the one moving part and the trigger is the other.

**Nothing else moves in the reload** — no breech, no cover, no lever.

### Built

- **`models/launchers/RPG/rpg_wm.md3`** — `wm_split.py scratchpad\rocket\spec_rpg.json`, rest
  frame 4.
  - Surfaces `body` (s0-s3), `trigger`, `drum`, `rocket1`…`rocket7`. Duplicate names are gone.
  - 8482/8482 verts and 7550/7550 tris. Worst vertex error 0.00000.
  - Each surface rendered alone over the gun.
- **`rpg.png`** — `RPG.png`, copied.
- **`wm_rpg_mag.md3`** — the drum with all seven rockets (4175v).
  - Re-origined on (3.520, -4.660, 2.325).
  - Stood with the out axis (0, -0.944, 0.329) straight down; the drum's own axis stays along x.
  - 18.17 x 24.59 x 24.50 (`wm_renders/wm_rpg_mag_rpg.png`).
- **`wm_rocket.md3`** — `rocket1` alone.
  - Re-origined on (3.278, 3.201, -1.132).
  - Lying along x, nose +x. 14.27 x 5.00 x 4.95.

### Classes and hand

- `WM_RPG`, prop `WM_PropRPG`, **off hand**, slot 5 (the lead's call).
- Class lines: as the RocketLauncher's — `Weapon.AmmoType1 "RocketAmmo"`,
  `WM_Gun.ShotClass "Rocket"`, `WM_Gun.FireTics 20` — GRAMMAR PENDING (approved, not yet in code).

### MODELDEF

```
// THE RPG -- OFF HAND. RS_ModelSwapper modeldef MS_RocketLauncher, Scale and Offset verbatim.
// Mirrored (Scale x negative). rpg_wm.md3 is RPG.md3's frame 4 -- frame 5, the donor's ready
// frame, with the drum home instead of mid-index -- split into named surfaces in the same units
// and origin, so the Offset carries over and the frame is 0 (_pending/ROCKET_CARDS.md).
Model WM_PropRPG
{
	Path "models/launchers/RPG"
	Model 0 "rpg_wm.md3"
	Skin 0 "rpg.png"
	Scale -1.0 1.0 1.0
	Offset 3.250 -14.172 8.828
	PlacementCVars wm_rpg
	NOAUTOREVERSE
	FollowOffHand
	FrameIndex WMPR A 0 0
}
```

### Cvars — stem `wm_rpg` (all ESTIMATE)

```
// ---- RPG, OFF HAND (renderer) ------------------------------------------------
user float wm_rpg_ofs_x   = 0.0;
user float wm_rpg_ofs_y   = 0.0;
user float wm_rpg_ofs_z   = 0.0;
user float wm_rpg_yaw     = -90.0;
user float wm_rpg_pitch   = 0.0;
user float wm_rpg_roll    = 0.0;
user float wm_rpg_scale   = 1.0;
user float wm_rpg_scale_x = 1.0;
user float wm_rpg_scale_y = 1.0;
user float wm_rpg_scale_z = 1.0;
```

### Draft card

```
# ======================================================================= RPG -- OFF HAND
# RS_ModelSwapper's rocket launcher (MS_RocketLauncher) as rpg_wm.md3: a SEVEN-CHAMBER DRUM on
# the tube, swapped whole. Rest frame 4 (frame 5 with the drum home, not mid-index). Surfaces
# body, trigger, drum, rocket1-7 (rocket1 in the bore, the rest in firing order). Every number
# measured in that mesh's space against the body; _pending/ROCKET_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_RPG"
  type      = launcher     # its hand-seat profile (the key landed in c688186)
  hand      = off
  prop      = "WM_PropRPG"
  model     = "models/launchers/RPG" "rpg_wm.md3"
  skin      = "models/launchers/RPG" "rpg.png"

  # The owner's six-rocket magazine. The drum has seven chambers: see `part drum`.
  capacity  = 6
  # Its own family: a drum seats only here, never the RocketLauncher's rack.
  magfamily = "rocketdrum"

  # GRAMMAR PENDING (approved, not yet in code): fires straight from the magazine.
  firesfrom = magazine
  # GRAMMAR PENDING (approved, not yet in code): nothing is thrown out, so no ejectport.
  casing    = none
  # GRAMMAR PENDING (approved, not yet in code): two-handed; `part support` below.
  hands     = 2

  # The tube's front ring (x 65.875), centred on the bore (y 3.25, z -1.33). The rockets'
  # noses point +x.
  muzzle    = 65.88, 3.25, -1.33
  barrel    = 1, 0, 0

  # THE LOOSE DRUM: drum + rocket1-7 lifted out, re-origined on their centroid and stood so
  # the out axis points down. magcenter is that centroid in the gun's space.
  magmodel  = "models/launchers/RPG" "wm_rpg_mag.md3"
  magskin   = "models/launchers/RPG" "rpg.png"
  magscale  = 0.34
  magcenter = 3.520, -4.660, 2.325

  # ONE ROCKET, this drum's own rocket1, lying along x. 14.27 units = 4.9 map units.
  roundmodel = "models/launchers/RPG" "wm_rocket.md3"
  roundskin  = "models/launchers/RPG" "rpg.png"
  roundscale = 0.34

  firesound    = "wm/rocket/fire"
  drysound     = "wm/dry"
  magoutsound  = "wm/rocket/magout"
  maginsound   = "wm/rocket/magin"
  magdropsound = "wm/magdrop/large"
end

# THE DRUM and its seven rockets, one part (rigid together on all 39 frames, fit <= 0.015).
# Axis: the drum's centroid over insert frames 29-33, relative to home -- (0, -0.944, 0.329),
# straight off the bore (the bore-to-drum-axis line is (0, -0.919, 0.395)). Distance: where the
# drum's footprint (outer radius 12.683) clears every body triangle in its x span, 10.75. detach
# 0.95 ESTIMATE.
# THE DRUM TURNS ON THE SHOT (index, below) and its rockets show the count (a roundsurface on the
# counted mag is drawn while it holds MORE than its number). They go in firing order: at 5 rocket1
# is gone and the drum has turned rocket2 into the bore, and so on to rocket6 at 1; at 0 the bore
# faces the seventh chamber, which is never loaded (part emptychamber, below).
part drum
  role    = feed
  subject = magazine
  take    = no          # out by its button, in by the hand carrying one
  surface = drum
  roundsurface = rocket1, mag, 5
  roundsurface = rocket2, mag, 4
  roundsurface = rocket3, mag, 3
  roundsurface = rocket4, mag, 2
  roundsurface = rocket5, mag, 1
  roundsurface = rocket6, mag, 0
  # The drum's outer rim on its out axis: the axis (y -4.562, z 2.026) plus 12.683 along
  # (0, -0.944, 0.329), at the drum's middle x. Radius ESTIMATE.
  grab       = 3.64, -16.54, 6.20
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, -0.944, 0.329
    distance = 10.75
    detach   = 0.95
  end
  # THE PER-SHOT TURN, measured from the donor's frames 4-7: -51.43 degrees (a seventh of a turn)
  # about +x through the drum's axis. Steps = clamp(6 - rounds, 0, 6), the defaults.
  index
    kind    = hinge
    axis    = 1, 0, 0
    pivot   = 3.636, -4.562, 2.026
    degrees = -51.43
  end
end

# THE SEVENTH CHAMBER STAYS EMPTY: capacity 6 in a seven-chamber drum. Hidden, not counted -- a
# count of 6 would never show. The loose drum (wm_rpg_mag.md3) carries no rocket7 either.
part emptychamber
  role    = hidden
  surface = rocket7
end

# A sliding trigger: 1.397 along (-1.000, 0, -0.011) at frame 8, 0.05 degrees, fit 0.007.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind     = slide
    axis     = -1, 0, -0.011
    distance = 1.397
  end
end

# ESTIMATE: the mesh has no forward grip. Under the front tube, well ahead of the trigger
# guard (which ends at x 29) and short of the muzzle (65.9); the underside is z -6.28 there.
part support
  role    = support
  subject = support
  grab       = 47.5, 3.25, -6.28
  grabradius = 3.0
end
```

---

## How the visible rockets relate to a capacity of 6

- **RocketLauncher: three on the rack. LIVE (R1 landed as G12, RS_VR_Reload.pk3 15:05).**
  - `rocket1, mag, 0` / `rocket2, mag, 1` / `rocket3, mag, 2`: full from 3 to 6, then the
    outermost goes first and the bore rocket last.
  - **Now indexed (G13, 15:17):**
    - `index` slide (0, -1, 0), distance 8.955 (the donor's 8.87 and 9.04, averaged), from 3,
      steps 2;
    - rocket1 `mag, 2`, rocket2 `mag, 1`, rocket3 `mag, 0`;
    - the rack reads full and still down to 3, then steps a rocket into the bore at 2 and 1.
- **RPG: seven chambers in the drum. LIVE.**
  - `rocket1..6` are `mag, 0..5` (the bore rocket last).
  - `rocket7` is `part emptychamber`, `role = hidden`. A count of 6 would never show.
  - The loose drum `wm_rpg_mag.md3` had its `rocket7` surface dropped byte for byte
    (`SP\chaingun\belt_split.py`): every other byte is unchanged, so its origin and the card's
    magcenter still hold.
  - **Now indexed (G13, 15:17):**
    - `index` hinge (1, 0, 0) through (3.636, -4.562, 2.026), -51.43 per step;
    - rockets in firing order: rocket1 `mag, 5` ... rocket6 `mag, 0`.
- `wm_rocket.md3` exists for each gun and is on the card as `roundmodel`. Neither card has a load
  verb, so no rocket goes in singly.

## Grammar gaps

1. **G1 — firing from the magazine, no chamber.** `firesfrom = magazine`, `casing = none`,
   `hands = 2` and the class lines. GRAMMAR PENDING (approved, not yet in code).
2. **R1 — round surfaces on a counted store. SETTLED as G12 (uzdxrema-11, 15:05):** on a counted
   store the third field is a count, drawn while the store holds more than *n*; n >= capacity is
   refused. Both cards use it.
3. **R2 — a magazine that indexes on the shot. SETTLED as G13 (uzdxrema-11, RS_VR_Reload.pk3
   15:17):** an `index` block in the feed part (kind, axis, pivot, degrees / distance a step, from,
   steps), steps = clamp(from - rounds, 0, steps). Both cards use it. The original ask:
   - RPG: the drum turns -51.43° about +x through (y -4.562, z 2.026) per shot — measured from
     frames 4-7.
   - RocketLauncher: the rack steps -y about 8.9 per shot.
   - Today a feed part has one dof, its detach slide. A per-shot index on the part (a hinge or a
     slide step, driven by the count) would draw the rocket to be fired in the bore. Cosmetic;
     both guns work without it.
4. **The RPG's swap path is an arc.** The donor lifts the drum out along (0, -0.999, 0.033) at 15
   units and seats it along (0, -0.924, 0.382) at the end. One straight slide (0, -0.944, 0.329)
   over 10.75 is close; a curved seat is not asked for.
5. **Backblast point (data only, no key).** The tubes' rear rings, for a later backblast effect:
   - RocketLauncher x -29.11, about (y 0.0, z 17.2)
   - RPG x -85.61, about (y 3.25, z -1.33)

## Unverified / ESTIMATE

- **RocketLauncher trigger.** 15° hinge about its top. The donor never animates it.
- **RPG support grab.** (47.5, 3.25, -6.28) — the mesh has no forward grip.
- **Detach fractions.**
  - RocketLauncher 0.93 is measured: the trailing edge passes the tube's outer wall.
  - RPG 0.95 is ESTIMATE. Its 10.75 distance is measured with a full-disk footprint, which is
    conservative.
- **Grab radii.** All 3.0. **Cvar defaults**: all of them.
- **RocketLauncher Offset.** FU's HUD placement, carried verbatim.
- **In game.** Neither mesh has been loaded yet. The engine's surface limit (`WM_Rig.SLOTS` 16) is
  above both cards' moving surfaces: 5 on the RocketLauncher, 9 on the RPG.

## Not taken

- **MeatGrinder RPG** (`models/meatgrinder/RPG/RPG.md3` @3b744a7). Both rocket candidates worked,
  so it was not extracted.
- **MS_RC_M32** (`RC_M32/m32.md3`, 37 frames, rest 0).
  - A revolving six-shot grenade cylinder: `magazine` is 484v in 1 island and turns 174° about x in
    its reload (7-36); the body is 4341v.
  - Its six chambers match "6", and it is the natural third launcher: a slotted, indexed cylinder,
    as the revolvers are.
- **MS_BD_M79** (`GrenadeLauncher/M79.md3`, 33 frames, rest 3, `Shell` 828v, break-open 7-15).
  Not measured. It would sit on the `breakaction` archetype.
