// ============================================================================
// BLOOM'S BRIDGE -- Bloom's own weapons become ours, and Doom's pickups stay shared.
//
// THIS ONE IS DIFFERENT FROM EVERY OTHER BRIDGE IN THE PACKAGE and deliberately so. The others
// replace Doom's whole table because their set stands IN PLACE OF Doom's arsenal. Bloom's stands
// BESIDE it -- the player carries both -- so replacing the lot would delete half the crossover off
// the floor.
//
// THE MARKER IS CHOSEN CAREFULLY AND IT IS NOT A WEAPON. Bloom and ZBloody Hell share most of their
// weapon class NAMES -- Pitchfork, FlareGun, TeslaRifle, LifeLeech, Dynamite, VoodooDoll, Spraycan
// and NapalmLauncher are declared by both -- so a marker taken from the weapons would match either
// mod, and this set and the Blood set would each claim the other's pickups. BlooMClass is Bloom's
// own player class and exists nowhere else.
// ============================================================================

class Bloom_Bridge : WM_SetBridge
{
	override String Marker() { return "BlooMClass"; }

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- BLOOM'S OWN WEAPON CLASSES, one for one ---------------------------------
			Swap("Pitchfork",      "BM_Pitchfork");
			Swap("Flaregun",       "BM_FlareGun");
			Swap("SawedOff",       "BM_Shotgun");
			Swap("TommyGun",       "BM_TommyGun");
			Swap("NapalmLauncher", "BM_Napalm");
			Swap("TeslaRifle",     "BM_TeslaGun");
			Swap("LifeLeech",      "BM_LifeLeech");
			Swap("Spraycan",       "BM_SprayCan");
			Swap("VoodooDoll",     "BM_Voodoo");
			Swap("Dynamite",       "BM_Dynamite");

			// NOT SWAPPED, BECAUSE WE DO NOT HAVE THEM: Colt and SingleShotgun. Bloom's own stay
			// on the floor rather than being replaced by something that is not them -- a swap
			// naming a class nobody built spawns nothing at all, which is worse than leaving the
			// mod's own weapon where it lies.
		}

		// ---- DOOM'S OWN PICKUPS, whether or not Bloom is loaded --------------------------
		//
		// Only the slots where Caleb's gun is the better find. A map that gives you a chaingun
		// gives you a Tommy gun, because a drum-fed .45 is what that pickup MEANS in his hands.
		Swap("Pistol",         "BM_FlareGun");
		Swap("Chaingun",       "BM_TommyGun");
		Swap("RocketLauncher", "BM_Napalm");
		Swap("PlasmaRifle",    "BM_TeslaGun");
		Swap("Chainsaw",       "BM_Pitchfork");

		// NO SHOTGUN, SUPERSHOTGUN OR BFG SWAP, AND THAT IS THE POINT. Doom's shotgun and SSG stay
		// on the floor beside the sawn-off, and the BFG stays beside whatever you are carrying,
		// because in a crossover you are meant to end up holding both arsenals. Swapping them
		// would quietly turn Bloom back into the Blood set with extra ammunition.
	}
}
