# Railgun cards — draft

Measured 2026-09-13 by the railgun helper. Read-only on RS_ModelSwapper; nothing shared in
RS_VR_Weapons was edited. `SP` below is this session's scratchpad
(`C:\Users\Command\AppData\Local\Temp\claude\E--DOOMWork-RS-VR-Weapons\1c739cbc-eb97-4b35-a0d1-aa9c4e697297\scratchpad`).

**Licence/credit: unrecorded.** Flag before anything ships.

## The pick: ONE railgun

There is one real railgun mesh. "If we only have one then so be it."

| Candidate | Result |
|---|---|
| **MS_BD_RailGun**, `models/hud/RailGun/RailGun.md3` (current) | **Used.** The gun below. |
| MS_BD_SnipaRG @6f23e1b, `models/bd21/Snipa/SnipaRG.md3` (and the copy in `bd21/RailGun/`) | **No gun.** Two surfaces of 4 vertices each (two flat planes), 1 frame. `Snipa.md3` is the same. |
| MS_BD_RailGun @6f23e1b `bd21/RailGun/RailGun.md3`, and MS_GH_Railgun `weapons/hud/RS_GH_Weapon/RS_GH_Railgun/RailGun.md3` | **Same gun.** The two are byte-identical. The current mesh is exactly that mesh + (-52.516, -0.141, -2.750), with identical UVs and triangles and the same skin (md5 78545b84…). It was re-origined in 315d09f. |
| Selaco's railgun (history `renders/selaco/MS_SEL_Railgun.png`) | Commercial asset. Not used, not opened. |
| Force Unleashed | No railgun in `SP\fu_survey.txt`. |
| MS_BD_Unmaker, `models/hud/Unmaker/Unmaker.md3` | **Noted only.** 16 frames, rest 4, filed under `bfg` by ModelSwapper. The survey found only two small moving parts: 274v turning 3.4° on frames 0 and 3, and 249v turning 20.3° on frames 0-3 and 8-10. There is no separable magazine. |

---

## Railgun: RS_ModelSwapper `models/hud/RailGun/RailGun.md3`

- **MODELDEF** `MS_BD_RailGun`:
  - `Scale -1.0 1.0 1.0`
  - `Offset -0.141 -52.516 -2.250`
  - `FrameIndex PLSG A 0 3`, so the **rest frame is 3**
- **Clips** (`RS_ForeignAnim.zs`):
  - ready/select 3
  - sprint 2
  - fire 3-10
  - **reload 11-34**
  - **ads 3 + 36**
- 37 frames, 5 surfaces:
  - Scope 2672v
  - ScopeGlass 18v
  - Gun 4660v
  - Trigger 46v
  - Mag-Bat 156v
- None of the surfaces carries a shader name. `Skin 0` covers them, as in ModelSwapper.
- **Size:** 152.5 x 11.9 x 32.2 model units. At Scale 1.0 x 0.34 that is **51.9 map units** from stock to muzzle.
- **Shape** (renders): a long rifle with a shoulder stock, a raked pistol grip and a ring trigger guard, a scope on top, a cell pack under the receiver, a handguard under the barrel, and top and bottom rails with coil rings out to the muzzle.

**Frame 36 is the ads clip, not the reload.** A first split over all 37 frames reported ~35 Scope and Gun
pieces moving 4.6-7.0 along -z on frame 36 only, with poor fits (0.04-0.46): the aim pose deforms.
Re-split on a copy holding frames 0-35 only (`SP\railgun\RailGun_f0_35.md3`, worst vertex error 0), with the body
seeded on the Gun surface, **exactly two parts move**. Every other island is fixed to the body.

### Measurements (rest frame 3, against Gun island 0)

| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | Gun 4660v / 83 isl, Scope 2672v / 42 isl, ScopeGlass 18v / 1 isl | fixed on every frame 0-35 | — | — | `SP\railgun\wm_renders\railgun_wm_body.png`, `railgun_wm_scope.png` |
| **magazine** | Mag-Bat 156v / **3 islands**: the pack (100v) and two side contacts (28v each, y ±3.1, z -8.57), all moving together | **29.99 straight along (0, 0, -1)** at frame 16, 0.02°. Every moving frame is on the same axis (frames 12-16 out, 17-29 back) | 12-29 | 0.010-0.014 | `SP\ww2_split\RG_f0_35\part1.png`, `SP\railgun\renders\rg_mag_well_f14.png`, `SP\railgun\wm_renders\railgun_wm_magazine.png` |
| **trigger** | Trigger 46v / 1 island, inside the ring guard | **22.85° about (0, 1, 0) through (-18.554, 0, -5.441)**, full at frame 4, easing back over frames 5-9 | 4-9 | 0.008 | `SP\ww2_split\RG_f0_35\part2.png`, `SP\railgun\renders\rg_trigger_f4.png` |
| (ads, excluded) | ~35 Scope and Gun pieces | 4.6-7.0 along -z, deforming | 36 only | 0.04-0.46 | `SP\ww2_split\RG_body_gun\part1.png` |

