// ============================================================================
// THROWN WEAPONS -- one thrower, for every gun whose card says `altmode = thrown`.
//
// THE ENGINE SIDE OF THIS WAS ALREADY BOUGHT AND PAID FOR. RS_WorldHands carries
// RS_ThrowService (zscript/hands/rs_throw.zs), which answers velocity, spin, and
// whether a release was a throw at all -- measured off AttackVel / OffhandVel,
// OpenXR's own controller velocity, which is true instantaneous hand speed rather
// than a position difference smeared over a tic. Spin is real too: RS_Swing
// averages per-tic angular deltas out of a ring buffer with Wrap180, so a wrist
// crossing 360 does not read as a 359-degree flick.
//
// WHAT WAS MISSING WAS NEVER THE PHYSICS. It was that every throwable had to be a
// HANDWRITTEN CLASS that talks to that service. RS_Grenade is two hundred lines of
// arming window, pin, hand identity, swing samples and fallback. The ShieldSaw
// wrote its own. The Axe would have been a third, the satchel charge a fourth, the
// card deck a fifth, and Blood's dynamite and voodoo doll a sixth and seventh --
// and RS_Throw's own header records what that costs: "the same flick threw three
// objects three different distances."
//
// So this is that code lifted ONCE, and a gun becomes throwable by card.
//
// BY SERVICE, NEVER BY CLASS. RS_Grenade deliberately removed its RS_Throw
// reference because the coupling "broke the whole game three separate times across
// three folder layouts" -- a ZScript class reference to a pk3 that is absent, or
// that loads later, is fatal AND global, and takes down every mod after it. A
// service has no such coupling: ask, and if nothing answers, use your own. This
// pk3 therefore throws correctly on its own, and better when RS_WorldHands is
// loaded, and names nothing in it either way.
//
// ALL THREE SPIN AXES ARE HANDED TO THE FLYING ACTOR AND NONE ARE INTERPRETED
// HERE. A shield takes roll alone and frisbees; an axe wants pitch and tumbles.
// That is a decision about what the object IS, so it belongs to the actor, which
// already has somewhere to put it -- not to a fourth card key that would make two
// objects behaving differently into two card dialects.
// ============================================================================

class WM_ThrownGun : WM_Gun
{
	// THE FALLBACK'S WINDOW, and only the fallback's. ~180ms at 35 tics: a throw's
	// release lands slightly AFTER peak hand speed, so the peak of a short window is
	// the throw and the instant of release is not. When RS_ThrowService answers, none
	// of this runs -- it has already done the same job better, and against the same
	// rs_throw_min every other thrown object in the game is judged by.
	const WM_SWING_SAMPLES = 7;
	private Vector3 swing[WM_SWING_SAMPLES];
	private int swingAt;
	private bool swingFilled;

	// Which physical hand this weapon is in. The engine already knows; a gun's hand is
	// baked into its class at load from the card's `hand`, and cannot change in play.
	int ThrowHand() const { return bOffhandWeapon ? 1 : 0; }

	// Palm centre. RS_Reach.Centre would refine this to the world hand's HANDPALM_joint
	// bone and apply the player's grab-volume offsets; this does not, for the same
	// reason RS_Grenade's copy does not -- an object drawn at its own tuned offset from
	// the controller is already anchored, and the bone would be a second opinion.
	Vector3 ThrowOrigin(PlayerPawn pmo) const
	{
		return (ThrowHand() == 0) ? pmo.AttackPos : pmo.OffhandPos;
	}

	// ---- THE SAMPLE RING ---------------------------------------------------
	//
	// Fed every tic the weapon is in a hand. Native velocity, NOT a position
	// difference: AttackVel / OffhandVel are the controller's motion through the play
	// area, so walking a simulated body through the level does not enter into them and
	// there is nothing to subtract back out. The player's own velocity is added once,
	// at the end, because a thrown object's world velocity is hand motion plus player
	// motion however the hand motion was measured.
	void SampleSwing(PlayerPawn pmo)
	{
		swing[swingAt] = (ThrowHand() == 0) ? pmo.AttackVel : pmo.OffhandVel;
		swingAt = (swingAt + 1) % WM_SWING_SAMPLES;
		if (swingAt == 0) swingFilled = true;
	}

	private Vector3 SwingPeak(PlayerPawn pmo) const
	{
		Vector3 best = (0, 0, 0);
		double bestLen = -1;
		int n = swingFilled ? WM_SWING_SAMPLES : swingAt;
		for (int i = 0; i < n; i++)
		{
			double l = swing[i].Length();
			if (l > bestLen) { bestLen = l; best = swing[i]; }
		}
		return best + pmo.Vel;
	}

