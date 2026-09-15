// ============================================================================
// GENERATED -- DO NOT EDIT. Written by _pending/tools/make_gun_classes.py from the Weapon Cards' `class` blocks
// (WMSHEET.*) on every build. Change the card, then build. A gun with no `class` block keeps its handwritten
// class. What a gun shoots is its Weapon Card's, applied at load and spawn by the reload system's reader.
// ============================================================================

// WMSHEET.plus_bfg line 14
class WM_VP_BFG : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 0;
		Weapon.SelectionOrder 2800;
		Weapon.AmmoType1 "Cell";
		Tag "BFG 9000";
		Inventory.PickupMessage "BFG 9000";
	}
}

// WMSHEET.plus_bfg line 36
class WM_VP_BFGHeavy : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 0;
		Weapon.SelectionOrder 9800;
		Weapon.AmmoType1 "Cell";
		Tag "BFG 10000";
		Inventory.PickupMessage "BFG 10000";
	}
}

// WMSHEET.plus_chainguns line 14
class WM_VP_Chaingun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 700;
		Weapon.AmmoType1 "Clip";
		Tag "Chaingun";
		Inventory.PickupMessage "Chaingun";
	}
}

// WMSHEET.plus_chainguns line 38
class WM_VP_MachineGun : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 9600;
		Weapon.AmmoType1 "Clip";
		Tag "Machine Gun";
		Inventory.PickupMessage "Machine Gun";
	}
}

// WMSHEET.plus_chainsaws line 14
class WM_VP_Chainsaw : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 2200;
		Weapon.AmmoType1 "Clip";
		Tag "Chainsaw";
		Inventory.PickupMessage "Chainsaw";
	}
}

// WMSHEET.plus_chainsaws line 32
class WM_VP_ChainsawHeavy : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9900;
		Weapon.AmmoType1 "Clip";
		Tag "Heavy Chainsaw";
		Inventory.PickupMessage "Heavy Chainsaw";
		Weapon.UpSound "wm/saw/start";
	}
}

// WMSHEET.plus_launchers line 14
class WM_VP_RocketLauncher : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 8;
		Weapon.SelectionOrder 2500;
		Weapon.AmmoType1 "RocketAmmo";
		Tag "Rocket Launcher";
		Inventory.PickupMessage "Rocket Launcher";
	}
}

// WMSHEET.plus_launchers line 34
class WM_VP_RPG : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 8;
		Weapon.SelectionOrder 9700;
		Weapon.AmmoType1 "RocketAmmo";
		Tag "RPG";
		Inventory.PickupMessage "RPG";
	}
}

// WMSHEET.plus_pistols line 14
class WM_VP_M4A3 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 100;
		Weapon.AmmoType1 "Clip";
		Tag "Pistol";
		Inventory.PickupMessage "Pistol";
	}
}

// WMSHEET.plus_pistols line 33
class WM_VP_Pistolet : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9000;
		Weapon.AmmoType1 "Clip";
		Tag "Handgun";
		Inventory.PickupMessage "Handgun";
	}
}

// WMSHEET.plus_plasma line 14
class WM_VP_PlasmaRifle : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 1700;
		Weapon.AmmoType1 "Cell";
		Tag "Plasma Rifle";
		Inventory.PickupMessage "Plasma Rifle";
	}
}

// WMSHEET.plus_plasma line 34
class WM_VP_PlasmaRifleBlue : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 1750;
		Weapon.AmmoType1 "Cell";
		Tag "Blue Plasma Rifle";
		Inventory.PickupMessage "Blue Plasma Rifle";
	}
}

// WMSHEET.plus_shotguns line 14
class WM_VP_PumpM37 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 1300;
		Weapon.AmmoType1 "Shell";
		Tag "Steelgun";
		Inventory.PickupMessage "Steelgun";
	}
}

// WMSHEET.plus_shotguns line 34
class WM_VP_PumpDoom : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9100;
		Weapon.AmmoType1 "Shell";
		Tag "Shotgun";
		Inventory.PickupMessage "Shotgun";
	}
}

// WMSHEET.plus_shotguns line 54
class WM_VP_SSG : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 1350;
		Weapon.AmmoType1 "Shell";
		Tag "Super Shotgun";
		Inventory.PickupMessage "Super shotgun";
	}
}

// WMSHEET.plus_shotguns line 76
class WM_VP_BullpupPump : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9150;
		Weapon.AmmoType1 "Shell";
		Tag "Quad Super";
		Inventory.PickupMessage "Quad Super";
	}
}
