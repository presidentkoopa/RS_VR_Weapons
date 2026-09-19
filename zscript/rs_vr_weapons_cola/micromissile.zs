// ============================================================================
// THE SIDEWINDER'S MICRO-MISSILE -- thirty little rockets that behave like rockets.
//
// The Sidewinder is Titanfall 2's Smart Missile Rifle: its texture is smr.png, its
// sounds are the mod's missilelauncher set, and each round is a MISSILE the size of a
// cartridge rather than a bullet. Firing bullets out of it was the placeholder.
//
// THE OWNER WANTED THEM ALIVE IN THE AIR, so the flight has four things happening at
// once and none of them are the same twice:
//
//   1. THEY LEAVE THE TUBE CROOKED AND COME BACK. Each missile is thrown a few degrees
//      off the aim line and then steers onto it, so a burst SPREADS and CONVERGES
//      instead of travelling as one dot. This is the whole reason a volley reads as a
//      volley.
//   2. THEY WEAVE. A corkscrew around the flight line, with a random phase, rate and
//      radius per missile -- so two missiles fired a tic apart never fly the same path.
//   3. THE MOTOR BURNS AND THEN QUITS. They leave slowly and accelerate: you see one
//      go, rather than seeing it arrive. At burnout the weave DECAYS to nothing and it
//      flies straight, which gives the flight a beginning, a middle and an end instead
//      of one looping effect.
//   4. THEY LEAN TOWARD WHAT YOU AIMED AT. A soft pull, narrow cone, capped per tic --
//      enough that they curve onto a target rather than track it. A missile that turns
//      hard stops reading as a rocket and starts reading as a homing cheat.
//
// NO MESH, AND THAT IS HONEST RATHER THAN MISSING. The source pack ships no projectile
// model -- its rocket art is muzzle-flash textures, which are out under the standing
// rule. A micro-missile is a few inches long: at that size what you actually see is the
// motor and the smoke, which is RS_Ballistics' job and not a model's.
// ============================================================================

class CL_MicroMissile : Actor
{
	// ---- THE FLIGHT, IN TICS AND UNITS -------------------------------------
	const LAUNCH_SPEED = 12.0;   // out of the tube: slow enough to watch it leave
	const TOP_SPEED    = 46.0;   // after the motor has done its work
	const BURN_TICS    = 12;     // about a third of a second of thrust
	const SCATTER_DEG  = 7.0;    // how crooked it leaves -- the spread half-angle
	const STEER_DEG    = 4.5;    // how hard it may turn in one tic, toward anything
	const SEEK_RANGE   = 1400.0;
	const SEEK_CONE    = 22.0;   // it leans toward what you aimed at, not what is behind you

	private Vector3 aimDir;      // the line it was fired along, and the line it returns to
	private Vector3 flyDir;      // where it is actually pointed this tic
	private double  weavePhase, weaveRate, weaveRadius;
	private int     age;
	private Actor   quarry;

	Default
	{
		Projectile;
		Radius 4;
		Height 4;
		Speed 12;
		Damage 0;                // the blast does the work, not the impact
		Scale 0.25;
		RenderStyle "Add";
		Alpha 0.9;
		+FORCEXYBILLBOARD
		+NOEXTREMEDEATH
		Obituary "%o caught a micro-missile.";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		double sp = Vel.Length();
		aimDir = (sp > 0) ? Vel / sp : (cos(Angle) * cos(Pitch), sin(Angle) * cos(Pitch), -sin(Pitch));
		flyDir = aimDir;

		// THE CROOKED LAUNCH. A random direction in a cone around the aim line, applied
		// to the HEADING only -- the missile still knows where it was aimed, which is
		// what lets it come back. Scatter without that memory is just inaccuracy.
		Vector3 r, u;
		Basis(aimDir, r, u);
		double a = FRandom(0, 360), m = FRandom(0, SCATTER_DEG);
		flyDir = (aimDir + (r * cos(a) + u * sin(a)) * tan(m)).Unit();

		// EVERY MISSILE GETS ITS OWN CORKSCREW. Phase so they are not in step, rate so
		// they do not share a frequency, radius so they do not share an amplitude.
		weavePhase  = FRandom(0, 360);
		weaveRate   = FRandom(17.0, 27.0);
		weaveRadius = FRandom(0.10, 0.22);

		Vel = flyDir * LAUNCH_SPEED;
		FaceVelocity();
		quarry = FindQuarry();
	}

