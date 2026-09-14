# Revolver candidates — Moonlight, Sunset, Cola

Measured 2026-09-13, read-only from `E:\DOOMWork\RS_ModelSwapper` (owner-approved source,
nothing edited there), with `tools/md3.py` rigid fits (`part_motion`, `rigid_fit`), never
animation-frame numbers taken at face value. Force Unleashed was re-checked and confirmed
to have no revolver and no speedloader (its folders: ammo, ammo_hand, bfg9000, chaingun,
chainsaw, common, hand, heatwave, hellshotgun, incinerator, pistol, plasmarifle,
rocketlauncher, shieldsaw, shotgun, ssg — `common/bullet.md3` is a loose-round candidate only).

**Copied in 2026-09-13** to `models/revolvers/`: `Revolver/rev.md3` + `WPN-REV.png` +
`WPN-REV2.png`; `Cola_Revolver/revolver.md3` + `revolver.png`. **Now in use** by the real
revolver cards (see "Built" at the end): Moonlight/Sunset draw `rev_wm.md3`, made from
`rev.md3`; Cola draws `revolver.md3` directly.

**Licence/credit: unrecorded**, same flag as the shotguns (SHOTGUN_CANDIDATES.md) — confirm
before anything ships.

---

## Moonlight / Sunset — `rev.md3` (one mesh, two skins: `WPN-REV.png` / `WPN-REV2.png`)

41 frames, 11 surfaces, all named `python.0xx` — no descriptive names, identified below by
motion, not by name. Reload animation runs roughly frames 15→33 (idle before and after).