**Trigger sign check.** Rotating the rest centroid (-18.637, -0.092, -7.447) by +22.85° lands 0.0000 from the
frame-4 centroid. By -22.85° it misses by 1.559.

**Muzzle and barrel.**
- The Gun surface's front face is at x 86.22: 76 verts, y -2.58..2.36, z -5.36..1.02, bounding-box centre y -0.109, z -2.172.
- Cross-sections at x 40, 50, 60 and 80 all centre on y -0.09..-0.11, z -2.17..-2.18.
- The top and bottom rails (Gun islands 15/16, z 3.17 and -7.70) straddle z -2.27.
- So **muzzle = 86.22, -0.11, -2.17** and **barrel = 1, 0, 0**.

**Magazine.**
- **Vertex centroid (magcenter):** -2.481, -0.098, -10.079. This is the SMG's convention, checked: its card magcenter is its magazine surface's vertex centroid.
- **Size:** 14.69 x 7.61 x 10.03. The y figure includes the contacts; the pack alone is 5.09 wide.
- **Floor:** 27 verts at z -16.22, centroid **-0.65, -0.19, -16.22**.
- **Top:** z -6.19.
- **The well:** the pack hangs under the receiver between the trigger-guard block behind it (Gun island 2, ends at x -9.08, down to z -10.41) and the handguard in front (Gun island 3, starts at x 4.72, down to z -10.56). It sits **4.37 deep** between them. No body geometry flanks its sides: 0 body verts with |y| ≥ 2.4 inside its x and z span.
- **Card distance = 10.03**, its full length along the axis, the SMG's and Tec9's convention. The measured clearance, 4.37, is the alternative if the pull feels long.

**Support.** **ESTIMATE** where the second hand goes. The point is measured: the centroid of the handguard's bottom strip
(Gun island 19, x 7.66..36.16, z -11.80..-10.56), **21.91, -0.09, -11.28**.

**Hands = 2.** A shoulder stock, a pistol grip and a handguard, 51.9 map units long: the model clearly needs two hands.

### Files written (`E:\DOOMWork\RS_VR_Weapons\models\railguns\Railgun\`)

