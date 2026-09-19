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
class WM_PlayerWW2 : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 3;
		WM_Player.StartGuns "WW2_Colt", "WW2_Luger";
		Player.DisplayName "WW2";

		Player.StartItem "WW2_Colt";
		Player.StartItem "WW2_Luger";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 100;
		Player.StartItem "WW2_TT33";
		Player.StartItem "WW2_HDM";
		Player.StartItem "WW2_MP40";
		Player.StartItem "WW2_Sten";
		Player.StartItem "WW2_MP34";
		Player.StartItem "WW2_Thompson";
		Player.StartItem "WW2_PPSh";
		Player.StartItem "WW2_StG44";
		Player.StartItem "WW2_FG42";
		Player.StartItem "WW2_G43";
		Player.StartItem "WW2_BAR";
		Player.StartItem "WW2_Mauser";
		Player.StartItem "WW2_Mosin";
		Player.StartItem "WW2_MG42";
		Player.StartItem "WW2_Browning";

		// ---- THE BWOLF ARSENAL, IN THE LEFT HAND ------------------------------------
		// The owner, 2026-09-19: pick BWolf and you play BWolf; pick THIS set and you play WW2
		// with BWolf's guns in your off hand. Two sets loaded together, neither one wasted.
		//
		// NAMED AS PLAIN START ITEMS ON PURPOSE, and this set still loads without the BWolf
		// pack: a StartItem naming a class that is not loaded is a WARNING at startup, never a
		// fatal -- which is exactly how RS_WorldFist is named above, and why no runtime lookup
		// is needed here. Load WW2 alone and these lines simply find nothing.
		//
		// The Thompson, Luger and Knife have no _Off twin because they are ALREADY off-hand
		// guns in the BWolf set, so they are named directly.
		Player.StartItem "BW_MP40_Off";
		Player.StartItem "BW_STG44_Off";
		Player.StartItem "BW_Kar98_Off";
		Player.StartItem "BW_Garand_Off";
		Player.StartItem "BW_1911_Off";
		Player.StartItem "BW_PPSh_Off";
		Player.StartItem "BW_BAR_Off";
		Player.StartItem "BW_MG42_Off";
		Player.StartItem "BW_Shotgun_Off";
		Player.StartItem "BW_Chaingun_Off";
		Player.StartItem "BW_Axe_Off";
		Player.StartItem "BW_Flamethrower_Off";
		Player.StartItem "BW_Grenade_Off";
		Player.StartItem "BW_P38_Off";
		Player.StartItem "BW_Nebelwerfer_Off";
		Player.StartItem "BW_Tommy";
		Player.StartItem "BW_Luger";
		Player.StartItem "BW_Knife";

		// NO SLOT 3 AND NO SLOT 7: this set has no shotgun and no flamethrower. RealRTCW's own
		// shotgun is the Ithaca, which has numbers in RTCW_NUMBERS.md but no Model Card yet, and
		// the Venom is the same. Both are the set's next two guns rather than gaps in it.
		Player.WeaponSlot 2, "WW2_Colt", "WW2_Luger", "WW2_TT33", "WW2_HDM";
		Player.WeaponSlot 4, "WW2_MP40", "WW2_Sten", "WW2_MP34", "WW2_Thompson", "WW2_PPSh";
		Player.WeaponSlot 5, "WW2_StG44", "WW2_FG42", "WW2_G43", "WW2_BAR", "WW2_Mauser", "WW2_Mosin";
		Player.WeaponSlot 6, "WW2_MG42", "WW2_Browning";
	}
}
