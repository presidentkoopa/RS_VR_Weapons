// ============================================================================
// THE UNMAKER -- main hand, slot 0 with the BFGs. The owner's pick (09-14): Doom 64's Unmaker, "a
// deadly, fuckoff pulsating red blast of hate" in our own laser look. Id frozen by the build lane
// (doomwork-5e); its card by the reload lane (uzdxrema-63). Mesh: RS_Main's RS_GH_Unmaker, rest frame
// 0, as models/unmaker/Unmaker/unmaker_wm.md3 (body, flap, lever -- neither hinge is a trigger).
//
// THE SHOT is the owner's (09-14): it drains a cell a tic, so it does a ton -- 101 on the hit and a 51
// blast out to 151, a laser every tic the trigger is held; a 100-cell skull is under three seconds of
// it. A real round, fired by WM_Gun like every other gun's -- WM_UnmakerBolt, below -- so it is spawned,
// moved and exploded identically on every machine. Where it lands and at the muzzle it is RS_Ballistics'
// (uzdxrema-45): impact "unmaker", a hot spot that builds while the beam holds on it, and flash
// "unmaker", a sustained red glow throbbing on the beam's beat.
//
// EVERYTHING IT KILLS MELTS: WM_UnmakerMelt, below.
//
// THE BEAM IS ONLY WHAT IT LOOKS LIKE. Two beam lines of its own, claimed from the engine
// (Level.ClaimBeam, "Engine docs/BEAM_LINES_PLAN.md"): a thin white-hot core and a wide red sheath,
// both throbbing on level.maptime, each with its own look (SetBeamStyle on its own slot). It never
// calls SetBeamCount, SetBeamLook or ClearBeams, and never writes a slot it did not claim, so the
// grab lasers (RS_WorldHands, slots 0-1) and the Lance (0-7) draw exactly as they did.
//
// Drawn from FireHeld / FireReleased, WM_Gun's hold hooks, which DoEffect calls on every machine; the
// beam's ends are read from the drawn gun and a trace, and decide nothing.
//
// CARRIED, NOT PUT IN HAND, like every gun here: a test-arsenal StartItem and slot 0 (loadout.zs), and the
// arsenal page's wm_giveunmaker row. Its card is uzdxrema-63's: the skull on top is the magazine -- pull it
// off, seat a fresh one from the pouch -- holding 100 cells (the owner, 09-14).
// ============================================================================

class WM_Unmaker : WM_Gun
{
	// How far the beam reaches when it hits nothing.
	const BEAM_REACH = 8192.0;

	// The two claimed lines: the core and the sheath.
	int beamCore;
	int beamSheath;
	// The map they were claimed on. totaltime - maptime holds still through one map and changes with
	// the next, and a claim never survives a map change -- nor a savegame load, which is why
	// beamHeld is transient: a loaded gun claims afresh rather than writing a slot it no longer owns.
	int beamMapKey;
	transient bool beamHeld;
	transient WM_UnmakerTrace beamTrace;

	Default
	{
		// RS_BALLISTICS: its muzzle is flash "unmaker", a glow held at the fire rate rather than a
		// strobe; its impact is the round's (WM_UnmakerBolt).
		WM_Gun.FlashProfile "unmaker";
		Weapon.SelectionOrder 2850;
		Weapon.SlotNumber 0;
		Inventory.PickupMessage "Unmaker";
		Tag "Unmaker";
		Weapon.AmmoType1 "Cell";
		WM_Gun.ShotClass "WM_UnmakerBolt";
		WM_Gun.FullAuto true;
		WM_Gun.FireTics 1;
	}

	// EVERY TIC THE TRIGGER STAYS DOWN after a shot left: the beam's sound, and the beam, from the muzzle
	// along the barrel.
	override void FireHeld(int heldTics)
	{
		Super.FireHeld(heldTics);
		if (!Owner) return;
		SoundBeam();
		if (!HoldBeams()) return;
		Vector3 from, dir;
		bool okFrom, okDir;
		[from, okFrom] = MuzzleToWorld();
		[dir, okDir]   = BarrelToWorld();
		DrawBeams(from, dir);
	}

	// ONCE, when the trigger comes back or the gun stops firing (dry, or a switch): the beam goes out.
	override void FireReleased(int heldTics)
	{
		Super.FireReleased(heldTics);
		QuietBeam();
		DarkBeams();
	}

	// Dropped or taken away mid-burst: nothing is left calling FireReleased, so go dark here.
	override void DetachFromOwner()
	{
		QuietBeam();
		DarkBeams();
		Super.DetachFromOwner();
	}

