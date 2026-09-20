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
// ITS LOOK is RS_Ballistics' rail: flash "rail", the Quake 2-style trail "rail" and the rail hits.
//
// AND IT KICKS. This used to say "rails take no recoil aim offset, so its sheet names no recoil
// profile" -- the first half is still true and the second did not follow from it. A rail aims and
// scatters itself, so the SHOT is not turned by the kick; the GUN still climbs. Those are two jobs
// and they were run together, so `recoil rail` -- a 2.20 climb, written for this gun, the hardest
// single shove in the package -- sat in RSBDEFS unused and the railgun delivered nothing.
//
// Measured on its cousin: CL_ParticleGun logged climb 0.0000 across twelve shots against a stated
// 0.55. The fire path now calls RecoilStep for a rail and suppresses only its effect on that round
// (RS_VR_Reload weapon.zs), which is the half that was missing -- and this line is the other half,
// because a gun that names no profile has nothing to accumulate.
// ============================================================================

class WM_Railgun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "rail";
		WM_Gun.RecoilProfile "rail";
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
