# Models pack + weapon sets: design

Weapons lane (leading it, the owner's call), 2026-09-14, for the owner's OK. **Nothing is built.**

- **Builds on:** the reload lane's `RS_VR_Reload/THE_CARD_PLAN.md` (model card, weapon sheet, tiny class).
- **Adds:** the second half, splitting into packs.
- **Engine:** no changes. ZScript and data only.

**The owner:** "define weapon sets by pointing them at the model we want and saying 'This model. These sounds. This skin.
These damage values, rate of fire. These ballistic parameters.' ... we load Doom + Models + Vanilla weapons, or Doom +
Models + Koopa'sLaserWeapons... the only difference in file is the weaponset".

---

## 1. Hard requirements

1. **The Vanilla set stays usable.**
   - The owner: "ensure the existing vanilla weaponset is something i can still get at and use once this is over".
   - After the switch, "Doom + Models + Vanilla" loads and plays the same: the same guns, pairs, pickups, sounds, looks and
     reloads.
   - **Verified two ways:**
     - the `wm_card` before/after printout of every gun must match;
     - a before/after pass over `RS_VR_Reload/VANILLA_TEST_CHECKLIST.md`, gun by gun: get it from its pickup, fire, reload,
       sound, flash. Every row the same, or the step doesn't commit.
   - **Rollback, already frozen by the build lane:** local tag `vanilla-set-2026-09-14` in every repo, plus
     `E:\DOOMWork\_backups\vanilla-set-2026-09-14\` (engine, mods, glow, README). Today's set loads from there whatever happens
     mid-switch.
2. **Nothing the owner tuned is lost** (section 5).
3. **No autoloads.** The owner picks the files.
   - A weapon set loaded without the models pack says so plainly at startup.
   - Two sets loaded at once is a startup error, and the README says so, as it does today for the folded grenade.
4. **Netplay:** the active set is the loaded files plus server cvars, identical on every machine, never a local choice.
5. **Published repos stay.** RS_VR_Weapons keeps existing and online. The models pack is a new folder.
6. **General, not per gun:** a sheet is data; the code is RS_VR_Reload's shared archetypes.
7. **No Vanilla+ design here.** This only shows that a Vanilla set and a future set are different sheet files.

## 2. Load order

**Doom → RS_Ballistics → RS_VR_Reload → RS_VR_Models → ONE weapon set** (today: RS_VR_Weapons = Vanilla), with RS_WorldHands,
RS_VRBody and the weapon wheel where they load now.

## 3. What lives where

| RS_VR_Reload (unchanged role) | RS_VR_Models (new) | A weapon set (RS_VR_Weapons = Vanilla) |
|---|---|---|
| Archetypes, parser, rigs | **Model cards** (a WMCARD lump): parts, grabs, stores, verbs, muzzle/barrel/eject, magazine and round meshes, `type`, `hands`, `magfamily`, default handling sounds | **Sheets** (a WMSHEET lump): which model, capacity, what it fires from, fire sound, damage, pellets, spread, fire rate, full auto, shot class, RS_Ballistics profile names; optional skin and handling-sound overrides |
| Hand seats `wm_hs_*`, grab page `wm_gp_*`, pouch | Meshes, skins, loose magazines, rounds, links | **Tiny gun classes:** name, slot, selection order, ammo type, off-hand flag, display name, pickup message, up/ready sound, plus any special code (the Unmaker's beam and melt, the grenade, the ShieldSaw) |
| NEW: the sheet reader, re-apply, `wm_card` printout | Prop classes + MODELDEF prop blocks + flying-pickup blocks | The player's start and slots, Doom pickup pairs, give commands, arsenal page, KEYCONF |
| | Placement cvars `wm_<model>_*` + their menu pages | Its own sounds; optionally its own RSBDEFS looks (RS_Ballistics reads every RSBDEFS lump, later wins) |
| | Handling sound files + SNDINFO; asset provenance | Set switches (grenade and ShieldSaw start) |

**One engine rule decides a split:** a MODELDEF block that names a class not loaded is a startup error
(`models.cpp`, "Unknown actor type").
- So a block lives in the pack that declares its class: prop blocks go to the models pack with their prop classes.
- A block that names a weapon class stays in the set: for example, the grenade's own weapon-layer model.

## 4. Names

- **Gun classes keep today's names** inside Vanilla (WM_M4A3 and so on), so saves, give commands, pickups and the wheel keep
  working.
- **Model cards and props are named for the model**, with no mod or author names. A name table, one row per model, comes in
  step 1 for the owner's OK.
- **Placement becomes `wm_<model>_*`** in the models pack.
- **Unchanged:** hand seats (`wm_hs_<type>_*`, keyed by type) and the grab page (`wm_gp_*`, keyed by hand and slot).
- **The bake ledger and `bake_defaults.py --cards`** follow model names through the same rename map (section 5).

## 5. The owner's saved values (read-only from the ini, 09-14)

41 values differ from their defaults.

| What | How many | Affected by the rename? |
|---|---|---|
| Grab ovals `wm_gp_*` | 16 | No: keyed by hand and slot |
| Per-gun placement `wm_<gun>_*` | 0 | Nothing to carry |
| Hand seats `wm_hs_*` | 0 | No: keyed by type |
| Bake ledger `wm_bake_ledger_*` | 0 entries | Nothing to carry |
| ShieldSaw stow and mount (`rs_ss_*`), grenade debug | 6 | No: names unchanged |
| Older per-hand magazine/slide tuning `wm_main_*` / `wm_off_*` (RS_VR_Reload) | 19 | No: names unchanged |

- **The migration anyway:** a rename map (old placement name → new).
  - Applied once on load to this machine's own settings: render-only, no gameplay.
  - A value tuned before the rename lands still carries over.
  - `bake_defaults.py` uses the same map for ledger keys.
- **Plainly: please hold headset calibration of placement, hands and grabs until step 6 lands.** Today nothing tuned is keyed
  to gun names, so the rename is free. It stays free if you wait.

## 6. How a sheet plays

THE_CARD_PLAN section 4, plus the weapons lane's notes:
- **Re-applied** on WorldLoaded and every rebind, so a save never keeps stale numbers.
- **The off-hand flag stays in the class.** The engine and the Sound Selection read it before any sheet loads.
- **A sheet's skin** is applied to the prop when the rig spawns it; the flying pickups already swap skins this way.
- **card_lint** refuses a sheet capacity the model can't hold.
- **The Sound Selection generator** learns sheets and model cards. Today it reads class lines, which step 5 removes.

## 7. Steps

Each step: compile check, install, then the build lane commits before the next.

| # | Who | What | Proof |
|---|---|---|---|
| 0 | build lane | **Done 09-14:** tag `vanilla-set-2026-09-14` in every repo and `E:\DOOMWork\_backups\vanilla-set-2026-09-14\` (the rollback) | the copy loads |
| 1 | weapons + reload lanes, paper | The key table (THE_CARD_PLAN section 1 + section 6 above) and the model name table | the owner's yes |
| 2 | reload lane | Sheet reader, re-apply, `wm_card` / `wm_card check`; no sheet yet | printout = today |
| 3 | weapons lane | WMSHEET.txt for the 34 carded guns, today's numbers; card_lint and Sound Selection learn sheets | `wm_card check` empty; printout unchanged |
| 4 | weapons lane | The copied lines leave the classes and cards | printout unchanged |
| 5 | weapons lane | Model and placement rename, with the rename map | printout unchanged apart from names |
| 6 | weapons lane | The split: RS_VR_Models (new folder) and RS_VR_Weapons as the Vanilla set | printout unchanged; the before/after VANILLA_TEST_CHECKLIST pass matches row for row, in the owner's headset |
| after | the owner leads | New sets are new sheet files | |

## 8. Choices for the owner

1. **Pack names.** A new `RS_VR_Models`, with `RS_VR_Weapons` staying the Vanilla set. **Recommend: yes.**
2. **Model names.** Named for what the model is, no mod or author names, the table in step 1. **Recommend: yes.**
3. **Calibration.** Hold placement, hand and grab calibration until the rename (step 5) lands. **Recommend: yes.**
4. **Publishing.** RS_VR_Models stays a local folder until you decide to publish it. **Recommend: local first.**
