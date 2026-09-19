// ============================================================================
// THE RIFLE -- a magazine-fed rifle for the main hand.
//
// RS_ModelSwapper's rifle mesh, ours as the Rifle (models/vanilla/rifles/Rifle/). Its
// magazine (surface Lipas), charging handle
// (liikkuvat, with the bolt carrier behind the port) and trigger are each their
// own surface, so today's grammar describes it as it is -- the charging handle
// is the action, the magazine the feed. A real card, not a stopgap. Its
// measurements are in RIFLE_CANDIDATES.md.
//
// THE SHOT is RS_Main's VR_Rifle (RS_Rifle.zs, RollStats), Uncommon tier -- the
// band the revolvers took: 14-24 a round, one round, Accuracy 82-92 at
// spreadScale 0.05, so tighter than the revolvers and the chaingun. FULL AUTO at
// the owner's 0.6x vanilla's chaingun: 4 / 0.6 = 6.67, so 7 tics, 5 a second.
//
// SLOT 5, carried but not in hand at spawn: the wheel, the number keys, or the
// rifle page's "Rifle into the main hand" (netevent wm_giverifle, loadout.zs).
// ============================================================================

class WM_Rifle : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "rifle_762";
		WM_Gun.FlashProfile "rifle";
		WM_Gun.EjectaProfile "brass_762";
		Weapon.SelectionOrder 1500;
		Weapon.SlotNumber 5;
		Inventory.PickupMessage "Rifle";
		Tag "Rifle";
		WM_Gun.ShotDamage 14, 24;
		// Tighter than the chaingun's 5.6 on refire, as the owner asked.
		WM_Gun.ShotSpread 0.3, 0.1;
		// The owner: rifles full auto, 0.6x vanilla's chaingun (4 tics a shot): 6.67,
		// so 7 in whole tics -- 5 a second.
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 7;
	}
}

// WHAT IT IS DRAWN AS. The card's `prop`; MODELDEF binds the mesh and the hand.
class WM_PropRifle : WM_Prop {}

// ============================================================================
// THE M16 -- off hand (the owner, 09-14: the Rifle's partner in Vanilla+), slot 5, beside the Rifle.
//
// RS_ModelSwapper's m16.md3, as m16_wm.md3: its charging handle is two small
// pieces of the body surface that move 5.60 back on every shot and at the rack,
// split into a surface of its own. Measurements in RIFLE_CANDIDATES.md.
//
// THE SHOT: the Rifle's, until the owner gives the M16 its own numbers.
// ============================================================================

class WM_M16 : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "rifle_556";
		WM_Gun.FlashProfile "rifle";
		WM_Gun.EjectaProfile "brass_556";
		// The off hand (the owner, 09-14: the Rifle's partner in Vanilla+), and an off-hand selection order the
		// engine never picks on its own.
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9550;
		Weapon.SlotNumber 5;
		Inventory.PickupMessage "M16";
		Tag "M16";
		WM_Gun.ShotDamage 14, 24;
		WM_Gun.ShotSpread 0.3, 0.1;
		// Full auto at the Rifle's 7 tics (0.6x the chaingun).
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 7;
	}
}

class WM_PropM16 : WM_Prop {}
