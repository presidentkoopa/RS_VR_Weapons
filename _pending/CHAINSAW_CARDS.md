# Chainsaw cards — draft

Measured 2026-09-13 by the chainsaw helper. Read-only on RS_ModelSwapper and `_old`; nothing shared in
RS_VR_Weapons was edited. `SP` below is this session's scratchpad
(`C:\Users\Command\AppData\Local\Temp\claude\E--DOOMWork-RS-VR-Weapons\1c739cbc-eb97-4b35-a0d1-aa9c4e697297\scratchpad`).

**Licence/credit: unrecorded** for the ModelSwapper saw. The Force Unleashed saw is from Ermac's mod, which the owner cleared.

## The pick: TWO chainsaws

| Candidate | Result |
|---|---|
| **MS_Chainsaw**, RS_ModelSwapper `models/hud/Chainsaw/chainsaw.md3` | **Used: `WM_Chainsaw`, main hand.** It has a real **ripcord**, render-verified: a T-grip pulled out on a cord during the donor's select clip. |
| **Force Unleashed chainsaw**, `_old/doom-force-unleashed_devbuild/models/chainsaw/` | **Used: `WM_ChainsawHeavy`, off hand.** The simple model: a static mesh with a separate trigger piece, and its chain as its own mesh in two poses. It is the larger saw (34.2 map units against 24.4). |
| MS_RC_Chainsaw, RS_ModelSwapper `models/hud/RC_Chainsaw/chainsaw.md3` | **Not a chainsaw.** It is a flat toothed **disc** saw (see "Not picked"). |
| History saws (`bd21/Chain_saw` @198c0b1, the 6-frame `Saw.md3` @2f749f8) | Not needed, not extracted. |

---

## Chainsaw (main hand): RS_ModelSwapper `models/hud/Chainsaw/chainsaw.md3`

- **MODELDEF** `MS_Chainsaw`:
  - `Scale 1.35 1.35 1.35`. **Not mirrored**, unlike most ModelSwapper guns; kept verbatim.
  - `Offset -2.468 -45.120 -15.378`
  - `FrameIndex SAWG A 0 13`, so the **rest frame is 13**
- **Clips** (`RS_ForeignAnim.zs`):
  - select 1-5 (**the ripcord pull**)
  - fire 6,7,8,9,10,11,12,7
  - ready 13@4, 14@4
  - deselect 11
- **Mesh:** 16 frames, one surface `Cube.020`, 1028v / 1250 tris / **28 islands**, shader name `saw`. `Skin 0` covers it, as in ModelSwapper.
- **Size at rest:** 53.1 x 16.8 x 24.5 model units. At 1.35 x 0.34 = 0.459 that is **24.4 map units** from the rear handle to the bar's nose.
- **Shape** (`SP\chainsaw\renders\ms_islands_f13.png`, `ms_isl1_context.png`, `ms_isl2_context.png`, `ms_isl3_context.png`):
  - engine body
  - a wrap-round front handle (islands 1 + 2)
  - a rear handle loop (island 3)
  - a clutch cover
  - the bar, tilted up 17°, with the chain teeth round its edge
  - a T-grip on the engine's -y side

### Measurements (rest frame 13, against Cube.020 island 0)

Island numbers are `islands_of()` per surface, largest first, as `wm_split.py` numbers them.

