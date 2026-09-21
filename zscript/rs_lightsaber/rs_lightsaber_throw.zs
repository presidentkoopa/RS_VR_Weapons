// ============================================================================
// THE THROWN LIGHTSABER -- Captain America's shield, with a lit blade.
//
// The owner, 2026-09-21: throw it "like the shieldsaw", "captain america lightsaber", and "give it a
// nice horizontal plane spin which respects the angle at which it was thrown".
//
// ADAPTED FROM RS_ShieldInFlight, with credit, and changed in exactly three places:
//
//   1. IT RICOCHETS THROUGH WHAT IT FINDS. The shield flies a route of targets you PAINTED while
//      holding it. The saber has no painting gesture, so at launch it takes the nearest living
//      enemies in a cone ahead of the throw -- up to rs_saber_throw_targets -- and flies them in
//      order, cutting through each, before it comes home. That is the Captain America part.
//
//   2. IT SPINS IN A PLANE, NOT ON AN AXIS OF ITS OWN. See Tick: the blade's direction is computed
//      every tic inside a plane tilted by your wrist's roll at release. The shield spins with
//      pitch-under-roll, which suits a DISC; a stick spun the same way wobbles, because Euler angles
//      tilt the axis along with the spin. So the stick is simply POINTED, each tic, where the spin
//      says it is -- and the plane stays exactly where you threw it.
//
//   3. IT IS CAUGHT. The shield comes home, vanishes and reappears on your shoulder. The saber lands
//      back in the hand that threw it, still lit.
//
// THE FLYING SABER DOES NOT FACE WHERE IT IS GOING. The shield turns its angle toward each target
// (aimAt, A_SetAngle), which would fight the spin every four tics. The saber's heading is its
// VELOCITY alone; its angle and pitch belong to the spin.
// ============================================================================

class RS_SaberInFlight : Actor
{
	Array<Actor> route;
	int          leg;
	bool         homing;
	RS_LightsaberBase launcher;
	int          hand;
	int          bladeColor;
	bool         backLit;       // thrown double-bladed: the pommel blade flies too -- the Maul throw
	int          backColor;
	double       size;          // the placement Size it left the hand at, so it is the same saber

	// THE SPIN PLANE, fixed at release: `heading` is the throw's horizontal direction and `side` is
	// the perpendicular in that plane, already tilted by the wrist. The blade points along
	// cos(phase) * heading + sin(phase) * side.
	Vector3 heading, side;
	double  spinRate;
	private double spinPhase;

	private int     stalled;
	private int     age;
	private int     noclipFor;
	private bool    legHit;
	private int     outbound;
	private Array<Actor> cutThisLeg;
	private Vector3 prevPos;

	// THE BLADE, RIDING THE HILT. A model has one render style: the hilt is solid metal and the blade
	// is additive light, so the blade is its own actor, turned to the same spin every tic.
	private Actor blade;
	private Actor backBlade;

	Default
	{
		Speed 26;
		Radius 10;
		Height 10;
		Projectile;
		DamageFunction (1);
		DamageType "Saber";
		BounceType "Doom";
		BounceFactor 1.0;
		BounceCount 4;              // off the walls -- the shield's ricochet
		+RIPPER
		+USEBOUNCESTATE
		+NOEXTREMEDEATH
		+DONTSPLASH
		Obituary "%o was cut down by a thrown lightsaber.";
	}

	// THE PLANE, from where it was thrown and how the wrist was turned. Roll 0 lies flat -- a
	// helicopter's spin. A turned wrist tilts the whole plane about the direction of travel.
	void SetPlane(Vector3 travel, double wristRoll)
	{
		Vector2 h2 = travel.xy;
		if (h2.Length() < 0.001) h2 = (cos(angle), sin(angle));
		h2 = h2.Unit();
		heading = (h2.x, h2.y, 0);
		Vector3 flatSide = (-h2.y, h2.x, 0);
		side = flatSide * cos(wristRoll) + (0, 0, 1) * sin(wristRoll);
	}

	void Launch()
	{
		leg = 0;
		homing = false;
		legHit = false;
		spinPhase = 0;
		cutThisLeg.Clear();
		A_StartSound("saber/hum", CHAN_BODY, CHANF_LOOPING, 0.7);
		blade = Actor.Spawn(RS_SaberColors.FlightClassFor(bladeColor), pos, NO_REPLACE);
		if (backLit)
			backBlade = Actor.Spawn(RS_SaberColors.FlightBackClassFor(backColor), pos, NO_REPLACE);
		if (route.Size() > 0) { aimAt(route[0]); return; }
		outbound = 28;
	}

	// TOWARD A TARGET, BY VELOCITY ONLY -- the angle is the spin's.
	private void aimAt(Actor t)
	{
		if (!t) { GoHome(); return; }
		Vector3 to = Level.Vec3Diff(pos, (t.pos.xy, t.pos.z + t.height * 0.5));
		double d = to.Length();
		if (d < 0.001) return;
		vel = to / d * Speed;
	}

	private void advance()
	{
		cutThisLeg.Clear();
		leg++;
		while (leg < route.Size())
		{
			Actor t = route[leg];
			if (t && t.health > 0 && t.bShootable) { aimAt(t); return; }
			leg++;
		}
		GoHome();
	}

	void GoHome()
	{
		if (homing) return;
		cutThisLeg.Clear();
		homing = true;
		ClearBounce();
		steerHome();
	}

