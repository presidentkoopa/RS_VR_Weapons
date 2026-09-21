// ==========================================================================
// XIM -- THE SET'S PLAYER CLASS.
//
// Ships ONLY in RS_VR_Weapons_Xim.pk3 and reaches the New Game screen through that pack's MAPINFO
// AddPlayerClasses. It derives from the base pack's WM_Player.
//
// WEAPONSET 11. Vanilla 0, Vanilla+ 1, BWolf 2, WW2 3, Aliens 4, Cola 5, HacX 6, Robocop 7, Blood 8,
// Bloom 9, Wardusted 10, Xim 11.
//
// XIM'S STAR WARS DOOM IS DEHACKED, so its guns ARE Doom's slots and this set keeps them: a blaster
// where the pistol was, a blaster rifle in slot 3, the bowcaster where the rocket launcher was, a
// thermal detonator where the BFG was, and a lightsaber where the chainsaw was. Its sounds are
// Wardust's Rogue Rebel's (the owner, 2026-09-21: "xim and wardusted weaponset with wardusted sounds").
//
// THE LIGHTSABER IS RS_Lightsaber.pk3's, NAMED BY STRING: absent from the slot and the start items
// when that pack is not loaded, one in each hand when it is.
// ==========================================================================
class WM_PlayerXim : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 11;
		WM_Player.StartGuns "XM_Pistol", "XM_Pistol";
		Player.DisplayName "Xim Star Wars";

		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "RS_Lightsaber";
		Player.StartItem "RS_LightsaberOff";
		Player.StartItem "XM_Pistol";
		Player.StartItem "XM_Shotgun";
		Player.StartItem "XM_SuperShotgun";
		Player.StartItem "XM_Chaingun";
		Player.StartItem "XM_RocketLauncher";
		Player.StartItem "XM_PlasmaRifle";
		Player.StartItem "XM_Thermal";
		Player.StartItem "Clip", 100;

		Player.WeaponSlot 1, "RS_WorldFist", "RS_WorldFistOff", "RS_Lightsaber", "RS_LightsaberOff";
		Player.WeaponSlot 2, "XM_Pistol";
		Player.WeaponSlot 3, "XM_Shotgun", "XM_SuperShotgun";
		Player.WeaponSlot 4, "XM_Chaingun";
		Player.WeaponSlot 5, "XM_RocketLauncher";
		Player.WeaponSlot 6, "XM_PlasmaRifle";
		Player.WeaponSlot 7, "XM_Thermal";
	}
}
