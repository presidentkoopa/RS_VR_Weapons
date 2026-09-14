// ============================================================================
// THE VANILLA WEAPON SET -- how Doom's weapons on a map become ours, and what a
// fresh start carries.
//
// The owner, 09-14: the guns built here ARE the Vanilla and Vanilla+ weapons.
// Vanilla is those guns behaving like Doom's, and for now ONE GUN PER PICKUP
// ("there will be an options menu but for now yes one gun per pickup").
//
// ------------------------------------------------------------ ONE GUN PER PICKUP
//
// Every Doom weapon a map places or a monster drops is replaced
// (WM_WeaponSet.CheckReplacement, below) by a pickup that keeps Doom's floor
// sprite and gives the next gun of its pair you do not carry yet, main hand first:
//
//   Doom's          first pickup       second pickup     ammo with it
//   Pistol          M4A3               9mm Handgun       20 Clip
//   Shotgun         M37A2              Doom shotgun       8 Shell
//   SuperShotgun    Super Shotgun      Double Barrel      8 Shell
//   Chaingun        Chaingun           Machine Gun       20 Clip
//   RocketLauncher  Rocket Launcher    RPG                2 RocketAmmo
//   PlasmaRifle     Plasma Rifle       Plasma Carbine    40 Cell
//   BFG9000         BFG                Heavy BFG         40 Cell
//   Chainsaw        Chainsaw           Heavy Chainsaw     none
//
// THE AMMO is each Doom weapon's Weapon.AmmoGive, counted as Weapon.AddAmmo and
// AddExistingAmmo count it: half from a dropped one (the skill's drop factor),
// the skill's ammo factor, 5/2 in Doom deathmatch when a gun comes with it, and
// never past the reserve's cap. Once you carry both guns it is ammo alone, and a
// full reserve leaves it lying, as Doom's does.
//
// THE GUN is picked up the way Doom's own weapon is (its CallTryPickup, so its
// AttachToOwner): it comes up in its own hand unless you never switch on pickup.
//
// WEAPONS STAY (a co-op game, or sv_weaponstay), exactly as Weapon.ShouldStay:
// it stays where it lies, each player takes each gun from it once, and it never
// gives ammo alone.
//
// ------------------------------------------------------------ A FRESH START
//
// A NEW GAME STARTS LIKE DOOM (the owner, 09-14): WM_Player (loadout.zs) carries the
// whole test arsenal, and wm_start_arsenal OFF -- the default -- trims a fresh start
// to Doom's with a gun for each hand: both fists, the M4A3 and the 9mm Handgun (each
// with the full magazine the reload system gives it), 50 Clip. ON keeps the arsenal
// for calibrating. A server cvar, on the "VR Weapons -- weapon set" page.
//
// NETPLAY: the replacement runs in the playsim on every machine, and a pickup
// decides from what its toucher carries, which every machine agrees on; the start
// reads a server cvar. No random call, nothing keyed to the console player.
// ============================================================================

// THE PICKUP BEHIND EVERY DOOM WEAPON. Each subclass names its pair, Doom's ammo
// and Doom's floor sprite.
class WM_PairPickup : Inventory abstract
{
	Class<Weapon> mainGun, offGun;
	Class<Ammo>   ammoType;
	int           ammoGive;
	// What this pickup just gave, for PickupMessage: Touch prints the message of
	// the same object whose TryPickup ran.
	String        gotMessage;

	property Guns: mainGun, offGun;
	property AmmoType: ammoType;
	property AmmoGive: ammoGive;

	Default
	{
		Inventory.PickupSound "misc/w_pkup";
		+WEAPONSPAWN
	}

	// WEAPON.SHOULDSTAY, word for word: a co-op game or sv_weaponstay keeps a
	// weapon where it lies, unless it was dropped.
	override bool ShouldStay()
	{
		return ((multiplayer && (!deathmatch && !alwaysapplydmflags)) || sv_weaponstay) && !bDropped;
	}

	// A DROPPED ONE carries the skill's drop share of Doom's ammo, as
	// Weapon.ModifyDropAmount: half, counted with the skill's ammo factor, unless
	// the skill names its own drop factor.
	override void ModifyDropAmount(int dropamount)
	{
		Super.ModifyDropAmount(dropamount);
		bool ignoreskill = true;
		double dropammofactor = G_SkillPropertyFloat(SKILLP_DropAmmoFactor);
		if (dropammofactor == -1)
		{
			dropammofactor = 0.5;
			ignoreskill = false;
		}
		ammoGive = int(ammoGive * dropammofactor);
		bIgnoreSkill = ignoreskill;
	}

