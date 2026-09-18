# Model-card part data for RS_PSReload

Generated 2026-09-18 for the ModelSwapper lane (rs-modelswapper-bc), who asked for magazine and
slide surface INDICES and frames per ModelSwapper donor so RS_PSReload can drive parts on the
psprite layer. Regenerate with `python _pending/tools/ms_parts.py` from the repo root.

**The headline:** seven donors are byte-identical to meshes we have already measured, so our
numbers transfer to them directly. The rest were rebuilt on our side -- re-origined, renamed,
and collapsed to one frame because our parts move continuously rather than playing an
animation -- so neither our surface indices nor our frame numbers mean anything on the donor.

Transfers: MS_AE_Pistol, MS_Pistol, MS_AE_Shotgun, MS_Shotgun, MS_SuperShotgun, MS_Cola,
MS_RifleBD. No card at all: MS_RC_M32, MS_Chaingun.

```
RS_VR_Weapons model-card part data, for RS_PSReload (2026-09-18)
==============================================================================

SHAPE, so you can convert rather than guess:
  * We name surfaces, we do not index them. Indices below are resolved from the MD3 by
    reading its surface order, so they are OUR mesh's indices.
  * We do NOT store a seated frame and an out frame. A card stores an AXIS and a
    DISTANCE (or degrees about a pivot), because the reload system slides a part along
    your hand continuously rather than playing an animation. Where a frame pair is
    known it is in the card's comment, not a field.
  * role = feed is the magazine/cell. role = action is the slide/pump/bolt.

------------------------------------------------------------------------------
WM_AssaultShotgun   models/shotguns/AssaultShotgunGH/assaultshotgun_wm.md3
  5 surfaces, 1 frames
    action   slide      charginghandle surface chargehandle=1
             slide 10.000 along -1, 0, 0.005
    feed     magazine   magazine   surface mag=3
             slide 12.16 along 0, 0, -1
    trigger  -          trigger    surface trigger=2
             hinge 19.93 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_BFGHeavy   models/bfg/BFGHeavy/bfgheavy_wm.md3
  2 surfaces, 1 frames
    feed     magazine   cell       surface 
             slide 8.703 along 0, 0, -1
    trigger  -          trigger    surface trigger=1
             hinge 30.15 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_BFGRifle   models/bfg/BFGRifle/bfgrifle_wm.md3
  2 surfaces, 1 frames
    feed     magazine   cell       surface 
             slide 7.91 along 0, 0, -1
    trigger  -          trigger    surface trigger=1
             hinge 15.02 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_Bolter   models/plasma/Bolter/bolter_wm.md3
  3 surfaces, 1 frames
    feed     magazine   magazine   surface mag=1
             slide 9.01 along 0.1734, 0, -0.9849
    trigger  -          trigger    surface trigger=2
             slide 0.898 along -1, 0, -0.004
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_BullpupPump   models/shotguns/BullpupPump/bullpuppump_wm.md3
  3 surfaces, 1 frames
    -        forend     forend     surface forend=1
             slide 10.778 along -1, 0, 0.001
    trigger  -          trigger    surface trigger=2
             hinge 10.00 deg
------------------------------------------------------------------------------
WM_Chaingun   models/chainguns/ChaingunGH/chaingungh_wm.md3
  3 surfaces, 1 frames
    trigger  -          trigger    surface trigger=1
             hinge 20.01 deg
    support  support    support    surface 
             
    -        -          barrels    surface barrels=2
             hinge 120 deg
------------------------------------------------------------------------------
WM_Chainsaw   models/chainsaws/Chainsaw/chainsaw_wm.md3
  5 surfaces, 1 frames
    -        -          chain      surface chain=1
             
    -        -          chain2     surface chain2=4
             
    -        -          ripcord    surface ripcord=2
             slide 9.864 along -0.433, 0.001, 0.901
    hidden   -          cord       surface cord=3
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_ChainsawHeavy   models/chainsaws/ChainsawHeavy/chainsaw_heavy_wm.md3
  4 surfaces, 1 frames
    trigger  -          trigger    surface trigger=1
             hinge 15.0 deg
    -        -          chain      surface chain=2
             
    -        -          chain2     surface chain2=3
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_ColaRevolver   models/revolvers/Cola_Revolver/revolver.md3
  7 surfaces, 55 frames
    -        foregrip   crane      surface Magazine.wheel=4, Magazine_rod=1, Bullet_holes=3
             hinge 90.0 deg
    hammer   -          hammer     surface Hammer=5
             hinge 29.98 deg
    trigger  -          trigger    surface Trigger=6
             hinge 30.17 deg
------------------------------------------------------------------------------
WM_DoubleBarrel   models/shotguns/DoubleBarrel/doublebarrel_wm.md3
  7 surfaces, 1 frames
    -        foregrip   barrels    surface barrels=1
             hinge 36.96 deg
    trigger  -          trigger    surface trigger=2
             hinge 19.24 deg
------------------------------------------------------------------------------
WM_Flamer   models/flamers/Flamer/flamer_wm.md3
  4 surfaces, 1 frames
    feed     magazine   canister   surface canister=2
             slide 1.03 along 0, 0, -1
    trigger  -          trigger    surface trigger=3
             hinge 16.70 deg
    hidden   -          pilotflame surface pilotflame=1
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_Flamethrower   models/flamers/Flamethrower2/flamethrower2_wm.md3
  4 surfaces, 1 frames
    feed     magazine   canister   surface canister=2
             slide 13.62 along 0, 0, -1
    trigger  -          trigger    surface trigger=1
             hinge 14.98 deg
    hidden   -          pilotflame surface pilotflame=3
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_LongbarChainsaw   models/chainsaws/LongbarChainsaw/longbarchainsaw_wm.md3
  3 surfaces, 1 frames
    -        -          chain      surface chain=1
             
    -        -          chain2     surface chain2=2
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_M16   models/rifles/M16/m16_wm.md3
  5 surfaces, 1 frames
    action   slide      charginghandle surface charginghandle=1
             slide 5.600 along -1, 0, -0.023
    feed     magazine   magazine   surface magazine=2
             slide 11.81 along -0.105, 0, -0.995
    trigger  -          trigger    surface trigger=3
             slide 1.245 along -0.997, 0, 0.083
    hidden   -          brass      surface casing=4
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_M4A3   models/pistols/m4a3.md3
  5 surfaces, 20 frames
    action   slide      slide      surface m4a3_slide=3
             slide 6.784 along -1, 0, 0
    feed     magazine   magazine   surface m4a3_magazine=4
             slide 17.0 along -0.354, 0, -0.935
    hammer   -          hammer     surface m4a3_hammer=2
             hinge 62.15 deg
    trigger  -          trigger    surface m4a3_trigger=1
             hinge 11.0 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_MachineGun   models/chainguns/MachineGun/machinegun_wm.md3
  7 surfaces, 1 frames
    -        foregrip   launchertube surface launchertube=4
             slide 9.504 along 1, 0, 0.001
    -        -          launcherlatch surface launcherlatch=6
             hinge 18.93 deg
    -        -          launchertrigger surface launchertrigger=5
             hinge 19.99 deg
    trigger  -          trigger    surface trigger=2
             slide 0.598 along -1, 0, -0.008
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_Moonlight   models/revolvers/Revolver/rev_wm.md3
  10 surfaces, 1 frames
    -        foregrip   barrel     surface python.007=3, python.005=1
             hinge 63.07 deg
    hammer   -          hammer     surface python.006=2
             hinge 54.66 deg
------------------------------------------------------------------------------
WM_Pistolet   models/pistols/pistolet.md3
  6 surfaces, 32 frames
    action   slide      slide      surface slide=4
             slide 3.889 along -1, 0, 0
    feed     magazine   magazine   surface mag=1, mag.001=3
             slide 10.0 along -0.31, 0, -0.95
    trigger  -          trigger    surface rec.001=5
             hinge 40.8 deg
    hidden   -          brass      surface casing=2
             
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_PlasmaCarbine   models/plasma/PlasmaCarbine/plasmacarbine_wm.md3
  3 surfaces, 1 frames
    feed     magazine   cell       surface cell=1
             slide 10.387 along -0.2308, 0, -0.9730
    trigger  -          trigger    surface trigger=2
             hinge 25.04 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_PlasmaRifle   models/plasma/PlasmaRifle/plasmarifle_wm.md3
  3 surfaces, 1 frames
    feed     magazine   cell       surface cell=1
             slide 12.33 along 0.1942, 0, -0.9810
    trigger  -          trigger    surface trigger=2
             hinge 19.96 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_PumpDoom   models/shotguns/Shotgun/shotgun.md3
  3 surfaces, 32 frames
    -        forend     forend     surface doomshot.001=1
             slide 7.400 along -1, 0, 0.002
------------------------------------------------------------------------------
WM_PumpM37   models/shotguns/AE_Shotgun/m37a2.md3
  4 surfaces, 29 frames
    -        forend     forend     surface m37a2_pump=1
             slide 11.205 along -1, 0, 0
    trigger  -          trigger    surface m37a2_trigger=2
             hinge 31.11 deg
    hidden   -          bakedshell surface shell=3
             
------------------------------------------------------------------------------
WM_RPG   models/launchers/RPG/rpg_wm.md3
  10 surfaces, 1 frames
    feed     magazine   drum       surface drum=2
             slide 10.75 along 0, -0.944, 0.329
    hidden   -          emptychamber surface rocket7=9
             
    trigger  -          trigger    surface trigger=1
             slide 1.397 along -1, 0, -0.011
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_Railgun   models/railguns/Railgun/railgun_wm.md3
  5 surfaces, 1 frames
    feed     magazine   magazine   surface magazine=3
             slide 10.03 along 0, 0, -1
    trigger  -          trigger    surface trigger=4
             hinge 22.85 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_Rifle   models/rifles/Rifle/Rifle.md3
  6 surfaces, 32 frames
    action   slide      charginghandle surface liikkuvat=0, ejectport=1
             slide 7.117 along -1, 0, 0
    feed     magazine   magazine   surface Lipas=3
             slide 22.3 along -0.025, 0, -1
    trigger  -          trigger    surface trigger=2
             hinge 16.98 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_RotaryGun   models/chainguns/RotaryGun/rotarygun_wm.md3
  4 surfaces, 1 frames
    trigger  -          trigger    surface trigger=2
             hinge 15.15 deg
    support  support    support    surface 
             
    -        -          barrels    surface barrels=1
             hinge 60 deg
------------------------------------------------------------------------------
WM_RotaryLauncher   models/launchers/RotaryLauncher/rotarylauncher_wm.md3
  4 surfaces, 1 frames
    trigger  -          trigger    surface trigger=2
             hinge 15.05 deg
    support  support    support    surface 
             
    -        -          tubes      surface tubes=1
             hinge 60 deg
------------------------------------------------------------------------------
WM_SMG   models/smgs/SMG/smg_wm.md3
  4 surfaces, 1 frames
    action   slide      charginghandle surface charginghandle=1
             hinge 5.26 along 0, 0, 1
    feed     magazine   magazine   surface magazine=3
             slide 26.15 along -0.298, 0, -0.954
    trigger  -          trigger    surface trigger=2
             slide 0.978 along -1, 0, 0
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_SSG   models/shotguns/SuperShotgun/ssg.md3
  6 surfaces, 26 frames
    -        foregrip   barrels    surface ssgbarrel.006=4
             hinge 58.55 deg
------------------------------------------------------------------------------
WM_Tec9   models/smgs/Tec9/tec9_wm.md3
  4 surfaces, 1 frames
    action   slide      bolt       surface bolt=3
             slide 7.091 along -1, 0, 0
    feed     magazine   magazine   surface magazine=1
             slide 18.3 along 0.013, 0, -1
    trigger  -          trigger    surface trigger=2
             hinge 25.11 deg
    support  support    support    surface 
             
------------------------------------------------------------------------------
WM_Unmaker   models/unmaker/Unmaker/unmaker_wm.md3
  3 surfaces, 1 frames
    feed     magazine   skull      surface flap=1, lever=2
             slide 7.0 along 0, 0, 1
    support  support    support    surface 
             

==============================================================================
DONOR MATCH: does the RS_ModelSwapper mesh carry the same surface list?
If SAME, our indices transfer. If not, nothing above is usable for that gun.

MS_AE_Flamer         models/hud/AE_Flamer/m260b.md3
    ours models/flamers/Flamer/flamer_wm.md3 (4 surf, 1 frames) vs donor (3 surf, 20 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:pilotflame, 2:canister, 3:trigger
      donor: 0:m260b, 1:m260b_canister, 2:m260b_trigger
MS_AE_Pistol         models/hud/AE_Pistol/m4a3.md3
    ours models/pistols/m4a3.md3 (5 surf, 20 frames) vs donor (5 surf, 20 frames) -- SAME ORDER, indices transfer
MS_AE_Shotgun        models/hud/AE_Shotgun/m37a2.md3
    ours models/shotguns/AE_Shotgun/m37a2.md3 (4 surf, 29 frames) vs donor (4 surf, 29 frames) -- SAME ORDER, indices transfer
MS_BD_RailGun        models/hud/RailGun/RailGun.md3
    ours models/railguns/Railgun/railgun_wm.md3 (5 surf, 1 frames) vs donor (5 surf, 37 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:scope, 2:scopeglass, 3:magazine, 4:trigger
      donor: 0:Scope, 1:ScopeGlass, 2:Gun, 3:Trigger, 4:Mag-Bat
MS_Bolter            models/hud/Bolter/Bolter.md3
    ours models/plasma/Bolter/bolter_wm.md3 (3 surf, 1 frames) vs donor (2 surf, 5 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:mag, 2:trigger
      donor: 0:main_part.003_Plane, 1:main_part.003_Plane
MS_Chaingun          models/hud/Chaingun/Chaingun.md3
    6 surfaces, 16 frames -- WE HAVE NO CARD for this one
      surfaces: 0:Runko, 1:Runko, 2:Pipe, 3:Runko, 4:Trigger, 5:Grip
MS_Cola              models/hud/Cola_Revolver/revolver.md3
    ours models/revolvers/Cola_Revolver/revolver.md3 (7 surf, 55 frames) vs donor (7 surf, 55 frames) -- SAME ORDER, indices transfer
MS_Machinegun        models/hud/Machinegun/Machinegun.md3
    ours models/chainguns/MachineGun/machinegun_wm.md3 (7 surf, 1 frames) vs donor (6 surf, 36 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:magazine, 2:trigger, 3:launcher, 4:launchertube, 5:launchertrigger, 6:launcherlatch
      donor: 0:alt-trig-reload, 1:alt-frame, 2:alt-trig, 3:alt-pipe, 4:Trigger, 5:M249_lowpoly
MS_Pistol            models/hud/Pistol/pistolet.md3
    ours models/pistols/pistolet.md3 (6 surf, 32 frames) vs donor (6 surf, 32 frames) -- SAME ORDER, indices transfer
MS_PlasmaRifle       models/hud/PlasmaRifle/PlasmaRifle.md3
    ours models/plasma/PlasmaRifle/plasmarifle_wm.md3 (3 surf, 1 frames) vs donor (4 surf, 30 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:cell, 2:trigger
      donor: 0:Frame, 1:Battery, 2:Trigger, 3:Frame
MS_RC_M32            models/hud/RC_M32/m32.md3
    9 surfaces, 37 frames -- WE HAVE NO CARD for this one
      surfaces: 0:trigger_plate, 1:trigger_guard, 2:magazine_back, 3:gun_barrel, 4:magazine_bracket_front, 5:magazine, 6:gun_body, 7:magazine_bracket, 8:trigger
MS_Revolver          models/hud/Revolver/rev.md3
    ours models/revolvers/Revolver/rev_wm.md3 (10 surf, 1 frames) vs donor (11 surf, 41 frames) -- DIFFERENT, do not transfer
      ours : 0:python.004, 1:python.005, 2:python.006, 3:python.007, 4:python.008, 5:python.009, 6:python.010, 7:python.011, 8:python.012, 9:python.013
      donor: 0:python.004, 1:python.005, 2:python.006, 3:python.007, 4:python.008, 5:python.009, 6:python.010, 7:python.011, 8:python.012, 9:python.013, 10:python.014
MS_Rifle             models/hud/Rifle/m16.md3
    ours models/rifles/M16/m16_wm.md3 (5 surf, 1 frames) vs donor (4 surf, 41 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:charginghandle, 2:magazine, 3:trigger, 4:casing
      donor: 0:weapon.002, 1:weapon.003, 2:weapon.004, 3:weapon.005
MS_RifleBD           models/hud/RifleBD/Rifle.md3
    ours models/rifles/Rifle/Rifle.md3 (6 surf, 32 frames) vs donor (6 surf, 32 frames) -- SAME ORDER, indices transfer
MS_RocketLauncher    models/hud/RocketLauncher/RPG.md3
    ours models/launchers/RPG/rpg_wm.md3 (10 surf, 1 frames) vs donor (13 surf, 39 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:trigger, 2:drum, 3:rocket1, 4:rocket2, 5:rocket3, 6:rocket4, 7:rocket5, 8:rocket6, 9:rocket7
      donor: 0:Frame, 1:Frame, 2:Cube, 3:Frame, 4:Trigger, 5:Cube, 6:Cube, 7:Cube, 8:Cube, 9:Cube, 10:Cube, 11:Cube, 12:Cube
MS_Shotgun           models/hud/Shotgun/shotgun.md3
    ours models/shotguns/Shotgun/shotgun.md3 (3 surf, 32 frames) vs donor (3 surf, 32 frames) -- SAME ORDER, indices transfer
MS_SuperShotgun      models/hud/SuperShotgun/ssg.md3
    ours models/shotguns/SuperShotgun/ssg.md3 (6 surf, 26 frames) vs donor (6 surf, 26 frames) -- SAME ORDER, indices transfer
MS_Tec9              models/hud/Tec9/tec9.md3
    ours models/smgs/Tec9/tec9_wm.md3 (4 surf, 1 frames) vs donor (4 surf, 6 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:magazine, 2:trigger, 3:bolt
      donor: 0:Cube, 1:Cube, 2:Cube, 3:Cube
MS_Unmaker           models/hud/Unmaker/Unmaker.md3
    ours models/unmaker/Unmaker/unmaker_wm.md3 (3 surf, 1 frames) vs donor (3 surf, 16 frames) -- DIFFERENT, do not transfer
      ours : 0:body, 1:flap, 2:lever
      donor: 0:mp_salvocannon, 1:mp_salvocannon, 2:mp_salvocannon
```
