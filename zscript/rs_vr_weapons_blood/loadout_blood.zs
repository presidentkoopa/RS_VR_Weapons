// ==========================================================================
// BLOOD -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_Blood.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces. Load
// the Vanilla base, then this, and the class screen grows a row.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a
// fatal, global load error, so nothing shared is duplicated here.
//
// WEAPONSET 8. Vanilla is 0, Vanilla+ 1, BWolf 2, Cola 5, HacX 6, Robocop 7.
//
// STARTS ON BL_Pitchfork AND BL_FlareGun.
// ==========================================================================
class WM_PlayerBlood : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 8;
		WM_Player.StartGuns "BL_Pitchfork", "BL_FlareGun";
		Player.DisplayName "Blood";

		Player.StartItem "BL_Pitchfork";
		Player.StartItem "BL_FlareGun";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "BL_Shotgun";
		Player.StartItem "BL_TommyGun";
		Player.StartItem "BL_Napalm";
		Player.StartItem "BL_TeslaGun";
		Player.StartItem "BL_LifeLeech";
		Player.StartItem "BL_SprayCan";
		Player.StartItem "BL_Sigil";
		Player.StartItem "BL_Dynamite";
		Player.StartItem "BL_Voodoo";
	}
}