	// A LOCAL COPY (sv_localitems) keeps what the original would give, and whether
	// it was dropped -- a copy that forgot it would think it stays, and linger.
	override Inventory CreateCopy(Actor other)
	{
		let copy = WM_PairPickup(Super.CreateCopy(other));
		if (copy && copy != self)
		{
			copy.ammoGive     = ammoGive;
			copy.bIgnoreSkill = bIgnoreSkill;
			copy.bDropped     = bDropped;
		}
		return copy;
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || !toucher.player) return false;
		bool stay = ShouldStay();

		// THE NEXT GUN OF THE PAIR this player does not carry, main hand first.
		Class<Weapon> next = null;
		if (mainGun && !toucher.FindInventory(mainGun))     next = mainGun;
		else if (offGun && !toucher.FindInventory(offGun))  next = offGun;

		// Weapons stay: a gun each, never ammo alone.
		if (!next && stay) return false;

		bool gotAmmo = GiveAmmoTo(toucher, next != null);
		// Both carried and the reserve full: it stays on the floor, as Doom's does.
		if (!next && !gotAmmo) return false;

		gotMessage = "";
		if (next)
		{
			let gun = Weapon(Spawn(next, toucher.Pos, NO_REPLACE));
			if (gun)
			{
				gun.ClearCounters();
				String gunTag = gun.GetTag();
				if (gun.CallTryPickup(toucher)) gotMessage = String.Format("You got the %s!", gunTag);
				else gun.Destroy();
			}
		}

		if (!stay) GoAwayAndDie();
		return true;
	}

	override String PickupMessage()
	{
		return (gotMessage.Length() > 0) ? gotMessage : PickupMsg;
	}

	// DOOM'S AMMO, the way Weapon.AddAmmo (with a gun) and AddExistingAmmo (alone)
	// count it. False when none went in: nothing to give, or the reserve is full.
	private bool GiveAmmoTo(Actor toucher, bool withGun)
	{
		if (!ammoType || ammoGive <= 0) return false;
		int amount = ammoGive;
		if (withGun && deathmatch && !sv_noextraammo && (gameinfo.gametype & GAME_DoomChex))
		{
			amount = amount * 5 / 2;
		}
		if (!bIgnoreSkill)
		{
			amount = int(amount * (G_SkillPropertyFloat(SKILLP_AmmoFactor) * sv_ammofactor));
		}
		if (amount <= 0) return false;

		let have = Ammo(toucher.FindInventory(ammoType));
		if (!have)
		{
			let fresh = Ammo(Spawn(ammoType));
			if (!fresh) return false;
			fresh.Amount = min(amount, fresh.MaxAmount);
			fresh.AttachToOwner(toucher);
			return true;
		}
		if (have.Amount >= have.MaxAmount && !sv_unlimited_pickup) return false;
		have.Amount += amount;
		if (have.Amount > have.MaxAmount && !sv_unlimited_pickup) have.Amount = have.MaxAmount;
		return true;
	}
}

class WM_PickupPistol : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_M4A3", "WM_Pistolet";
		WM_PairPickup.AmmoType "Clip";
		WM_PairPickup.AmmoGive 20;
		Inventory.PickupMessage "$PICKUP_PISTOL_DROPPED";
		Tag "$TAG_PISTOL";
	}
	States
	{
	Spawn:
		PIST A -1;
		Stop;
	}
}

class WM_PickupShotgun : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_PumpM37", "WM_PumpDoom";
		WM_PairPickup.AmmoType "Shell";
		WM_PairPickup.AmmoGive 8;
		Inventory.PickupMessage "$GOTSHOTGUN";
		Tag "$TAG_SHOTGUN";
	}
	States
	{
	Spawn:
		SHOT A -1;
		Stop;
	}
}

class WM_PickupSuperShotgun : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_SSG", "WM_DoubleBarrel";
		WM_PairPickup.AmmoType "Shell";
		WM_PairPickup.AmmoGive 8;
		Inventory.PickupMessage "$GOTSHOTGUN2";
		Tag "$TAG_SUPERSHOTGUN";
	}
	States
	{
	Spawn:
		SGN2 A -1;
		Stop;
	}
}

class WM_PickupChaingun : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_Chaingun", "WM_MachineGun";
		WM_PairPickup.AmmoType "Clip";
		WM_PairPickup.AmmoGive 20;
		Inventory.PickupMessage "$GOTCHAINGUN";
		Tag "$TAG_CHAINGUN";
	}
	States
	{
	Spawn:
		MGUN A -1;
		Stop;
	}
}

class WM_PickupRocketLauncher : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_RocketLauncher", "WM_RPG";
		WM_PairPickup.AmmoType "RocketAmmo";
		WM_PairPickup.AmmoGive 2;
		Inventory.PickupMessage "$GOTLAUNCHER";
		Tag "$TAG_ROCKETLAUNCHER";
	}
	States
	{
	Spawn:
		LAUN A -1;
		Stop;
	}
}

