# Rifle candidates — the Rifle, the M16, and the Brutal Wolfenstein WW2 set

Measured 2026-09-13, read-only. Numbers come from `tools/md3.py` rigid fits with the body's own
motion divided out. Every identification below was checked against a render made with
`RS_ModelSwapper/tools_md3_render.py`, except where it says **measured only**.

**Licence/credit: unrecorded for all of these.** Sources:
- ModelSwapper's rifle mesh (the Rifle): its code credits Brutal Doom v21.
- m16.md3: no source recorded.
- The WW2 set: the Brutal Wolfenstein 3D VR weapons pack.

Flag before anything ships.

---

## The Rifle — ModelSwapper's rifle mesh, now `models/rifles/Rifle/`

Ours as the Rifle. 32 frames, 6 surfaces, unique
names (Finnish). **REST FRAME IS 3.** Frames 0-2 are the donor's raise, with the gun swung across
the body. ModelSwapper's block (`FrameIndex CHGG A 0 3`) and its ready clip both show frame 3.

| Surface | Verts | Role | Measured (rest frame 3, against `Runko`) |
|---|---|---|---|
| `Runko` | 4554 | body | muzzle at +x, front-most vertices (54.24, 0.13, 0.20); barrel end 2.2 × 2.1 across, stock 4.3 × 10.8 |
| `Lipas` | 2046 | **magazine** | pure slide, fit 0.015. Insert axis (-0.025, 0, -1.0) from frames 12-14; frames 10-11 tilt as it clears, frame 9 is its fall. 22.3 long along the axis. Floorplate (1.21, 0.08, -22.20) |
| `liikkuvat` | 268 | **charging handle** (T-handle, top rear) | 7.117 along -x at frames 5 and 22, 0.04°, fit 0.008. Rear (-16.48, 0.97, 2.59) |
| `ejectport` | 79 | **bolt carrier** behind the port | 10.44 along -x on the same frames — **a constant 1.466 × the handle** on every frame (checked 5 and 18-24) |
| `trigger` | 76 | trigger | 16.98° hinge about (0, 1, 0) through (-7.155, 0, -5.124), frame 4, fit 0.009 |
| `tähtäin` | 2781 | sights | static (0.02 at most); UTF-8 name, so not referenced by the card |

Three-surface minimum: **passes** (body `Runko`, action `liikkuvat`, magazine `Lipas`).

- **Ejection port side:** the receiver wall over the carrier (x -10..2, z -0.5..3) has 80
  vertices on -y against 20 on +y. That puts the port on -y, by the same test the M4A3's card
  used. The port *point* is an ESTIMATE.
- **Handguard:** no vertices between x 12 and 24 (long quads). The underside is z -3.59 at x 8-12
  and -3.06 at x 24-28, so the support grab (18, 0, -3.3) is an ESTIMATE.
- **Pistol grip:** x -19.9..-2.9, centroid (-9.5, 0.15, -10.4), bottom at z -18.0.
- **Loose magazine:** `models/rifles/Rifle/wm_rifle_mag.md3` — `Lipas` at frame 3, stood upright
  on the insert axis, 10.6 × 2.0 × 22.5, roundtrip-verified.

**Wiring (2026-09-13), approved by the reload lane:**
- card `WM_Rifle` in WMCARD.txt
- MODELDEF `WM_PropRifle` at `FrameIndex WMPR A 0 3`
- slot 5
- sliders `wm_rifle_*`
- menu row `wm_giverifle`
- `WM_Gun.FireTics 12`

**Gaps for the reload lane:**
- **R-G1, a `follows` with a rate.** The carrier must travel 1.466 × the charging handle. Today
  both surfaces ride one part at the handle's 7.117, so the carrier falls 3.3 units short behind
  the port. Planned in BUILD.md step 9.
- **R-G2, fire cadence — resolved.** RS_Main's rifle fires 3 shots a second; WM_Gun's fixed Fire
  state gave 1.84. `WM_Gun.FireTics` landed (default 19), and the Rifle sets 12: about 2.9 a
  second, as fast as you can pull.
- Known already: no `hands = 2`, so the support hand is a brace, not a second hold (G10).

---

## M16 — ModelSwapper `models/hud/Rifle/m16.md3`, copied to `models/rifles/M16/` — UN-PARKED

