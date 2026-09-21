// ============================================================================
// THE LIGHTSABER -- a hilt you hold, a blade that stays lit, and bolts that go back where they came.
//
// The owner, 2026-09-21: "i want to use our engine system for a *nice* fuckin lightsaber" -- throw
// it like the shieldsaw, deflect like the shieldsaw, two of them, colours of his choosing, and FIRE
// EXTENDS AND RETRACTS THE BLADE.
//
// BUILT ALONGSIDE THE SHIELDSAW, NOT ON IT. RS_ShieldSaw has no virtual methods, its core is private,
// and its state machine finds the weapon by EXACT class name -- a subclass would never be seen by the
// draw, the throw or the recall. So the pieces that work are COPIED with credit and the shield's
// assumptions (one of them, off hand only, a shoulder mount, a round face) are left behind:
//
//   the hand pose        HandPos / HandAngle / HandPitch, verbatim -- including the +90 and the
//                        negation, which are the engine's storage convention, not fudge factors
//   the deflect          deflect() nearly verbatim; the SWEEP is new, because a blade guards a
//                        LINE and the shield guarded a DISC
//
// WHAT DRAWS IT is rs_lightsaber_world.zs. This file is the weapon: the blade's length, what it
// deflects, what it cuts, and what it sounds like.
//
// THE BLADE IS DRAWN AND THE BLADE IS SIMULATED, AND THEY ARE TWO THINGS. The drawn blade is a model
// placed by the renderer off the controller; the simulated blade is a line from the hand along where
// the controller points, rs_saber_reach map units long. If they disagree in the headset, the reach
// slider brings the simulated one to the drawn one -- the physics was never measured off the mesh,
// because a model's drawn size and a map unit are not the same thing in this fork.
// ============================================================================

class RS_LightsaberBase : Weapon abstract
{
	// HOW FAR THE BLADE IS OUT, 0 folded into the emitter .. EXT_FULL at full length. The world
	// handler shows this as the blade model's frame, so ignition EXTENDS rather than pops.
	const EXT_FULL = 8;

	// ONE FRAME OF BLADE A TIC: 8 tics out, 8 back -- about a quarter second, the films' snap.
	int  ext;
	bool wantLit;

	// THE TIP LAST TIC, for how fast the blade is moving -- which drives the hum's pitch, the swing
	// sound and whether a touch is a cut.
	private Vector3 lastTip;
	private bool    lastTipValid;
	private int     swingQuiet;       // tics until another swing sound may play

	// WHO WAS CUT, AND WHEN. A blade drawn through a monster touches it every tic it passes; without
	// this a slow sweep would hit it thirty-five times a second.
	private Array<Actor> cutWho;
	private Array<int>   cutWhen;

	// A SEGMENT SHORTER THAN THIS IS A POINT, for SegSegDist's degenerate cases.
	const EPS = 0.000001;

