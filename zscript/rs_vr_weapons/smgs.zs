// ============================================================================
// THE SMGS -- slot 6. The SMG in the main hand, the Tec9 in the off hand.
//
// RS_ModelSwapper's tec9.md3, as tec9_wm.md3: its four surfaces were all named
// "Cube", and its magazine was a separate piece inside the body, so the copy names
// them body, magazine, trigger and bolt. Measurements in SMG_CANDIDATES.md.
//
// THE SHOT is RS_Main's VR_SMG (RS_SMG.zs, RollStats), Uncommon -- the tier the
// revolvers and rifles already carry: 7-15 a round, Accuracy 59-69 at spreadScale
// 0.05, so (100 - 64) x 0.05 = 1.8, taken as 0.9 sideways and 0.3 up and down the
// way the revolvers and rifles were. Full auto at 1.3x vanilla's chaingun: 3 tics.
// ============================================================================

class WM_Tec9 : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "pistol_9mm";
		WM_Gun.FlashProfile "smg";
		WM_Gun.EjectaProfile "brass_9mm";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9400;
		Weapon.SlotNumber 6;
		Inventory.PickupMessage "Tec9";
		Tag "Tec9";
		WM_Gun.ShotDamage 7, 15;
		WM_Gun.ShotSpread 0.9, 0.3;
		// The owner: SMGs full auto, 1.3x vanilla's chaingun (4 tics a shot): 3.08,
		// so 3 in whole tics.
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 3;
	}
}

// WHAT IT IS DRAWN AS. The card's `prop`; MODELDEF binds the mesh and the hand.
class WM_PropTec9 : WM_Prop {}

// ============================================================================
// THE SMG -- main hand, slot 6, beside the Tec9.
//
// RS_ModelSwapper's SMG (models/hud/SMG, a KRISS Vector's shape) as smg_wm.md3:
// the source's rest frame 3 as its only frame, its surfaces named body,
// charginghandle, trigger and magazine. The charging handle folds out, then pulls
// back -- the card's dof and dof2. Measurements in SMG_CANDIDATES.md.
//
// THE SHOT is the Tec9's: RS_Main's VR_SMG at Uncommon (7-15, spread 0.9 / 0.3).
// FULL AUTO at the owner's 1.3x vanilla's chaingun: 4 / 1.3 = 3.08, so 3 tics, 11.7
// a second. The card's magazine holds 35.
// ============================================================================

class WM_SMG : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "pistol_45";
		WM_Gun.FlashProfile "smg";
		WM_Gun.EjectaProfile "brass_45";
		Weapon.SelectionOrder 1600;
		Weapon.SlotNumber 6;
		Inventory.PickupMessage "SMG";
		Tag "SMG";
		WM_Gun.ShotDamage 7, 15;
		WM_Gun.ShotSpread 0.9, 0.3;
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 3;
	}
}

class WM_PropSMG : WM_Prop {}
