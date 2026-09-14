// ============================================================================
// THE MEATGRINDER FAMILY -- seven guns from RS_Main's MeatGrinder models (and RS_GH's assault
// shotgun), each beside the Doom weapon whose slot it shares. Ids frozen by the build lane
// (doomwork-5e, 09-14); cards by the reload lane (uzdxrema-63), measured on the _wm meshes this
// package built (_pending/MEATGRINDER_MESHES.md).
//
//   Slot  Main hand            Off hand
//   1     WM_LongbarChainsaw
//   3     WM_AssaultShotgun    WM_BullpupPump
//   7     WM_RotaryGun
//   8                          WM_RotaryLauncher
//   9                          WM_Bolter
//   0     WM_BFGRifle
//
// THE SHOTS -- the owner's words (09-14) where given, otherwise vanilla by the owner's table:
//   ASSAULT SHOTGUN   "an auto-shotgun weapon with a 14 round magazine, it fires 1.6 the rate of the
//                     normal shotgun": the Doom shotgun's seven pellets and spread, FireTics 28 --
//                     vanilla's 44-tic shotgun cycle over 1.6. Hold-to-fire or a pull per shot waits
//                     on the owner; until then a pull per shot.
//   BULLPUP PUMP      "a 4 shot ssg": every shell is the super shotgun's blast -- twenty pellets, its
//                     spread -- out of a 4-shell tube, worked by the pump the mesh animates. One shell
//                     a blast, where the SSG spends two.
//   BOLTER            "a high damage, single shot plasma gun ... we can make it anything once we get
//                     the card working": one heavy plasma bolt a pull (WM_BolterBolt, 20 x 1d8 against
//                     the plasma ball's 5 x 1d8), one cell, FireTics 18.
//   BFG RIFLE         vanilla BFG, as WM_BFG.
//   ROTARY GUN        vanilla chaingun, as WM_Chaingun.
//   ROTARY LAUNCHER   vanilla rocket launcher, as WM_RPG.
//   LONGBAR CHAINSAW  vanilla chainsaw, as WM_ChainsawHeavy -- no ripcord in the mesh, so it runs on
//                     its trigger.
//
// CARRIED, NOT PUT IN HAND, like every family: StartItems and slots in loadout.zs, and the arsenal
// page's rows (wm_giveassaultshotguns, wm_givebolter, wm_givebfgrifle, wm_giverotaries,
// wm_givelongbar). Their cards are the last seven in WMCARD.txt.
// ============================================================================

class WM_AssaultShotgun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "buckshot";
		WM_Gun.FlashProfile "shotgun";
		WM_Gun.EjectaProfile "hull_12ga";
		Weapon.AmmoType1 "Shell";
		Weapon.SelectionOrder 1320;
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "Assault shotgun";
		Tag "Assault Shotgun";
		WM_Gun.ShotPellets 7;
		WM_Gun.ShotSpread 5.6, 0;
		WM_Gun.FireTics 28;
	}
}

class WM_BullpupPump : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "buckshot";
		WM_Gun.FlashProfile "shotgun_double";
		WM_Gun.EjectaProfile "hull_12ga";
		+WEAPON.OFFHANDWEAPON
		Weapon.AmmoType1 "Shell";
		Weapon.SelectionOrder 9150;
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "Bullpup pump";
		Tag "Bullpup Pump";
		WM_Gun.ShotPellets 20;
		WM_Gun.ShotSpread 11.25, 7.097;
	}
}

class WM_Bolter : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "plasma";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9510;
		Weapon.SlotNumber 9;
		Inventory.PickupMessage "Bolter";
		Tag "Bolter";
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "WM_BolterBolt";
		WM_Gun.FireTics 18;
	}
}

// THE BOLTER'S BOLT: RS_Ballistics' plasma ball -- its flight, its motes and its impact -- hitting four
// times as hard. Everything else is the engine's PlasmaBall. A compile-time reference to RS_Ballistics,
// which this package already loads after (the flamethrowers name RSB_Flame).
class WM_BolterBolt : RSB_PlasmaBall
{
	Default
	{
		Damage 20;
	}
}

class WM_BFGRifle : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "bfg";
		Weapon.SelectionOrder 2810;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "BFG rifle";
		Tag "BFG Rifle";
		Weapon.AmmoType1 "Cell";
		WM_Gun.RoundsPerShot 40;
		WM_Gun.ShotClass "RSB_BFGBall";
		WM_Gun.ChargeTics 30;
		WM_Gun.ChargeSound "wm/bfg/charge";
		WM_Gun.FireTics 30;
	}
}

class WM_RotaryGun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "rifle_556";
		WM_Gun.FlashProfile "smg";
		WM_Gun.EjectaProfile "brass_556";
		Weapon.SelectionOrder 710;
		Weapon.SlotNumber 7;
		Inventory.PickupMessage "Rotary gun";
		Tag "Rotary Gun";
		Weapon.AmmoType1 "Clip";
		WM_Gun.ShotSpread 5.6, 0;
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 4;
	}
}

class WM_RotaryLauncher : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "rocket";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9710;
		Weapon.SlotNumber 8;
		Inventory.PickupMessage "Rotary launcher";
		Tag "Rotary Launcher";
		Weapon.AmmoType1 "RocketAmmo";
		WM_Gun.ShotClass "RSB_Rocket";
		WM_Gun.FireTics 20;
	}
}

class WM_LongbarChainsaw : WM_Gun
{
	Default
	{
		Weapon.SelectionOrder 2210;
		Weapon.SlotNumber 1;
		Inventory.PickupMessage "Longbar chainsaw";
		Tag "Longbar Chainsaw";
		WM_Gun.ShotSaw true;
		WM_Gun.SawSounds "wm/saw/loop", "wm/saw/hit";
		Weapon.ReadySound "wm/saw/idle";
		Weapon.UpSound "wm/saw/start";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 4;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropAssaultShotgun : WM_Prop {}
class WM_PropBullpupPump : WM_Prop {}
class WM_PropBolter : WM_Prop {}
class WM_PropBFGRifle : WM_Prop {}
class WM_PropRotaryGun : WM_Prop {}
class WM_PropRotaryLauncher : WM_Prop {}
class WM_PropLongbarChainsaw : WM_Prop {}
