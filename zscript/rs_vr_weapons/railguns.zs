// ============================================================================
// THE RAILGUN -- main hand, slot 9.
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
// NOT CARRIED YET. Its card needs the reload system's firesfrom / casing / hands
// keys, so there is no StartItem, slot entry or "into the hand" row until they land.
// These lines wait too -- an unknown property is a fatal load error:
//   Weapon.AmmoType1 "Cell";
//   WM_Gun.ShotRail true;
//   WM_Gun.RoundsPerShot 10;
// ============================================================================

class WM_Railgun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "rail";
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
