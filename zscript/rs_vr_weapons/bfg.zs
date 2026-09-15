// ============================================================================
// THE BFGS -- slot 0. The BFG in the main hand, the heavy BFG in the off hand. Both fired
// straight from a cell battery, both held in two hands.
//
// BFG: RS_Main's RS_GH_BFG9000 (the owner, 09-15) -- the heavy BFG's own mesh, re-origined, so it
// draws bfgheavy_wm.md3 in the main hand, with no cover and no meter. Until 09-15 it was Force
// Unleashed's BFG 9000 (_pending/_unused/bfg/BFG).
// HEAVY BFG: RS_ModelSwapper's BFG mesh as bfgheavy_wm.md3 (body, trigger). THIS MESH HAS
// NO CELL in any version, so its card's cell is hidden and every cell number is an
// ESTIMATE. Measurements in _pending/BFG_CARDS.md.
//
// THE SHOT is vanilla's BFG: 30 tics of charge, then a BFGBall (its own 100 x 1d8 and
// the spray), 40 cells a shot. The battery holds 160 -- four shots, the lead's pick (the
// owner: "i've no idea"). On vanilla's clock (RS_VR_Reload VANILLA_PARITY.md F2): held, it goes
// again every 40 tics -- 30 charge + B 10 A_FireBFG, then A_ReFire goes straight round; let go and
// vanilla's B 20 plays out, 60 (FullAuto, FireTics 10, ReleaseTics 20).
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
		WM_Gun.FlashProfile "bfg_9000";
		Weapon.SelectionOrder 2800;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "BFG 9000";
		Tag "BFG 9000";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.RoundsPerShot 40;
		WM_Gun.ShotClass "RSB_BFGBall";
		WM_Gun.ChargeTics 30;
		WM_Gun.ChargeSound "weapons/bfgf";   // vanilla dsbfg (the owner, 09-14); RS_Main's wm/bfg/charge stays in the sound menu
		// VANILLA'S CLOCK (VANILLA_PARITY F2): held, A_ReFire at t=40 goes straight round, so 30 charge +
		// 10 = 40 a shot; let go and the B 20 plays out, 60.
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 10;
		WM_Gun.ReleaseTics 20;
	}
}

class WM_BFGHeavy : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "bfg_heavy";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9800;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "BFG 10000";
		Tag "BFG 10000";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.RoundsPerShot 40;
		WM_Gun.ShotClass "RSB_BFGBallHeavy";
		WM_Gun.ChargeTics 30;
		WM_Gun.ChargeSound "weapons/bfgf";   // vanilla dsbfg (the owner, 09-14); RS_Main's wm/bfg/charge stays in the sound menu
		// VANILLA'S CLOCK (VANILLA_PARITY F2): held, A_ReFire at t=40 goes straight round, so 30 charge +
		// 10 = 40 a shot; let go and the B 20 plays out, 60.
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 10;
		WM_Gun.ReleaseTics 20;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropBFG : WM_Prop {}
class WM_PropBFGHeavy : WM_Prop {}
