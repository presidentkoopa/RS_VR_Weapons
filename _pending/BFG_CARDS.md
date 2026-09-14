# BFG family — two guns, measured and drafted (2026-09-13)

Read-only sources; nothing edited in `_old`, RS_ModelSwapper or RS_VR_Reload. Every part below
was fitted rigidly against the body (the body's own motion divided out), and checked in renders
made with RS_ModelSwapper's `tools_md3_render.py`. Scripts, logs and renders are in the session
scratch folder `bfg\`: `fu_measure.txt`, `fu_render.txt`, `fu_build.txt`, `fu_build2.txt`,
`ms_build.txt`, `ms_split_*.txt`, plus `fu_renders\`, `wm_renders\` and `ms_islands\`.

**Licence/credit: unrecorded** for both donors. Flag this before anything ships.

**The lead's battery:** 160 cells, 4 vanilla shots at 40 each; 30 tics of charge, then the BFGBall.

| Gun | Class / prop | Hand | Donor | Why |
|---|---|---|---|---|
| **BFG** | `WM_BFG` / `WM_PropBFG` | main | Force Unleashed `bfg9000.md3` + `bfg9000_pod.md3` | A real removable pod under a hinged top cover, both animated |
| **BFGHeavy** | `WM_BFGHeavy` / `WM_PropBFGHeavy` | off | RS_ModelSwapper `models/hud/BFG9000/BFG.md3` | The only other BFG shape. **It has no cell**, so this card's cell is hidden and an ESTIMATE |

---

## 1. BFG — MAIN HAND

### Source
- **Meshes:** `E:\DOOMWork\_old\doom-force-unleashed_devbuild\models\bfg9000\`
  - `bfg9000.md3`: 6 frames. Surfaces `bfg`, `bfg_case`, `bfg_trigger`, `bfg_meter`.
  - `bfg9000_pod.md3`: 12 frames. One surface, `bfg._ammo`.
- **MODELDEF:** `modeldefs\weapons\bfg9000.txt`, block `RLBFG9000`, `Scale -1.0 1.0 1.0`, `Offset 0.0 -24.0 -10.0`.
  - Model 0 (gun) and Model 1 (pod) sit in one block, so they share one space.
  - **Rest:** gun frame 0 + pod frame 0 (idle `BFGG A 0 0 / A 1 0`, the pod seated).
- **Donor animation:**
  - Opening (D-I): gun 2,3,4,5,5,5 and pod 1-6, drawn with `bfg9000_off.png`, the spent-pod skin.
  - Pod gone (J): pod frame 99.
  - Inserting (K-O): gun 5, pod 7-11, drawn with the full skin.
- **Scale:** Scale 1.0 × 0.34 = **0.34 map units per model unit**. The gun is 100.2 long, so 34 map units.

### Measurements (model units, rest frame, the body is static on every frame: fit 0.0000)

| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | `bfg`, 6209v, 37 islands | static | — | 0.000 | `wm_renders\bfg_wm_body.png` |
| **cover** | `bfg_case`, 1414v, 7 islands. All 6 real islands turn together (69.04-69.06°); island 6 is a 3v sliver at the pin | **hinge +69.05° about (0, 1, 0) through (35.858, 0, 29.629)**; the rear end lifts, the pin is at the front | 2-5 (10.4°, 34.5°, 58.6°, 69.05°) | 0.0098; every vertex within 0.030 | `fu_renders\cover_0_vs_5.png`, `wm_renders\bfg_wm_cover.png` |
| meter | `bfg_meter`, 5v quad on top of the cover, own texture `bfg_meter1` | **rides the cover** (the cover's hinge carries its vertices to frame 5 within 0.016) | 2-5 | — | `wm_renders\bfg_wm_meter.png` |
| trigger | `bfg_trigger`, 53v, 1 island | **slide 2.047 along (-1, 0, 0)** | 1 | 0.000 | `fu_renders\trigger_only_0_vs_1.png` |
| **cell** | pod `bfg._ammo`, 208v, 3 islands (the case and two tubes on top) | stage 1: **slide 9.471 along (-1, 0, 0)**, pure translation (0.00°) | 1-4 (0.44, 1.95, 4.86, 9.47) | 0.009 | `fu_renders\pod_0_vs_4.png`, `wm_renders\bfg_wm_cell.png` |
| cell, lift | same | donor frames 5-6: out to −y with a roll. Neither a hinge nor a slide (next table). **Card: slide 8.703 along (0, 0, 1)** | 5-6 out, 7-11 back in from +y | — | `fu_renders\pod_4_vs_6.png` |

**The lift: hinge or slide?** Measured from pod frame 4, where the slide ends:

| Test | rms error |
|---|---|
| A pure hinge fitted to frames 4→6 (33.36° about (0.927, 0.361, 0.100)), checked at frame 6 | 14.817 |
| The same hinge at half angle, checked at frame 5 | 9.659 |
| Hinge plus 14.817 of travel along its own axis (a screw), at frame 6 | 0.017 |
| The same screw at half, checked at frame 5 | 4.659 (the path is not one screw either) |
| A straight slide along the 4→6 chord, at frame 6 | 4.161 |

- **So:** it is not a hinge. Pinned to one axis it cannot be driven.
- **The card lifts straight up**, for these reasons:
  - Nothing of the body is above the slid-back cell (0 vertices).
  - The only thing in its box is the cradle, body island 8, whose rim reaches z 28.62 over the footprint (3.46 above the cell's floor at 25.16).
  - The side walls stop at z 25.53.
  - The donor itself rises 7.3 by frame 5.
- **Distance:** 8.703 is the cell's own height, measured; it clears the cradle rim with 5.2 to spare. The *direction* is a choice, not the donor's.

**The cover really does trap the cell.** 408 cover vertices sit over the seated cell, the lowest at z 30.11, below the cell's top at 33.86.

**Other donor files:**
- `bfg9000_pod2.md3`: the same cell with the same UVs and triangles, only moved by (-20.71, 0, -24.84). No turn, fit 0.011, sitting on its floor (z 0.31..9.02), not centred. Not used.
- `bfg9000_meter.md3`: the same 5-vertex quad, 0.05 higher, a separate overlay the donor re-skins with `bfg_meter1..7` (a gauge needle, low to high) while charging. Not used.
- `bfg9000_mf.md3`: the muzzle flash, 5 frames. It starts at x 67.6, centroid y −0.2, z 19.7; that confirms the muzzle line.

### Card points (rest frame, model space)

| Key | Value | How |
|---|---|---|
| muzzle | 61.20, -0.01, 19.43 | The emitter's front face (body island 6, a 13 × 13 disc recessed 6.5 inside the housing mouth at x 67.75), centred |
| barrel | 1, 0, 0 | The housing and emitter are symmetric about y 0; the flash runs along +x |
| magcenter | 22.660, 0.075, 32.136 | The cell's rest centroid |
| cell grab | 23.58, 0.04, 33.78 | The cell's top face centroid (74v) |
| cover grab | -16.34, 0.02, 31.78 | The cover's rear edge, top centre; you lift the end away from the pin |
| support grab | 38.93, 0.01, -2.90 | The keel under the housing (body island 11, 26 long × 8 deep × 3.6 thick). **ESTIMATE** that it is the forward grip |
| grab radii | 3.0 map units | **ESTIMATE** |
| split | 0.521 | Distance-weighted: 9.471 / (9.471 + 8.703) |

### Files written (`models/bfg/BFG/`)
- **`bfg_wm.md3`**: one frame; gun frame 0 and pod frame 0 merged with no transform.
  - Surfaces, in order: `body` 0, `cover` 1, `meter` 2, `trigger` 3, `cell` 4.
  - 7889/7889 verts, 5710/5710 tris, worst vertex error 0.00000, UVs identical, **packed normals copied bit for bit** (0 changed; see "Tool bug" at the end).
  - Shaders: `bfg9000.png`; `meter` has `bfg_meter1.png`.
- **`wm_bfg_cell.md3`**: the loose cell.
  - Re-origined on its rest centroid and stood along the dof axis. (-1, 0, 0) is turned to point down, so the nose, the end deepest in the gun, points up, as `md3_write.extract` does for a magazine.
  - Size 8.703 × 21.312 × 35.219. Back in gun space it is within 0.0042. Its normals are turned with GZDoom's own math: worst 0.87°, which is 1-byte quantisation.
- `bfg9000.png`, `bfg_meter1.png`, copied verbatim.

### MODELDEF block
```
// THE BFG -- MAIN HAND. Force Unleashed's RLBFG9000 block, Scale and Offset verbatim: its
// gun (Model 0) and pod (Model 1) share one space, and bfg_wm.md3 is gun frame 0 and pod
// frame 0 merged, so the Offset carries over and the frame is 0. The meter quad (surface 2)
// has its own texture (_pending/BFG_CARDS.md).
Model WM_PropBFG
{
	Path "models/bfg/BFG"
	Model 0 "bfg_wm.md3"
	Skin 0 "bfg9000.png"
	SurfaceSkin 0 2 "bfg_meter1.png"
	Scale -1.0 1.0 1.0
	Offset 0.0 -24.0 -10.0
	PlacementCVars wm_bfg
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

### Cvar stem `wm_bfg` (every default an ESTIMATE)
```
// ---- BFG, MAIN HAND (renderer) -- ESTIMATE seat, tune in the headset -------
user float wm_bfg_ofs_x   = 0.0;
user float wm_bfg_ofs_y   = 0.0;
user float wm_bfg_ofs_z   = 0.0;
user float wm_bfg_yaw     = -90.0;
user float wm_bfg_pitch   = 0.0;
user float wm_bfg_roll    = 0.0;
user float wm_bfg_scale   = 1.0;
user float wm_bfg_scale_x = 1.0;
user float wm_bfg_scale_y = 1.0;
user float wm_bfg_scale_z = 1.0;
```

### Class lines (the lead writes them)
```
AmmoType1 "Cell"
WM_Gun.RoundsPerShot 40        // GRAMMAR PENDING (approved, not yet in code)
WM_Gun.ShotClass "BFGBall"     // GRAMMAR PENDING (approved, not yet in code)
WM_Gun.ChargeTics 30           // GRAMMAR PENDING (approved, not yet in code)
WM_Gun.ChargeSound ...         // GRAMMAR PENDING -- the lead picks the sound
```
Vanilla facts only; no damage, no rates.

### Draft card
```
# ============================================================== BFG -- MAIN HAND
# Force Unleashed's bfg9000.md3 + bfg9000_pod.md3 as bfg_wm.md3 (gun frame 0 and pod
# frame 0, one shared space). A top cover on a pin at its front lifts to uncover a cell
# battery lying in a cradle on top of the gun; the cell slides back, then lifts out.
# Every number measured at the rest frame against the static body. _pending/BFG_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_BFG"
  type      = bfg     # its hand-seat profile (the key landed in c688186)
  hand      = main
  prop      = "WM_PropBFG"
  model     = "models/bfg/BFG" "bfg_wm.md3"
  skin      = "models/bfg/BFG" "bfg9000.png"

  # The lead's battery: 160 cells, four vanilla shots of 40.
  capacity  = 160
  # One family for both BFGs: vanilla has one Cell ammo, so one battery fits either.
  magfamily = "bfgcell"

  # FIRED STRAIGHT FROM THE BATTERY: no chamber, no rack, no action part, no cycle.
  firesfrom = magazine     # GRAMMAR PENDING (approved, not yet in code)
  casing    = none         # GRAMMAR PENDING (approved, not yet in code)
  hands     = 2            # GRAMMAR PENDING (approved, not yet in code)

  # The emitter's front face (body island 6), centred; the flash mesh runs along +x from there.
  muzzle    = 61.20, -0.01, 19.43
  barrel    = 1, 0, 0

  # The loose battery: the cell surface lifted out, re-origined on its centroid and
  # stood along its dof axis (-x down, its nose up). magcenter is its rest centroid.
  magmodel  = "models/bfg/BFG" "wm_bfg_cell.md3"
  magskin   = "models/bfg/BFG" "bfg9000.png"
  magscale  = 0.34
  magcenter = 22.660, 0.075, 32.136
  # A SPENT CELL LOOKS SPENT: dropped or pulled out with 0 rounds it wears the donor's own
  # bfg9000_off.png.
  magskinempty = "models/bfg/BFG" "bfg9000_off.png"

  # SOUNDS: silent until the lead picks them (fire, open/close, mag out/in).
end

# THE TOP COVER, with the charge meter riding on it. +69.05 degrees about (0, 1, 0)
# through (35.858, 0, 29.629) at frame 5, fit 0.0098; every vertex within 0.030.
# Sign checked: +69.05 lands the rest centroid on frame 5's (miss 0.000); -69.05 misses
# by 37.51. The pin is at the front, so the rear edge lifts: grab it there.
# subject = foregrip, as every open-verb part on this package's cards (a lid has no word).
part cover
  subject = foregrip
  surface = cover
  surface = meter
  # THE METER shows the cell: its surface wears skin ceil(fill x 7) of the donor's
  # bfg_meter1..7 (1 with the cell out or empty), and keeps it while the cover moves.
  metersurface = meter
  meterskins   = "models/bfg/BFG" "bfg_meter%d.png"
  metersteps   = 7
  grab       = -16.34, 0.02, 31.78    # the rear edge, top centre
  grabradius = 3.0                    # ESTIMATE
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 69.05
    pivot   = 35.858, 0, 29.629
  end
end

# THE CELL. Stage 1 (dof), measured: 9.471 along -x at pod frame 4, a pure slide (0.00
# degrees, fit 0.009). Stage 2 (dof2): the donor rolls it out sideways (a screw -- 33.36
# degrees plus 14.8 along the roll axis; as a hinge it misses by 14.8), so the card lifts it
# STRAIGHT UP out of its cradle instead: 8.703 is the cell's own height (measured), clearing
# the cradle's rim (3.46 above its floor) with nothing of the body above. The direction is
# a choice. split 0.521: the two distances' share of the pull.
part cell
  role    = feed
  subject = magazine
  take    = no
  surface = cell
  grab       = 23.58, 0.04, 33.78     # the top face
  grabradius = 3.0                    # ESTIMATE
  dof
    kind     = slide
    axis     = -1, 0, 0
    distance = 9.471
    detach   = 0.9
  end
  dof2
    kind     = slide
    axis     = 0, 0, 1
    distance = 8.703
    split    = 0.521
  end
end

# A sliding trigger: 2.047 along -x at frame 1, fit 0.000.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind     = slide
    axis     = -1, 0, 0
    distance = 2.047
  end
end

# THE FORWARD GRIP, ESTIMATE: the keel under the barrel housing (body island 11), its middle.
part support
  role    = support
  subject = support
  grab       = 38.93, 0.01, -2.90
  grabradius = 3.0
end

# THE COVER OPENS. A gun with an open verb not shut does not fire, so the BFG cannot fire
# with its cover up. It stays where the hand leaves it.
open cover
  part    = cover
  openat  = 0.85
  closeat = 0.05
  rest    = stay
end

# THE BATTERY. Declaring `open` turns verb synthesis off, so the swap is declared too,
# with the synthesised swap's own numbers (as WM_SMG). It NEEDS THE COVER UP: with it shut
# the drop button does nothing, a cell at the well is refused and a hand cannot pull one out
# (the closed cover overlaps the cell -- lowest cover vertex z 30.11, cell top 33.86).
swap magwell
  part     = cell
  store    = mag
  detachat = 0.9
  pullout  = 0.97
  button   = yes
  handtake = no
  needs    = open:cover
end
```

---

## 2. BFGHeavy — OFF HAND (hidden-cell ESTIMATE)

### Source
- **Mesh:** `E:\DOOMWork\RS_ModelSwapper\models\hud\BFG9000\BFG.md3`, 16 frames, **rest 6**.
  - Surfaces: `Untitled` 7121v in 49 islands, and `Untitled` 52v.
  - The mesh file has no shader entries.
- **MODELDEF:** block `MS_VR_BFG9000`, `Scale -1.0 1.0 1.0`, `Offset 0.078 -54.500 1.016`, `FrameIndex BFGG A 0 6`.
- **Scale:** 1.0 × 0.34 = 0.34. It is 114.0 long, so 38.8 map units.

### THERE IS NO CELL, in any version

| Version | Frames | Reload frames | What moves against the body |
|---|---|---|---|
| Current (history `VR_BFG9000_va/BFG.md3`, re-origined at 315d09f) | 16 | — | only the 52v trigger |
| `models/bd21/BFG/BFG_10k.md3` (@3b744a7 = @198c0b1 = @2f749f8, the same blob) | 21 | 11-20 (RS_ForeignAnim.zs @198c0b1) | only the trigger. The reload is the whole gun lifting and tilting (`ms10k_6_vs_16.png`) |
| `models/bd21/BFG/BFG.md3` | 16 | 7-15 | only the trigger |
| `models/meatgrinder/BFG/BFG.md3` (@198c0b1) | 11 | — | only the trigger (15.0°) |

- **Commit 198c0b1 changed the importer's frame table, not the meshes.** The BFG blobs are identical before and after it.
- All 49 islands of the big surface stay fixed to the body on every frame (`ww2_split`, tolerance 0.15). They are listed with renders in `ms_islands\`.
  - None is cell-shaped.
  - The belly under the receiver (island 2) is a curved half-shell, 27.2 × 21.9 × 6.8.
  - The 8.7 above that shell holds 533 receiver vertices, so there is no empty well for a cell.

### Measurements (rest frame 6)

| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | surface 0, 7121v, 49 islands | the reference (its largest island, the grip) | — | ≤0.013 | `wm_renders\bfgheavy_wm_body.png` |
| trigger | surface 1, 52v | **hinge +30.15° about (0, 1, 0) through (-21.722, 0, -3.952)** | 7-13 (30.15 → 3.73) | 0.0099 | `wm_renders\bfgheavy_wm_trigger.png` |
| cell | **none** | **ESTIMATE**: straight down (0, 0, -1) out of the belly, 8.703 | — | — | — |

**Trigger sign check:** +30.15 lands the rest centroid on frame 7's (miss 0.000); −30.15 misses by 1.329.

### Card points (rest frame 6)

| Key | Value | How |
|---|---|---|
| muzzle | 57.95, 0.08, 10.01 | The upper front ring (island 36, y ±10.7, z 3.5..15.7), its front face (44v) centred; the upper housing (islands 5, 7) runs back from it |
| barrel | 1, 0, 0 | The trigger and pistol grip are at −x, the stock at x −56; symmetric about y 0.08 |
| support grab | 31.39, 0.08, -5.96 | The underside of the lower fore end (island 13, bottom centroid). **ESTIMATE** that the hand goes there |
| cell grab | -0.33, 0.08, -12.41 | The belly's lowest point (island 2). The point is measured; that a cell leaves there is an **ESTIMATE** |
| magcenter | 0.02, 0.08, -8.89 | The belly's centroid. **ESTIMATE** |
| cell axis / distance | (0, 0, -1) / 8.703 | **ESTIMATE**: down out of the belly, by the shared cell's height |

### Files written (`models/bfg/BFGHeavy/`)
- **`bfgheavy_wm.md3`**: frame 6 as the only frame, surfaces `body` 0 and `trigger` 1.
  - 7173/7173 verts, 7355/7355 tris, worst error 0.00000, UVs identical, packed normals copied bit for bit.
  - Shader `bfg.png`.
- **`wm_bfgheavy_cell.md3`**: the loose battery. It is **the BFG's own cell geometry**, since this gun has none and both share the 160-cell battery.
  - Re-origined on its centroid, **lying flat, not turned**: this card's axis is (0, 0, -1), and flat is how it would seat.
  - Size 35.219 × 21.312 × 8.703, within 0.0042, normals unchanged. Skin: `models/bfg/BFG/bfg9000.png`.
- `bfg.png`, copied verbatim from RS_ModelSwapper.

### MODELDEF block
```
// THE BFGHEAVY -- OFF HAND. RS_ModelSwapper's MS_VR_BFG9000 block, Scale and Offset
// verbatim. bfgheavy_wm.md3 is that mesh's rest frame 6 written as its only frame.
Model WM_PropBFGHeavy
{
	Path "models/bfg/BFGHeavy"
	Model 0 "bfgheavy_wm.md3"
	Skin 0 "bfg.png"
	Scale -1.0 1.0 1.0
	Offset 0.078 -54.500 1.016
	PlacementCVars wm_bfgheavy
	NOAUTOREVERSE
	FollowOffHand
	FrameIndex WMPR A 0 0
}
```

### Cvar stem `wm_bfgheavy` (every default an ESTIMATE)
```
// ---- BFGHEAVY, OFF HAND (renderer) -- ESTIMATE seat, tune in the headset ---
user float wm_bfgheavy_ofs_x   = 0.0;
user float wm_bfgheavy_ofs_y   = 0.0;
user float wm_bfgheavy_ofs_z   = 0.0;
user float wm_bfgheavy_yaw     = -90.0;
user float wm_bfgheavy_pitch   = 0.0;
user float wm_bfgheavy_roll    = 0.0;
user float wm_bfgheavy_scale   = 1.0;
user float wm_bfgheavy_scale_x = 1.0;
user float wm_bfgheavy_scale_y = 1.0;
user float wm_bfgheavy_scale_z = 1.0;
```

### Class lines
The same as the BFG's: `AmmoType1 "Cell"`, `WM_Gun.RoundsPerShot 40`, `WM_Gun.ShotClass "BFGBall"`,
`WM_Gun.ChargeTics 30`, `WM_Gun.ChargeSound` (the lead picks). All but AmmoType1 are
GRAMMAR PENDING (approved, not yet in code).

### Draft card
```
# ======================================================== BFGHEAVY -- OFF HAND
# RS_ModelSwapper's BFG.md3 (MS_VR_BFG9000, rest frame 6) as bfgheavy_wm.md3.
# THIS MESH HAS NO CELL: no piece moves against the body on any frame of it or its
# history twins (BFG_10k's reload 11-20 moves only the whole gun). The cell is HIDDEN --
# its part names no surface -- and every cell number is an ESTIMATE. _pending/BFG_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_BFGHeavy"
  type      = bfg     # its hand-seat profile (the key landed in c688186)
  hand      = off
  prop      = "WM_PropBFGHeavy"
  model     = "models/bfg/BFGHeavy" "bfgheavy_wm.md3"
  skin      = "models/bfg/BFGHeavy" "bfg.png"

  capacity  = 160
  magfamily = "bfgcell"

  firesfrom = magazine     # GRAMMAR PENDING (approved, not yet in code)
  casing    = none         # GRAMMAR PENDING (approved, not yet in code)
  hands     = 2            # GRAMMAR PENDING (approved, not yet in code)

  # The upper front ring (island 36), its front face centred.
  muzzle    = 57.95, 0.08, 10.01
  barrel    = 1, 0, 0

  # The loose battery is the BFG's own cell (this gun has none), lying flat.
  # magcenter ESTIMATE: the belly's centroid.
  magmodel  = "models/bfg/BFGHeavy" "wm_bfgheavy_cell.md3"
  magskin   = "models/bfg/BFG" "bfg9000.png"
  magscale  = 0.34
  magcenter = 0.02, 0.08, -8.89

  # SOUNDS: silent until the lead picks them.
end

# THE HIDDEN CELL, ESTIMATE: pulled straight down out of the belly by the shared cell's own
# height. No surface: nothing in the mesh moves; the battery appears as it leaves. The swap
# is SYNTHESISED (this card declares no verbs), and a synthesised verb is not asked for a
# surface (parser.zs VerbProblem) -- a declared one would be refused.
part cell
  role    = feed
  subject = magazine
  take    = no
  grab       = -0.33, 0.08, -12.41    # the belly's lowest point
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, 0, -1
    distance = 8.703
    detach   = 0.9
  end
end

# 30.15 degrees about the pin at -21.722, -3.952 (frame 7, fit 0.0099). Sign checked:
# +30.15 lands its rest centroid within 0.000 of frame 7; -30.15 misses by 1.329.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 30.15
    pivot   = -21.722, 0, -3.952
  end
end

# ESTIMATE: under the lower fore end (island 13's underside).
part support
  role    = support
  subject = support
  grab       = 31.39, 0.08, -5.96
  grabradius = 3.0
end
```

---

## Grammar gaps

**Approved, not in code** (written into both drafts):
- **G1** `firesfrom = magazine`
- `casing = none`
- `hands = 2`
- The class lines `RoundsPerShot`, `ShotClass`, `ChargeTics`, `ChargeSound`

**Not asked for, found while measuring:**
1. **The cover gates the cell. SETTLED (uzdxrema-11, RS_VR_Reload.pk3 14:38:07):** a swap now takes `needs = open:<id>`. The BFG's `swap magwell` carries `needs = open:cover`, so with the cover shut the drop button does nothing (logged once), a cell at the well is refused ("open its cover first"), and a hand cannot pull one out. The open verb still keeps the gun from firing while the cover is up.
2. **Declaring `open` turns swap synthesis off. SETTLED:** the declared swap reads fine beside the open verb and works as declared.
3. **The two-stage cell. FIXED in the reload system (14:38:07):**
   - Before, the well's mouth and a button drop read only the feed part's `dof`: the well sat at stage one complete, inside the cradle, and a dropped cell spawned there moving -x.
   - Now a dof2 feed part's well is the grab point through both stages. A button drop spawns the cell fully out and throws it along the last stage's axis.
   - Seating still drives the staged path from 1.0 down.
4. **The hidden cell (BFGHeavy). SETTLED, one quirk:**
   - The part has no surface, so it has no slot for seating to drive: the cell seats the moment it reaches the well.
   - A button drop spawns the cell at magcenter, moving along its dof axis.
   - A visible push would need a surface to drive, and this mesh has none.
5. **Meter skin. SETTLED by code (uzdxrema-11):** a pose override slot has no skin field, so a moving `meter` keeps its `SurfaceSkin 0 2` texture.
6. **The donor's gauge and spent cell. SETTLED (RS_VR_Reload.pk3 16:16:24):**
   - `part cover` carries `metersurface = meter`, `meterskins = "models/bfg/BFG" "bfg_meter%d.png"` and `metersteps = 7`. The meter wears ceil(fill x 7).
   - The card carries `magskinempty = "models/bfg/BFG" "bfg9000_off.png"` for a loose cell with 0 rounds.
   - bfg_meter2-7 and bfg9000_off.png were copied byte-identical from FU's models/bfg9000/ (the donor, cleared).
7. **No subject word for a lid:** the cover uses `foregrip`.

## Tool bug found (not a BFG gap; it affects other lanes' meshes)

**`md3.py` decodes packed normals with the two bytes swapped**, in steps of 2π/255. Quake 3 and GZDoom use the high byte as the azimuth, in steps of π/128. So any MD3 written by `md3_write.write` from surfaces loaded with `md3.py` gets rewritten normals.

**Evidence:**
- On `bfg9000.md3`, the Quake 3 reading agrees with the face normals (mean |dot| 0.657), md3.py's does not (0.369).
- A first `bfg_wm.md3` built that way kept 515 of 7633 packed normals.
- `models/smgs/SMG/smg_wm.md3` (read only) keeps **3821 of 21072**.
- Every `wm_split.py` output is likely affected: tec9, m16, SMG. Positions and UVs are exact; only lighting normals are wrong.

**Fix:**
- Pass the raw packed shorts. `md3_write.encode_normal` returns an int unchanged; scratch `bfg\rawmd3.py` reads them.
- Or correct `md3._decode_normal`.
- **Not fixed here:** the tools are shared.
