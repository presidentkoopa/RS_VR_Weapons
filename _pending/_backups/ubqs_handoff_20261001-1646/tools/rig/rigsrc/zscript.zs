version "4.10"

// ==========================================================================================================
// UBQS TEST RIG -- NOT SHIPPED. Holds the two UltraBadassQuestSaber sabers in scripted poses on a PC with no
// headset, so the world layer (glow dots, lights, clash sparks / lightning / LockGlow) can be screenshotted.
// Needs the saber's TEST RIG HOOK (UBQS_SaberBase.rigPose/rigPos/rigAngle/rigPitch/rigRoll); run_rig.sh
// patches it into a temporary copy of the saber pk3.
//
// rig_phase: 0 off   1 idle, apart   2 "+" (main horizontal across the off hand's vertical blade, mid-blade)
//            3 "X"   4 swing (main hand sweeps +-50 deg in the screen plane, off hand still)
// Each phase change restarts the phase clock; phases 2/3 approach for 8 tics then hold crossed.
// ==========================================================================================================

class UBQSRig_StandIn : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+INTERPOLATEANGLES
		+DONTSPLASH
		RenderStyle "Normal";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		RGBS A -1;
		Stop;
	AllSprites:
		RGBS AB 0; RGGS AB 0; RGRS AB 0; RGPS AB 0; RGYS AB 0; RGOS AB 0; RGCS AB 0; RGWS AB 0;
		Stop;
	}
}

class UBQSRig_Handler : EventHandler
{
	int phase, phaseStart, lastLight;
	bool placed;
	UBQSRig_StandIn standIn[2];
	double eyeZ;
	Vector3 lastSb;
	bool haveSb;
	Vector3 eye, fwd, rgt, upv;

	static int CI(String n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }
	static double CF(String n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }

	// ---- the room: dark, the player a set distance from a wall, facing it --------------------------------
	void Place(PlayerPawn mo)
	{
		double bestA = mo.angle, bestD = 0;
		for (int i = 0; i < 16; i++)
		{
			double a = mo.angle + i * 22.5;
			FLineTraceData t;
			mo.LineTrace(a, 4096, 0, TRF_THRUACTORS, mo.player.viewheight, data: t);
			if (t.HitType != TRACE_HitWall) continue;
			double d = t.Distance;
			// a wall comfortably far (room to stand back), not the far end of a hall
			double score = (d >= 180 && d <= 900) ? 1000 - abs(d - 300) : d * 0.1;
			if (score > bestD) { bestD = score; bestA = a; }
		}
		FLineTraceData t;
		mo.LineTrace(bestA, 4096, 0, TRF_THRUACTORS, mo.player.viewheight, data: t);
		double back = clamp(t.Distance - 112.0, 0.0, 4096.0);
		Vector2 xy = mo.pos.xy + (cos(bestA), sin(bestA)) * back;
		double fz = level.PointInSector(xy).floorplane.ZAtPoint(xy);
		mo.SetOrigin((xy, fz), false);
		mo.angle = bestA;
		mo.pitch = 0;
		mo.vel = (0, 0, 0);
		Console.PrintfEx(PRINT_LOG, "UBQSRIG placed at %.0f %.0f %.0f facing %.0f, wall %.0f ahead", xy.x, xy.y, fz, bestA, t.Distance - back);
	}

	// ---- the solver: a hand pose whose blade (as the saber's own BladeDir/BladeBase compute it) starts at
	// `base` and points along `d`, the wrist turned so the hand's own up leans toward the camera ----------
	void Pose(UBQS_SaberBase s, Vector3 base, Vector3 d)
	{
		d = d.Unit();
		double ua = UBQS_Data.Up(s.frameNow);
		Vector3 toCam = -fwd;
		Vector3 n = toCam - d * (toCam dot d);
		if (n.Length() < 0.01) n = upv - d * (upv dot d);
		n = n.Unit();
		Vector3 f = d * cos(ua) - n * sin(ua);
		Vector3 hu = d * sin(ua) + n * cos(ua);
		double a = VectorAngle(f.x, f.y);
		Vector3 flatRight = (sin(a), -cos(a), 0);
		Vector3 levelUp = flatRight cross f;
		double r = atan2(-(hu dot flatRight), hu dot levelUp);
		s.rigPose = true;
		s.rigAngle = a - 90.0;
		s.rigPitch = asin(clamp(f.z, -1.0, 1.0));
		s.rigRoll = -r;
		s.rigPos = (0, 0, 0);
		Vector3 off = s.BladeBase() - s.rigPos;
		s.rigPos = base - off;
	}

