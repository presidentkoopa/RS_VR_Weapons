# The grenade and the ShieldSaw — meshes ready for their cards (2026-09-14)

The owner brought RS_Grenade and RS_ShieldSaw into the weapon set.
- **ShieldSaw:** it keeps everything: held, the saw's deploy and spin, the throw, the route lock and the return
  to the hand.
- **Grenade:** it builds on RS_Grenade (RSVG_Ammo, RSVG_Blast and RSVG_Pickup by name).
- **Cards:** they wait for the reload lane's THROWABLE archetype.
- **VELOCITY-BASED, REAL VR MECHANICS (the owner, 09-14):** "make sure they are both velocity based" / "we want
  real vr mechanics".
  - Both throw by the hand's real controller velocity at release, through RS_WorldHands' shared thrower
    (RS_ThrowService, on the engine's AttackVel / OffhandVel). No button throw, no scripted arc.
  - The pin pull, the lever release and the ShieldSaw's catch on return are done with the hands.
  - Netplay: velocities read zero in a netgame today. How the thrower keeps a throw in sync is for the reload lane
    to confirm before the archetype relies on it.
- **Model examination:** `GRENADE_SHIELDSAW_MODEL_REPORT.md`.
- **Build scripts:** in the weapons session scratchpad, `grenade/build_mesh.py` and `shieldsaw/build_mesh.py`.
  Both copy vertex records, UVs and triangles byte for byte (md3_raw), then verify them against the donor.
  Renders with `tools/md3_render.py` show each mesh inside its header bounds.

All numbers below are in MD3 model units, in each new mesh's own space.

## Grenade — `models/grenades/grenade_wm.md3` (skin `nade.png`, already beside it)

- **Source:** RS_Grenade `nade.md3`, frame 2. Frame 2 is byte-identical to frame 3: the body upright, the pin
  home, the lever shut.
- **Origin:** moved to the body's bounding-box centre, by whole 1/64 steps (-28.4062, 0, +1.2188). Positions
  move exactly; every packed normal is the donor's byte for byte.
- **Surfaces:**

  | id | from | verts | extent |
  |---|---|---|---|
  | `body` | low_lowbodymesh (s0) + the fuze bushing low_button01mesh (s4) | 1570 | x ±3.95, y ±3.95, z -8.52..8.50 |
  | `pin` | low_ring02mesh (s2): pull ring, shaft, eyelet | 535 | x -4.80..1.31, y -1.48..5.34, z 3.38..8.09 |
  | `lever` | low_button01mesh (s3): lever and lugs | 542 | x -4.81..2.92, y -0.92..0.91, z -3.05..8.41 |

  The donor's 3-vertex stray triangle (s1) is dropped.
- **Grip:** the body centre, which is the origin.
- **Pin: a rigid slide along +Y (0, 1, 0), measured against the still body.** It travels 2.31 (f4), 9.02 (f5),
  17.61 (f6), then 24.65 (f7), rigid to rmsd 0.008. From f8 it deforms (rmsd 0.5 to 2.0), the donor collapsing
  it. **Full pull: 24.65.**
- **Lever: a hinge about +Y (0, 1, 0) through (2.08, -0.02, 7.02), near the top hook.** The pivot holds exactly
  for 34.1° (f11) and 45.0° (f12), rigid to rmsd 0.01 with the body's own motion divided out. Past 45° (f13) the
  pivot moves: the lever flies off. **Hinge: 45°, then released.**
- **In hand:** the report suggests Scale ~0.56 (17.0 × 0.56 × 0.34 ≈ 3.2 map units), placed from the origin.

## ShieldSaw — `models/shieldsaw/ShieldSaw/shieldsaw_wm.md3`

**Skins:** `shieldsaw_HD.png` for `face` and the blades; `shieldsaw_b_HD.png` for `back`, `rim` and `rimopen`.
In MODELDEF that is `SurfaceSkin` for surfaces 0-2, or Skin plus SurfaceSkin.

- **Source:** RS_ShieldSaw's held `shield.md3` (the back half) and `shieldsaw.md3` (the face and 16 blades).
  Its MODELDEF draws the two in one space, so they are merged with no transform, and the origin stays as authored,
  beside the grip bar.
- **Surfaces:**

  | # | id | from | verts | note |
  |---|---|---|---|---|
  | 0 | `back` | shield_holder + shield_bolt + shield_handle + shield_back, f0 | 975 | checked static on every frame; the grip bar is in here |
  | 1 | `rim` | shield_rim f0 | 185 | closed |
  | 2 | `rimopen` | shield_rim f3 | 185 | 0.83 wider, the donor's pose while the saw runs |
  | 3 | `face` | shield_front f0 | 3528 | checked static on every frame |
  | 4 | `bladesstowed` | 16 saw_blade surfaces, f0 | 2656 | teeth in: x -38.80..19.94, z ±29.3 |
  | 5 | `blades` | the blades, f7 | 2656 | deployed; one tooth pitch (22.5°) on from f4, so it reads as deployed at rest |
  | 6 | `blades2` | the blades, f5 | 2656 | a spin pose, -7.1° from f4 |
  | 7 | `blades3` | the blades, f6 | 2656 | a spin pose, -14.7° from f4 |

  RS_ShieldSaw's own spin cycles f5, f6, f7 at a tic each. Our parser's `flip` alternates two parts
  (flipphase 0 and 1), so the card picks two of these three. The deploy (f1-f4) is not baked: the card shows
  `bladesstowed`, then `blades`.
- **Grip:** the D-handle's grip bar, 18.1 long along Z, centred (4.68, 2.17, -0.80) (the report's measure; no
  transform was applied).
- **Disc:** centre around (-9.4, _, 0), with the face towards -Y.
- **Possible thumb controls:** the central boss (in `back`), or the face's two side lugs at x -36.7 and +17.8.
  Neither moves in the mesh.
- **In hand:** the report suggests Scale 1.0. The X-scale sign (which side the face is on) and the yaw get settled
  in the headset. Place it from the grip bar.
- **Not taken:**
  - `shield_saw.md3`: its provenance is not cleared.
  - The hand meshes: RS_WorldHands draws the hands.
- **Flight meshes, BROUGHT IN 09-14** (the reload lane's card draws its own flying disc), byte-identical from
  RS_ShieldSaw into `models/shieldsaw/ShieldSaw/`:
  - `shield_weapon.md3`: 3 surfaces. 0 face and 2 rim take `shieldsaw_HD.png`, 1 back takes `shieldsaw_b_HD.png`.
    56.56 across, 16 frames of spin; a total world-path scale of 0.3483 matches the held shield's 19.70 map units.
  - `shield_weapon_glow.md3`: 72.7 across, skin `shieldsaw_glow.png` (copied too).
