// ==========================================================================
// ALIENS -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_Aliens.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces. Load the
// Vanilla base, then this, and the class screen grows a row -- the same way every other set does.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a fatal,
// global load error, so nothing shared is duplicated here.
//
// WEAPONSET 4. Vanilla is 0, Vanilla+ 1, BWolf 2, WW2 3.
//
// STARTS ON THE M4A3, which is the Colonial Marines' sidearm and also, as it happens, the base
// pack's own pistol -- the mesh came from this set originally.
// ==========================================================================
class WM_PlayerAliens : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 4;
		WM_Player.StartGuns "AE_M4A3", "AE_Knife";
		Player.DisplayName "Aliens";

		Player.StartItem "AE_M4A3";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "AE_Knife";
		Player.StartItem "AE_M37A2";
		Player.StartItem "AE_PulseRifle";
		Player.StartItem "AE_Smartgun";
		Player.StartItem "AE_Flamer";
		Player.StartItem "AE_PowerLoader";
		Player.StartItem "AE_Satchel";
	}
}
