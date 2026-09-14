# Plasma rifle family: two draft cards

Measured on 2026-09-13, read-only. Numbers come from `tools/md3.py` rigid fits with the body's
own motion divided out. Scratch scripts, renders and raw output are in the session scratchpad
`plasma/` (`survey.txt`, `analyse.txt`, `measure.txt`). Each part was identified from a render
made with `RS_ModelSwapper/tools_md3_render.py`.

**Licence/credit: unrecorded for both.** Flag before anything ships.

**The two guns:**
- **PlasmaRifle (main hand):** ModelSwapper's plasma rifle mesh.
- **PlasmaCarbine (off hand):** Force Unleashed's plasma rifle and its cell.

The ModelSwapper lane reports no other distinct plasma rifle, and the Unmaker was not needed.

**What both cards share:**
- Capacity 50 (the owner's number).
- They fire straight from the cell: no chamber, no action part, no cycle, and no declared verbs.
  The swap is synthesised from the `role = feed` part.
- No brass, so neither card has an ejectport or ejectdir.
- Scale is MODELDEF 1.0 x 0.34, so 0.34 map units per model unit.

---

## 1. PlasmaRifle, main hand

### Source

| | |
|---|---|
| Mesh | `E:\DOOMWork\RS_ModelSwapper\models\hud\PlasmaRifle\PlasmaRifle.md3` + `PlasmaRifle.png` (512²) |
| MODELDEF | RS_ModelSwapper `modeldef`, block `MS_PlasmaRifle`: `Scale -1.0 1.0 1.0`, `Offset 0.469 -60.688 -1.266`, `FrameIndex PLSG A 0 4` |
| Rest frame | **4** |
| Clips | `RS_ForeignAnim.zs`: ready 4, fire 4-17, reload 18-29, sprint 3 |
| Structure | 30 frames, 4 surfaces: `[0] Frame` 4v, `[1] Battery` 34v, `[2] Trigger` 88v, `[3] Frame` 7467v (66 islands). **Two surfaces are named `Frame`**, so the `_wm` copy renames them. |

### Measurements

Rest frame 4. The body is every island of surface 3. The body fits to 0.015 or better on every
frame, and all 66 islands stay put.

| Part | Surface / islands | Motion | Frames | Fit | Render (scratchpad `plasma/`) |
|---|---|---|---|---|---|
| **cell** | `Battery`, 1 island. A box with 8 corners: 12.0 long × 3.19 thick × 10.77 tall, leaning 3.2° with its bottom forward. The UVs are a hazard-striped panel with a copper end strip, so it reads as a battery pack. | **Pure slide.** Frames 20-25 move it straight in: 0.05° of turn at most, and dx/dz stays between -0.197 and -0.199. The axis is **(0.1942, 0, -0.9810)**, 11.2° forward of straight down. Frame 19 is its fall, 41.01 below. | 19-25 | 0.010-0.013 | `wm_renders/plasmarifle_wm_cell.png`, `ms_battery_context.png`, `uv_ms_battery.png`, `../ww2_split/plasma_ms/part2.png` |
| **trigger** | `Trigger`, 1 island | **19.96°** about (0, 1, 0) through (-27.838, 0, -2.315), frame 5. Frames 6 and 7 turn 17.15° and 10.01° about the same pin. **Sign checked:** +19.96 lands the rest centroid 0.000 off frame 5; -19.96 misses by 1.255. | 5-7 (fire) | 0.009 | `wm_renders/plasmarifle_wm_trigger.png`, `../ww2_split/plasma_ms/part1_only.png` |
| body | `Frame` 7467v, plus the 4v `Frame`, which is a small red indicator decal on the +y side above the grip. It never moves (`ms_quad_context.png`, `uv_ms_quad.png`). | fixed | | ≤ 0.015 | `wm_renders/plasmarifle_wm_body.png` |

**The battery's sideways drift is left out on purpose.** While dropping it also moves along -y,
eased rather than in a line:

| Frame | dy | dz |
|---|---|---|
| 20 | -0.63 | -15.0 |
| 23 | -0.30 | -2.2 |
| 25 | -0.09 | -0.24 |

A well cannot let a cell slide sideways, so the axis keeps only the part in the xz plane, which is
a straight line.

### Other numbers

- **Muzzle (39.41, 0.54, 0.14).** The front face is 96 vertices at x 39.41 (y -3.89..4.95,
  z -5.00..5.27). The middles of the barrel rings (islands 0, 2, 7, 12) are all at y 0.539,
  z 0.13-0.14, so the bore is level along +x.
- **Distance 12.33.** This is the cell's own length along its axis, the pistols' convention. Its
  top drops below the lowest body vertex hugging it (z -11.69; the top is at z -7.84) after 3.92
  along the axis.
- **Grab (-12.38, 0.47, -18.93).** The centre of the cell's bottom face.
- **magcenter (-12.701, 0.469, -13.239).**
- **Support, ESTIMATE (14.0, 0.54, -8.1).** Under the rail beneath the barrel (surface 3 island 10,
  x -5.7..26.6; its underside is z -8.09 at x 12-16; `ms_rail_context.png`).
- **Pistol grip, for reference:** island 9, x -39.6..-23.9, z -14.4..-2.4.

### Built

- **`models/plasma/PlasmaRifle/plasmarifle_wm.md3`:** rest frame 4 written as its only frame.
  - Surfaces: `body` (surfaces 3 + 0, 7471v), `cell` (34v), `trigger` (88v).
  - Checks: 7593/7593 verts, 8678/8678 tris, worst vertex error **0.00000**.
  - Each surface is rendered alone over the gun (`wm_renders/`).
- **`wm_plasmarifle_cell.md3`:** the cell lifted out, re-origined on its centroid, and stood with
  its pull-out axis along -Z. This is how `rig.zs DropMagazine` drops a magazine
  (`down = feed.dof.axis`).
  - Size 13.36 × 3.19 × 12.31.
  - Rotated back into the gun, every vertex lands within 0.008.
- **`PlasmaRifle.png`:** a byte copy.

### Names, MODELDEF, cvars

- Classes: `WM_PlasmaRifle` / `WM_PropPlasmaRifle`. Hand: main.
- Cvar stem: `wm_plasmarifle`. Every default below is an ESTIMATE:

```
user float wm_plasmarifle_ofs_x   = 0.0;
user float wm_plasmarifle_ofs_y   = 0.0;
user float wm_plasmarifle_ofs_z   = 0.0;
user float wm_plasmarifle_yaw     = -90.0;
user float wm_plasmarifle_pitch   = 0.0;
user float wm_plasmarifle_roll    = 0.0;
user float wm_plasmarifle_scale   = 1.0;
user float wm_plasmarifle_scale_x = 1.0;
user float wm_plasmarifle_scale_y = 1.0;
user float wm_plasmarifle_scale_z = 1.0;
```

```
// THE PLASMA RIFLE -- MAIN HAND. RS_ModelSwapper's MS_PlasmaRifle block, Scale and Offset
// verbatim. plasmarifle_wm.md3 is that mesh's rest frame 4 written as its only frame, in the
// same units and origin, so the Offset carries over and the frame is 0 (PLASMA_CARDS.md).
Model WM_PropPlasmaRifle
{
	Path "models/plasma/PlasmaRifle"
	Model 0 "plasmarifle_wm.md3"
	Skin 0 "PlasmaRifle.png"
	Scale -1.0 1.0 1.0
	Offset 0.469 -60.688 -1.266
	PlacementCVars wm_plasmarifle
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

### Draft card

```
# ======================================================= PLASMA RIFLE -- MAIN HAND
# RS_ModelSwapper's plasma rifle as plasmarifle_wm.md3: rest frame 4 as its only frame,
# its two surfaces named "Frame" and the Battery renamed body and cell. Every number
# measured at frame 4 against every island of the body. _pending/PLASMA_CARDS.md.
#
# IT FIRES FROM THE CELL: no chamber, no action part, no cycle, no verbs declared --
# the swap is synthesised from the feed part.
weapon "WM_PlasmaRifle"
  type      = plasma     # its hand-seat profile (the key landed in c688186)
  hand      = main
  prop      = "WM_PropPlasmaRifle"
  model     = "models/plasma/PlasmaRifle" "plasmarifle_wm.md3"
  skin      = "models/plasma/PlasmaRifle" "PlasmaRifle.png"

  # Fifty cells, the owner's number.
  capacity  = 50
  # Its own family: the two plasma guns' cells are different shapes.
  magfamily = "plasmarifle"

  firesfrom = magazine   # GRAMMAR PENDING (approved, not yet in code)
  casing    = none       # GRAMMAR PENDING (approved, not yet in code) -- plasma throws no brass

  # The body's front face (x 39.41), on the barrel rings' centre (y 0.54, z 0.14). Level.
  muzzle    = 39.41, 0.54, 0.14
  barrel    = 1, 0, 0

  # The loose cell: its Battery surface lifted out, re-origined on its centroid and
  # stood along its pull-out axis. magcenter is that centroid in the gun's space.
  magmodel  = "models/plasma/PlasmaRifle" "wm_plasmarifle_cell.md3"
  magskin   = "models/plasma/PlasmaRifle" "PlasmaRifle.png"
  magscale  = 0.34
  magcenter = -12.701, 0.469, -13.239

  # This package's SNDINFO wm/plasma/* (the Vanilla+ plasma rifle's shots and cell foley).
  firesound    = "wm/plasma/fire"
  drysound     = "wm/dry"
  magoutsound  = "wm/plasma/magout"
  maginsound   = "wm/plasma/magin"
  magdropsound = "wm/magdrop"
end

# THE CELL. A pure slide on its insert frames 20-25 (0.05 degrees of turn at most, fit
# 0.013), dx/dz constant at -0.198: (0.1942, 0, -0.9810), 11.2 degrees forward of straight
# down. The donor's eased sideways drift (0.63 at most) is left out -- a well cannot let a
# cell slide sideways. Distance is the cell's own length along the axis.
part cell
  role    = feed
  subject = magazine
  take    = no          # out by its button, in by the hand carrying one
  surface = cell
  grab       = -12.38, 0.47, -18.93   # the cell's bottom face
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0.1942, 0, -0.9810
    distance = 12.33
    detach   = 0.9
  end
end

# 19.96 degrees about the pin at -27.838, -2.315 (frame 5, fit 0.009). Sign checked:
# +19.96 lands the rest centroid 0.000 off frame 5; -19.96 misses by 1.255.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 19.96
    pivot   = -27.838, 0, -2.315
  end
end

# ESTIMATE: under the rail beneath the barrel (underside z -8.09 at x 12-16).
part support
  role    = support
  subject = support
  grab       = 14.0, 0.54, -8.1
  grabradius = 3.0
end
```

---

## 2. PlasmaCarbine, off hand

### Source

| | |
|---|---|
| Meshes | `E:\DOOMWork\_old\doom-force-unleashed_devbuild\models\plasmarifle\plasma_rifle.md3` (2 frames: 0 idle, 1 fire) + `plasma_mag.md3` (6 frames) + `plasmarifle.png` (512²) |
| MODELDEF | `modeldefs\weapons\plasmarifle.txt`, class `RLPlasmaRifle`, blocks PLSG/PLSP/PL2H/PL2P/PLNH/PLNP. Each block draws `Model 0 plasma_rifle.md3` and `Model 1 plasma_mag.md3` together, in one space: `Scale -1.0 1.0 1.0`, `Offset 0.0 -24.0 -10.0` |
| Rest frame | **rifle 0 + mag 0.** Idle `PLSG A 0 0` / `PLSG A 1 0` has the cell seated. |
| Donor animation | Mag frame 99 (out of range) hides the cell when empty. Reload states D-H play mag frames 1-5, and frame 5 equals frame 0. |
| Structure | `plasma_rifle` 3167v (16 islands), `plasma_rifle_trigger` 46v, `plasma_rifle_pipes` 291v (6 islands), `plasma_rifle_heatsink` 790v. `plasma_rifle_mag` 295v has 2 islands: the cell 279v and its top contact plate 16v, which move together. Rifle frame 1 moves only the trigger (body fit 0.0000). |
| Not used | `plasma_mag2.md3` is FU's loose copy of the same cell (identity rotation, shifted by (-26.59, 0, 4.27), rmsd 0.017). |

### Measurements

| Part | Surface / islands | Motion | Frames | Fit | Render (scratchpad `plasma/`) |
|---|---|---|---|---|---|
| **cell** | `plasma_rifle_mag`, both islands. A pentagon-sided cell with a blue emblem in its UVs. It sits ahead of the trigger guard, 3.73 up inside the receiver: the plate top is z 10.56 and the receiver underside is z 6.83 (x 20.48..32.59, y ±3.62). | Frame 1: the centroid moves **10.387 along (-0.2308, 0, -0.9730)** and turns **20.19° about +y**. Frames 2-4 are the same motion scaled to u = 0.848, 0.509, 0.161. **One slide with twist about the cell's rest centroid lands every vertex within 0.021 / 0.031 / 0.040 / 0.030** on frames 1-4 (with -turn it misses by up to 6.5). The top plate, the part inside the well, moves straight down: (-0.010, 0, -1.000) on every frame. | 1-5 (reload) | 0.009-0.011 | `fu_cell_context.png`, `fu_mag_0_vs_1.png`, `fu_cell_f1_vs_model.png` (the model lies exactly on frame 1), `wm_renders/plasmacarbine_wm_cell.png` |
| **trigger** | `plasma_rifle_trigger`, 1 island | **25.04°** about (0, 1, 0) through (12.290, 0, 6.588), frame 1. **Sign checked:** +25.04 lands the rest centroid 0.000 off; -25.04 misses by 1.885. | 1 (fire) | 0.009 | `fu_trigger_context.png`, `wm_renders/plasmacarbine_wm_trigger.png`, `../ww2_split/plasma_fu/part1.png` |
| body | `plasma_rifle` + `pipes` + `heatsink` | fixed | | 0.0000 | `wm_renders/plasmacarbine_wm_body.png` |

### How the cell comes out: one slide with `twist`

I chose a single slide with `twist` over a straight slide or dof + dof2, for three reasons:

1. **It is the donor's own motion.** It matches every reload frame to 0.04.
2. **Nothing turns inside the receiver.** The turn about the centroid and the backward slide cancel
   at the top, so the top of the cell comes straight down out of the well. Below the well the cell
   rocks out past the trigger guard its rear face stands against (cell x 20.14, guard front
   x 20.47).
3. **It needs no new grammar.** It is one stage, and `twist` / `twistaxis` on a slide dof are
   already in the grammar: `rig.zs` turns it in the hand and `CarriedBy` / `PartOffset` pose it.
   `detach` stays on the dof, as the lead asked.

**Pivot = the cell's rest centroid = magcenter.** `DropMagazine` places the loose cell at
`magcenter + axis × value × distance`, so it appears exactly where the drawn cell's centroid is.

**Distance 10.387 is the donor's own drop, not the cell's length (14.89).** The twist is locked to
it at 1.94° per unit, and the cell is clear of the well from 36% of the pull. A longer pull would
need the twist scaled with it, for example 14.89 and 28.9° (ESTIMATE; tips further than the donor).

**Measured fallback, if twist is not wanted: dof + dof2.**
- Stage one: slide (0, 0, -1) 3.73, out of the well.
- Stage two: hinge 20.19° about (0, 1, 0) through (7.455, 0, 2.990). This lands every vertex of
  frame 1 within 0.021.
- Split: 0.353 by path length.
- `detach` must stay on the dof. How the synthesised swap reads it against a two-stage pull is for
  the reload lane to confirm.

### Other numbers

- **Muzzle (87.67, 0.0, 15.38).** The front face is 126 vertices at x ≥ 87.1, bbox middle y 0.008,
  z 15.383. FU's own flash `plasma_mf2.md3` is centred at (92.69, 0.11, 15.26), in front of it.
  The receiver (z 6.83..23.92) centres on the same height, so the bore is level along +x.
- **Grab (29.45, 0.0, -3.69).** The centre of the cell's bottom face, which runs x 25.89..33.02.
- **magcenter (26.560, 0.005, 3.176).**
- **Support, ESTIMATE (57.0, 0.0, 8.0).** Under the heatsink, which runs x 41.3..73.5 with its
  underside at z 8.03. The underside has no vertices within |y| < 3 there.
- **Pistol grip, for reference:** island 2, x -4.7..5.6, z -7.25..10.14. **FU's origin is at the
  grip**, not re-centred the way ModelSwapper's meshes are, so its placement sliders will land
  far from the rifle's.
- **Not copied, both optional:**
  - A three-digit round counter: `plasma_d1..d3.md3` are 4-vert quads at x -1.59..0.31,
    y -2.02..2.00, z 20.92..22.42 (rear top, facing the shooter), drawn with skins
    `plasma_digit_0..9.png`.
  - `plasmarifle_HD.png` (1024²) and its PBR maps.

### Built

- **`models/plasma/PlasmaCarbine/plasmacarbine_wm.md3`:**
  - First `plasma_rifle.md3` frame 0 and `plasma_mag.md3` frame 0 were merged into one mesh
    (scratch `fu_combined.md3`, checked against both sources, worst 0.00000), then split.
  - Surfaces: `body` (plasma_rifle + pipes + heatsink, 4248v), `cell` (295v), `trigger` (46v).
  - Checks: 4589/4589 verts, 5044/5044 tris, worst vertex error **0.00000**.
- **`wm_plasmacarbine_cell.md3`:** the cell upright along its slide axis.
  - Size 15.34 × 6.50 × 14.89.
  - Rotated back into the gun, every vertex lands within 0.009.
- **`plasmacarbine.png`:** a byte copy of `plasmarifle.png`.

### Names, MODELDEF, cvars

- Classes: `WM_PlasmaCarbine` / `WM_PropPlasmaCarbine`. Hand: off.
- Cvar stem: `wm_plasmacarbine`, with the same ten keys and defaults as the rifle (ofs 0, yaw -90,
  pitch 0, roll 0, scale 1, scale_x/y/z 1). All ESTIMATE.

```
// THE PLASMA CARBINE -- OFF HAND. Force Unleashed's plasma rifle and its cell, which its
// MODELDEF draws in one block and one space: Scale and Offset verbatim. plasmacarbine_wm.md3
// is plasma_rifle.md3 frame 0 and plasma_mag.md3 frame 0 (seated) as one frame, the same units
// and origin, so the Offset carries over (PLASMA_CARDS.md).
Model WM_PropPlasmaCarbine
{
	Path "models/plasma/PlasmaCarbine"
	Model 0 "plasmacarbine_wm.md3"
	Skin 0 "plasmacarbine.png"
	Scale -1.0 1.0 1.0
	Offset 0.0 -24.0 -10.0
	PlacementCVars wm_plasmacarbine
	NOAUTOREVERSE
	FollowOffHand
	FrameIndex WMPR A 0 0
}
```

### Draft card

```
# ===================================================== PLASMA CARBINE -- OFF HAND
# Force Unleashed's plasma rifle and its cell as plasmacarbine_wm.md3: the rifle's idle
# frame and the cell seated, one frame, surfaces body, cell and trigger. Every number
# measured in that shared space. _pending/PLASMA_CARDS.md.
#
# IT FIRES FROM THE CELL, as the plasma rifle's card: no chamber, no action, no verbs.
weapon "WM_PlasmaCarbine"
  type      = plasma     # its hand-seat profile (the key landed in c688186)
  hand      = off
  prop      = "WM_PropPlasmaCarbine"
  model     = "models/plasma/PlasmaCarbine" "plasmacarbine_wm.md3"
  skin      = "models/plasma/PlasmaCarbine" "plasmacarbine.png"

  capacity  = 50
  magfamily = "plasmacarbine"

  firesfrom = magazine   # GRAMMAR PENDING (approved, not yet in code)
  casing    = none       # GRAMMAR PENDING (approved, not yet in code)

  # The emitter block's front face (x 87.67), centred (y 0.0, z 15.38). Level.
  muzzle    = 87.67, 0.0, 15.38
  barrel    = 1, 0, 0

  magmodel  = "models/plasma/PlasmaCarbine" "wm_plasmacarbine_cell.md3"
  magskin   = "models/plasma/PlasmaCarbine" "plasmacarbine.png"
  magscale  = 0.34
  magcenter = 26.560, 0.005, 3.176

  firesound    = "wm/plasma/fire"
  drysound     = "wm/dry"
  magoutsound  = "wm/plasma/magout"
  maginsound   = "wm/plasma/magin"
  magdropsound = "wm/magdrop"
end

# THE CELL ROCKS OUT: ONE SLIDE THAT TURNS AS IT GOES. The donor's reload frames 1-4 are
# one motion scaled -- the centroid 10.387 along (-0.2308, 0, -0.9730) while turning 20.19
# degrees about +y -- and this dof lands every vertex of every one within 0.04 (the other
# way round misses by 6.5). The cell's top, the part in the well, comes straight down;
# the bottom rocks back past the trigger guard. Pivot is the cell's rest centroid, which
# is magcenter, so a dropped cell appears where the drawn one is.
part cell
  role    = feed
  subject = magazine
  take    = no
  surface = cell
  grab       = 29.45, 0.0, -3.69     # the cell's bottom face
  grabradius = 3.0
  dof
    kind      = slide
    axis      = -0.2308, 0, -0.9730
    distance  = 10.387
    twist     = 20.19
    twistaxis = 0, 1, 0
    pivot     = 26.560, 0.005, 3.176
    detach    = 0.9
  end
end

# 25.04 degrees about the pin at 12.290, 6.588 (frame 1, fit 0.009). Sign checked:
# +25.04 lands the rest centroid 0.000 off; -25.04 misses by 1.885.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 25.04
    pivot   = 12.290, 0, 6.588
  end
end

# ESTIMATE: under the heatsink (x 41.3..73.5, underside z 8.03).
part support
  role    = support
  subject = support
  grab       = 57.0, 0.0, 8.0
  grabradius = 3.0
end
```

---

## Class lines (the lead writes the classes)

Both guns take the same lines. Vanilla's plasma rifle calls A_FirePlasma every 3 tics while the
trigger is held, and waits 20 tics after release.

| Class line | Status |
|---|---|
| `Weapon.AmmoType1 "Cell"` | Standard GZDoom property |
| `WM_Gun.FullAuto true` | Already a property in `RS_VR_Reload/zscript/wm/weapon.zs` |
| `WM_Gun.FireTics 3` | Already a property in `weapon.zs` |
| `WM_Gun.ShotClass "PlasmaBall"` | **GRAMMAR PENDING (approved, not yet in code)**; not in `weapon.zs` |

No damage or rates are set here.

## Grammar gaps

- **G1 `firesfrom = magazine`** — GRAMMAR PENDING (approved, not yet in code). Both cards declare no
  stores, so the pistol pair (`mag` + `chamber`) is synthesised today. What `firesfrom` does with
  the synthesised chamber is for the reload lane to decide.
- **`casing = none`** — GRAMMAR PENDING (approved, not yet in code).
- **`WM_Gun.ShotClass`** — GRAMMAR PENDING (approved, not yet in code).
- **The 20-tic wait after release. SETTLED as G15 (uzdxrema-11, RS_VR_Reload.pk3 15:18):**
  `WM_Gun.ReleaseTics`. Both plasma classes set 20, vanilla's `PLSG B 20 A_ReFire`.
- **A dropped cell forgets its twist (read from code, not seen in game). G14, in progress with
  uzdxrema-11.** `DropMagazine` orients the loose cell by `feed.dof.axis` only, and `loose.zs`
  reads no `twist`.
  - At `detach 0.9` the carbine's drawn cell is turned 18°, so the loose one will likely snap
    upright as it drops.
  - Its position is exact, because the pivot is the centroid.
  - The loose meshes' stand rotations were measured for it (`SP\lead\measure_stand.py`,
    `stand_rule.py`).
- **Optional:** FU's three-digit round counter, which would need a per-digit skin swap capability.
  No emitter glow or muzzle flash was measured for either gun.