- **`railgun_wm.md3`**, from `SP\railgun\spec_railgun.json` through `wm_split.py`:
  - Rest frame 3 as its only frame. Surfaces `body` (Gun), `scope` (Scope), `scopeglass` (ScopeGlass), `magazine` (Mag-Bat, all 3 islands) and `trigger` (Trigger).
  - **7552/7552 verts, 5733/5733 tris, worst vertex error 0.00000.** `md3.py` self-check OK.
  - Each surface is rendered alone over the gun in `SP\railgun\wm_renders\`.
  - The scope glass is kept as its own surface so a glass skin or style can find it later. Nothing reads it now.
- **`wm_railgun_mag.md3`**: `md3_write.extract` of `magazine`, re-origined on its centroid, skin name `railgun.png`.
  - The insert axis (0, 0, -1) is already vertical, so no turn was needed.
  - 156v / 104 tris, size 14.69 x 7.61 x 10.03, half-thinnest 3.80.
  - Against (wm magazine - centroid): worst 0.0045, UVs and triangles identical.
  - Put back at magcenter it lies exactly over the gun's magazine (`SP\railgun\renders\rg_loose_mag_back_at_magcenter.png`).
- **`railgun.png`**: `RailGun.png` copied, md5 identical.

Scripts: `SP\railgun\rg_survey.py`, `rg_measure.py`, `rg_mag.py`. Output: `SP\railgun\survey.txt`, `measure.txt`.

### Classes and hand

- `WM_Railgun` / `WM_PropRailgun`, **main hand**.
- Class lines, the lead's to write:
  - `AmmoType1 Cell`
  - `WM_Gun.ShotRail true` — **GRAMMAR PENDING (approved, not yet in code)**
  - `WM_Gun.RoundsPerShot 10` — **GRAMMAR PENDING (approved, not yet in code)**
  - `WM_Gun.ShotDamage 464, 688` (RS_Main's railgun at Uncommon)
  - `WM_Gun.FireTics 18`
- `class WM_PropRailgun : WM_Prop {}`

### MODELDEF

```
// THE RAILGUN. RS_ModelSwapper's MS_BD_RailGun (models/hud/RailGun) as railgun_wm.md3:
// its rest frame 3 as its only frame, in the same units and origin, so the Offset
// carries over and the frame is 0 (RAILGUN_CARDS.md).
Model WM_PropRailgun
{
	Path "models/vanilla/railguns/Railgun"
	Model 0 "railgun_wm.md3"
	Skin 0 "railgun.png"
	Scale -1.0 1.0 1.0
	Offset -0.141 -52.516 -2.250
	PlacementCVars wm_railgun
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

### CVARINFO: stem `wm_railgun`, every default an ESTIMATE

```
// Railgun placement. ESTIMATES: not yet seen on a controller.
user float wm_railgun_ofs_x   = 0.0;
user float wm_railgun_ofs_y   = 0.0;
user float wm_railgun_ofs_z   = 0.0;
user float wm_railgun_yaw     = -90.0;
user float wm_railgun_pitch   = 0.0;
user float wm_railgun_roll    = 0.0;
user float wm_railgun_scale   = 1.0;
user float wm_railgun_scale_x = 1.0;
user float wm_railgun_scale_y = 1.0;
user float wm_railgun_scale_z = 1.0;
```

### Draft card

```
# ============================================================== RAILGUN -- MAIN HAND
# RS_ModelSwapper's RailGun.md3 (MS_BD_RailGun) as railgun_wm.md3: surfaces body, scope,
# scopeglass, magazine, trigger. Every number measured at the source's rest frame 3
# against the Gun surface's largest island; frame 36 (the ads clip) excluded.
# _pending/RAILGUN_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_Railgun"
  # Its hand seats: the railgun profile (wm_hs_railgun_*), landed in c688186.
  type      = railgun
  hand      = main
  # GRAMMAR PENDING (approved, not yet in code): a shoulder stock, a pistol grip and a
  # handguard, 51.9 map units long.
  hands     = 2
  prop      = "WM_PropRailgun"
  model     = "models/vanilla/railguns/Railgun" "railgun_wm.md3"
  skin      = "models/vanilla/railguns/Railgun" "railgun.png"

  # RS_Main's railgun: 50 cells, 10 a shot, 5 shots a magazine.
  capacity  = 50
  magfamily = "rail"

  # GRAMMAR PENDING (approved, not yet in code): no chamber and no rack -- the shot
  # draws straight from the magazine. No role = action part, no cycle verb.
  firesfrom = magazine
  # GRAMMAR PENDING (approved, not yet in code): nothing leaves the gun on a shot.
  casing    = none

  # The barrel's front face (x 86.22); the bore holds y -0.11, z -2.17 from x 40 to it.
  muzzle    = 86.22, -0.11, -2.17
  barrel    = 1, 0, 0

  # No ejectport, ejectdir or roundmodel: no brass and no loose round.

  # The loose magazine: its magazine surface lifted out and re-origined on its
  # centroid; it already drops straight down, so it stands as it sat.
  magmodel  = "models/vanilla/railguns/Railgun" "wm_railgun_mag.md3"
  magskin   = "models/vanilla/railguns/Railgun" "railgun.png"
  magscale  = 0.34
  magcenter = -2.481, -0.098, -10.079

  # SNDINFO's railgun set: the Vanilla+ plasma rifle's rail-beam shot and its cell foley.
  firesound      = "wm/rail/fire"
  drysound       = "wm/dry"
  magoutsound    = "wm/rail/magout"
  maginsound     = "wm/rail/magin"
  magdropsound   = "wm/magdrop"
end

# THE MAGAZINE: a cell pack and its two side contacts, one surface of three islands.
# 29.99 straight down (0, 0, -1) at frame 16, 0.02 degrees, fit 0.013; the same axis
# on every frame 12-29. 10.03 long along it; it sits 4.37 deep between the trigger
# guard and the handguard. The drop button and seating key on this part, and the swap
# is synthesised from it: no verbs declared.
part magazine
  role    = feed
  subject = magazine
  take    = no
  surface = magazine
  grab       = -0.65, -0.19, -16.22   # the floor of the pack
  grabradius = 3.0                    # ESTIMATE, the SMG's
  dof
    kind     = slide
    axis     = 0, 0, -1
    distance = 10.03
    detach   = 0.9                    # ESTIMATE, the SMG's
  end
end

# 22.85 degrees about the pin at -18.554, -5.441 (frame 4, fit 0.008). Sign checked:
# +22.85 lands its rest centroid on frame 4's (0.0000); -22.85 misses by 1.56.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 22.85
    pivot   = -18.554, 0, -5.441
  end
end

# The second hand. ESTIMATE: where the hand goes. The point is the centroid of the
# handguard's bottom strip (body island 19, x 7.66..36.16).
part support
  role    = support
  subject = support
  grab       = 21.91, -0.09, -11.28
  grabradius = 3.0
end
```

### Grammar and gaps

- **GRAMMAR PENDING (approved, not yet in code):**
  - `firesfrom = magazine`
  - `casing = none`
  - `hands = 2`: none of the three is in `RS_VR_Reload/zscript/wm/parser.zs` today, so today's parser refuses the card at the first of them.
  - `WM_Gun.ShotRail`
  - `WM_Gun.RoundsPerShot`
- **A partial magazine: settled by the reload lane.** A shot needs a full RoundsPerShot, so with 1-9 cells left it dry-clicks ("magazine has N, a shot needs M"), the same as the BFG under 40. Drop the magazine and seat a fresh one.
- **`hands = 2`: confirmed by the reload lane.** Keep the support grip under the handguard.
- **ESTIMATES:**
  - support grab point
  - all grab radii
  - magazine `detach`
  - every placement cvar default
- **Magazine distance:** 10.03 (its length) against the measured 4.37 clearance. The owner or lane chooses on feel.
- **Unverified in game:** placement, size (51.9 map units long at scale 1), and that the shaderless surfaces take `Skin 0` on the prop as they do in ModelSwapper.
