// ============================================================================
// WHAT DRAWS THE LIGHTSABER -- the hilt, the blade, and the light it throws on the walls.
//
// THE SHIELDSAW'S PATTERN, and the reason the blade can be solid. RS_ShieldSawWorld spawns a prop per
// hand and MODELDEF's FollowMainHand / FollowOffHand places it off the CONTROLLER, in the renderer,
// at draw rate. Nothing moved by the playsim can do that: the playsim runs at 35 a second and the
// hand does not. A blade that lagged the hand by a tic would read as a blade on a string. So the
// blade is a model on a prop, and it cannot lag.
//
// TWO PROPS A HAND, NOT ONE. The hilt is an ordinary textured object and the blade is ADDITIVE light;
// a model has one render style, so they are two actors sharing one set of placement sliders.
//
// THE COLOUR IS THE BLADE'S CLASS. Each colour is its own prop class wearing its own skins (generated,
// rs_lightsaber_blades.zs). Change rs_saber_color and the next tic swaps the prop.
//
// ONLY consoleplayer, AS THE SHIELDSAW DOES, and for the same reason: FollowMainHand is the LOCAL
// controller. There is no way to draw another player's saber off his controller from this machine.
// ============================================================================

// THE BLADE PROP. Additive and full-bright: it is light, not a surface.
class RS_SaberBladeProp : Actor
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
		SBLD A -1 Bright;
		stop;
	}
}

// THE HILT PROP. An ordinary object in the hand.
class RS_SaberHiltProp : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
	}
	States
	{
	Spawn:
		SBLD A -1;
		stop;
	}
}
class RS_SaberHilt : RS_SaberHiltProp {}
class RS_SaberHiltOff : RS_SaberHiltProp {}

// THE LIGHT ON THE WALLS. Invisible; it only carries the dynamic light, and sits halfway down the
// blade so the glow is where the blade is, not at the fist.
class RS_SaberLight : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A -1;
		stop;
	}
}

class RS_LightsaberWorld : EventHandler
{
	private Actor hilt[2], blade[2], glow[2];
	private int   bladeColor[2];
	private int   glowRadius[2];

	// THE SECOND BLADE, out of the pommel, and its own light -- the double-bladed saber.
	private Actor back[2], backGlow[2];
	private int   backColor[2];
	private int   backGlowRadius[2];

	// THE GRIP LAST TIC, per hand, for the release edge that is a throw. Updated EVERY tic whatever
	// else happens: the shieldsaw learned that gating the update behind the same conditions as the
	// action leaves it stale, and a stale "was held" fires a throw nobody made.
	private bool gripWas[2];

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = PlayerPawn(p.mo);
		if (!pmo) return;