	// THE BEAM'S SOUND, RS_Main's gh_unmaker set (SNDINFO.txt): its spin-up on the first tic, the loop swelling in
	// under it over LOOP_SWELL tics while the trigger stays down, and the wind-down -- over whatever is left of
	// the spin-up -- when it comes back. The class plays it, not the card: a card's firesound sounds once a
	// shot, and this shoots every tic. On the holder, on two channels of its own. Sound only; it decides nothing.
	const SND_BEAM   = 23;   // the spin-up, then the wind-down over it
	const SND_LOOP   = 24;
	const LOOP_SWELL = 20;
	transient bool beamSounding;
	transient int  beamSoundTics;

	void SoundBeam()
	{
		if (!beamSounding)
		{
			Owner.A_StartSound("wm/unmaker/start", SND_BEAM, 0, 0.8);
			Owner.A_StartSound("wm/unmaker/loop", SND_LOOP, CHANF_LOOPING, 0.2);
			beamSounding  = true;
			beamSoundTics = 0;
			return;
		}
		if (beamSoundTics >= LOOP_SWELL) return;
		beamSoundTics++;
		Owner.A_SoundVolume(SND_LOOP, 0.2 + 0.5 * beamSoundTics / double(LOOP_SWELL));
	}

	void QuietBeam()
	{
		if (!beamSounding) return;
		beamSounding = false;
		if (!Owner) return;
		Owner.A_StopSound(SND_LOOP);
		Owner.A_StartSound("wm/unmaker/stop", SND_BEAM, 0, 0.8);
	}

	int MapKey() const { return level.totaltime - level.maptime; }

	// OUR TWO LINES, claimed once a map, released by the engine when this gun is destroyed (the
	// claim's owner). False when the engine has no slot to spare: then there is simply no beam.
	bool HoldBeams()
	{
		if (beamHeld && beamMapKey == MapKey() && level.IsBeamClaimed(beamCore) && level.IsBeamClaimed(beamSheath))
			return true;
		beamHeld = false;
		int core   = level.ClaimBeam(self);
		int sheath = level.ClaimBeam(self);
		if (core < 0 || sheath < 0)
		{
			if (core >= 0) level.ReleaseBeam(core);
			if (sheath >= 0) level.ReleaseBeam(sheath);
			return false;
		}
		beamCore   = core;
		beamSheath = sheath;
		beamMapKey = MapKey();
		beamHeld   = true;
		// airGlow, halo, taper, flare. Both glow in the air and neither tapers -- a bar, not a
		// cone. The sheath's wide halo is the red haze around it; the core's flare is the white-hot
		// splash where it lands.
		level.SetBeamStyle(beamSheath, 1.0, 0.85, 0.0, 4.5);
		level.SetBeamStyle(beamCore,   1.0, 0.25, 0.0, 5.0);
		return true;
	}

	// THE LOOK: a deadly, throbbing red. The beat is a 5-tic sine on level.maptime (seven a second),
	// the same on every machine, slow enough that 35 Hz samples of it read as a throb, not a flicker.
	// On the beat the sheath swells and brightens and the core narrows to a white-hot needle burning
	// well past 1.0, which is what the bloom pass picks up. Now and then a tic surges -- a product of
	// two sines of the tic, no random number -- so it never settles into a steady hum.
	void DrawBeams(Vector3 from, Vector3 dir)
	{
		double len = dir.Length();
		if (len < 1e-6) return;
		dir /= len;
		Vector3 to = BeamEnd(from, dir);
		double beat  = 0.5 + 0.5 * sin(level.maptime * 72.0);
		double surge = max(0.0, abs(sin(level.maptime * 157.3) * sin(level.maptime * 311.7)) - 0.7) / 0.3;

		// ANCHORED ONLY FOR THE PLAYER HOLDING IT. The engine resolves an anchored beam slot to the
		// CONSOLE player's hand (hw_drawinfo.cpp ResolveLineAnchor), so the start follows your
		// controller at frame rate in your own headset, and another player's Unmaker is drawn from its
		// muzzle as the tic left it. Presentation only: nothing here reaches the playsim.
		int anchor = 0;
		if (Owner.player && Owner.PlayerNumber() == consoleplayer) anchor = bOffhandWeapon ? 2 : 1;
		level.SetBeamAnchor(beamSheath, anchor);
		level.SetBeamAnchor(beamCore, anchor);
		level.SetBeam(beamSheath, from, to, 2.0 + 1.4 * beat + 0.8 * surge, 1.8 + 1.0 * beat, 0xFF0A04,
			0.8 + 0.8 * beat + 0.6 * surge);
		color coreColor = (beat > 0.6) ? 0xFFE8D8 : 0xFF7050;
		level.SetBeam(beamCore, from, to, 0.8 - 0.35 * beat, 0.35, coreColor, 1.6 + 1.6 * beat + 0.8 * surge);
	}

