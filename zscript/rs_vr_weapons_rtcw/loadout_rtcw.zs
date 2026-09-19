// ==========================================================================
// RTCW -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_RTCW.pk3, and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces. Load the
// Vanilla base, then this, and the class screen grows a row -- the same way Vanilla+ and WW2 do.
//
// It derives from WM_Player, which is the base pack's: a class defined in two archives is a fatal,
// global load error, so nothing shared is duplicated here.
//
// WEAPONSET 3. Vanilla is 0, Vanilla+ 1, WW2 2.
//
// STARTS ON THE LUGER AND THE COLT, the same pairing the WW2 set starts on, because they are the
// same two guns -- eleven of this set's seventeen are also in WW2 and carry identical numbers.
// What separates the sets is the models and the five this one adds, not the balance.
// ==========================================================================
class WM_PlayerRTCW : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 3;
		WM_Player.StartGuns "RT_Colt", "RT_Luger";
		Player.DisplayName "RTCW";

		Player.StartItem "RT_Colt";
		Player.StartItem "RT_Luger";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "RT_TT33";
		Player.StartItem "RT_HDM";
		Player.StartItem "RT_MP40";
		Player.StartItem "RT_Sten";
		Player.StartItem "RT_MP34";
		Player.StartItem "RT_Thompson";
		Player.StartItem "RT_PPSh";
		Player.StartItem "RT_StG44";
		Player.StartItem "RT_FG42";
		Player.StartItem "RT_G43";
		Player.StartItem "RT_BAR";
		Player.StartItem "RT_Mauser";
		Player.StartItem "RT_Mosin";
		Player.StartItem "RT_MG42";
		Player.StartItem "RT_Browning";

		// NO SLOT 3 AND NO SLOT 7: this set has no shotgun and no flamethrower. RealRTCW's own
		// shotgun is the Ithaca, which has numbers in RTCW_NUMBERS.md but no Model Card yet, and
		// the Venom is the same. Both are the set's next two guns rather than gaps in it.
		Player.WeaponSlot 2, "RT_Colt", "RT_Luger", "RT_TT33", "RT_HDM";
		Player.WeaponSlot 4, "RT_MP40", "RT_Sten", "RT_MP34", "RT_Thompson", "RT_PPSh";
		Player.WeaponSlot 5, "RT_StG44", "RT_FG42", "RT_G43", "RT_BAR", "RT_Mauser", "RT_Mosin";
		Player.WeaponSlot 6, "RT_MG42", "RT_Browning";
	}
}
