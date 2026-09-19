// ============================================================================
// THE AXE IN FLIGHT -- BW_Axe's thrown secondary, and the first caller of the
// shared thrower.
//
// The owner: "bw_axe is a melee wiuth a secondary of a throwable". It swings in your
// hand and it leaves it, and neither half is the whole weapon.
//
// IT TUMBLES ON PITCH, WHICH IS THE ONLY DECISION THIS FILE MAKES. The ShieldSaw takes
// roll alone and frisbees; an axe goes end over end. Both read the same three spin axes
// off the same measurement and disagree about which one matters, which is exactly why
// the spin is handed over uninterpreted instead of being a card key -- two objects
// behaving differently rather than two card dialects.
//
// A FLOOR UNDER THE TUMBLE. A gentle release measures almost no wrist rotation, and an
// axe that flies dead flat looks broken rather than gentle. So the measured pitch sets
// the tumble where there is one, and a minimum applies where there is not: thrown
// weakly it still turns over, just slowly.
// ============================================================================

class BW_ThrownAxe : WM_ThrownObject
{
	const MIN_TUMBLE = 9.0;    // degrees a tic, floor -- about a turn and a half a second
	const MAX_TUMBLE = 34.0;   // and a ceiling, so a hard flick does not strobe

	private double tumble;

	Default
	{
		Projectile;
		-NOGRAVITY;              // it is an axe, and it comes down
		Gravity 0.35;
		Radius 8;
		Height 8;
		Speed 0;                 // the thrower sets the velocity; nothing here should override it
		Damage 0;                // dealt on impact below, scaled by how fast it was going
		+FORCEXYBILLBOARD
		Obituary "%o was split by a flying axe.";
	}

	// Called by WM_ThrownGun on the tic it leaves the hand, after the spin and velocity
	// are set. The measured pitch is degrees per tic as the controller actually turned.
	override void Launched()
	{
		tumble = clamp(abs(spinPitch), MIN_TUMBLE, MAX_TUMBLE);
		// Keep the direction of the wrist: an underarm throw turns the other way, and it
		// is the kind of thing nobody notices until it is wrong.
		if (spinPitch < 0) tumble = -tumble;
		A_StartSound("bwolf/axe/fire", CHAN_BODY);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen()) return;
		// PITCH ONLY. Yaw and roll were measured and are deliberately ignored here -- an axe
		// that also yaws reads as tumbling badly rather than tumbling.
		Pitch = Pitch + tumble;
	}

	// HOW HARD IT LANDS IS HOW HARD IT WAS THROWN. A lobbed axe bruises; one thrown at the
	// wall behind someone's head does not. Reading it off the velocity at impact means the
	// player's arm sets the damage, which is the whole argument for measuring the throw at
	// all rather than issuing a fixed projectile.
	override int DoSpecialDamage(Actor victim, int damage, Name damageType)
	{
		double speed = Vel.Length();
		return int(clamp(speed * 1.6, 12, 90));
	}

	States
	{
	Spawn:
		WMPR A -1;
		Stop;
	Death:
		WMPR A 1 A_StartSound("bwolf/axe/hit", CHAN_BODY);
		WMPR A 8;
		Stop;
	}
}
