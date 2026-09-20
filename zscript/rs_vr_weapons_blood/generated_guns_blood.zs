// ============================================================================
// GENERATED -- DO NOT EDIT. Written by _pending/tools/make_gun_classes.py from the Weapon Cards' `class` blocks
// (WMSHEET.*) on every build. Change the card, then build. A gun with no `class` block keeps its handwritten
// class. What a gun shoots is its Weapon Card's, applied at load and spawn by the reload system's reader.
// ============================================================================

// WMSHEET.blood line 24
class BL_Pitchfork : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9190;
		Tag "Pitchfork";
		Inventory.PickupMessage "Pitchfork";
	}
}

// WMSHEET.blood line 37
class BL_FlareGun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 9290;
		Weapon.AmmoType1 "Clip";
		Tag "Flare Pistol";
		Inventory.PickupMessage "Flare Pistol";
	}
}

// WMSHEET.blood line 78
class BL_Shotgun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 9390;
		Weapon.AmmoType1 "Shell";
		Tag "Sawn-Off";
		Inventory.PickupMessage "Sawn-Off";
	}
}

// WMSHEET.blood line 112
class BL_TommyGun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 4;
		Weapon.SelectionOrder 9490;
		Weapon.AmmoType1 "Clip";
		Tag "Tommy Gun";
		Inventory.PickupMessage "Tommy Gun";
	}
}

// WMSHEET.blood line 143
class BL_Napalm : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 5;
		Weapon.SelectionOrder 9590;
		Weapon.AmmoType1 "RocketAmmo";
		Tag "Napalm Launcher";
		Inventory.PickupMessage "Napalm Launcher";
	}
}

// WMSHEET.blood line 173
class BL_TeslaGun : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 6;
		Weapon.SelectionOrder 9690;
		Weapon.AmmoType1 "Cell";
		Tag "Tesla Cannon";
		Inventory.PickupMessage "Tesla Cannon";
	}
}

// WMSHEET.blood line 202
class BL_LifeLeech : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 7;
		Weapon.SelectionOrder 9790;
		Weapon.AmmoType1 "Cell";
		Tag "Life Leech";
		Inventory.PickupMessage "Life Leech";
	}
}

// WMSHEET.blood line 254
class BL_Sigil : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 8;
		Weapon.SelectionOrder 9890;
		Weapon.AmmoType1 "Cell";
		Tag "Sigil";
		Inventory.PickupMessage "Sigil";
	}
}

// WMSHEET.blood line 276
class BL_Dynamite : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 9990;
		Tag "Dynamite";
		Inventory.PickupMessage "Dynamite";
	}
}

// WMSHEET.blood line 290
class BL_Voodoo : WM_Gun
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 9191;
		Tag "Voodoo Doll";
		Inventory.PickupMessage "Voodoo Doll";
	}
}

// WMSHEET.blood line 303
class BL_Lighter : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 9991;
		Tag "Lighter";
		Inventory.PickupMessage "Lighter";
	}
}
