// ==========================================================================
// BLOOM -- THE CROSSOVER. Doom's arsenal and Caleb's, in the same hands.
//
// THIS SET CARDS NOTHING AND SHIPS NO MESHES, and that is the whole design. Bloom is not a set of
// guns -- it is a LOADOUT. Every weapon it hands out already exists: the WM_* come from the base
// pack and the BL_* from RS_VR_Weapons_Blood.pk3, both of which it requires. It adds a row to the
// New Game screen and nothing else.
//
// I READ THE MOD RATHER THAN GUESS ITS ARSENAL. BloomFINALVERSION.pk3, Actors/Blood_Weapons.txt:
// TeslaRifle is slot 8, LifeLeech slot 9, Dynamite slot 6, VoodooDoll slot 0 -- the SAME SLOTS
// Doom's own weapons occupy. That is not a clash, it is the crossover's design: two weapons per
// slot, and you cycle within it. Building this as a new set of guns would have meant carding
// eleven meshes that are already carded and rebuilding Doom's, which the owner's standing rule
// forbids anyway: the Vanilla cards are headset-tested and are never regenerated.
//
// WHAT BLOOM HAS THAT WE DO NOT: a Colt and a single-barrel shotgun. Neither is carded and neither
// is invented here -- an arsenal with two guns missing is honest; two guns faked from neighbours
// is not. They are one ask to the card lane whenever the owner wants them.
//
// WHAT WE HAVE THAT BLOOM DOES NOT: the Sigil. It is handed out anyway. This is our take on the
// crossover rather than a reproduction of it, the same way Vanilla+ is our take on Doom's.
//
// WEAPONSET 9. Vanilla 0, Vanilla+ 1, BWolf 2, WW2 3, Aliens 4, Cola 5, HacX 6, Robocop 7,
// Blood 8.
// ==========================================================================
class WM_PlayerBloom : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 9;
		// THE PITCHFORK AND THE FLARE GUN, which is how Blood opens. Caleb climbs out of the
		// ground with a pitchfork; the flare gun is the first thing he finds.
		WM_Player.StartGuns "BM_FlareGun", "BM_Pitchfork";
		Player.DisplayName "Bloom";

		Player.StartItem "BM_FlareGun";
		Player.StartItem "BM_Pitchfork";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";

		// ---- CALEB'S -------------------------------------------------------------------
		Player.StartItem "BM_Shotgun";
		Player.StartItem "BM_TommyGun";
		Player.StartItem "BM_Napalm";
		Player.StartItem "BM_TeslaGun";
		Player.StartItem "BM_LifeLeech";
		Player.StartItem "BM_SprayCan";
		Player.StartItem "BM_Dynamite";
		Player.StartItem "BM_Voodoo";

		// ---- DOOM'S, SHARING THE SAME SLOTS ---------------------------------------------
		//
		// These are the BASE PACK'S classes, not copies. A class defined in two archives is a
		// fatal, global load error, so this names them and defines nothing.
		Player.StartItem "WM_Chainsaw";
		Player.StartItem "WM_M4A3";
		Player.StartItem "WM_PumpDoom";
		Player.StartItem "WM_SSG";
		Player.StartItem "WM_Chaingun";
		Player.StartItem "WM_RocketLauncher";
		Player.StartItem "WM_PlasmaRifle";
		Player.StartItem "WM_BFG";

		// Both arsenals eat from the same four pools, so the counts are Doom's own doubled at
		// the low end -- you are carrying twice the guns.
		Player.StartItem "Clip", 200;
		Player.StartItem "Shell", 50;
		Player.StartItem "Cell", 300;
		Player.StartItem "RocketAmmo", 20;
	}
}
