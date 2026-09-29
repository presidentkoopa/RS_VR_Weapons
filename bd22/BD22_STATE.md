# RS_VR_BD22 -- state at 2026-09-28

Brutal Doom v22's guns as VR world models with hand reloads. 25 guns. Models are Brutal
Doom **v21's**, from `VR_WeaponSetRebuild/WeaponSets/br_vr` -- BD22 itself ships no weapon
models, its guns are sprites.

## LOAD ORDER (both `BD22.zdl` and `test.zdl` on the desktop are set to this)

    brutal22test6.pk3
    RS_Ballistics.pk3          reload needs RSB_Flash from it
    RS_VR_Reload.pk3           the reload system; WM_Gun, WM_Prop, WM_SetBridge
    RS_WorldHands.pk3          without it no hand is drawn on the parts
    RS_VR_Weapons.pk3          WM_Player still lives here
    RS_VR_BD22.pk3
    RS_VR_BD22_Players.pk3     starts you holding BD_ guns
    RS_VR_BD22_Slots.pk3       puts them on the number keys
    RS_Avatar.pk3

## WHAT WORKS

Pistol shoots and its slide racks (owner, in headset). 14 of 25 guns reload:
AssaultShotgun, Buzzsaw, Flamethrower, M79, MP40, Machinegun, Minigun, Pistol, Plasma,
RPG, Railgun, Rifle, SMG, Unmaker.

11 are rulings and correct as they are: Axe, BFG, BFG10k, Chainsaw, Dragonslayer,
FlameCannon, Grenade, Hellish, Revolver, SSG, Shotgun. The owner confirmed BFG, BFG10k,
FlameCannon and Hellish do not reload in Brutal Doom. **Hellish is the Revenant's shoulder
launcher** -- its body surface is literally `mp_revenant`.

## HOW THE MAGAZINES WERE FOUND, because it is the lesson of the day

The pipeline shipped **21 of 25 guns with no feed part at all** and nothing flagged it --
not card_lint, not ship_set, not the pack verifier, not the compile check. A reload card
with no magazine is silent. Do not trust silence.

Four of them were solved by **Vanilla having already carded the identical mesh**:
flamethrower, RPG, Unmaker, plasma. Matched by vertex count, then by solving the rigid
transform between the two meshes and mapping Vanilla's carve across -- the flamethrower's
canister landed on 770 BD22 body vertices at **zero distance**. Always check Vanilla first.

Traps hit on the way, all real:
  * "slides straight, does not rotate" finds the BOLT on a gun with a reciprocating bolt.
  * The machinegun's biggest sliding part is its **over-under grenade launcher**.
  * The buzzsaw's belt drum comes off **sideways (+y)**, so no downward test finds it.
  * The plasma's cell is a **34-vertex flat quad**; I dismissed it, Vanilla had carded it.

## WHAT IS IN, PENDING A REBUILD (the pk3 was locked -- owner was in game)

`WMSHEET.bd22`: 21 guns now carry **Brutal Doom's own numbers**, read from its
`actors/Weapons/*.dec` -- damage, pellets, spread, firetics, firesound. Rifle 20, MG42 24,
Revolver 22 at 7 pellets / 20x7, SSG 9 pellets. Owner's call: **match BD exactly**.

Each also got an existing RS_Ballistics profile (round / flash / ejecta / recoil) -- no new
effects authored. e.g. Rifle -> rifle_556 / rifle / brass_556; MP40 -> ww2_mp40 throughout.

## OPEN

1. **Rebuild.** `powershell -ExecutionPolicy Bypass -File E:\DOOMWork\RS_VR_BD22\build.ps1`
2. **Five guns need a second pass** on their fire data -- minigun, hellish, BFG10k, Unmaker,
   flamethrower. Their Fire states are structured differently and the extractor got nothing.
3. **18 of 25 MODELDEF blocks still have `Offset 0.000 0.000 0.000`.** That offset is what
   puts the grip on the controller. Not a code bug -- it is a headset job with the
   `bd_<gun>_ofs_*` sliders, then bake the numbers back into MODELDEF.
4. **Ballistics tiers.** `rsb_tier` is 0 off, 1 plain, 2 normal, 3 heavy (recommended),
   4 extreme; `rsb_style` is "" or gritty / cinematic / clean. Owner wants: ballistics ON
   replaces BD's visuals entirely; **ballistics OFF falls back to Brutal Doom's own**.
   THE CATCH: our guns REPLACE BD's classes, so BD's weapon states never run and its
   `DecorativeTracer` / `RifleCaseSpawn` / flare spawns never fire. "Off" therefore has to
   mean OUR gun spawns BD's effect actors by name. They all still exist in the mod.
5. **Secondary fire** is untouched. BD's rifle has an under-barrel grenade launcher
   (`ShortGrenade`), and its AltFire is ADS zoom, which is meaningless in VR.

## DO NOT

* Do not put `replaces <BrutalDoomClass>` on the gun classes. ZScript cannot replace a
  DECORATE class; it stops the whole pack loading and you get sprite guns with no error.
  `make_gun_classes.py` has been stopped from writing it.
* Do not rebuild the weapon slot table on a timer. That was a haptic pulse every second
  from the moment a level loaded. Slots belong to `RS_VR_BD22_Slots.pk3`.
* Do not regenerate `WMCARD.bd22` or the `*_wm.md3` models. The models were re-posed by
  hand to the BD21 aim frame and every card point moved with them; the magazines above were
  added by hand. Regenerating throws all of it away.