	// HOME IS THE HAND THAT THREW IT -- read from the launcher every tic, so it finds the hand where
	// the hand has moved to, not where it was.
	Vector3 homePoint()
	{
		if (launcher) return launcher.HandPos();
		return (master.pos.xy, master.pos.z + master.height * 0.75);
	}

	private void steerHome()
	{
		if (!master) { Destroy(); return; }
		Vector3 to = Level.Vec3Diff(pos, homePoint());
		double d = to.Length();
		if (d < 0.001) return;
		vel = to / d * (Speed * 1.5);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;

		// THE SPIN, IN THE PLANE. The blade's direction this tic, then the stick pointed along it.
		spinPhase += spinRate;
		Vector3 b = heading * cos(spinPhase) + side * sin(spinPhase);
		angle = VectorAngle(b.x, b.y);
		pitch = -asin(clamp(b.z, -1.0, 1.0));
		roll  = 0;
		if (blade)
		{
			blade.SetOrigin(pos, true);
			blade.angle = angle;
			blade.pitch = pitch;
			blade.roll  = 0;
		}
		if (backBlade)
		{
			backBlade.SetOrigin(pos, true);
			backBlade.angle = angle;
			backBlade.pitch = pitch;
			backBlade.roll  = 0;
		}

		// THE SPINNING BLADES CUT AND DEFLECT -- along their whole length and as wide as the beam,
		// the same test the held saber uses and the same numbers it is drawn from. A thrown saber
		// is a spinning DISC of blade; its small body was never what should hit. It is always
		// moving fast, so the speed gate on a cut is simply passed.
		if (launcher)
		{
			double sz = (size > 0) ? size : 1.0;
			double len = RS_SaberGeom.LENGTH * sz;
			double th  = RS_SaberGeom.RADIUS * sz;
			Vector3 f0 = pos + b * (RS_SaberGeom.EMITTER * sz);
			launcher.SweepDeflect(f0, b, len, th);
			launcher.Cut(f0, b, len, 1000.0, th);
			if (backLit)
			{
				Vector3 k0 = pos - b * (RS_SaberGeom.POMMEL * sz);
				launcher.SweepDeflect(k0, -b, len, th);
				launcher.Cut(k0, -b, len, 1000.0, th);
			}
		}

		if (!master) { Destroy(); return; }

		if (homing)
		{
			steerHome();
			if (Level.Vec3Diff(pos, homePoint()).Length() < max(32.0, vel.Length() * 1.2))
			{
				Caught();
				return;
			}
		}
		else if (leg < route.Size())
		{
			Actor t = route[leg];
			// REACHED WHEN THE BLADES REACH IT: they sweep a disc as wide as the blade is long.
			double sz = (size > 0) ? size : 1.0;
			double reach = t ? (t.radius + RS_SaberGeom.LENGTH * sz * 0.6) : 32.0;
			if (!t || t.health <= 0 || legHit || Distance3D(t) < reach)
			{
				legHit = false;
				advance();
			}
			else if (level.time % 4 == 0) aimAt(t);
		}
		else if (outbound > 0) outbound--;
		else GoHome();

		// STUCK IN A WALL: walk it home through the geometry. The shield's fix, unchanged.
		bool moved = Level.Vec3Diff(pos, prevPos).Length() >= 2.0;
		if (!moved) stalled++; else stalled = 0;
		if (stalled > 6) { stalled = 0; bNOCLIP = true; noclipFor = 20; GoHome(); }
		if (bNOCLIP)
		{
			if (noclipFor > 0) noclipFor--;
			else if (moved) bNOCLIP = false;
		}

		// A SABER THAT NEVER COMES BACK IS A SABER LOST FOR THE MAP. Twelve seconds, then it is in
		// your hand regardless.
		if (++age > 35 * 12) { Caught(); return; }
		prevPos = pos;
	}

	override void OnDestroy()
	{
		if (blade) { blade.Destroy(); blade = null; }
		if (backBlade) { backBlade.Destroy(); backBlade = null; }
		Super.OnDestroy();
	}

	// BACK IN THE HAND, LIT.
	private void Caught()
	{
		A_StopSound(CHAN_BODY);
		if (launcher) launcher.Caught();
		Destroy();
	}

	// ONCE PER TARGET PER LEG. It rips through, so without this a monster it passes through takes
	// a hit every tic it is inside it.
	// THE BODY DOES NOT CUT -- THE BLADES DO (Tick, through the launcher's own test). Letting the
	// hilt rip as well would hit a monster twice in one tic. It still passes through them (RIPPER);
	// it just leaves the hurting to the part of a lightsaber that hurts.
	override int DoSpecialDamage(Actor victim, int damage, Name damagetype)
	{
		return -1;
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name meansofdeath)
	{
		GoHome();
	}

	States
	{
	Spawn:
		SBLT A 1 Bright;
		loop;
	Bounce:
		SBLT A 0 A_StartSound("saber/hitwall", CHAN_6);
		goto Spawn;
	Death:
	Crash:
		SBLT A 0 { GoHome(); }
		goto Spawn;
	}
}

// THE FLYING BLADE. Additive light riding the spinning hilt; one class per colour, generated
// (rs_lightsaber_blades.zs), each wearing its own skins -- exactly as the held blades do.
class RS_SaberFlyBladeProp : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "Add";
		Alpha 1.0;
	}
	States
	{
	Spawn:
		SBLT A -1 Bright;
		stop;
	}
}
