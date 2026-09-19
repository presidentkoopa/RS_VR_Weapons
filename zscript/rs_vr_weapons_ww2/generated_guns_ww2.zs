// ============================================================================
// GENERATED -- DO NOT EDIT. Written by _pending/tools/make_gun_classes.py from the Weapon Cards' `class` blocks
// (WMSHEET.*) on every build. Change the card, then build. A gun with no `class` block keeps its handwritten
// class. What a gun shoots is its Weapon Card's, applied at load and spawn by the reload system's reader.
// ============================================================================

// WMSHEET.ww2 line 18
class WW2_MP40 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9400;
		Weapon.AmmoType1 "Clip";
		Tag "MP40";
		Inventory.PickupMessage "MP40";
	}
}

// WMSHEET.ww2 line 33
class WW2_STG44 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9520;
		Weapon.AmmoType1 "Clip";
		Tag "StG 44";
		Inventory.PickupMessage "StG 44";
	}
}

// WMSHEET.ww2 line 48
class WW2_Tommy : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9410;
		Weapon.AmmoType1 "Clip";
		Tag "Thompson M1A1";
		Inventory.PickupMessage "Thompson M1A1";
	}
}

// WMSHEET.ww2 line 63
class WW2_Kar98 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9500;
		Weapon.AmmoType1 "Clip";
		Tag "Kar98k";
		Inventory.PickupMessage "Kar98k";
	}
}

// WMSHEET.ww2 line 78
class WW2_Garand : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9510;
		Weapon.AmmoType1 "Clip";
		Tag "M1 Garand";
		Inventory.PickupMessage "M1 Garand";
	}
}

// WMSHEET.ww2 line 93
class WW2_Luger : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9190;
		Weapon.AmmoType1 "Clip";
		Tag "Luger P08";
		Inventory.PickupMessage "Luger P08";
	}
}

// WMSHEET.ww2 line 108
class WW2_1911 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9200;
		Weapon.AmmoType1 "Clip";
		Tag "Colt M1911";
		Inventory.PickupMessage "Colt M1911";
	}
}

// WMSHEET.ww2 line 123
class WW2_PPSh : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9420;
		Weapon.AmmoType1 "Clip";
		Tag "PPSh-41";
		Inventory.PickupMessage "PPSh-41";
	}
}

// WMSHEET.ww2 line 138
class WW2_BAR : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9530;
		Weapon.AmmoType1 "Clip";
		Tag "BAR";
		Inventory.PickupMessage "BAR";
	}
}

// WMSHEET.ww2 line 152
class WW2_MG42 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 6;
		Weapon.SelectionOrder 9600;
		Weapon.AmmoType1 "Clip";
		Tag "MG42";
		Inventory.PickupMessage "MG42";
	}
}

// WMSHEET.ww2 line 167
class WW2_Shotgun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9300;
		Weapon.AmmoType1 "Shell";
		Tag "Trench Gun";
		Inventory.PickupMessage "Trench Gun";
	}
}

// WMSHEET.ww2 line 183
class WW2_Chaingun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 6;
		Weapon.SelectionOrder 9610;
		Weapon.AmmoType1 "Clip";
		Tag "Heavy Machine Gun";
		Inventory.PickupMessage "Heavy Machine Gun";
	}
}

// WMSHEET.ww2 line 198
class WW2_Knife : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9100;
		Tag "Trench Knife";
		Inventory.PickupMessage "Trench Knife";
	}
}

// WMSHEET.ww2 line 208
class WW2_Axe : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9110;
		Tag "Hatchet";
		Inventory.PickupMessage "Hatchet";
	}
}

// WMSHEET.ww2 line 218
class WW2_Flamethrower : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 9700;
		Weapon.AmmoType1 "Cell";
		Tag "Flammenwerfer";
		Inventory.PickupMessage "Flammenwerfer";
	}
}

// WMSHEET.ww2 line 229
class WW2_Grenade : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 9900;
		Tag "Stielhandgranate";
		Inventory.PickupMessage "Stielhandgranate";
	}
}
