// ==========================================================================================================
// THE FORCE: one item every saber-carrier holds. It owns the push (both hands share its cooldown), and reads
// the OFF HAND's gestures -- the off-hand saber's alt held, or with no off-hand saber the bare Force hand's
// trigger -- and the Force jump.
//   THRUST the hand out, held:  PUSH (along your thrust).
//   YANK it back to you, held:  PULL -- enemies stagger in, pickups fly to your hand, a thrown saber comes home.
//   HOLD it still on an enemy:  GRIP -- it rises, choking, and hangs where your hand points; move your hand and
//                               it moves; let go mid-swing and it is FLUNG (and hurts when it hits).
//   HOLD JUMP:                  a FORCE JUMP -- higher, and a floating fall while jump stays held.
// ==========================================================================================================
class UBQS_Force : Inventory
{
	int pushReady;
	Vector3 h0, h1, h2, h3;
	double lastYaw;
	Vector3 lastBody;
	bool armed, fired;
	int armTics, lastScan;
	// the grip
	Actor gripped;
	double gripDist, dmgAcc;
	bool gripNoGrav;
	State gripPain;
	int gripSince;
	// a flung body, watched for the moment it hits something
	Actor slamMo;
	int slamTics;
	double slamLast;
	// things pulled toward you
	Array<Actor> pulled;
	Array<int> pulledUntil;
	// the jump
	int airTics;
	bool boostOk;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
	}
	static UBQS_Force Of(Actor who)
	{
		if (!who) return null;
		let f = UBQS_Force(who.FindInventory("UBQS_Force"));
		if (!f) f = UBQS_Force(who.GiveInventoryType("UBQS_Force"));
		return f;
	}
	double FV(String n, double fb) { return UBQS_Data.F(owner, n, fb); }
	int IV(String n, int fb) { return UBQS_Data.I(owner, n, fb); }

	// ---- THE OFF HAND ------------------------------------------------------------------------------------
	Vector3 OffPos()
	{
		Vector3 p = owner.OffhandPos;
		if (p == (0, 0, 0)) p = owner.Vec3Offset(0, 0, owner.player ? owner.player.viewheight * 0.8 : 40.0);
		return p;
	}
	Vector3 OffAim()
	{
		double a = owner.OffhandAngle + 90.0, p = -owner.OffhandPitch;
		return (cos(p) * cos(a), cos(p) * sin(a), -sin(p));
	}
	Vector3 ViewFwd()
	{
		double a = owner.angle, p = owner.pitch;
		return (cos(p) * cos(a), cos(p) * sin(a), -sin(p));
	}
	Vector3 HandVel()
	{
		Vector3 a = h0 - h1, b = h1 - h2, c = h2 - h3;
		Vector3 v = a;
		if (b.Length() > v.Length()) v = b;
		if (c.Length() > v.Length()) v = c;
		return v;
	}
	void Buzz()
	{
		if (owner && owner.player) owner.LineAttack(owner.angle, 1, -90, 1, 'UBQS_Haptic', 'UBQS_HapticPuff', 256);
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner || !owner.player || owner.health <= 0) { if (gripped) EndGrip(false); return; }
		let p = owner.player;
		// the off hand's last four positions, less the body; a snap turn or teleport forgets them
		h3 = h2; h2 = h1; h1 = h0;
		h0 = OffPos() - owner.pos;
		if (abs(DeltaAngle(lastYaw, owner.angle)) >= 8.0 || (owner.pos - lastBody).Length() > 48.0) { h1 = h0; h2 = h0; h3 = h0; }
		lastYaw = owner.angle;
		lastBody = owner.pos;

		let off = p.OffhandWeapon;
		bool forceHand = off is "UBQS_ForceHand";
		bool saberUp = (p.ReadyWeapon is "UBQS_SaberBase") || forceHand;
		int bits = 0;
		if (forceHand) bits = BT_OFFHANDATTACK | BT_OFFHANDALTATTACK;
		else if (off is "UBQS_SaberOff" && IV("ubqs_force_gestures", 1) && !UBQS_SaberBase(off).merged) bits = BT_OFFHANDALTATTACK;
		bool held = bits != 0 && (p.cmd.buttons & bits);

		if (gripped) GripTick(held);
		else if (held)
		{
			if (!armed) { armed = true; fired = false; armTics = 0; }
			armTics++;
			if (!fired) Gesture();
		}
		else armed = false;

		SlamTick();
		PulledTick();
		if (saberUp) ForceJump(p);
	}

	// ---- READING THE HAND ----------------------------------------------------------------------------------
	private void Gesture()
	{
		Vector3 hv = HandVel();
		double sp = hv.Length();
		double thr = FV("ubqs_force_gesture", 2.0);
		Vector3 fwd = ViewFwd();
		if (sp >= thr)
		{
			Vector3 u = hv / sp;
			double dd = u dot fwd;
			if (dd >= 0.55) { Push(OffPos(), (u + fwd).Unit()); fired = true; return; }
			if (dd <= -0.55) { Pull(OffPos(), (OffAim() + fwd).Unit()); fired = true; return; }
		}
		// held still: reach for something to grip (looked for every few tics, not every one)
		if (armTics >= 8 && sp < 1.5 && level.maptime - lastScan >= 3)
		{
			lastScan = level.maptime;
			let t = FindGrip();
			if (t) { StartGrip(t); fired = true; }
		}
	}

	// ---- PUSH ------------------------------------------------------------------------------------------------
	// Everything in a cone in front of the hand is thrown back -- the lighter it is the farther -- and knocked
	// about; shots in the cone are turned round. A shock ring rolls out along the cone (particles: no light).
	void Push(Vector3 hp, Vector3 d)
	{
		if (!owner) return;
		if (level.maptime < pushReady) { owner.A_StartSound("ubqs/off", CHAN_AUTO, 0, 0.25); return; }
		pushReady = level.maptime + int(FV("ubqs_push_cooldown", 1.5) * 35);
		double range = FV("ubqs_push_range", 448.0), cone = 40.0;
		owner.A_StartSound("ubqs/push", CHAN_AUTO, 0, 1.0);
		let it = BlockThingsIterator.CreateFromPos(hp.x, hp.y, hp.z - range, range * 2.0, range, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || mo == owner || mo is "UBQS_Thrown" || mo is "UBQS_Light" || mo is "UBQS_Remote") continue;
			Vector3 to = level.Vec3Diff(hp, (mo.pos.xy, mo.pos.z + mo.height * 0.5));
			double dist = to.Length();
			if (dist < 1 || dist > range) continue;
			Vector3 u = to / dist;
			if (acos(clamp(u dot d, -1.0, 1.0)) > cone) continue;
			if (mo.bMissile)
			{
				if (mo.target == owner) continue;
				double sp = max(mo.Speed, mo.vel.Length());
				Actor shooter = mo.target;
				mo.target = owner;
				if (mo.bSeekerMissile) mo.tracer = shooter;
				mo.vel = u * max(sp, 8.0);
				mo.angle = VectorAngle(u.x, u.y);
				mo.pitch = -asin(clamp(u.z, -1.0, 1.0));
				continue;
			}
			if (!mo.bShootable || mo.health <= 0 || mo.bDontThrust || (mo.player && !deathmatch) || (mo.bFriendly && owner.player)) continue;
			if (!owner.CheckSight(mo, SF_IGNOREVISIBILITY)) continue;
			double falloff = 1.0 - dist / range * 0.6;
			double f = clamp(2400.0 / max(mo.Mass, 50), 2.0, 26.0) * falloff * FV("ubqs_push_power", 1.0);
			mo.vel += (u.x * f, u.y * f, max(u.z * f, 0.0) + f * 0.3);
			mo.DamageMobj(self, owner, int(FV("ubqs_push_damage", 8.0)), 'Saber', DMG_THRUSTLESS);
		}
		Ring(hp, d, 1.0);
		Buzz();
	}
	// the shock ring: out along the cone (dir 1) or rushing in to the hand (dir -1)
	void Ring(Vector3 hp, Vector3 d, double dir)
	{
		FSpawnParticleParams p;
		p.flags = SPF_FULLBRIGHT;
		p.style = STYLE_Add;
		p.startalpha = 0.55;
		p.fadestep = -1;
		p.lifetime = 14;
		p.size = 6.0;
		p.sizestep = dir > 0 ? 1.2 : -0.3;
		Vector3 side = (d cross (0, 0, 1));
		if (side.Length() < 0.01) side = (1, 0, 0);
		side = side.Unit();
		Vector3 up = side cross d;
		for (int k = 0; k < 28; k++)
		{
			double a = k * (360.0 / 28);
			Vector3 ring = side * cos(a) + up * sin(a);
			p.color1 = (k & 1) ? 0xB8D8FF : 0xFFFFFF;
			if (dir > 0)
			{
				p.pos = hp + d * 8.0 + ring * 4.0;
				p.vel = d * 22.0 + ring * 9.0;
			}
			else
			{
				p.pos = hp + d * 300.0 + ring * 120.0;
				p.vel = -(d * 22.0 + ring * 9.0);
			}
			level.SpawnParticle(p);
		}
	}

	// ---- PULL ------------------------------------------------------------------------------------------------
	void Pull(Vector3 hp, Vector3 d)
	{
		if (level.maptime < pushReady) { owner.A_StartSound("ubqs/off", CHAN_AUTO, 0, 0.25); return; }
		pushReady = level.maptime + int(FV("ubqs_push_cooldown", 1.5) * 35);
		owner.A_StartSound("ubqs/pull", CHAN_AUTO, 0, 1.0);
		// your sabers, wherever they are, come home
		for (let item = owner.Inv; item; item = item.Inv)
		{
			let sb = UBQS_SaberBase(item);
			if (sb && sb.thrown) sb.thrown.Recall();
		}
		double range = FV("ubqs_pull_range", 768.0), cone = 30.0;
		let it = BlockThingsIterator.CreateFromPos(hp.x, hp.y, hp.z - range, range * 2.0, range, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || mo == owner || mo.bMissile || mo is "UBQS_Thrown" || mo is "UBQS_Light" || mo is "UBQS_Remote") continue;
			Vector3 to = level.Vec3Diff(hp, (mo.pos.xy, mo.pos.z + mo.height * 0.5));
			double dist = to.Length();
			if (dist < 1 || dist > range) continue;
			Vector3 u = to / dist;
			if (acos(clamp(u dot d, -1.0, 1.0)) > cone) continue;
			let inv = Inventory(mo);
			if (inv)
			{
				if (inv.Owner || !inv.bSpecial || pulled.Find(mo) < pulled.Size()) continue;
				if (!owner.CheckSight(mo, SF_IGNOREVISIBILITY)) continue;
				pulled.Push(mo);
				pulledUntil.Push(level.maptime + 70);
				continue;
			}
			if (!mo.bShootable || mo.health <= 0 || mo.bDontThrust || mo.player || (mo.bFriendly && owner.player)) continue;
			if (!owner.CheckSight(mo, SF_IGNOREVISIBILITY)) continue;
			double falloff = 1.0 - dist / range * 0.5;
			double f = clamp(1800.0 / max(mo.Mass, 50), 2.0, 22.0) * falloff * FV("ubqs_push_power", 1.0);
			mo.vel += (-u.x * f, -u.y * f, f * 0.25);
		}
		Ring(hp, d, -1.0);
		Buzz();
	}
	// pickups fly to you and are taken as they arrive
	private void PulledTick()
	{
		for (int i = pulled.Size() - 1; i >= 0; i--)
		{
			let inv = Inventory(pulled[i]);
			if (!inv || inv.Owner || level.maptime > pulledUntil[i])
			{
				pulled.Delete(i);
				pulledUntil.Delete(i);
				continue;
			}
			Vector3 to = level.Vec3Diff(inv.pos, owner.pos + (0, 0, owner.height * 0.5));
			double dist = to.Length();
			if (dist < owner.radius + 16.0)
			{
				inv.Touch(owner);
				pulled.Delete(i);
				pulledUntil.Delete(i);
				continue;
			}
			inv.SetOrigin(inv.pos + to / dist * min(16.0, dist), true);
		}
	}

	// ---- GRIP ------------------------------------------------------------------------------------------------
	private Actor FindGrip()
	{
		double maxMass = FV("ubqs_grip_mass", 600.0);
		if (maxMass <= 0) return null;
		Vector3 hp = OffPos(), aim = OffAim();
		double range = 1024.0, best = 12.0;
		Actor pick = null;
		let it = BlockThingsIterator.CreateFromPos(hp.x, hp.y, hp.z - range, range * 2.0, range, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || mo == owner || !mo.bIsMonster || !mo.bShootable || mo.health <= 0 || mo.bFriendly || mo.bBoss) continue;
			if (mo.Mass > maxMass || mo.bDontThrust) continue;
			Vector3 to = level.Vec3Diff(hp, (mo.pos.xy, mo.pos.z + mo.height * 0.5));
			double dist = to.Length();
			if (dist < 1 || dist > range) continue;
			double off = acos(clamp((to / dist) dot aim, -1.0, 1.0));
			if (off >= best) continue;
			if (!owner.CheckSight(mo, SF_IGNOREVISIBILITY)) continue;
			best = off;
			pick = mo;
		}
		return pick;
	}
	private void StartGrip(Actor mo)
	{
		gripped = mo;
		gripDist = clamp(level.Vec3Diff(OffPos(), mo.pos).Length(), 56.0, 320.0);
		gripNoGrav = mo.bNoGravity;
		mo.bNoGravity = true;
		gripPain = mo.FindState("Pain");
		gripSince = level.maptime;
		dmgAcc = 0;
		owner.A_StartSound("ubqs/grip", 23, CHANF_LOOPING, 0.7);
		mo.A_StartSound(mo.PainSound, CHAN_VOICE);
		if (gripPain) mo.SetState(gripPain);
		Buzz();
	}
	private void GripTick(bool held)
	{
		let mo = gripped;
		if (!mo || mo.health <= 0) { EndGrip(false); return; }
		if (!held) { EndGrip(true); return; }
		// it hangs where your hand points, lifted a little, and follows the hand
		Vector3 want = OffPos() + OffAim() * gripDist + (0, 0, 10.0 - mo.height * 0.5);
		Vector3 dv = level.Vec3Diff(mo.pos, want);
		double l = dv.Length();
		Vector3 v = dv * 0.25;
		if (v.Length() > 14.0) v = v.Unit() * 14.0;
		mo.vel = v;
		// it can do nothing but struggle: its frame is held, and every so often it chokes
		if (mo.tics >= 0 && mo.tics < 2) mo.tics = 2;
		int t = level.maptime - gripSince;
		if (t > 0 && (t %% 18) == 0)
		{
			mo.A_StartSound(mo.PainSound, CHAN_VOICE);
			if (gripPain) mo.SetState(gripPain);
			if (mo.tics >= 0 && mo.tics < 2) mo.tics = 2;
		}
		if ((t %% 12) == 0) Buzz();
		// the choke
		dmgAcc += FV("ubqs_grip_damage", 6.0) / 35.0;
		if (dmgAcc >= 1.0)
		{
			int dmg = int(dmgAcc);
			dmgAcc -= dmg;
			mo.DamageMobj(self, owner, dmg, 'Force', DMG_NO_PAIN | DMG_THRUSTLESS);
			if (!mo || mo.health <= 0) { EndGrip(false); return; }
		}
		// a faint shimmer about it
		if ((level.maptime & 1) == 0)
		{
			FSpawnParticleParams p;
			p.flags = SPF_FULLBRIGHT;
			p.style = STYLE_Add;
			p.startalpha = 0.35;
			p.fadestep = -1;
			p.lifetime = 10;
			p.size = 4.0;
			p.sizestep = -0.2;
			p.color1 = 0xB8D8FF;
			for (int i = 0; i < 3; i++)
			{
				double a = frandom[UBQSFx](0, 360);
				p.pos = mo.pos + (cos(a) * mo.radius, sin(a) * mo.radius, frandom[UBQSFx](0, mo.height));
				p.vel = (0, 0, 0.6);
				level.SpawnParticle(p);
			}
		}
	}
	private void EndGrip(bool fling)
	{
		let mo = gripped;
		gripped = null;
		if (owner) owner.A_StopSound(23);
		if (!mo) return;
		mo.bNoGravity = gripNoGrav;
		if (mo.tics > 1) mo.tics = 1;
		if (fling && mo.health > 0)
		{
			Vector3 hv = HandVel();
			Vector3 v = hv * FV("ubqs_grip_fling", 3.5);
			if (v.Length() > 40.0) v = v.Unit() * 40.0;
			mo.vel += v;
			slamMo = mo;
			slamTics = 40;
			slamLast = mo.vel.Length();
			if (v.Length() > 6.0) owner.A_StartSound("ubqs/push", CHAN_AUTO, 0, 0.5, ATTN_NORM, 1.4);
		}
	}
	// a flung body that stops dead has hit something: it hurts, as hard as it was going
	private void SlamTick()
	{
		if (!slamMo) return;
		if (--slamTics <= 0 || slamMo.health <= 0) { slamMo = null; return; }
		double sp = slamMo.vel.Length();
		if (slamLast > 9.0 && sp < slamLast * 0.4)
		{
			int dmg = int(slamLast * FV("ubqs_grip_slam", 3.0));
			slamMo.A_StartSound("ubqs/drop", CHAN_AUTO, 0, 0.8, ATTN_NORM, 0.6);
			slamMo.DamageMobj(self, owner, dmg, 'Force');
			slamMo = null;
			return;
		}
		slamLast = sp;
	}

	// ---- FORCE JUMP ----------------------------------------------------------------------------------------
	private void ForceJump(PlayerInfo p)
	{
		if (!IV("ubqs_force_jump", 1)) return;
		bool jump = (p.cmd.buttons & BT_JUMP) != 0;
		if (p.onground) { airTics = 0; boostOk = jump; return; }
		airTics++;
		if (!jump) { boostOk = false; return; }
		double pw = FV("ubqs_jump_power", 1.0);
		if (boostOk && owner.vel.z > 0 && airTics <= 8)
		{
			owner.vel.z += 0.55 * pw;
			if (airTics == 1) owner.A_StartSound("ubqs/push", CHAN_AUTO, 0, 0.35, ATTN_NORM, 1.6);
		}
		else if (owner.vel.z < -5.0 / max(pw, 0.25)) owner.vel.z = -5.0 / max(pw, 0.25);   // a floating fall
	}

	override void DetachFromOwner()
	{
		if (gripped) EndGrip(false);
		Super.DetachFromOwner();
	}
}

