# Proposed brace points for the five Breach rifles -- REPORT ONLY (2026-09-18)

Their current support points are a palm centre from Breach's left-hand joints, projected onto the gun's mid-plane. They sit 4-6 units off any surface. Proposed below is the nearest outer wall under the bore -- a measured place on the mesh -- carried back into the card's own space.

**Nothing here is applied.** The cards are untouched until the owner picks a direction; this is the diff they would be looking at.

| Gun | Current `grab` | Proposed | Moves by | Off the mesh now | Surface normal there |
|---|---|---|---|---|---|
| MK18 | 38.743, 4.934, -13.886 | 38.743, 4.679, -8.029 | **5.86** | 5.86 | 0.008, -0.032, -0.999 |
| MK18S | 38.743, 4.934, -13.886 | 38.743, 4.679, -8.029 | **5.86** | 5.86 | 0.008, -0.032, -0.999 |
| HK416S | 38.743, 5.148, -13.886 | 38.743, 4.938, -9.072 | **4.82** | 4.82 | -0.507, -0.148, -0.849 |
| MCX | 38.743, 4.896, -13.886 | 38.743, 4.714, -9.718 | **4.17** | 4.17 | -0.507, -0.160, -0.847 |
| G36C | 38.743, 5.037, -13.886 | 38.743, 4.856, -9.746 | **4.14** | 4.14 | -0.600, -0.098, -0.794 |

## What to look at

- `Moves by` is how far the brace hand would shift. It is roughly half a hand, which is what a palm centre is.
- The normal is the way that surface faces, in the card's space, so the hand's turn comes from the gun rather than from a per-type constant.
- The pistols, the MP5 and the Benelli are NOT in this table: their brace points came off gun geometry and already sit within 0.3-1.5 of a surface.
