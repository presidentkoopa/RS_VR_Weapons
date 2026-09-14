# RS_Grenade and RS_ShieldSaw -- model examination for the VR weapon set

Read-only examination by the build lane's agent, 2026-09-14. Nothing edited, built or launched.
Renders and logs: this folder (`renders\`, `log_*.txt`). Tools: md3.py, RS_ModelSwapper/tools_md3_render.py,
scratch exam scripts (island split, per-island motion fit vs the body, normals/winding tests). Every render viewed.

## Engine facts used
- Hand path: models.cpp:1839 `followHandUnitScale = 0.01` (commit 9388202c23, 2026-09-09) -> 1 model unit at Scale 1 = 0.34 map units.
- Models are back-face culled only for non-Normal render styles or FORCECULLBACKFACES (hw_models.cpp:55/:92): reversed winding is invisible at Normal; wrong normals only affect lighting.
- 64 MD3 surfaces per model (model.h:50). OBJ surfaces with no skin are skipped (models_obj.cpp:652-654).

## Reference guns (barrel +X, up +Z, placement yaw -90)
| mesh | length (mu) | MODELDEF Scale | Offset | in hand (map units) |
|---|---|---|---|---|
| m4a3 | 31.2 | -0.82 | 0.013 -28.103 -8.435 | 8.7 |
| Doom shotgun | 61.8 | 1.35 | 0.042 -41.745 -4.028 | 28.4 |
| chainsaw_wm | 53.2 | 1.35 | -2.468 -45.120 -15.378 | 24.4 |

## 1. nade.md3 (RS_Grenade) -- byte-identical copy already in RS_VR_Weapons models/grenades/ (WM_LauncherGrenade)
Surfaces (all nade.png; nade_red.png exists; nade_n.png unused):
- s0 low_lowbodymesh 1427v/2143t body; s1 low_lowbodymesh 3v/1t stray triangle; s2 low_ring02mesh 535/800 pin;
  s3 low_button01mesh 542/778 lever; s4 low_button01mesh 143/216 fuze bushing. Duplicate names s0/s1, s3/s4 -> rename before a card can address them.
Frames (27, whole-body first-person animation):
- f0 raise start, body tilted 45 deg; f1-2 body turns 45 deg and moves 21.7 units to upright.
- f2-10 body still; pin assembly (all s2) slides straight out +Y: 2.3, 9.0, 17.6, 24.6 by f7, rigid (fit 0.01); f8-9 shrinks; f10+ collapsed.
- f11-15 lever swings about Y: 34/45/62/80/87 deg; for the first 45 deg the pivot is fixed at (25.65, 0, -17.45) frame-0 coords
  (1.5 units from the top hook); beyond that it flies off.
- f16 lever+pin hidden, body upright ("lever flown"); f17-26 throw, body tumbles to 175 deg. RS_Grenade uses only f0 (safe) and f16 (live).
Islands: s0 body cylinder (537), ribbed base cap (442), fuze collar (167), fuze cap (106), fuze nose/lever bracket (58), pin boss (43), 2 rivets;
s2 pull ring (147) + pin shaft (52, 2.34 long along Y) + eyelet (336), move together; s3 lever (444) + 2 lugs (49 each); s4 static bushing.
=> body, pin, lever already separate.
Size/orientation: upright (f2-16) 17.0 tall x 7.9 across; fuze +Z, lever on -X face, pin ring on +Y side pulled along +Y.
Origin far from body: body centre (28.41, 0, -1.23) at f2, (19.49, 0, -20.74) at f0. Grip = body centre.
In hand like our guns: Scale ~0.56 (17.0 x 0.56 x 0.34 = 3.2 map units, a 0.1 m grenade; RS_Grenade's psprite 0.5643 is right for this path);
no rotation if the rest pose comes from f2-f10 (f0 needs ~45 deg about Y); Offset from the body centre.
Normals: winding matches reference guns; stored normals in a Y-up basis (agreement -0.23 vs -0.86..-0.92 good; rotated (x,-z,y) -0.77);
half of each view reads red; m4a3 has the identical defect; lighting only.
Existing-mod risks (reported, not fixed):
- RS_Grenade's held grenade effectively INVISIBLE: RS_VRGrenadeHeldMain/Off (default, rsvg_psprite=false) Scale 0.005642 set 09-05, before the
  engine's x0.01 change on 09-09 -> draws 0.03 map units long.
- Live grenade drawn ~10 map units off its actor: PivotOffset (5.848 0 -8.597 at Scale 0.3) measured at f0; at f16 body centre is 32.7 mu from it
  (9.8 map units). Affects RS_VRGrenadeThrown and WM_LauncherGrenade (always f16): both orbit the actor while tumbling. Safe->live also jumps
  7.6 map units and turns 45 deg.
- Thrown at Scale 0.3 = 5.1 map units vs held 0.5643 = 3.3 (1.6x smaller). Minor: duplicate names, stray triangle, orphaned MODELDEF comment fragments.

## 2. RS_ShieldSaw
Provenance: README says the shield came from Rusted Legacy via RS_ForceUnleashed (Ermac's Force Unleashed, owner-cleared per LANE_BRIEF). No licence file in either mod.
### shield.md3 (back half)
Surfaces (shieldsaw_b.png; MODELDEF shieldsaw_b_HD.png): s0 shield_holder 120/76 (plate behind handle, 29x20); s1 shield_bolt 67/65 (central boss);
s2 shield_handle 206/170, 7 islands = D-handle: i0 grip bar 18.1 long along Z centred (4.68, 2.17, -0.80), i1-i2 end blocks, i3-i6 two pairs of standoff arms;
s3 shield_back 582/922 (2 islands: back plate + detail layer); s4 shield_rim 185/366 (actually the full front disc).
Frames: 4 ("closed to open") but nothing moves rigidly; only the rim disc widens 56.88 -> 57.67 -> 58.48 (+2.8%).
Bounds 57.9 across XZ, 12.3 deep Y; disc centre (-9.4, _, 0), face -Y; origin next to the grip; stored frame bounds don't enclose the mesh.
Normals: holder/back/rim outward OK; bolt/handle in a rotated basis; holder/bolt/handle/back wound opposite to our set (only matters translucent).
### shieldsaw.md3 (saw face + blades, same space)
s0 shield_front 3528/3651 (15 degenerate tris); s1-s16 saw_blade.002-.017 166/160 each (shieldsaw.png; HD override exists).
s0 islands (29): front dome, inner saw-track ring (50 across), 8 raised wedges + 8 flat bases, 2 side lugs (x -36.7 / +17.8), 9 studs.
Each blade: hooked tooth (89v) + round root (77v).
Frames: face still. f0-4 deploy: tooth radius 27.46 -> 33.24 (tip 29.26 -> 35.04), each tooth swings out up to 45 deg on its root, root moves out 2.9.
f4-7 spin: ring turns about disc centre -7.1/-7.6 deg per frame; at 22.5 deg tooth pitch, looping 5-6-7 wraps by -8.1 deg -> reads continuous.
Bounds 58.7 x 8.0 x 58.5 at f0, 70.1 across teeth out; sits in front of shield.md3 at y -16..-8. Normals outward; all 17 surfaces wound opposite our set.
Held shield, composite (shaded_composite_shield0_blade0_hand1.png): 0.58 m across (0.70 teeth out) = 19.7 map units at Scale 1; hand frame 1 is a fist
round the vertical grip bar, origin inside that fist. For our set: Scale 1.0 (same space as the set's other Ermac guns: Scale -1.0 1.0 1.0, Offset 0 -24 -10);
X-scale sign decides which side the face is on (original -1; RS_ShieldSaw now +1 with NOAUTOREVERSE); face points -Y with the bar vertical as authored --
forward vs outward is a headset decision; Offset from the grip bar.
### shield_saw.md3 -- UNUSED alternative
42 surfaces all "PorterMesh*" (shield_saw.png), 10,245v/10,960t, 8 frames (teeth deploy+spin on 32 small surfaces), 60.7 across x 20.7 deep,
winding matches, normals permuted. Referenced by nothing; textures ~3.5 MB in the zip.
RISK: names look like an asset-extraction tool's output and the design matches DOOM: The Dark Ages' Shield Saw; source unrecorded -> treat as NOT cleared.
### shield_weapon.md3 (thrown shield)
shield_weapon 100/158 (shieldsaw.png), shield_weapon_back 128/126 (shieldsaw_b.png), shield_weapon_rim 278/492 (shieldsaw.png).
Islands: face disc; back plate + inner layer; 16 teeth. Frames 16: f0-12 one full turn about Y easing in/out; f12-15 body held, teeth turn +7/19/26 deg;
3.5 deg pop when looping to f0. Bounds 56.6 x 4.2 x 55.9 centred on origin. Winding matches; normals swapped+inverted.
RISKS: MODELDEF `Skin 0 "shieldsaw_b_HD.png"` overrides every surface, so face and teeth draw with the back-plate texture (UVs laid out for shieldsaw.png)
-> needs SurfaceSkin for surfaces 0 and 2. On a plain world actor at MODELDEF 1.0 x actor Scale 0.55 it is 31 map units across, ~1.6x the held shield.
### shield_weapon_glow.md3
1 surface shield_glow 61/88 (shieldsaw_glow.png exists), 1 frame, shallow dome 72.7 across; used by RS_ShieldTrail and RS_ShieldLockMark (no Skin line,
mesh shader resolves); winding matches (translucent trail stays visible); normals basis-swapped.
### Other RS_ShieldSaw findings (for its own lane)
- Stowed shield oversized: 57.9 map units across on the back at defaults (MODELDEF 1.0 x rs_ss_mount_scale 1.0), ~2.9x the held shield.
- Mount marker draws nothing: diamond OBJ has no material, the block has no Skin, nothing passes a skin through A_ChangeModel.

## 3. hand.md3 / hand2.md3
One surface each (fist1/fist2), 1021v/1693t, hand.png (MODELDEF hand_HD.png exists); ao/m/n/r maps unused. One island each (welded glove).
Frames: animation libraries (hand.md3 211, hand2.md3 196). hand.md3 f2-5 straight punch (+X 8.6, 18.9, 18.9, 8.6); hand2.md3 many 90-177 deg turns (swings/throws).
RS_ShieldSaw uses only hand.md3 f1; nothing references hand2.md3.
hand.md3 f1: 17.0 x 10.6 x 13.0 centred on origin, gloved fist, cuff -X, vertical tunnel closing round the shield grip bar; 0.17 m at Scale 1 (a bare fist;
RS_WorldHands' hand_left.iqm is 0.33 m incl. forearm). The two meshes are an opposite-handed pair. Winding matches; normals axis-permuted (hand2 also inverted).
Conflict with RS_WorldHands: none at defaults (rs_ss_world on -> applyModel sets psp.NoDraw, rs_shieldsaw.zs:653; world props carry no hand). With rs_ss_world off
and rs_ss_handmodel on (its default), hand.md3 draws as a second hand where RS_WorldHands' hand is. For our set: bring in neither hand; use hand.md3 f1 only as the
reference for where the fist grips.

## 4. rs_ss_diamond.obj
32v/32t, 4 islands = four bars of a wireframe diamond (open tubes), radius 1.03 flat in XY, 0.09 thick; byte-identical to RS_HardPoints/models/rs_hp_diamond.obj.
Used by RS_ShieldMountMarker (Scale 4, then A_SetScale(reach*0.25)), the shoulder mount marker -- draws nothing (no material/skin). HardPoints avoids it by passing a skin
through A_ChangeModel (RS_HardPointProp.zs:161). Not a weapon part.

## 5. Recommendations
### Grenade -- usable, best structured
- Parts: body = s0+s4; pin = slide along +Y, 24.6 mu rigid (~4.7 map units at Scale 0.56); lever = hinge about Y at (25.65, 0, -17.45), 45 deg, then released.
- Mesh work (script): write an upright f2/f3 as a one-frame _wm mesh, origin to body centre, rename surfaces body/pin/lever, drop the stray triangle.
- Card: the reload system has pump, breaktop_revolver, swingout_revolver, breakaction only -> needs a general THROWABLE archetype (reload lane), verbs for a part pulled
  off and dropped (pin), a part released on letting go (lever), the whole weapon thrown.
- "Reload": an empty hand reaches to a belt pouch/hardpoint and takes a fresh grenade (RSVG_Ammo as the store); the other hand or the vest pulls the pin along its slide,
  past a threshold armed; grip holds the lever, letting go throws.
- Scale ~0.56; Offset from body centre.
- OWNER DECISION: RS_VR_Weapons already uses RSVG_Ammo, RSVG_Blast, RSVG_Pickup by name -- does the set's grenade REPLACE RS_VRGrenade in slot 9 or WRAP it?
### Shield saw -- usable as a held prop; only the blades move
- Mesh work: merge shield.md3 + shieldsaw.md3 into one mesh (shared space), like the other merged _wm meshes.
- Surfaces: body; blades in 2-3 baked poses (f0 stowed, f4 out, f5-7 spin) flipped while the trigger is held, like the chainsaw's chain/chain2 -- avoids spending all 16
  surface-transform slots (RS_ShieldSaw's own comment says per-tooth driving would need them). Deploy as a flip or an estimated slide.
- Grab points: grip bar = hand seat (4.68, 2.17, -0.80), 18 units along Z; possible thumb controls: central boss (shield_bolt) or the two side lugs (s0 i10/i11) -- they
  don't move in the mesh, so any motion would be estimated.
- Throw: needs the same throwable archetype. RS_ShieldSaw's route locking and return are gameplay, not card data -> OWNER DECISION: does the card cover only the held weapon?
- Hands: leave hand.md3/hand2.md3 out; RS_WorldHands draws the hands.
- Scale 1.0; X-scale sign and yaw (face forward vs outward) settled in the headset; Offset from the grip bar.
- Do NOT use shield_saw.md3 (provenance not cleared).
