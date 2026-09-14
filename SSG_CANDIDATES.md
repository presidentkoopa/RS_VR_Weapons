# SSG and AssaultShotgun candidates — for the break-action double and a magazine-fed shotgun

Measured 2026-09-13, read-only, `tools/md3.py` rigid fits (receiver's own motion divided
out) plus a visual check with `RS_ModelSwapper/tools_md3_render.py` (overlaying rest and
open/cycled frames, with the reference surface's own motion subtracted out first where the
donor animation also tilts the whole gun, same method as REVOLVER_CANDIDATES.md).
Measurement only — no card or ZScript edits.

Both meshes already live in this package (`models/shotguns/SuperShotgun/`,
`models/shotguns/AssaultShotgun/`), copied in with the other shotgun candidates
(SHOTGUN_CANDIDATES.md, 2026-09-12).

---

## Super Shotgun (SSG) — `ssg.md3`, break-action double

26 frames, 6 surfaces, clean unique names — no naming problems on this mesh.

| Surface | Verts | Role | Confidence |
|---|---|---|---|
| `ssgbase.006` | 379 | Frame/grip (reference) | — |
| `ssgbarrel.006` | 160 | The barrel unit — hinges open | High |
| `shotshell1.006` | 34 | Chambered shell, right barrel (y +0.93) | High |
| `shotshell2.007` | 34 | Chambered shell, left barrel (y −0.97) | High |
| `newshell1.006` | 34 | A shell being loaded in (visible only frames 14-22) | High |
| `newshell2.006` | 34 | Same, the other barrel | High |

### Barrel hinge — measured and visually confirmed

Rigid fit of `ssgbarrel.006` against `ssgbase.006`, frame 12 (plateau, frames 11-21 all
agree to within 0.02°), rotation read off the fit matrix directly (not `part_motion`'s
translation-only `axis` field — see REVOLVER_CANDIDATES.md for the method):