	// Out, and anchors cleared -- only on slots this gun still holds this map.
	void DarkBeams()
	{
		if (!beamHeld || beamMapKey != MapKey()) return;
		if (level.IsBeamClaimed(beamCore))
		{
			level.SetBeamAnchor(beamCore, 0);
			level.SetBeam(beamCore, (0, 0, 0), (0, 0, 0), 0.01, 0.01, 0, 0.0);
		}
		if (level.IsBeamClaimed(beamSheath))
		{
			level.SetBeamAnchor(beamSheath, 0);
			level.SetBeam(beamSheath, (0, 0, 0), (0, 0, 0), 0.01, 0.01, 0, 0.0);
		}
	}

	// Where the beam lands: the first wall, floor or shootable thing along it, past the holder.
	Vector3 BeamEnd(Vector3 from, Vector3 dir)
	{
		if (!beamTrace) beamTrace = new("WM_UnmakerTrace");
		Sector sec = level.PointInSector(from.xy);
		if (sec && beamTrace.Trace(from, sec, dir, BEAM_REACH, 0, 0xFFFFFFFF, false, Owner))
			return beamTrace.Results.HitPos;
		return from + dir * BEAM_REACH;
	}
}

// The beam's trace stops at walls, floors and shootable things; it passes through the rest.
class WM_UnmakerTrace : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		if (Results.HitType == TRACE_HitActor && Results.HitActor && !Results.HitActor.bShootable)
			return TRACE_Skip;
		return TRACE_Stop;
	}
}

// THE UNMAKER'S ROUND: a laser that crosses a room in a tic. 101 on the hit, then a 51 blast out to
// 151 that spares the shooter, and RS_Ballistics' "unmaker" hot spot where it lands. Unseen: the beam
// is what you see.
class WM_UnmakerBolt : FastProjectile
{
	Default
	{
		Radius 2;
		Height 2;
		Speed 500;
		DamageFunction 101;
		+DONTSPLASH
		// Nothing it kills bursts into gibs: it melts instead (WM_UnmakerMelt).
		+NOEXTREMEDEATH
	}

	action void A_UnmakerHit()
	{
		A_Explode(51, 151, 0);
		RSB_Impact.Land(self, "unmaker", (cos(angle) * cos(pitch), sin(angle) * cos(pitch), -sin(pitch)));
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	Death:
		TNT1 A 1 A_UnmakerHit();
		Stop;
	}
}

// ============================================================================
// THE MELT. Everything the Unmaker kills melts: white-hot on the instant, throbbing orange on the beam's
// beat as it falls, then sagging and spreading into red slag that burns away to nothing, with
// RS_Ballistics' smoke, embers and drips rising off it and a slag pool left under it (the owner, 09-14:
// "utterly MELT things"). Nothing gibs -- WM_UnmakerBolt is +NOEXTREMEDEATH -- this is its extreme death.
//
// ITS DEATH STILL PLAYS. The melt only changes how the body is drawn; its death states run underneath,
// so A_BossDeath, A_KeenDie and every other death special fire as they always did. The body leaves the
// world only once it lies still on its last frame (tics -1), after all of them.
//
// NEVER RAISED. The engine raises only corpses -- p_mobj.cpp GetRaiseState checks MF_CORPSE, for an
// Arch-vile and for Thing_Raise alike -- so the melt clears the corpse flag, every tic, because Die sets
// it after WorldThingDied, which is where the melt began.
//
// MONSTERS ONLY: never a player (a pawn is never removed), never a barrel or other shootable thing.
//
// NETPLAY. WorldThingDied runs on every machine, and the melt runs the same on each: its clock is its
// own age and level.maptime, it draws no random number, and it reads nothing local. The body's
// translation (TRNSLATE.txt), brightness, style, alpha and scale are actor state every machine sets
// alike. RS_Ballistics' unmaker_melt and unmaker_melt_pool only draw.
// ============================================================================

class WM_UnmakerMeltHandler : EventHandler
{
	override void WorldThingDied(WorldEvent e)
	{
		let body = e.Thing;
		if (!body || body.player || !body.bIsMonster) return;
		if (!e.Inflictor || !(e.Inflictor is "WM_UnmakerBolt")) return;
		let melt = WM_UnmakerMelt(Actor.Spawn("WM_UnmakerMelt", body.pos));
		if (melt) melt.Begin(body);
	}
}

