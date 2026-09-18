// ============================================================================
// VANILLA+ -- THE ADD-ON'S PLAYER CLASS.
//
// This file ships ONLY in RS_VR_Weapons_Plus.pk3. The base pk3 has no Vanilla+ player and no
// WM_VP_* guns; loading the add-on on top of it adds this class to the New Game screen through
// MAPINFO's AddPlayerClasses, which is additive (gi.cpp:370) where PlayerClasses replaces.
//
// Moved out of zscript/rs_vr_weapons/loadout.zs on 2026-09-18 with every line unchanged. It has
// to live in its own lump because the base and the add-on are separate archives: a class defined
// in both would be a fatal, global load error the moment they were loaded together.
//
// Its siblings stayed behind on purpose. weaponset.zs's Vanilla+ pickup machinery is keyed on
// strings and on SetOf(player) == 1, true only for this class, and PlusList already skips a name
// that is not a loaded weapon -- so all of it sits inert in the base and needs no second copy.
// ============================================================================

// ============================================================================
// VANILLA+ -- THE SECOND PLAYER CLASS (the owner, 09-14: "load doom, new game, choose class").
//
// Its own guns: the Vanilla+ versions of the sixteen Vanilla guns (WM_VP_*: each only its Weapon Card in WMSHEET.plus_*,
// its class written into generated_guns.zs by the class writer), starting from the Vanilla numbers and tuned apart from
// them, plus the revolvers, the rifles, the SMGs, the flamethrowers and the Railgun. Doom's weapon pickups hand a
// Vanilla+ player these (weaponset.zs, WM_PairPickup.PlusGuns); a Vanilla player on the same pickup still gets the
// Vanilla gun. The start is Doom's, as Vanilla's: both fists, its Pistol and Handgun, 50 Clip.
//
// A SUBCLASS WITH ITS OWN LISTS: the engine starts a class's start items afresh at the first Player.StartItem it
// declares, and every slot is declared again here. As WM_Player's list is the test arsenal, this is Vanilla+'s: every
// Vanilla+ gun carried, trimmed to Doom's start while wm_start_arsenal is off. The first weapon listed is raised in the
// main hand and the first off-hand one in the off hand, as for WM_Player.
// ============================================================================
class WM_PlayerPlus : WM_Player
{
	Default
	{
		WM_Player.WeaponSet 1;
		WM_Player.StartGuns "WM_VP_M4A3", "WM_VP_Pistolet";
		WM_Player.StartGrenade true;
		WM_Player.StartShieldSaw true;
		Player.DisplayName "Vanilla+";

		Player.StartItem "WM_VP_M4A3";
		Player.StartItem "WM_VP_Pistolet";
		Player.StartItem "WM_PistoletBlue";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 200;
		Player.StartItem "Shell", 50;
		Player.StartItem "RocketAmmo", 20;
		Player.StartItem "Cell", 300;
		Player.StartItem "WM_VP_PumpM37";
		Player.StartItem "WM_VP_PumpDoom";
		Player.StartItem "WM_VP_SSG";
		Player.StartItem "WM_VP_BullpupPump";
		Player.StartItem "WM_Moonlight";
		Player.StartItem "WM_Sunset";
		Player.StartItem "WM_ColaRevolver";
		Player.StartItem "WM_Rifle";
		Player.StartItem "WM_M16";
		Player.StartItem "WM_SMG";
		Player.StartItem "WM_Tec9";
		Player.StartItem "WM_VP_Chaingun";
		Player.StartItem "WM_VP_MachineGun";
		Player.StartItem "WM_VP_RocketLauncher";
		Player.StartItem "WM_VP_RPG";
		Player.StartItem "WM_VP_PlasmaRifle";
		Player.StartItem "WM_VP_PlasmaRifleBlue";
		Player.StartItem "WM_Railgun";
		Player.StartItem "WM_VP_BFG";
		Player.StartItem "WM_VP_BFGHeavy";
		Player.StartItem "WM_Flamer";
		Player.StartItem "WM_Flamethrower";
		Player.StartItem "WM_VP_Chainsaw";
		Player.StartItem "WM_VP_ChainsawHeavy";

		Player.WeaponSlot 1, "RS_WorldFist", "RS_WorldFistOff", "WM_VP_Chainsaw", "WM_VP_ChainsawHeavy", "RS_ShieldSaw";
		Player.WeaponSlot 2, "WM_VP_M4A3", "WM_VP_Pistolet", "WM_PistoletBlue";
		Player.WeaponSlot 3, "WM_VP_PumpM37", "WM_VP_PumpDoom", "WM_VP_SSG", "WM_VP_BullpupPump";
		Player.WeaponSlot 4, "WM_Moonlight", "WM_Sunset", "WM_ColaRevolver";
		Player.WeaponSlot 5, "WM_Rifle", "WM_M16";
		Player.WeaponSlot 6, "WM_SMG", "WM_Tec9";
		Player.WeaponSlot 7, "WM_VP_Chaingun", "WM_VP_MachineGun";
		Player.WeaponSlot 8, "WM_VP_RocketLauncher", "WM_VP_RPG";
		Player.WeaponSlot 9, "WM_VP_PlasmaRifle", "WM_VP_PlasmaRifleBlue", "WM_Railgun", "RS_VRGrenade";
		Player.WeaponSlot 0, "WM_VP_BFG", "WM_VP_BFGHeavy", "WM_Flamer", "WM_Flamethrower";
	}
}
