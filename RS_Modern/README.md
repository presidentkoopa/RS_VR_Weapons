# RS_Modern

Modern weapon sets for the VR reload system, and a **Modern** player class on the New Game menu that starts with them.

The owner, 2026-09-15: *"ideally we would have RS_Weapons_Vanilla, RS_Weapons_VanillaPlus, RS_Modern — and every pk3
you load would add a selectable class from the new game menu."*

## Load order

Load after RS_Ballistics, RS_VR_Reload and RS_VR_Weapons:
- its guns are the reload system's `WM_Gun` / `WM_Prop`, with cards the reload system reads;
- its class starts from RS_VR_Weapons' `WM_Player`;
- its MAPINFO **adds** the class (`AddPlayerClasses`). RS_VR_Weapons **replaces** the class list (`PlayerClasses`), so it must come first.

## The BREACH set

ZeroDoomThirty's BREACH Weapons (`licenses/breach_weapons_CREDIT.txt`): every gun is a rigged IQM whose moving parts are
**joints**, driven by the engine's bone drive. Each gun keeps Breach's own shot, capacity, sounds and icon; its flash, smoke
and brass are RS_Ballistics'.

| Gun | Class | Hand | Moving parts | Shot (Breach's) | Magazine |
|---|---|---|---|---|---|
| Glock | `WM_BreachGlock` | main | slide, trigger, magazine | 20–60, 3°, 6 tics, semi | 17, `glock` |
| Glock (suppressed) | `WM_BreachGlockS` | main | slide (with its sight), trigger, magazine | 20–60, 3°, 6 tics, semi | 17, `glock` |
| Kimber | `WM_BreachKimber` | off | slide, magazine | 34–102, 3°, 6 tics, semi | 8, `kimber` |
| MK18 | `WM_BreachMK18` | main | charging handle, magazine | 30–90, 3°, 3 tics, select fire | 30, `stanag` |
| MK18 (suppressed) | `WM_BreachMK18S` | main | as the MK18; silencer and laser models | 30–90, 3°, 3 tics, select fire | 30, `stanag` |
| HK416 (suppressed) | `WM_BreachHK416S` | main | charging handle, magazine | 28–84, 1.75°, 3 tics, select fire | 30, `stanag` |
| MCX (suppressed) | `WM_BreachMCX` | main | charging handle, magazine | 28–84, 2°, 3 tics, select fire | 30, `stanag` |
| G36C (suppressed) | `WM_BreachG36C` | main | magazine (its handle has no mesh) | 28–84, 2°, 3 tics, select fire | 30, `g36` |
| MP5 | `WM_BreachMP5` | main | cocking handle, magazine | 20–60, 0.8°, 3 tics, select fire | 30, `mp5` |
| Benelli M4 | `WM_BreachBenelli` | main | bolt (cycles itself on each shot), trigger | 30 pellets of 15–45, 4.5°×5°, 16 tics, auto | 7-shell tube, `12ga` |

**How each was measured** (`tools/`):
- **Frame:** `breach_frames.py` finds the frame where the gun stands straight. Breach's own Ready frame is used where it does.
- **Points:** `breach_points.py` takes muzzle, grabs, magazine axis and floorplate, eject port and trigger off that frame, skinned as the renderer skins it. A gun with no trigger bone uses Breach's right index finger; the support grab is Breach's left hand.
- **Seat:** `breach_seat.py` puts the trigger on the M4A3's (main hand) or the Pistolet's (off hand), pointing the same way, with no rotation.
- **Scale:** 1.145 for the rigs drawn at the Glock's size, 2.29 for the MP5 (half-size rig: Breach's own hand measures half), 2.62 for the Benelli (885 mm).
- **Loose magazines:** `breach_extract.py` cuts them from each rig.
- **Sounds:** `make_breach_sounds.py` mixes each gun's two fire layers.
- **Output files:** `gen_breach_set.py` writes the classes, cards, MODELDEF, SNDINFO, the Modern class and the credit list.

**For the owner's eye in a headset:**
- the rifles' 2.5° roll and the Benelli's 3° yaw (the rigs' own; no rotation is shipped);
- sizes;
- the Benelli trigger's swing direction.

**Its own effects (2026-09-16):** every gun fires its own RS_Ballistics look (0cc3ff5) — `glock17`, `glock17_sup`, `kimber1911`,
`mk18`, `mk18_sup`, `hk416_sup`, `mcx_sup`, `g36c_sup`, `mp5` (one profile for every fire mode), `benelli_m4` — one id across that
gun's round, flash, brass and recoil. The suppressed guns have a real suppressed look now (a faint glow at the can, gas blown back
out of the port, a quieter room tail), not a missing flash. Nothing here is on another gun's profile.

**Not yet:**
- **Flashbang and C4:** tabled by the owner (2026-09-15), to be revisited with throwing for the grenade and the ShieldSaw.

## Build

`build.ps1`: pack the pk3, verify every mesh, skin and sound reference, compile-check with the data validators on (the card
checker), and install on a pass. `-NoCompileCheck` packs and verifies only.