	// An orthonormal pair across `d`, for scatter and weave. Picks its reference axis off
	// whichever world axis `d` is least aligned with, so a missile fired straight up does
	// not produce a degenerate basis.
	private static void Basis(Vector3 d, out Vector3 right, out Vector3 up)
	{
		Vector3 ref = (abs(d.z) < 0.9) ? (0.0, 0.0, 1.0) : (1.0, 0.0, 0.0);
		right = (d cross ref).Unit();
		up    = (right cross d).Unit();
	}

	// What it leans toward: the nearest shootable thing inside a narrow cone about the
	// line it was FIRED along -- not about where it is currently pointing, or a weaving
	// missile would chase its own wobble into a wall.
	private Actor FindQuarry() const
	{
		Actor best = null;
		double bestDist = SEEK_RANGE;
		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (a == self || a == target) continue;
			if (!a.bShootable || a.health <= 0 || a.bFriendly) continue;
			Vector3 delta = Vec3To(a);
			double d = delta.Length();
			if (d <= 0 || d > bestDist) continue;
			if (acos(clamp((delta / d) dot aimDir, -1, 1)) > SEEK_CONE) continue;
			if (!CheckSight(a)) continue;
			best = a; bestDist = d;
		}
		return best;
	}

	override void Tick()
	{
		if (isFrozen() || bDestroyed) { Super.Tick(); return; }
		age++;

		// THE MOTOR. Speed climbs over the burn and holds after it.
		double t = (age >= BURN_TICS) ? 1.0 : double(age) / BURN_TICS;
		double speed = LAUNCH_SPEED + (TOP_SPEED - LAUNCH_SPEED) * t;

		// WHERE IT WANTS TO BE POINTED: the aim line, or the quarry if it still has one.
		Vector3 want = aimDir;
		if (quarry)
		{
			if (quarry.health <= 0 || !quarry.bShootable) quarry = null;
			else
			{
				Vector3 delta = Vec3To(quarry);
				delta.z += quarry.Height * 0.5;
				double d = delta.Length();
				if (d > 0) want = delta / d;
			}
		}

		// STEER, CAPPED. A per-tic ceiling on the turn is what keeps this a rocket
		// leaning onto a target instead of a dot glued to one.
		double off = acos(clamp(flyDir dot want, -1, 1));
		if (off > 0.0001)
		{
			double step = min(off, STEER_DEG);
			flyDir = (flyDir * cos(step) + ((want - flyDir * (flyDir dot want)).Unit()) * sin(step)).Unit();
		}

		// THE WEAVE, DECAYING AFTER BURNOUT. While the motor runs it corkscrews; once the
		// motor quits the corkscrew fades over the next dozen tics and it flies straight.
		double decay = (age <= BURN_TICS) ? 1.0 : max(0.0, 1.0 - (age - BURN_TICS) / 12.0);
		Vector3 heading = flyDir;
		if (decay > 0 && weaveRadius > 0)
		{
			Vector3 r, u;
			Basis(flyDir, r, u);
			double ph = weavePhase + age * weaveRate;
			heading = (flyDir + (r * cos(ph) + u * sin(ph)) * (weaveRadius * decay)).Unit();
		}

		Vel = heading * speed;
		FaceVelocity();
		Super.Tick();
	}

	// Point the actor along its flight. Free now, and the day a mesh exists it is the
	// difference between a rocket and a sideways sprite.
	private void FaceVelocity()
	{
		double flat = (Vel.x, Vel.y, 0).Length();
		if (Vel.Length() <= 0) return;
		Angle = atan2(Vel.y, Vel.x);
		Pitch = -atan2(Vel.z, flat);
	}

	States
	{
	Spawn:
		WMPR A 1 Bright;
		Loop;
	Death:
		WMPR A 1 Bright A_Explode(24, 72, 0);
		WMPR A 4;
		Stop;
	}
}