41 frames, 4 surfaces, rest frame 0 (ModelSwapper's ready clip `0@1`).

| Surface | Role | Measured |
|---|---|---|
| `weapon.002` | body **and the charging handle** | 9 pieces of geometry. Islands 7 + 8 (24 verts, x -1.83..-0.69, y 1.20..3.17, z 0.83..4.22) travel **5.60 along (-1.000, 0, -0.023)**, fit 0.008, on every fire cycle (frames 1-6) and at the reload's rack (35-39, peak 37). The other 7 pieces stay fixed |
| `weapon.005` | magazine | out and back frames 11-35, collapsed (hidden) 21-26. Its main piece fits 0.007 with a 6° tilt; two small inner pieces (rounds/follower) deform (fit 0.3-0.7) |
| `weapon.004` | trigger | a 1.0-unit slide on frames 1-3 |
| `weapon.003` | ejected casing | hidden outside frames 1-8 |

**CORRECTION (2026-09-13).** This section first said the M16 had no charging handle and all 9
body pieces were fixed. That was wrong. My island script took the whole named body surface as
body, so it never tested the two small islands that move. The build lane found them with a
per-island fit, and the fixed script confirms them: 5.60 back, frames 1-6 and 35-39. The M16
passes the three-surface minimum once islands 7 + 8 are split into their own `charginghandle`
surface in a `m16_wm.md3` copy.

**Built (2026-09-13).** `models/rifles/M16/m16_wm.md3`:
- m16.md3's frame 0 as the only frame, with surfaces `body` (islands 0-6), `charginghandle`
  (islands 7 + 8), `magazine`, `trigger` and `casing`
- 696/696 verts, 843/843 tris, worst vertex error 0.00000; each surface rendered alone over the gun

`wm_m16_mag.md3` is the magazine, stood upright on its insert axis.

Card `WM_M16`:
- charging handle 5.600 along (-1, 0, -0.023)
- magazine along (-0.105, 0, -0.995), 11.81, the axis from frame 29, its purest insert frame (1.6°)
- sliding trigger 1.245
- casing hidden
- support under the handguard (ESTIMATE)
- ejection port on -y (ESTIMATE, 9 against 11 wall vertices, too few to tell)

The rest:
- MODELDEF `WM_PropM16` (MS_Rifle Scale 1.35 / Offset verbatim)
- slot 5 beside the Rifle
- sliders `wm_m16_*` and page `WM_M16Gun`
- netevent and alias `wm_givem16`
- its shot is the Rifle's until the owner gives the M16 its own numbers

---

## The WW2 set — Brutal Wolfenstein 3D VR weapons pack

Source: `D:\SteamLibrary\steamapps\common\DooM VR\__Games\BrutalWolfenstein3D\BW-VR-Weapons\Models`.
ModelSwapper's addon (`.gen/ww2`) holds re-centred copies of the same meshes.

**Every gun is ONE surface, and every gun still has separate moving parts.** The magazine, bolt,
trigger and so on are each their own disconnected piece of geometry inside that surface, and each
moves rigidly. They can't be carded as they are, since a card names surfaces. **Splitting each
piece group into its own named surface is a script job, not remodelling.**

Rest frames are from ModelSwapper's `tools_make_ww2_addon.py`. Distances are model units.
Pieces = separate chunks of geometry in the mesh.

| Gun (rest) | Pieces | Parts found (relative to the body) | Card path once split |
|---|---|---|---|
| **Garand** (1) | 41 | **en-bloc clip with 8 rounds** (39.9, frames 19-35; render shows 2 × 4 rounds); **bolt** 9.42 back turning 21.5°; **op rod** 10.90 along -x; trigger 23.8° | magazine + action on today's grammar (the clip as the magazine) |
| **Kar98k** (1) | 38 | **bolt** 7.94 along -x; **bolt handle** turning 137° about the bore axis plus 9.18 of travel (render: lifts and comes back); **five rounds + stripper clip** (~40, frames 12-43); a single round/case 45.5; trigger 28.1° | the bolt action — BUILD.md step 12 (`dof` + `dof2`) |
| **StG 44** (13) | 79 | **curved magazine** (render: drops out); **charging handle / carrier** 15.72 along -x (frames 14-18 fire, 42-47 charge), fit 0.009; trigger 26.8° | magazine + action on today's grammar, like the Rifle |
| **MP40** (13) | 57 | **magazine** 48.6 straight down; **bolt handle** 13.86 along -x; trigger 33.9°; two pieces that fold 97-162° only during the raise — likely the folding stock (**measured only**) | magazine + action on today's grammar |
| **Thompson** (1) | 29 | **stick magazine** (out with a spin, 65); **bolt handle** 9.49 along -x; trigger 29.6°; small 9° hinge (magazine catch?) (**measured only**) | magazine + action on today's grammar |
| **Trench Gun M12** (1) | 26 | **pump** 8.00 along -x (30.8 long); **action bar** with it (8.07); **shell** into the tube (37.8); carrier 17.5° hinge; trigger 15.8° (**measured only**) | the `pump` archetype |
| **MG42** (12) | 224 | **top cover** 117.3° hinge about +y through (43.2, 0, 10.9), plus a feed piece with it; **belt/box** moving together (76.8°); **charging handle** 15.98 along -x; trigger 27.3° (**measured only**) | belt-fed — a new archetype |
| **Luger** (0) | 17 | **magazine** 15.3 down and back; **toggle links** 86.6° and 43.6°; **breechblock** 4.95 along -x; barrel/receiver 0.91 recoil; trigger 15° (**measured only**) | toggle lock — new kinematics |
| **1911** (1) | 58 | **slide against frame** 4.09 along x; **hammer** 61.1°; **magazine** 14.3 down; no separate trigger piece found (**measured only**) | slide + magazine on today's grammar (the pistols' shape) |
| **Flammenwerfer** (0) | 19 | one lever/trigger 39.2°; nothing else moves | not a gun for this system |

On the 1911, the "body" picked was the slide, the largest single piece. The travel above is the
slide relative to the frame either way.

### How the parts were found (so it can be repeated)

1. Per surface, join vertices into pieces through shared triangles.
2. Also join vertices that sit at the same position on *every* frame (UV-seam duplicates).
3. Take the body's motion from a rigid fit of the largest piece, or the longest one (`--seed-longest`)
   when the magazine is the largest piece, as on the StG 44.
4. Call a piece **body** when three probes on it (centroid, farthest vertex, farthest from that
   line) stay within 0.15 of their rest position in the body's frame on every frame.
5. Group moving pieces into parts when a rigid fit of the pair holds to within 0.06 on every frame
   they share.
6. For each part, write a two-frame MD3 in the body's frame (rest and the part's farthest frame)
   with `tools/md3_write.py`, and render it with `tools_md3_render.py`, with and without the body.

The script lives in this session's scratchpad (`ww2_split.py`). It could move to `E:\DOOMWork\tools\`
next to md3.py. The next step — writing each gun out with its parts as named surfaces for a card —
is the same code writing all frames instead of two.
