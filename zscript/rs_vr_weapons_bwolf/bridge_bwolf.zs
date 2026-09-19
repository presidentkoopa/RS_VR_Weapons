// ============================================================================
// WW2's BRIDGE -- these guns ARE Brutal Wolfenstein's guns when Brutal Wolfenstein is loaded, and a
// WW2 weapon set when it is not.
//
// The owner, 2026-09-19. See WM_SetBridge in the base pack for how and why; this file is only the
// three things a set fills in.
//
// WRITTEN AGAINST BRUTAL WOLFENSTEIN II v0.2.5, NOT 5.0. Everything moved between those versions --
// the base class every weapon derives from, every weapon's class name, every ammo class, and the
// names of the pickups its maps actually place. A 5.0-era table does not half-work against BWII, it
// does nothing at all, because not one string in it matches. This was rewritten rather than patched.
//
// THE MARKER is BWGun, the class every BWII weapon derives from (5.0's was DefaultBWgun, which no
// longer exists). Looked up by name at runtime, so this package has no reference to a pk3 that may
// not be there.
//
// WITH BRUTAL WOLFENSTEIN LOADED, its own pickups hand out these guns. Its maps placed them, its
// levels are balanced around where they sit, and a WW2 model set that ignored that would be fighting
// the mod it is meant to be part of. The class names below are ITS classes, named as plain strings
// and never referenced.
//
// WITHOUT IT, Doom's weapons become the set instead, so it plays in Doom, Doom 2, TNT, Plutonia or a
// nazi levelset with no map made for it. The mapping is by ROLE rather than by name -- Doom's shotgun
// is the set's shotgun, its chaingun is the set's belt gun -- because that is what a player reaching
// for the thing on the floor expects it to be.
//
// The pistol is deliberately the LUGER on the Doom side: it is the sidearm a WW2 set should start you
// on, and the M1911 is then something you find rather than something you are given.
//
// WE SWAP ONLY THE GUNS WE ACTUALLY HAVE. BWII's roster is thirty-three; sixteen of them are carded.
// A swap naming a class we have not built yet would spawn nothing at all, which is worse than leaving
// its own weapon on the floor, so the rest are listed at the bottom as the work rather than swapped.
// ============================================================================

class BWolf_Bridge : WM_SetBridge
{
	override String Marker() { return "BWGun"; }

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- ITS WEAPON CLASSES, one for one -------------------------------------------
			Swap("MP40",              "BW_MP40");
			Swap("BWSTG44",           "BW_STG44");
			Swap("BWThompson",        "BW_Tommy");
			Swap("BWKar98",           "BW_Kar98");
			Swap("BWKar98Classic",    "BW_Kar98");      // same rifle, different sprites
			Swap("BWGarand",          "BW_Garand");
			Swap("LugerP08",          "BW_Luger");
			Swap("Colt1911",          "BW_1911");
			Swap("BWPapasha",         "BW_PPSh");
			Swap("BWBAR",             "BW_BAR");
			Swap("BWMG42",            "BW_MG42");
			Swap("BWTGUN",            "BW_Shotgun");
			Swap("BWGatling",         "BW_Chaingun");
			Swap("BWKnifeAndMelee",   "BW_Knife");
			Swap("BWAxe2",            "BW_Axe");
			Swap("BWFM",              "BW_Flamethrower");

			// ---- AND THE PICKUPS ITS MAPS ACTUALLY PLACE -----------------------------------
			//
			// THE THING ON THE FLOOR IS NOT THE WEAPON CLASS. BWII places a separate `*Spawner`
			// pickup for nearly every gun, and those are what its maps and its nazis put in front
			// of you. Swapping only the weapon classes above would leave almost every gun in the
			// game still being its own -- which is exactly how the 5.0 table failed.
			Swap("MP40Spawner",       "BW_MP40");
			Swap("STG44Spawner",      "BW_STG44");
			Swap("HellAwaitsSTG44Spawner", "BW_STG44");
			Swap("ThompsonSpawner",   "BW_Tommy");
			Swap("K98Spawner",        "BW_Kar98");
			Swap("K98CSpawner",       "BW_Kar98");
			Swap("GarandSpawner",     "BW_Garand");
			Swap("LugerP08Spawner",   "BW_Luger");
			Swap("1911Spawner",       "BW_1911");
			Swap("PPSH41Spawner",     "BW_PPSh");
			Swap("BARSpawner",        "BW_BAR");
			Swap("MG42Spawner",       "BW_MG42");
			Swap("TGUNSpawner",       "BW_Shotgun");
			Swap("GatlingSpawner",    "BW_Chaingun");
			Swap("FlammenSpawner",    "BW_Flamethrower");
			Swap("BWAxeSpawner",      "BW_Axe");
			Swap("BWGrenadeSpawner",  "BW_Grenade");
			Swap("BWGrenade3Spawner", "BW_Grenade");