	// the pose of saber `which` (0 main, 1 off) at phase time t (tics)
	Vector3 wBase, wDir;
	void Want(int which, double t, double L)
	{
		Vector3 base, d;
		Vector3 C = eye + fwd * CF("rig_dist", 50.0);
		double app = clamp((8.0 - t) / 8.0, 0.0, 1.0);   // 1 -> 0 over the first 8 tics: the approach
		if (phase == 2)
		{
			if (which == 1) { d = upv; base = C - upv * (L * 0.5); }
			else { d = -rgt; base = C + rgt * (L * 0.5) - fwd * (14.0 * app) + upv * (6.0 * app); }
		}
		else if (phase == 3)
		{
			if (which == 1) { d = (upv + rgt).Unit(); base = C - d * (L * 0.5); }
			else { d = (upv - rgt).Unit(); base = C - d * (L * 0.5) - fwd * (14.0 * app) + rgt * (6.0 * app); }
		}
		else if (phase == 4 && which == 0)
		{
			double th = 50.0 * sin(t * 360.0 / 24.0);
			d = upv * cos(th) - rgt * sin(th);
			base = C + rgt * 16.0 - upv * (L * 0.45);
		}
		else if (phase == 5 && which == 0)
		{
			// (predict agent) the swing of phase 4, frozen dead at t = 12 -- at its peak speed (13 deg/tic)
			double th = 50.0 * sin(min(t, 12.0) * 360.0 / 24.0);
			d = upv * cos(th) - rgt * sin(th);
			base = C + rgt * 16.0 - upv * (L * 0.45);
		}
		else if (phase == 6 && which == 0)
		{
			// (predict agent) instant reversals at +-50 deg, 15 deg/tic (525 deg/s) between: a triangle wave
			double P = 4.0 * 50.0 / 15.0;
			double x = (t / P) - floor(t / P);
			double th = 50.0 * (x < 0.5 ? 4.0 * x - 1.0 : 3.0 - 4.0 * x);
			d = upv * cos(th) - rgt * sin(th);
			base = C + rgt * 16.0 - upv * (L * 0.45);
		}
		else if (phase == 7 && which == 0)
		{
			// (b51) THE OWNER'S HEADSET SHOT: the saber held close below the eye, the blade going away from it
			// (about 25 deg off the line of sight)
			d = (fwd * 0.9 + upv * 0.42 + rgt * 0.05).Unit();
			base = eye + fwd * 9.0 - upv * 5.0 + rgt * 1.5;
		}
		else if (phase == 8 && which == 0)
		{
			// (b51) close, side on: the blade across the view 16 units out
			d = (rgt * 0.9 + upv * 0.35).Unit();
			base = eye + fwd * 16.0 - rgt * 7.0 - upv * 5.0;
		}
		else if (phase == 9 && which == 0)
		{
			// (b51) the emitter end close, from a little below: the bottom of the glow
			d = (upv * 0.8 + fwd * 0.45 + rgt * 0.2).Unit();
			base = eye + fwd * 12.0 - upv * 3.0;
		}
		else
		{
			double sd = (which == 0) ? 1.0 : -1.0;
			d = (upv + rgt * (0.18 * sd)).Unit();
			base = C + rgt * (15.0 * sd) - upv * (L * 0.5);
		}
		wBase = base;
		wDir = d;
	}

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let mo = p.mo;
		if (!mo) return;
		int lt = CI("rig_light", 40);
		if (lt != lastLight)
		{
			lastLight = lt;
			for (int i = 0; i < level.Sectors.Size(); i++) level.Sectors[i].SetLightLevel(lt);
		}
		if (!placed && level.maptime >= 2) { Place(mo); placed = true; }
		mo.vel = (0, 0, 0);
		mo.pitch = 0;
		p.cheats |= CF_GODMODE;
		eye = mo.pos + (0, 0, p.viewheight);
		fwd = (cos(mo.angle), sin(mo.angle), 0);
		rgt = (sin(mo.angle), -cos(mo.angle), 0);
		upv = (0, 0, 1);

