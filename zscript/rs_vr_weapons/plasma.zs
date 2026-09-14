// ============================================================================
// THE PLASMA GUNS -- slot 9, beside the railgun. The plasma rifle in the main hand,
// the plasma carbine in the off hand.
//
// PLASMA RIFLE: RS_ModelSwapper's plasma rifle mesh as plasmarifle_wm.md3 (body, cell,
// trigger); its battery pack slides out 11 degrees forward of straight down.
// PLASMA CARBINE: Force Unleashed's plasma rifle and its cell, merged into
// plasmacarbine_wm.md3 (body, cell, trigger); the cell rocks out as it drops.
// Measurements in _pending/PLASMA_CARDS.md.
//
// THE SHOT is vanilla's plasma rifle: a PlasmaBall (its own 5 x 1d8) every 3 tics
// while the trigger is held -- FullAuto, FireTics 3. 50 cells a magazine, the owner's
// number.
//
// BOTH LIVE: Weapon.AmmoType1 "Cell" and WM_Gun.ShotClass "RSB_PlasmaBall" -- RS_Ballistics'
// subclass of the engine's PlasmaBall (rsb/projectiles.zs): speed, damage, flags and states
// are the PlasmaBall's, untouched; RS_Ballistics adds only what each machine draws, motes
// along the flight and a spark splash, ring and light where it hits. After a firing
// run each waits 20 tics before it can fire or switch again -- vanilla's
// `PLSG B 20 A_ReFire` -- through the reload system's WM_Gun.ReleaseTics
// (RS_VR_Reload.pk3 09-13 15:18).
// ============================================================================

class WM_PlasmaRifle : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "plasma_rifle";
		Weapon.SelectionOrder 1700;
		Weapon.SlotNumber 9;
		Inventory.PickupMessage "Plasma Rifle";
		Tag "Plasma Rifle";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "RSB_PlasmaBall";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 3;
		WM_Gun.ReleaseTics 20;
	}
}

// THE BLUE PLASMA RIFLE -- the Plasma Rifle pickup's second gun, in the off hand (the owner, 09-14: the Railgun goes
// to Vanilla+; "copy and rename what we have now and change the skin to be more blue"). The Plasma Rifle exactly,
// on its own mesh with a steel-blue skin.
class WM_PlasmaRifleBlue : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "plasma_rifle";
		Weapon.SelectionOrder 1750;
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 9;
		Inventory.PickupMessage "Blue Plasma Rifle";
		Tag "Blue Plasma Rifle";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "RSB_PlasmaBall";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 3;
		WM_Gun.ReleaseTics 20;
	}
}

class WM_PlasmaCarbine : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "plasma_carbine";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9500;
		Weapon.SlotNumber 9;
		Inventory.PickupMessage "Plasma Carbine";
		Tag "Plasma Carbine";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "RSB_PlasmaBallCarbine";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 3;
		WM_Gun.ReleaseTics 20;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropPlasmaRifle : WM_Prop {}
class WM_PropPlasmaRifleBlue : WM_Prop {}
class WM_PropPlasmaCarbine : WM_Prop {}
