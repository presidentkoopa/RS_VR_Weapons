// ============================================================================
// THE NAPALM LAUNCHER'S SHOT -- Doom's Rocket cannot name its own impact, so this can.
//
// BL_Napalm fired a plain `Rocket` until now, which meant it landed as a rocket lands: a blast,
// and nothing left behind. Napalm's whole argument is what happens AFTER it stops.
//
// SO IT LEAVES A BURNING POOL THAT RIDES WHOEVER IS STANDING IN IT. That is the same capability
// the flare gun and the thrown lighter got this afternoon -- fire that FOLLOWS what it caught
// rather than marking the floor where it caught. A pool that stays put is a scorch mark; one that
// walks out of the room on a man's legs is a weapon.
//
// RSB_Impact.Land IS NAMED DIRECTLY, for the same reason it is on the thrown lighter: the owner's
// load order is Ballistics -> Reload -> Weapons, and build.ps1 refuses to pack this package at all
// without RS_Ballistics present. A reference that cannot dangle is not the coupling RS_Grenade had
// to remove -- that one was to a pk3 which could legitimately be absent or load later.
//
// THE BLAST DAMAGE IS THE WEAPON'S AND THE FIRE'S LOOK IS BALLISTICS'. Same boundary that keeps a
// cartridge out of a weapon's damage: what the pool does to a wall -- scorch, smoke, light -- is
// theirs; what it does to a man is ours.
// ============================================================================

class BL_NapalmRocket : Actor
{
	Default
	{
		Projectile;
		Radius 11;
		Height 8;
		Speed 28;                 // slower than a rocket: it is a lobbed canister of burning tar
		Damage 0;                 // the blast below does the work, not the touch
		+RANDOMIZE
		+DEHEXPLOSION
		SeeSound "blood/napalm/fire";
		DeathSound "blood/napalm/blast";
		Obituary "%o was cooked.";
	}

	States
	{
	Spawn:
		WMPR A 1 Bright;
		Loop;
	Death:
		WMPR A 1 Bright
		{
			// THE POOL. Named here rather than read from a key, because a projectile class is where
			// the impact actually happens and a `roundprofile` the class never consults is a
			// reference to nothing -- the silent failure this package keeps finding, pointed the
			// other way round.
			RSB_Impact.Land(self, "bl_napalm", vel);
		}
		WMPR A 3 Bright A_Explode(64, 128, 0);
		WMPR A 6 Bright;
		Stop;
	}
}