| Part | Surface / islands | Motion | Frames | Fit | Render |
|---|---|---|---|---|---|
| body | islands 0-8, 834v (the bar is island 5) | fixed on all 16 frames (≤ 0.006) | — | body self-fit ≤ 0.011 | `SP\chainsaw\wm_renders\chainsaw_wm_body.png` |
| **ripcord** | **island 9**, 18v, a T-grip at y -7.11..-5.19 (the body wall is at y -6.80) | **9.864 along (-0.433, 0.001, 0.901)** at frame 2, turning **16.17° about (-0.791, -0.585, -0.177)** through its own centroid. Frames 1 / 3 / 4: 4.934 / 7.306 / 2.555, all on the same axis and turn per unit of pull. | 1-4 (out 1-2, back 3-4) | rigid 0.009-0.017; as a pure slide 0.416 | `SP\chainsaw\renders\ms_ripcord_f1.png`..`f4.png`, **`ms_ripcord_zoom_f2.png`**, `SP\chainsaw\wm_renders\chainsaw_wm_ripcord.png` |
| **cord** | **island 27**, 8v | **Stretches.** `_wm` cord v0-3 (source 708-711) ride the grip, ≤ 0.012 off its motion. v4-7 (source 712-715) stay on the body, ≤ 0.016. Its length is 1.82 at rest and 6.68 / 11.59 / 9.04 / 4.31 on frames 1-4. | 1-4 | not rigid (4.885) | `ms_ripcord_zoom_f2.png`, `SP\chainsaw\wm_renders\chainsaw_wm_cord.png` |
| **chain** | **islands 10-26**, 168v: 10-13 the top run, 14-17 the bottom run, 18-26 round the nose | **Two poses.** The rest pose, and a second pose on frames 0-6, 8 and 10: the top run -0.716 along the bar, the bottom run +0.755, the nose sections turned about 10° about (0, -1, 0) through about (28.7, 2.03, 5.6). The teeth are about 7.4 apart, so the flip reads as a running chain. | fire 6-12 alternate | runs 0.006-0.010; nose group 0.062 | `SP\chainsaw\renders\ms_chain_f3.png`, `ms_chain_nose_zoom_f3.png`, `SP\chainsaw\wm_renders\chainsaw_wm_chain.png` |
| bar | island 5, 28v (in `body`) | fixed. Long axis **(0.9557, 0, 0.2944)**, 17.12° up, 33.61 long | — | — | `ms_islands_f13.png` |
| trigger | **none** | No island moves on the fire frames except the chain: the trigger is fused into the body. | — | — | — |
| handles | island 1 + 2 wrap-round front handle; island 3 rear handle loop | fixed | — | — | `ms_isl1_context.png`, `ms_isl2_context.png`, `ms_isl3_context.png` |

**The ripcord is real.** In `ms_ripcord_zoom_f2.png` the T-grip sits against the housing at rest (black). At frame 2 it is out, up and back (blue), with the cord drawn as a line from the housing to it.

**Sign check, the card's own motion.** `rig.zs` moves a twisting slide as `pivot + Rotate(m - pivot, twistaxis, u * twist) + axis * (u * distance)`. With pivot = the grip's rest centroid (-7.515, -6.255, -2.464):

| Frame | u | Worst vertex miss, +twist | Worst vertex miss, -twist |
|---|---|---|---|
| 2 | 1 | 0.014 | 1.230 |
| 1 | 0.5 | 0.029 | 0.616 |
| 3 | 0.741 | 0.025 | 0.912 |
| 4 | 0.259 | 0.025 | 0.319 |

The motion is linear in the pull. A hinge reading of the same fit, pin at (-19.30, 27.58, -4.91), misses by 1.80 at +16.17° and 19.29 at -16.17°: it is not a pin, it is a slide that turns.

**Muzzle and reach.**
- The bar's centre line runs from **(1.007, 2.031, -3.707)** at its rear end to **(33.753, 2.031, 6.382)**, the front-most of bar and chain along the axis.
- The teeth at the nose centre on (33.44, 2.02, 6.48).
- The exposed chain starts at x 1.44.
- **Reach 33.61 model units = 15.4 map units.**

**Grip points** (measured points; where the hands go is an ESTIMATE):
- **Main hand:** the rear loop's top run. Its z 6..9 band centroid is (-11.62, 1.81, 7.05) and its top (z > 8.58) centroid is (-11.11, 2.23, 9.65), for the placement sphere.
- **Support:** the front handle's top bar (z > 9, y -8.52..6.16), centroid **(-1.49, -1.16, 10.04)**.
- **Ripcord grab:** the T-grip's centroid **(-7.52, -6.26, -2.46)**.

### Files written (`E:\DOOMWork\RS_VR_Weapons\models\chainsaws\Chainsaw\`)

