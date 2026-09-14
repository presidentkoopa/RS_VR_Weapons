// ============================================================================
// THE RAILGUN -- OFF hand, slot 9. A Vanilla+ gun (the owner, 09-14): off the Plasma Rifle pickup, whose second gun is
// the Blue Plasma Rifle; carried by the test arsenal.
//
// RS_ModelSwapper's railgun mesh (models/hud/RailGun) as railgun_wm.md3: surfaces
// body, scope, scopeglass, magazine and trigger. Its cell pack drops straight out of
// the receiver. Measurements in _pending/RAILGUN_CARDS.md. The only railgun: every
// other candidate was two flat planes or this same mesh moved.
//
// THE SHOT is RS_Main's RS_GH_Railgun (RollStats), Uncommon -- the tier the
// revolvers, rifles and SMGs carry: 464-688, dead on (spreadScale 0), 10 cells a
// shot from a 50-cell magazine, RateOfFire 2 a second, so FireTics 18 (35 / 2).
//
// ITS LOOK is RS_Ballistics' rail: flash "rail", the Quake 2-style trail "rail" and the rail hits. Rails take no
// recoil aim offset (RECOIL_PLAN), so its sheet names no recoil profile.
// ============================================================================

class WM_Railgun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "rail";
		// In the off hand (09-14).
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 2900;
		Weapon.SlotNumber 9;
		Inventory.PickupMessage "Railgun";
		Tag "Railgun";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotRail true;
		// RS_Ballistics' Quake 2-style trail (d7170fc) from the muzzle to the hit, in place of the engine's spiral.
		WM_Gun.TrailProfile "rail";
		WM_Gun.RoundsPerShot 10;
		WM_Gun.ShotDamage 464, 688;
		WM_Gun.FireTics 18;
	}
}

// WHAT IT IS DRAWN AS. The card's `prop`; MODELDEF binds the mesh and the hand.
class WM_PropRailgun : WM_Prop {}