class WM_PickupPlasmaRifle : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_PlasmaRifle", "WM_PlasmaCarbine";
		WM_PairPickup.AmmoType "Cell";
		WM_PairPickup.AmmoGive 40;
		Inventory.PickupMessage "$GOTPLASMA";
		Tag "$TAG_PLASMARIFLE";
	}
	States
	{
	Spawn:
		PLAS A -1;
		Stop;
	}
}

class WM_PickupBFG : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_BFG", "WM_BFGHeavy";
		WM_PairPickup.AmmoType "Cell";
		WM_PairPickup.AmmoGive 40;
		Inventory.PickupMessage "$GOTBFG9000";
		Tag "$TAG_BFG9000";
	}
	States
	{
	Spawn:
		BFUG A -1;
		Stop;
	}
}

// No ammo: Doom's chainsaw gives none, so once both saws are carried it stays on
// the floor.
class WM_PickupChainsaw : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_Chainsaw", "WM_ChainsawHeavy";
		Inventory.PickupMessage "$GOTCHAINSAW";
		Tag "$TAG_CHAINSAW";
	}
	States
	{
	Spawn:
		CSAW A -1;
		Stop;
	}
}

// A START ALREADY APPLIED TO THIS INVENTORY. It rides with the inventory, so a
// level change that carries it does nothing; a start that hands the inventory out
// afresh (a new game, a death in a single-player game, a netgame respawn, a pistol
// start) has none, and is trimmed again. Not undroppable: ClearInventory must be
// free to take it with everything else.
class WM_StartApplied : Inventory
{
	Default
	{
		+INVENTORY.UNTOSSABLE
		Inventory.MaxAmount 1;
	}
}

class WM_WeaponSet : EventHandler
{
	// DOOM'S WEAPONS BECOME OUR PICKUPS. Exact classes only: a mod's own subclass
	// of a Doom weapon is that mod's business. A final replacement another handler
	// made is left alone.
	override void CheckReplacement(ReplaceEvent e)
	{
		if (e.IsFinal || !e.Replacee) return;
		Name n = e.Replacee.GetClassName();
		if      (n == 'Pistol')         e.Replacement = "WM_PickupPistol";
		else if (n == 'Shotgun')        e.Replacement = "WM_PickupShotgun";
		else if (n == 'SuperShotgun')   e.Replacement = "WM_PickupSuperShotgun";
		else if (n == 'Chaingun')       e.Replacement = "WM_PickupChaingun";
		else if (n == 'RocketLauncher') e.Replacement = "WM_PickupRocketLauncher";
		else if (n == 'PlasmaRifle')    e.Replacement = "WM_PickupPlasmaRifle";
		else if (n == 'BFG9000')        e.Replacement = "WM_PickupBFG";
		else if (n == 'Chainsaw')       e.Replacement = "WM_PickupChainsaw";
	}

	// A FRESH START: PlayerSpawned for a new game or a level entered,
	// PlayerRespawned for a netgame respawn. The token decides which are fresh.
	override void PlayerSpawned(PlayerEvent e)   { ApplyStart(e.PlayerNumber); }
	override void PlayerRespawned(PlayerEvent e) { ApplyStart(e.PlayerNumber); }

	private void ApplyStart(int num)
	{
		if (num < 0 || num >= MAXPLAYERS || !playeringame[num]) return;
		let player = players[num];
		let pmo = player.mo;
		if (!pmo || pmo.FindInventory("WM_StartApplied")) return;
		pmo.GiveInventory("WM_StartApplied", 1);

		let cv = CVar.FindCVar("wm_start_arsenal");
		if (!cv || cv.GetBool()) return;

		// DOOM'S START, a gun for each hand: every carded gun but the two pistols
		// goes. Nothing in a hand is touched -- the spawn raised the pistols.
		Inventory following;
		for (let item = pmo.Inv; item; item = following)
		{
			following = item.Inv;
			if (!(item is 'WM_Gun') || item is 'WM_M4A3' || item is 'WM_Pistolet') continue;
			let gun = Weapon(item);
			if (gun == player.ReadyWeapon || gun == player.OffhandWeapon) continue;
			if (gun == player.PendingWeapon) player.PendingWeapon = WP_NOCHANGE;
			item.Destroy();
		}
		let clip = pmo.FindInventory("Clip");
		if (clip && clip.Amount > 50) clip.Amount = 50;
		ZeroAmmo(pmo, "Shell");
		ZeroAmmo(pmo, "Cell");
		ZeroAmmo(pmo, "RocketAmmo");
		Console.Printf("WM: start -- Doom's (wm_start_arsenal is off): fists, M4A3 and 9mm Handgun, %d Clip.", pmo.CountInv("Clip"));
	}

	private void ZeroAmmo(PlayerPawn pmo, Class<Inventory> type)
	{
		let have = pmo.FindInventory(type);
		if (have) have.Amount = 0;
	}
}
