# Chaingun family — measurements and draft cards

2026-09-13, the chaingun helper. Read-only on every source. Nothing in the shared files was
touched. The only files written are the ones under `models/chainguns/` and this file.

**Two guns:**
- **Chaingun** (main hand): Force Unleashed's chaingun, with its own box magazine.
- **MachineGun** (off hand): RS_ModelSwapper's belt-fed machine gun. Its ammo box is a separate
  piece under the receiver and can be split out cleanly. The box never moves in the donor's
  frames, so its axis comes from its shape, as the Tec9's did.

**Licence/credit: unrecorded** for both (Force Unleashed is Ermac's mod, cleared by the owner;
the ModelSwapper mesh is a Brutal Doom import). Flag before anything ships.

`SP` below = `C:\Users\Command\AppData\Local\Temp\claude\E--DOOMWork-RS-VR-Weapons\1c739cbc-eb97-4b35-a0d1-aa9c4e697297\scratchpad`.

**Method:**
- Every surface was split into islands.
- Every island was rigid-fit against the body with the body's own motion divided out.
- Every hinge was sign-checked: the rest centroid was turned by +deg and by -deg and compared
  with the frame.
- Every part was rendered with `RS_ModelSwapper/tools_md3_render.py`, and the PNGs were looked at.

Scripts and text output are in `SP\chaingun\`:
- `measure_fu.py` / `measure_fu.txt`
- `measure_mg.py` / `measure_mg.txt`
- `checks.py` / `checks.txt`
- `fu_build.py` / `build_fu.txt`
- `spec_machinegun.json` / `build_mg.txt`

**Vanilla facts** (for the class; the lead writes the lines):
- A_FireCGun fires one bullet every 4 tics and uses 1 Clip per shot.
- Damage is 5 × 1d3.
- The first shot of a burst is dead on. On refire the shot spreads up to ±5.6° horizontally.
- Class lines: `AmmoType1 Clip`, `WM_Gun.FullAuto true`, `WM_Gun.FireTics 4` (and
  `ShotSpread 5.6, 0` per ARSENAL_LEAD.md).

**Scale:** both MODELDEFs are `Scale -1 1 1`, so 1 model unit is 0.34 map units in the follow-hand
frame. `magscale 0.34` on both.

---

## 1. CHAINGUN — Force Unleashed, main hand

### Source
- **Gun:** `E:\DOOMWork\_old\doom-force-unleashed_devbuild\models\chaingun\chaingun.md3`
  - 11 frames. Rest is **frame 0**.
  - Frames 1-4 are the barrel spin (FU `CGUN C-F`).
- **Magazine:** `cg_mag.md3`, **frame 5** = seated.
  - FU's idle `CGUN A` draws gun frame 0 with mag frame 5.
  - The mag's frames 0-5 are the insert (`H-M`).
  - Frame 99/9 is past the end of the file, i.e. hidden.
- **Belt:** `cg_ammo1.md3`, the full ammo-counter belt.
- **One space:** FU's MODELDEF (`modeldefs\weapons\chaingun.txt`, `Model RLChaingun`) draws
  `Model 0 chaingun.md3` and `Model 1 cg_mag.md3` in one block, with `Scale -1.0 1.0 1.0` and
  `Offset 0.0 -24.0 -10.0`.
  - The `CGNA` overlay block draws `cg_ammo1..10.md3` at the same Scale and Offset.
- **Skin:** `chaingun_HD.png` (1024²), copied.
  - `chaingun.png` is the same diffuse at 512²; the layouts are identical (both were looked at).
  - `_n/_r/_m/_ao/_bm` are the PBR maps, not used.

### What the extra files are
- **`cg_ammo1..10.md3` — an ammo counter.**
  - It is a belt of rounds hanging on the gun's -y wall.
  - `cg_ammo1` has 11 rounds (`cg_ammo.001-.011`, 150v each) and 9 link quads.
  - Each next file drops the bottom round; `cg_ammo10` has 2.
  - FU picks the file by rounds left: >10 shows `cg_ammo1`, down to `cg_ammo10`, and nothing at 0
    (`zscript\weapons\chaingun.txt` AmmoOverlay).
  - The top round turns into the receiver through body island 14, a flat quad at y -5.28,
    z 14.4..16.9 (measured; `SP\chaingun\zoom\fu_belt.png`).
- **`cg_ammoclip.md3` — one belt link.**
  - 38v, 1.70 × 1.66 × 0.58.
  - FU throws one with each case (`CGCasingSpawner` spawns `CGBulletCasing` and `CGAmmoClip`).
  - Not copied.
- **`cg_mf.md3`** is the muzzle-flash quads, centred at z 21.2-21.6: the top barrel.
- **`chaingun_pickup.md3`** is the world pickup, which has a side handlebar the HUD mesh lacks.
  Not used.

### Built
**`models/chainguns/Chaingun/chaingun_wm.md3`**
- One frame; surfaces `body`, `barrels`, `trigger`, `magazine`, `belt`.
- 4763/4763 verts, 4971/4971 tris, worst vertex error 0.00000, every UV identical.
- Made by `SP\chaingun\fu_build.py`. It merges three source models in their one space, so
  wm_split.py (single source) was not used; the same verification is done.

**`models/chainguns/Chaingun/wm_chaingun_mag.md3`**
- The `magazine` surface (box + its top rounds), 773v, made with `md3_write.extract`.
- Re-origined on its vertex centroid.
- Its pull axis is already (0, 0, -1), so it stands exactly as it sits in the gun.
- Size 7.23 × 7.09 × 13.94, i.e. 2.5 × 2.4 × 4.7 map units.

**`models/chainguns/Chaingun/chaingun_HD.png`**

### Measurements (rest: gun frame 0, magazine frame 5)

| Part | Surface / islands | Motion (body's own divided out) | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | `cg_body` 954v, 15 islands | static on all 11 frames (t 0.000) | — | 0.0000 | `SP\chaingun\wm_renders\chaingun_wm_body.png`, `SP\chaingun\fu_gun\gun_hl_0_*.png` |
| barrels | `cg_barrel` 503v, 12 isl (shroud ring + 6 tubes + 5 end discs), `cg_barrel_ring1` 199v/4, `ring2` 495v/1, `ring3` 102v/1; 1299v total | **60.00° about (1, 0, 0) through (y 0, z 15.03)** at frame 4; 30.34 / 47.86 / 57.12 / 60.00 over frames 1-4 (an ease), 60 held 5-10. Six tubes 60° apart at radius 5.4-5.6 | 1-4 | 0.012-0.013 | `SP\chaingun\wm_renders\chaingun_wm_barrels.png`, `SP\ww2_split\cg_fu_gun\part1.png` |
| barrels, sign | top tube (`cg_barrel` island 1) | its centroid goes (y -0.05, z 20.60) → (-4.84, 17.77) at frame 4; +60 about +x lands it (miss 0.0000, -60 misses 0.0235) | 4 | — | `SP\chaingun\zoom\fu_muzzle.png` |
| trigger | `cg_trigger` 46v, 1 isl | **19.02° about (0, 1, 0) through (12.115, 0, 6.675)**; +19.02 misses 0.0011, -19.02 misses 1.54 | 1 (held 1-10) | 0.0091 | `SP\chaingun\wm_renders\chaingun_wm_trigger.png`, `SP\ww2_split\cg_fu_gun\part2.png` |
| magazine | `cg_mag` 426v (the box) + `cg_ammo` 347v, 3 isl (rounds out of its top), `cg_mag.md3` frame 5 | **12.125 along (0, 0, -1)** from seated (frame 5) to frame 0, 3.03 a step, 0.001-0.004° — a pure slide. Seated centroid **(21.850, -0.314, 8.678)**; z -0.125..13.812, **13.94 long**; floorplate centroid (22.211, -0.002, -0.125) | mag 0-5 | 0.007-0.011 | `SP\chaingun\wm_renders\chaingun_wm_magazine.png`, `SP\chaingun\fu_compose\seat.png`, `SP\chaingun\zoom\fu_mag.png` |
| the well | `cg_body` island 4, the plate under the receiver | z 4.64..8.09 over x 16.44..28.08: the box shows 4.77 below it at rest; its top clears the plate after 9.17 of pull | — | — | `SP\chaingun\fu_gun\gun_hl_0_4.png` |
| belt | `cg_ammo1.md3`, all 20 surfaces, 1691v | static; y -9.80..-4.92, z -4.91..16.67, x 19.27..25.42; rounds 6.156 long along x | — | — | `SP\chaingun\wm_renders\chaingun_wm_belt.png`, `SP\chaingun\zoom\fu_belt.png` |
| carry handle | `cg_body` island 5, 76v | static; a Π on top: posts at y ±7.1 from z 20.88, bar x 25.27..27.39, y -4.66..4.70, z 27.91..29.34 | — | — | `SP\chaingun\zoom\fu_handle.png` |
| pistol grip | `cg_body` island 2, 136v | static; x -4.38..5.58, z -6.62..7.30, behind the trigger | — | — | `SP\chaingun\zoom\fu_rear.png` |
| muzzle | the front face of the barrels | x 91.125. Top tube's front ring: y -1.83..2.12, z 18.58..22.50, centre (0.15, 20.54), radius 5.51 from the axis. Cluster axis at the front: (91.12, 0, 15.03) | — | — | `SP\chaingun\zoom\fu_muzzle.png` |
| side walls | `cg_body` verts with \|y\| > 7, x 15..32, z 7..23 | -y 63, +y 93. Four small plates on +y (islands 8-11, 3.98 × 0.50 × 1.75, x 17.7..26.6, z 15.5..19.9); the belt's entry quad on -y | — | — | `SP\chaingun\zoom\fu_walls.png` |

### Classes, hand, slot
- `WM_Chaingun : WM_Gun` and `WM_PropChaingun : WM_Prop`.
- **Main hand.** Slot 7 (ARSENAL_LEAD.md).

### MODELDEF
```
// THE CHAINGUN -- MAIN HAND. Force Unleashed's chaingun (modeldefs/weapons/chaingun.txt,
// Model RLChaingun), Scale and Offset verbatim. Mirrored (Scale x negative). chaingun_wm.md3 is
// FU's gun frame 0, its box magazine seated (cg_mag.md3 frame 5) and its full ammo belt
// (cg_ammo1.md3) in their one shared space, parts named (_pending/CHAINGUN_CARDS.md).
Model WM_PropChaingun
{
	Path "models/chainguns/Chaingun"
	Model 0 "chaingun_wm.md3"
	Skin 0 "chaingun_HD.png"
	Scale -1.0 1.0 1.0
	Offset 0.0 -24.0 -10.0
	PlacementCVars wm_chaingun
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

### CVARINFO — stem `wm_chaingun`, every default an ESTIMATE
```
// ---- CHAINGUN, MAIN HAND (renderer) -- ESTIMATE defaults, tune on its page ----
user float wm_chaingun_ofs_x   = 0.0;
user float wm_chaingun_ofs_y   = 0.0;
user float wm_chaingun_ofs_z   = 0.0;
user float wm_chaingun_yaw     = -90.0;
user float wm_chaingun_pitch   = 0.0;
user float wm_chaingun_roll    = 0.0;
user float wm_chaingun_scale   = 1.0;
user float wm_chaingun_scale_x = 1.0;
user float wm_chaingun_scale_y = 1.0;
user float wm_chaingun_scale_z = 1.0;
```

### Draft card
```
# ============================================================================
# THE CHAINGUNS: box-fed, fired straight from the box. No chamber, no rack.
#
# A trigger pull fires the next round out of the magazine. The only reload is the box: drop it
# by its button, take a fresh one from the pouch, push it up into the well. The shot is the
# class's (5 x 1d3 hitscan every 4 tics, 5.6 degrees on refire). Measured in
# _pending/CHAINGUN_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
# ============================================================================


# ============================================================ CHAINGUN -- MAIN HAND
# Force Unleashed's chaingun as chaingun_wm.md3: its gun (frame 0), its box magazine seated
# (cg_mag.md3 frame 5) and its full ammo belt (cg_ammo1.md3), three meshes FU draws in one
# space, written as one frame with named surfaces.
weapon "WM_Chaingun"
  type      = chaingun     # its hand-seat profile (the key landed in c688186)
  hand      = main
  prop      = "WM_PropChaingun"
  model     = "models/chainguns/Chaingun" "chaingun_wm.md3"
  skin      = "models/chainguns/Chaingun" "chaingun_HD.png"

  # The owner's 100-round box.
  capacity  = 100
  magfamily = "chaingun"

  # GRAMMAR PENDING (approved, not yet in code): fires from the magazine -- no chamber,
  # no `role = action` part, no cycle verb (a cycle is refused).
  firesfrom = magazine
  # GRAMMAR PENDING (approved, not yet in code): held in two hands; the support part below.
  hands     = 2

  # THE TOP BARREL'S BORE, at the barrels' front face (x 91.125). Six tubes turn about
  # (y 0, z 15.03); the one at twelve o'clock is 5.51 above the axis, and it is where FU's own
  # muzzle flash (cg_mf.md3) is centred. The cluster's axis at the front is 91.12, 0, 15.03.
  muzzle    = 91.12, 0.0, 20.54
  barrel    = 1, 0, 0

  # THE PORT'S SIDE IS REASONED, ITS POINT IS AN ESTIMATE. The belt feeds the -y wall (its top
  # round enters through the flat quad at y -5.28, z 14.4..16.9), so brass leaves by +y. The
  # point is the middle of the four small plates on that wall (x 17.7..26.6, z 15.5..19.9,
  # outer face y 8.06). ejectdir ESTIMATE, the rifles' mirrored.
  ejectport = 22.1, 8.1, 17.7
  ejectdir  = -0.3, 0.9, 0.4

  # The loose box: the magazine surface (box + the rounds out of its top), lifted out,
  # re-origined on its centroid. Its pull axis is straight down already, so it stands as it sits.
  # magcenter is that centroid in the gun's space (cg_mag.md3 frame 5, seated).
  magmodel  = "models/chainguns/Chaingun" "wm_chaingun_mag.md3"
  magskin   = "models/chainguns/Chaingun" "chaingun_HD.png"
  magscale  = 0.34
  magcenter = 21.850, -0.314, 8.678

  # A LOOSE ROUND, sized to this mesh's own: a belt round is 6.156 units x 0.34 = 2.09 map
  # units; bullet.md3 is 6.266 long, so 0.33.
  roundmodel = "models/pistols" "bullet.md3"
  roundskin  = "models/pistols" "bullet.png"
  roundscale = 0.33

  # A BELT LINK WITH EVERY CASE, as FU's CGCasingSpawner throws CGAmmoClip: its cg_ammoclip.md3
  # (1.70 x 1.66 x 0.58 units), on the chaingun's own skin. 0.34 keeps it the size it is on the gun.
  linkmodel = "models/chainguns/Chaingun" "cg_ammoclip.md3"
  linkskin  = "models/chainguns/Chaingun" "chaingun_HD.png"
  linkscale = 0.34

  # This package's chaingun sounds (SNDINFO wm/chaingun/*). The last three are the barrels'
  # wind-up, loop and wind-down (part barrels' spin).
  firesound    = "wm/chaingun/fire"
  drysound     = "wm/dry"
  magoutsound  = "wm/chaingun/magout"
  maginsound   = "wm/chaingun/magin"
  magdropsound = "wm/magdrop/large"
  casingsound  = "wm/casing"
  spinupsound   = "wm/chaingun/spinup"
  spinsound     = "wm/chaingun/spin"
  spindownsound = "wm/chaingun/spindown"
end

# THE BOX, AND THE BELT WITH IT. cg_mag + cg_ammo: 12.125 along (0, 0, -1) from seated to FU's
# first insert frame, 0.001-0.004 degrees, fit 0.007-0.011 -- a pure slide. Distance is the box
# and its rounds' own length along the axis, 13.94 (z -0.125..13.812); its top clears the well
# plate (z 4.64) after 9.17.
# THE BELT COUNTS DOWN AS FU'S DOES, riding the box. FU draws cg_ammo1 above 10 rounds,
# cg_ammo(12 - n) at 3-10, cg_ammo10 at 1-2 and nothing at 0. chaingun_wm.md3's belt is split by
# the count each piece first goes missing at, and each is a roundsurface on the counted mag,
# drawn while it holds MORE than its number: `belt` (the top two rounds and the entry link) at
# any count, belt03 from 3 rounds up, and so on to belt11 (the bottom round and its link) from 11.
part magazine
  role    = feed
  subject = magazine
  take    = no          # out by its button, in by the hand carrying one
  surface = magazine
  roundsurface = belt, mag, 0
  roundsurface = belt03, mag, 2
  roundsurface = belt04, mag, 3
  roundsurface = belt05, mag, 4
  roundsurface = belt06, mag, 5
  roundsurface = belt07, mag, 6
  roundsurface = belt08, mag, 7
  roundsurface = belt09, mag, 8
  roundsurface = belt10, mag, 9
  roundsurface = belt11, mag, 10
  grab       = 22.21, 0.0, -0.13     # the floorplate, 4.77 below the well plate at rest
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, 0, -1
    distance = 13.94
    detach   = 0.9
  end
end

# 19.02 degrees about the pin at 12.115, 6.675 (frame 1, fit 0.009). Sign checked: +19.02 lands
# its rest centroid within 0.001 of frame 1; -19.02 misses by 1.54. Follows your finger.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 19.02
    pivot   = 12.115, 0, 6.675
  end
end

# THE OTHER HAND ON THE CARRY HANDLE. Measured: the bar of the handle on top of the receiver
# (cg_body island 5), x 25.27..27.39, y -4.66..4.70, z 27.91..29.34; this is its middle. The only
# handle on the mesh ahead of the pistol grip. The other candidate is the barrel shroud ring
# (x 33.5..42.0, z 6.1..24.0) if the hold feels short.
part support
  role    = support
  subject = support
  grab       = 26.33, 0.0, 28.63
  grabradius = 3.0
end

# THE BARRELS SPIN while the trigger is held, about the cluster's axis (1, 0, 0) through
# (y 0, z 15.03). Six tubes, so one period is 60 degrees. FU's own spin eases 30.3 / 47.9 / 57.1
# / 60 over four frames, then steps a frame a tic: 15 degrees a tic at full speed, 4 tics to
# reach it. spindown 20 is an ESTIMATE: the donor has no wind-down frames. Looks only -- it
# never holds off the shot.
part barrels
  surface  = barrels
  spin     = trigger
  spinrate = 15
  spinup   = 4
  spindown = 20
  dof
    kind    = hinge
    axis    = 1, 0, 0
    pivot   = 0, 0, 15.03
    degrees = 60
  end
end
```

---

## 2. MACHINEGUN — RS_ModelSwapper's belt-fed machine gun, off hand

> **SUPERSEDED (2026-09-13, the owner):** the bullets come from the reserve and the reload is the
> underbarrel grenade launcher, loaded with RS_Grenade's grenades. The measurements below still
> stand; the card is `_pending/MACHINEGUN_UBL.md`.

### Source
- **Mesh:** `E:\DOOMWork\RS_ModelSwapper\models\hud\Machinegun\Machinegun.md3`
  - 36 frames. Rest **frame 10**.
  - Clips (`zscript\RS_ForeignAnim.zs`): select 4-5, fire 4,5,7-10, altfire 11-17, reload 18-35.
- **MODELDEF:** block `MS_BD_Machinegun` in `RS_ModelSwapper\modeldef`: `Scale -1.0 1.0 1.0`,
  `Offset -0.203 -52.594 -4.188`, `FrameIndex CHGG A 0 10`.
  - The mesh is re-origined there, so the Offset carries over.
- **Skin:** `Machinegun.png` (512²), copied under that name.
- **It carries an underbarrel launcher** (`alt-*` surfaces).
  - **The donor's reload clip (18-35) is the launcher's:** its tube slides forward 9.50.
  - **No box, feed cover or belt moves in any frame.**

### The box
M249_lowpoly islands 20, 22 and 33 are an ammo box hanging under the receiver, ahead of the
trigger guard:
- island 20, 162v: the box
- island 22, 152v: its lid, same footprint
- island 33, 101v: a feed piece on top

**Why it can be split:**
- They are separate islands, so the split cuts no triangle.
- Over all 36 frames they drift at most 0.028 / 0.030 / 0.030 against the receiver: it is a box
  that never moves.

**Seating needs no animation.** The axis comes from its shape, as on the Tec9:
- It is an axis-aligned box: covariance off-diagonals ≤ 0.09.
- Its top is flush with the receiver's underside (box top z -1.75; the receiver above its
  footprint starts at z -1.88).