- **`chainsaw_wm.md3`**, from `SP\chainsaw\spec_chainsaw.json` through `wm_split.py`:
  - Rest frame 13 as its only frame.
  - Surfaces `body` (islands 0-8), `chain` (10-26), `ripcord` (9), `cord` (27).
  - **1028/1028 verts, 1250/1250 tris, worst vertex error 0.00000.** `md3.py` self-check OK.
  - Each surface is rendered alone over the saw in `SP\chainsaw\wm_renders\`.
- **`chainsaw.png`**: copied, byte-identical (128 x 128 RGB).

Scripts: `SP\chainsaw\survey.py`, `ms_measure.py`, `twist_check.py`, `grips.py`, `islands_view.py`. Output: `survey_ms.txt`, `ms_measure.txt`, `grips.txt`.

### Classes and hand

- `WM_Chainsaw` / `WM_PropChainsaw`, **main hand**.
- Class lines, the lead's to write:
  - `WM_Gun.ShotSaw true` — **GRAMMAR PENDING (approved, not yet in code)**
  - `WM_Gun.SawSounds "full", "hit"` — **GRAMMAR PENDING (approved, not yet in code)**. The lead picks the names. `ARSENAL_LEAD.md` has `"wm/saw/loop", "wm/saw/hit"`. The IWAD's are `weapons/sawfull` and `weapons/sawhit` (checked in `UZDXREMA/wadsrc/static/filter/game-doomchex/sndinfo.txt`).
  - `WM_Gun.FullAuto true`
  - `WM_Gun.FireTics 4` (vanilla A_Saw every 4 tics)
  - `ReadySound "weapons/sawidle"` and `UpSound "weapons/sawup"`, both in the IWAD SNDINFO. `ARSENAL_LEAD.md` has `wm/saw/idle` and `wm/saw/start`; SNDINFO also has `wm/saw/cord`, `stop`, `off` and `zip`.
- `class WM_PropChainsaw : WM_Prop {}`

### MODELDEF

```
// THE CHAINSAW -- MAIN HAND. RS_ModelSwapper's MS_Chainsaw (models/hud/Chainsaw) as
// chainsaw_wm.md3: its rest frame 13 as its only frame, in the same units and origin, so
// the Offset carries over and the frame is 0. Scale verbatim -- this donor is NOT mirrored
// (CHAINSAW_CARDS.md).
Model WM_PropChainsaw
{
	Path "models/chainsaws/Chainsaw"
	Model 0 "chainsaw_wm.md3"
	Skin 0 "chainsaw.png"
	Scale 1.35 1.35 1.35
	Offset -2.468 -45.120 -15.378
	PlacementCVars wm_chainsaw
	NOAUTOREVERSE
	FollowMainHand
	FrameIndex WMPR A 0 0
}
```

### CVARINFO: stem `wm_chainsaw`, every default an ESTIMATE

```
// Chainsaw placement. ESTIMATES: not yet seen on a controller. The bar is tilted 17.12
// degrees up in the mesh; a pitch may level it (sign untested).
user float wm_chainsaw_ofs_x   = 0.0;
user float wm_chainsaw_ofs_y   = 0.0;
user float wm_chainsaw_ofs_z   = 0.0;
user float wm_chainsaw_yaw     = -90.0;
user float wm_chainsaw_pitch   = 0.0;
user float wm_chainsaw_roll    = 0.0;
user float wm_chainsaw_scale   = 1.0;
user float wm_chainsaw_scale_x = 1.0;
user float wm_chainsaw_scale_y = 1.0;
user float wm_chainsaw_scale_z = 1.0;
```

### Draft card

```
# ============================================================ CHAINSAW -- MAIN HAND
# RS_ModelSwapper's chainsaw.md3 (MS_Chainsaw) as chainsaw_wm.md3: surfaces body, chain,
# ripcord, cord. Every number measured at the source's rest frame 13 against Cube.020's
# largest island. _pending/CHAINSAW_CARDS.md.
#
# SCALE: MODELDEF Scale 1.35 x 0.34 = 0.459 map units per model unit.
weapon "WM_Chainsaw"
  type      = chainsaw     # its hand-seat profile (the key landed in c688186)
  hand      = main
  prop      = "WM_PropChainsaw"
  model     = "models/chainsaws/Chainsaw" "chainsaw_wm.md3"
  skin      = "models/chainsaws/Chainsaw" "chainsaw.png"

  # GRAMMAR PENDING (approved, not yet in code): no ammo, no stores.
  firesfrom = none
  # GRAMMAR PENDING (approved, not yet in code): nothing leaves the saw.
  casing    = none

  # THE BAR'S NOSE, on its centre line: the front-most of bar and chain along the bar's
  # own long axis (island 5's shape), which is tilted 17.12 degrees up in the mesh. The
  # same line's rear end is 1.01, 2.03, -3.71: 33.61 units, 15.4 map units of cutting edge.
  muzzle    = 33.75, 2.03, 6.38
  barrel    = 0.956, 0, 0.294

  # No ejectport, magazine or round. The cut's sounds are the class's (SawSounds). The ENGINE's
  # are the card's, for its ripcord (start ripcord, below): the cord as the pull begins, the
  # engine catching, its idle looped while it runs with the trigger up, and the stop when the
  # saw leaves the hand.
  pullsound  = "wm/saw/cord"
  startsound = "wm/saw/start"
  idlesound  = "wm/saw/idle"
  stopsound  = "wm/saw/stop"
