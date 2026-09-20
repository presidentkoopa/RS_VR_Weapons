// ============================================================================
// THE HACX SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
//
// IT DETECTS HACX AND REPLACES HACX'S OWN GUNS (the owner, 2026-09-20: "if a weaponset is loaded
// with a gameplay mod it supports, then it becomes the 3D weaponset for that mod").
//
// THIS USED TO SAY "no parent mod" AND THAT WAS NOT A DESIGN DECISION -- it was nobody having gone
// and read HACX.WAD. The class names are not ours to guess, so the marker stayed empty and the set
// only ever replaced Doom's pickups. The names below are READ OUT OF HACX.WAD's own DECORATE lump,
// not invented: HacxPistol, HacxUzi, HacxTazer, HacxCryogun, HacxReznator, HacxPhotonZooka,
// HacxNuker and HacxAntigun, each inheriting from the Doom weapon it replaces.
//
// HacxAntigun IS DELIBERATELY NOT SWAPPED: we have no gun carded for it, and a swap naming a class
// that does not exist spawns NOTHING -- worse than leaving the mod's own weapon on the floor.
//
// WITHOUT THIS THE SET WOULD ONLY EXIST AT SPAWN. A player class hands out its guns at the
// start of a level; a map's pickups are what keeps you armed after that.
//
// MAPPED BY ROLE, not by name, because that is what a player reaching for the thing on the
// floor expects it to be.
// ============================================================================

class HacX_Bridge : WM_SetBridge
{
	// HACX.WAD's own pistol class. Present only when HacX itself is loaded, which is exactly the
	// question `parentLoaded` asks.
	override String Marker() { return "HacxPistol"; }

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- HACX'S OWN WEAPON CLASSES, one for one ------------------------------------
			Swap("HacxPistol",      "HX_Pistol");
			Swap("HacxUzi",         "HX_Uzi");
			Swap("HacxTazer",       "HX_Tazer");
			Swap("HacxCryogun",     "HX_Cryogun");
			Swap("HacxReznator",    "HX_Reznator");
			Swap("HacxPhotonZooka", "HX_Zooka");
			Swap("HacxNuker",       "HX_Nuker");

			// ITS AMMO NEEDS NO SWAP: HacX's guns inherit Doom's own weapon classes and draw on
			// Clip, Shell and Cell unchanged, and so do ours.
		}

		// ---- AND DOOM'S OWN, BY ROLE, whether or not HacX is loaded ------------------------
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
