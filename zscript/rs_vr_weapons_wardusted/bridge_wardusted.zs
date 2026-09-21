// ============================================================================
// THE WARDUSTED SET'S BRIDGE -- Wardust's Rogue Rebel's guns become ours when that mod is loaded, and
// Doom's pickups become ours when it is not.
//
// THE OWNER, 2026-09-21: standalone packs "that i can use with the mods or not", and the lightsaber
// "swapping out any lightsaber they might call for themselves". And his standing rule: never patch the
// parent mod -- every name below is READ OUT OF THE MOD (its Actors/Weapons and Actors/MapSpawner) and
// only ever named here as a string.
//
// WARDUSTED PLACES ITS ITEMS THROUGH RANDOM SPAWNERS that replace Doom's (ShotgunReplace rolls
// E22Blaster, ClipReplace rolls 15EnergyUnits...). A spawner rolls first and we only ever see the leaf
// it rolled, so it is the LEAVES that are swapped -- every weapon and every ammo pickup the spawners
// and the mod's own maps can produce.
//
// ITS AMMO BECOMES DOOM'S, by what it feeds. Our guns draw on Doom's four ammo types (WMSHEET.wardusted),
// so a mod ammo pickup left alone would be ammo nothing here can use.
// ============================================================================

class Wardusted_Bridge : WM_SetBridge
{
	override String Marker() { return "DL44Blaster"; }
	override String SetClass() { return "WM_PlayerWardusted"; }

	// THE SABER ONLY IF ITS PACK IS LOADED. A swap to a class that does not exist would turn the mod's
	// saber pickup into nothing at all, which is worse than leaving it the mod's own.
	private void SaberSwap(String from)
	{
		if (Object.FindClass("RS_Lightsaber", "Actor")) Swap(from, "RS_Lightsaber");
	}

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- ITS WEAPONS, one for one -------------------------------------------------------
			Swap("DL44Blaster",           "WD_DL44");
			Swap("DarkBlaster",           "WD_DarkBlaster");
			Swap("E11Blaster",            "WD_E11");
			Swap("E22Blaster",            "WD_E22");
			Swap("Z6RotaryBlaster",       "WD_Z6");
			Swap("DLT19",                 "WD_DLT19");
			Swap("Bowcaster",             "WD_Bowcaster");
			Swap("ConcussionRifle",       "WD_Concussion");
			Swap("DisruptorRifle",        "WD_Disruptor");
			Swap("SniperRifle",           "WD_Sniper");
			Swap("DarkAssaultCannon",     "WD_AssaultCannon");
			Swap("RebelThermalDetonator", "WD_Thermal");
			Swap("ProximityMines",        "WD_Mines");
			SaberSwap("Lightsaber");

			// ---- ITS AMMO, by what it feeds ------------------------------------------------------
			// EnergyUnits feed its blaster pistols and the E-11 -> our Clip.
			Swap("EnergyUnits",          "Clip");
			Swap("15EnergyUnits",        "Clip");
			Swap("60EnergyUnits",        "ClipBox");
			// DLTCells and AutoGunCells feed the repeaters (DLT-19, Z-6) -> Clip.
			Swap("DLTCells",             "Clip");
			Swap("150DLTCells",          "ClipBox");
			Swap("AutoGunCells",         "Clip");
			Swap("150AutoGunCells",      "ClipBox");
			// PowerCells feed the E-22 and MortarShells the bowcaster -> our Shell.
			Swap("PowerCells",           "Shell");
			Swap("10PowerCells",         "Shell");
			Swap("30PowerCells",         "ShellBox");
			Swap("50PowerCells",         "ShellBox");
			Swap("MortarShells",         "Shell");
			Swap("1MortarShell",         "Shell");
			Swap("3MortarShells",        "Shell");
			Swap("5MortarShells",        "ShellBox");
			// PlasmaCartridges feed the concussion and assault guns -> Cell.
			Swap("PlasmaCartridges",     "Cell");
			Swap("20PlasmaCartridges",   "Cell");
			Swap("30PlasmaCartridges",   "CellPack");
			// Its missiles -> RocketAmmo, which our assault cannon draws on.
			Swap("AssaultCannonMissiles", "RocketAmmo");
			Swap("1Missile",             "RocketAmmo");
			Swap("5Missiles",            "RocketBox");
			// Its detonators and mines ARE the throwables here: a pickup of them is the weapon.
			Swap("1ThermalDetonator",    "WD_Thermal");
			Swap("3ThermalDetonators",   "WD_Thermal");
			Swap("1IMMine",              "WD_Mines");
			Swap("5IMMines",             "WD_Mines");
		}

		// ---- AND DOOM'S OWN, WITH OR WITHOUT THE MOD, the way the mod itself maps them ---------------
		// Its MapSpawner: Shotgun and SuperShotgun -> E22Blaster, Chaingun -> Z6RotaryBlaster,
		// RocketLauncher -> Bowcaster, PlasmaRifle -> ConcussionRifle, BFG9000 -> DarkAssaultCannon,
		// Chainsaw -> Lightsaber. The one departure: the SUPER shotgun is the E-11 here, so the rifle
		// the films are full of turns up on the floor too, rather than two E-22s.
		Swap("Pistol",         "WD_DL44");
		Swap("Shotgun",        "WD_E22");
		Swap("SuperShotgun",   "WD_E11");
		Swap("Chaingun",       "WD_Z6");
		Swap("RocketLauncher", "WD_Bowcaster");
		Swap("PlasmaRifle",    "WD_Concussion");
		Swap("BFG9000",        "WD_AssaultCannon");
		SaberSwap("Chainsaw");
	}
}
