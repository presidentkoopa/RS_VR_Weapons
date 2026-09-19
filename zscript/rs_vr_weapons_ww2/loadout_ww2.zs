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
class WM_PlayerWW2 : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 2;
		WM_Player.StartGuns "WW2_1911", "WW2_Luger";
		Player.DisplayName "WW2";

		Player.StartItem "WW2_1911";
		Player.StartItem "WW2_Luger";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "WW2_Knife";
		Player.StartItem "WW2_Axe";
		Player.StartItem "WW2_Shotgun";
		Player.StartItem "WW2_MP40";
		Player.StartItem "WW2_Tommy";
		Player.StartItem "WW2_PPSh";
		Player.StartItem "WW2_Kar98";
		Player.StartItem "WW2_Garand";
		Player.StartItem "WW2_STG44";
		Player.StartItem "WW2_BAR";
		Player.StartItem "WW2_MG42";
		Player.StartItem "WW2_Chaingun";
		Player.StartItem "WW2_Flamethrower";
		Player.StartItem "WW2_Grenade";
		Player.StartItem "WW2_P38";
		Player.StartItem "WW2_Nebelwerfer";

		Player.WeaponSlot 1, "WW2_Knife", "WW2_Axe";
		Player.WeaponSlot 2, "WW2_1911", "WW2_Luger", "WW2_P38";
		Player.WeaponSlot 3, "WW2_Shotgun";
		Player.WeaponSlot 4, "WW2_MP40", "WW2_Tommy", "WW2_PPSh";
		Player.WeaponSlot 5, "WW2_Kar98", "WW2_Garand", "WW2_STG44", "WW2_BAR";
		Player.WeaponSlot 6, "WW2_MG42", "WW2_Chaingun";
		Player.WeaponSlot 7, "WW2_Flamethrower";
		Player.WeaponSlot 8, "WW2_Nebelwerfer";
		Player.WeaponSlot 9, "WW2_Grenade";
	}
}
