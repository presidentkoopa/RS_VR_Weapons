// ============================================================================
// THE BLOOD SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
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

class Blood_Bridge : WM_SetBridge
{
// ZBLOODY HELL, AND NOT BLOOM. The two mods share most of their weapon class names -- Pitchfork,
	// FlareGun, TeslaRifle, LifeLeech, Dynamite, VoodooDoll, Spraycan and NapalmLauncher are in
	// both -- so a marker taken from the weapons would match either and the two sets would fight
	// over the same pickups. BloodChair is a piece of ZBloody Hell's scenery and is in neither
	// Bloom nor anything else.
	override String Marker() { return "BloodChair"; }
	override String SetClass() { return "WM_PlayerBlood"; }   // only when this set is the one being played

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- ZBLOODY HELL'S OWN WEAPON CLASSES, one for one --------------------------
			//
			// Its arsenal is ours exactly: this set was carded off these very meshes, so every
			// one of its twelve has a counterpart and none is standing in for anything.
			Swap("Pitchfork",         "BL_Pitchfork");
			Swap("FlareGun",          "BL_FlareGun");
			Swap("Sawedoff",          "BL_Shotgun");
			Swap("Tommygun",          "BL_TommyGun");
			Swap("NapalmLauncher",    "BL_Napalm");
			Swap("TeslaRifle",        "BL_TeslaGun");
			Swap("LifeLeech",         "BL_LifeLeech");
			// ZBLOOD HAS ONE SPRAYCAN AND WE HAVE TWO OBJECTS. Ours is the can in one hand and
			// BL_Lighter in the other, and their arsenal has no igniter to swap for the second.
			// The can hands out its own lighter on pickup (BL_SprayCan.AttachToOwner), so this
			// stays a one-for-one swap and the parent mod never has to know there are two.
			Swap("Spraycan",          "BL_SprayCan");
			Swap("VoodooDoll",        "BL_Voodoo");
			Swap("Dynamite",          "BL_Dynamite");
			// THE OTHER TWO BUNDLES ARE A DETONATOR AND A TRIGGER rather than different sticks:
			// RemoteDynamite and ProximityDynamite both become the same dynamite until somebody
			// builds what makes them different.
			Swap("RemoteDynamite",    "BL_Dynamite");
			Swap("ProximityDynamite", "BL_Dynamite");
		}

		Swap("Pistol",          "BL_FlareGun");
		Swap("Shotgun",         "BL_Shotgun");
		Swap("Chaingun",        "BL_TommyGun");
		Swap("RocketLauncher",  "BL_Napalm");
		Swap("PlasmaRifle",     "BL_TeslaGun");
		Swap("BFG9000",         "BL_Sigil");
		Swap("Chainsaw",        "BL_Pitchfork");

		// NO SUPERSHOTGUN SWAP. The sawn-off IS the double barrel and it already stands in
		// for Doom's shotgun; giving it both slots would be the same gun twice on one floor.
	}
}
