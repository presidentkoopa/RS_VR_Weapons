// ============================================================================
// TWO TEST PISTOLS, ONE FOR EACH HAND.
//
// Moved here from the reload system (its weapon.zs) on 2026-09-12: the reload
// system holds reload profiles and machinery, and every gun is a weapon
// package's. Same shape as the shotguns: a weapon class is a name, an ammo type
// and a hand. Its parts, stores and every mesh number are on its card, in this
// package's WMCARD.txt, under the class name.
//
//   MAIN HAND  WM_M4A3      the M4A3 (a 1911)
//   OFF HAND   WM_Pistolet  RS_Main's 9mm
//
// THE SHOT: neither class sets WM_Gun.ShotPellets, ShotSpread or ShotDamage, so
// each fires WM_Gun's default -- one round, dead on, 5 x 1d3 -- the Doom pistol,
// exactly as before the move.
//
// Pickup message "Pistol", as WM_Gun's own default said before the move.
// ============================================================================

// THE MAIN-HAND GUN. Its card is in WMCARD under this class name.
class WM_M4A3 : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "pistol_45";
		WM_Gun.FlashProfile "pistol_45";   // its own: a rounder, oranger bloom, more smoke (RS_Ballistics d928582)
		WM_Gun.EjectaProfile "brass_45";
		Weapon.SelectionOrder 100;
		Weapon.SlotNumber 2;
		Inventory.PickupMessage "Pistol";
		Tag "Pistol";
	}
}

// THE OFF-HAND GUN. +OFFHANDWEAPON is the whole difference -- and a selection
// order the engine will never pick on its own, so it cannot be raised into the
// main hand at spawn and leave the off hand empty.
class WM_Pistolet : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "pistol_9mm";
		WM_Gun.FlashProfile "pistol_9mm";  // the showpiece: a sharp white snap, a turning star of tongues (RS_Ballistics d928582)
		WM_Gun.EjectaProfile "brass_9mm_pistolet";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9000;
		Weapon.SlotNumber 2;
		Inventory.PickupMessage "Handgun";
		// The owner, 09-14: "rename pistolet to 9mm Handgun". The class stays WM_Pistolet (card id).
		Tag "Handgun";
	}
}

// WHAT EACH IS DRAWN AS. The card's `prop` names one of these; this package's
// MODELDEF binds the mesh and the hand to it -- FollowMainHand on the M4A3,
// FollowOffHand on the Pistolet, which is the only reason there are two.
class WM_PropM4A3     : WM_Prop {}
class WM_PropPistolet : WM_Prop {}
