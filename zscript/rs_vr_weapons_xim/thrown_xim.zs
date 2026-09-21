// ============================================================================
// WHAT THE XIM SET THROWS -- the thermal detonator in flight, in the BFG's slot and with the BFG's
// weight behind it: a bigger blast than the Wardusted one, and ballistics' sw_thermal_big look.
//
// ITS OWN CLASS, not the Wardusted set's: that one lives in another pack, and a set that borrowed it
// would not load without it. The gun's `shotclass` (WMSHEET.xim); it draws the mesh the hand held
// (`# flightclass`, WMCARD.xim -> MODELDEF).
// ============================================================================

class XM_ThrownThermal : Actor
{
	const FUSE_TICS = 105;          // three seconds
	int fuse;

	Default
	{
		Projectile;
		-NOGRAVITY;
		Gravity 0.5;
		Radius 4;
		Height 6;
		Speed 24;
		Damage 0;
		BounceType "Doom";
		BounceFactor 0.45;
		WallBounceFactor 0.5;
		BounceCount 8;
		+BOUNCEONACTORS
		+CANBOUNCEWATER
		Obituary "%o caught %k's thermal detonator.";
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || isFrozen()) return;
		if (++fuse >= FUSE_TICS) Blow();
	}

	void Blow()
	{
		A_StartSound("xim/thermal/boom", CHAN_BODY, CHANF_DEFAULT, 1.0, ATTN_NONE);
		A_Explode(300, 320);
		Vector3 travel = (Vel.Length() > 0.01) ? Vel.Unit() : (0, 0, -1);
		RSB_Impact.Land(self, "sw_thermal_big", travel, true);
		Destroy();
	}

	States
	{
	Spawn:
		WMPR A 1;
		Loop;
	Death:
		WMPR A -1;
		Stop;
	}
}
