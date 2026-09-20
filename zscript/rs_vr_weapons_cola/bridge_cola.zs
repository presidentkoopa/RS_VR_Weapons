// ============================================================================
// THE COLA 3 SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
//
// NO PARENT MOD, for the same reason the Aliens set has none: this is our take on Cola 3's
// arsenal, not a stand-in for Cola 3's own weapon classes.
//
// WITHOUT THIS THE SET WOULD ONLY EXIST AT SPAWN. A player class hands out its guns at the start
// of a level; a map's pickups are what keeps you armed after that.
//
// MAPPED BY ROLE. This set is the one with two shotguns and two energy weapons, so it fills more
// of Doom's table than most: the KS-23 is the shotgun, the Jackhammer the super shotgun, and the
// two plasma weapons take the plasma rifle and the BFG.
// ============================================================================

class Cola_Bridge : WM_SetBridge
{
	override String Marker() { return ""; }   // no parent mod: always the Doom table
	override String SetClass() { return "WM_PlayerCola"; }   // only when this set is the one being played

	override void Configure()
	{
		// ---- Doom's weapons, by role --------------------------------------------------------
		Swap("Pistol",         "CL_Revolver");
		Swap("Shotgun",        "CL_KS23");
		Swap("SuperShotgun",   "CL_Jackhammer");
		Swap("Chaingun",       "CL_Sidewinder");
		Swap("PlasmaRifle",    "CL_ParticleGun");
		Swap("BFG9000",        "CL_PlasmaGun");
		Swap("Chainsaw",       "CL_FryPan");

		// NO ROCKETLAUNCHER SWAP. Nothing in this set is a launcher -- the Sidewinder is a rifle
		// with a missile's name -- and standing something in for it would take a weapon away
		// rather than replace it.
	}
}
