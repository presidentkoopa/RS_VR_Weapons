# WEAPONS LANE — STARTUP (2026-09-13, round 2)

The owner sends this to you first. It is your work order. Read it, then `LANE_BRIEF.md` in this folder: who owns
what, house rules, ZScript traps, and how a gun is put together. Then `README.md`, then the code.
**Where a doc and the code disagree, the code wins.**

Owner, after testing: *"shotguns are fuckin great!"* The pump archetype works. Your job now is to fill out the
arsenal and get it into the owner's hands.

---

## 0. The rules that bite (full list in LANE_BRIEF.md §3–4)

- **You never build, pack, commit, push, or launch the game.** Hand off to the reload/build lane (session
  `doomwork-f9`) with: files touched · what each change does · a one-line commit message. It reviews, packs,
  compile-checks and commits.
- **Nothing gun-specific in `RS_VR_Reload`.** If a gun needs something the reload system cannot express, write
  the gap down precisely (see `RS_VR_Reload/CARDS_ON_PAPER.md` for the format) and send it to the reload lane.
  Don't work around it in your package.
- **Netplay is sacred.** No `random`/`frandom` on local-only paths; key behaviour by the actor's owner, never
  `consoleplayer`.
- **Every slider is renderer-read** (MODELDEF `PlacementCVars` / per-actor `PlacementPrefix`). A menu pauses the
  game, so a slider read by script does nothing while the owner watches. `tools/menu_lint.py --dep` fails it.
- **No typing in a headset.** Whatever is being tested starts in the player's hands or on their person.
- **Build the diagnostic with the feature:** one log line per map or per change that proves it worked.
- **Assets:** ModelSwapper models and Force Unleashed (`E:\DOOMWork\_old\doom-force-unleashed_devbuild`) are
  cleared for use. Copy into this package. Never edit `RS_ModelSwapper`. Owner: *"always check ForceUnleashed
  for other models which might work, as we go on."*

---

## 1. Being worked on right now by the reload/build lane — do NOT touch

- **Shotgun sliders:** live menu sliders for each shotgun's ovals (grab/insert zones) and for where the hands sit
  on the gun. This will add cvars and menu rows to this package's `CVARINFO`/`MENUDEF` and shotgun cards. When it
  lands, copy **that pattern** for every new gun.
- **Pump grip:** on grip, the off hand currently jumps to the pistol-slide position. It is being made to lock to
  the **pump**, under the gun toward the muzzle, driven by the card.
- **Shotgun loading direction:** the M37A2 ("the aliens one") loads **from the bottom**; the Doom shotgun loads
  **from the side**. The insert zones follow that. Keep it true in any card you touch: when loading drives the
  shell part of the MD3 animation, the zone must sit where that model's shell actually goes in.
- **Holstered guns look see-through** (back-faces or sorting). Being fixed in the render and body path.
- **Engine:** the VR menu keeps head tracking and the 3D view, so the owner can place holsters with live sliders.

If your work needs any of these, wait for the handoff note or ask the reload lane.

---

## 2. TASK 1 (first) — every test weapon on the owner's person, selectable by slot and by the wheel

Owner: *"ensure these weapons are on my person and i can select them, you know? slot 2 slot 3 etc, i want these
as my playerclass weapons. so i can select them with my wheel."*

Today `WM_Player` (`zscript/rs_vr_weapons/loadout.zs`) gives the weapons as StartItems, and `WM_PumpTestHandler`
puts the shotguns in hand. Nothing sets weapon slots, so the wheel and the number keys cannot reach them cleanly.

**Decision (from the reload lane — follow it):**

| Slot | Weapons |
|---|---|
| 1 | `RS_WorldFist`, `RS_WorldFistOff` (RS_WorldHands, only if loaded) |
| 2 | `WM_M4A3`, `WM_Pistolet` |
| 3 | `WM_PumpM37`, `WM_PumpDoom` |
| 4 | the revolvers from Task 2, as they arrive |

- Set slots on the **player class** (`Player.WeaponSlot` in `WM_Player`'s Default block). Classes from other
  packages go in by name, and slot lists take names, so RS_WorldHands not being loaded must not break the load.
  Also give each weapon `Weapon.SlotNumber`, so a different player class still finds them.
- **Find how the weapon wheel lists weapons before you finish.** The wheel is
  `E:\DOOMWork\RS_WeaponSelectionSystem` (`zscript/wheel/`, e.g. `wr_constellation.zs`). Read it; don't edit it.
  Ignore the copy under `RS_Sweeps/.claude/worktrees`.
  **Already checked:**
  - The wheel walks the player's **weapon slots** (`WeaponSlots.SlotSize` / `GetWeapon` in `zscript.zs` ~3578,
    `wr_constellation.zs` ~731), so a weapon in no slot never appears.
  - On selection it sets `bOffhandWeapon` from the hand that picked it (`wr_constellation.zs` ~1205).
  - It skips a held `bNoHandSwitch` weapon for the wrong hand (`zscript.zs` ~3586).
  Confirm how the two off-hand test guns (`+OFFHANDWEAPON` by default) behave when picked with either hand. Confirm it reads the player's slots and ownership, and check
  whether it hides `+OFFHANDWEAPON` weapons. The off-hand guns (`WM_Pistolet`, `WM_PumpDoom`) must be reachable.
  If the wheel cannot show off-hand weapons, write down exactly why and send it to the reload lane. Do not edit
  the wheel.
- **Keep the headset start as it is:** the pistols and shotguns still start in hand (`WM_PumpTestHandler`, cvar
  `wm_pump_start_in_hands`). Slots are *in addition*.
