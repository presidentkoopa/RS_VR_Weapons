# Flamer cards: the Flamer (main hand) and the Flamethrower (off hand)

2026-09-13, measurement-and-assets helper for the weapons lane. Nothing here is wired: no WMCARD,
MODELDEF, CVARINFO, MENUDEF, SNDINFO or zscript edit. The lead copies the blocks below into place.

Both picks **animate a canister**, so both reload (the owner: "assume it doesn't reload unless the
models animate"). Every number was measured, and every part was rendered and looked at, unless the
line says ESTIMATE.

- **Picked:** RS_ModelSwapper `MS_AE_Flamer` and Force Unleashed's incinerator.
- **Not picked:** `MS_BD_Flamethrower2` animates fire only, with no canister motion. FU heatwave was
  not examined, since neither pick failed.
- **Licence/credit:** the AE mesh's is unrecorded, so flag it before anything ships. Force Unleashed
  was cleared by the owner (commit 6c9a00f).

Scripts, text output and renders live in the session scratchpad
`...\scratchpad\flamer\` (named `SPF` below):
- surveys: `ae_survey.py`, `ae_zoom.py`, `fu_survey.py`, `fu_zoom.py`, `fu_scan.py`, each with a `.txt`
- builds: `ae_build.py`, `fu_build.py`
- renders: `ae\`, `fu\`, `wm_renders\`

Renders are three-view wireframes from `RS_ModelSwapper/tools_md3_render.py`: black is the first pose,
blue the second or the highlighted part.

---

## 1. FLAMER: main hand

### Source
- **Mesh:** `E:\DOOMWork\RS_ModelSwapper\models\hud\AE_Flamer\m260b.md3` + `m260b.png`, 20 frames.
- **MODELDEF:** block `MS_AE_Flamer`, `Scale -1.1 1.1 1.1`, `Offset -0.378 -62.450 -4.043`.
- **Rest frame 0:** the canister is seated and the gun is still. Frames 1-3 recoil (0.59 up, about 1°).
  Frames 10-18 tilt the whole gun 20° for the reload.
- **Scale:** 1.1 x 0.34 = **0.374 map units per model unit**.

### Built (`models/vanilla/flamers/Flamer/`)
- **`flamer_wm.md3`** is frame 0 written as its only frame, same units and origin, so the Offset
  carries over verbatim. Written by `wm_split.py` (spec `SPF\spec_flamer.json`), 3436/3436 verts,
  3338/3338 tris, worst vertex error 0.00000. Surfaces:

  | Surface | Taken from | Verts |
  |---|---|---|
  | `body` | m260b, minus islands 59-72 | 3141 |
  | `pilotflame` | m260b islands 59-72 | 84 |
  | `canister` | m260b_canister | 174 |
  | `trigger` | m260b_trigger | 37 |

- **`flamer.png`** is `m260b.png` copied (800555 bytes).
- **`wm_flamer_can.md3`** is the canister lifted out and re-origined on its centroid. Its pull axis is
  already -z, so it stays upright with no turn. 10.73 x 10.73 x 28.27; worst vertex error against the
  gun's canister 0.006 (quantisation).

### Measurements (rest frame 0, rigid fit against the body's largest island)
| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | m260b: 76 islands | Every island fixed to the largest (max deviation 0.044 over 20 frames) | — | ≤0.013 | `SPF\wm_renders\flamer_wm_body.png` |
| **canister** | m260b_canister: 2 islands (bottle 118v, middle band 56v) that move as one | Out: **straight along (0, 0, -1)**, a pure slide (0.00°), 19.3 / 65.4 / 120.4 / 166.5 / 185.8 on frames 5-9. In: along (-0.004..-0.015, 0, -1), 11.1 / 3.3 / 0.41 on frames 11-13. Frames 11-19 also carry a 20.0° spin about its own axis (0, 0, -1) through (-9.82, -0.35): cosmetic, not carded | 5-13 | 0.009-0.015 | `SPF\ae\can_f5.png`, `can_f6.png`, `SPF\wm_renders\flamer_wm_canister.png` |
| **canister clearing** | The neck (r 2.18-2.36, z -0.78..0.36) sits in a collar under the body (island 28, r ≥ 2.24, z -0.67..1.34) | **Clear after 1.03 down**: neck top z 0.359 falls below the collar's lower rim z -0.672. Last vertex contact by radial profile at 0.78. Nothing else of the body is over it | — | — | `SPF\ae\zoom_can_neck.png` |
| **trigger** | m260b_trigger, 37v | **16.70° about (0, 1, 0) through (-29.304, 0, -2.348)**. Sign: +16.70 lands the rest centroid on frame 1's (miss 0.000); -16.70 misses by 4.097 | 1-3 | 0.012 | `SPF\wm_renders\flamer_wm_trigger.png` |
| **pilot flame** | Body islands 59-72: fourteen 6-vertex quads, all on texel (60, 29, 8), orange | Static. A small flame from (40.43, 1.68, -4.58) up to (42.37, -0.24, -2.08), at the tip of the pilot burner | — | — | `SPF\ae\zoom_nozzle_flamequads.png` |
| pilot line | Body island 47 (tube under the right side, x 23.9-39.1), 46, and 29 (the burner, bending up to x 42.0) | Static | — | — | `SPF\ae\zoom_nozzle_pilotline.png` |
| nozzle | Body island 4 | Bore level on (y -0.40, z -1.00): z -0.977 at x 32, -1.000 at x 36, inside quantisation. **Orifice ring**: 20 verts at x 36.30-36.31, radius 0.73. A lip under it runs out to x 37.66 (z -2.8..-3.75) | — | — | `SPF\ae\zoom_nozzle_barrel.png` |

- **Grip:** island 0, x -40.4..-14.7.
- **Body underside ahead of the canister:** lowest at x 12-14 (z -8.88), the box under the barrel.

### Class and hand
`WM_Flamer` (the weapon) and `WM_PropFlamer` (the prop), **main hand**.

### MODELDEF
```
// THE FLAMER -- MAIN HAND. RS_ModelSwapper modeldef MS_AE_Flamer, Scale and Offset verbatim.
// Mirrored (Scale x negative). flamer_wm.md3 is m260b.md3's rest frame 0 with its parts
// named, in the same units and origin (_pending/FLAMER_CARDS.md).
Model WM_PropFlamer
{
	Path "models/vanilla/flamers/Flamer"
	Model 0 "flamer_wm.md3"
	Skin 0 "flamer.png"
	Scale -1.1 1.1 1.1
	Offset -0.378 -62.450 -4.043
	PlacementCVars wm_flamer
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

### CVARs (stem `wm_flamer`, all ESTIMATE)
```
// ---- FLAMER, MAIN HAND (renderer) -- defaults ESTIMATE ----------------------
user float wm_flamer_ofs_x   = 0.0;
user float wm_flamer_ofs_y   = 0.0;
user float wm_flamer_ofs_z   = 0.0;
user float wm_flamer_yaw     = -90.0;
user float wm_flamer_pitch   = 0.0;
user float wm_flamer_roll    = 0.0;
user float wm_flamer_scale   = 1.0;
user float wm_flamer_scale_x = 1.0;
user float wm_flamer_scale_y = 1.0;
user float wm_flamer_scale_z = 1.0;
```

### Draft card
```
# ============================================================== FLAMER -- MAIN HAND
# RS_ModelSwapper's MS_AE_Flamer (m260b.md3) as flamer_wm.md3 -- rest frame 0 written as its
# only frame, parts named: body, pilotflame, canister, trigger. Every number measured at frame 0
# against the body's largest island. _pending/FLAMER_CARDS.md.
#
# A MAGAZINE CARD WITH A CANISTER FOR A MAGAZINE: no action part, no cycle, no declared verbs --
# the swap is synthesised from the feed part.
#
# SCALE: MODELDEF Scale 1.1 x 0.34 = 0.374 map units per model unit.
weapon "WM_Flamer"
  type      = flamethrower     # its hand-seat profile (the key landed in c688186)
  hand      = main
  prop      = "WM_PropFlamer"
  model     = "models/vanilla/flamers/Flamer" "flamer_wm.md3"
  skin      = "models/vanilla/flamers/Flamer" "flamer.png"

  # GRAMMAR PENDING (approved, not yet in code): fires straight from the canister's store.
  firesfrom = magazine
  # FALLBACK: `firesfrom = reserve` -- no stores, fires from the player's Cells; also take
  # `role = feed` off the canister part below.
  # GRAMMAR PENDING (approved, not yet in code): a flame throws no brass.
  casing    = none

  # ONE DOOM CELL PACK: 100 cells, 5.7 seconds of flame at FireTics 2 (17.5 a second). ESTIMATE.
  capacity  = 100
  # Its own family: this canister seats only here.
  magfamily = "flamer"

  # The nozzle's orifice ring: 20 vertices at x 36.30-36.31, radius 0.73, centred on the bore
  # (y -0.40, z -1.00). The bore is level: z -0.977 at x 32, -1.000 at x 36.
  muzzle    = 36.31, -0.40, -1.00
  barrel    = 1, 0, 0

  # The loose canister: this gun's own canister surface, lifted out, re-origined on its centroid.
  # Its pull axis is already -z, so it is upright untouched. magscale 0.374 = 1.1 x 0.34.
  magmodel  = "models/vanilla/flamers/Flamer" "wm_flamer_can.md3"
  magskin   = "models/vanilla/flamers/Flamer" "flamer.png"
  magscale  = 0.374
  magcenter = -9.808, -0.488, -10.237

  # The flame's own sound is RS_Ballistics' (rsb/flame/*). The canister takes the Vanilla+
  # plasma rifle's cell foley already in this package's SNDINFO. ESTIMATE choice.
  magoutsound  = "wm/plasma/magout"
  maginsound   = "wm/plasma/magin"
  drysound     = "wm/dry"
  magdropsound = "wm/magdrop"
end

# THE CANISTER. Straight down: a pure slide along (0, 0, -1), frames 5-9 (0.00 degrees, fit
# 0.009), and back in on the same line over 11-13. The donor drops it 185.8, off screen; the
# hand's pull is only until it is free. Its neck sits 1.03 up inside a collar under the body
# (neck top z 0.359, collar rim z -0.672), and nothing else of the body stands over it.
part canister
  role    = feed
  subject = magazine
  take    = no          # out by its button, in by the hand carrying one
  surface = canister
  grab       = -10.03, -0.45, -27.89    # the bottom face's centre
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, 0, -1
    distance = 1.03
    detach   = 0.9
  end
end

# 16.70 degrees about the pin at -29.304, -2.348 (frame 1, fit 0.012). Sign checked: +16.70
# lands the rest centroid within 0.000 of frame 1; -16.70 misses by 4.097. Follows your finger.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 16.70
    pivot   = -29.304, 0, -2.348
  end
end

# THE DONOR'S BAKED PILOT FLAME: fourteen orange quads at the pilot burner's tip. Hidden while
# RSB_Flame.Pilot draws the live one; delete this part to see the baked flame instead.
part pilotflame
  role    = hidden
  surface = pilotflame
end

# ESTIMATE: under the box beneath the barrel (x 12-14, underside z -8.88), well ahead of the
# canister (front edge x -4.52).
part support
  role    = support
  subject = support
  grab       = 12.0, -0.45, -8.5
  grabradius = 3.0
end
```

### For the ballistics lane (Flamer, `_wm` model space)
- **Stream:** `RSB_Flame.Stream("incinerator", owner, hand, nozzleAt, dir, carrierVel)`
  - nozzleAt **(36.31, -0.40, -1.00)**, the orifice ring's centre
  - dir **(1, 0, 0)**
- **Pilot:** `RSB_Flame.Pilot("incinerator", pilotAt, pilotDir)`
  - pilotAt **(40.43, 1.68, -4.58)**, the baked pilot flame's base on the burner tip (burner's front
    end (41.86, 1.86, -4.69))
  - pilotDir **(0.524, -0.519, 0.675)**, the baked flame's own lean from base to tip, up and in toward
    the bore
- **Personality: `incinerator`**, a tight, fast jet. The orifice is small and round (r 0.73 model
  units = 0.27 map units) in a flared head, with a lip under it and a pilot burner lighting it from
  below right.

---

## 2. FLAMETHROWER: off hand

### Source
- **Mesh:** `E:\DOOMWork\_old\doom-force-unleashed_devbuild\models\incinerator\` `flamethrower.md3`
  (18 frames) + `gascan.md3` (7 frames), skin `flamethrower.png`.
- **MODELDEF:** `modeldefs\weapons\incinerator.txt`, class `RLIncinerator`, no-hand block `FLNH`.
  Model 0 is the gun and Model 1 the can in ONE block: `Scale -1.0 1.0 1.0`, `Offset 0.0 -24.0 -10.0`.
  One shared space.
- **Rest:** gun frame 0 + can frame 0 (idle `A`: can seated).
- **Scale:** 1.0 x 0.34 = **0.34 map units per model unit**.

### Built (`models/vanilla/flamers/Flamethrower/`)
- **`flamethrower_wm.md3`** is gun frame 0 and can frame 0 merged into one frame, same units and origin,
  so the Offset carries over verbatim. Written by `SPF\fu_build.py`, 8971/8971 verts, 7750/7750 tris,
  worst vertex error 0.00000, UVs checked. Surfaces:

  | Surface | Taken from | Verts |
  |---|---|---|
  | `body` | flamethrower + flamethrower_bolts + flamethrower.nozzle + flamethrower_valve, all still on every frame | 7780 |
  | `trigger` | flamethrower_trigger | 87 |
  | `lever` | flamethrower_lever | 161 |
  | `canister` | gascan.md3 flamethrower_can | 943 |

  Every source surface already names `flamethrower.png`.
- **`flamethrower.png`** is copied (160146 bytes).
- **`wm_flamethrower_can.md3`** is the canister re-origined on its centroid. Its pull axis is -z (below),
  so it stays as it lies in the gun: along x, 53.98 x 11.84 x 11.77. Worst vertex error 0.006.
  `gascan2.md3` (the donor's loose copy) is the same shape offset (74.225, 0, -7.070) with no turn.
  The extraction was used instead, so magcenter is exact.

### Measurements (rest = gun 0 + can 0)
| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | 4 surfaces, 91 islands | 0.000 vertex motion on all 18 frames | — | — | `SPF\wm_renders\flamethrower_wm_body.png` |
| **canister, donor motion** | gascan `flamethrower_can` 943v, 9 islands. Lies along x under the front housing (x 47.02..101.00, y -5.95..5.89, z -7.00..4.77) | **Twist 70.01° about (1, 0, 0) through (x, 0.005, -0.865)** at frame 4, 35° a frame (6->5->4), no screw travel. Sign: +70.01 lands the centroid (miss 0.000), -70.01 misses 2.570; every vertex within 0.029. Then out **back and down with 8-17° of pitch**: 5.9 / 18.0 / 24.8 from frame 4 on frames 3 / 2 / 1, along (-0.597, 0, -0.802) to (-0.812, 0, -0.584) | can 1-6 (states J-O); 0 at rest, 99 hidden | 0.011-0.013 | `SPF\fu\zoom_can_0_vs_4.png`, `zoom_can_4_vs_1.png`, `SPF\wm_renders\flamethrower_wm_canister.png` |
| **canister seat** | Valve surface (a coupling of discs round y 0, z -1.12, x 41.6-49.4) | At rest the can's rear end sits **2.39 deep over the valve's spigot** (47 valve vertices, x 48.78-49.41, inside the can). The cradle is open underneath | — | — | `SPF\fu\surf_5_flamethrower_valve.png`, `SPF\fu\mouth_inner.png` |
| **canister, card pull** | Body vertices inside the can's hull, slice by slice (`fu_scan.py`), swept in 0.25 steps | See the pull list below | — | — | `SPF\fu_scan.txt` |
| **lever** | flamethrower_lever 161v, 2 islands (hub 107v, arm 54v) on the valve's side plate (y 3.94) | **99.28° about (0, 1, 0) through (45.246, 0, -1.088)**. Sign: +99.28 lands frame 5 (miss 0.000), -99.28 misses 4.440. Swings on 3-5, open 5-14, back 15-17 | 3-16 | 0.010-0.011 | `SPF\fu\zoom_lever_close.png`, `SPF\wm_renders\flamethrower_wm_lever.png` |
| **trigger** | flamethrower_trigger 87v | **1.325 along (-1, 0, 0)**, 0.00° | 1 | 0.006 | `SPF\wm_renders\flamethrower_wm_trigger.png` |
| nozzle | nozzle islands 3, 4 (+10): **twin jets**, faces at x 96.1, centres (y -1.43 / +1.48, z 9.05). A round perforated shroud runs to the mouth at x 104.45 (y ±4.98, z 7.56..14.47). Islands 16, 29-31: **igniter wire**, curving forward to a tip at (99.36, -0.14, 9.04) | Static | — | — | `SPF\fu\mouth_inner.png` |
| off hand | Donor `models\hand\hand2.md3` (same block) | Ready (frame 136): centroid (25.73, -0.48, -8.35), 0.24 from the body underside at (25.60, -0.34, -8.03). The support grip | — | — | `SPF\fu_zoom.txt` |

**The card pull.** Straight slides compared, from the untwisted rest pose:
- **Straight down, untwisted:** last body contact at **4.50** (0.05 steps). Every contact is the valve
  spigot passing through the can's rear end. The lever at rest is never touched.
- **Straight down, twisted:** clears only at 7.75, and later than the untwisted can in every direction
  tried. **So the turn is not needed to get it out.**
- **The donor's back-and-down line:** 15.0, with up to 137 contacts through the valve. It is not used.
- **Forward (+x) 2.5:** unplugs the can off the spigot with no new contact; any direction is then free.

**What the lever is.** The **canister lock lever** on the side of the fuel valve, not a foregrip.
The donor's off hand shows it:
- at the ready pose (hand2 frame 136) the hand is 9.39 away from the lever
- the hand is on the lever as the reload starts (frame 138, 0.41) and throws it
- it works the can (frames 143-149)
- it shuts the lever again (frame 153, 0.13)

At rest the lever hangs down and forward below the gun's +y side (to z -17.4). Open, it lies back
along the underside.

### Class and hand
`WM_Flamethrower` (the weapon) and `WM_PropFlamethrower` (the prop), **off hand**.

### MODELDEF
```
// THE FLAMETHROWER -- OFF HAND. Force Unleashed's incinerator block (Model 0 the gun, Model 1
// the can, one space), Scale and Offset verbatim. Mirrored (Scale x negative).
// flamethrower_wm.md3 is gun frame 0 and can frame 0 merged into one frame with its parts
// named, in the same units and origin (_pending/FLAMER_CARDS.md).
Model WM_PropFlamethrower
{
	Path "models/vanilla/flamers/Flamethrower"
	Model 0 "flamethrower_wm.md3"
	Skin 0 "flamethrower.png"
	Scale -1.0 1.0 1.0
	Offset 0.0 -24.0 -10.0
	PlacementCVars wm_flamethrower
	NOAUTOREVERSE
	FollowOffHand
	FrameIndex WMPR A 0 0
}
```

### CVARs (stem `wm_flamethrower`, all ESTIMATE)
```
// ---- FLAMETHROWER, OFF HAND (renderer) -- defaults ESTIMATE -----------------
user float wm_flamethrower_ofs_x   = 0.0;
user float wm_flamethrower_ofs_y   = 0.0;
user float wm_flamethrower_ofs_z   = 0.0;
user float wm_flamethrower_yaw     = -90.0;
user float wm_flamethrower_pitch   = 0.0;
user float wm_flamethrower_roll    = 0.0;
user float wm_flamethrower_scale   = 1.0;
user float wm_flamethrower_scale_x = 1.0;
user float wm_flamethrower_scale_y = 1.0;
user float wm_flamethrower_scale_z = 1.0;
```

### Draft card
```
# ======================================================== FLAMETHROWER -- OFF HAND
# Force Unleashed's incinerator as flamethrower_wm.md3 -- flamethrower.md3 frame 0 and gascan.md3
# frame 0 (one MODELDEF block, one space) merged into one frame, parts named: body, trigger,
# lever, canister. _pending/FLAMER_CARDS.md.
#
# A MAGAZINE CARD WITH A CANISTER FOR A MAGAZINE: no action part, no cycle. Its one declared verb is
# the canister's swap, latched on the lock lever.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_Flamethrower"
  type      = flamethrower     # its hand-seat profile (the key landed in c688186)
  hand      = off
  prop      = "WM_PropFlamethrower"
  model     = "models/vanilla/flamers/Flamethrower" "flamethrower_wm.md3"
  skin      = "models/vanilla/flamers/Flamethrower" "flamethrower.png"

  # GRAMMAR PENDING (approved, not yet in code): fires straight from the canister's store.
  firesfrom = magazine
  # FALLBACK: `firesfrom = reserve` -- no stores, fires from the player's Cells; also take
  # `role = feed` off the canister part below.
  # GRAMMAR PENDING (approved, not yet in code).
  casing    = none

  # ONE DOOM CELL PACK, as the Flamer's: 100 cells, 5.7 seconds at FireTics 2. ESTIMATE. (Its
  # tank is about 1.35x the Flamer's bottle in map-unit volume, if the two should differ.)
  capacity  = 100
  magfamily = "flamethrower"

  # TWIN JETS inside a round shroud: their faces are at x 96.1, centres y -1.43 / +1.48, z 9.05;
  # the shroud's mouth is x 104.45. The muzzle is the mouth plane on the jets' line, between them.
  muzzle    = 104.45, 0.03, 9.05
  barrel    = 1, 0, 0

  # The loose canister: this gun's own canister surface, lifted out, re-origined on its centroid.
  # Its pull axis is -z, so it lies as it lies in the gun, along x. magscale 0.34 = 1.0 x 0.34.
  magmodel  = "models/vanilla/flamers/Flamethrower" "wm_flamethrower_can.md3"
  magskin   = "models/vanilla/flamers/Flamethrower" "flamethrower.png"
  magscale  = 0.34
  magcenter = 58.803, 1.343, -1.124

  # As the Flamer's: the flame is RS_Ballistics'; the canister takes the plasma cell foley. ESTIMATE.
  magoutsound  = "wm/plasma/magout"
  maginsound   = "wm/plasma/magin"
  drysound     = "wm/dry"
  magdropsound = "wm/magdrop"
end

# THE CANISTER, STRAIGHT DOWN. It lies along x under the front housing in a cradle open below, its
# rear end 2.39 deep over the valve's spigot. Pulled straight down untwisted, the last body
# contact is at 4.50 and every contact is that spigot; the lever at rest is never in the way.
# The donor twists it 70.01 degrees first, then draws it back and down -- that line runs through
# the valve (15.0 before it is clear), and the twisted can clears later than the untwisted one on
# every line tried, so the card pulls it straight and does not turn it.
part canister
  role    = feed
  subject = magazine
  take    = no          # out by its button, in by the hand carrying one
  surface = canister
  # Under the tank where the donor's off hand holds it seated (hand2.md3 frame 149, x 61.5); z is
  # the tank's underside, y its middle. PART ESTIMATE.
  grab       = 61.5, 0.0, -7.0
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 0, 0, -1
    distance = 4.6
    detach   = 0.9
  end
  # OPTIONAL, the donor's lock twist, after the drop -- same end pose as the donor (twist, then
  # drop), since the pin rides the slide. 70.01 degrees about +x, sign checked (+70.01 lands frame
  # 4, -70.01 misses 2.570). Not in the card because it changes nothing about getting it out, and
  # the drop/well code reads only `dof` (gap F2).
  # dof2
  #   kind    = hinge
  #   axis    = 1, 0, 0
  #   degrees = 70.01
  #   pivot   = 58.803, 0.005, -5.465
  #   split   = 0.8
  # end
end

# A sliding trigger: 1.325 along -x at frame 1, fit 0.006 -- follows your finger.
part trigger
  role    = trigger
  surface = trigger
  dof
    kind     = slide
    axis     = -1, 0, 0
    distance = 1.325
  end
end

# WHERE THE DONOR'S OFF HAND HOLDS IT: hand2.md3 frame 136 (ready) sits 0.24 from the underside
# at (25.60, -0.34, -8.03). Measured.
part support
  role    = support
  subject = support
  grab       = 25.6, -0.34, -8.0
  grabradius = 3.0
end

# THE LOCK LEVER LATCHES THE CANISTER (F3, RS_VR_Reload.pk3 09-13 16:18). The donor's off hand
# throws it before it works the can and shuts it after (hand2.md3 frames 138 / 153). Measured:
# 99.28 degrees about (0, 1, 0) through (45.246, 0, -1.088), sign checked (+99.28 lands frame 5,
# -99.28 misses 4.440). A lock you throw and leave: it stays where the hand leaves it.
part lever
  surface = lever
  # The arm's lower end, hanging below the valve plate: its lowest 12 vertices' centroid (the
  # arm is island 1, 54v, down to z -17.39; the hub is island 0 on the pivot).
  grab       = 51.04, 6.07, -17.06
  grabradius = 2.5                     # ESTIMATE
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 99.28
    pivot   = 45.246, 0, -1.088
  end
end

# THE CANISTER'S SWAP, DECLARED so it can take the latch, with the synthesised swap's own numbers
# (verb.zs SynthSwap: magwell, detachat = the dof's 0.9, pullout 0.97, button, no hand take).
# Until the lever is thrown past 0.8 the drop button, seating and a hand pull-out are refused.
swap magwell
  part     = canister
  store    = mag
  detachat = 0.9
  pullout  = 0.97
  button   = yes
  handtake = no
  latch    = lever
  latchat  = 0.8
end
```

### For the ballistics lane (Flamethrower, `_wm` model space)
- **Stream:** `RSB_Flame.Stream("napalm", owner, hand, nozzleAt, dir, carrierVel)`
  - nozzleAt **(104.45, 0.03, 9.05)**, the mouth plane on the twin jets' line
  - dir **(1, 0, 0)**
  - Alternates: the jets' faces (96.1, -1.43 / +1.48, 9.05); the shroud mouth's middle
    (104.45, 0.03, 11.0)
- **Pilot:** `RSB_Flame.Pilot("napalm", pilotAt, pilotDir)`
  - pilotAt **(99.36, -0.14, 9.04)**, the igniter wire's tip in front of the jets. No baked flame on
    this mesh.
  - pilotDir **(1, 0, 0)**
- **Personality: `napalm`**, a wide spray. Two jets fire side by side (2.9 model units apart) inside
  a wide round shroud (10 across = 3.4 map units), with an igniter across their front.

---

## Shared

**Class lines** (the lead writes them): `AmmoType1 Cell`, `WM_Gun.FullAuto true`, `WM_Gun.FireTics 2`,
`WM_Gun.ShotDamage 11, 17`, `WM_Gun.ShotSpread 1.0, 0.33`, on both.

The flame hooks, per gun, with that gun's profile and points:
- `override void FireHeld(int heldTics)` calls `RSB_Flame.Stream(profile, owner, hand, nozzleAt, dir, carrierVel)` every held tic.
- `override void FireReleased(int heldTics)` calls `RSB_Flame.StopStream(owner, hand)`.
- `RSB_Flame.Pilot(profile, pilotAt, pilotDir)` runs every idle tic.

nozzleAt, dir, pilotAt and pilotDir are MD3 model space and need the rig's conversion to world.
The first brief's `WM_Gun.ShotClass` (flame projectile, TBD) and `WM_Gun.RoundsPerShot 1` are listed
only in case the lead's class still wants them.

**Capacity:** 100 each, one Doom cell pack. At RS_Main's rate of a shot about every 2 tics (17.5
cells a second) that is 5.7 seconds of flame a canister. ESTIMATE.

## Grammar and code gaps

- **F1: GRAMMAR PENDING (approved, not yet in code).**
  - `firesfrom = magazine | reserve` (fires from the canister: G1) and `casing = none`.
  - The `FireHeld` / `FireReleased` hooks (G8).
  - `RSB_Flame.Stream / StopStream / Pilot` still waits on the main lane's compile check.
- **F2: the drop and well code read only a feed part's `dof`.**
  - `WM_Rig` (rig.zs 1318-1328) spawns a dropped magazine at `magCenter + dof.axis * v * dof.distance`
    and throws it along `dof.axis`.
  - `WellPointRaw` (rig.zs 711) puts the well at `grab + dof.axis * dof.distance`.
  - With a hinge first stage (the donor's twist-then-pull), a dropped can would spawn seated and fly
    along the pin, and the well would sit on the grab. With any `dof2`, `v * dof.distance` also ignores
    the split.
  - This is why the Flamethrower card is one straight slide and its twist is a commented option.
- **F3: a latch on a swap. SETTLED (uzdxrema-11, RS_VR_Reload.pk3 16:18:15):** `latch` / `latchat` on
  open and swap.
  - The Flamethrower card now carries `part lever` (grab at the arm's lower end, 51.04, 6.07, -17.06,
    radius ESTIMATE).
  - It declares `swap magwell` with the synthesised swap's own numbers, plus `latch = lever`,
    `latchat = 0.8`.
  - The lever stays where the hand leaves it, as a lock does.
- **F4: the Flamer's pull is short.** 1.03 model units is 0.39 map units: the canister is only plugged
  in by its neck. If that reads as nothing in the hand, the pistol convention (its own length, 28.27 =
  10.6 map units) is the alternative. Lead or owner call.
- **F5: no round.** A flamer card has no `roundmodel`; whether the system wants one on a magazine
  card is unchecked.
- **F6: the Flamethrower's loose can is big.** 53.98 x 11.84 units = 18.4 x 4.0 map units in the hand.
  The held-magazine sliders will need it.
- **F7: the Flamer's baked pilot flame** is hidden in the card on the assumption the live
  `RSB_Flame.Pilot` replaces it.
- **ESTIMATE, not measured:**
  - both support grab on the Flamer; the Flamethrower's canister grab z/y
  - capacities and sound choices
  - every cvar default
  - main-hand grip seats: none measured; the sliders place them

## The ballistics lane's final flame API (2026-09-13; written, waiting on a compile check)

```
RSB_Flame.Stream(String profile, Actor owner, int hand, Vector3 nozzleAt, Vector3 dir, Vector3 carrierVel,
                 double intensity = 1.0, double fuelShare = 1.0, Vector3 acrossAxis = (0,0,0))
RSB_Flame.StopStream(Actor owner, int hand)
RSB_Flame.Pilot(String profile, Vector3 pilotAt, Vector3 pilotDir)
```

- **WM_Flamer:** profile `incinerator`.
  - Stream from (36.31, -0.40, -1.00) along (1, 0, 0).
  - Pilot every idle tic at (40.43, 1.68, -4.58) along (0.524, -0.519, 0.675).
  - The baked `pilotflame` stays hidden, as the ballistics lane agrees: the live pilot follows
    the effects settings.
- **WM_Flamethrower:** profile `napalm`, twin jets built into the profile (`jets = 2, 1.0, 3`: 1.0
  map unit apart, 3° splay).
  - Stream from the shroud mouth (104.45, 0.03, 9.05) along (1, 0, 0).
  - **acrossAxis** = the gun's model +y as a world DIRECTION (the rig's direction transform,
    not the point transform), so the jets stay side by side when the wrist rolls.
  - Pilot at (99.36, -0.14, 9.04) along (1, 0, 0).
- **FireHeld:** Stream every tic (every 2 works; every tic tracks the hand better). `hand` is the
  rig's 0 or 1; 9 and 20-21 are taken.
- **FireReleased:** StopStream, which throws a short flame-out gout unless the canister is empty,
  and plays rsb/flame/stop.
- **Sputter:** pass `fuelShare = cells / capacity`. Below 15% the jet coughs.
- **Damage stays ours.** The look runs every tic, independent of the 2-tic shots.
- **Needed from the reload system for the hooks:** a model-to-world POINT transform for nozzleAt
  and pilotAt, a model-to-world DIRECTION transform for dir, pilotDir and acrossAxis, and the
  feed store's count for fuelShare.
