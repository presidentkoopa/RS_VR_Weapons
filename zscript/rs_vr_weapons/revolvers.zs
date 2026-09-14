// ============================================================================
// THREE TEST REVOLVERS -- Moonlight and Sunset (one mesh, two skins), and the
// Cola revolver as a second model to compare.
//
// THE REAL MECHANISMS. Moonlight and Sunset are break-tops (the reload system's
// `breaktop_revolver` archetype), the Cola a swing-out (`swingout_revolver`):
// open, throw the cases out, a speedloader in, shut, a chamber a pull, double
// action. How each is worked is its card in this package's WMCARD.txt; the
// measurements are in REVOLVER_CANDIDATES.md. Nothing here says anything about
// the mechanism -- a class is a name, a hand, an ammo type (Clip, WM_Gun's
// default: the speedloader is drawn from it) and its shot.
//
// SLOT 4, CARRIED BUT NOT IN HAND at spawn. Reach them by the wheel or the
// number keys, or put them straight in hand without typing: the revolver page's
// "Revolvers into both hands" (netevent wm_giverevolvers, loadout.zs).
// ============================================================================

// MAIN HAND. Its card is in WMCARD under this class name.
class WM_Moonlight : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "revolver_357";
		WM_Gun.FlashProfile "revolver";
		WM_Gun.EjectaProfile "brass_357";
		Weapon.SelectionOrder 1400;
		Weapon.SlotNumber 4;
		Inventory.PickupMessage "Revolver";
		Tag "Moonlight";
		// PULLED FROM RS_MAIN (RS_Revolver.zs, VR_Revolver.RollStats), Uncommon
		// tier: DamagePerShot 13-23, one pellet, Accuracy 71-81 / spreadScale
		// 0.05 -- fairly tight, not dead-on like the pistols. Fire cadence NOT
		// overridden: RS_Main's own RateOfFire is 2 shots/sec fixed by its fire
		// animation, and WM_Gun's own Fire state (10+4+5 tics) is already
		// 35/19 = 1.84/sec -- close enough that a custom States block isn't
		// worth the risk to the mustRelease/trigger-gate logic for a stopgap.
		WM_Gun.ShotDamage 13, 23;
		WM_Gun.ShotSpread 0.6, 0.2;
	}
}

// OFF HAND. Same mesh as Moonlight, the second skin (WPN-REV2.png), exactly
// how the pistols share m4a3.md3-shaped code across two meshes -- here it is
// one mesh, two skins, on two cards.
class WM_Sunset : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "revolver_357";
		WM_Gun.FlashProfile "revolver";
		WM_Gun.EjectaProfile "brass_357";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9200;
		Weapon.SlotNumber 4;
		Inventory.PickupMessage "Revolver";
		Tag "Sunset";
		WM_Gun.ShotDamage 13, 23;
		WM_Gun.ShotSpread 0.6, 0.2;
	}
}

// A SECOND MODEL TO COMPARE, off hand (the owner: "get the Cola one as well
// so we can try 2 diff models"). Higher SelectionOrder than Sunset so it
// never preempts it as the off-hand default.
class WM_ColaRevolver : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "revolver_357";
		WM_Gun.FlashProfile "revolver";
		WM_Gun.EjectaProfile "brass_357";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9300;
		Weapon.SlotNumber 4;
		Inventory.PickupMessage "Revolver";
		Tag "Cola Revolver";
		WM_Gun.ShotDamage 13, 23;
		WM_Gun.ShotSpread 0.6, 0.2;
	}
}

// WHAT EACH IS DRAWN AS. The card's `prop` names one of these; this package's
// MODELDEF binds the mesh and the hand to it.
class WM_PropMoonlight : WM_Prop {}
class WM_PropSunset     : WM_Prop {}
class WM_PropCola       : WM_Prop {}
