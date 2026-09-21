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
// THE BLADE THAT HITS IS THE BLADE YOU SEE. The drawn blade is a model placed by the renderer off the
// controller; the simulated blade is a line from the hilt along where the controller points. They
// are built from the SAME numbers (RS_SaberGeom: the mesh and the scale the MODELDEF draws at), times
// the placement Size slider -- so their length, their width, and where each leaves the hilt agree by
// construction rather than by a slider somebody tuned to make them match.
// ============================================================================

class RS_LightsaberBase : Weapon abstract
{
	// HOW FAR THE BLADE IS OUT, 0 folded into the emitter .. EXT_FULL at full length. The world
	// handler shows this as the blade model's frame, so ignition EXTENDS rather than pops.
	const EXT_FULL = 8;

	// ONE FRAME OF BLADE A TIC: 8 tics out, 8 back -- about a quarter second, the films' snap.
	int  ext;
	bool wantLit;

	// THE SECOND BLADE, out of the pommel -- ALT FIRE. The double-bladed saber (the owner,
	// 2026-09-21: "secondary fire spawns a blade from the hilt, same length and color"). Extends and
	// retracts exactly as the first, on its own count.
	int  extBack;
	bool wantBack;

	// THE TIP LAST TIC, for how fast the blade is moving -- which drives the hum's pitch, the swing
	// sound and whether a touch is a cut.
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
	// THE BACK BLADE'S COLOUR: its own if set, the front's if not (-1).
	int BackColorIndex()
	{
		let c = CVar.GetCVar(bOffhandWeapon ? "rs_saber_color_back_off" : "rs_saber_color_back",
		                     owner ? owner.player : null);
		int v = c ? c.GetInt() : -1;
		return (v >= 0) ? v : ColorIndex();
	}
	// ---- THE BLADE THAT HITS IS THE BLADE YOU SEE -----------------------------------------------
	//
	// The owner, 2026-09-21: "i'd like the detection to be as wide as the beam for as much realism
	// as we can get with a lightsaber". This used to be two sliders, reach and thickness, set by hand
	// to agree with a blade drawn from different numbers. Now every dimension below is the DRAWN
	// blade's own (RS_SaberGeom, generated from the same mesh and scale the MODELDEF draws), times the
	// placement Size slider -- which scales the drawn model by the very same factor. Resize the saber
	// and the blade that hits resizes with it.
	double SizeScale()
	{
		let c = CVar.GetCVar(bOffhandWeapon ? "rs_saber_off_scale" : "rs_saber_scale",
		                     owner ? owner.player : null);
		double s = c ? c.GetFloat() : 1.0;
		return (s > 0) ? s : 1.0;       // the renderer ignores zero and below, so does this
	}
	double Thickness() { return RS_SaberGeom.RADIUS * SizeScale(); }

	// ---- THE SIMULATED BLADES -------------------------------------------------------------------
	// Along where the controller points. RETURNS NOTHING IN AN out PARAMETER: `out Vector3` compiles,
	// loads and then faults in play in this engine (the micro-missile). One function per value.
	Vector3 BladeDir()
	{
		double a = HandAngle(), p = HandPitch();
		return (cos(p) * cos(a), cos(p) * sin(a), -sin(p));
	}

	// THE FRONT BLADE leaves the emitter, ahead of the grip.
	Vector3 FrontBase() { return HandPos() + BladeDir() * (RS_SaberGeom.EMITTER * SizeScale()); }
	double  FrontLen()  { return RS_SaberGeom.LENGTH * SizeScale() * (ext / double(EXT_FULL)); }
	Vector3 FrontMid()  { return FrontBase() + BladeDir() * (FrontLen() * 0.5); }

	// THE BACK BLADE -- ALT FIRE -- leaves the pommel, behind the grip, pointing the other way.
	Vector3 BackBase()  { return HandPos() - BladeDir() * (RS_SaberGeom.POMMEL * SizeScale()); }
	double  BackLen()   { return RS_SaberGeom.LENGTH * SizeScale() * (extBack / double(EXT_FULL)); }
	Vector3 BackMid()   { return BackBase() - BladeDir() * (BackLen() * 0.5); }

