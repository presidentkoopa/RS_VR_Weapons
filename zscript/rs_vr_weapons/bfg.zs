// ============================================================================
// THE BFGS -- slot 0. The BFG in the main hand, the heavy BFG in the off hand. Both fired
// straight from a cell battery, both held in two hands.
//
// BFG: Force Unleashed's BFG 9000 and its pod, merged into bfg_wm.md3 (body, cover, meter,
// trigger, cell). A top cover on a pin at its front lifts 69 degrees; the cell under it
// slides back, then lifts out.
// HEAVY BFG: RS_ModelSwapper's BFG mesh as bfgheavy_wm.md3 (body, trigger). THIS MESH HAS
// NO CELL in any version, so its card's cell is hidden and every cell number is an
// ESTIMATE. Measurements in _pending/BFG_CARDS.md.
//
// THE SHOT is vanilla's BFG: 30 tics of charge, then a BFGBall (its own 100 x 1d8 and
// the spray), 40 cells a shot. The battery holds 160 -- four shots, the lead's pick (the
// owner: "i've no idea"). FireTics 30: vanilla's B 10 A_FireBFG + B 20 A_ReFire after the
// shot.
//
// BOTH LIVE: Weapon.AmmoType1 "Cell", RoundsPerShot 40, ChargeTics 30 + ChargeSound, and
// WM_Gun.ShotClass "RSB_BFGBall" -- RS_Ballistics' subclass of the engine's BFGBall
// (rsb/projectiles.zs). Speed, damage, the spray, flags and states are the BFGBall's,
// untouched; RS_Ballistics adds only what each machine draws: a green trail, and a splash,
// motes, a ring and a light where it bursts. No RNG, nothing keyed to the console player.
// ============================================================================

class WM_BFG : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "bfg";
		Weapon.SelectionOrder 2800;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "BFG";
		Tag "BFG";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.RoundsPerShot 40;
		WM_Gun.ShotClass "RSB_BFGBall";
		WM_Gun.ChargeTics 30;
		WM_Gun.ChargeSound "wm/bfg/charge";
		WM_Gun.FireTics 30;
	}
}

class WM_BFGHeavy : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "bfg";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9800;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "Heavy BFG";
		Tag "Heavy BFG";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.RoundsPerShot 40;
		WM_Gun.ShotClass "RSB_BFGBall";
		WM_Gun.ChargeTics 30;
		WM_Gun.ChargeSound "wm/bfg/charge";
		WM_Gun.FireTics 30;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropBFG : WM_Prop {}
class WM_PropBFGHeavy : WM_Prop {}
