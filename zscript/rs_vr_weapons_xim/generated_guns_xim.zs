// ============================================================================
// GENERATED -- DO NOT EDIT. Written by _pending/tools/make_gun_classes.py from the Weapon Cards' `class` blocks
// (WMSHEET.*) on every build. Change the card, then build. A gun with no `class` block keeps its handwritten
// class. What a gun shoots is its Weapon Card's, applied at load and spawn by the reload system's reader.
// ============================================================================

// WMSHEET.xim line 11
class XM_Pistol : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9290;
		Weapon.AmmoType1 "Clip";
		Tag "Blaster Pistol";
		Inventory.PickupMessage "Blaster Pistol";
	}
}

// WMSHEET.xim line 30
class XM_Shotgun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9391;
		Weapon.AmmoType1 "Shell";
		Tag "Blaster Rifle";
		Inventory.PickupMessage "Blaster Rifle";
	}
}

// WMSHEET.xim line 49
class XM_SuperShotgun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9392;
		Weapon.AmmoType1 "Shell";
		Tag "Ion Blaster";
		Inventory.PickupMessage "Ion Blaster";
	}
}

// WMSHEET.xim line 68
class XM_Chaingun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9493;
		Weapon.AmmoType1 "Clip";
		Tag "Heavy Blaster";
		Inventory.PickupMessage "Heavy Blaster";
	}
}

// WMSHEET.xim line 88
class XM_RocketLauncher : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9594;
		Weapon.AmmoType1 "RocketAmmo";
		Tag "Bowcaster";
		Inventory.PickupMessage "Bowcaster";
	}
}

// WMSHEET.xim line 107
class XM_PlasmaRifle : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 6;
		Weapon.SelectionOrder 9695;
		Weapon.AmmoType1 "Cell";
		Tag "Rotary Blaster";
		Inventory.PickupMessage "Rotary Blaster";
	}
}

// WMSHEET.xim line 127
class XM_Thermal : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 9796;
		Tag "Thermal Detonator";
		Inventory.PickupMessage "Thermal Detonator";
	}
}