class WM_UnmakerMelt : Actor
{
	// The melt's clock, in tics from the kill (35 a second).
	const HOT_END     = 8;        // white-hot
	const THROB_END   = 28;       // throbbing orange on the beam's beat while it falls
	const SAG_END     = 56;       // sagged and spread into red slag
	const GONE        = 74;       // burnt away to nothing
	const POOL_AT     = 24;       // RS_Ballistics' slag pool, once, as it starts to sag
	const FUMES_EVERY = 6;        // RS_Ballistics' smoke, embers and drips, this often until it's gone
	const WAIT_MAX    = 35 * 30;  // a death that never lies still: stop waiting, and leave it unseen

	int age;
	// How the body was drawn before: put back if it lives again after all (a script, a cheat).
	Vector2 bodyScale;
	TranslationID bodyTranslation;
	int bodyStyle;
	double bodyAlpha;
	bool bodyBright;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOSECTOR
		RenderStyle "None";
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}

	void Begin(Actor body)
	{
		tracer          = body;
		bodyScale       = body.Scale;
		bodyTranslation = body.Translation;
		bodyStyle       = body.GetRenderStyle();
		bodyAlpha       = body.Alpha;
		bodyBright      = body.bBright;
	}

	// Nothing to move, so no Super.Tick: only the body's look, and its fumes.
	override void Tick()
	{
		if (isFrozen()) return;
		let body = tracer;
		if (!body)
		{
			Destroy();
			return;
		}
		if (body.health > 0)
		{
			PutBack(body);
			Destroy();
			return;
		}
		body.bCorpse = false;

		int t = age++;
		if (t <= GONE)
		{
			MeltLook(body, t);
			if (t % FUMES_EVERY == 0) Fumes(body, "unmaker_melt");
			if (t == POOL_AT) Fumes(body, "unmaker_melt_pool");
			return;
		}
		// Burnt away and unseen. Out of the world once its death has played to its last frame; a death
		// that never lies still is simply left unseen.
		if (body.tics == -1)
		{
			body.Destroy();
			Destroy();
			return;
		}
		if (t > GONE + WAIT_MAX) Destroy();
	}

	// THE BODY, hotter than anything alive, on the beam's beat (sin(maptime x 72)).
	void MeltLook(Actor body, int t)
	{
		bool onBeat = sin(level.maptime * 72.0) > 0.0;
		body.bBright = true;
		if (t < HOT_END)
		{
			body.A_SetTranslation('WM_UnmakerWhiteHot');
		}
		else if (t < THROB_END)
		{
			if (onBeat) body.A_SetTranslation('WM_UnmakerWhiteHot');
			else        body.A_SetTranslation('WM_UnmakerOrange');
		}
		else if (t < SAG_END)
		{
			// Sagging into the floor and spreading across it, slow at first and then all at once.
			double s = Ease((t - THROB_END) / double(SAG_END - THROB_END));
			if (onBeat) body.A_SetTranslation('WM_UnmakerOrange');
			else        body.A_SetTranslation('WM_UnmakerRed');
			body.Scale = (bodyScale.x * (1.0 + 0.35 * s), bodyScale.y * (1.0 - 0.75 * s));
		}
		else
		{
			// Red slag burning away: added light that fades to nothing as it flattens.
			double s = (t - SAG_END) / double(GONE - SAG_END);
			body.A_SetTranslation('WM_UnmakerRed');
			body.A_SetRenderStyle(1.0 - s, STYLE_Add);
			body.Scale = (bodyScale.x * (1.35 + 0.15 * s), bodyScale.y * (0.25 - 0.17 * s));
		}
		if (t >= GONE) body.A_SetRenderStyle(0.0, STYLE_None);
	}

	static double Ease(double s)
	{
		return s * s * (3.0 - 2.0 * s);
	}

	// RS_Ballistics' fumes, off the floor under the body: traced down, so a body on a ledge or a lift
	// finds its own floor.
	void Fumes(Actor body, String impact)
	{
		let floorSurf = RSB_Materials.FloorUnder(body, body.pos + (0, 0, 8), 96);
		if (floorSurf) RSB_Impact.LandOn(body, floorSurf, impact, (0, 0, -1));
	}

	void PutBack(Actor body)
	{
		body.Translation = bodyTranslation;
		body.A_SetRenderStyle(bodyAlpha, bodyStyle);
		body.bBright = bodyBright;
		body.Scale = bodyScale;
	}
}

// WHAT IT IS DRAWN AS. The card's `prop`; MODELDEF binds the mesh and the hand.
class WM_PropUnmaker : WM_Prop {}
