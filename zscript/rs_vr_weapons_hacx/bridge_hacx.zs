// ============================================================================
// THE HACX SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
//
// NO PARENT MOD. This is our take on that arsenal, not a stand-in for the original mod's own
// weapon classes, so Marker() stays empty and the Doom table is the only table.
//
// WITHOUT THIS THE SET WOULD ONLY EXIST AT SPAWN. A player class hands out its guns at the
// start of a level; a map's pickups are what keeps you armed after that.
//
// MAPPED BY ROLE, not by name, because that is what a player reaching for the thing on the
// floor expects it to be.
// ============================================================================

class HacX_Bridge : WM_SetBridge
{
	override String Marker() { return ""; }   // no parent mod: always the Doom table

	override void Configure()
	{
		Swap("Pistol",          "HX_Pistol");
		Swap("Chaingun",        "HX_Uzi");
		Swap("PlasmaRifle",     "HX_Reznator");
		Swap("BFG9000",         "HX_Nuker");
		Swap("RocketLauncher",  "HX_Zooka");
		Swap("Chainsaw",        "HX_Melee");

		// NO SHOTGUN SWAP. HacX has no shotgun -- its close-range answer is the Uzi -- and
		// replacing Doom's with a rifle would take a weapon away rather than stand in for one.
	}
}
