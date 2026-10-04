# BREACH grabs on the bind pose (reload lane, 2026-09-18)

Every grab point the cards author, carried back onto the BIND POSE for piece E (`FollowActorOfsInModel` takes a bind-pose point as **(x, z, y)**; these are file axes x, y, z).

**These are hand positions, and nobody has confirmed one in a headset.** They were fitted to the RS hand at its size, so treat them as a starting guess per body, not as truth. The mesh facts (muzzle, eject port, magazine centre, joint names) are in each gun's JSON beside them.

## The headline: the bind pose is NOT the gun you see

These are character rigs, and their bind pose parks the whole gun far from where the drawn frame puts it. Feeding a drawn number into `FollowActorOfsInModel` would not be off by a slide's travel -- it would be off by this much:

| Gun | Gun-frame joint | Drawn frame | Whole gun sits this far from bind |
|---|---|---|---|
| Glock | `tag_weapon` | 0 | **116.4** |
| GlockS | `tag_weapon` | 0 | **116.4** |
| Kimber | `j_slide` | 0 | **106.5** |
| MK18 | `tag_sling` | 25 | **112.2** |
| MK18S | `tag_sling` | 25 | **112.2** |
| HK416S | `tag_weapon` | 25 | **112.2** |
| MCX | `tag_weapon` | 25 | **112.2** |
| G36C | `tag_sling` | 25 | **112.2** |
| MP5 | `tag_sling` | 109 | **62.9** |
| Benelli | `gun` | 59 | **11.4** |

## The points

`part travel` is the point's own movement IN THE GUN'S OWN FRAME between bind and the drawn frame. ~0 means the part was at rest on that frame, so the card's relative geometry and the bind geometry agree and only the whole-gun placement above differs. Anything large is a part that was mid-motion.

`surface normal` is the way the mesh faces where that point lands, on the bind pose, pointing out of the gun (area-weighted mean of the nearest faces). With the bore line it gives the hand's turn, so no rotation needs tuning per gun. `off` is how far the point sits from the nearest face -- a grab point is meant to be a little off the surface, so this is a sanity number, not an error.

| Gun | Part | Joint | Bind (x, y, z) | Drawn (x, y, z) | part travel | Surface normal | off |
|---|---|---|---|---|---|---|---|
| Glock | slide | `j_slide` | 0.012, -6.808, 95.932 | 32.844, 5.813, -2.770 | 0.000 | 0.013, 0.493, 0.870 | 0.10 |
| Glock | magazine | `j_mag1` | 0.026, -5.470, 82.768 | 31.506, 5.827, -15.934 | 0.000 | - | 0.30 |
| Glock | support | `tag_weapon` | 0.000, -11.155, 86.891 | 37.191, 5.801, -11.811 | 0.000 | -0.083, -0.494, -0.865 | 0.45 |
| GlockS | slide | `j_slide` | 0.012, -6.808, 95.932 | 32.844, 5.813, -2.770 | 0.000 | -0.005, 0.823, 0.568 | 0.10 |
| GlockS | magazine | `j_mag1` | -0.027, -5.470, 82.768 | 31.506, 5.774, -15.934 | 0.000 | - | 0.30 |
| GlockS | support | `tag_weapon` | -0.025, -11.155, 86.891 | 37.191, 5.776, -11.811 | 0.000 | -0.081, -0.495, -0.865 | 0.45 |
| Kimber | slide | `j_slide` | -0.074, -8.088, 95.549 | 34.124, 5.727, -3.153 | 0.000 | -0.005, -0.026, 1.000 | 0.10 |
| Kimber | magazine | `j_mag1` | -0.064, -8.234, 83.276 | 34.270, 5.737, -15.426 | 0.000 | 0.028, 0.171, -0.985 | 0.44 |
| Kimber | support | `tag_weapon` | -0.060, -12.487, 88.891 | 38.523, 5.741, -9.811 | 0.000 | 0.055, 0.000, -0.998 | 0.28 |
| MK18 | charginghandle | `j_charginghandle` | 5.501, -2.389, 107.681 | 13.841, 5.024, -3.984 | 0.000 | - | 0.10 |
| MK18 | magazine | `j_mag1` | 16.979, -3.314, 89.617 | 25.319, 4.887, -22.071 | 0.001 | -0.544, -0.083, -0.835 | 0.15 |
| MK18 | support | `tag_sling` | 30.403, -2.910, 97.793 | 38.743, 4.934, -13.886 | 0.000 | 0.008, -0.075, -0.997 | 5.86 |
| MK18S | charginghandle | `j_charginghandle` | 5.501, -2.389, 107.681 | 13.841, 5.024, -3.984 | 0.000 | - | 0.10 |
| MK18S | magazine | `j_mag1` | 16.979, -3.314, 89.617 | 25.319, 4.887, -22.071 | 0.001 | -0.544, -0.083, -0.835 | 0.15 |
| MK18S | support | `tag_sling` | 30.403, -2.910, 97.793 | 38.743, 4.934, -13.886 | 0.000 | 0.008, -0.075, -0.997 | 5.86 |
| HK416S | charginghandle | `j_charginghandle` | 7.824, -2.984, 107.663 | 16.164, 4.430, -4.028 | 0.000 | - | 0.07 |
| HK416S | magazine | `j_mag1` | 20.020, -3.142, 89.372 | 28.360, 5.069, -22.308 | 0.001 | - | 0.24 |
| HK416S | support | `tag_weapon` | 30.403, -2.696, 97.783 | 38.743, 5.148, -13.886 | 0.000 | -0.507, -0.185, -0.842 | 4.82 |
| MCX | charginghandle | `j_charginghandle` | 8.359, -2.159, 107.895 | 16.699, 5.244, -3.760 | 0.000 | - | 0.37 |
| MCX | magazine | `j_mag1` | 19.632, -2.717, 90.443 | 27.972, 5.447, -21.220 | 0.001 | 0.285, 0.053, -0.957 | 0.22 |
| MCX | support | `tag_weapon` | 30.403, -2.948, 97.794 | 38.743, 4.896, -13.886 | 0.000 | -0.507, -0.197, -0.839 | 4.17 |
| G36C | charginghandle | `j_charginghandle` | 7.382, -2.420, 106.667 | 15.722, 5.037, -4.999 | 0.000 | - | 1.59 |
| G36C | magazine | `j_mag1` | 19.778, -2.577, 90.294 | 28.118, 5.593, -21.362 | 0.001 | - | 0.17 |
| G36C | support | `tag_sling` | 30.403, -2.807, 97.788 | 38.743, 5.037, -13.886 | 0.000 | -0.600, -0.132, -0.789 | 4.14 |
| MP5 | charginghandle | `j_charging_tube` | 6.573, -2.795, 60.379 | 20.722, 2.407, -2.278 | 0.000 | 0.017, -0.999, -0.036 | 0.10 |
| MP5 | magazine | `j_mag1` | 7.613, -0.129, 50.747 | 18.080, 3.435, -11.918 | 0.000 | -0.028, -0.508, -0.861 | 0.27 |
| MP5 | support | `tag_sling` | 7.679, 0.018, 57.381 | 17.913, 3.501, -5.284 | 0.000 | -0.015, -0.002, -1.000 | 0.58 |
| Benelli | bolt | `bolt` | 20.564, 9.944, -8.436 | 12.871, 3.448, -3.154 | 0.000 | - | 0.07 |
| Benelli | support | `gun` | 26.473, 9.743, -12.142 | 18.783, 2.900, -6.819 | 0.000 | 0.008, -0.000, -1.000 | 1.46 |