end

# THE CHAIN RUNS (CS-G4, RS_VR_Reload.pk3 09-13 15:46): 17 tooth sections round the bar's edge
# (islands 10-26), and chain2, the same teeth at the donor's fire frame 8 (top run -0.716 along
# the bar, bottom run +0.755, nose turned), taken byte for byte. Shown by turns while the
# trigger is held, a tic each -- the donor's own fire state steps its two poses a tic a frame
# (6@1 .. 12@1). At rest only chain (phase 0) shows.
part chain
  surface   = chain
  flip      = trigger
  fliptics  = 1
  flipphase = 0
end

part chain2
  surface   = chain2
  flip      = trigger
  fliptics  = 1
  flipphase = 1
end

# THE RIPCORD: the T-grip on the engine's -y side. The donor's select clip (frames 1-4) pulls
# it 9.864 along -0.433, 0.001, 0.901 at frame 2, turning 16.17 degrees about
# -0.791, -0.585, -0.177 through its own centroid (rigid fit 0.009). Moved the way this dof
# moves it, every vertex lands within 0.014 of frame 2, and within 0.029 of frame 1 at half
# the pull; turned the other way it misses by 1.23. 9.864 units is 4.5 map units.
# `start ripcord` below names it, so it is grabbable: pull it to start the engine. The hand on
# it reads the chainsaw type's slide seat (it has no subject), a set nothing else on the saw uses.
part ripcord
  surface = ripcord
  grab       = -7.52, -6.26, -2.46     # the T-grip's centroid
  grabradius = 2.5                     # ESTIMATE
  dof
    kind      = slide
    axis      = -0.433, 0.001, 0.901
    distance  = 9.864
    pivot     = -7.515, -6.255, -2.464
    twist     = 16.17
    twistaxis = -0.791, -0.585, -0.177
  end
end

# THE CORD: stretches from the housing (anchor end -7.00, -5.71, -4.41) to the grip -- its
# vertices 0-3 ride the ripcord, 4-7 stay on the body. A surface moves whole, so it is
# hidden. At rest it lies inside the grip's own extent, so nothing visible is lost.
# GAP: a surface that stretches between a part and the body.
part cord
  role    = hidden
  surface = cord
end

# PULL TO START (CS-G1, RS_VR_Reload.pk3 09-13 15:45). Pulled past outat the engine catches and
# the saw cuts; let go and the grip springs home. Until then the trigger only clicks, and the
# engine stops when the saw leaves the hand, so every draw takes a pull. outat 0.85 is the
# reload system's default, stated: 0.85 of the 4.5-map-unit pull.
start ripcord
  part  = ripcord
  outat = 0.85
end

# NO TRIGGER PART: nothing in the mesh moves on the fire frames (6-12) but the chain.

# THE OTHER HAND on the wrap-round front handle's top bar (islands 1 + 2). ESTIMATE: where
# the hand goes. The point is measured: the bar's top (z > 9) centroid.
part support
  role    = support
  subject = support
  grab       = -1.49, -1.16, 10.04
  grabradius = 3.0                     # ESTIMATE
