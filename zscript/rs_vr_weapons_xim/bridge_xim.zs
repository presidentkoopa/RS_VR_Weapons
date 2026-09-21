// ============================================================================
// THE XIM SET'S BRIDGE -- Doom's weapon pickups become this set's guns.
//
// XIM'S STAR WARS DOOM IS A DEHACKED WAD: it re-dresses Doom's own classes and adds none. So there is
// no parent class to detect and nothing to tell "Xim loaded" from "plain Doom" -- and nothing needs to:
// its guns and Doom's are the same classes, so the one table serves both, with the mod or without it.
//
// THE CHAINSAW IS XIM'S LIGHTSABER (its SAWG frames are a blue saber), so it becomes ours --
// RS_Lightsaber.pk3's, by string, and only when that pack is loaded.
// ============================================================================

class Xim_Bridge : WM_SetBridge
{
	override String SetClass() { return "WM_PlayerXim"; }

	override void Configure()
	{
		Swap("Pistol",         "XM_Pistol");
		Swap("Shotgun",        "XM_Shotgun");
		Swap("SuperShotgun",   "XM_SuperShotgun");
		Swap("Chaingun",       "XM_Chaingun");
		Swap("RocketLauncher", "XM_RocketLauncher");
		Swap("PlasmaRifle",    "XM_PlasmaRifle");
		Swap("BFG9000",        "XM_Thermal");
		if (Object.FindClass("RS_Lightsaber", "Actor")) Swap("Chainsaw", "RS_Lightsaber");
	}
}
