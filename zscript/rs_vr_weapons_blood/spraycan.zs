// ============================================================================
// THE SPRAY CAN -- a can of propellant that is only a flamethrower when something lights it.
//
// The owner: "i want our blood vr weapons to have the can by itself, firing inert gas. the lighter
// has to be in the offhand, lit, and in front of the can while it is discharging."
//
// SO IT IS TWO WEAPONS OUT OF ONE NOZZLE and the gun decides which, every tic. That is why this is
// a handwritten class rather than a sheet key: a key states ONE name, and the whole character of
// this weapon is that the name DEPENDS. The condition is code and the two profile names are data;
// a key would have forced the condition into data, where it cannot be expressed.
//
//     bl_spray_inert   the can alone. Propellant. No fire, no light, no heat, no scorch -- and no
//                      sound of its own, because the sheet's firesound IS the hiss and a loop from
//                      the flame system would double it.
//     bl_spray_lit     while a lit lighter is held in front of the nozzle. Shorter and thinner
//                      than a Flammenwerfer, with unburnt mist at the edges of the stream, which
//                      is what makes an improvised flamethrower look improvised.
//
// WHAT THIS CLASS CAN HONESTLY TEST TODAY is whether BL_Lighter is the weapon in the player's OTHER
// hand. That is most of the gesture and it is the half that is actually a decision -- you have to
// choose to be holding it.
//
// WHAT IT CANNOT TEST IS "IN FRONT OF THE NOZZLE", and I am not faking it. Nothing in the card
// system, the sheet or this class knows where one weapon is relative to another; that is the hands
// lane's, and it is now load-bearing rather than a flourish, because without it the can is only
// ever an inert jet. THE HOOK IS ONE FUNCTION, LitInFront(), so when that capability lands it is a
// one-line change here and nothing else in the package moves.
// ============================================================================

class BL_SprayCan : WM_FlameGun
{
	Default
	{
		WM_Gun.FlashProfile "none";      // the flame owns the light, when there is one
		Weapon.SelectionOrder 9781;
		Weapon.SlotNumber 7;
		Weapon.AmmoType1 "Cell";
		Inventory.PickupMessage "Spray Can";
		Tag "Spray Can";
	}

	// ---- IT IS A TWO-HAND WEAPON, SO IT BRINGS THE SECOND HAND -----------------------------
	//
	// The can is the jet and BL_Lighter is the igniter, and they are separate weapons in separate
	// hands. So a player who obtains the can and not the lighter is holding an object that CAN
	// NEVER BE LIT -- an aerosol that sprays inert gas forever, with no way in the game to find out
	// why.
	//
	// AND ZBLOOD IS EXACTLY THAT CASE. Its arsenal has ONE Spraycan and no separate igniter, so
	// every route into the can from the parent mod -- its pickups, its maps, its own starting
	// arsenal -- hands over half a weapon. Nothing in the bridge can fix that by swapping, because
	// there is no second class of theirs to swap.
	//
	// SO THE CAN GIVES THE LIGHTER, HERE, RATHER THAN EVERY CALLER REMEMBERING TO. A pickup, a
	// StartItem, a bridge swap, a cheat and a co-op respawn all arrive through AttachToOwner, and
	// this is the only place all five meet. A loadout line would have covered exactly one of them,
	// which is how the can came to be inert in ZBlood in the first place.
	//
	// IDEMPOTENT ON PURPOSE: a second can must not hand out a second lighter, and a player who
	// already carries one keeps the one they have.
	override void AttachToOwner(Actor other)
	{
		Super.AttachToOwner(other);
		let pmo = PlayerPawn(other);
		if (pmo && !pmo.FindInventory("BL_Lighter"))
			pmo.GiveInventory("BL_Lighter", 1);
	}

	// Is the lit lighter held in front of this nozzle?
	//
	// TODAY: is BL_Lighter the weapon in the other hand. A weapon a player has selected into a hand
	// is a deliberate act, which is the part of the owner's sentence that is a CHOICE rather than a
	// posture.
	//
	// STILL MISSING, DELIBERATELY UNFAKED: lit, and in front. A lighter has no lit state yet -- it
	// is a thrown weapon with a flame nobody has struck -- and no lane owns "where is that hand
	// relative to this muzzle". Returning true for merely holding it would make the can a
	// flamethrower whenever the lighter is out, which is not what was asked for and is the kind of
	// nearly-right that is worse than plainly unfinished.
	virtual bool LitInFront() const
	{
		let pmo = PlayerPawn(Owner);
		if (!pmo || !pmo.player) return false;
		// The hand this gun is NOT in.
		Weapon other = bOffhandWeapon ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
		if (!other || other.GetClassName() != 'BL_Lighter') return false;
		// The two tests the owner asked for that nothing can answer yet. When the hands lane can
		// say where the off hand is, they land here and nowhere else.
		return false;
	}

	override String FlameProfile()
	{
		return LitInFront() ? "bl_spray_lit" : "bl_spray_inert";
	}
}
