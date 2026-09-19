// ============================================================================
// THE ALIENS SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
//
// NO PARENT MOD. Aliens Eradication is a total conversion with its own weapon classes, but this
// set is not standing in for them the way BWolf stands in for Brutal Wolfenstein's -- the owner
// has not asked for that and the TC's class names are not ours to assume. So Marker() stays
// empty, WM_SetBridge reads that as "no parent", and the Doom table is the only table.
//
// WITHOUT THIS THE SET WOULD ONLY EXIST AT SPAWN. A player class hands out its guns at the start
// of a level; a map's pickups are what keeps you armed after that.
//
// MAPPED BY ROLE, not by name, because that is what a player reaching for the thing on the floor
// expects it to be.
//
// SEVERAL SETS LOADED AT ONCE ALL WANT DOOM'S PICKUPS, and whichever handler resolves first takes
// them -- the others stand down, because the base class refuses to touch a replacement already
// made final. That is one set's guns on the floor rather than a mixture, which is the better
// outcome, but WHICH set wins is handler registration order and not a choice anyone made.
// ============================================================================

class Aliens_Bridge : WM_SetBridge
{
	override String Marker() { return ""; }   // no parent mod: always the Doom table

	override void Configure()
	{
		// ---- Doom's weapons, by role --------------------------------------------------------
		Swap("Pistol",         "AE_M4A3");
		Swap("Shotgun",        "AE_M37A2");
		Swap("Chaingun",       "AE_PulseRifle");
		Swap("PlasmaRifle",    "AE_Smartgun");
		Swap("BFG9000",        "AE_Flamer");
		Swap("Chainsaw",       "AE_Knife");

		// NO SUPERSHOTGUN AND NO ROCKETLAUNCHER SWAP. This set has one shotgun and no launcher --
		// the satchel is thrown, not fired down a tube, and standing it in for the rocket
		// launcher would take a weapon away rather than replace it. Doom's own stay on the floor.
	}
}
