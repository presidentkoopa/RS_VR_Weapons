// ============================================================================
// THE FLAMETHROWERS -- slot 0, beside the BFGs. The flamer in the main hand, the
// flamethrower in the off hand. Both RELOAD: each model animates a fuel canister, and the
// owner's rule was "assume it doesn't reload (unless the models animate)".
//
// FLAMER: RS_ModelSwapper's AE flamer (m260b.md3) as flamer_wm.md3 (body, pilotflame,
// canister, trigger); its canister drops straight out from under the gun.
// FLAMETHROWER: RS_Main's RS_GH_Flamethrower (the owner, 09-14), as flamethrower2_wm.md3 (body,
// trigger, canister, pilotflame) -- held like a fuel-nozzle handle, its canister swapped straight
// down. Its card is the reload lane's (WMCARD.13_flamethrower). Until 09-14 it was Force
// Unleashed's incinerator (_pending/_unused/flamers/Flamethrower, _pending/FLAMER_CARDS.md).
//
// THE SHOT is RS_Main's RS_GH_Flamethrower (RollStats), Uncommon -- the tier the revolvers,
// rifles, SMGs and railgun carry: 11-17 a shot, Accuracy 55-65 at spreadScale 0.05, so
// (100 - 60) x 0.05 = 2.0, taken as 1.0 sideways and 0.33 up and down the way the others
// were; RateOfFire 17 a second, so FireTics 2 (35 / 17). RS_Main's flamethrower fires a
// travelling flame round (RS_GH_FlameJet, DamageType "Fire"), not a bullet: here that is
// WM_FlameShot (the flamer) and WM_NapalmShot (the flamethrower) below, each reaching as far
// as its RS_Ballistics flame profile draws (incinerator 520, napalm 380).
//
// THE FLAME YOU SEE is RS_Ballistics' RSB_Flame, fed from WM_FlameGun below through the reload
// system's hooks: FireHeld every tic the trigger stays down, FireReleased once when it comes
// up, and a pilot light while the gun is idle with fuel. THIS PACKAGE THEREFORE NEEDS
// RS_BALLISTICS LOADED BEFORE IT (RSB_Flame is a compile-time reference); build.ps1's compile
// check loads it first, as the owner's load order does.
//
// BOTH LIVE: Weapon.AmmoType1 "Cell" and WM_Gun.ShotClass "WM_FlameShot" / "WM_NapalmShot".
// The flame rounds carry their 11-17 themselves (ShotDamage only ever sets a bullet's --
// RS_Ballistics' RSB_Bullet); ShotDamage 11, 17 stays on the classes, where the gun's
// summary reads it.
// ============================================================================

// ============================================================================
// WHAT BOTH FLAMETHROWERS DO WITH THEIR FLAME. Presentation only: the drawn gun is placed
// from the local controller, so these points differ between machines and decide nothing the
// game compares -- damage is the flame rounds', fuel is the reload system's. RSB_Flame's actors
// are +NOINTERACTION and use no playsim RNG.
// ============================================================================

class WM_FlameGun : WM_Gun
{
	// Each flamethrower says which RSBDEFS flame it draws and where its pilot light is on the
	// card (MD3 model space, the card's own numbers).
	virtual String FlameProfile() { return "incinerator"; }
	virtual Vector3 PilotPoint()  { return (0, 0, 0); }
	virtual Vector3 PilotDir()    { return (1, 0, 0); }

	// EVERY TIC THE TRIGGER STAYS DOWN after a shot left: the stream out of the nozzle -- the
	// card's muzzle with this hand's muzzle trim sliders -- along the barrel, carried with the
	// hand, coughing as the canister runs low (FeedShare), its twin jets kept side by side on a
	// rolled wrist (AcrossToWorld).
	override void FireHeld(int heldTics)
	{
		Super.FireHeld(heldTics);
		if (!Owner) return;
		Vector3 nozzle, aim, across;
		bool ok;
		[nozzle, ok] = MuzzleToWorld();
		[aim, ok]    = BarrelToWorld();
		[across, ok] = AcrossToWorld();
		// fuelShare is the canister's fill (FeedShare), for the sputter below 15%; acrossAxis the
		// gun's across direction, to keep napalm's twin jets side by side on a rolled wrist --
		// (0, 0, 0), RS_Ballistics' own "none", when there is no drawn gun to read it from.
		if (!ok) across = (0, 0, 0);
		RSB_Flame.Stream(FlameProfile(), Owner, Hand(), nozzle, aim, CarrierVelocity(), 1.0, FeedShare(), across);
	}