- **Axis: (0, 1, 0)** — straight across the gun, exactly a break-action's hinge.
- **Degrees: 58.55°** (agrees exactly with SHOTGUN_CANDIDATES.md's earlier estimate).
- **Pivot: (3.965, 0, −1.238)**, model space. Singular values (0.978, 0, 0.978) — clean
  single-axis hinge, same signature as every other hinge measured on this project.
- Fit quality: barrel rmsd 0.012, base rmsd 0.008.

**Visually confirmed**: rendered frame 0 against frame 12/17 (`tools_md3_render.py`, no
divide-out needed — `ssgbase.006`'s own drift is only 3.32, negligible next to the barrel's
14.4). The SIDE view shows the classic break-open silhouette: the barrel unit swings down
and forward away from the frame, hanging below the closed-gun line. No ambiguity here, unlike
the revolvers — this mesh has one hinge, one plane of motion, and a rest pose that already
looks like a shotgun.

### The two chambers

Two barrels, confirmed side by side (not over/under): the muzzle's front-most vertices split
into two clusters at the same height (z ≈ 1.45–1.52) and opposite y (−1.14 / +0.86), muzzle
tip at x = 24.75.

- `shotshell1.006` rest centroid: (0.70, 0.93, 1.12) — right barrel.
- `shotshell2.007` rest centroid: (0.70, −0.97, 1.12) — left barrel.

Both are rigid and stationary through frames 0-8, then eject fast starting frame 9,
becoming degenerate (thrown clear, geometry gone) by frame 18, exactly matching the barrel's
own open transition (frames 9-21) — **`onopen = ejectall` is exactly what's drawn here**,
already in the shape BUILD.md's break-action worked card expects (`store barrels kind =
slotted slots = 2`, two `load` blocks with explicit `slot = 0` / `slot = 1`, matching this
mesh's left/right split precisely).

`newshell1.006` / `newshell2.006` exist (non-degenerate) only frames 14-22, appearing well
away from the gun (dist ~45-48 units, low rotation) and are the mesh author's own "shell
being loaded" depiction — decorative reference for where a `load` zone might sit per barrel,
not something to drive directly (same category as the pistols' baked brass: real objects are
thrown/carried instead of playing this animation).

### Not yet measured

Trigger and hammer(s) — this mesh has neither as a separately named surface (fused into
`ssgbase.006`, same situation as the Doom shotgun's own card). A top lever / latch surface
also isn't separately named — same open question as both revolver meshes (REVOLVER_
CANDIDATES.md's G-R1); the barrel may simply open on its own grab.

### The shot — vanilla Doom (owner, 2026-09-13)

When the SSG is wired, its class takes Doom's own `A_FireShotgun2` (UZDXREMA
`wadsrc/static/zscript/actors/doom/weaponssg.zs`), not RS_Main's numbers:

- `WM_Gun.ShotPellets 20`
- `WM_Gun.ShotSpread 11.25, 7.097`
- no `ShotDamage`, so each pellet keeps `WM_Bullet`'s own 5 × 1d3.

Both spreads are `Random2 × spread / 256`, the same triangular shape `WM_Gun.ScatterShot`
draws.

### Built (2026-09-13)

Wired end to end: `WM_SSG` (zscript/rs_vr_weapons/ssg.zs), its card at the end of
WMCARD.txt on the reload system's new `archetype breakaction`, `WM_PropSSG` in MODELDEF
(MS_SuperShotgun's Scale 1.35 / Offset 0 -36.344 -2.995 verbatim), the `wm_ssg_*`
placement set, the `WM_SSGGun` page (linked from WM_PumpTest), slot 3, netevent and alias
`wm_givessg`. Compiled with both packages; both menu lints clean.

**"Not yet measured", measured.** Every surface split into its disconnected islands, each
rigid-fit against the body over all 26 frames:

| Surface | Islands | Motion relative to the body |
|---|---|---|
| `ssgbase.006` | 171v stock/receiver, 104v breech block, 56v top lever (x −4.1..−2.4, z 2.1..3.1), 48v trigger guard (z −4.3..−2.3) | all ≤ 0.29°, ≤ 0.01 units — **never move** |
| `ssgbarrel.006` | 85v barrels, 56v forend (x 3.02..17.08, z −2.66..0.92), 19v front sight | all 58.55° about (0, 1, 0), fit ≤ 0.012 — **one part** |

So the top lever and trigger exist only as static geometry. There is nothing to drive, and
the barrels open on their own grab. The hinge sign was checked the way round: the barrels'
centroid turned +58.55° about +y through the pivot lands where frame 12 has it, and
`tools_md3_render.py --frame 0 --frame2 12` shows the barrels hanging below the closed line
with the breech lifted.

**The shot, as built.** Not `ShotPellets 20`: `ShotPellets 10` + `WM_Gun.ChambersPerPull 2`
(a new, generic, default-1 property), so one pull fires every LOADED barrel at once — both
loaded is vanilla's 20 pellets, one loaded is 10, none clicks. `ShotSpread 11.25, 7.097`
(vanilla exact), no ShotDamage. `FireTics 20` (vanilla's 57 is its reload animation; here
the hands are the reload).

**Gaps closed** (CARDS_ON_PAPER.md): G7 slotted two-chamber store with a round surface per
barrel; G2 one shell at a time into it (one `load breech`, `slot = next`, rides the
barrels, gated on open); G11/G12/G14 the barrels as an `open` part that stays, ejecting
live shells as shells and spent hulls as brass; G16 no fire while open or part-open; G9
the double's shot is the class's.

**Still open.** G15, the flick close: push the barrels up by hand. G8, one muzzle: flash
and sparks come from between the bores. Left and right: the zone fills slot 0 (the +y
barrel, `shotshell1.006`) first; which side that is in the hand is unconfirmed by eye.

---

## AssaultShotgun — `AssaultShotgun.md3`, magazine-fed

32 frames, 7 surfaces — **two names collide**: `Sights` appears twice (665 verts and 436
verts — genuinely different geometry, not an LOD pair) and `Trigger` appears twice (847 and
44 verts). `FindModelSurfaceIndex`-by-name resolves to whichever the engine's lookup returns
first, so **the second `Sights` and the second `Trigger` can never be addressed
individually** — this was flagged "not usable" in SHOTGUN_CANDIDATES.md and this pass
confirms it's still true; nothing here fixes it.

| Surface | Verts | Role | Confidence |
|---|---|---|---|
| `Frame` | 2776 | Body + barrel + everything static (reference) | — |
| `Mag` | 196 | Magazine — drops out | High |
| `Receiver` | 38 | Small moving part, own motion distinct from the magazine | Medium — see below |
| `Sights` ×2 | 665, 436 | Two different pieces, same name — **unaddressable individually** | — |
| `Trigger` ×2 | 847, 44 | Same problem | — |

The donor animation also tilts the whole gun (a reload flourish, same pattern as both
revolver meshes and the pistols) — `Frame`'s own absolute drift is 46.84, so every number
below has that divided out via `part_motion(ref_name='Frame')`, and the visual check used
the same "subtract the reference surface's own rigid motion first" render as
REVOLVER_CANDIDATES.md, not a plain frame-overlay (which would show the flourish, not the
part).

- **`Mag`**: 27.99 units of **pure translation** (0.02° rotation — clean), along
  (−0.707, 0, −0.707) — a 45° drop, down and back out of the well. rmsd 0.009. This is a
  detachable box magazine, same shape as the pistols' own magazine swap, just bigger travel.
- **`Receiver`** (38 verts, small): 10.02 units of pure translation (0.03°, rmsd 0.011),
  along (−0.708, 0, +0.707) — up and back, the *opposite* vertical sense from the magazine's
  drop. Isolated and rendered alone (excluding every other surface): it is a rod with a
  knob/cap at each end plus a separate small flat blade — genuinely handle-shaped geometry,
  moving as its own clean rigid piece, not noise or an authoring artifact.
  **Owner's read: this gun probably has no other moving parts** — worth weighing against the
  measurement. A donor mesh animating a charging handle as pure reload flourish, with no
  intent for it to be a separate interactive part, is common and would look exactly like
  this in the data (real geometry, clean rigid motion, just not meant to be grabbed). Not
  asserting it as a functional part — flagging the shape and the motion, and leaving whether
  it becomes a card `part` to whoever specs this gun.

**Visually confirmed** (magazine only): rendered with `Frame`'s own motion divided out —
the magazine hangs as a separate small block below and behind the frame at frame 16, a plain
drop, no tumble. Matches the clean rigid-fit number.

### Usability verdict

Usable for a magazine-fed archetype with just `Mag` (the swap) — a plain, clean, single-part
reload, matching the owner's own read that this gun likely has no other moving parts to
design around. `Receiver` is on record as real, handle-shaped geometry with clean motion, in
case it turns out wanted later, but it is not being carried forward as a part. **Not usable
for anything needing the sights or a second trigger-adjacent part** — those are permanently
unaddressable on this mesh by name. If the assault shotgun ships, budget a pass re-exporting
or renaming the duplicate surfaces before depending on either one.

---

## Summary for the reload lane

- **SSG is a clean, ready-to-card break-action double.** Hinge axis (0,1,0), 58.55°, pivot
  (3.965, 0, −1.238); two chambers with real, symmetric rest positions and a confirmed
  `ejectall`-shaped ejection; muzzle at (24.75, ±~1, ~1.5) split by barrel. No trigger/latch
  surface (same open question as both revolvers).
- **AssaultShotgun is a one-part magazine reload** (`Mag`, a plain 28-unit drop, pure
  translation) — matches the owner's own read of the gun. `Receiver` is real, handle-shaped
  geometry that also moves cleanly, logged in case it's wanted later, but not treated as a
  part. A real, unfixed naming defect exists on two other surfaces (`Sights` ×2, `Trigger`
  ×2) if anything beyond the magazine is ever needed.

---

## Double Barrel — Force Unleashed's `ssg.md3` + `ssg_shell.md3`, the second break-action double

Built 2026-09-13, so every Doom gun has two (the owner's roster). Force Unleashed (Ermac's Rusted Legacy, MIT) is
owner-cleared. Its one MODELDEF block (`RLSuperShotgun`) draws `ssg.md3` (37 frames) and `ssg_shell.md3` (41 frames)
in one space, `Scale -1 1 1`, `Offset 0 -24 -10`. Measured with `SP\ssg2\measure.py` (output `measure.txt`):
rigid fits against `ssg_stock`, its own recoil (frames 3-5, 9-11, 15-17) divided out.

| Surface | Verts | What it does | Measured |
|---|---|---|---|
| `ssg_stock` + `ssg_stock_base` | 814 + 73 | the body; the stock base never moves | reference |
| `ssg_barrel` + `ssg_barrel_base` | 394 + 54 | one hinge | **36.96° about (0, 1, 0) through (29.29, 0, 11.78)**, open frames 22-33, fit 0.009-0.011; frames 20/21 and 34/35 at 9.5° / 27.4° on the same axis |
| `ssg_trigger` | 46 | pulled on every fire frame | **19.24° about (0, 1, 0) through (9.09, 0, 8.41)**, fit 0.007 |
| `ssg_hammer_left` / `_right` | 137 / 139 | fall on the fire frames | 63.95° about (0, 1, 0) through (11.75, ±3.4, 12.68) -- no verb cocks them, so drawn fixed |
| `ssg_shell` / `ssg_shell2` | 51 / 51 | the chambered shells | seated at (21.99, ±3.34, 14.98) in the barrels' own rest space on every loaded frame, frame 0 included |

- **Rest pose:** frame 0 of both models. The donor hides the shell model at ready (frame 99), but its frame 0 has
  both shells seated, in the same space -- so the merge copies bytes and turns nothing.
- **Muzzle:** the barrels' front face, x 77.87, two bores centred (y 1.90, z 14.93) and (y -2.21, z 15.08).
- **Breech:** the barrels' rear face, x 16.86 (centre y 0.15, z 15.01); the shells' rims at x 17.06.
- **Size:** 1.0 x 0.34 = 0.34 map units a unit. The shell is 9.86 units = 3.4 map units, so the card's loose round
  is this gun's own shell at 0.34.

**Built:** `models/shotguns/DoubleBarrel/doublebarrel_wm.md3` (`SP\ssg2\build_mesh.py`): body, barrels, trigger,
hammerleft, hammerright, shell1, shell2, frame 0 byte for byte (md3_raw), every vertex record and UV verified;
`wm_doublebarrel_shell.md3` (shell1 lifted out, all 51 packed normals kept); `ssg_HD.png` and `shells.png` (MODELDEF
`SurfaceSkin 0 5/6`); the donor's sounds ssgfire / DSDBOPN / DSDBCLS / CLIPINSS as `wm/dbarrel/*`. Card
`WM_DoubleBarrel` (off hand, `mechanism = breakaction`), class in `ssg.zs` with the SSG's vanilla shot.

**ESTIMATE, for the headset:** the placement set (all defaults), the grab oval's across/up size, the ejectport's side.