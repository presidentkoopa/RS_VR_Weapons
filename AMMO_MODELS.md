# Ammo models — Force Unleashed

Owner, 2026-09-13, relayed by the build lane: *"take all needed ammo models from forceunleashed"*.

- **Source:** `E:\DOOMWork\_old\doom-force-unleashed_devbuild\models` (Ermac's mod, cleared by the
  owner). Read-only; nothing there was edited.
- **Checks:** every mesh below was structure-dumped with `tools/md3.py` and rendered with
  `RS_ModelSwapper/tools_md3_render.py`.

**Licence/credit:** Force Unleashed, Ermac. Cleared by the owner for this project; flag before
anything ships outside it.

---

## 1. Map pickups — Doom's ammo classes, drawn as FU's models (wired)

MODELDEF blocks go on **Doom's own classes**, not on FU's replacement actors (`Clip_Pickup`
and so on). Every map's ammo wears them, and what an item gives, how pickups work, and how
the reload system reads `Clip` / `Shell` are all unchanged.

- **Mesh, skin, Scale and spin:** FU's own `modeldefs/ammo.txt`, verbatim.
- **Frame:** each class's own Spawn frame (UZDXREMA `doomammo.zs`).
- **Sliders:** every pickup has a live placement set `wm_pu_<item>`, on its own page under
  Options → "VR Weapons -- ammo pickups".

| Doom class (sprite) | FU mesh(es) | Skin(s) | FU Scale | Sliders |
|---|---|---|---|---|
| `Clip` (CLIP A) | `AmmoClip_Case.md3` + `AmmoClip_Shell.md3` | `AmmoClip_Case.png`, `AmmoClip_Shell.png` | 1.3 1.4 1.3 | `wm_pu_clip` |
| `ClipBox` (AMMO A) | `AmmoBox.md3` | `AmmoBox.png` | 0.65 0.8 0.92 | `wm_pu_clipbox` |
| `Shell` (SHEL A) | `Shells.md3` (four shells in a row) | `Shells.png` | 1.2 1.2 1.1 | `wm_pu_shell` |
| `ShellBox` (SBOX A) | `ShellBox.md3` + `ShellBox_Shells.md3` | `ShellBox.png`, `ShellBox_Shells.png` | 0.8 1.17 1.4 | `wm_pu_shellbox` |
| `RocketAmmo` (ROCK A) | `IRocket.md3` | `IRocket.png` | 0.68 0.68 0.64 | `wm_pu_rocket` |
| `RocketBox` (BROK A) | `RocketBox.md3` | `RocketBox.png` | 0.65 1.2 1.4 | `wm_pu_rocketbox` |
| `Cell` (CELL A) | `Cell.md3` | `Cell.png` | 0.65 1.15 1.3 | `wm_pu_cell` |
| `CellPack` (CELP A) | `CellLarge.md3` (three terminals on top) | `CellLarge.png` | 1.6 2.0 2.15 | `wm_pu_cellpack` |
| `Backpack` (BPAK A) | `Backpack.md3` | `Backpack.png`, converted from FU's `Backpack.pcx` (64×64 grayscale); the build packs only .md3/.png | 0.5 0.4 0.46 | `wm_pu_backpack` |

**Nothing else in the load order replaces these classes, or gives them a MODELDEF block.** The
package's own `WM_LooseMag` / `WM_LooseRound` derive from `Clip`, but MODELDEF is per class and
not inherited, so they keep their own blocks.

## 2. Held and loose ammo on our guns (already FU's, nothing to change)

| Use | Mesh | Where it comes from |
|---|---|---|
| Loose round: pistols, revolvers, Rifle, M16, Tec9, SMG | `models/pistols/bullet.md3` | FU `common/bullet.md3`, byte-identical |
| Held and loose shell: both pumps | `models/shell/shell.md3` | FU `common/shell.md3`, byte-identical |
| Each gun's magazine or speedloader | that gun's own, lifted out of its own mesh | not FU: a magazine must be its own gun's ("every gun is unique") |

The SSG's shells are the build lane's card.

## 3. Left out, and why

| FU mesh | Why not |
|---|---|
| `ammo/Cell-Glow.md3` | FU draws the cell's glow as a separate Bright actor it spawns every tic. As a second model in the `Cell` block it would draw unlit and opaque |
| `pistol/berreta_mag.md3`, `berreta_mag2.md3`, `ammo_hand/mag_pistol.md3` | FU's Beretta magazine. None of our guns is a Beretta, and each of our guns drops its own magazine |
| `chaingun/cg_mag.md3`, `cg_ammo*.md3`, `cg_ammoclip.md3`, `ammo_hand/mag_chaingun.md3` | Chaingun box and belt: we have no chaingun yet. Keep for it |
| `plasmarifle/plasma_mag*.md3`, `ammo_hand/mag_plasma.md3` | Plasma rifle cell magazine: no plasma rifle yet |
| `heatwave/heat_mag*.md3`, `ammo_hand/pod_heat.md3` | FU's heatwave gun: not in our set |
| `rocketlauncher/rockets*.md3`, `ammo_hand/pod_rocket.md3` | Rocket launcher loads: no rocket launcher yet (the `RocketAmmo` pickup above covers the map) |
| `ammo_hand/pod_bfg.md3`, `ammo_hand/flame_can.md3` | BFG and flamethrower loads: not built yet |
| `shotgun/shell.md3`, `hellshotgun/hellshell.md3`, `ssg/ssg_shell.md3`, `ammo_hand/shot_shell*.md3` | Animated or posed copies of the same shell already in use as `common/shell.md3` |
| `ammo_hand/ammo_hand.md3` | A hand mesh, not ammo |
| `common/ammo_hud_*`, `w_*`, digits, watch faces | FU's HUD and wrist display, not ammo |

**Already on disk and unused:** `models/ammo_hand/` came in with an earlier copy. Its magazines
and pods are the future-gun list above: kept, drawn by nothing.