end
```

---

## ChainsawHeavy (off hand): Force Unleashed `models/chainsaw/`

- **Sources** (`E:\DOOMWork\_old\doom-force-unleashed_devbuild\models\chainsaw\`), each one frame:
  - `chainsaw.md3`: surfaces `chainsaw` 1756v / 15 islands and `saw_handle` 120v / 2 islands
  - `saw_blade1.md3`: `saw_blade` 284v
  - `saw_blade2.md3`: `saw_blade2` 194v
  - skin `chainsaw.png`, 512 x 512 paletted. Every surface's shader names it. The HD/PBR set (`chainsaw_HD.png`, `_n`, `_m`, `_r`, `_ao`) was not copied.
- **MODELDEF** `modeldefs\weapons\chainsaw.txt`, block `RLChainsaw` ("without hand" variant):
  - `Model 0 "chainsaw.md3"`, `Model 1 "saw_blade1.md3"` — one shared space
  - `Scale -1.0 1.0 1.0`
  - `Offset 0.0 -24.0 -10.0`
  - `NOINTERPOLATION`
  - **Rest = frame 0**, its only frame.
  - **Its animation is a mesh swap:** attack frame B draws `saw_blade2.md3` as Model 1; frames A, C and D draw `saw_blade1.md3`.
- **Merged** into one mesh first, `SP\chainsaw\fu_combined.md3`, surfaces in that order. Read back against the three sources: worst vertex error 0.00000, triangles and UVs identical.
- **Size:** 100.5 x 39.5 x 47.3 model units. At 1.0 x 0.34 that is **34.2 map units** long.
- **Shape** (`SP\chainsaw\renders\fu_islands.png`, `fu_body_zoom.png`):
  - engine body
  - a rear handle arching over the back (island 5)
  - a front bail on the +y side (`saw_handle`)
  - a hand guard plate (island 0)
  - the bar, tilted up 20°, with the chain mesh round it

### Measurements (frame 0; nothing is measured from motion, the mesh has none)

| Part | Surface / islands | Measured | Render |
|---|---|---|---|
| body | `chainsaw` islands 0-11, 13, 14 + `saw_handle` 1:0, 1:1; 1846v | static | `SP\chainsaw\wm_renders\chainsaw_heavy_wm_body.png` |
| **trigger** | `chainsaw` **island 12**, 30v | A 3.68-long wedge hanging under the top of the rear handle's arc (the handle is y -0.62..8.06, the wedge y 2.88..4.45). Long axis (0.933, 0.035, 0.358). Front end (11.84, 3.87, -0.27), rear end (8.83, 3.32, -1.33). | `SP\chainsaw\renders\fu_rearhandle_box.png`, `fu_trigger_context.png`, `SP\chainsaw\wm_renders\chainsaw_heavy_wm_trigger.png` |
| **chain** | `saw_blade` (saw_blade1.md3), 284v | round the bar's edge; y -0.83..0.67, x 33.95..98.27 | `SP\chainsaw\wm_renders\chainsaw_heavy_wm_chain.png` |
| **chain2** | `saw_blade2` (saw_blade2.md3), 194v | the donor's second chain pose, in the same place (x 33.95..97.97, same y) | `SP\chainsaw\wm_renders\chainsaw_heavy_wm_chain2.png` |
| bar | `chainsaw` island 3, 202v (in `body`) | long axis **(0.9379, 0.0043, 0.3469)**, 20.30° up, 63.29 long | `fu_islands.png` |
| rear handle | `chainsaw` island 5, 168v | an arc over the back. Its top run is x 10..19 at z 0.5..1.9; the x 13..16 band centroid is (14.96, 3.74, 1.04). | `SP\chainsaw\renders\fu_rearhandle_context.png`, `fu_rearhandle_box.png` |
| front bail | `saw_handle` island 0, 98v | a loop in front of the engine on the +y side; its top (z > 1.24) centroid is (23.68, 16.22, 1.87) | `SP\chainsaw\renders\fu_bail_context.png` |
| (not a ripcord) | `chainsaw` islands 6, 7, 14 | Two parallel ribbed tubes, 114v and 106v, about 11 long and 3.1 apart, bent inward at the front, low on the -y side. Island 14 (8v) is an end cap on island 7. No T-grip, no cord, no animation. | `SP\chainsaw\renders\fu_side_box.png`, `fu_sidepieces_context.png` |

**No ripcord** on this saw, so, per the owner, nothing to pull.

**Muzzle and reach.**
- The bar's centre line runs from **(35.05, -0.18, -12.46)** at its rear end (inside the engine, which ends at x 40.06) to **(97.78, 0.11, 10.75)**, the front-most of bar and chain.
- The chain starts at x 33.95.
- **Reach 63.29 model units = 21.5 map units.**

**Grip points** (measured points; where the hands go is an ESTIMATE):
- **Main hand:** the rear handle's top run, about (13.3, 3.7, 0.8), over the trigger.
- **Support:** the bail's top, **(23.68, 16.22, 1.87)**.

### Files written (`E:\DOOMWork\RS_VR_Weapons\models\chainsaws\ChainsawHeavy\`)

- **`chainsaw_heavy_wm.md3`**, from `SP\chainsaw\spec_chainsawheavy.json` through `wm_split.py` on `fu_combined.md3`:
  - Surfaces `body`, `trigger` (island 12), `chain` (saw_blade), `chain2` (saw_blade2).
  - **2354/2354 verts, 2230/2230 tris, worst vertex error 0.00000.** `md3.py` self-check OK.
  - Each surface is rendered alone over the saw in `SP\chainsaw\wm_renders\`.
- **`chainsaw.png`**: Force Unleashed's `chainsaw.png` copied, byte-identical.

Scripts: `SP\chainsaw\fu_measure.py` (merge + measure), `grips.py`. Output: `fu_measure.txt`, `grips.txt`.

### Classes and hand

- `WM_ChainsawHeavy` / `WM_PropChainsawHeavy`, **off hand**.
- Class lines, the lead's to write: the same as `WM_Chainsaw`'s:
  - `WM_Gun.ShotSaw true` — **GRAMMAR PENDING (approved, not yet in code)**
  - `WM_Gun.SawSounds "full", "hit"` — **GRAMMAR PENDING (approved, not yet in code)**
  - `WM_Gun.FullAuto true`
  - `WM_Gun.FireTics 4`
  - `ReadySound "weapons/sawidle"`
  - `UpSound "weapons/sawup"`
- `class WM_PropChainsawHeavy : WM_Prop {}`

### MODELDEF

```
// THE HEAVY CHAINSAW -- OFF HAND. Force Unleashed's chainsaw (models/chainsaw, block
// RLChainsaw): chainsaw.md3 + saw_blade1.md3 + saw_blade2.md3 merged as
// chainsaw_heavy_wm.md3 in their one shared space, so its Scale and Offset carry over
// verbatim and the frame is 0 (CHAINSAW_CARDS.md).
Model WM_PropChainsawHeavy
{
	Path "models/chainsaws/ChainsawHeavy"
	Model 0 "chainsaw_heavy_wm.md3"
	Skin 0 "chainsaw.png"
	Scale -1.0 1.0 1.0
	Offset 0.0 -24.0 -10.0
	PlacementCVars wm_chainsawheavy
	NOAUTOREVERSE
	FollowOffHand
	FrameIndex WMPR A 0 0
}
```

### CVARINFO: stem `wm_chainsawheavy`, every default an ESTIMATE

```
// Heavy chainsaw placement. ESTIMATES: not yet seen on a controller. The bar is tilted
// 20.30 degrees up in the mesh; a pitch may level it (sign untested).
user float wm_chainsawheavy_ofs_x   = 0.0;
user float wm_chainsawheavy_ofs_y   = 0.0;
user float wm_chainsawheavy_ofs_z   = 0.0;
user float wm_chainsawheavy_yaw     = -90.0;
user float wm_chainsawheavy_pitch   = 0.0;
user float wm_chainsawheavy_roll    = 0.0;
user float wm_chainsawheavy_scale   = 1.0;
user float wm_chainsawheavy_scale_x = 1.0;
user float wm_chainsawheavy_scale_y = 1.0;
user float wm_chainsawheavy_scale_z = 1.0;
```

### Draft card

```
# ======================================================= CHAINSAW HEAVY -- OFF HAND
# Force Unleashed's chainsaw (Ermac's mod, cleared by the owner) -- chainsaw.md3,
# saw_blade1.md3 and saw_blade2.md3 in one shared space -- merged as chainsaw_heavy_wm.md3:
# surfaces body, trigger, chain, chain2. A one-frame mesh: every number is measured from its
# shape, none from motion. _pending/CHAINSAW_CARDS.md.
#
# SCALE: MODELDEF Scale 1.0 x 0.34 = 0.34 map units per model unit.
weapon "WM_ChainsawHeavy"
  type      = chainsaw     # its hand-seat profile (the key landed in c688186)
  hand      = off
  prop      = "WM_PropChainsawHeavy"
  model     = "models/chainsaws/ChainsawHeavy" "chainsaw_heavy_wm.md3"
  skin      = "models/chainsaws/ChainsawHeavy" "chainsaw.png"

  # GRAMMAR PENDING (approved, not yet in code): no ammo, no stores.
  firesfrom = none
  # GRAMMAR PENDING (approved, not yet in code): nothing leaves the saw.
  casing    = none

  # THE BAR'S NOSE, on its centre line: the front-most of bar and chain along the bar's own
  # long axis (island 3's shape), tilted 20.30 degrees up in the mesh. The same line's rear
  # end is 35.05, -0.18, -12.46: 63.29 units, 21.5 map units; the chain starts at x 33.95.
  muzzle    = 97.78, 0.11, 10.75
  barrel    = 0.938, 0.004, 0.347
