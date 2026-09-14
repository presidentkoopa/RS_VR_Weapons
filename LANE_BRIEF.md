# WEAPONS LANE — START HERE

You are the **weapons lane** for a private VR fork of GZDoom ("DoomXR", engine source `E:\DOOMWork\UZDXREMA`).
The owner sends you this first. Read it all, then `E:\DOOMWork\RS_VR_Weapons\README.md`, then the files you
will work in. Written 2026-09-13 by the reload/build lane (session `doomwork-f9`) right after the restructure
(commit `2902504`). **Where this and the code disagree, the code wins.**

---

## 1. Who does what

| Lane | Owns | Session |
|---|---|---|
| **Reload / build** | `RS_VR_Reload` (the reload system), **all engine work**, **all builds and commits**, the review gate for every lane | `doomwork-f9` |
| **Ballistics** | `RS_Ballistics` — bullets, tracers, impacts, muzzle flashes, casings, combat effects | `uzdxrema-9f` |
| **Weapons — you** | `RS_VR_Weapons` — the guns | (you) |
| ModelSwapper | `RS_ModelSwapper` — separate; read its models, never edit it | `rs-modelswapper-b8` |

Owner, verbatim: *"you do reloading, ballistics does ballistics, and weapons does whatever that is. you all work
together, no one builds engine except you, and everyone runs all their shit past you."*

## 2. What you own: `E:\DOOMWork\RS_VR_Weapons`

Everything **gun-specific**:
- each gun's **card** (its measurements) in `WMCARD.txt`
- its **weapon class** and **prop class** (ZScript), its **MODELDEF** block, **models/skins**, **sounds**
- its **shot** — pellets, spread, damage — set on the weapon class
- the **starting loadout** (`WM_Player`) and this package's `MAPINFO`, `KEYCONF`, menu page, placement sliders
- bringing in **new gun models** and measuring them

You do **not** own: the reload system's profiles and machinery (`RS_VR_Reload`), effects (`RS_Ballistics`), the
engine, or ModelSwapper. If a gun needs something the reload system can't express, **write the gap down precisely
and send it to the reload/build lane** — don't work around it in your package.

## 3. House rules (all from the owner — non-negotiable)

1. **You never build, pack, commit, or launch the game.** You edit source, then hand off to the reload/build lane:
   *files touched · what each change does · a one-line commit message*. It reviews, packs (`build.ps1`),
   compile-checks (a hidden `-norun` load) and commits locally. Nothing is pushed online, ever.
2. **Nothing gun-specific in `RS_VR_Reload`**, and `RS_VR_Reload` must load with no weapons package. Your package
   may name reload-system classes (it loads after); the reload system never names yours.
3. **NETPLAY MUST NEVER BE JEOPARDIZED** (owner: *"we cannot jeopardize netplay"*). No playsim RNG
   (`random`/`frandom`) on a path that runs on only one machine; anything that affects the game is keyed by the
   actor's **owner**, never `consoleplayer` (which is for local presentation only). Named RNG (`random[Name]`)
   on paths every machine runs identically.
4. **Headset tests need no typing.** Whatever is being tested goes into the player's hands by default. (The owner
   was once asked to type console commands in a headset. Don't.)
5. **Build the diagnostic in with the feature** — a log line (once per map / on change, never per tic) that proves
   it worked or says why not, so one headset run answers the question.
