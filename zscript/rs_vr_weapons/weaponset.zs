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
//   Doom's          first pickup       second pickup      ammo with it
//   Pistol          Pistol             Handgun            20 Clip
//   Shotgun         Steelgun           Shotgun             8 Shell
//   SuperShotgun    Super Shotgun      Quad Super          8 Shell
//   Chaingun        Chaingun           Machine Gun        20 Clip
//   RocketLauncher  Rocket Launcher    RPG                 2 RocketAmmo
//   PlasmaRifle     Plasma Rifle       Blue Plasma Rifle  40 Cell
//   BFG9000         BFG 9000           BFG 10000          40 Cell
//   Chainsaw        Chainsaw           Heavy Chainsaw      none
//
// VANILLA+ (the owner, 09-14): a player of the Vanilla+ class (WM_PlayerPlus, loadout.zs) takes that set's guns
// from the same pickups, one gun per pickup: the next on the pickup's Vanilla+ list it does not carry yet
// (WM_PairPickup.PlusGuns). A Vanilla player on the same pickup gets the Vanilla gun, so a netgame can mix the
// two classes -- each pickup decides from its toucher's class, which every machine agrees on.
//
//   Doom's          Vanilla+ guns, in the order they are handed out
//   Pistol          Pistol, Handgun
//   Shotgun         Steelgun, Shotgun, Moonlight, Sunset, Cola Revolver, SMG, Tec9
//   SuperShotgun    Super Shotgun, Quad Super
//   Chaingun        Chaingun, Machine Gun, Rifle, M16
//   RocketLauncher  Rocket Launcher, RPG
//   PlasmaRifle     Plasma Rifle, Blue Plasma Rifle, Flamer, Flamethrower, Railgun
//   BFG9000         BFG 9000, BFG 10000
//   Chainsaw        Chainsaw, Heavy Chainsaw
//
// A GUN ON ANOTHER AMMO than its pickup's (a revolver or an SMG off the Shotgun) comes with its own ammo, as much
// as a Doom weapon on that ammo gives: twice the ammo's small pickup (Clip 10, so 20 -- Doom's Pistol and
// Chaingun). Ammo alone, once every gun is carried, is the pickup's own, as in Vanilla.
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
// ------------------------------------------------------------ CATCH TO EQUIP
//
// The owner, 09-14: pull a weapon pickup to you with the hands (RS_WorldHands' lock and flick)
// and it becomes our gun in the air; catch it and "the hand that catches it decides" -- the pair's
// main-hand gun in the main hand, its off-hand gun in the off hand, put straight in that hand, or
// that hand switched to it if you carry it already, with Doom's ammo; miss it and it lands as
// Doom's ammo for that weapon. On the floor it keeps Doom's sprite, and walking over it still
// gives the next gun of the pair.
//
// Built on two general services RS_WorldHands asks of any mod (rs_grabpolicy.zs): its events
// (WM_PickupGrabEventService -- a flick dresses the pickup, a miss sends wm-miss) and its take
// question (WM_PickupGrabTakeService -- a catch uses the pickup up and sends wm-catch). Both by
// name, so this package still loads without RS_WorldHands.
//
// NETPLAY: the hands run for one player on one machine, so catch-to-equip is SINGLE-PLAYER until
// they are synced (the build lane, 09-14). In a netgame both services answer nothing and every
// pickup is Doom's. The outcome still travels the netgame way: the catching machine sends the
// pickup's spawn number and the hand as a network event, and WM_WeaponSet.NetworkProcess applies
// it from those args for e.Player on every machine.
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
	// VANILLA+'S GUNS on this pickup, in the order they are handed out: class names, comma separated. Empty: a
	// Vanilla+ player gets the Vanilla pair.
	String        plusGuns;
	// What this pickup just gave, for PickupMessage: Touch prints the message of
	// the same object whose TryPickup ran.
	String        gotMessage;

	// This pickup's number, the same on every machine (spawn order, WM_WeaponSet.NextSerial), so a
	// network event can name it.
	int           catchSerial;
	// Caught or missed, and waiting the tic for its network event: untouchable meanwhile, and a
	// caught one unseen. Counts down; at zero with no event it lies back down as the pickup it was.
	int           catchPendingTics;
	// The Vanilla+ look on the floor is refreshed every few tics (UpdatePlusLook); a local, looks-only count.
	transient int lookTics;

	property Guns: mainGun, offGun;
	property AmmoType: ammoType;
	property AmmoGive: ammoGive;
	property PlusGuns: plusGuns;

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

		// THE NEXT GUN this player does not carry: of the pair, main hand first -- or, for a Vanilla+ player, the
		// next on this pickup's Vanilla+ list.
		bool plus = (SetOf(toucher) == 1 && plusGuns != "");
		Class<Weapon> next = null;
		if (plus)
		{
			Array<Class<Weapon> > guns;
			PlusList(guns);
			for (int i = 0; i < guns.Size() && !next; i++)
				if (!toucher.FindInventory(guns[i])) next = guns[i];
		}
		else if (mainGun && !toucher.FindInventory(mainGun)) next = mainGun;
		else if (offGun && !toucher.FindInventory(offGun))   next = offGun;

		// Weapons stay: a gun each, never ammo alone.
		if (!next && stay) return false;

		bool gotAmmo = plus ? GiveAmmoFor(toucher, next, next != null) : GiveAmmoTo(toucher, next != null);
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

	// ---- CATCH TO EQUIP -------------------------------------------------------------------

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		let ws = WM_WeaponSet(EventHandler.Find("WM_WeaponSet"));
		if (ws) catchSerial = ws.NextSerial();
	}

	override void Tick()
	{
		Super.Tick();
		if (--lookTics <= 0)
		{
			lookTics = 8;
			UpdatePlusLook();
		}
		if (catchPendingTics <= 0) return;
		catchPendingTics--;
		if (catchPendingTics > 0) return;
		// No event came, which a single-player game never does: lie back down as Doom's pickup.
		bInvisible = false;
		bSPECIAL   = true;
	}

	// VANILLA+ ON THE FLOOR (the owner, 09-15: Doom's pickups show "the sprite of the Vanilla+ gun they'll hand you
	// next"). For the player THIS MACHINE VIEWS: a Vanilla+ player sees the next gun on this pickup's Vanilla+ list it
	// does not carry (the first, once it carries them all) in that gun's pickup sprite (TEXTURES.vp_pickups); anyone
	// else sees Doom's. ONLY THE LOOK: picnum, which the renderer draws in place of the sprite frame -- it may differ
	// between machines and decides nothing; what a touch gives is still TryPickup's, from the toucher. Doom's sprite
	// while the pickup flies (its gun's model then) or when the gun has no sprite of its own.
	void UpdatePlusLook()
	{
		TextureID look;
		look.SetInvalid();
		let viewer = players[consoleplayer].mo;
		if (viewer && plusGuns != "" && SetOf(viewer) == 1 && !InStateSequence(CurState, ResolveState("Fly")))
		{
			Array<Class<Weapon> > guns;
			PlusList(guns);
			Class<Weapon> show = null;
			for (int i = 0; i < guns.Size() && !show; i++)
				if (!viewer.FindInventory(guns[i])) show = guns[i];
			if (!show && guns.Size() > 0) show = guns[0];
			look = PickupLook(show);
		}
		picnum = look;
	}

	// EACH VANILLA+ GUN'S FLOOR SPRITE: RS_Main's pickup art where RS_Main has pickup art (TEXTURES.vp_pickups, sized to
	// the vanilla Doom pickup of its kind), and Doom's own nearest pickup sprite where it has only first-person art. A
	// gun not named keeps its pickup's own sprite.
	static TextureID PickupLook(Class<Weapon> gun)
	{
		TextureID none;
		none.SetInvalid();
		if (!gun) return none;
		String spr = "";
		switch (gun.GetClassName())
		{
		// RS_Main's pickup art
		case 'WM_VP_PumpM37':         case 'WM_VP_PumpDoom':        spr = "VPSGA0"; break;
		case 'WM_VP_BullpupPump':                                   spr = "VPAGA0"; break;
		case 'WM_VP_Chaingun':                                      spr = "VPMNA0"; break;
		case 'WM_VP_MachineGun':                                    spr = "VPMGA0"; break;
		case 'WM_VP_BFG':                                           spr = "VPBFA0"; break;
		case 'WM_VP_BFGHeavy':                                      spr = "VPBTA0"; break;
		case 'WM_Rifle':              case 'WM_M16':                spr = "VPRIA0"; break;
		case 'WM_SMG':                case 'WM_Tec9':               spr = "VPSMA0"; break;
		case 'WM_Flamer':             case 'WM_Flamethrower':       spr = "VPFTA0"; break;
		case 'WM_Railgun':                                          spr = "VPRAA0"; break;
		// no RS_Main pickup art: Doom's own nearest pickup
		case 'WM_VP_M4A3':            case 'WM_VP_Pistolet':        spr = "PISTA0"; break;
		case 'WM_Moonlight':          case 'WM_Sunset':             spr = "PISTA0"; break;
		case 'WM_ColaRevolver':                                     spr = "PISTA0"; break;
		case 'WM_VP_SSG':                                           spr = "SGN2A0"; break;
		case 'WM_VP_RocketLauncher':  case 'WM_VP_RPG':             spr = "LAUNA0"; break;
		case 'WM_VP_PlasmaRifle':     case 'WM_VP_PlasmaRifleBlue': spr = "PLASA0"; break;
		case 'WM_VP_Chainsaw':        case 'WM_VP_ChainsawHeavy':   spr = "CSAWA0"; break;
		}
		if (spr == "") return none;
		return TexMan.CheckForTexture(spr, TexMan.Type_Sprite);
	}

	// WHICH SET A PLAYER PLAYS: its player class says (WM_Player.WeaponSet, loadout.zs); any other player is Vanilla.
	static int SetOf(Actor who)
	{
		let wp = WM_Player(who);
		return wp ? wp.weaponSet : 0;
	}

	// THIS PICKUP'S VANILLA+ GUNS, from PlusGuns, in order. A name that is not a loaded weapon is skipped.
	void PlusList(out Array<Class<Weapon> > guns)
	{
		guns.Clear();
		String list = plusGuns;
		list.Replace(" ", "");
		Array<String> names;
		list.Split(names, ",");
		for (int i = 0; i < names.Size(); i++)
		{
			let c = (Class<Weapon>)(Object.FindClass(names[i], "Weapon"));
			if (c) guns.Push(c);
		}
	}

	// THE GUN A HAND GETS: the pair's main-hand gun for the main hand, its off-hand gun for the off hand. For a
	// Vanilla+ player (who), the first gun on the Vanilla+ list for that hand it does not carry, else the first
	// for that hand.
	Class<Weapon> GunForHand(int hand, Actor who = null)
	{
		if (who && SetOf(who) == 1 && plusGuns != "")
		{
			Array<Class<Weapon> > guns;
			PlusList(guns);
			Class<Weapon> first = null;
			for (int i = 0; i < guns.Size(); i++)
			{
				int gunHand = GetDefaultByType(guns[i]).bOffhandWeapon ? 1 : 0;
				if (gunHand != hand) continue;
				if (!who.FindInventory(guns[i])) return guns[i];
				if (!first) first = guns[i];
			}
			if (first) return first;
			return (guns.Size() > 0) ? guns[0] : null;
		}
		if (hand == 1 && offGun) return offGun;
		return mainGun ? mainGun : offGun;
	}

	// IN THE AIR IT IS THE GUN THE PULLING HAND WOULD CATCH: that gun's card mesh and skin on that gun's own
	// look block (MODELDEF WM_FlightLook<gun>: its handedness, its in-hand size, centred), from a frame only
	// those blocks bind. A_ChangeModel's modeldef points this pickup at the block (models.cpp FindModelFrame
	// reads modelData->modelDef). Nothing changes for a gun with no card or no block.
	void BeginFlightLook(int hand)
	{
		// The puller: the hands run for one player on one machine, single-player only (the header), and this is
		// only a look -- the catch itself travels as a network event.
		Class<Weapon> gun = GunForHand(hand, players[consoleplayer].mo);
		if (!gun) return;
		let sys  = WM_System(EventHandler.Find("WM_System"));
		let card = sys ? sys.CardForWeapon(gun.GetClassName()) : null;
		String gunName = gun.GetClassName();
		// A gun on a borrowed Model Card (a Vanilla+ gun) flies as that model's gun.
		String lookName = (card && card.modelId != "") ? card.modelId : gunName;
		String look = "WM_FlightLook" .. lookName.Mid(3);
		if (!card || card.modelFile == "" || !Object.FindClass(look, "Actor")) return;
		A_ChangeModel(look, 0, card.modelPath, card.modelFile, 0, card.skinPath, card.skinFile);
		SetStateLabel("Fly");
	}

	// BACK TO DOOM'S PICKUP: its sprite (no look block binds a Doom frame).
	void EndFlightLook()
	{
		if (!InStateSequence(CurState, ResolveState("Fly"))) return;
		SetStateLabel("Spawn");
	}

	// CAUGHT (wm-catch, applied on every machine): the catching hand's gun, with Doom's ammo. Not carried:
	// given, and put in that hand. Carried: that hand switches to it. Both through the one put-in-hand
	// every gun here uses (WM_PumpTestHandler.PutInHand). Then the pickup is gone.
	void CatchInto(PlayerPawn pmo, int hand)
	{
		Class<Weapon> gun = GunForHand(hand, pmo);
		if (!pmo || !pmo.player || !gun) return;
		let carried = Weapon(pmo.FindInventory(gun));
		if (SetOf(pmo) == 1 && plusGuns != "") GiveAmmoFor(pmo, gun, carried == null);
		else                                   GiveAmmoTo(pmo, carried == null);
		Weapon w = carried;
		if (!w)
		{
			let fresh = Weapon(Spawn(gun, pmo.Pos, NO_REPLACE));
			if (fresh)
			{
				fresh.ClearCounters();
				if (fresh.CallTryPickup(pmo)) w = Weapon(pmo.FindInventory(gun));
				else fresh.Destroy();
			}
		}
		if (w)
		{
			WM_PumpTestHandler.PutInHand(pmo, w, hand);
			PlayPickupSound(pmo);
			PrintPickupMessage(pmo.CheckLocalView(), String.Format("You got the %s!", w.GetTag()));
		}
		Destroy();
	}

	// NOT CAUGHT (wm-miss, applied on every machine): Doom's own ammo for this weapon, Doom's amount --
	// counted as a drop, by the skill, as the pickup would have given it -- where the gun fell. A pair
	// with no ammo (the chainsaws) lands as the gun pickup it was.
	void MissToAmmo()
	{
		EndFlightLook();
		catchPendingTics = 0;
		bSPECIAL = true;
		if (!ammoType || ammoGive <= 0) return;
		let am = Inventory(Spawn(ammoType, Pos, ALLOW_REPLACE));
		if (!am) return;
		am.Amount       = ammoGive;
		am.bIgnoreSkill = bIgnoreSkill;
		am.bDROPPED     = true;
		am.Vel          = Vel;
		Destroy();
	}

	override String PickupMessage()
	{
		return (gotMessage.Length() > 0) ? gotMessage : PickupMsg;
	}

	// DOOM'S AMMO, the way Weapon.AddAmmo (with a gun) and AddExistingAmmo (alone)
	// count it. False when none went in: nothing to give, or the reserve is full.
	//
	// otherAmmo / otherGive: another ammo than this pickup's, and how much (GiveAmmoFor).
	private bool GiveAmmoTo(Actor toucher, bool withGun, Class<Ammo> otherAmmo = null, int otherGive = -1)
	{
		Class<Ammo> kind = otherAmmo ? otherAmmo : ammoType;
		int giveBase     = (otherGive >= 0) ? otherGive : ammoGive;
		if (!kind || giveBase <= 0) return false;
		int amount = giveBase;
		if (withGun && deathmatch && !sv_noextraammo && (gameinfo.gametype & GAME_DoomChex))
		{
			amount = amount * 5 / 2;
		}
		if (!bIgnoreSkill)
		{
			amount = int(amount * (G_SkillPropertyFloat(SKILLP_AmmoFactor) * sv_ammofactor));
		}
		if (amount <= 0) return false;

		let have = Ammo(toucher.FindInventory(kind));
		if (!have)
		{
			let fresh = Ammo(Spawn(kind));
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

	// THE AMMO WITH A VANILLA+ GUN: this pickup's own (GiveAmmoTo), unless the gun runs on another -- a revolver or
	// an SMG off the Shotgun -- when it is that ammo, as much as a Doom weapon on it gives: twice the ammo's small
	// pickup (Clip 10, Shell 4, RocketAmmo 1, Cell 20 -- every Doom weapon's AmmoGive is twice its ammo's), with
	// this pickup's drop share (ModifyDropAmount) carried over. With no gun it is this pickup's own.
	private bool GiveAmmoFor(Actor toucher, Class<Weapon> gun, bool withGun)
	{
		Class<Ammo> gunAmmo = null;
		if (gun) gunAmmo = GetDefaultByType(gun).AmmoType1;
		if (!gunAmmo || !ammoType || gunAmmo == ammoType) return GiveAmmoTo(toucher, withGun);
		int give = GetDefaultByType(gunAmmo).Amount * 2;
		let mine = GetDefaultByType((Class<WM_PairPickup>)(GetClass()));
		if (mine && mine.ammoGive > 0) give = give * ammoGive / mine.ammoGive;
		return GiveAmmoTo(toucher, withGun, gunAmmo, give);
	}

	States
	{
	// IN THE AIR (catch to equip): a frame only each pickup's MODELDEF block binds, so the gun's mesh is
	// drawn and Doom's sprite is not.
	Fly:
		WMPR A -1;
		Stop;
	}
}

class WM_PickupPistol : WM_PairPickup
{
	Default
	{
		WM_PairPickup.Guns "WM_M4A3", "WM_Pistolet";
		WM_PairPickup.PlusGuns "WM_VP_M4A3, WM_VP_Pistolet";
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
		WM_PairPickup.PlusGuns "WM_VP_PumpM37, WM_VP_PumpDoom, WM_Moonlight, WM_Sunset, WM_ColaRevolver, WM_SMG, WM_Tec9";
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
		// The owner, 09-14: "the 4 shot bullpup and the traditional breakaction". The Double Barrel stays in the
		// arsenal, off this pair.
		WM_PairPickup.Guns "WM_SSG", "WM_BullpupPump";
		WM_PairPickup.PlusGuns "WM_VP_SSG, WM_VP_BullpupPump";
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
		WM_PairPickup.PlusGuns "WM_VP_Chaingun, WM_VP_MachineGun, WM_Rifle, WM_M16";
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
		WM_PairPickup.PlusGuns "WM_VP_RocketLauncher, WM_VP_RPG";
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
		WM_PairPickup.Guns "WM_PlasmaRifle", "WM_PlasmaRifleBlue";
		WM_PairPickup.PlusGuns "WM_VP_PlasmaRifle, WM_VP_PlasmaRifleBlue, WM_Flamer, WM_Flamethrower, WM_Railgun";
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
		WM_PairPickup.PlusGuns "WM_VP_BFG, WM_VP_BFGHeavy";
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
		WM_PairPickup.PlusGuns "WM_VP_Chainsaw, WM_VP_ChainsawHeavy";
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
	// CATCH TO EQUIP's numbering: each WM_PairPickup takes the next number as it begins play, in spawn
	// order, so every machine numbers the same pickup the same.
	private int serialCounter;
	int NextSerial() { serialCounter++; return serialCounter; }

	// A CATCH TAKES THE SQUEEZE THAT MADE IT. The hand that caught is claimed on the grip arbiter for
	// as long as that squeeze lasts, so the reload system (which claims before it grabs a gun part or
	// draws from the pouch) cannot read the same squeeze a second time. Single-player, like the hands.
	transient bool catchSqueeze[2];
	transient PlayerPawn catchSqueezer;

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

		// DOOM'S START, a gun for each hand: every carded gun but the class's two pistols (WM_Player.StartGuns --
		// Vanilla's, or Vanilla+'s) goes. Nothing in a hand is touched -- the spawn raised the pistols.
		Class<Weapon> keepMain = "WM_M4A3", keepOff = "WM_Pistolet";
		let wp = WM_Player(pmo);
		if (wp && wp.startMainGun) keepMain = wp.startMainGun;
		if (wp && wp.startOffGun)  keepOff  = wp.startOffGun;
		Inventory following;
		for (let item = pmo.Inv; item; item = following)
		{
			following = item.Inv;
			if (!(item is 'WM_Gun') || item.GetClass() == keepMain || item.GetClass() == keepOff) continue;
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
		Console.Printf("WM: start -- Doom's (wm_start_arsenal is off): fists, Pistol and Handgun, %d Clip.", pmo.CountInv("Clip"));
	}

	private void ZeroAmmo(PlayerPawn pmo, Class<Inventory> type)
	{
		let have = pmo.FindInventory(type);
		if (have) have.Amount = 0;
	}

	// ---- CATCH TO EQUIP ---------------------------------------------------------------------

	// A PICKUP IS A GRIP-SHAPED THING, weighted above the ammo lying round it, on RS_WorldHands' grab
	// rules (inheritance-aware, so every pair). Absent-safe: no rules service, nothing asked.
	override void OnRegister()
	{
		let it = ServiceIterator.Find("RS_GrabRuleService");
		Service s;
		while (s = it.Next())
		{
			if (s.GetInt("grab.hello") != 1) continue;
			s.GetInt("grab.rule", "WM_PairPickup", GRIPSUBJ_Grip, -1, null, 'RS_VR_Weapons');
			s.GetInt("grab.weight", "WM_PairPickup", 0, 2.0, null, 'RS_VR_Weapons');
			break;
		}
	}

	static Service GripArbiter()
	{
		let it = ServiceIterator.Find("RS_GripArbiterService");
		Service s;
		while (s = it.Next())
			if (s.GetInt("grip.hello") == 1) return s;
		return null;
	}

	// True when the squeeze is the catch's: the arbiter granted the hand, or there is no arbiter to ask. False
	// when somebody else already holds this hand on this tic -- the reload system taking the same squeeze for a
	// gun part or the pouch -- and then there is no catch: the first claim on the tic wins.
	bool HoldSqueeze(PlayerPawn pmo, int hand)
	{
		if (!pmo || (hand != 0 && hand != 1)) return false;
		let arb = GripArbiter();
		if (!arb) return true;
		if (arb.GetInt("grip.claim", "", hand, GRIPSUBJ_Grip, pmo, 'WM_CatchToEquip') != 1) return false;
		catchSqueeze[hand] = true;
		catchSqueezer = pmo;
		return true;
	}

	// Renewed every tic the catching grip stays closed, released the tic it opens.
	override void WorldTick()
	{
		if (multiplayer || !catchSqueezer) return;
		let arb = GripArbiter();
		for (int h = 0; h < 2; h++)
		{
			if (!catchSqueeze[h]) continue;
			bool closed = (h == 0) ? catchSqueezer.GripHeldMain : catchSqueezer.GripHeldOff;
			if (closed && arb)
			{
				arb.GetInt("grip.claim", "", h, GRIPSUBJ_Grip, catchSqueezer, 'WM_CatchToEquip');
				continue;
			}
			if (arb) arb.GetInt("grip.release", "", h, 0, catchSqueezer, 'WM_CatchToEquip');
			catchSqueeze[h] = false;
		}
	}

	static WM_PairPickup FindBySerial(int serial)
	{
		if (serial <= 0) return null;
		let it = ThinkerIterator.Create("WM_PairPickup");
		WM_PairPickup pk;
		while (pk = WM_PairPickup(it.Next()))
			if (pk.catchSerial == serial) return pk;
		return null;
	}

	// THE OUTCOME OF A CATCH OR A MISS, from the machine whose hands made it, applied here from its args
	// on every machine for the player who sent it. Never typed at the console, never the console player.
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.IsManual) return;
		if (e.Name != "wm-catch" && e.Name != "wm-miss") return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let pmo = players[e.Player].mo;
		let pk  = FindBySerial(e.Args[0]);
		if (!pmo || !pk || pk.Owner) return;
		if (e.Name == "wm-catch") pk.CatchInto(pmo, (e.Args[1] == 1) ? 1 : 0);
		else                      pk.MissToAmmo();
	}
}