// THE BARE FORCE HAND: with no off-hand saber (ubqs_dual off), the off hand holds nothing but the Force.
// Its trigger and its alt are both the Force's gestures (UBQS_Force reads them).
class UBQS_ForceHand : Weapon
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOALERT
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOAUTOFIRE
		+WEAPON.CHEATNOTWEAPON
		Weapon.SelectionOrder 9000;
		Tag "The Force";
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	Select:
		TNT1 A 1 A_Raise(20);
		Loop;
	Deselect:
		TNT1 A 1 A_Lower(20);
		Loop;
	Ready:
		TNT1 A 1 A_WeaponReady();
		Loop;
	Fire:
	AltFire:
		TNT1 A 4;
		Goto Ready;
	}
}

// ==========================================================================================================
// THE TRAINING REMOTE (the Falcon, A New Hope): a little drone that circles in front of you and stings you
// with bolts for practice. Deflect them. ubqs_remote_level 1-3 sets how fast and how often; ubqs_remote_sting
// how much a hit hurts (0: not at all). It keeps score on screen. Summoned and dismissed from the menu, or
// `netevent ubqs_remote`.
// ==========================================================================================================
class UBQS_Remote : Actor
{
	Actor trainee;
	double th, om, rad, hgt;
	int nextShot, windup, nextChirp, omUntil;
	int shots, deflects, stung, struck;