	// ---- FIRE: OUT, OR BACK IN ------------------------------------------------------------------
	action void A_ToggleSaber()
	{
		invoker.wantLit = !invoker.wantLit;
		if (invoker.wantLit)
			A_StartSound("saber/on", invoker.bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
		else
			A_StartSound("saber/off", invoker.bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
	}

	// ---- ALT FIRE: THE SECOND BLADE, OUT OF THE POMMEL, OR BACK IN -------------------------------
	action void A_ToggleBack()
	{
		invoker.wantBack = !invoker.wantBack;
		A_StartSound(invoker.wantBack ? "saber/on" : "saber/off",
			invoker.bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
	}

	// ---- THE THROW ------------------------------------------------------------------------------
	//
	// THE FLYING SABER, while it is out of the hand. Null means it is in the hand. A destroyed actor's
	// reference reads null by itself, so a saber lost to a map change is simply back in the hand.
	Actor thrown;
	bool IsThrown() { return thrown != null; }

	double ThrowDamage() { return FlagF("rs_saber_throw_damage", 1.0); }

	// WHAT THE THROW SERVICE MEASURED AT RELEASE -- the peak of the hand's motion, not its speed at
	// the instant the fingers opened, which is already slowing. Copied from RS_ShieldSaw. Asked once,
	// on the thrower's own machine; the answer travels in the net event to every machine alike.
	static Vector3 MeasureRelease(PlayerPawn pmo, int hand)
	{
		ServiceIterator it = ServiceIterator.Find("RS_ThrowService");
		Service sv;
		while (sv = it.Next())
		{
			if (sv.GetInt("throw.hello", "", 0, 0, null, 'None') != 1) continue;
			double mx = sv.GetInt("throw.vel.x", "", hand, 0, pmo, 'RS_Lightsaber');
			double my = sv.GetInt("throw.vel.y", "", hand, 0, pmo, 'RS_Lightsaber');
			double mz = sv.GetInt("throw.vel.z", "", hand, 0, pmo, 'RS_Lightsaber');
			return (mx, my, mz);
		}
		return (0, 0, 0);
	}

	// HOW FAST IT SPINS: always -- a thrown saber that does not spin reads as slid, not thrown -- and
	// faster with a flick of the wrist. The flick is the hand's YAW rate at release, because a flat
	// spin is a frisbee's and a frisbee is thrown with a sideways flick. Its sign picks the direction.
	private double SpinRate()
	{
		double wrist = 0;
		ServiceIterator it = ServiceIterator.Find("RS_ThrowService");
		Service sv;
		while (sv = it.Next())
		{
			if (sv.GetInt("throw.hello", "", 0, 0, null, 'None') != 1) continue;
			wrist = sv.GetInt("throw.spin.yaw", "", HandIndex(), 0, owner, 'RS_Lightsaber') / 1000.0;
			break;
		}
		double least = FlagF("rs_saber_spin_base", 32.0);      // degrees a tic: ~3 turns a second
		double sign = (wrist < 0) ? -1.0 : 1.0;
		return sign * max(abs(wrist) * FlagF("rs_saber_spin_scale", 1.0), least);
	}

	// CAPTAIN AMERICA: the nearest living enemies in a cone ahead of the throw, nearest first. The
	// shield flies a route you painted; the saber has no painting gesture, so it finds its own.
	private void AcquireRoute(RS_SaberInFlight f, Vector3 dir)
	{
		int most = int(FlagF("rs_saber_throw_targets", 3.0));
		if (most <= 0) return;
		double range = FlagF("rs_saber_throw_range", 1024.0);
		double coneCos = cos(FlagF("rs_saber_throw_cone", 30.0));

		Array<Actor> who;
		Array<double> far;
		BlockThingsIterator it = BlockThingsIterator.Create(owner, range);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || mo == owner || !mo.bIsMonster || !mo.bShootable || mo.health <= 0) continue;
			if (mo.bFriendly) continue;
			Vector3 to = Level.Vec3Diff(HandPos(), (mo.pos.xy, mo.pos.z + mo.height * 0.5));
			double d = to.Length();
			if (d < 1.0 || d > range) continue;
			if (((to / d) dot dir) < coneCos) continue;
			if (!owner.CheckSight(mo)) continue;
			// nearest first: insertion into a short list
			int at = 0;
			while (at < far.Size() && far[at] < d) at++;
			who.Insert(at, mo);
			far.Insert(at, d);
		}
		for (int i = 0; i < who.Size() && i < most; i++)
			f.route.Push(who[i]);
	}

	// OUT OF THE HAND. Called on every machine from the net event, with the release velocity the
	// thrower's machine measured.
	void Throw(Vector3 rel)
	{
		if (!owner || !owner.player || thrown) return;

		// THE DIRECTION IS THE HAND'S; THE SPEED IS THE SABER'S. The service measures in thousandths
		// on one path and map units on another, and the direction is the same in both -- so the
		// direction is taken and the magnitude is not trusted. A throw that went twice as fast on a
		// hard flick is the next thing to tune, not something to guess the units for.
		Vector3 dir = (rel.Length() > 0.001) ? rel.Unit() : BladeDir();

		int alflags = bOffhandWeapon ? ALF_ISOFFHAND : 0;
		Actor mo = owner.SpawnPlayerMissile("RS_SaberInFlight", aimflags: alflags);
		let f = RS_SaberInFlight(mo);
		if (!f)
		{
			if (mo) mo.Destroy();
			return;
		}
		f.master = owner;
		f.target = owner;
		f.launcher = self;
		f.hand = HandIndex();
		f.bladeColor = ColorIndex();
		f.backLit = (extBack > 0);
		f.backColor = BackColorIndex();
		f.size = SizeScale();
		f.vel = dir * f.Speed;
		f.SetPlane(dir, bOffhandWeapon ? owner.OffhandRoll : owner.MainHandRoll);
		f.spinRate = SpinRate();
		AcquireRoute(f, dir);
		f.Launch();

		thrown = f;
		wantLit = true;
		owner.A_StopSound(HumChan());
		owner.A_StartSound("saber/swing", bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON);
		owner.A_AlertMonsters(640);
		if (owner.PlayerNumber() == consoleplayer)
			level.VRHaptic(HandIndex(), 0.8, 60.0);
	}

	// BACK IN THE HAND, AND STILL LIT -- it was lit when it left, and a caught saber that has to be
	// re-ignited is not a catch.
	void Caught()
	{
		thrown = null;
		wantLit = true;
		ext = EXT_FULL;
		if (wantBack) extBack = EXT_FULL;
		ResetTips();
		if (!owner) return;
		owner.A_StartSound("saber/deflect", bOffhandWeapon ? CHAN_OFFWEAPON : CHAN_WEAPON, 0, 0.6);
		if (owner.PlayerNumber() == consoleplayer)
			level.VRHaptic(HandIndex(), 1.0, 70.0);
	}

	// ---- EVERY TIC, WHILE CARRIED ---------------------------------------------------------------
	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner) return;