// CATCH TO EQUIP's LOOKS: a class per gun, only so MODELDEF can give each gun its own flight-look block
// (handedness, size, centring). Never spawned; a flying pickup borrows the block by name.
class WM_FlightLookM4A3 : Actor {}
class WM_FlightLookPistolet : Actor {}
class WM_FlightLookPumpM37 : Actor {}
class WM_FlightLookPumpDoom : Actor {}
class WM_FlightLookSSG : Actor {}
class WM_FlightLookBullpupPump : Actor {}
class WM_FlightLookDoubleBarrel : Actor {}
class WM_FlightLookChaingun : Actor {}
class WM_FlightLookMachineGun : Actor {}
class WM_FlightLookRocketLauncher : Actor {}
class WM_FlightLookRPG : Actor {}
class WM_FlightLookPlasmaRifle : Actor {}
class WM_FlightLookPlasmaCarbine : Actor {}
class WM_FlightLookRailgun : Actor {}
class WM_FlightLookPlasmaRifleBlue : Actor {}
class WM_FlightLookBFG : Actor {}
class WM_FlightLookBFGHeavy : Actor {}
class WM_FlightLookChainsaw : Actor {}
class WM_FlightLookChainsawHeavy : Actor {}

// CATCH TO EQUIP's ears on the hands: RS_WorldHands tells every Service whose name contains
// "GrabEventService" what a pull did (rs_grabpolicy.zs, RS_GrabPolicy.Tell). A flick dresses a weapon
// pickup as the pulling hand's gun; an arc that runs out, or one that hits a wall, is a miss; a pull
// called off puts Doom's sprite back. Nothing in a netgame (the header).
class WM_PickupGrabEventService : Service
{
	override int GetInt(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "grab.event" || multiplayer) return 0;
		let pk = WM_PairPickup(objectArg);
		if (!pk || pk.Owner || pk.catchPendingTics > 0) return 0;
		int hand = (intArg == 1) ? 1 : 0;
		if (stringArg == "pull.start")
		{
			pk.BeginFlightLook(hand);
		}
		else if (stringArg == "pull.missed" || stringArg == "pull.blocked")
		{
			pk.bSPECIAL = false;
			pk.catchPendingTics = 35;
			EventHandler.SendNetworkEvent("wm-miss", pk.catchSerial);
		}
		else if (stringArg == "pull.aborted")
		{
			pk.EndFlightLook();
		}
		return 0;
	}
}

