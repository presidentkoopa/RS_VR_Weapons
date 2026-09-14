// ============================================================================
// TWO PUMP SHOTGUNS, ONE FOR EACH HAND.
//
// The same shape as this package's two test pistols (pistols.zs): a weapon
// class is a name, an ammo type, a hand and its shot, and nothing about how the
// gun is worked. Its parts, stores, verbs and every mesh number are on its card,
// in this package's WMCARD.txt, under the class name.
//
//   MAIN HAND  WM_PumpM37   the M37A2 (Aliens: Eradication's Ithaca 37)
//   OFF HAND   WM_PumpDoom  the classic Doom shotgun (VanAlek's mesh)
//
// TWO DIFFERENT GUNS ON PURPOSE. A fault that runs one hand's gun from the
// other hand's card cannot hide when the two cards disagree on every number.
//
// ------------------------------------------------------- THE PISTOLS COME UP FIRST
//
// Both hands start on the pistols, as they always have.
// The engine raises the LOWEST selection order a hand has (player.zs
// BestWeapon, which skips off-hand weapons for the main hand and the reverse):
//
//   main hand  WM_M4A3 100  <  WM_PumpM37 1300  <  RS_WorldFist 3700
//   off hand   RS_WorldFistOff 3701  <  WM_Pistolet 9000  <  WM_PumpDoom 9100
//
// so a shotgun is never raised ahead of its hand's pistol. The reload system's
// spawn window (system.zs Equip) then puts each carded gun over a FIST, in card
// order -- and the pistols' cards come first in this package's WMCARD.txt -- so
// each hand ends up on its pistol, never on a shotgun.
//
// ------------------------------------------------------------------ THE SHOT
//
// Doom's own: A_FireShotgun is A_FireBullets(5.6, 0, 7, 5) -- seven pellets, 5.6
// degrees either side, level, each 5 x 1d3. So ShotPellets 7 and ShotSpread
// 5.6, 0, fired by WM_Gun.WM_TryFire; no ShotDamage, so each pellet deals its round
// profile's own 5 x 1d3 (RS_Ballistics' RSB_Bullet, RSBDEFS `buckshot`; the cards' old
// `damage = 5, 15` was never applied).
// ============================================================================

class WM_PumpM37 : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "buckshot";
		WM_Gun.FlashProfile "shotgun";
		WM_Gun.EjectaProfile "hull_12ga";
		Weapon.AmmoType1 "Shell";
		Weapon.SelectionOrder 1300;
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "M37A2 pump shotgun";
		Tag "M37A2";
		WM_Gun.ShotPellets 7;
		WM_Gun.ShotSpread 5.6, 0;
	}
}

// +OFFHANDWEAPON is the whole difference, as it is for the Pistolet.
class WM_PumpDoom : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "buckshot";
		WM_Gun.FlashProfile "shotgun";
		WM_Gun.EjectaProfile "hull_12ga";
		+WEAPON.OFFHANDWEAPON
		Weapon.AmmoType1 "Shell";
		Weapon.SelectionOrder 9100;
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "Pump shotgun";
		Tag "Doom shotgun";
		WM_Gun.ShotPellets 7;
		WM_Gun.ShotSpread 5.6, 0;
	}
}

// WHAT EACH IS DRAWN AS. The card's `prop` names one of these; MODELDEF binds
// the mesh and the hand to it (FollowMainHand / FollowOffHand), which is the
// only reason there are two.
class WM_PropPumpM37  : WM_Prop {}
class WM_PropPumpDoom : WM_Prop {}