		int ph = CI("rig_phase", 0);
		if (ph != phase) { phase = ph; phaseStart = level.maptime; Console.PrintfEx(PRINT_LOG, "UBQSRIG phase %d at %d", ph, level.maptime); }
		UBQS_SaberBase sab[2];
		sab[0] = UBQS_SaberBase(mo.FindInventory("UBQS_Saber"));
		sab[1] = UBQS_SaberBase(mo.FindInventory("UBQS_SaberOff"));
		// the main-hand saber drawn (the player starts holding the pistol; the bridge raises the off hand's)
		if (sab[0] && p.ReadyWeapon != sab[0] && p.PendingWeapon == WP_NOCHANGE && level.maptime > 10 && level.maptime % 35 == 0)
			p.PendingWeapon = sab[0];
		double t = level.maptime - phaseStart;
		double lead = CF("rig_lead", 1.0);
		// (predict agent) MEASURE what the last frame showed: the main glow (placed last tic, drawn at TicFrac 1
		// under cl_capfps) against the stand-in (the hand layer's pose, also placed last tic) -- before either moves
		if (phase >= 4 && standIn[0] && haveSb)
		{
			let si = standIn[0];
			Vector3 sd = (cos(si.pitch) * cos(si.angle), cos(si.pitch) * sin(si.angle), -sin(si.pitch));
			double best = 999, ca = -1, ha = -1, bb = -1, eb = 999, ebb = -1;
			// (unit vectors: BladeDir is 1e-7 off unit, which acos turns into a fake 0.03 deg)
			sd = sd.Unit();
			Vector3 bd = sab[0] ? sab[0].BladeDir().Unit() : sd, bbase = sab[0] ? sab[0].BladeBase() : lastSb;
			let it = ThinkerIterator.Create("UBQS_BeamGlow");
			Actor g;
			while (g = Actor(it.Next()))
			{
				if ((g.pos - lastSb).Length() > 12.0) continue;
				Vector3 gd = UBQS_Data.GlowAxis(g.angle, g.pitch, g.roll).Unit();   // (b51: the glow is rolled to face the eye)
				double e = acos(clamp(gd dot sd, -1.0, 1.0));
				if (e < best) { best = e; bb = (g.pos - lastSb).Length(); }
				double e2 = acos(clamp(gd dot bd, -1.0, 1.0));
				if (e2 < eb) { eb = e2; ebb = (g.pos - bbase).Length(); }
				String cn = g.GetSpriteIndex("UBC3") == g.sprite ? "c" : "h";
				if (cn == "c") ca = g.alpha; else ha = g.alpha;
			}
			Console.PrintfEx(PRINT_LOG, "UBQSRIG err phase %d t %d: glow vs stand-in %.3f deg, base %.3f, core alpha %.2f halo %.2f | vs the script blade now %.4f deg base %.4f", phase, int(t), best, bb, ca, ha, eb, ebb);
		}
		for (int w = 0; w < 2; w++)
		{
			let s = sab[w];
			if (!s) continue;
			if (phase == 0) { s.rigPose = false; continue; }
			double L = s.FullLen();
			Vector3 b, d;
			// THE STAND-IN for the hand-layer model: where the hand will be `lead` tics on (in VR the hand layer
			// draws the live controller, about a tic ahead of anything the world layer was given)
			Want(w, t + lead, L);
			Pose(s, wBase, wDir);
			Vector3 sb = s.BladeBase(), sp = s.Pommel(), sd = s.BladeDir();
			if (w == 0) { lastSb = sb; haveSb = true; }
			// ...and the pose the saber's own script (glow, FX, clash) sees this tic
			Want(w, t, L);
			b = wBase; d = wDir;
			Pose(s, b, d);
			Vector3 chk = s.BladeDir();
			if (level.maptime % 35 == 0)
				Console.PrintfEx(PRINT_LOG, "UBQSRIG %s frame %d lit %d len %.1f dir err %.4f base err %.3f", w ? "off" : "main", s.frameNow, s.Lit(), s.BladeLen(), (chk - d.Unit()).Length(), (s.BladeBase() - b).Length());
			if (!CI("rig_standin", 1) || !s.InHand()) { if (standIn[w]) { standIn[w].Destroy(); standIn[w] = null; } continue; }
			if (!standIn[w]) standIn[w] = UBQSRig_StandIn(Actor.Spawn("UBQSRig_StandIn", (sb + sp) * 0.5));
			let si = standIn[w];
			si.SetOrigin((sb + sp) * 0.5, false);
			si.angle = VectorAngle(sd.x, sd.y);
			si.pitch = -asin(clamp(sd.z, -1.0, 1.0));
			si.roll = 0;
			double sc = (sb - sp).Length() / (2.0 * 7.95);
			si.scale = (sc, sc);
			si.sprite = Actor.GetSpriteIndex(String.Format("RG%sS", UBQS_Data.Col(s.ColIdx())));
			let tc = CVar.FindCVar("ubqs_blade_tube");
			si.frame = (s.Lit() ? 0 : 1) + ((tc && !tc.GetBool()) ? 2 : 0);   // (b50) C/D: tube off + stub
		}
	}
}
