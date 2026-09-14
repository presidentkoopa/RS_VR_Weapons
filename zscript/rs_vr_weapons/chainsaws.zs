// ============================================================================
// THE CHAINSAWS -- slot 1, with the fists. The chainsaw in the main hand, the heavy
// chainsaw in the off hand. No ammo, nothing to reload.
//
// CHAINSAW: RS_ModelSwapper's chainsaw as chainsaw_wm.md3 (body, chain, ripcord, cord, and
// chain2, the chain's second running pose from the donor's fire frame 8). It
// HAS A RIPCORD: a T-grip on the engine's side, pulled 9.86 out on a cord in the donor's
// select clip. Pull it to start the engine (its card's `start ripcord`); until then the
// trigger only clicks.
// HEAVY CHAINSAW: Force Unleashed's chainsaw and its two chain poses, merged into
// chainsaw_heavy_wm.md3 (body, trigger, chain, chain2). No ripcord. Measurements in
// _pending/CHAINSAW_CARDS.md.
//
// THE ATTACK is vanilla's chainsaw: A_Saw (2 x 1d10) every 4 tics while held.
//
// BOTH LIVE: WM_Gun.ShotSaw and SawSounds "wm/saw/loop", "wm/saw/hit". The heavy chainsaw
// runs on its trigger, so it keeps UpSound "wm/saw/start", and its idle hum is its card's idlesound,
// which RS_VR_Reload idles while it is drawn (VANILLA_PARITY F4: a ReadySound restarted every tic here,
// because WM_Gun's Ready is a one-tic loop and A_WeaponReady replays it on every pass).
// The chainsaw's engine sounds are its card's instead (pullsound, startsound, idlesound,
// stopsound; RS_VR_Reload.pk3 09-13 15:45): the class's ReadySound would idle an engine that
// is not running, and its UpSound would start one nobody pulled.
// ============================================================================

class WM_Chainsaw : WM_Gun
{
	Default
	{
		Weapon.SelectionOrder 2200;
		Weapon.SlotNumber 1;
		Inventory.PickupMessage "Chainsaw";
		Tag "Chainsaw";
		// LIVE: the reload system's keys for this gun landed. No ReadySound or UpSound: the
		// engine's sounds are its card's, played by the ripcord.
		WM_Gun.ShotSaw true;
		WM_Gun.SawSounds "wm/saw/loop", "wm/saw/hit";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 4;
	}
}

class WM_ChainsawHeavy : WM_Gun
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9900;
		Weapon.SlotNumber 1;
		Inventory.PickupMessage "Heavy Chainsaw";
		Tag "Heavy Chainsaw";
		// LIVE: the reload system's keys for this gun landed.
		WM_Gun.ShotSaw true;
		WM_Gun.SawSounds "wm/saw/loop", "wm/saw/hit";
		Weapon.UpSound "wm/saw/start";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 4;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropChainsaw : WM_Prop {}
class WM_PropChainsawHeavy : WM_Prop {}
