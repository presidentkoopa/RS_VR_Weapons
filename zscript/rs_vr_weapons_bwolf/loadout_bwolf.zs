// ==========================================================================
// WW2 -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_WW2.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces. Load the
// Vanilla base, then this, and the class screen grows a row -- the same way Vanilla+ and Modern do.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a fatal,
// global load error, so nothing shared is duplicated here.
// ==========================================================================
class WM_PlayerBWolf : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 2;
		WM_Player.StartGuns "BW_1911", "BW_Luger";
		Player.DisplayName "BWolf";

		Player.StartItem "BW_1911";
		Player.StartItem "BW_Luger";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "BW_Knife";
		Player.StartItem "BW_Axe";
		Player.StartItem "BW_Shotgun";
		Player.StartItem "BW_MP40";
		Player.StartItem "BW_Tommy";
		Player.StartItem "BW_PPSh";
		Player.StartItem "BW_Kar98";
		Player.StartItem "BW_Garand";
		Player.StartItem "BW_STG44";
		Player.StartItem "BW_BAR";
		Player.StartItem "BW_MG42";
		Player.StartItem "BW_Chaingun";
		Player.StartItem "BW_Flamethrower";
		Player.StartItem "BW_Grenade";
		Player.StartItem "BW_P38";
		Player.StartItem "BW_Nebelwerfer";

		Player.WeaponSlot 1, "BW_Knife", "BW_Axe";
		Player.WeaponSlot 2, "BW_1911", "BW_Luger", "BW_P38";
		Player.WeaponSlot 3, "BW_Shotgun";
		Player.WeaponSlot 4, "BW_MP40", "BW_Tommy", "BW_PPSh";
		Player.WeaponSlot 5, "BW_Kar98", "BW_Garand", "BW_STG44", "BW_BAR";
		Player.WeaponSlot 6, "BW_MG42", "BW_Chaingun";
		Player.WeaponSlot 7, "BW_Flamethrower";
		Player.WeaponSlot 8, "BW_Nebelwerfer";
		Player.WeaponSlot 9, "BW_Grenade";
	}
}