			// ---- AND ITS AMMO, or none of the above is worth picking up ---------------------
			//
			// Its maps place ITS ammo and its nazis drop it. Our guns feed from Doom's pools, so
			// without this every magazine and every shell in a BWII level is inert -- the guns
			// would be its guns and the ammo would feed nothing.
			//
			// Matched by SIZE rather than by name: a magazine becomes a clip, a box becomes a box.
			// The amounts are not identical, and that is accepted, because a map's PACING is set by
			// how often ammo appears rather than by the exact count, and no swap preserves both.
			Swap("9mmMag",            "Clip");       // MP40, Luger, P38
			Swap("Drop9mmMag",        "Clip");
			Swap("ThompsonMag",       "Clip");       // Thompson and the 1911 share it
			Swap("PPSHReserve",       "Clip");
			Swap("STG44Reserve",      "Clip");       // StG and FG42 share it
			Swap("MauserClip",        "Clip");       // Kar98
			Swap("3006Reserve",       "Clip");       // Garand and BAR share it
			Swap("MG42Reserve",       "Clip");
			Swap("MG42ReserveDrop",   "Clip");
			Swap("MG42ReserveWad",    "ClipBox");    // the belt, not a magazine
			Swap("G43Reserve",        "Clip");
			Swap("RevolverReserve",   "Clip");
			Swap("CUMReserve",        "Clip");
			Swap("GoldMag",           "Clip");
			Swap("EnBlocSpawner",     "Clip");       // the Garand's en-bloc, placed as a pickup
			Swap("BWShells",          "Shell");
			Swap("BWShells2",         "ShellBox");

			// THE FLAMETHROWER AND THE ENERGY GUNS DRAW ON CELL, which is what our Flammenwerfer
			// feeds from. BWII replaces Doom's Cell with its own pickup, so without these two the
			// flamethrower would have no fuel anywhere in the game.
			Swap("FlammenReserve",    "Cell");
			Swap("FlammenDrop",       "Cell");
			Swap("EnergyReserve",     "Cell");

			// NOT SWAPPED, DELIBERATELY:
			//   Its grenade and axe ammo (BWGrenadeAmmo, BWThreeNades, BWAxeAmmo). Our grenade and
			//   axe declare no ammo type at all, so there is nothing for a count to feed. Mapping
			//   them onto Clip would hand out rifle rounds for picking up a grenade.
			//   Its backpack (AmmoSuply) is a BackpackItem and works on its own.
			//   The seventeen guns we have not carded -- the AA12, Auto5, FG42, G43, Golden Luger,
			//   Blue MP40, Marksman Rifle, M30, Revolver, Walther P38, Tesla, both Leichenfausts,
			//   Panzerfaust, Panzerschreck, Nebelwerfer and Spear of Destiny -- along with their
			//   spawners and their ammo. Those stay BWII's own until the set has them.
			return;
		}

		// ---- Doom's weapons, by role --------------------------------------------------------
		Swap("Pistol",         "BW_Luger");
		Swap("Shotgun",        "BW_Shotgun");
		Swap("SuperShotgun",   "BW_Shotgun");
		Swap("Chaingun",       "BW_MG42");
		Swap("RocketLauncher", "BW_BAR");
		Swap("PlasmaRifle",    "BW_STG44");
		Swap("BFG9000",        "BW_MG42");
		Swap("Chainsaw",       "BW_Axe");

		// ---- DOOM'S AMMO NEEDS NO SWAP, EXCEPT THE DEAD ONE ---------------------------------
		//
		// Every WW2 gun already draws on Clip, Shell or Cell, so Doom's own clips, shells and
		// cells feed the set as they are -- including the ones a former human drops, which is why
		// drops need nothing special here either.
		//
		// ROCKETS ARE THE EXCEPTION. Nothing in this set fires one, so a rocket box in a Doom map
		// would be a pickup you walk over forever. It becomes rifle ammo, which is the nearest
		// thing to "a big pickup that matters" the set has.
		Swap("RocketAmmo", "Clip");
		Swap("RocketBox",  "ClipBox");
	}
}
