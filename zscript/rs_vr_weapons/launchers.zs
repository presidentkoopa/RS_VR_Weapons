// ============================================================================
// THE ROCKET LAUNCHERS -- slot 8. The rocket launcher in the main hand, the RPG in the
// off hand. Both fired straight from their magazine, both held in two hands.
//
// ROCKET LAUNCHER: Force Unleashed's launcher and its three-rocket side rack, merged into
// rocketlauncher_wm.md3 (body, trigger, rack, rocket1-3); the rack slides out +y.
// RPG: RS_ModelSwapper's rocket launcher as rpg_wm.md3 (body, trigger, drum, rocket1-7):
// a seven-chamber drum on the tube, lifted off whole. Rest frame 4 -- the donor's ready
// frame 5 catches the drum mid-turn. Measurements in _pending/ROCKET_CARDS.md.
//
// THE SHOT is vanilla's rocket launcher: a Rocket (its own 20 x 1d8 and blast) about
// every 20 tics -- MISG B 8, B 12 -- again and again while the trigger is held, as vanilla's
// A_ReFire does (FullAuto; RS_VR_Reload VANILLA_PARITY.md F1). Six rockets a magazine, the
// owner's number; the rack draws three and the drum seven whatever the count.
//
// BOTH LIVE: Weapon.AmmoType1 "RocketAmmo" and WM_Gun.ShotClass "RSB_Rocket" --
// RS_Ballistics' subclass of the engine's Rocket (rsb/projectiles.zs). Speed, damage, blast,
// flags and states are the Rocket's, untouched; RS_Ballistics adds only what each machine
// draws: a lit smoke trail, and a fireball, embers, a smoke column and a scorch ring where it
// bursts. No RNG, nothing keyed to the console player.
// ============================================================================

class WM_RocketLauncher : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "rocket_launcher";
		Weapon.SelectionOrder 2500;
		Weapon.SlotNumber 8;
		Inventory.PickupMessage "Rocket Launcher";
		Tag "Rocket Launcher";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "RocketAmmo";
		WM_Gun.ShotClass "RSB_Rocket";
		WM_Gun.FullAuto true;   // vanilla refires while held (A_ReFire) -- VANILLA_PARITY F1
		WM_Gun.FireTics 20;
	}
}

class WM_RPG : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "rocket_rpg";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9700;
		Weapon.SlotNumber 8;
		Inventory.PickupMessage "RPG";
		Tag "RPG";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "RocketAmmo";
		WM_Gun.ShotClass "RSB_RocketRPG";
		WM_Gun.FullAuto true;   // vanilla refires while held (A_ReFire) -- VANILLA_PARITY F1
		WM_Gun.FireTics 20;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropRocketLauncher : WM_Prop {}
class WM_PropRPG : WM_Prop {}
