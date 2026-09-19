// ==========================================================================
// HACX -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_HacX.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces. Load
// the Vanilla base, then this, and the class screen grows a row.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a
// fatal, global load error, so nothing shared is duplicated here.
//
// WEAPONSET 6. Vanilla is 0, Vanilla+ 1, BWolf 2, WW2 3, Aliens 4, Cola 5.
//
// STARTS ON HX_Pistol AND HX_Melee.
// ==========================================================================
class WM_PlayerHacX : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 6;
		WM_Player.StartGuns "HX_Pistol", "HX_Melee";
		Player.DisplayName "HacX";

		Player.StartItem "HX_Pistol";
		Player.StartItem "HX_Melee";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "HX_Uzi";
		Player.StartItem "HX_Tazer";
		Player.StartItem "HX_Cryogun";
		Player.StartItem "HX_Reznator";
		Player.StartItem "HX_Zooka";
		Player.StartItem "HX_Nuker";
		Player.StartItem "HX_Stick";
	}
}