	// ONCE, when the trigger comes back or the gun stops firing: the flame goes out (its
	// flame-out gout, which RS_Ballistics skips on an empty canister).
	override void FireReleased(int heldTics)
	{
		Super.FireReleased(heldTics);
		if (Owner) RSB_Flame.StopStream(Owner, Hand());
	}

	// THE PILOT LIGHT: only while this gun is up in a hand, drawn, not firing, with fuel.
	// Super first -- WM_Gun.DoEffect is what runs FireHeld and FireReleased.
	override void DoEffect()
	{
		Super.DoEffect();
		if (!Owner || TriggerIsDown() || FeedShare() <= 0) return;
		let pl = Owner.player;
		if (!pl || (pl.ReadyWeapon != self && pl.OffhandWeapon != self)) return;
		Vector3 at, dir;
		bool okAt, okDir;
		[at, okAt]   = CardPointToWorld(PilotPoint());
		[dir, okDir] = CardDirToWorld(PilotPoint(), PilotDir());
		if (okAt && okDir) RSB_Flame.Pilot(FlameProfile(), at, dir);
	}
}

class WM_Flamer : WM_FlameGun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "none";
		Weapon.SelectionOrder 3000;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "Flamer";
		Tag "Flamer";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "WM_FlameShot";
		WM_Gun.ShotDamage 11, 17;
		WM_Gun.ShotSpread 1.0, 0.33;
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 2;
	}

	// A tight, fast jet out of a small round orifice (FLAMER_CARDS.md). The pilot: the donor's
	// baked pilot flame's base on the burner tip below right, leaning up and in toward the bore.
	override String FlameProfile() { return "incinerator"; }
	override Vector3 PilotPoint()  { return (40.43, 1.68, -4.58); }
	override Vector3 PilotDir()    { return (0.524, -0.519, 0.675); }
}

class WM_Flamethrower : WM_FlameGun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.FlashProfile "none";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9950;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "Flamethrower";
		Tag "Flamethrower";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "WM_NapalmShot";
		WM_Gun.ShotDamage 11, 17;
		WM_Gun.ShotSpread 1.0, 0.33;
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 2;
	}

	// A wide spray out of a round shroud (the napalm profile). The pilot: the igniter cone's base on
	// flamethrower2_wm.md3, leaning up and forward toward the shroud (the reload lane, 09-14).
	override String FlameProfile() { return "napalm"; }
	override Vector3 PilotPoint()  { return (54.60, 3.52, -1.55); }
	override Vector3 PilotDir()    { return (0.460, 0.002, 0.888); }
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropFlamer : WM_Prop {}
class WM_PropFlamethrower : WM_Prop {}

// ============================================================================
// THE FLAME ROUNDS -- what the two flamethrowers fire once WM_Gun.ShotClass names them.
//
// RS_Main's RS_GH_FlameJet, as far as the damage goes: DamageType "Fire", RS_Main's
// flamethrower's Uncommon 11-17 a hit, no puff. It carries its own damage because
// WM_Gun.ShotDamage only ever sets a bullet's (RS_Ballistics' RSB_Bullet). Invisible: the stream you see is
// RS_Ballistics' RSB_Flame; this is only what hurts.
//
// REACH = SPEED x LIFE, matched to the flame each gun draws: the flamer's incinerator
// profile reaches 520 (26 a tic for 20 tics), the flamethrower's napalm 380 (19 for 20). A
// round that meets nothing within that simply ends.
//
// NETPLAY: the damage is rolled on a named RNG inside the playsim, where the hit happens,
// so every machine rolls alike; nothing here reads the console player.
// ============================================================================

class WM_FlameShot : Actor
{
	Default
	{
		Projectile;
		Radius 6;
		Height 8;
		Speed 26;
		DamageType "Fire";
		DamageFunction (random[WMFlame](11, 17));
		+DONTSPLASH
	}

	States
	{
	Spawn:
		TNT1 A 20;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class WM_NapalmShot : WM_FlameShot
{
	Default
	{
		Speed 19;
	}
}