end

# THE THROTTLE: the wedge under the top of the rear handle (island 12). ESTIMATE, all of it:
# the mesh never moves it. A hinge at its front end, so pulling lifts its rear end up into
# the grip -- turned +15 about +y, the rear end (8.83, -1.33) rises. It may clip the
# handle's underside (z -0.53 over x 10-13).
part trigger
  role    = trigger
  surface = trigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 15.0
    pivot   = 11.84, 3.87, -0.27
  end
end

# THE CHAIN RUNS (CS-G4, RS_VR_Reload.pk3 09-13 15:46): saw_blade1.md3's chain and
# saw_blade2.md3's second pose, in the same place, shown by turns while the trigger is held --
# as Force Unleashed's Fire state swaps SAWG A and B, about 2 tics a pose. At rest only chain
# (phase 0) shows.
part chain
  surface   = chain
  flip      = trigger
  fliptics  = 2
  flipphase = 0
end

part chain2
  surface   = chain2
  flip      = trigger
  fliptics  = 2
  flipphase = 1
end

# THE OTHER HAND on the front bail's top (saw_handle island 0). ESTIMATE: where the hand
# goes. The point is measured: the bail's top (z > 1.24) centroid.
part support
  role    = support
  subject = support
  grab       = 23.68, 16.22, 1.87
  grabradius = 3.0                     # ESTIMATE
