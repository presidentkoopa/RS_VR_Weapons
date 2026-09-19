// ============================================================================
// GENERATED -- DO NOT EDIT. Written by _pending/tools/make_gun_classes.py from the Weapon Cards' `class` blocks
// (WMSHEET.*) on every build. Change the card, then build. A gun with no `class` block keeps its handwritten
// class. What a gun shoots is its Weapon Card's, applied at load and spawn by the reload system's reader.
// ============================================================================

// WMSHEET.bwolf line 22
class BW_MP40 : WM_Gun
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

// WMSHEET.bwolf line 66
class BW_STG44 : WM_Gun
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

// WMSHEET.bwolf line 108
class BW_Tommy : WM_Gun
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

// WMSHEET.bwolf line 152
class BW_Kar98 : WM_Gun
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

// WMSHEET.bwolf line 191
class BW_Garand : WM_Gun
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

// WMSHEET.bwolf line 230
class BW_Luger : WM_Gun
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

// WMSHEET.bwolf line 269
class BW_1911 : WM_Gun
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

// WMSHEET.bwolf line 308
class BW_PPSh : WM_Gun
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

// WMSHEET.bwolf line 352
class BW_BAR : WM_Gun
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

// WMSHEET.bwolf line 395
class BW_MG42 : WM_Gun
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

// WMSHEET.bwolf line 434
class BW_Shotgun : WM_Gun
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

// WMSHEET.bwolf line 479
class BW_Chaingun : WM_Gun
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

// WMSHEET.bwolf line 525
class BW_Knife : WM_Gun
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

// WMSHEET.bwolf line 540
class BW_Axe : WM_ThrownGun
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9110;
		Tag "Hatchet";
		Inventory.PickupMessage "Hatchet";
	}
}

// WMSHEET.bwolf line 568
class BW_Flamethrower : WM_Gun
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

// WMSHEET.bwolf line 592
class BW_Grenade : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 9900;
		Tag "Stielhandgranate";
		Inventory.PickupMessage "Stielhandgranate";
	}
}

// WMSHEET.bwolf line 608
class BW_P38 : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9230;
		Weapon.AmmoType1 "Clip";
		Tag "Walther P38";
		Inventory.PickupMessage "Walther P38";
	}
}

// WMSHEET.bwolf line 640
class BW_Nebelwerfer : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 8;
		Weapon.SelectionOrder 9800;
		Weapon.AmmoType1 "RocketAmmo";
		Tag "Nebelwerfer";
		Inventory.PickupMessage "Nebelwerfer";
	}
}

// WMSHEET.bwolf line 689
class BW_MP40_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9401;
		Weapon.AmmoType1 "Clip";
		Tag "MP40 (left)";
		Inventory.PickupMessage "MP40";
	}
}

// WMSHEET.bwolf line 701
class BW_STG44_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9521;
		Weapon.AmmoType1 "Clip";
		Tag "StG 44 (left)";
		Inventory.PickupMessage "StG 44";
	}
}

// WMSHEET.bwolf line 713
class BW_Kar98_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9501;
		Weapon.AmmoType1 "Clip";
		Tag "Kar98k (left)";
		Inventory.PickupMessage "Kar98k";
	}
}

// WMSHEET.bwolf line 725
class BW_Garand_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9511;
		Weapon.AmmoType1 "Clip";
		Tag "M1 Garand (left)";
		Inventory.PickupMessage "M1 Garand";
	}
}

// WMSHEET.bwolf line 737
class BW_1911_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9201;
		Weapon.AmmoType1 "Clip";
		Tag "Colt M1911 (left)";
		Inventory.PickupMessage "Colt M1911";
	}
}

// WMSHEET.bwolf line 749
class BW_PPSh_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9421;
		Weapon.AmmoType1 "Clip";
		Tag "PPSh-41 (left)";
		Inventory.PickupMessage "PPSh-41";
	}
}

// WMSHEET.bwolf line 761
class BW_BAR_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9531;
		Weapon.AmmoType1 "Clip";
		Tag "BAR (left)";
		Inventory.PickupMessage "BAR";
	}
}

// WMSHEET.bwolf line 773
class BW_MG42_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 6;
		Weapon.SelectionOrder 9601;
		Weapon.AmmoType1 "Clip";
		Tag "MG42 (left)";
		Inventory.PickupMessage "MG42";
	}
}

// WMSHEET.bwolf line 785
class BW_Shotgun_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9301;
		Weapon.AmmoType1 "Shell";
		Tag "Trench Gun (left)";
		Inventory.PickupMessage "Trench Gun";
	}
}

// WMSHEET.bwolf line 797
class BW_Chaingun_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 6;
		Weapon.SelectionOrder 9611;
		Weapon.AmmoType1 "Clip";
		Tag "Heavy Machine Gun (left)";
		Inventory.PickupMessage "Heavy Machine Gun";
	}
}

// WMSHEET.bwolf line 809
class BW_Axe_Off : WM_ThrownGun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9111;
		Tag "Hatchet (left)";
		Inventory.PickupMessage "Hatchet";
	}
}

// WMSHEET.bwolf line 826
class BW_Flamethrower_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 9701;
		Weapon.AmmoType1 "Cell";
		Tag "Flammenwerfer (left)";
		Inventory.PickupMessage "Flammenwerfer";
	}
}

// WMSHEET.bwolf line 838
class BW_Grenade_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 9901;
		Tag "Stielhandgranate (left)";
		Inventory.PickupMessage "Stielhandgranate";
	}
}

// WMSHEET.bwolf line 849
class BW_P38_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9231;
		Weapon.AmmoType1 "Clip";
		Tag "Walther P38 (left)";
		Inventory.PickupMessage "Walther P38";
	}
}

// WMSHEET.bwolf line 861
class BW_Nebelwerfer_Off : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 8;
		Weapon.SelectionOrder 9801;
		Weapon.AmmoType1 "RocketAmmo";
		Tag "Nebelwerfer (left)";
		Inventory.PickupMessage "Nebelwerfer";
	}
}