	// ---- THE THROW ---------------------------------------------------------
	//
	// Returns a zero vector when the release was not a throw. A release with no arm
	// behind it drops the thing at your feet, and that line is drawn ONCE for the whole
	// game -- ask the service which this was rather than inventing a second threshold
	// that could disagree with every other thrown object.
	//
	// `weight` is the object's own: a grenade is heavier than a magazine and lighter
	// than a barrel. That is a fact about the thing, not a setting about the player, so
	// it multiplies the measured throw rather than replacing it.
	Vector3 MeasureThrow(PlayerPawn pmo, double weight = 1.0)
	{
		int hand = ThrowHand();

		ServiceIterator sit = ServiceIterator.Find("RS_ThrowService");
		Service sv;
		while (sv = sit.Next())
		{
			// ServiceIterator matches a case-insensitive SUBSTRING of the class name, so
			// finding something proves nothing on its own. The handshake proves it.
			if (sv.GetInt("throw.hello", "", 0, 0, null, 'None') != 1) continue;

			if (sv.GetInt("throw.iscast", "", hand, 0, pmo, 'WM_ThrownGun') != 1)
				return (0, 0, 0);

			// Thousandths: a Service returns an int, and a throw needs finer resolution
			// than whole units per tic.
			Vector3 v = ( sv.GetInt("throw.vel.x", "", hand, 0, pmo, 'WM_ThrownGun') / 1000.0,
			              sv.GetInt("throw.vel.y", "", hand, 0, pmo, 'WM_ThrownGun') / 1000.0,
			              sv.GetInt("throw.vel.z", "", hand, 0, pmo, 'WM_ThrownGun') / 1000.0 );
			// Already arced and already carrying the player's own velocity. Only the
			// object's weight is left.
			return v * weight;
		}

		// LOCAL FALLBACK -- this pk3 on its own, with RS_WorldHands absent.
		//
		// The same drop test as the shared path, against the hand's own motion with the
		// player's walk taken back out: strolling past should never be what makes a
		// release count as a throw.
		Vector3 raw = SwingPeak(pmo) - pmo.Vel;
		if (raw.Length() < 1.17) return (0, 0, 0);

		Vector3 v = SwingPeak(pmo) * weight;
		// THE ARC. A flat throw of a heavy object reads as a shove; a little lift makes
		// it read as thrown. RS_Grenade invented this as rsvg_lift and it is everyone's
		// now -- the shared path above has already applied its own, which is why this
		// only runs here.
		double flat = (v.x, v.y, 0).Length();
		v.z += flat * 0.35;
		return v;
	}

	// Spin, all three axes, uninterpreted. Zero when nothing answers: the local fallback
	// measures linear velocity only, and an object that flies straight and does not
	// tumble is a worse throw rather than a broken one.
	Vector3 MeasureSpin(PlayerPawn pmo) const
	{
		int hand = ThrowHand();
		ServiceIterator sit = ServiceIterator.Find("RS_ThrowService");
		Service sv;
		while (sv = sit.Next())
		{
			if (sv.GetInt("throw.hello", "", 0, 0, null, 'None') != 1) continue;
			return ( sv.GetInt("throw.spin.yaw",   "", hand, 0, pmo, 'WM_ThrownGun') / 1000.0,
			         sv.GetInt("throw.spin.pitch", "", hand, 0, pmo, 'WM_ThrownGun') / 1000.0,
			         sv.GetInt("throw.spin.roll",  "", hand, 0, pmo, 'WM_ThrownGun') / 1000.0 );
		}
		return (0, 0, 0);
	}

	// ---- THE BUTTON --------------------------------------------------------
	//
	// AltPressed / AltReleased are WM_Gun's, fired off the SAME altNow/altWasDown edge that
	// drives select fire. One detector for the whole package: a second one of my own would
	// sooner or later be a tic out of step with that one, and a thrower that disagrees with
	// the state machine about when the button changed reads as "sometimes it just does not
	// throw", which is the worst possible thing to chase while wearing a headset.
	//
	// NEITHER HOOK IS GATED ON A MODE and that is right -- the edges are a general
	// capability and the mode is this class's business. Hence the ThrowsOnAlt() test here
	// rather than upstream.
	private int windUp;
	private bool winding;