end
```

---

## Not picked: MS_RC_Chainsaw (`models/hud/RC_Chainsaw/chainsaw.md3`)

- **It is a disc saw** (`SP\chainsaw\renders\rc_islands_f0.png`, `rc_f0_vs_f5.png`, `rc_f0_vs_f24.png`):
  - `chainsaw_blade` island 0 (426v) is a flat, horizontal toothed disc: x -1.62..26.27, y -14.09..13.81, z -2.19..-1.23, about 28 across.
  - It spins about (0, 0, -1) through (12.81, -0.30); rigid fits read 180°, which is its tooth symmetry. Island 1 (15v) spins with it.
  - It moves on frames 2-35 and 37-43.
- **No ripcord and no trigger.**
  - In altfire 11-36 only the disc moves.
  - All 7 islands of `chainsaw_hand` stay fixed to the body (≤ 0.015) on every frame.
- **`chainsaw_hand` is not a hand.** It is the saw's housing plus a D-handle loop under it (islands 3 + 4, `SP\chainsaw\renders\rc_handleloop_context.png`), whatever the note in `RS_ForeignAnim.zs` says.
- **Skin is `chainsaw.jpg`.**
  - `build.ps1` packs only `.md3` and `.png` under `models/` (line 49), so it would need a `.png`. The conversion is a one-line Pillow call.
  - Not copied, not converted.
- MODELDEF `MS_RC_Chainsaw`: `Scale -0.85 0.85 0.85`, `Offset 0.212 -32.465 -7.901`, rest 0.
- A buzzsaw, if the owner ever wants one.

---

## Grammar and gaps

**GRAMMAR PENDING (approved, not yet in code):**
- `firesfrom = none` (**G5**, a card with no store). Today's parser would refuse both cards at this key. Without it, a card with no stores gets the pistol pair synthesised, and the saw would want a magazine.
- `casing = none`
- `WM_Gun.ShotSaw` + `WM_Gun.SawSounds` (**G6**, the saw attack).

**Open gaps** (not approved; for the reload lane):
- **CS-G1. Pull-to-start (Chainsaw only). SETTLED (uzdxrema-11, RS_VR_Reload.pk3 15:45:10):** a
  `start ripcord` verb (part, outat 0.85) and card `pullsound` / `startsound` / `idlesound` /
  `stopsound`, all live on WM_Chainsaw's card. The class dropped ReadySound and UpSound. The
  original ask:
  - Today the `ripcord` part has no role and no verb names it, so it is not grabbable.
  - Wanted: grab the T-grip and pull it along its dof past a threshold, and the engine starts: `wm/saw/cord` on the pull, `wm/saw/start` as it catches, then idle. It springs back when let go.
  - The saw does not cut until started. It stops with `wm/saw/stop` / `wm/saw/off`.
  - The ChainsawHeavy has no ripcord and would start on its trigger (the owner: no ripcord, nothing to pull).
- **CS-G2. The cut's reach is a segment, not a point.** A card has one `muzzle` and one `barrel`. The bar is a line, so both cards give its rear end in the comment beside `muzzle`: Chainsaw 15.4 map units, ChainsawHeavy 21.5. If `ShotSaw` traces from the muzzle along the barrel like A_Saw, that works as it is. A cut anywhere along the bar would need a second point or a length.
- **CS-G3. A surface that stretches (Chainsaw's cord).**
  - Its 4 grip-end vertices (`cord` v0-3) ride `ripcord` and its 4 anchor-end vertices (v4-7) stay on the body.
  - Parts move whole surfaces, so `cord` is `role = hidden` until a per-vertex split exists.
- **CS-G4. The chain runs while the saw revs. SETTLED (uzdxrema-11, RS_VR_Reload.pk3 15:46:56):**
  part keys `flip = trigger | fire`, `fliptics`, `flipphase`.
  - ChainsawHeavy flips chain / chain2 at 2 tics a pose (Force Unleashed's SAWG A/B).
  - Chainsaw flips chain and a new `chain2` at 1 tic a pose. chain2 is the donor's frame-8 teeth,
    added to chainsaw_wm.md3 byte for byte (`SP\chainsaw\chain2_build.py`); only chain vertices
    move between frames 13 and 8.
  - The original gap: Dof kinds are `slide | hinge`; nothing drives a running chain.
  - ChainsawHeavy: flip `chain` / `chain2` visibility each few tics while the trigger is held. That is the donor's own animation.
  - Chainsaw: the second pose is measured above (top run -0.716, bottom run +0.755 along the bar, nose turned about 10°) but is not in the mesh as a surface. It would need a `chain2` surface built from source frame 6, or the same flip done as an offset.
- **Two hands.** Both saws have a front handle; `hands = 2` is approved grammar but is not in the lead's chainsaw row, so the cards leave it out. The support parts are a brace.

**ESTIMATES:**
- every grab point and radius
- ChainsawHeavy's whole trigger hinge
- the main-hand grip points (for the placement sphere)
- every placement cvar default
- the bar tilt (17.12° / 20.30° up) as a pitch

**Unverified in game:**
- placement and size (24.4 and 34.2 map units long at scale 1)
- the Chainsaw's shader name `saw` taking `Skin 0` on the prop, as it does in ModelSwapper
- the ChainsawHeavy's paletted PNG skin
- whether a 4.5-map-unit ripcord pull feels long enough (the mesh's cord only reaches 11.59 units, 5.3 map units)