| Surface | Verts | Role (measured) | Confidence |
|---|---|---|---|
| `python.004` | 298 | **Frame/grip** — the reference body | Grip only: its own rest bounds are just 13.9 units on its longest axis (x -9.34..4.56), too short to be grip+barrel both. Where the barrel geometry actually lives is **not resolved by motion alone** — see below. |
| `python.005` | 63 | Part of the **crane/cylinder swing** (see below) | High — motion is byte-for-byte identical to `python.007`'s |
| `python.006` | 28 | **Hammer** | High — one quick ~55° blip at frames 1-3 (cocking), then rides rigidly with the frame for the rest of the animation |
| `python.007` | 105 | Part of the **crane/cylinder swing** (see below) | High for "moves with 005"; **which of 005/007 is the cylinder vs. the crane/ejector-rod arm is not resolved** — see below |
| `python.008` – `python.013` | 18 each | **The six chambered rounds** | High — each collapses to a point (extent 0) except a short live window inside frames 20-30 (each surface's own window varies by 1-2 frames, e.g. 008 live 20-29, 009 live 20-27, 011 live 20-29), which is exactly the cylinder's open window below |
| `python.014` | 257 | **The speedloader** | High — collapsed (extent 0) everywhere except frames 20-38; appears exactly as the cylinder opens |

### The swing — RESOLVED: a break-top, not a swing-out crane

The earlier read (WEAPON_LANE_STARTUP.md's table) measured `python.005` and `python.007`
**relative to `python.004`** and read them as two different parts because their absolute
travel differed. That was measuring the wrong thing. Measured **absolute** (rigid fit
against frame 0, no reference divided out):

- `python.004` (assumed frame) itself rotates **31.87°** absolute, settling frames 23-29 —
  the donor animation tilts the whole gun sideways as part of the reload flourish. This
  is bake-in from the source animation, not something a WM card would ever reproduce (per
  the project rule: numbers come from rigid fit, never from played animation frames).
- `python.006` (hammer) matches `python.004`'s 31.87° exactly after its own early blip —
  confirms it is rigidly mounted to the frame, consistent with "hammer."
- `python.005` and `python.007` both rotate **95.23-95.31°** absolute, matching each other
  to within measurement noise (rmsd ≈ 0.01-0.02, same as a clean rigid fit elsewhere in this
  project) — **one rigid assembly**, not two independent parts.
- **Relative to the frame** (divide out `python.004`'s own 31.87°): the assembly swings
  **≈63.4°** relative to the gun body, plateaued frames 21-29, transitioning frames 16-20
  (open) and 30-33 (close).

**Part identity — confirmed by frame-0 bounds (reload lane, cross-checked here):**

| Surface | Frame-0 size (long × wide × tall) | Identity |
|---|---|---|
| `python.005` | 4.7 × 4.3 × 4.2 | **Cylinder** — drum-shaped |
| `python.007` | 18.7 × 2.3 × 6.3 | **Barrel** (+ whatever rides under it) |

`python.004` is the grip frame alone — which is exactly why its own bounds (13.9 units)
never looked like "grip + barrel": the barrel isn't on the frame, it's on the swinging
assembly. **A barrel and cylinder locked together on one hinge, tipping away from a
grip-only frame, is a BREAK-TOP revolver** (Webley/Schofield-style: the whole top half
tips down to eject and reload), not a swing-out crane. The `python.*` names are leftover
from the donor mesh and name nothing about this gun.

### Hinge axis and pivot — measured

Reading the rotation axis off the rigid-fit rotation matrix directly (`axis = (R[2][1]−R[1][2],
R[0][2]−R[2][0], R[1][0]−R[0][1]) / (2 sin θ)`, since `rigid_fit`'s own returned `axis` field
is the *translation* direction, not the rotation axis) and solving the pivot by least squares
(`(I−R)p = t`, via the same SVD `md3.py` already uses for the fit itself — one singular value
comes back ~0, exactly the hinge's own null direction, confirming a clean single-axis hinge):

- **Axis: pure (0, 1, 0)** — straight across the gun, exactly what a break-top's hinge should
  be. Angle 63.07° (agrees with the plateau measurement above to 0.3°).
- **Pivot: (3.448, 0, −1.432)**, model space, `python.004`'s own rest frame. This sits toward
  the front of the frame (max x there is 4.56) at a middling height (frame z runs −8.83 to
  +4.16) — front-and-center rather than the extreme front-bottom a real Webley's stirrup latch
  sits at, but the singular-value check (one value ≈0, the other two equal and nonzero) says
  the fit is clean, not degenerate.
- Fit quality: assembly rmsd 0.094 (pooling `python.005`+`python.007` as one rigid body),
  frame body rmsd 0.012 — both well inside what this project already treats as clean.

Hammer (`python.006`), same method, its own early blip (frame 2 of 41): **axis (0, −1, 0),
54.66° about pivot (−3.36, 0, 1.094)**, fit 0.0087 — as clean as the M4A3's own hammer
measurement (0.012).

**Visually confirmed** (2026-09-13, owner asked for a check rather than trusting the math
alone): rendered with RS_ModelSwapper's own `tools_md3_render.py`, frame 0 against the open
frame with `python.004`'s own motion divided out first (so the frame itself sits still and
only the real relative displacement shows). The barrel+cylinder assembly swings down and
back, hanging below the frame — a break-top, matching the axis (0,1,0) measurement. Also
structural: **the barrel (`python.007`) moves with the cylinder** rather than staying on the
frame — a swing-out design never moves its barrel, so this alone would have ruled out a
crane even without the render.

Speedloader (`python.014`): hidden (extent 0) outside frames 20-38. Visible and moving
frames 20-38, peaking at 87 units of travel around frame 22-29 (a translation distance
relative to the frame — the loader is carried well away from the gun during that window,
consistent with "brought to the cylinder and used").

---

## Cola ("Vanilla") — `revolver.md3`, named surfaces, 55 frames — a SWING-OUT CRANE

Confirmed the other kind of revolver from Moonlight/Sunset: `Magazine_rod` (ejector rod) and
`Magazine.wheel` (cylinder) swing 90° together to the side on one hinge — a crane, not a
break-top — with a separate ejector stroke on `Bullet_set` once open. Two different
mechanisms on the two meshes; see the two separate card sketches below
(`mechanism = breaktop_revolver` for Moonlight/Sunset, `mechanism = swingout_revolver` for
Cola).

Reload plays frames ~28→54 (fire/trigger sits just before it, frames ~0-9 and ~28-30).

| Surface | Verts | Role (measured) | Confidence |
|---|---|---|---|
| `Revolver` | 1260 | Frame/body (reference) | — |
| `Magazine_rod` | 127 | **Ejector rod** — swings **90.0°** with the cylinder (frames 31-42, plateau 33-40), no separate spin afterward | High |
| `Magazine.wheel` | 368 | **Cylinder** — swings the same 90.0° with the rod, *and* additionally spins **180° in place** frames 45-53 (indexing/flourish after closing, dist stays ~0.2 so it's not still swung out) | High |
| `Bullet_set` | 900 | **All six rounds, as one surface** — moves with the cylinder's 90° swing, *and* has its own extra translation out to 19.7 units (frames 34-38, peak at 36) before returning — this is the ejector stroke (rounds pop out, then back for the reload) — *and* shares the cylinder's 180° indexing spin at frames 45-53 | High |
| `Bullet_holes` | 540 | Not yet measured (almost certainly the empty-chamber backs, cosmetic) | — |
| `Hammer` | 108 | Independent **~30° blip**, frames 0-6, unrelated to reload | High |
| `Trigger` | 42 | Independent **~30° blip**, frames 28-29, right at the reload's start (last shot's trigger pull) | High |

**Crane hinge, measured** (same rotation-matrix method as Moonlight/Sunset, pooling
`Magazine_rod`+`Magazine.wheel` as one rigid body against `Revolver`, frame 36 where both
plateau): **axis (−1, 0, 0)** — along the barrel, a pin running front-to-back, which is
exactly how a real crane hinges the cylinder out sideways like a door — **90.0° exactly**,
pivot (0, 0.029, −4.347), fit 0.017/0.014, singular values (0, 1.41, 1.41) — clean.
**Sign corrected 2026-09-13** (it read (1, 0, 0) here first): the fit's rotation matrix gives
(−1, 0, 0), and turning the cylinder's centroid +90° about −x lands it at (−0.54, +4.53,
−4.34) where the mesh has (−0.54, 4.56, −4.32); about +x it would swing into the frame.
`Bullet_holes` rides the crane too (same 90°, fit 0.012-0.015).

**Twelve chambers, not six**: `Bullet_set` is 36 separate pieces — a head, a body and a
tip for each of twelve rounds, 30° apart round the axis (y 0.03, z 0.10).

**Trigger hinge, measured**: axis (0, −1, 0), 30.17° about (−5.681, 0, −4.337), frame 28,
fit 0.010. **Ejector stroke**: `Bullet_set` relative to the cylinder moves along pure −x,
18.74 units at its peak (frame 36).

**Visually confirmed**, same method as Moonlight/Sunset's own check below: with `Revolver`'s
own motion divided out, the cylinder+rod assembly splits off as a distinct blob sitting
*beside* the frame in the TOP and FRONT views — sideways displacement, not downward.
Structural check too: **the barrel stays on `Revolver`** (the frame surface) here, unlike
rev.md3 where it rides the swinging assembly — barrel-stays-put is the swing-out signature.

**Hammer hinge, measured** (`Hammer` against `Revolver`, frame 6, its own early blip):
**axis (0, −1, 0), 29.98°**, pivot (−11.685, 0, −2.063), fit 0.009 — clean, same axis
convention as every other hammer measured in this project.

**No speedloader surface, confirmed** — `Bullet_set` is the six rounds moving and ejecting
as **one rigid group**, never six independent chambers. This is worse than "no speedloader
surface" for our purposes: it also means Cola's own mesh cannot show three-live/three-spent
mid-reload even if we wanted to drive it directly — `WM_Store`'s SLOTTED kind (BUILD.md
§2/§3) is exactly built for that distinction and this mesh cannot display it. Cola works
fine as the "compare a second model" gun BUILD.md's grammar accepts, but it should not be
the mesh a `mechanism = revolver` slotted-chamber design is validated against.

---

## The speedloader decision (WEAPON_LANE_STARTUP.md §3, "bring the choice to the reload lane")

Two options, cheapest first:

1. **`python.014`, extracted into its own MD3** (`tools/md3_write.py extract`, the same tool
   that made the pistols' dropped-mag meshes), used as the ammo prop for both Moonlight and
   Sunset. Not "surgery" in the sense BUILD.md worries about — `md3_write.py extract` already
   exists and already does exactly this for the pistol magazines; it is a proven tool being
   pointed at a third mesh, not a new capability.
2. **Drive the surface in place** (`SetModelSurfaceDrive` on `python.014`, hidden by default,
   revealed and moved only during the loading window) — avoids a second file, but ties the
   ammo prop's shape to a fully rigged, name-addressable slot the moment it's needed as a
   detachable, thrown, pouch-able object — everything `WM_LooseMag` already does for a
   magazine. Extracting it is the smaller change measured against what a loose object already
   needs to do.

**Recommend option 1** — extract `python.014` the same way the pistol magazines were made,
since the tool and the precedent both already exist and a loose speedloader needs to be a
free-standing thrown/pouched object exactly like `WM_LooseMag` regardless.

Cola's `Bullet_set` cannot supply a speedloader at all (six rounds, one rigid group, no
separate loader geometry) — if Cola ships, it needs Moonlight's extracted speedloader mesh
reused as its ammo prop too (WEAPON_LANE_STARTUP.md's option 2 for Cola specifically),
since there is nothing on Cola's own mesh to extract.

**Done 2026-09-13, then re-done**: first extracted at frame 22, in the donor's tilted
reload pose. **Replaced** the same day by `python.014` at **frame 26**, where it sits seated
against the cylinder holding its own six rounds, carried into the cylinder's rest frame
(so its axis is the gun's x), re-origined and stood so it goes in UPWARD like a magazine
(−x points down). Same file name, `wm_speedloader.md3`. `wm_cola_rounds.md3` was re-made
the same way (Bullet_set at rest, in the cylinder's frame, stood up), so both loaders sit
alike on the shared held-magazine sliders.

---

## The revolver archetypes — cards on paper, today's `verb`/`store` grammar (BUILD.md §3-4)

**BUILT 2026-09-13** -- the sketches below are the paper that led to it, kept as the record.
What shipped is `archetype breaktop_revolver` and `archetype swingout_revolver` in
RS_VR_Reload/WMCARD.txt and the real Moonlight, Sunset and Cola cards in this package's
WMCARD.txt; the grammar it needed is in RS_VR_Reload/BUILD.md section 3, "Keys added for the
revolvers". Where the sketches and the cards differ, the cards win (the break verb is `open
break` on part `barrel`; Cola's crane axis is -x; Cola has twelve chambers; the load zones
take a speedloader and ride the moving part; Cola ejects by the muzzle, not a rod part).

### `mechanism = breaktop_revolver` — Moonlight / Sunset (rev.md3)

```
store cylinder  kind = slotted  slots = 6  indexed = yes  advance = onshot end

# ONE part, two surfaces -- barrel and cylinder are rigidly one assembly on
# one hinge (reload lane's call: repeated `surface`, not `follows` -- see
# the grammar note below).
part topbreak
  subject = foregrip
  surface = python.007      # barrel
  surface = python.005      # cylinder
  dof kind = hinge  axis = 0, 1, 0  degrees = 63.07  pivot = 3.448, 0, -1.432 end
end

part hammer
  subject = hammer   surface = python.006
  dof kind = hinge  axis = 0, -1, 0  degrees = 54.66  pivot = -3.36, 0, 1.094 end
end

open topbreak
  part = topbreak   openat = 0.85   rest = stay
  onopen = ejectall   from = cylinder
  # no `latch` -- see G-R1, neither mesh shows a separate latch surface
end

load chamber
  into = cylinder   slot = next   subject = round
  needs = open:topbreak
  at = MEASURE   size = MEASURE   # per-chamber point -- blocked on G-R3
end
```

### `mechanism = swingout_revolver` — Cola (revolver.md3)

```
store cylinder  kind = slotted  slots = 6  indexed = yes  advance = onshot end

part crane
  subject = foregrip
  surface = Magazine.wheel   # cylinder
  surface = Magazine_rod     # ejector rod -- rides the same hinge, see below
  dof kind = hinge  axis = 1, 0, 0  degrees = 90.0  pivot = 0, 0.029, -4.347 end
end

part hammer
  subject = hammer   surface = Hammer
  dof kind = hinge  axis = 0, -1, 0  degrees = 29.98  pivot = -11.685, 0, -2.063 end
end

open crane
  part = crane   openat = 0.85   rest = stay
end

eject rod
  part = crane  at = 0.85  from = cylinder  all = yes  needs = open:crane
  # Magazine_rod's own extra translation (the ejector STROKE, distinct from
  # the 90 deg swing) is not expressible as a second motion on a part already
  # declared by its hinge -- see G-R5.
end

load chamber
  into = cylinder   slot = next   subject = round
  needs = open:crane
  at = MEASURE   size = MEASURE   # blocked on G-R3
end
```

Cola's `Bullet_set` (all six rounds, one rigid group — see above) cannot drive individual
chamber state once loaded; this archetype's `store cylinder` slotted state would exist in
the simulation but the mesh can't display three-live/three-spent. Fine for comparing feel,
not for validating the slotted-chamber design end to end — Moonlight/Sunset's mesh has
individually addressable rounds (`python.008`–`.013`) and should be the one that design gets
proven against.

**Gaps beyond what BUILD.md's own worked example already lists as pending (steps 1-3, 7, 8,
9, 11):**

- **G-R1. No `latch` surface identified on either mesh -- still none, and not needed.** The
  cards open by hand with no latch; `closeat` (shut again only back at 0.05) is what keeps a
  half-closed gun from firing. Revisit only if a headset test says it opens too easily.
- **G-R2. RESOLVED by the reload lane**: one `part` with two repeated `surface` lines (the
  break-action double's own pattern), not `follows`. `follows` is for a leader/follower
  sharing one DOF value at different rates (the pump's bolt-follows-forend); barrel+cylinder
  and crane+rod are each rigidly one physical assembly on one hinge, which repeated
  `surface` already expresses with no new key.
- **G-R3. CLOSED 2026-09-13.** Per-chamber load points were not needed: a speedloader fills
  every empty chamber at once from ONE zone on the cylinder's rear face (`subject = loader`),
  and a single round fills the next empty one there too. For the display, the six Moonlight
  rounds' SEATED positions were measured -- frame 20, against the cylinder's own motion (fit
  0.093), centroids on a 1.4-unit circle about (y 0, z 0.98) -- and built into `rev_wm.md3`.
- **G-R4. RESOLVED for this pass**: the rotation axis (not `part_motion`'s translation-only
  `axis` field) is read off the rigid-fit rotation matrix directly — `axis = (R[2][1]−R[1][2],
  R[0][2]−R[2][0], R[1][0]−R[0][1]) / (2 sin θ)` — and the pivot by least-squares solving
  `(I−R)p = t` via the SVD `md3.py` already has. Both revolvers' hinges and hammers above
  used it; worth folding into `md3.py`'s own `part_motion` output as a small addition so the
  next mechanism doesn't need a one-off script.
- **G-R5. CLOSED 2026-09-13 by choice of mechanism.** The ejector is `eject rod` with
  `by = muzzleup`: with the crane open, pointing the muzzle up past 0.70 (about 44 degrees)
  throws every case out of the back of the cylinder. Chosen over a hand-pushed rod because
  the rod rides the crane's hinge and a push would be a second motion on top of it (no card
  or engine grammar composes that), and because the tilt leaves the other hand free for the
  loader. The measured stroke (Bullet_set, 18.74 units along -x) sets the eject direction.

---

## Built -- 2026-09-13 (the STOPGAP cards are gone)

The stopgap pistol-grammar cards (hammer as a slide, speedloader as a magazine, brass on every
shot) were deleted and replaced by real cards on two new archetypes.

**Moonlight (main) and Sunset (off), `mechanism = breaktop_revolver`.** Part `barrel` is
`python.007` + `python.005` on the measured hinge (0, 1, 0), 63.07 degrees about (3.448, 0,
-1.432) -- direction checked: the barrel centroid turned +63.07 lands at (7.655, 0, -3.076),
the mesh has (7.676, 0, -3.027). The six rounds are `roundsurface`s of that part, one per
chamber slot, so they ride the barrel and vanish when their chamber is thrown out. `hammer`
is `python.006`, (0, -1, 0) 54.66 about (-3.36, 0, 1.094), `cock = trigger`. Store `cylinder`:
6 slots, indexed, turns on the shot. Load zone at the rear face (-3.46, 0, 0.98) riding the
barrel.

**`rev_wm.md3`** (models/revolvers/Revolver/) is `rev.md3` made for this: ONE frame (rest), the
six rounds' frame-20 geometry carried by the inverse of the cylinder's frame-0-to-20 rigid
fit into the cylinder's rest frame and pushed along x so each rim stands 0.17 proud of the
rear face; `python.014` (collapsed) left out. Read back by md3.py, worst vertex 0.008; a
front-view render shows six rounds on the chamber circle. `rev.md3` is still in the package,
drawn by nothing.

**Cola (off), `mechanism = swingout_revolver`.** Part `crane` is `Magazine.wheel`,
`Magazine_rod`, `Bullet_holes`, with `Bullet_set` as a `roundsurface` on `any` slot; hinge
(-1, 0, 0) 90 about (0, 0.029, -4.347). Hammer (0, -1, 0) 29.98, `cock = trigger`; trigger
(0, -1, 0) 30.17 about (-5.681, 0, -4.337). Store `cylinder`: **12** slots. Load zone at
(-8.8, 0.03, 0.10) riding the crane. Eject: muzzle up (G-R5).

**The speedloader.** The pouch hands a revolver a loader of up to its capacity from the Clip
reserve, drawn as the card's magmodel and held on the held-magazine sliders; let go of in the
open cylinder's zone it fills every empty chamber at once and is then spent: it drops as a
loose empty loader that fades after `wm_round_life` (`wm_loader_spent_drops` on, the
default) or vanishes (off). A loader with rounds left drops with them. Both loaders
(`wm_speedloader.md3`, `wm_cola_rounds.md3`) were re-extracted so they stand upright.

**Firing.** Double action: each pull fires the chamber under the hammer and turns the next
one round; a pull on an empty or spent chamber clicks and turns it. The case stays in its
chamber (no brass per shot). Opening puts the gun out of battery; so does a barrel or crane
not back to `closeat`. Shot numbers are the weapon class's (revolvers.zs).

**Sounds** (SNDINFO `wm/revolver/*`): the pistol pool's 9mmshoot for the shot, PCOUT opening,
PSNAP shutting, 9mmclip2 for the loader. No revolver foley exists in the project yet.

**Not done, and why:**
- The cylinder does not visibly turn a chamber per shot: it shares the barrel's (or crane's)
  hinge drive slot, and the engine's per-slot extra rotation is refused on a hinge drive.
- A map clip grabbed through RS_WorldHands still becomes a PISTOL magazine, not a speedloader:
  the become service is not told which player grabbed it, and choosing by the console
  player's hands would break the netplay rule. The pouch is the speedloader's source.
- No latch (G-R1). Licence/credit still unrecorded (see the top of this file).

## Task 2 status against WEAPON_LANE_STARTUP.md section 3 "Steps"

1. **Parts identified** -- done, and corrected: Cola's crane axis is (-1, 0, 0) and it has
   twelve chambers.
2. **Copied in** -- done; `rev_wm.md3` derived from `rev.md3` for the seated rounds.
3. **Speedloader** -- extracted, then re-extracted seated and upright; Cola's loader likewise.
4. **Cards** -- BUILT, on two archetypes (above). G-R1 open (not needed), G-R2/G-R4
   resolved, G-R3/G-R5 closed.
5. **In hand, shooting** -- real mechanism; slot 4, carried; "Revolvers into both hands" and
   "Cola revolver into the off hand" on the revolver page (netevents `wm_giverevolvers`,
   `wm_givecola`).
6. **Shot values** -- the weapon class's (revolvers.zs), owned by the weapons lane.