// CATCH TO EQUIP's hand on the take: RS_WorldHands asks every Service whose name contains
// "GrabTakeService" before holding what a hand closed on (RS_GrabPolicy.AskTake). A weapon pickup CAUGHT
// OUT OF THE AIR is used up: hidden at once, the catching squeeze held, and wm-catch sent with the hand
// that caught it. Off the floor it is left to the hands as before. Nothing in a netgame (the header).
class WM_PickupGrabTakeService : Service
{
	override int GetInt(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "grab.take" || multiplayer || doubleArg < 0.5) return 0;
		let pk = WM_PairPickup(objectArg);
		if (!pk || pk.Owner || pk.catchPendingTics > 0) return 0;
		// The catcher: in a single-player game the hands only ever run for this player.
		let pmo = players[consoleplayer].mo;
		if (!pmo) return 0;
		int hand = (intArg == 1) ? 1 : 0;
		// The squeeze first: a hand somebody else took this tic catches nothing.
		let ws = WM_WeaponSet(EventHandler.Find("WM_WeaponSet"));
		if (ws && !ws.HoldSqueeze(pmo, hand)) return 0;
		pk.bSPECIAL   = false;
		pk.bInvisible = true;
		pk.catchPendingTics = 35;
		EventHandler.SendNetworkEvent("wm-catch", pk.catchSerial, hand);
		return 1;
	}
}
