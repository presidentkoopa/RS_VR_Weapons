// ============================================================================
// THE ROBOCOP SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
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

class Robocop_Bridge : WM_SetBridge
{
	override String Marker() { return ""; }   // no parent mod: always the Doom table

	override void Configure()
	{
		Swap("Pistol",          "RC_Auto9");
		Swap("Shotgun",         "RC_Shotgun");
		Swap("SuperShotgun",    "RC_KSG");
		Swap("Chaingun",        "RC_Chaingun");
		Swap("RocketLauncher",  "RC_M32");
		Swap("BFG9000",         "RC_Cobra");
		Swap("Chainsaw",        "RC_Chainsaw");

		// NO PLASMARIFLE SWAP. Nothing in this set is an energy weapon -- it is a set of
		// firearms and one cannon -- so Doom's stays on the floor rather than being replaced by a rifle.
	}
}
