// ==========================================================================
// COLA 3 -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_Cola.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a fatal,
// global load error, so nothing shared is duplicated here.
//
// WEAPONSET 5. Vanilla is 0, Vanilla+ 1, BWolf 2, WW2 3, Aliens 4.
//
// STARTS ON THE REVOLVER, which Vanilla+ already hands out as WM_ColaRevolver. This is the same
// mesh under the set's own name.
// ==========================================================================
class WM_PlayerCola : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 5;
		WM_Player.StartGuns "CL_Revolver", "CL_FryPan";
		Player.DisplayName "Cola 3";

		Player.StartItem "CL_Revolver";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "CL_FryPan";
		Player.StartItem "CL_KS23";
		Player.StartItem "CL_Jackhammer";
		Player.StartItem "CL_Sidewinder";
		Player.StartItem "CL_PlasmaGun";
		Player.StartItem "CL_ParticleGun";
		Player.StartItem "CL_CardDeck";
	}
}