- **Diagnostic:** one log line at PlayerSpawned listing each slot's weapons and whether the player owns them.

---

## 3. TASK 2 — revolvers: Moonlight, Sunset, and the Cola revolver

Owner: *"go back to modelswapper and get us two revolvers (I want Moonlight and Sunset, but get the Cola one as
well so we can try 2 diff models) … there is a speedloader part of the moonlight and sunset. i want that
speedloader as our 'ammo' that we load into the gun. check ForceUnleashed for a revolver equivalent before we do
some weird surgery on the MD3."*

### What was already checked (2026-09-13)

**Force Unleashed has no revolver and no speedloader.** Its models folders are ammo, ammo_hand, bfg9000,
chaingun, chainsaw, common, hand, heatwave, hellshotgun, incinerator, pistol (Beretta), plasmarifle,
rocketlauncher, shieldsaw, shotgun, ssg. `common/bullet.md3` is a possible loose-round model. Re-check yourself
if you find a reason to.

**ModelSwapper** (`E:\DOOMWork\RS_ModelSwapper`, read only):

| Owner's name | ModelSwapper actor | Mesh | Skin |
|---|---|---|---|
| **Moonlight** | `MS_Revolver` | `models/hud/Revolver/rev.md3` | `WPN-REV.png` |
| **Sunset** | `MS_Revolver2` | same `rev.md3` | `WPN-REV2.png` |
| **Cola** ("Vanilla") | `MS_Cola_Revolver` | `models/hud/Cola_Revolver/revolver.md3` | `revolver.png` |

Moonlight and Sunset are **one mesh, two skins**, so one prop class with a per-class skin. Main hand gets one,
off hand the other. The Cola revolver is the second model to compare.

**`rev.md3`**: 41 frames, 11 surfaces, all named `python.0xx`, so you must identify the parts yourself.
Frame-0 bounds, and how far each centroid travels over the animation:

| Surface | Verts | Frame-0 bounds (x / y / z) | Travel | First read |
|---|---|---|---|---|
| python.004 | 298 | -9.3..4.6 / ±1.6 / -8.8..4.2 | 7.3 | frame / body |
| python.005 | 63 | -1.3..3.4 / ±2.1 / -1.2..3.1 | 15.9 | cylinder? |
| python.006 | 28 | -5.3..-2.7 / ±0.4 / 0.8..3.0 | 8.8 | hammer? |
| python.007 | 105 | -1.3..17.4 / ±1.2 / -2.1..4.2 | 15.2 | barrel + crane / ejector? |
| python.008 … 013 | 18 each | collapsed to a point | ~135–145 | **the six rounds** (appear during reload) |
| python.014 | 257 | collapsed far away (6.1, 24.6, -74.6) | 108 | **the speedloader**, most likely (hidden at rest) |

**`revolver.md3` (Cola)**: 55 frames, named surfaces `Revolver`, `Magazine_rod` (ejector rod),
`Bullet_set` (the six rounds as one part), `Bullet_holes`, `Magazine.wheel` (cylinder), `Hammer`, `Trigger`.
ModelSwapper's reload is frames 31–54. **There is no speedloader surface.** Options, cheapest first:

1. `Bullet_set` is its loaded group.
2. Reuse Moonlight's speedloader mesh as the ammo prop for both.

Bring the choice to the reload lane.

### Steps

1. **Identify the parts properly.** Measure with `E:\DOOMWork\tools\md3.py` (`md3.MD3Model.load`, then
   `surface.verts[frame]`), frame by frame through the reload animation. Name each surface's role (frame, cylinder,
   crane, ejector rod, hammer, trigger, rounds, speedloader), its hinge axis and the cylinder's swing angle. Record
   it all in `RS_VR_Weapons/REVOLVER_CANDIDATES.md`, like `RS_VR_Reload/SHOTGUN_CANDIDATES.md`. Check the
   **three-surface minimum** (body, action, ammo) and the load log.
2. **Copy** the meshes and skins into `RS_VR_Weapons/models/revolvers/<Revolver|Cola_Revolver>/`. Do not move
   anything in ModelSwapper.
3. **The speedloader is the ammo.** When the owner grabs revolver ammo, the thing in hand is the speedloader model,
   the same idea as a clip becoming a magazine in flight. Extracting `python.014` into its own MD3 is "surgery",
   so only do it if driving the surface in place (engine `SetModelSurfaceDriveHinge/Stage`, per-part frame
   addressing) can't work. Say which in the candidates doc.
4. **The revolver is a new archetype** (swing-out cylinder: open, eject, load, close, cock or pull). The reload
   system has only `pump` and the pistol profile. **Do not invent the machinery.** Write both revolver cards on
   paper in today's grammar, list the gaps in the `CARDS_ON_PAPER.md` style, and send them to the reload lane. It
   decides the `mechanism = revolver` profile and builds the verbs. You build the weapon classes, props, MODELDEF,
   placement sliders and cards against it.
5. **Get them in hand early:** slot 4, both revolvers on the person, one starting in each hand once they fire.
   Shooting first, reload second, so the owner can test the feel before the archetype exists.
6. **Shot values** go on the weapon class (`ShotPellets 1`, `ShotSpread`, `ShotDamage`), heavier than the pistols.
   Casings and effects are the ballistics lane's. Ask it for a revolver profile rather than building effects.

---

## 4. Handoff checklist (every time)

- Files touched, one line each on what changed.
- New cvars and menu rows, each confirmed renderer-read.
- ZScript traps checked (field initialisers, `const`, `out Vector3`, cross-pk3 class literals).
- Netplay: RNG and consoleplayer checked.
- What the owner should test in the headset, in one or two lines, with nothing to type.
- A one-line commit message.