		// IN THE AIR, NOT IN THE HAND: the flying saber does the humming, the cutting and the
		// deflecting-by-ripping, and nothing is drawn in the hand until it is caught.
		if (thrown)
		{
			owner.A_StopSound(HumChan());
			ResetTips();
			return;
		}

		// PUT AWAY, IT RETRACTS -- both blades. Selecting another weapon folds them whatever was asked.
		bool inHand = InHand();
		bool lit  = wantLit  && inHand;
		bool litB = wantBack && inHand;
		if (lit   && ext < EXT_FULL)     ext++;
		if (!lit  && ext > 0)            ext--;
		if (litB  && extBack < EXT_FULL) extBack++;
		if (!litB && extBack > 0)        extBack--;

		if (ext <= 0 && extBack <= 0)
		{
			owner.A_StopSound(HumChan());
			ResetTips();
			return;
		}

		// EACH BLADE FROM ITS REAL GEOMETRY -- where it leaves the hilt, how long it is, how wide it
		// detects -- the same numbers it is DRAWN from. What hits is what you see.
		double thick = Thickness();
		Vector3 dir = BladeDir();
		double speed = 0;

		if (ext > 0)
		{
			Vector3 b0 = FrontBase();
			double len = FrontLen();
			speed = max(speed, TipSpeed(b0 + dir * len, 0));
			SweepDeflect(b0, dir, len, thick);
			Cut(b0, dir, len, speed, thick);
		}
		if (extBack > 0)
		{
			Vector3 bdir = -dir;
			Vector3 b0 = BackBase();
			double len = BackLen();
			speed = max(speed, TipSpeed(b0 + bdir * len, 1));
			SweepDeflect(b0, bdir, len, thick);
			Cut(b0, bdir, len, speed, thick);
		}

		Hum(speed);
		Swing(speed);
	}

	// HOW FAST A BLADE'S TIP IS MOVING, per blade, since the last tic -- where the blade moves most.
	private Vector3 lastTips[2];
	private bool    lastTipsValid[2];
	private void ResetTips() { lastTipsValid[0] = false; lastTipsValid[1] = false; }
	private double TipSpeed(Vector3 tip, int which)
	{
		double s = lastTipsValid[which] ? (tip - lastTips[which]).Length() : 0.0;
		lastTips[which] = tip;
		lastTipsValid[which] = true;
		return s;
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
	// NOT PRIVATE: the thrown saber sweeps its spinning blades through this same test.
	void SweepDeflect(Vector3 base, Vector3 dir, double len, double thick)
	{
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
	// NOT PRIVATE: the thrown saber cuts with its spinning blades through this same test.
	void Cut(Vector3 base, Vector3 dir, double len, double tipSpeed, double thick)
	{
		if (tipSpeed < FlagF("rs_saber_cut_min", 6.0)) return;

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
	AltFire:
		// THE SECOND BLADE, out of the pommel: the double-bladed saber.
		SBLD A 1 A_ToggleBack;
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
