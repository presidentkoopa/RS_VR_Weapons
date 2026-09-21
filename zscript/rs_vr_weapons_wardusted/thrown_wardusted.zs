// ============================================================================
// WHAT THE WARDUSTED SET THROWS -- the thermal detonator and the proximity mine in flight.
//
// Each is its gun's `shotclass` (WMSHEET.wardusted), the whole-weapon throw BL_Lighter established,
// and each draws the mesh the hand held (`# flightclass`, WMCARD.wardusted -> MODELDEF).
//
// THE BLAST LOOKS ARE RS_BALLISTICS', named where they go off, the way BL_ThrownLighter names its
// own: sw_thermal and sw_mine (the ballistics lane, 2026-09-21: "Thrown things ... name their impact
// in the class when they go off"). RSB_Impact is resolved before this file in the owner's load order
// (Ballistics -> Reload -> Weapons -> this), so naming it is safe here.
// ============================================================================

// A THERMAL DETONATOR: armed as it leaves the hand, bounces, and goes off on a three-second fuse
// wherever it has got to -- which is what makes it a detonator and not a grenade that pops on contact.
class WD_ThrownThermal : Actor
{
	const FUSE_TICS = 105;          // three seconds
	int fuse;

	Default
	{
		Projectile;
		-NOGRAVITY;
		Gravity 0.5;
		Radius 4;
		Height 6;
		Speed 24;
		Damage 0;
		BounceType "Doom";
		BounceFactor 0.45;
		WallBounceFactor 0.5;
		BounceCount 8;
		+BOUNCEONACTORS
		+CANBOUNCEWATER
		Obituary "%o caught %k's thermal detonator.";
	}

	virtual String BlastLook() { return "sw_thermal"; }
	virtual int BlastDamage()  { return 160; }
	virtual int BlastRadius()  { return 192; }
	virtual Sound BlastSound() { return "wardusted/thermal/boom"; }

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen()) return;
		if (++fuse >= FUSE_TICS) Blow();
	}

	void Blow()
	{
		A_StartSound(BlastSound(), CHAN_BODY, CHANF_DEFAULT, 1.0, ATTN_NONE);
		A_Explode(BlastDamage(), BlastRadius());
		Vector3 travel = (Vel.Length() > 0.01) ? Vel.Unit() : (0, 0, -1);
		RSB_Impact.Land(self, BlastLook(), travel, true);
		Destroy();
	}

	States
	{
	Spawn:
		WMPR A 1;
		Loop;
	Death:
		// OUT OF BOUNCES: it lies where it stopped and the fuse keeps running (Tick).
		WMPR A -1;
		Stop;
	}
}

// A PROXIMITY MINE: it sticks where it lands, beeps as it arms, and goes off when anything hostile
// comes within reach -- Wardusted's own ProximityMines, named by its MineBeep and MineExplode.
class WD_ThrownMine : Actor
{
	const ARM_TICS = 35;
	const REACH    = 88.0;

	int armed;          // tics since it came to rest; -1 while still flying

	Default
	{
		Projectile;
		-NOGRAVITY;
		Gravity 0.6;
		Radius 4;
		Height 4;
		Speed 20;
		Damage 0;
		Obituary "%o stepped on %k's mine.";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		armed = -1;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen() || armed < 0) return;
		armed++;
		if (armed == ARM_TICS) A_StartSound("wardusted/mine/beep", CHAN_BODY);
		if (armed < ARM_TICS || (armed % 4) != 0) return;
		BlockThingsIterator it = BlockThingsIterator.Create(self, REACH);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || !mo.bIsMonster || !mo.bShootable || mo.health <= 0 || mo.bFriendly) continue;
			if (Distance3D(mo) > REACH + mo.radius) continue;
			if (!CheckSight(mo)) continue;
			Blow();
			return;
		}
	}

	void Blow()
	{
		A_StartSound("wardusted/mine/boom", CHAN_BODY, CHANF_DEFAULT, 1.0, ATTN_NONE);
		A_Explode(200, 176);
		RSB_Impact.Land(self, "sw_mine", (0, 0, -1), true);
		Destroy();
	}

	States
	{
	Spawn:
		WMPR A 1;
		Loop;
	Death:
		// IT STICKS: stopped dead where it met the floor or the wall, and the arming count starts.
		WMPR A 0
		{
			Vel = (0, 0, 0);
			bNoGravity = true;
			armed = 0;
		}
		WMPR A -1;
		Stop;
	}
}
