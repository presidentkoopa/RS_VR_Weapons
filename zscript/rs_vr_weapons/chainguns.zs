// ============================================================================
// THE CHAINGUNS -- slot 7. The chaingun in the main hand, the machine gun in the off
// hand. Both held in two hands.
//
// CHAINGUN: Force Unleashed's chaingun, its box magazine and its ammo belt, merged into
// chaingun_wm.md3 (body, barrels, trigger, magazine, belt). Box-fed, fired straight from
// the box; the box slides straight up into the well.
// MACHINE GUN: RS_ModelSwapper's belt-fed machine gun as machinegun_wm.md3. ITS BULLETS
// COME FROM THE RESERVE (the owner): the ammo box is drawn as part of the gun and never
// swapped. WHAT YOU RELOAD IS ITS UNDERBARREL GRENADE LAUNCHER: press the latch, slide
// the tube forward, drop one of RS_Grenade's grenades into the breech, slide it shut, and
// fire it on the second button -- WM_LauncherGrenade below. The launcher's parts are named
// in the mesh (launcher, launchertube, launchertrigger, launcherlatch) and measured.
// Measurements in _pending/CHAINGUN_CARDS.md and _pending/MACHINEGUN_UBL.md.
//
// THE SHOT is vanilla's chaingun: 5 x 1d3 (the round profile's own, RS_Ballistics' RSB_Bullet) every 4 tics while held,
// up to 5.6 degrees sideways. Vanilla's first shot of a burst is dead on; here every
// shot takes the spread. The chaingun's box holds 100, the owner's number.
//
// BOTH LIVE. Weapon.AmmoType1 "Clip" on both: the chaingun's box refills from it, the
// machine gun fires from it. The machine gun's launcher is the card's `barrel launcher`
// (the reload system's second-barrel grammar, RS_VR_Reload.pk3 09-13 15:02): alt fire,
// from its one-round store gl, WM_LauncherGrenade by name, RS_Grenade's RSVG_Ammo from
// the pouch, and only while the breech is shut -- the machine gun fires with it open.
// ============================================================================

class WM_Chaingun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "rifle_556";
		WM_Gun.FlashProfile "smg";
		WM_Gun.EjectaProfile "brass_556";
		Weapon.SelectionOrder 700;
		Weapon.SlotNumber 7;
		Inventory.PickupMessage "Chaingun";
		Tag "Chaingun";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Clip";
		WM_Gun.ShotSpread 5.6, 0;
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 4;
		// VANILLA'S FIRST TWO ARE DEAD ON: A_FireCGun fires twice before its A_ReFire, both accurate;
		// the rest of a held run scatters within the spread (RS_VR_Reload 09-14).
		WM_Gun.FirstShotsAccurate 2;
	}
}

class WM_MachineGun : WM_Gun
{
	Default
	{
		// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS.
		WM_Gun.RoundProfile "rifle_762";
		WM_Gun.FlashProfile "rifle";
		WM_Gun.EjectaProfile "brass_762";
		WM_Gun.AltFlashProfile "rocket";
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 9600;
		Weapon.SlotNumber 7;
		Inventory.PickupMessage "Machine Gun";
		Tag "Machine Gun";
		// LIVE: the reload system's keys for this gun landed.
		Weapon.AmmoType1 "Clip";
		WM_Gun.ShotSpread 5.6, 0;
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 4;
		// Vanilla's chaingun, as WM_Chaingun: the first two of a held run dead on.
		WM_Gun.FirstShotsAccurate 2;
	}
}

// WHAT THEY ARE DRAWN AS. The cards' `prop`; MODELDEF binds the mesh and the hand.
class WM_PropChaingun : WM_Prop {}
class WM_PropMachineGun : WM_Prop {}

// ============================================================================
// THE MACHINE GUN'S GRENADE -- what its underbarrel launcher fires.
//
// RS_GRENADE'S GRENADE, LAUNCHED. The owner: "we can use those grenades for the over
// under". It goes off as RS_Grenade's thrown one does (rs_vrgrenade.zs,
// RS_VRGrenadeThrown, Death): the same sounds, its RSVG_Blast effect, and the same two
// A_Explode calls -- fired from THIS actor, so the kill, the obituary and the score are
// the shooter's. The difference is when: on IMPACT, once it is armed. Inside
// ARM_DISTANCE it is a dud and drops RS_Grenade's own pickup, so the grenade comes back.
//
// A SOFT DEPENDENCY. RS_Grenade is found by name at run time (RSVG_Blast, RSVG_Pickup,
// its rsvg/* sounds), never by type, so this package still loads without it: the blast
// falls back to Doom's rocket explosion sound and a dud drops nothing.
//
// NETPLAY: all of it runs in the playsim on every machine, from the projectile's own
// position; no random call, nothing keyed to the console player.
// ============================================================================

class WM_LauncherGrenade : Actor
{
	// About three metres. A real 40 mm round arms much further out; a Doom room is small.
	const ARM_DISTANCE = 96.0;

	Vector3 launchedFrom;

	Default
	{
		Projectile;
		-NOGRAVITY;
		Radius 3;
		Height 3;
		Speed 40;
		Gravity 0.25;
		Damage 0;            // the blast does the damage, not the impact
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		launchedFrom = Pos;
	}

	bool Armed() const
	{
		return (Pos - launchedFrom).Length() >= ARM_DISTANCE;
	}

	// An actor of RS_Grenade's, by name, where this one is -- nothing when it is not loaded.
	action void A_WMSpawnNamed(String className)
	{
		Class<Actor> c = (Class<Actor>)(Object.FindClass(className, "Actor"));
		if (c) Actor.Spawn(c, Pos, NO_REPLACE);
	}

	action void A_WMGrenadeSounds()
	{
		if (Object.FindClass("RSVG_Blast", "Actor"))
		{
			A_StartSound("rsvg/explode", CHAN_AUTO);
			A_StartSound("rsvg/farexpl", CHAN_7);
		}
		else
		{
			A_StartSound("weapons/rocklx", CHAN_AUTO);
		}
	}

	States
	{
	Spawn:
		WMPR A -1;
		Stop;
	Death:
	XDeath:
		TNT1 A 0 A_JumpIf(!Armed(), "Dud");
		TNT1 A 0 A_NoBlocking();
		TNT1 A 0 A_WMGrenadeSounds();
		TNT1 A 0 A_WMSpawnNamed("RSVG_Blast");
		TNT1 A 1 A_Explode(85, 200, 1);
		TNT1 A 1 A_Explode(75, 255, 1);
		Stop;
	Dud:
		TNT1 A 0 A_WMSpawnNamed("RSVG_Pickup");
		Stop;
	}
}
