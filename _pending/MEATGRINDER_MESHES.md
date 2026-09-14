# The MeatGrinder family — _wm meshes for the reload lane's cards (2026-09-14)

**Scope:**
- Seven guns. The ids are frozen by doomwork-5e; the cards come from uzdxrema-63.
- **Classes, props, MODELDEF, placement and pages:** `zscript/rs_vr_weapons/meatgrinder.zs` and the package lumps.
- **Build script:** the weapons session scratchpad `mg/build_all.py`. Its report is `mg/build_all.txt`, and the part
  analysis is `mg/analyse.py` / `mg/analysis_all.txt`.

**How each mesh was made:**
- **Source frame:** the rest frame, written as the only frame.
- **Surface names:** one unique name per part, merged or split from the source surfaces. Every source surface is
  used exactly once.
- **Byte for byte (md3_raw):** vertex records, UVs, shaders and triangles are copied, not re-encoded.
- **Re-origin:** the whole mesh moves so its rest vertex centroid is on the origin, in whole 1/64 steps (the rule
  `tools/md3_reorigin.py` uses). To carry a measurement from the source into the _wm, subtract the shift.
  - The Bolter is not moved: it is RS_ModelSwapper's already re-centred `MS_MG_Bolter`. Its re-centre from RS_Main's
    Bolter is (37.6719, 0.2031, -4.4688), as uzdxrema-63 measured it from the trigger.
- **Checks:**
  - every position is the source minus the shift exactly;
  - every packed normal is identical;
  - `tools/md3_render.py` puts each mesh inside its header bounds.
- **MODELDEF Offset:** `(-shift_y, -shift_x, zoffset + shift_z) x |Scale|`, RS_ModelSwapper's compensation. The script
  reproduces `MS_MG_Bolter`'s block exactly.
- **Scale in hand:** 0.34 map units per model unit at |Scale| 1, so 0.340 for the assault shotgun and 0.374 for the six
  MeatGrinder meshes.

| Class | Hand | Mesh | Source (rest frame) | Shift | Scale / Offset |
|---|---|---|---|---|---|
| WM_AssaultShotgun | main | `shotguns/AssaultShotgunGH/assaultshotgun_wm.md3` | RS_GH AssaultShotgun (4) | 54.6562, -0.0469, -0.9062 | -1.0 / 0.047 -54.656 -5.906 |
| WM_BullpupPump | off | `shotguns/BullpupPump/bullpuppump_wm.md3` | MeatGrinder SSG (0) | 41.2656, 0, 0.7031 | -1.1 / 0.000 -45.392 -5.227 |
| WM_Bolter | off | `plasma/Bolter/bolter_wm.md3` | RS_ModelSwapper MS_MG_Bolter (0) | none | -1.1 / -0.223 -41.439 -10.916 |
| WM_BFGRifle | main | `bfg/BFGRifle/bfgrifle_wm.md3` | MeatGrinder BFG (0) | 53.5469, -0.0781, 0.6094 | -1.1 / 0.086 -58.902 -5.330 |
| WM_RotaryGun | main | `chainguns/RotaryGun/rotarygun_wm.md3` | MeatGrinder ChainGun (0) | 60.8281, 0.4688, -4.9688 | -1.1 / -0.516 -66.911 -11.466 |
| WM_RotaryLauncher | off | `launchers/RotaryLauncher/rotarylauncher_wm.md3` | MeatGrinder RPG (0) | 54.9375, 0.1250, -7.3281 | -1.1 / -0.138 -60.431 -14.061 |
| WM_LongbarChainsaw | main | `chainsaws/LongbarChainsaw/longbarchainsaw_wm.md3` | MeatGrinder Saw (0) | 66.1562, 2.5312, -0.3281 | -1.1 / -2.784 -72.772 -6.361 |

## Parts

All coordinates below are in each _wm's own space.

- **WM_AssaultShotgun.**
  - `body`: Sights + Frame + Sights.
  - `chargehandle`: the whole Receiver, 38 verts. It slides 10.00 along -X.
  - `trigger`: s5. It hinges 19.9° about Y.
  - `mag`: s6, centroid (-10.06, 0.06, -9.46). It drops 28.0 along -Z.
  - `shell`: s1, the magazine's top shell. It goes down with the magazine.
  - **Loose magazine** `wm_assaultshotgun_mag.md3`: 196 verts, normals 196/196, re-origined on its centroid. It drops
    along -z, so it stands as authored.
- **WM_BullpupPump.**
  - `body`: s2, 3, 4, 6–10. s3 is a 0.44 sight bead, left in the body.
  - `forend`: s1 + s5, 1642 verts. It slides 10.78 along -X.
  - `trigger`: s0. It hinges 10° about Y.
- **WM_Bolter.**
  - `body`: s0 without its magazine.
  - `mag`: the 468-vert welded piece split out of s0, centroid (2.16, 0.01, -8.55).
  - `trigger`: s1. It slides 0.90 along -X.
  - **Loose magazine** `wm_bolter_mag.md3`: 468 verts, normals 468/468. No frame shows its insert axis, so it stands as
    authored; the card sets the axis.
- **WM_BFGRifle.**
  - `body`: s0, 49 still pieces. No cell piece moves.
  - `trigger`: s1. It hinges 15° about Y through source (32.0, 0, -2.5).
- **WM_RotaryGun.**
  - `body`: s0, 11, 12, 14, 15, 16.
  - `barrels`: s1–10. They turn 45° a step about -X through source (y -0.2, z -7.3).
  - `trigger`: s13. It hinges 15.2° about Y through source (34.8, -0.2, -1.6).
  - `button`: s17, a small cylinder above the grip. It dips 0.38 while firing.
- **WM_RotaryLauncher.**
  - `body`: s0, 1, 3, 5, 6, 7, 11.
  - `tubes`: s2, 9, 10, 12–17, 5940 verts. They turn 45° about +X through source (y -0.2, z -9.0).
  - `trigger`: s4. It hinges 15° about Y through source (34.8, -0.2, -3.2).
  - `button`: s8, the same dipping cylinder.
- **WM_LongbarChainsaw.**
  - `body`: s0 + s1 (the side handle) + s2 + s3 (the bar's plates).
  - `chain`: s4 at frame 0. It shows on the even frames.
  - `chain2`: s5 from frame 1. It shows on the odd frames.
    - It is not byte-identical in space. Frame 1's body sits 13/64 lower (the view bob), so chain2 is moved back up by
      exactly 13/64.
    - The body's frame-1 records match frame 0 plus 13/64 to within 2/64 (0.03 model units, export rounding).
    - Normals are untouched.
  - No pull cord is modelled.

## The shots (the classes, `meatgrinder.zs`)

The owner's words (09-14) where given, otherwise vanilla by the owner's table:

| Gun | Shot |
|---|---|
| Assault shotgun | Shotgun pellets and spread, FireTics 28 (44 / 1.6). Hold-to-fire or a pull per shot waits on the owner. |
| Bullpup pump | 20 pellets at SSG spread per shell, 4-shell tube |
| Bolter | WM_BolterBolt, an RSB_PlasmaBall doing 20 x 1d8; 1 cell; FireTics 18 |
| BFG rifle | as WM_BFG |
| Rotary gun | as WM_Chaingun |
| Rotary launcher | as WM_RPG |
| Longbar chainsaw | as WM_ChainsawHeavy |

Carried, not put in hand: StartItems, slots and give rows in loadout.zs and the arsenal page. The cards, by uzdxrema-63,
are the last seven in WMCARD.txt.