- So the axis is straight down.

Renders: `SP\chaingun\zoom\mg_box.png`, `SP\chaingun\zoom\mg_box_20.png`,
`SP\chaingun\ms_mg\mg_hl_*.png`.

### Built
**`models/chainguns/MachineGun/machinegun_wm.md3`**
- Rest frame 10 as one frame, by `SP\wm_split.py SP\chaingun\spec_machinegun.json`.
- Surfaces: `body`, `magazine` (islands 20, 22, 33), `trigger`, `launcher` (alt-frame),
  `launchertube` (alt-pipe), `launchertrigger` (alt-trig), `launcherlatch` (alt-trig-reload).
- 16748/16748 verts, 14895/14895 tris, worst vertex error 0.00000.
- The launcher pieces are named only so a card can hide or drive them later; the card below
  leaves them drawn, fixed.

**`models/chainguns/MachineGun/wm_machinegun_mag.md3`**
- The `magazine` surface, 415v, via `md3_write.py extract --axis 0,0,-1`.
- Re-origined, upright.
- 7.64 × 10.77 × 11.47, i.e. 2.6 × 3.7 × 3.9 map units.

**`models/chainguns/MachineGun/Machinegun.png`**

### Measurements (rest frame 10, against M249_lowpoly island 0, the receiver)

| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | `M249_lowpoly` less islands 20/22/33, 11581v | receiver island 0 (802v) is the reference; it drifts in world (raise 0-3, recoil 0.28 at 4/11/18+), divided out; every other island within 0.15 on all frames | — | — | `SP\chaingun\wm_renders\machinegun_wm_body.png`, `SP\chaingun\ms_mg\mg_whole.png` |
| magazine | islands 20 + 22 + 33, 415v | **never moves** (worst drift 0.030). Centroid **(-9.390, -0.351, -5.410)**; x -13.23..-5.59, y -5.83..4.94, z -13.22..-1.75, **11.47 tall**; axis from shape (0, 0, -1) | — | — | `SP\chaingun\wm_renders\machinegun_wm_magazine.png`, `SP\chaingun\zoom\mg_box.png` |
| trigger | `Trigger` 58v, 1 isl | **slides 0.598 along (-1, 0, -0.008)**, 0.11° | 5 | 0.0078 | `SP\chaingun\wm_renders\machinegun_wm_trigger.png`, `SP\ww2_split\cg_ms_machinegun\part4.png` |
| launchertube | `alt-pipe` 3470v, 2 isl | 9.504 along (1, 0, 0.001), 0.00° (the launcher's reload) | 19-35, plateau 24-35 | 0.0088 | `SP\chaingun\wm_renders\machinegun_wm_launchertube.png`, `SP\ww2_split\cg_ms_machinegun\part1.png` |
| launcher | `alt-frame` 1014v, 2 isl | static (0.015) | — | 0.0087 | `SP\chaingun\wm_renders\machinegun_wm_launcher.png` |
| launchertrigger | `alt-trig` 106v | 19.99° about (0, 1, 0) through (-2.177, 0, -7.864); +deg misses 0.0011, -deg 0.943 | 11 (altfire) | 0.0080 | `SP\chaingun\wm_renders\machinegun_wm_launchertrigger.png`, `SP\ww2_split\cg_ms_machinegun\part2.png` |
| launcherlatch | `alt-trig-reload` 104v | 18.93° about (0, -1, 0) through (0.801, 0, -8.229); +deg misses 0.0011, -deg 0.695 | 18-35 | 0.0099 | `SP\chaingun\wm_renders\machinegun_wm_launcherlatch.png`, `SP\ww2_split\cg_ms_machinegun\part3.png` |
| muzzle | front-most receiver verts | x 43.953, 56 verts, centroid (43.953, -0.241, 3.983); y -1.55..1.06, z 2.66..5.30 | — | — | — |
| launcher tube underside | alt-pipe island 0 | x 5.30..26.62, underside z -9.75 (-9.73 at x 12..20), y -3.41..2.88 | — | — | `SP\chaingun\wm_renders\machinegun_wm_launchertube.png` |
| receiver walls | verts at z -1..5 | y -2.77..2.58 over x -14..-4, -3.69..3.20 over x -4..4 | — | — | — |

### Classes, hand, slot
- `WM_MachineGun : WM_Gun` and `WM_PropMachineGun : WM_Prop`.
- **Off hand.** Slot 7.

### MODELDEF
```
// THE MACHINEGUN -- OFF HAND. RS_ModelSwapper modeldef MS_BD_Machinegun, Scale and Offset
// verbatim. Mirrored (Scale x negative). machinegun_wm.md3 is Machinegun.md3's rest frame 10
// written as its only frame, its ammo box split out as `magazine` and the underbarrel launcher's
// pieces named, in the same units and origin (_pending/CHAINGUN_CARDS.md).
Model WM_PropMachineGun
{
	Path "models/chainguns/MachineGun"
	Model 0 "machinegun_wm.md3"
	Skin 0 "Machinegun.png"
	Scale -1.0 1.0 1.0
	Offset -0.203 -52.594 -4.188
	PlacementCVars wm_machinegun
	NOAUTOREVERSE
	FollowOffHand
	FrameIndex WMPR A 0 0
}
```

### CVARINFO — stem `wm_machinegun`, every default an ESTIMATE
```
// ---- MACHINEGUN, OFF HAND (renderer) -- ESTIMATE defaults, tune on its page ----
user float wm_machinegun_ofs_x   = 0.0;
user float wm_machinegun_ofs_y   = 0.0;
user float wm_machinegun_ofs_z   = 0.0;
user float wm_machinegun_yaw     = -90.0;
user float wm_machinegun_pitch   = 0.0;
user float wm_machinegun_roll    = 0.0;
user float wm_machinegun_scale   = 1.0;
user float wm_machinegun_scale_x = 1.0;
user float wm_machinegun_scale_y = 1.0;
user float wm_machinegun_scale_z = 1.0;
```

### Draft card
```
# ======================================================== MACHINEGUN -- OFF HAND
# RS_ModelSwapper's belt-fed machine gun as machinegun_wm.md3: rest frame 10 as its only frame,
# its ammo box (islands 20, 22, 33 of the receiver surface) split out as `magazine`. Every number
# measured at frame 10 against the receiver's largest island. The underbarrel launcher's pieces
# are named in the mesh (launcher, launchertube, launchertrigger, launcherlatch) and left fixed.
weapon "WM_MachineGun"
  type      = chaingun     # its hand-seat profile (the key landed in c688186)
  hand      = off
  prop      = "WM_PropMachineGun"
  model     = "models/chainguns/MachineGun" "machinegun_wm.md3"
  skin      = "models/chainguns/MachineGun" "Machinegun.png"

  # The owner's 100-round box, as the Chaingun's; the same family, so a box seats in either.
  capacity  = 100
  magfamily = "chaingun"

  # GRAMMAR PENDING (approved, not yet in code): fires from the magazine.
  firesfrom = magazine
  # GRAMMAR PENDING (approved, not yet in code): held in two hands.
  hands     = 2

  # The receiver's front-most vertices (the flash hider, x 43.95), on the bore.
  muzzle    = 43.95, -0.24, 3.98
  barrel    = 1, 0, 0

  # ESTIMATE, SIDE AND POINT. -y, the right side, as on the Rifle's and M16's cards; the
  # receiver wall ahead of the box (y -3.69 at x -4..4) and above the launcher's frame (its top
  # is z -2.67). A real one of these throws its cases down, but here the launcher is under it.
  ejectport = -4.0, -3.7, 0.5
  ejectdir  = -0.3, -0.9, 0.4

  # The loose box: its magazine surface lifted out, re-origined on its centroid, upright.
  magmodel  = "models/chainguns/MachineGun" "wm_machinegun_mag.md3"
  magskin   = "models/chainguns/MachineGun" "Machinegun.png"
  magscale  = 0.34
  magcenter = -9.390, -0.351, -5.410

  # 5.56x45, as the Rifle's.
  roundmodel = "models/pistols" "bullet.md3"
  roundskin  = "models/pistols" "bullet.png"
  roundscale = 0.31

  firesound    = "wm/chaingun/fire"
  drysound     = "wm/dry"
  magoutsound  = "wm/chaingun/magout"
  maginsound   = "wm/chaingun/magin"
  magdropsound = "wm/magdrop/large"
  casingsound  = "wm/casing"
end

# THE BOX. MEASURED FROM ITS SHAPE, NOT FRAMES: the donor never moves it (its reload clip is
# the launcher's). An axis-aligned box whose top is flush with the receiver's underside, so it
# comes straight down. Distance is its own height, 11.47.
part magazine
  role    = feed
  subject = magazine
  take    = no
  surface = magazine
  grab       = -9.39, -0.35, -13.22   # the bottom of the box
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, 0, -1
    distance = 11.47
    detach   = 0.9
  end
end

# A sliding trigger: 0.598 along (-1, 0, -0.008) at frame 5, fit 0.008.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind     = slide
    axis     = -1, 0, -0.008
    distance = 0.598
  end
end

# THE OTHER HAND UNDER THE LAUNCHER TUBE, which is where the handguard's underside is on this
# gun. Measured: the tube's underside is z -9.73 over x 12..20, centred y -0.27. ESTIMATE along
# x: the middle of the tube's body (x 5.30..26.62).
part support
  role    = support
  subject = support
  grab       = 15.96, -0.27, -9.73
  grabradius = 3.0
end
```

---

## Candidates not taken

**MS_Chaingun** (`models\hud\Chaingun\Chaingun.md3`, 16 frames, rest 4)
- A minigun with a spade grip and a side crank handle (Runko island 0, y +9..+27).
- `Pipe` (2568v, 37 isl) spins: 106° about (1, 0, 0) at frame 7, fit 0.014.
- `Trigger` turns 20.0° about (0, 1, 0) through (-35.63, 0, 6.62) at frame 8, fit 0.007.
- **No magazine, box or drum:** every island was listed, and none is box-shaped.
- Renders: `SP\chaingun\ms_cg\cg_whole.png`, `SP\ww2_split\cg_ms_chaingun\part1.png`, `part2.png`.
  Islands: `SP\chaingun\ms_cg\islands.txt`.

**MeatGrinder Chaingun** (`models/meatgrinder/ChainGun/Chaingun.md3` @3b744a7, extracted to
`SP\chaingun\mg_hist\`)
- 6 frames, 18 primitive surfaces of 1 island each.
- The barrels (six stretched spheres and cylinders) turn 45° about (-1, 0, 0) at frame 3, fit 0.013.
- A trigger-sized cube turns 15.2°.
- **No box.**
- Renders: `SP\ww2_split\cg_mg_chaingun\part*.png`.

**MS_BD_Minigun** (history @6f23e1b): not examined. A usable box had already been found in the
Machinegun.

---

## Grammar gaps

1. **SPINNING BARRELS. SETTLED as G11 (uzdxrema-11, RS_VR_Reload.pk3 15:09):** part keys `spin`,
   `spinrate`, `spinup`, `spindown` on a one-period hinge, and card sounds `spinupsound` /
   `spinsound` / `spindownsound`. The live Chaingun card uses them (spinrate 15, spinup 4,
   spindown 20 ESTIMATE). The original ask:
   - **Chaingun:** the `barrels` surface turns about (1, 0, 0) through (y 0, z 15.03). Six tubes,
     so 60° brings it back to the same look.
   - **Donor rate:** FU eases 30.3 / 47.9 / 57.1 / 60° over four frames; its loop steps one frame
     a tic.
   - **Sounds:** `wm/chaingun/spinup`, `spin` and `spindown` are already in SNDINFO, but no card
     key plays them.
   - **What it wants:** a part kind (or dof kind) that turns at a rate while the trigger is held,
     with spin-up and spin-down, axis and pivot from the card, and those three sounds.
   - The MS_Chaingun's `Pipe` would use the same part.
2. **G1, `firesfrom = magazine`:** approved, not yet in code. Both cards use it and declare no
   action part and no verbs.
3. **G10, `hands = 2`:** approved, not yet in code. Both cards give a `role = support` part.
4. **THE BELT SHOWS ITS ROUNDS. SETTLED as G12 (15:05):** a roundsurface on a counted store is
   drawn while it holds more than *n*.
   - `chaingun_wm.md3`'s belt was split into `belt`, `belt03`..`belt11` byte for byte, by the
     count FU's AmmoOverlay first leaves each piece out at (`SP\chaingun\belt_count.py`,
     `belt_split.py`). Vertex bytes, UVs and triangles were verified.
   - FU keeps two rounds down to 1 (cg_ammo10), so `belt` holds the top two rounds and the
     entry link.
5. **BELT LINKS. SETTLED as G16 (uzdxrema-11, 15:15):** card keys `linkmodel` / `linkskin` /
   `linkscale`; a link leaves with every case the main barrel throws.
   - FU's link mesh `cg_ammoclip.md3` (1 surface, 38v, shader chaingun.png) is copied,
     byte-identical, to `models/chainguns/Chaingun/`.
   - It is on the Chaingun and the MachineGun cards, skin `chaingun_HD.png` (the same layout),
     scale 0.34.
   - MODELDEF.txt carries the `WM_BeltLink` block. Without it no link is thrown.
6. **THE MACHINEGUN'S UNDERBARREL LAUNCHER** has no grammar: a second weapon on one gun, with its
   own trigger (19.99°), latch (18.93°) and a tube that slides forward 9.504 to load. Its
   surfaces are named and drawn fixed.
7. **THE MACHINEGUN'S BOX NEVER MOVES** in the donor, so its axis and distance are from its shape.
   A real belt-fed gun is also loaded through a feed cover. The mesh has no moving cover, and the
   owner's reload is a box swap.

## Unverified / ESTIMATE, in one place
- **Placement cvars:** all defaults (ofs 0, yaw -90, scale 1).
- **Ejection ports:** both points and both directions. The Chaingun's side is reasoned from the
  belt, not a port cut.
- **MachineGun support:** its x along the tube.
- **Chaingun support:** measured, but the carry handle vs the shroud is a choice to try in hand.
- **Muzzle choice:** the Chaingun's is the top barrel (where FU flashes), not the cluster axis.
- **Nothing in-game:** no game launch, no build.
