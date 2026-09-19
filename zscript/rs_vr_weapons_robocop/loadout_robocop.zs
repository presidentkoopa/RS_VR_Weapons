// ==========================================================================
// ROBOCOP -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_Robocop.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces. Load
// the Vanilla base, then this, and the class screen grows a row.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a
// fatal, global load error, so nothing shared is duplicated here.
//
// WEAPONSET 7. Vanilla is 0, Vanilla+ 1, BWolf 2, Aliens 4, Cola 5, HacX 6.
//
// STARTS ON RC_Auto9 AND RC_Chainsaw.
// ==========================================================================
class WM_PlayerRobocop : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 7;
		WM_Player.StartGuns "RC_Auto9", "RC_Chainsaw";
		Player.DisplayName "Robocop";

		Player.StartItem "RC_Auto9";
		Player.StartItem "RC_Chainsaw";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "RC_M27";
		Player.StartItem "RC_KSG";
		Player.StartItem "RC_Shotgun";
		Player.StartItem "RC_M32";
		Player.StartItem "RC_Cobra";
		Player.StartItem "RC_Chaingun";
	}
}