	const HUM_CHAN_MAIN = 20;         // own channels, so the hum never cuts off anything else
	const HUM_CHAN_OFF  = 21;

	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 3700;
		Weapon.Kickback 0;
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOAUTOAIM
		Inventory.PickupMessage "A lightsaber!";
		Tag "Lightsaber";
	}

	// ---- EITHER HAND, in one place --------------------------------------------------------------
	// Copied from RS_ShieldSaw. THE +90 AND THE NEGATION ARE NOT FUDGE FACTORS: the engine stores
	// AttackAngle as (viewYaw - 90) and AttackPitch as (-viewPitch) -- hw_vrmodes.cpp:1421 and :1445.
	Vector3 HandPos()
	{
		if (!owner) return (0, 0, 0);
		return bOffhandWeapon ? owner.OffhandPos : owner.AttackPos;
	}
	double HandAngle()
	{
		if (!owner) return 0.0;
		return (bOffhandWeapon ? owner.OffhandAngle : owner.AttackAngle) + 90.0;
	}
	double HandPitch()
	{
		if (!owner) return 0.0;
		return -(bOffhandWeapon ? owner.OffhandPitch : owner.AttackPitch);
	}
	int HandIndex() { return bOffhandWeapon ? 1 : 0; }
	int HumChan()   { return bOffhandWeapon ? HUM_CHAN_OFF : HUM_CHAN_MAIN; }

	// Is this saber actually in a hand right now? A holstered saber retracts.
	bool InHand()
	{
		if (!owner || !owner.player) return false;
		return bOffhandWeapon ? (owner.player.OffhandWeapon == self) : (owner.player.ReadyWeapon == self);
	}

	// ---- SETTINGS -------------------------------------------------------------------------------
	private double FlagF(String n, double fb)
	{
		let c = CVar.GetCVar(n, owner ? owner.player : null);
		return c ? c.GetFloat() : fb;
	}
	int ColorIndex()
	{
		let c = CVar.GetCVar(bOffhandWeapon ? "rs_saber_color_off" : "rs_saber_color",
		                     owner ? owner.player : null);
		return c ? c.GetInt() : 0;
	}
	double Reach() { return FlagF("rs_saber_reach", 48.0); }

	// ---- THE SIMULATED BLADE --------------------------------------------------------------------
	// From the hand, along where the controller points, as far as the blade is out.
	// RETURNS NOTHING IN AN out PARAMETER: `out Vector3` compiles, loads and then faults in play in
	// this engine (the micro-missile). Two functions instead.
	Vector3 BladeDir()
	{
		double a = HandAngle(), p = HandPitch();
		return (cos(p) * cos(a), cos(p) * sin(a), -sin(p));
	}
	double BladeLen() { return Reach() * (ext / double(EXT_FULL)); }

	// ---- FIRE: OUT, OR BACK IN ------------------------------------------------------------------
	action void A_ToggleSaber()
	{
		invoker.wantLit = !invoker.wantLit;
		if (invoker.wantLit)
			A_StartSound("saber/on", invoker.bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
		else
			A_StartSound("saber/off", invoker.bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
	}

	// ---- EVERY TIC, WHILE CARRIED ---------------------------------------------------------------
	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner) return;

		// PUT AWAY, IT RETRACTS. Selecting another weapon folds the blade whatever was asked.
		bool lit = wantLit && InHand();
		if (lit  && ext < EXT_FULL) ext++;
		if (!lit && ext > 0)        ext--;

		if (ext <= 0)
		{
			owner.A_StopSound(HumChan());
			lastTipValid = false;
			return;
		}

		Vector3 base = HandPos();
		Vector3 dir = BladeDir();
		double len = BladeLen();
		Vector3 tip = base + dir * len;

		// HOW FAST THE BLADE IS MOVING, measured at the tip, where it moves most.
		double tipSpeed = lastTipValid ? (tip - lastTip).Length() : 0.0;
		lastTip = tip;
		lastTipValid = true;

		Hum(tipSpeed);
		Swing(tipSpeed);
		SweepDeflect(base, dir, len);
		Cut(base, dir, len, tipSpeed);
	}

	// THE HUM, AND IT RISES WITH THE SWING. The single thing that makes a lightsaber sound like one:
	// the drone lifts in pitch as the blade moves, and settles when it stops.
	private void Hum(double tipSpeed)
	{
		int ch = HumChan();
		if (!owner.IsActorPlayingSound(ch))
			owner.A_StartSound("saber/hum", ch, CHANF_LOOPING, 0.6);
		double pitchUp = 1.0 + clamp(tipSpeed / 40.0, 0.0, 0.6);
		owner.A_SoundPitch(ch, pitchUp);
	}

	private void Swing(double tipSpeed)
	{
		if (swingQuiet > 0) { swingQuiet--; return; }
		if (tipSpeed < FlagF("rs_saber_swing_min", 14.0)) return;
		owner.A_StartSound("saber/swing", bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
		swingQuiet = 9;
	}

	// ---- DEFLECT: A BLADE GUARDS A LINE ---------------------------------------------------------
	//
	// NEW, BECAUSE THE SHIELD'S TEST DOES NOT FIT. The shield caught a missile crossing a DISC. A
	// blade is a line segment, so the test is the closest approach between two segments this tic:
	// where the missile goes (its position to its position plus its velocity) and where the blade is.
	// Within the blade's thickness plus the missile's radius, it is caught.
	private void SweepDeflect(Vector3 base, Vector3 dir, double len)
	{
		double thick = FlagF("rs_saber_thickness", 6.0);
		Vector3 mid = base + dir * (len * 0.5);
		double reach = len * 0.5 + thick + 48.0;

		BlockThingsIterator it = BlockThingsIterator.CreateFromPos(
			mid.x, mid.y, mid.z - reach, reach * 2.0, reach, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || !mo.bMissile || mo.bNoInteraction || mo.bNoClip) continue;
			// YOURS PASSES. Once turned, a missile's target IS you -- which is also what stops it
			// being caught again on its way back out.
			if (mo == owner || mo.target == owner || mo.master == owner) continue;
			if (mo is "RS_ShieldInFlight") continue;

			// Both segments relative to the blade's base, so portals do not break the arithmetic.
			Vector3 p0 = Level.Vec3Diff(base, mo.Pos);
			double d = SegSegDist(p0, mo.Vel, dir * len);
			if (d > thick + mo.radius) continue;

			Deflect(mo, dir);
		}
	}

	// THE CLOSEST TWO SEGMENTS COME. Segment A: a0 .. a0+da. Segment B: origin .. db.
	// Ericson, Real-Time Collision Detection, 5.1.9 -- the standard form, with its degenerate cases.
	static double SegSegDist(Vector3 a0, Vector3 da, Vector3 db)
	{
		Vector3 r = a0;                  // a0 - b0, with b0 at the origin
		double a = da dot da;
		double e = db dot db;
		double f = db dot r;
		double s = 0, t = 0;

		if (a <= EPS && e <= EPS) return r.Length();
		if (a <= EPS)
		{
			t = clamp(f / e, 0.0, 1.0);
		}
		else
		{
			double c = da dot r;
			if (e <= EPS)
			{
				s = clamp(-c / a, 0.0, 1.0);
			}
			else
			{
				double b = da dot db;
				double denom = a * e - b * b;
				s = (denom != 0) ? clamp((b * f - c * e) / denom, 0.0, 1.0) : 0.0;
				t = (b * s + f) / e;
				if (t < 0)      { t = 0; s = clamp(-c / a, 0.0, 1.0); }
				else if (t > 1) { t = 1; s = clamp((b - c) / a, 0.0, 1.0); }
			}
		}
		Vector3 ca = a0 + da * s;
		Vector3 cb = db * t;
		return (ca - cb).Length();
	}

	// TURNED, NOT EATEN. Copied from RS_ShieldSaw.deflect, with one change: the mirror is off the
	// BLADE, so its normal is the part of the incoming direction that is square to the blade.
	private void Deflect(Actor mo, Vector3 bladeDir)
	{
		Actor shooter = mo.target;
		Vector3 came = (mo.Vel.Length() > 0.0001) ? mo.Vel.Unit() : -bladeDir;

		// THE FACE THE MISSILE MET: square to the blade, pointing back at where it came from.
		Vector3 n = -came;
		n = n - bladeDir * (n dot bladeDir);
		n = (n.Length() > 0.0001) ? n.Unit() : -came;

		mo.target = owner;
		if (mo.bSeekerMissile) mo.tracer = shooter;

		double sp = max(mo.Speed, mo.Vel.Length());
		if (sp <= 0) sp = 10.0;

		// BACK AT WHOEVER FIRED IT while they are standing -- the films' whole point -- and mirrored
		// off the blade otherwise.
		Vector3 dir;
		if (shooter && shooter.health > 0 && shooter != owner)
			dir = Level.Vec3Diff(mo.Pos, (shooter.pos.xy, shooter.pos.z + shooter.height * 0.5));
		else
			dir = mo.Vel - n * (2.0 * (mo.Vel dot n));
		if (dir.Length() < 0.0001) dir = n;
		dir = dir.Unit();

		mo.Vel = dir * sp;
		mo.A_SetAngle(VectorAngle(dir.x, dir.y), SPF_INTERPOLATE);
		mo.pitch = -asin(clamp(dir.z, -1.0, 1.0));

		owner.A_StartSound("saber/deflect", CHAN_BODY);

		// THE LOOK IS BALLISTICS', off the missile, exactly as the shield chooses it. `true` is
		// inAirToo: a deflection happens in open air and nothing draws without it.
		String what = "deflect_energy";
		if (mo is "RSB_Bullet")            what = "deflect_bullet";
		else if (mo.DamageType == 'Fire')  what = "deflect_fire";
		RSB_Impact.Land(mo, what, came, true);

		if (owner.PlayerNumber() == consoleplayer)
			level.VRHaptic(HandIndex(), 0.8, 45.0);
	}

	// ---- CUT: WHATEVER THE BLADE PASSES THROUGH, WHILE IT IS MOVING ------------------------------
	//
	// GATED ON SPEED. A lit blade resting against a monster is not a strike; a swing through one is.
	// Damage rises with how fast the tip is moving, and each thing can be cut again only after a
	// short gap, so a slow drag does not become a blender.
	private void Cut(Vector3 base, Vector3 dir, double len, double tipSpeed)
	{
		if (tipSpeed < FlagF("rs_saber_cut_min", 6.0)) return;

		double thick = FlagF("rs_saber_thickness", 6.0);
		Vector3 mid = base + dir * (len * 0.5);
		double reach = len * 0.5 + thick + 64.0;

		BlockThingsIterator it = BlockThingsIterator.CreateFromPos(
			mid.x, mid.y, mid.z - reach, reach * 2.0, reach, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || mo == owner || !mo.bShootable || mo.health <= 0) continue;
			if (mo.bFriendly && owner.player) continue;
			if (!CutReady(mo)) continue;

			// THE NEAREST POINT OF THE BLADE TO THE THING'S MIDDLE, and is that inside it?
			Vector3 c = Level.Vec3Diff(base, (mo.pos.xy, mo.pos.z + mo.height * 0.5));
			Vector3 blade = dir * len;
			double t = (len > 0.0001) ? clamp((c dot blade) / (len * len), 0.0, 1.0) : 0.0;
			Vector3 nearest = blade * t;
			Vector3 gap = c - nearest;
			if ((gap.xy).Length() > mo.radius + thick) continue;
			if (abs(gap.z) > mo.height * 0.5 + thick) continue;

			int dmg = int(FlagF("rs_saber_damage", 40.0) * clamp(tipSpeed / 20.0, 0.5, 2.5));
			mo.DamageMobj(self, owner, dmg, 'Saber', DMG_THRUSTLESS);
			owner.A_StartSound(mo.bNoBlood ? "saber/hitwall" : "saber/hit", CHAN_BODY);
			MarkCut(mo);

			if (owner.PlayerNumber() == consoleplayer)
				level.VRHaptic(HandIndex(), 1.0, 60.0);
		}
	}

	private bool CutReady(Actor mo)
	{
		int i = cutWho.Find(mo);
		return i == cutWho.Size() || (level.maptime - cutWhen[i]) > 8;
	}
	private void MarkCut(Actor mo)
	{
		int i = cutWho.Find(mo);
		if (i == cutWho.Size()) { cutWho.Push(mo); cutWhen.Push(level.maptime); }
		else cutWhen[i] = level.maptime;
		// Forget the dead and the gone, so the list cannot grow for a whole map.
		for (int k = cutWho.Size() - 1; k >= 0; k--)
		{
			if (!cutWho[k] || cutWho[k].health <= 0)
			{
				cutWho.Delete(k);
				cutWhen.Delete(k);
			}
		}
	}

	// ---- STATES ---------------------------------------------------------------------------------
	// THE PSPRITE DRAWS NOTHING. SBLD is a one-pixel placeholder and no MODELDEF names this class on
	// SBLD, so the hand shows only the world props the handler places. The FLOOR pickup is SBLP,
	// which MODELDEF does draw as the hilt.
	States
	{
	Spawn:
		SBLP A -1;
		stop;
	Select:
		SBLD A 1 A_Raise;
		loop;
	Deselect:
		SBLD A 1 A_Lower;
		loop;
	Ready:
		SBLD A 1 A_WeaponReady;
		loop;
	Fire:
		// OUT, OR BACK IN -- and held off for a moment, so one press is one toggle.
		SBLD A 1 A_ToggleSaber;
		SBLD A 12;
		goto Ready;
	}
}

// THE TWO HANDS. The owner wants two of these; each hand has its own colour.
class RS_Lightsaber : RS_LightsaberBase {}

class RS_LightsaberOff : RS_LightsaberBase
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 3701;
	}
}