		for (int h = 0; h < 2; ++h)
		{
			// THE GRIP, READ FIRST AND REMEMBERED WHATEVER HAPPENS BELOW. Read after the saber check,
			// a hand with no saber in it never updated gripWas -- so gripping with an empty hand,
			// drawing a saber, and letting go fired a throw from a squeeze that was never on it.
			bool grip = (h == 0) ? pmo.GripHeldMain : pmo.GripHeldOff;
			bool released = !grip && gripWas[h];
			gripWas[h] = grip;

			let saber = RS_LightsaberBase((h == 0) ? p.ReadyWeapon : p.OffhandWeapon);
			if (!saber)
			{
				Clear(h);
				continue;
			}

			Vector3 hand = (h == 0) ? pmo.AttackPos : pmo.OffhandPos;

			// THE THROW: squeeze, swing, let go. A release while the hand is MOVING is a throw; a
			// release at rest is you simply letting go of the grip, and nothing leaves the hand.
			if (released && !saber.IsThrown() && saber.ext > 0)
			{
				Vector3 hv = (h == 0) ? pmo.AttackVel : pmo.OffhandVel;
				// MAP UNITS PER SECOND, not per tic -- the hand's velocity is not pmo.Vel.
				if (hv.Length() >= Flag("rs_saber_throw_min", 80.0))
				{
					Vector3 rel = RS_LightsaberBase.MeasureRelease(pmo, h);
					// NO THROW SERVICE LOADED: the hand's own velocity is the next best direction.
					if (rel.Length() < 0.001) rel = hv;
					// THE HAND RIDES IN THE NAME: a net event carries only three numbers, and the
					// velocity needs all three.
					SendNetworkEvent((h == 0) ? "rs-saber-throw0" : "rs-saber-throw1",
						int(rel.x), int(rel.y), int(rel.z));
				}
			}

			// IN THE AIR, NOT IN THE HAND: nothing held is drawn until it is caught.
			if (saber.IsThrown())
			{
				Clear(h);
				continue;
			}

			// THE HILT, always, while it is in the hand -- lit or not.
			if (!hilt[h]) hilt[h] = Actor.Spawn((h == 0) ? "RS_SaberHilt" : "RS_SaberHiltOff", hand, NO_REPLACE);
			if (hilt[h]) hilt[h].SetOrigin(hand, true);

			int col = saber.ColorIndex();

			// THE BACK BLADE, handled first and on its own: it is lit or not whatever the front is,
			// and wears its own colour if one is set.
			TendBack(h, saber, hand, saber.BackColorIndex());

			// THE FRONT BLADE, only while any of it is out. Frame 0 is folded into the emitter, and
			// a folded blade drawn additive is a speck of light at the fist -- so it is not drawn.
			if (saber.ext <= 0)
			{
				KillBlade(h);
				continue;
			}

			if (blade[h] && bladeColor[h] != col) KillBlade(h);       // colour changed: swap it
			if (!blade[h])
			{
				blade[h] = Actor.Spawn(RS_SaberColors.ClassFor(col, h == 1), hand, NO_REPLACE);
				bladeColor[h] = col;
				glowRadius[h] = -1;
			}
			if (blade[h])
			{
				blade[h].SetOrigin(hand, true);
				// HOW FAR OUT IT IS, as the model's frame: the extension the weapon counted.
				blade[h].frame = clamp(saber.ext, 0, RS_LightsaberBase.EXT_FULL);
			}

			// THE LIGHT, halfway down the blade, growing as it extends.
			Vector3 mid = saber.FrontMid();
			if (!glow[h]) glow[h] = Actor.Spawn("RS_SaberLight", mid, NO_REPLACE);
			if (glow[h])
			{
				glow[h].SetOrigin(mid, true);
				int rad = int(40 + 60 * (saber.ext / double(RS_LightsaberBase.EXT_FULL)));
				if (rad != glowRadius[h])
				{
					glow[h].A_AttachLight('saberglow', DynamicLight.PointLight,
						RS_SaberColors.LightFor(col), rad, rad, DynamicLight.LF_ATTENUATE);
					glowRadius[h] = rad;
				}
			}
		}
	}

	// THE THROW, ON EVERY MACHINE. Measured on the thrower's, applied everywhere from the same numbers,
	// so the saber flies the same path for everyone.
	override void NetworkProcess(ConsoleEvent e)
	{
		int h = -1;
		if (e.Name == "rs-saber-throw0") h = 0;
		else if (e.Name == "rs-saber-throw1") h = 1;
		if (h < 0) return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let p = players[e.Player];
		if (!p.mo) return;
		let saber = RS_LightsaberBase((h == 0) ? p.ReadyWeapon : p.OffhandWeapon);
		if (saber) saber.Throw((e.Args[0], e.Args[1], e.Args[2]));
	}

	private static double Flag(String n, double fb)
	{
		let c = CVar.FindCVar(n);
		return c ? c.GetFloat() : fb;
	}

	// THE SECOND BLADE AND ITS LIGHT: spawned in its colour, placed on the hand, its frame the
	// back blade's own extension, and the light halfway down it.
	private void TendBack(int h, RS_LightsaberBase saber, Vector3 hand, int col)
	{
		if (saber.extBack <= 0)
		{
			KillBack(h);
			return;
		}
		if (back[h] && backColor[h] != col) KillBack(h);
		if (!back[h])
		{
			back[h] = Actor.Spawn(RS_SaberColors.BackClassFor(col, h == 1), hand, NO_REPLACE);
			backColor[h] = col;
			backGlowRadius[h] = -1;
		}
		if (back[h])
		{
			back[h].SetOrigin(hand, true);
			back[h].frame = clamp(saber.extBack, 0, RS_LightsaberBase.EXT_FULL);
		}
		Vector3 mid = saber.BackMid();
		if (!backGlow[h]) backGlow[h] = Actor.Spawn("RS_SaberLight", mid, NO_REPLACE);
		if (backGlow[h])
		{
			backGlow[h].SetOrigin(mid, true);
			int rad = int(40 + 60 * (saber.extBack / double(RS_LightsaberBase.EXT_FULL)));
			if (rad != backGlowRadius[h])
			{
				backGlow[h].A_AttachLight('saberglow', DynamicLight.PointLight,
					RS_SaberColors.LightFor(col), rad, rad, DynamicLight.LF_ATTENUATE);
				backGlowRadius[h] = rad;
			}
		}
	}

	private void KillBack(int h)
	{
		if (back[h])     { back[h].Destroy();     back[h] = null; }
		if (backGlow[h]) { backGlow[h].Destroy(); backGlow[h] = null; }
		backGlowRadius[h] = -1;
	}

	private void KillBlade(int h)
	{
		if (blade[h]) { blade[h].Destroy(); blade[h] = null; }
		if (glow[h])  { glow[h].Destroy();  glow[h] = null; }
		glowRadius[h] = -1;
	}

	private void Clear(int h)
	{
		KillBlade(h);
		KillBack(h);
		if (hilt[h]) { hilt[h].Destroy(); hilt[h] = null; }
	}

	// A NEW MAP STARTS WITH NOTHING. The props belong to the level they were spawned in.
	override void WorldUnloaded(WorldEvent e)
	{
		for (int h = 0; h < 2; ++h)
		{
			hilt[h] = null;
			blade[h] = null;
			glow[h] = null;
			glowRadius[h] = -1;
			back[h] = null;
			backGlow[h] = null;
			backGlowRadius[h] = -1;
		}
	}
}
