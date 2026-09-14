// ============================================================================
// THE SUPER SHOTGUN -- a break-action double for the main hand.
//
// The reload system's `breakaction` archetype (RS_VR_Reload/WMCARD.txt): the other
// hand takes the barrels from below and pulls them down (or the drop-mag button opens
// them); tipped past its side or over, the open gun drops its hulls (or the button
// throws them); one shell at a time from the pouch into the breech; push the barrels
// up, or flick the gun up, to shut. How it is worked is its card in this package's WMCARD.txt, under this
// class name; the measurements are in SSG_CANDIDATES.md.
//
// ------------------------------------------------------------------ THE SHOT
//
// Doom's own A_FireShotgun2 (UZDXREMA weaponssg.zs): twenty pellets, each 5 x
// random(1, 3), sideways Random2 x 11.25 / 256 and up Random2 x 7.097 / 256 -- the
// same triangular spread WM_Gun.ScatterShot draws. Split per barrel, because a
// pull here fires every LOADED barrel at once (WM_Gun.ChambersPerPull 2): ten
// pellets a barrel, so both loaded is vanilla's twenty and one loaded is ten. No
// ShotDamage, so each pellet deals its round profile's own 5 x 1d3 (RS_Ballistics'
// RSB_Bullet, RSBDEFS `buckshot`). Neither loaded clicks.
//
// FIRETICS 20, NOT VANILLA'S 57. Vanilla's 57 tics is its reload animation -- the
// break, two shells, the close -- played on every shot. Here the reload is your own
// hands and takes longer than that anyway, so the wait after a shot is only the
// kick: 20 tics (0.57 s), about the pistol's 19, so a pull straight after a reload
// is never swallowed and a click on an empty gun comes back at the cadence every
// other gun has.
//
// SLOT 3 with the pumps, carried but not put in hand at spawn: the wheel, the
// number keys, or the SSG page's "SSG into the main hand" (netevent wm_givessg,
// loadout.zs).
// ============================================================================

class WM_SSG : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "buckshot";
		WM_Gun.FlashProfile "shotgun_double";
		WM_Gun.EjectaProfile "hull_12ga";
		Weapon.AmmoType1 "Shell";
		// Above the M37A2's 1300, so the SSG never preempts it as the main hand's
		// shotgun; below the revolvers' 1400.
		Weapon.SelectionOrder 1350;
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "Super shotgun";
		Tag "Super Shotgun";
		WM_Gun.ShotPellets 10;
		WM_Gun.ShotSpread 11.25, 7.097;
		WM_Gun.ChambersPerPull 2;
		WM_Gun.FireTics 20;
	}
}

// WHAT IT IS DRAWN AS. The card's `prop`; MODELDEF binds the mesh and the hand.
class WM_PropSSG : WM_Prop {}

// ============================================================================
// THE DOUBLE BARREL -- the second break-action double, for the off hand, so every Doom gun has two.
//
// Force Unleashed's super shotgun (Ermac's Rusted Legacy, MIT) as doublebarrel_wm.md3, on the same
// `breakaction` archetype: its card is WM_DoubleBarrel in WMCARD.txt, its measurements in
// SSG_CANDIDATES.md ("Double Barrel").
//
// THE SHOT is the SSG's -- vanilla Doom's A_FireShotgun2 split per barrel (above): ten pellets a
// loaded barrel, the same spread, both loaded barrels on one pull, FireTics 20.
//
// SLOT 3 with the pumps and the SSG, carried but not put in hand at spawn; the Double Barrel page's
// "into the off hand" row (netevent wm_givedoublebarrel, loadout.zs).
// ============================================================================

class WM_DoubleBarrel : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "buckshot";
		WM_Gun.FlashProfile "shotgun_double";
		WM_Gun.EjectaProfile "hull_12ga";
		+WEAPON.OFFHANDWEAPON
		Weapon.AmmoType1 "Shell";
		Weapon.SelectionOrder 9350;
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "Double barrel";
		Tag "Double Barrel";
		WM_Gun.ShotPellets 10;
		WM_Gun.ShotSpread 11.25, 7.097;
		WM_Gun.ChambersPerPull 2;
		WM_Gun.FireTics 20;
	}
}

class WM_PropDoubleBarrel : WM_Prop {}
