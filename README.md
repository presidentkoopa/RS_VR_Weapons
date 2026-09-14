# RS_VR_Weapons

**The VR weapon set for the UZDXREMA (DoomXR) mod family.** It has 26 guns you
reload with your hands: two for every Doom weapon, plus ten more. Each gun runs on
an [RS_VR_Reload](https://github.com/presidentkoopa/RS_VR_Reload) card and fires
[RS_Ballistics](https://github.com/presidentkoopa/RS_Ballistics) rounds.

## Status

- **All 26 guns are live.** Every model works, and every gun reloads by hand.
  Hand seats and grab ovals are being calibrated in the headset, then baked into
  the cards as defaults.
- **Vanilla set:** the guns behave like Doom's. Doom's weapon pickups give these
  guns, one gun per pickup.
- **Not vanilla yet:**
  - the machine gun has an underbarrel grenade launcher;
  - the chaingun's first shot of a burst spreads, where Doom's is dead on;
  - the pistols fire once per pull, where Doom's refire while held.
- **Next:**
  - Vanilla+ primary and secondary fires, designed one gun at a time;
  - an options menu for the weapon set.

## The guns

| Slot | Doom weapon | Main hand | Off hand |
|---|---|---|---|
| 1 | Chainsaw | Chainsaw (pull its ripcord to start it) | Heavy Chainsaw |
| 2 | Pistol | M4A3 | 9mm Handgun |
| 3 | Shotgun | M37A2 (pump) | Doom shotgun (pump) |
| 3 | Super Shotgun | Super Shotgun (break action) | Bullpup Pump (four-shell pump) |
| 7 | Chaingun | Chaingun (box and belt) | Machine Gun (belt, underbarrel launcher) |
| 8 | Rocket Launcher | Rocket Launcher (three-rocket rack) | RPG (seven-rocket drum) |
| 9 | Plasma Rifle | Plasma Rifle | Plasma Carbine |
| 0 | BFG9000 | BFG (cover, cell, charge meter) | Heavy BFG |

**The extras, for Vanilla+:**

| Slot | Main hand | Off hand |
|---|---|---|
| 4 | Moonlight (revolver) | Sunset, Cola Revolver |
| 5 | Rifle, M16 | |
| 6 | SMG | Tec9 |
| 9 | Railgun | |
| 0 | Flamer | Flamethrower |

**Reloading** depends on the kind of gun:
- **Magazines:** drop them with a button or pull them out; seat a fresh one from
  the pouch; rack the slide or bolt.
- **Pump shotguns:** feed shells into the tube one at a time, then pump.
- **Break actions:** break them open, tip them to dump the hulls, load the
  shells, and flick them shut.
- **Revolvers:** open them, tip or eject the rounds, load, and flick them shut.
- **The rest:** cells, canisters, the BFG's cover and battery, the rocket rack
  and drum, and the machine gun's launcher breech.

The shots come from vanilla Doom for the Doom weapons. For the revolvers, rifles,
SMGs, flamethrowers and railgun they come from RS_Main's Uncommon tier.

## Getting the guns

- **Map pickups.** Every Doom weapon a map places, or a monster drops, keeps
  Doom's sprite. It gives the next gun of its pair you don't carry yet, main hand
  first.
  - It comes with Doom's ammo for that weapon: half if dropped, scaled by skill.
  - Once you carry both guns of the pair, the pickup gives ammo only.
  - With weapons stay on, each player takes each gun once.
- **The start.** A new game starts like Doom, with a gun for each hand: both fists,
  the M4A3 and the 9mm Handgun (a full magazine each) and 50 bullets.
  - Options > VR Weapons -- weapon set > "Start with the whole test arsenal instead"
    starts you with every gun. It is the server cvar `wm_start_arsenal`, default `0`.
- **Console or menu:** each command puts a family into its hands.
  - `wm_giveshotguns`, `wm_givessg`, `wm_givedoublebarrel`
  - `wm_giverevolvers`, `wm_givecola`
  - `wm_giverifle`, `wm_givem16`, `wm_givesmg`, `wm_givetec9`
  - `wm_givechaingun`, `wm_givemachinegun`
  - `wm_givelaunchers`, `wm_giveplasma`, `wm_giverailgun`, `wm_givebfg`
  - `wm_givechainsaws`, `wm_giveflamers`
  - `wm_equippistols`
- **Options → the VR Weapons pages** hold each gun's placement sliders and its
  "into the hand" rows.

## Requirements and load order

1. `RS_Ballistics`
2. `RS_VR_Reload`
3. `RS_VR_Weapons`

Required and optional pieces:
- **Engine:** requires UZDXREMA (DoomXR).
- **RS_Ballistics:** required. It draws the rounds, flashes, casings and flames,
  and the flamethrowers name its `RSB_Flame` at compile time.
- **RS_VR_Reload:** required. Every gun derives from its `WM_Gun`, every prop from
  its `WM_Prop`, and its archetypes run the pumps, revolvers and break actions.
- **RS_WorldHands:** optional; it supplies the two fists.
- **RS_Grenade:** optional; its grenade joins the set in slot 9, thrown by hand
  velocity, and it supplies the machine gun's launcher grenades.
- **RS_ShieldSaw:** optional; the ShieldSaw joins the set in slot 1: held, saw,
  a throw along your swing, route lock and return.
- **RS_ModelSwapper is not needed.** Every mesh is a copy in `models/`.

## How a gun is made

A gun is data, not code:
- **a card** in `WMCARD.txt`: its parts, stores, verbs, sounds and mesh numbers,
  on an RS_VR_Reload archetype where one fits;
- **a short weapon class** in `zscript/rs_vr_weapons/`: ammo, hand, slot, the shot,
  and its RS_Ballistics round, flash and casing profiles;
- **a prop class**, with its MODELDEF block and a CVARINFO placement set.

Card class, part and load ids are stable. Calibration bakes match on them.

## Building

```
powershell -File build.ps1
```

The build runs these steps in order:
1. Lints the menu.
2. Packs an allowlist to `%TEMP%\rs_vr_weapons_stage`.
3. Verifies every entry and every mesh and skin reference.
4. Compile-checks the staged pk3 (hidden, `-norun`) with RS_Ballistics and
   RS_VR_Reload.
5. Copies it over `RS_VR_Weapons.pk3` only if the check passes.

`-NoCompileCheck` packs without installing.

The build expects the DOOMWork workspace:
- `tools/menu_lint.py` and `tools/compile_check.ps1`;
- the RS_VR_Reload and RS_Ballistics pk3s beside this folder;
- UZDXREMA's `wadsrc` for the lint.

`python _pending/card_lint.py --wmcard` checks the cards without a build.

## Netplay

- **Pickups and the start:** decided in the playsim, from what each player
  carries and a server cvar.
- **Local effects:** local-only paths never use the playsim's random numbers.
- **Consoleplayer:** nothing that changes the game is keyed to it.

## Credits

- **Force Unleashed**, Ermac's (iAmErmac) "Rusted Legacy" VR mod, under the MIT
  License: see `licenses/force_unleashed_MIT.txt`.
  - Meshes: the Double Barrel, Plasma Carbine, Chaingun and its belt link, Rocket
    Launcher, BFG and its meter, Heavy Chainsaw, Flamethrower, shotgun shell,
    ammo pickups and hand ammo.
  - Sounds: the Double Barrel's.
  - Force Unleashed's own README credits Brutal Doom for sound effects, sprites
    and sounds, and Sketchfab authors for its models.
- **RS_ModelSwapper's meshes:**
  - the VanAlek VR set: the Doom shotgun, Super Shotgun and Heavy BFG;
  - Aliens: Eradication: the M37A2 and the Flamer;
  - MeatGrinder: the Tec9;
  - further sets whose origin is not recorded: the M4A3, Pistolet, three
    revolvers, Rifle, M16, SMG, Railgun, Plasma Rifle, Machine Gun, RPG and
    Chainsaw;
  - Brutal Doom v21: the assault shotgun mesh, carried but not used.
- **RS_Main:**
  - its weapon sound pool: pistols, revolvers, rifles, chainguns, launchers,
    plasma, BFG, chainsaws and magazine drops;
  - the Uncommon stats for the revolvers, rifles, SMGs, flamethrowers and
    railgun.
- **RS_Grenade:** the launcher grenade mesh.
- **Doom** (id Software): the weapon stats. Its sounds and floor sprites are used
  by name only; nothing from the IWAD ships here.

Where each model and sound came from, and what is recorded about its terms, is in
`_pending/ASSET_PROVENANCE.md`. Only Force Unleashed's licence is recorded;
everything else remains its authors'.