6. **Assets:** don't pull files from other packages or `E:\oldshit` unless the owner has named them for this.
   Named so far: `RS_ModelSwapper`'s models (four shotguns already copied in), **Force Unleashed**
   (`E:\DOOMWork\_old\doom-force-unleashed_devbuild` — Ermac's mod, cleared by the owner for use), `E:\oldshit\ART
   SOURCE` (e.g. shell casings), `RS_Main`'s combat effects folder (effects are the ballistics lane's). Confirm each
   specific pull from anywhere else.
   **Licence/credit for the ModelSwapper meshes is unrecorded** (code comments credit Aliens: Eradication,
   VanAlek, Brutal Doom v21) — flag it before anything ships.
7. **Placement sliders are renderer-read**: MODELDEF `PlacementCVars <prefix>` with a full set
   (`_ofs_x/_ofs_y/_ofs_z/_yaw/_pitch/_roll/_scale`, sizes > 0), so they move the gun live with the menu open.
   Every menu cvar must be declared and read — `tools/menu_lint.py` fails the build otherwise.
8. **Keep replies to the owner short and plain.** They know folders and pk3s, not branches. Ask one question at a
   time, with choices, when a decision is theirs.

## 4. ZScript traps that have broken the load (each one is FATAL for every mod loaded)

- **Class fields cannot have initialisers** (`int x = 1;` at class scope). Locals may.
- **Identifiers are case-insensitive**: a field `mode` and a method `Mode()` collide; same for properties vs fields.
- **One identifier per `const` statement** (`const A = 0, B = 1;` is refused).
- **No `out Vector3`** parameters (compiles, then aborts the VM) — return vectors.
- Prefer a plain `if` over `?:` that mixes a vector literal with a vector expression.
- No compile-time class references into a package that may not be loaded (use `Object.FindClass` by name).

## 5. How a gun is put together

**Weapon class** (`zscript/rs_vr_weapons/*.zs`) derives from `WM_Gun` (reload system):
```
class WM_PumpM37 : WM_Gun
{
    Default
    {
        Weapon.AmmoType1 "Shell";        // the reserve the pouch and pickups use
        Weapon.SelectionOrder 1300;      // lower wins its hand at spawn
        WM_Gun.ShotPellets 7;            // 0 = 1 pellet
        WM_Gun.ShotSpread 5.6, 0;        // yaw, pitch degrees; 0,0 = dead on
        // WM_Gun.ShotDamage 5, 15;      // 0,0 = vanilla 5 x 1d3 per pellet
    }
}
```
Off-hand guns add `+OFFHANDWEAPON`. The pistols (`WM_M4A3`, `WM_Pistolet`) set no shot properties = vanilla pistol.
The fire action lives in `WM_Gun.WM_TryFire`; it fires `WM_Bullet` projectiles (ballistics) per pellet.
Later idea from the owner: selectable **fire profiles** (Vanilla / Vanilla+ / modern) — not started.

**Prop class** derives from `WM_Prop`; its MODELDEF block draws the gun in the hand
(`PlacementCVars wm_main` / `wm_off` for the pistols, `wm_pumpm37` / `wm_pumpdoom` for the shotguns).

**Card** (`WMCARD.txt`) — the gun's measurements, read by the reload system by weapon class name:
- **One key per line.** Blocks close with `end`. An unknown key refuses that weapon only, naming the lump and line.
- **Every number is measured off the mesh by rigid fit** (`E:\DOOMWork\tools\md3.py`, `md3.part_motion`) — never
  taken from animation frames; receivers drift between frames.
- A gun names its reload profile with `mechanism = pump` (the `archetype pump` block lives in the reload system)
  and states only what differs. Magazine-and-slide guns (the pistols) use `role = action` (slide) and
  `role = feed` (magazine) parts and get their behaviour synthesised.
- `part <id>`: `surface` (repeatable), `grab`, `grabsize` (half-sizes, map units), `subject`, and a `dof` block
  (`kind = slide|hinge`, `axis`, `distance` / `degrees` + `pivot`). A part a verb names is grabbable.
- `store tube` (`kind = counted`, `capacity = N`, `detach = no`), `store chamber` (`kind = slotted`, `slots = 1`).
- `load gate`: `at = x, y, z` (model space), optional `size`, `subject = shell`.
- `magfamily` matters: a round/magazine only goes into its own family (`"12ga"`, `"pistol"`).
- **Sounds you don't state are silent** (except dry click, magazine drop and casing, which default to the reload
  system's). Keys: `firesound`, `drysound`, `magoutsound`, `maginsound`, `slidebacksound`, `slidefwdsound`,
  `rackapexsound`, `rackresetsound`, `cycleoutsound`, `cyclehomesound`, `loadsound`, `magdropsound`.
- **Card order matters**: at spawn the reload system puts guns in hands in card order (pistols are first).
- A usable mesh needs separately named surfaces: **magazine gun = body + slide + magazine; pump = body + forend;
  break action = body + barrels.** One fused surface can't be driven.

## 6. What exists now

| Gun | Class | Hand | Mesh | Notes |
|---|---|---|---|---|
| M4A3 pistol | `WM_M4A3` | main | `models/pistols/m4a3.md3` | proven reload loop |
| Pistolet | `WM_Pistolet` | off | `models/pistols/pistolet.md3` | proven reload loop |
| M37A2 pump | `WM_PumpM37` | main | `models/shotguns/AE_Shotgun/m37a2.md3` | forend 11.205 along -x; trigger hinge 31.11°; its own `shell` surface hidden (its skin doesn't exist) |
| Doom shotgun | `WM_PumpDoom` | off | `models/shotguns/Shotgun/shotgun.md3` | forend 7.4; no trigger/gate surface; load point estimated |
| *(no card yet)* assault shotgun | — | — | `models/shotguns/AssaultShotgun/` | magazine-fed + charging handle; duplicate surface names |
| *(no card yet)* super shotgun | — | — | `models/shotguns/SuperShotgun/ssg.md3` | break action, barrel hinge 58.55° |

- Shell mesh for both pumps: `models/shell/shell.md3` + `shell.png` — Force Unleashed's shotgun shell (roundscale
  0.228 = 1.75 map units; modelled lying along its length, so held/dropped-round sliders may need a turn). The old
  hull cut from the Doom shotgun (`models/shotguns/Shotgun/wm_shotshell.md3`) is still on disk, unused.
- Force Unleashed ammo models, copied in and NOT yet wired to anything: `models/ammo/` (pickups for every ammo
  type — shell box, shells, clip of shells, bullet box, clip, cells, rockets, backpack) and `models/ammo_hand/`
  (in-hand pistol/chaingun/plasma magazines, rocket/BFG/heat pods, flame can, shells, with their skins).
- Loadout `WM_Player` (`loadout.zs`): fists, both pistols, Clip 200, both shotguns, Shell 50. `WM_PumpTestHandler`
  puts the shotguns in hand 40 tics after spawn (`wm_pump_start_in_hands`, default on) and runs
  `wm_giveshotguns` / `wm_equippistols` (also on the menu: Options → "VR Weapons -- test shotguns").
- Measurements and candidate notes: `E:\DOOMWork\RS_VR_Reload\SHOTGUN_CANDIDATES.md`.
- Background on the reload system: `RS_VR_Reload\BUILD.md` (the rebuild plan), `CARDS_ON_PAPER.md` (gaps).

## 7. Known reload-system gaps that affect your guns (report, don't patch)

- No `hands = 2` (a gun held by both hands) and no `follows` (a part that moves with another).
- The forend has no tuning page yet, and the hand on a forend uses the pistol slide's seat.
- The spent shotgun hull looks like a pistol casing (ballistics lane's casing work, "M3").
- **Break action (super shotgun) is blocked** until the reload system acts on the `open` verb (stay-open barrels,
  latch, eject on open) — its grammar parses today but does nothing.
- Loading a shell and pushing the forend home are silent unless the card states `loadsound` / `cyclehomesound`.

## 8. Load order and building

Load: **`RS_Ballistics` → `RS_VR_Reload` → `RS_VR_Weapons`** (other mods around them as the owner has them).
`RS_VR_Weapons\build.ps1` (run by the reload/build lane): menu lint (`--prefix wm_pump --dep RS_VR_Reload`), pack,
verify every mesh/skin/sound path, compile-check this pk3 with the reload pk3. Never run it yourself.

## 9. Good first work (check with the owner which first)

0. **Wire the Force Unleashed ammo pickups** (`models/ammo/`) to Doom's ammo classes via MODELDEF so map ammo
   draws as those models (changes what the map looks like — confirm with the owner), and see which
   `models/ammo_hand/` pieces suit the guns in hand.
1. **Shotgun polish from the owner's headset test** — sit/placement, load point positions, a pump-home and a
   shell-load sound using Doom's own sounds (`doom.wad`) via `cyclehomesound` / `loadsound`.
2. **More pistols** — the owner mentioned about eight pistol models in ModelSwapper. Survey them read-only (which
   have separate slide + magazine surfaces), report, and ask before copying any in. This also proves the cards
   and grab ovals work across many pistols.
3. **Assault shotgun** as a magazine-and-charging-handle gun (check what its surfaces allow).
4. **Later:** fire profiles; a **card generator tool** that reads any model's surfaces and animation and writes its
   card (owner: *"eventually we will need a smarter system where any 'shotgun' model can work with the shotgun
   profile"*) — then the same at load time, and fused meshes working mechanically.

## 10. Handoff template

```
HANDOFF (weapons lane) — <short title>
Files: <path> — <what changed and why>   (one line each)
Checks I ran (read-only): <lint / grep / md3.py measurements>
Netplay: <why this is safe>
Headset test: <what the owner will see, no typing needed>
Log lines: <what proves it>
Commit line: <one line>
```
