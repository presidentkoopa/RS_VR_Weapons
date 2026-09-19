// ============================================================================
// THE LIGHTER IN FLIGHT -- what BL_Lighter becomes when it leaves your hand.
//
// The owner: "i can throw it and it does damage like a flare gun ok?"
//
// SO IT IS A FLARE, NOT A GRENADE. It does not detonate. It tumbles, it lands, and whatever it
// lands on catches -- which is exactly what BL_FlareGun's shot does, and is the one behaviour in
// this set that nothing else in the package has: a projectile whose work STARTS on impact instead
// of finishing there.
//
// IT KEEPS BURNING WHERE IT STOPS. A thrown lighter that explodes is a grenade with a Zippo
// texture; a thrown lighter that sets fire to the floor is a thrown lighter.
//
// TUMBLES ON ITS OWN AXIS, not on a measured wrist turn. It is thrown by the whole-weapon
// `type = thrown` path rather than by WM_ThrownGun's alt-button release, so no spin measurement
// reaches it -- unlike BW_ThrownAxe, which reads the three axes off the throw service. A lighter
// is small and light enough that a fast, slightly irregular tumble reads better than a measured
// one anyway: nobody throws a Zippo end over end deliberately.
// ============================================================================

class BL_ThrownLighter : Actor
{
	const TUMBLE_MIN = 14.0;    // degrees a tic
	const TUMBLE_MAX = 26.0;
	const BURN_TICS  = 245;     // about seven seconds of fire where it lands

	private double tumble, roll_;

	Default
	{
		Projectile;
		-NOGRAVITY;              // it is a lump of brass and it comes down
		Gravity 0.4;
		Radius 4;
		Height 4;
		Speed 22;
		Damage 0;                // the FIRE does the work, not the impact
		Scale 0.6;
		+FORCEXYBILLBOARD
		+THRUACTORS               // it is not a bullet; it should not stop on the first shoulder
		Obituary "%o was set alight.";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		// Its own tumble, randomised per throw. Two lighters thrown a second apart should not
		// spin in step -- that is what makes a handful of small objects read as objects rather
		// than as one effect repeated.
		tumble = FRandom(TUMBLE_MIN, TUMBLE_MAX) * RandomPick(-1, 1);
		roll_  = FRandom(TUMBLE_MIN, TUMBLE_MAX) * RandomPick(-1, 1);
		A_StartSound("blood/spraycan/zipopen", CHAN_BODY);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen()) return;
		Pitch = Pitch + tumble;
		Roll  = Roll  + roll_;
	}

	States
	{
	Spawn:
		WMPR A 1 Bright;
		Loop;
	Death:
		// IT LANDS AND IT STAYS LIT, and the fire is RS_Ballistics' rather than drawn here. The
		// owner's rule is that effect art is ours and never a source mod's -- ZBloody Hell's own
		// zippo_flame is deliberately not shipped -- and the ballistics lane owns a full flame
		// vocabulary already: flame_body, flame_core, flame_sheet, flame_licks, flame_embers.
		//
		// RSB_Impact.Land IS CALLED BY NAME AND THAT IS SAFE HERE, unlike the class reference
		// RS_Grenade had to remove. The owner's load order is Ballistics -> Reload -> Weapons, so
		// RSB_Impact is always resolved before this file is read -- and build.ps1 refuses to pack
		// this package at all without RS_Ballistics present. A reference that cannot be dangling
		// is not the coupling that broke the game three times; that one was to a pk3 that could
		// legitimately be absent or load later.
		//
		// THE IMPACT IS NAMED, NOT READ FROM A PROFILE KEY. A thrown weapon has no round in
		// flight for a roundprofile to describe, so the ballistics lane asked what this class
		// reads and the honest answer was "nothing" -- so it states the name itself.
		WMPR A 1 Bright
		{
			A_StartSound("blood/spraycan/fire", CHAN_BODY);
			RSB_Impact.Land(self, "bl_lighter", vel);
		}
		// IT KEEPS BURNING WHERE IT STOPPED. The hotspot rides whatever it landed on, so a man set
		// alight burns while he runs. The damage here is the WEAPON's; what the fire does to the
		// wall -- scorch, smoke, light -- is the ballistics lane's, the same boundary that keeps a
		// cartridge out of a weapon's damage.
		WMPR A BURN_TICS Bright A_Explode(8, 48, 0);
		Stop;
	}
}
