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

	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = PlayerPawn(p.mo);
		if (!pmo) return;

		for (int h = 0; h < 2; ++h)
		{
			let saber = RS_LightsaberBase((h == 0) ? p.ReadyWeapon : p.OffhandWeapon);
			if (!saber)
			{
				Clear(h);
				continue;
			}

			Vector3 hand = (h == 0) ? pmo.AttackPos : pmo.OffhandPos;

			// THE HILT, always, while it is in the hand -- lit or not.
			if (!hilt[h]) hilt[h] = Actor.Spawn((h == 0) ? "RS_SaberHilt" : "RS_SaberHiltOff", hand, NO_REPLACE);
			if (hilt[h]) hilt[h].SetOrigin(hand, true);

			// THE BLADE, only while any of it is out. Frame 0 is folded into the emitter, and a
			// folded blade drawn additive is a speck of light at the fist -- so it is not drawn.
			if (saber.ext <= 0)
			{
				KillBlade(h);
				continue;
			}

			int col = saber.ColorIndex();
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
			Vector3 mid = saber.HandPos() + saber.BladeDir() * (saber.BladeLen() * 0.5);
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

	private void KillBlade(int h)
	{
		if (blade[h]) { blade[h].Destroy(); blade[h] = null; }
		if (glow[h])  { glow[h].Destroy();  glow[h] = null; }
		glowRadius[h] = -1;
	}

	private void Clear(int h)
	{
		KillBlade(h);
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
		}
	}
}
