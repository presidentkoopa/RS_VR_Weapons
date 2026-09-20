// ============================================================================
// THE ROBOCOP SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
//
// IT DETECTS ROBOCOP AND REPLACES ROBOCOP'S OWN GUNS (the owner, 2026-09-20: "if a weaponset is
// loaded with a gameplay mod it supports, then it becomes the 3D weaponset for that mod").
//
// THIS USED TO SAY "no parent mod" AND THAT WAS NOT A DESIGN DECISION -- it was nobody having gone
// and read robocop.pk3. The class names are not ours to guess, so the marker stayed empty and the
// set only ever replaced Doom's pickups. The names below are READ OUT OF THE MOD ITSELF -- its
// DECORATE lives in a wad NESTED inside the pk3 (ROBOGUNS.wad), which is why a look at the pk3's
// own DECORATE finds nothing and why this went unwired: RoboPunch, Auto9, RoboShotgun,
// CobraAssaultCannon, Ed209Gun, MiniMissileShooter and M27PlasmaRifle.
//
// M27PlasmaRifle IS DELIBERATELY NOT SWAPPED: our RC_M27 is a 5.56 service rifle off its own
// sheet, and the mod's is an energy weapon. Same name, different gun -- swapping it would hand the
// player the wrong thing and quietly change what the mod is.
//
// WITHOUT THIS THE SET WOULD ONLY EXIST AT SPAWN. A player class hands out its guns at the
// start of a level; a map's pickups are what keeps you armed after that.
//
// MAPPED BY ROLE, not by name, because that is what a player reaching for the thing on the
// floor expects it to be.
// ============================================================================

class Robocop_Bridge : WM_SetBridge
{
	// The mod's own Auto 9 -- Murphy's sidearm, present only when Robocop itself is loaded, which
	// is exactly the question `parentLoaded` asks.
	override String Marker() { return "Auto9"; }
	override String SetClass() { return "WM_PlayerRobocop"; }   // only when this set is the one being played

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- ROBOCOP'S OWN WEAPON CLASSES, one for one ---------------------------------
			Swap("Auto9",              "RC_Auto9");
			Swap("RoboShotgun",        "RC_Shotgun");
			Swap("CobraAssaultCannon", "RC_Cobra");
			Swap("Ed209Gun",           "RC_Chaingun");
			Swap("MiniMissileShooter", "RC_M32");
			Swap("RoboPunch",          "RC_Chainsaw");   // its melee, and ours is the set's melee

			// ITS AMMO NEEDS NO SWAP: the mod's guns draw on Doom's own Clip, Shell, Cell and
			// RocketAmmo, and so does every gun on this set's sheet.
		}

		// ---- AND DOOM'S OWN, BY ROLE, whether or not Robocop is loaded ---------------------
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
