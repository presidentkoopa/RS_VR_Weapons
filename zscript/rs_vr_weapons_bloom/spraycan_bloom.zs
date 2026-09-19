// ==========================================================================
// BLOOM'S SPRAY CAN. The same mesh and the same two jets as the Blood set's, because Bloom did not
// change what an aerosol does -- but it is its own class, because a class defined in two archives
// is a fatal, global load error and the Blood pack owns BL_SprayCan.
//
// IT INHERITS EVERYTHING. BL_SprayCan already chooses between bl_spray_inert and bl_spray_lit
// every tic; this changes nothing about that and exists only to be a separate name.
// ==========================================================================
class BM_SprayCan : BL_SprayCan
{
	Default
	{
		Weapon.SelectionOrder 9796;
		Weapon.SlotNumber 7;
		Inventory.PickupMessage "Spray Can";
		Tag "Spray Can";
	}
}