	Default
	{
		Radius 5;
		Height 8;
		Health 1000;
		Mass 10;
		+NOGRAVITY
		+SHOOTABLE
		-SOLID
		+NOBLOOD
		+NOTARGET
		+DONTSPLASH
		+NOTAUTOAIMED
		+DONTTHRUST
		+NODAMAGETHRUST
		+FLOAT
		+NOBLOCKMONST
		Tag "Training remote";
	}
	int Level() { return clamp(UBQS_Data.I(trainee, "ubqs_remote_level", 2), 1, 3); }
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		th = 0;
		om = 1.6;
		rad = 72;
		hgt = 0;
		nextShot = level.maptime + 70;
		nextChirp = level.maptime + 35;
	}
	void Report()
	{
		if (trainee) trainee.A_Print(String.Format("TRAINING REMOTE\ndeflected %%d   stung %%d   hit it %%d", deflects, stung, struck), 2.0);
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!trainee || !trainee.player) { Destroy(); return; }
		// THE DANCE: round you, out in front, drifting in and out and up and down
		if (level.maptime >= omUntil)
		{
			om = frandom[UBQSFx](0.8, 2.6) * (random[UBQSFx](0, 1) ? 1 : -1);
			omUntil = level.maptime + random[UBQSFx](25, 70);
		}
		th += om;
		if (th > 70) { th = 70; om = -abs(om); }
		if (th < -70) { th = -70; om = abs(om); }
		rad = clamp(rad + frandom[UBQSFx](-1.5, 1.5), 56.0, 100.0);
		hgt = clamp(hgt + frandom[UBQSFx](-0.8, 0.8), -10.0, 14.0);
		double a = trainee.angle + th;
		double eye = trainee.player.viewheight;
		Vector3 want = trainee.Vec3Offset(cos(a) * rad, sin(a) * rad, eye - 6.0 + hgt + sin(level.maptime * 9.0) * 2.0);
		Vector3 dv = level.Vec3Diff(pos, want);
		if (dv.Length() > 512.0) { SetOrigin(want, false); vel = (0, 0, 0); }
		else
		{
			Vector3 v = dv * 0.12;
			if (v.Length() > 6.0) v = v.Unit() * 6.0;
			vel = vel * 0.5 + v * 0.5;
		}
		Vector3 to = level.Vec3Diff(pos, trainee.pos + (0, 0, eye * 0.8));
		angle = VectorAngle(to.x, to.y);
		// THE SHOT: a beep, its lamps glow for a moment, then it stings
		if (windup > 0)
		{
			if (--windup == 0) { Fire(); frame = 0; }
		}
		else if (trainee.health > 0 && level.maptime >= nextShot)
		{
			windup = 12 - Level() * 2;
			frame = 1;
			A_StartSound("ubqs/rcharge", CHAN_BODY, 0, 0.7);
		}
		if (level.maptime >= nextChirp)
		{
			nextChirp = level.maptime + random[UBQSFx](60, 160);
			A_StartSound("ubqs/rbeep", CHAN_VOICE, 0, 0.6);
		}
	}
	void Fire()
	{
		if (!trainee) return;
		static const double SPD[] = { 7.0, 9.0, 12.0 };
		static const int GAPMIN[] = { 45, 30, 18 };
		static const int GAPMAX[] = { 90, 60, 40 };
		int L = Level() - 1;
		Vector3 at = trainee.pos + (frandom[UBQSFx](-8, 8), frandom[UBQSFx](-8, 8), trainee.height * frandom[UBQSFx](0.45, 0.85));
		Vector3 from = pos + (0, 0, height * 0.5);
		Vector3 d = level.Vec3Diff(from, at);
		if (d.Length() < 1) return;
		d = d.Unit();
		let b = UBQS_RemoteBolt(Spawn("UBQS_RemoteBolt", from + d * 6.0));
		if (b)
		{
			b.target = self;
			b.home = self;
			b.rgb = 0xFF3020;
			b.Speed = SPD[L];
			b.vel = d * SPD[L];
			b.angle = VectorAngle(d.x, d.y);
			b.pitch = -asin(clamp(d.z, -1.0, 1.0));
		}
		shots++;
		A_StartSound("ubqs/rfire", CHAN_WEAPON);
		nextShot = level.maptime + random[UBQSFx](GAPMIN[L], GAPMAX[L]);
	}
	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		// a deflected sting back into it: a point to you. A swat with the blade (or a shot): knocked away.
		if (inflictor is "UBQS_RemoteBolt")
		{
			struck++;
			Report();
			A_StartSound("ubqs/rsad", CHAN_VOICE);
		}
		else A_StartSound("ubqs/rbeep", CHAN_VOICE);
		Vector3 kick = (frandom[UBQSFx](-1, 1), frandom[UBQSFx](-1, 1), frandom[UBQSFx](0, 1));
		if (source && source != self)
		{
			Vector3 away = level.Vec3Diff(source.pos, pos);
			if (away.Length() > 1) kick = away.Unit() + (0, 0, 0.3);
		}
		vel += kick * 8.0;
		nextShot = max(nextShot, level.maptime + 35);
		return 0;
	}
	States
	{
	Spawn:
		UBRM A -1;
		Stop;
	Register:
		UBRM B -1;
		Stop;
	}
}

class UBQS_RemoteBolt : UBQS_Bolt
{
	UBQS_Remote home;
	bool counted;
	Default
	{
		Speed 9;
		Radius 2;
		Height 3;
		DamageFunction (1);
		DamageType "Remote";
		Obituary "%%o was stung by a training remote.";
	}
	override bool CanCollideWith(Actor other, bool passive)
	{
		if (passive) return true;
		bool back = target && target.player;          // deflected: it is yours now
		if (other is "UBQS_Remote") return back;
		if (other.player) return !back;
		return back && other.bShootable;
	}
	override int DoSpecialDamage(Actor victim, int damage, Name damagetype)
	{
		if (victim && victim.player && home && victim == home.trainee)
		{
			home.stung++;
			home.Report();
			return UBQS_Data.I(victim, "ubqs_remote_sting", 2);
		}
		if (victim is "UBQS_Remote") return 1;
		return 10;
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!counted && home && target && target.player)
		{
			counted = true;
			home.deflects++;
			home.Report();
		}
	}
}

