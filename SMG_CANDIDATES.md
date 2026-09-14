# SMG candidates — Tec9, the SMG, and the WW2 MP40 / Thompson

Measured 2026-09-13, read-only, from `E:\DOOMWork\RS_ModelSwapper` (nothing edited there).
Each surface was split into its separate pieces of geometry (islands), and each piece was
rigid-fit against the body with the body's own motion divided out. Every part below was
rendered with `RS_ModelSwapper/tools_md3_render.py`.

**Licence/credit: unrecorded.** Flag before anything ships.

---

## Tec9 — `models/hud/Tec9/tec9.md3` — the owner wants it

6 frames, fire only: ModelSwapper plays `ready 0`, `fire 4,1,2,0`. **There is no reload
animation**, so the magazine never moves in any frame. 4 surfaces, **all named `Cube`**. A card
names surfaces and the engine takes the first match (`FindModelSurfaceIndex`), so every part
needs its own name in a `tec9_wm.md3` copy.

| Piece | Where | Role | Measured (rest frame 0) |
|---|---|---|---|
| surface 0 | 5055 verts, 20 islands | body | fixed on all 6 frames except its own recoil |
| surface 0, island 3 | 306 verts; x -2.81..1.17, y -1.22..1.06, z -15.86..2.22 | **magazine** | a separate chunk, straight box in front of the trigger guard (render). Long axis **(0.013, 0, -1.0)** from its own shape, 18.13 long; floorplate (-0.76, -0.08, -15.64), top/feed lips (-1.00, -0.08, 1.72) |
| surface 0, islands 4, 5, 6 | 300 verts each; x -2.42..1.00, z -0.75..2.38 | **three rounds** at the top of the magazine | staggered stack (render); they leave with the magazine |
| surfaces 2 + 3 | 168 + 186 verts | **bolt handle on the side** (2: y +0.31..+3.83) and **the bolt** in the receiver (3) | together **7.09 along -x** at frame 3 (3.55 at frame 4), fit 0.010 |
| surface 1 | 60 verts | trigger | **25.1°** about (0, 1, 0) through (-7.13, 0, -0.38), fit 0.013 |

**Seating needs no animation.** The reload system never plays donor frames; it slides the
magazine along the card's axis at the hand's pace. The axis here comes from the magazine's own
straight shape, not from frames, and the card will say so.

**The magazine is not fused**, so there is nothing to hide. Split island 3 + islands 4-6 into a
`magazine` surface, and it drops, carries and seats like the pistols'.

MODELDEF from ModelSwapper (MS_MG_Tec9): `Scale -1.1 1.1 1.1`, `Offset -0.086 -43.243 -7.822`,
frame 0.

**Built (2026-09-13).** `models/smgs/Tec9/tec9_wm.md3`:
- surfaces `body`, `magazine` (islands 3-6), `trigger` and `bolt` (surfaces 2 + 3)
- 5469/5469 verts, 3986/3986 tris, worst vertex error 0.00000; each surface rendered alone over the gun

`wm_tec9_mag.md3` is the magazine with its rounds, upright. `tec9.png` is copied.

Card `WM_Tec9`, off hand:
- bolt 7.091 along -x, grabbed at the handle's knob (-0.98, 3.26, 3.40)
- magazine along its shape axis (0.013, 0, -1), 18.3
- trigger 25.11° (sign checked: +25.11 misses the frame-3 centroid by 0.006, -25.11 by 2.06)
- 32 rounds, magfamily `tec9`
- ejection port on -y (73 against 101 wall vertices; the point is an ESTIMATE)
- support under the shroud (ESTIMATE)

The rest:
- MODELDEF `WM_PropTec9` (MS_MG_Tec9 Scale / Offset verbatim)
- slot 6; sliders `wm_tec9_*`; pages `WM_SMGTest` and `WM_Tec9Gun`
- netevent and alias `wm_givetec9`
- no shot numbers until the owner gives them

---

## SMG — RS_ModelSwapper `models/hud/SMG` (shape reads as a KRISS Vector)

27 frames, **rest frame 3** (frames 0-2 are the raise; ModelSwapper `ready 3`). 4 surfaces.
`Sights` appears twice (surface 0 and the body, surface 1). The engine's first match is
surface 0, the lever below, but the `_wm` copy renames them anyway.

| Surface | Role | Measured (rest frame 3, against surface 1) |
|---|---|---|
| 1 `Sights` (17897 verts, 165 islands) | body | every island fixed |
| 3 `Lipas` (2714 verts) | **magazine** | **16.76 along (-0.298, 0, -0.954)**, out at frame 8, back in over 9-18, pure slide, fit 0.010; 25.3 long |
| 2 `Trigger` (222 verts) | trigger | 0.98 along -x (a sliding trigger), fit 0.008 |
| 0 `Sights` (239 verts; x 12.3..20.6, y 1.3..3.4, z 3.1..4.3) | **folding charging handle** | lies along the top right of the gun, **folds straight out 90°** about (0, 0, 1) through (9.91, -1.18, 0), frames 20-25, back at 26, fit 0.010 (render) |

**Gap:** the handle only folds out. The animation has no rearward pull (a real Vector's handle
folds out, then pulls back). The card can take the fold as the rack (a hinge action, as a
lever gun would), or give the handle a pull-back whose distance the mesh doesn't have
(ESTIMATE). Reload lane / owner call.

MODELDEF from ModelSwapper's own SMG block: `Scale -1.0 1.0 1.0`,
`Offset -0.156 -38.438 -10.984`, frame 3. Its name here is the SMG.

---

## WW2 MP40 and Thompson — one-surface meshes, parts found (RIFLE_CANDIDATES.md, WW2 table)

- **MP40** (rest 13):
  - magazine 48.6 straight down
  - bolt handle 13.86 along -x
  - trigger 33.9°
  - two pieces fold during the raise (likely the stock)
- **Thompson** (rest 1):
  - stick magazine (comes out with a spin; the insert axis is from its last frames)
  - bolt handle 9.49 along -x
  - trigger 29.6°

Both need their parts split into named surfaces first, the same job as `tec9_wm.md3` and
`m16_wm.md3`. Their numbers were found with the fixed script's method but haven't been
re-measured into card-ready form yet.