	override void AltPressed()
	{
		Super.AltPressed();
		if (!ThrowsOnAlt()) return;
		windUp = 0;
		winding = true;
	}

	override void AltReleased()
	{
		Super.AltReleased();
		if (!winding) return;
		winding = false;
		if (!ThrowsOnAlt()) return;

		// THE WIND-UP IS A MINIMUM, NOT A TIMER. Let go early and nothing leaves your hand:
		// `throwtics` is how long before the thing CAN go, so a twitch on the button is not a
		// throw any more than a release with no arm behind it is.
		if (windUp < ThrowTicsEach()) return;

		let pmo = PlayerPawn(Owner);
		if (!pmo) return;

		// RESOLVED HERE, NOT AT PARSE TIME, and this is the reload lane's call rather than
		// mine: a sheet is read when the sheet loads, and the actor it names may live in a pk3
		// that loads later. Refusing an unresolved name at parse would make LOAD ORDER decide
		// whether a card is valid, which is the same class of trap as a class reference across
		// archives. So it resolves at the moment of the throw -- and fails LOUDLY, because a
		// silent miss here is a button that does nothing.
		Class<Actor> what = (Class<Actor>)(Object.FindClass(throwClassName, "Actor"));
		if (!what)
		{
			Console.Printf("\c[Red]%s: throwclass \"%s\" is not an actor -- nothing to throw.",
			               GetClassName(), throwClassName);
			return;
		}

		Vector3 v = MeasureThrow(pmo);
		if (v.Length() <= 0) return;      // a release with no arm behind it drops it at your feet
		ReleaseThrown(what, v, MeasureSpin(pmo));
	}

	// Fed every tic the weapon is owned: the swing ring for the local fallback, and the
	// wind-up counter. Both are cheap and neither is worth a second virtual.
	override void DoEffect()
	{
		Super.DoEffect();
		let pmo = PlayerPawn(Owner);
		if (!pmo) return;
		SampleSwing(pmo);
		if (winding) windUp++;
	}

	// ---- RELEASE -----------------------------------------------------------
	//
	// Spawns the card's `throwclass` at the palm, gives it the measured velocity and
	// hands it the spin to do with as it likes. Returns the actor so a caller can dress
	// it further -- the thrower does not own what the thing does once it has left.
	//
	// THE SPIN IS PASSED, NOT APPLIED. Writing it into Angles here would decide that
	// every thrown object tumbles the same way, which is exactly the decision that
	// belongs to the object.
	Actor ReleaseThrown(Class<Actor> what, Vector3 vel, Vector3 spin)
	{
		let pmo = PlayerPawn(Owner);
		if (!pmo || !what) return null;

		Vector3 at = ThrowOrigin(pmo);
		let a = Actor.Spawn(what, at, ALLOW_REPLACE);
		if (!a) return null;

		a.target = pmo;
		a.Vel = vel;
		a.Angle = pmo.Angle;

		// THE SPIN IS HANDED OVER TYPED, OR NOT AT ALL. A_SetUserVar would have meant
		// every throwclass had to declare three user vars it might never read, and a
		// name that does not exist there is a runtime fault rather than a compile one --
		// silent until someone throws the thing. A cast costs nothing and a throwclass
		// that does not care about spin simply is not a WM_ThrownObject.
		let t = WM_ThrownObject(a);
		if (t)
		{
			t.spinYaw   = spin.x;
			t.spinPitch = spin.y;
			t.spinRoll  = spin.z;
			t.Launched();
		}
		return a;
	}
}

// ============================================================================
// WHAT FLIES -- the base for anything a WM_ThrownGun lets go of.
//
// It exists to carry the spin across the handover with a type on it, and to give the
// object one place to decide what it does with it. Everything else about a thrown
// thing -- how much damage it does, whether it sticks, bounces, explodes or comes
// back -- is the object's own and is deliberately not here.
//
// A SHIELD TAKES ROLL ALONE AND FRISBEES. AN AXE WANTS PITCH AND TUMBLES. Those are
// two actors behaving differently, which is right; making it a card key would have
// made them two card dialects, which is not.
// ============================================================================
class WM_ThrownObject : Actor
{
	// Degrees per tic, as the controller actually turned. Wrap180 has already been
	// applied upstream, so a wrist crossing 360 reads as a small turn and not a flick.
	double spinYaw, spinPitch, spinRoll;

	// Called once, on the tic it leaves the hand, after the spin is set and the
	// velocity is on. Override to decide what kind of thrown thing this is.
	virtual void Launched() {}
}
