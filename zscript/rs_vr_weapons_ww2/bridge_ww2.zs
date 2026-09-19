// ============================================================================
// RTCW's BRIDGE -- Doom's weapon pickups become this set's guns.
//
// UNLIKE THE WW2 SET, THIS ONE HAS NO PARENT MOD. WW2 exists to stand in for Brutal Wolfenstein's
// guns when Brutal Wolfenstein is loaded; this set is bound to nobody. RealRTCW is a different
// engine's game, not a Doom mod, so there is no load order in which its pickups could appear and
// nothing to detect.
//
// So Marker() stays empty, WM_SetBridge reads that as "no parent", and the Doom table is the only
// table. Everything else -- the runtime replacement, the final-answer rule that stops a parent
// mod's chain, the exact-name matching -- is the base class's and is shared with WW2.
//
// WITHOUT THIS THE SET WOULD ONLY EXIST AT SPAWN. A player class hands out its guns at the start
// of a level; a map's pickups are what keeps you armed after that. With no bridge, every shotgun
// and chaingun on the floor of every Doom map would still be Doom's.
//
// MAPPED BY ROLE, not by name, because that is what a player reaching for the thing on the floor
// expects it to be.
//
// TWO SETS LOADED AT ONCE BOTH WANT DOOM'S PICKUPS. If WW2 and RTCW are both in the load order
// they both replace Doom's Pistol, and whichever handler resolves first takes it -- the other
// stands down, because the base class refuses to touch a replacement already made final. That is
// one set's guns on the floor rather than a mixture, which is the better of the two outcomes, but
// WHICH set wins is handler registration order and not a choice anyone made. Worth knowing before
// the owner loads two sets and wonders why the floor is all WW2.
// ============================================================================

class WW2_Bridge : WM_SetBridge
{
	override String Marker() { return ""; }   // no parent mod: always the Doom table

	override void Configure()
	{
		// ---- Doom's weapons, by role --------------------------------------------------------
		//
		// THE PISTOL IS THE LUGER, matching the WW2 set's choice: it is the sidearm the set starts
		// you on, and the Colt is then something you find rather than something you are given.
		Swap("Pistol",         "WW2_Luger");
		Swap("Chaingun",       "WW2_MG42");
		Swap("PlasmaRifle",    "WW2_StG44");
		Swap("BFG9000",        "WW2_Browning");

		// NO SHOTGUN AND NO SUPERSHOTGUN SWAP. This set has no shotgun -- RealRTCW's is the
		// Ithaca and it is not carded yet. Leaving Doom's shotgun alone means a Doom map still
		// arms you, which is far better than replacing it with a rifle and quietly removing the
		// only close-range answer in the game. It goes in the moment the Ithaca lands.
		//
		// THE ROCKET LAUNCHER IS THE BAR rather than anything explosive, for the same reason the
		// WW2 set does it: nothing here fires a rocket, and the BAR is the biggest thing it has.
		Swap("RocketLauncher", "WW2_BAR");
		Swap("Chainsaw",       "WW2_Mosin");   // no melee in the set; the bolt rifle is the prize

		// ---- DOOM'S AMMO NEEDS NO SWAP, EXCEPT THE DEAD ONE ---------------------------------
		//
		// Every gun here draws on Clip, so Doom's own clips and boxes feed the set as they are --
		// including the ones a former human drops, which is why drops need nothing special.
		//
		// ROCKETS ARE THE EXCEPTION. Nothing in this set fires one, so a rocket box in a Doom map
		// would be a pickup you walk over forever.
		Swap("RocketAmmo", "Clip");
		Swap("RocketBox",  "ClipBox");

		// Shells are deliberately left alone: Doom's shotgun is still Doom's here, so its ammo
		// still has a gun to feed.
	}
}
