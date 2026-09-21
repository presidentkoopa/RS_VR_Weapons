// ==========================================================================
// WARDUSTED -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_Wardusted.pk3 and reaches the New Game screen through that pack's
// MAPINFO AddPlayerClasses (additive, gi.cpp:370). It derives from the base pack's WM_Player.
//
// WEAPONSET 10. Vanilla 0, Vanilla+ 1, BWolf 2, WW2 3, Aliens 4, Cola 5, HacX 6, Robocop 7, Blood 8,
// Bloom 9, Wardusted 10, Xim 11.
//
// THE SLOTS FOLLOW WHAT DOOM'S PICKUPS BECOME (bridge_wardusted.zs), so a shotgun on the floor is a
// slot-3 gun whatever the map (the owner, 2026-09-20: "pickup a 'shotgun / slot3' weapon, i get a
// 'slot3' weapon from whatever weaponset i am using"). And Wardusted's own choices decide which gun
// that is -- its MapSpawner turns Doom's shotgun into the E-22, its chaingun into the Z-6.
//
// THE LIGHTSABER IS RS_Lightsaber.pk3's, NAMED BY STRING. A start item or slot entry whose class is
// not loaded is silently absent (thingdef_properties.cpp resolves slot names against what loaded), so
// this set loads with or without the saber and simply has one when it is there. One in each hand --
// the owner: "have two of these".
// ==========================================================================
class WM_PlayerWardusted : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 10;
		WM_Player.StartGuns "WD_DL44", "WD_DarkBlaster";
		Player.DisplayName "Wardusted";

		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "RS_Lightsaber";
		Player.StartItem "RS_LightsaberOff";
		Player.StartItem "WD_DL44";
		Player.StartItem "WD_DarkBlaster";
		Player.StartItem "WD_E22";
		Player.StartItem "WD_E11";
		Player.StartItem "WD_Z6";
		Player.StartItem "WD_DLT19";
		Player.StartItem "WD_Bowcaster";
		Player.StartItem "WD_Concussion";
		Player.StartItem "WD_Disruptor";
		Player.StartItem "WD_Sniper";
		Player.StartItem "WD_AssaultCannon";
		Player.StartItem "WD_Thermal";
		Player.StartItem "WD_Mines";
		Player.StartItem "Clip", 100;

		Player.WeaponSlot 1, "RS_WorldFist", "RS_WorldFistOff", "RS_Lightsaber", "RS_LightsaberOff";
		Player.WeaponSlot 2, "WD_DL44", "WD_DarkBlaster";
		Player.WeaponSlot 3, "WD_E22", "WD_E11";
		Player.WeaponSlot 4, "WD_Z6", "WD_DLT19";
		Player.WeaponSlot 5, "WD_Bowcaster";
		Player.WeaponSlot 6, "WD_Concussion", "WD_Disruptor", "WD_Sniper";
		Player.WeaponSlot 7, "WD_AssaultCannon";
		Player.WeaponSlot 8, "WD_Thermal", "WD_Mines";
	}
}
