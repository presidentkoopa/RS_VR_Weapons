// ============================================================================
// WHAT YOU START WITH, AND A WAY TO PUT THE SHOTGUNS IN YOUR HANDS.
// ============================================================================

// THE PLAYER: a fist in each hand, a pistol in each hand, a shotgun for each
// hand, and ammunition for both kinds -- THE WHOLE TEST ARSENAL, while the owner
// calibrates. wm_start_arsenal off trims a fresh start to Doom's (weaponset.zs),
// and the guns then come from Doom's weapon pickups, one gun per pickup. Set as
// the player by this package's MAPINFO. The reload system has no player class of its own: loaded alone, you
// are the engine's own player with nothing carded to carry.
//
// ONE CLASS, NOT A SUBCLASS. This used to be WM_PlayerShotguns deriving from the
// reload system's WM_Player and repeating its list -- the engine starts a class's
// start items afresh at the first Player.StartItem it declares
// (thingdef_properties.cpp, `startitem`: bag.DropItemSet). With the pistols moved
// here, the whole arsenal is this package's, so it is one list in one place, and
// the name WM_Player is kept so nothing that names it breaks.
//
// ORDER: the pistols first, then the fists, then the shotguns. The FIRST weapon
// listed is the one the engine leaves as the ready weapon (player.zs
// GiveDefaultInventory walks the list last-declared first and sets ReadyWeapon on
// each weapon it gives), so the M4A3 is the gun raised in the main hand. The
// selection orders in shotguns.zs keep the Pistolet ahead of the Doom shotgun in
// the off hand.
//
// AND A FIST IN EACH HAND, RS_WorldHands' own. A gun in both hands left no free
// hand: nothing to catch with, nothing to pass with, nothing to pull with. Named
// as plain StartItems: a class that is not loaded is a warning at startup, not a
// fatal, so this still loads without RS_WorldHands.
//
// 200 Clip in reserve -- thirteen magazines at fifteen -- and each pistol starts
// with fifteen in the magazine and one up the spout, which the reload system gives
// it. 50 Shell for the two tubes.
class WM_Player : DoomPlayer
{
	Default
	{
		Player.StartItem "WM_M4A3";
		Player.StartItem "WM_Pistolet";
		Player.StartItem "RS_WorldFist";
		Player.StartItem "RS_WorldFistOff";
		Player.StartItem "Clip", 200;
		Player.StartItem "WM_PumpM37";
		Player.StartItem "WM_PumpDoom";
		Player.StartItem "Shell", 50;
		// Slot 4 -- carried, NOT put in hand (the shotguns are what's under
		// test today; reach these by the wheel or the number keys instead).
		Player.StartItem "WM_Moonlight";
		Player.StartItem "WM_Sunset";
		Player.StartItem "WM_ColaRevolver";
		// Slot 5 -- the Rifle, carried, not put in hand.
		Player.StartItem "WM_Rifle";
		// Slot 3 -- the super shotgun, carried, not put in hand (ssg.zs).
		Player.StartItem "WM_SSG";
		// Slot 3 -- the double barrel, the SSG's off-hand pair, carried, not put in hand (ssg.zs).
		Player.StartItem "WM_DoubleBarrel";
		// Slot 5 -- the M16, beside the Rifle; slot 6 -- the SMG and the Tec9
		// (smgs.zs). Carried, not put in hand.
		Player.StartItem "WM_M16";
		Player.StartItem "WM_SMG";
		Player.StartItem "WM_Tec9";
		// The plasma family, carried, not put in hand.
		Player.StartItem "WM_PlasmaRifle";
		Player.StartItem "WM_PlasmaCarbine";
		Player.StartItem "Cell", 300;
		// The railgun family, carried, not put in hand.
		Player.StartItem "WM_Railgun";
		// The chaingun family, carried, not put in hand.
		Player.StartItem "WM_Chaingun";
		// The launchers family, carried, not put in hand.
		Player.StartItem "WM_RocketLauncher";
		Player.StartItem "WM_RPG";
		Player.StartItem "RocketAmmo", 20;
		// The bfg family, carried, not put in hand.
		Player.StartItem "WM_BFG";
		Player.StartItem "WM_BFGHeavy";
		// The chainsaws family, carried, not put in hand.
		Player.StartItem "WM_Chainsaw";
		Player.StartItem "WM_ChainsawHeavy";
		// The flamers family, carried, not put in hand.
		Player.StartItem "WM_Flamer";
		Player.StartItem "WM_Flamethrower";
		// The machinegun family, carried, not put in hand.
		Player.StartItem "WM_MachineGun";
		// The MeatGrinder family (meatgrinder.zs), carried, not put in hand.
		Player.StartItem "WM_AssaultShotgun";
		Player.StartItem "WM_BullpupPump";
		Player.StartItem "WM_Bolter";
		Player.StartItem "WM_BFGRifle";
		Player.StartItem "WM_RotaryGun";
		Player.StartItem "WM_RotaryLauncher";
		Player.StartItem "WM_LongbarChainsaw";
		Player.DisplayName "WM";

		// SLOTS, so the wheel and the number keys can reach these without
		// typing. Slot lists take class names, so a package that is not
		// loaded (RS_WorldHands) is silently absent from the slot rather
		// than a load-time error -- confirmed by the property parser
		// (thingdef_properties.cpp DEFINE_CLASS_PROPERTY_PREFIX weaponslot),
		// which only ever resolves the names against what actually loaded.
		// RS_ShieldSaw and RS_Grenade's grenade are in the set by name: each is given
		// by its own mod when that mod is loaded (RS_ShieldSaw's grant, RS_Grenade's
		// handler) and slotted where it slots itself -- 1 and 9 -- and a mod that is
		// not loaded is simply absent from its slot.
		Player.WeaponSlot 1, "RS_WorldFist", "RS_WorldFistOff", "WM_Chainsaw", "WM_ChainsawHeavy", "WM_LongbarChainsaw", "RS_ShieldSaw";
		Player.WeaponSlot 2, "WM_M4A3", "WM_Pistolet";
		Player.WeaponSlot 3, "WM_PumpM37", "WM_PumpDoom", "WM_SSG", "WM_DoubleBarrel", "WM_AssaultShotgun", "WM_BullpupPump";
		Player.WeaponSlot 4, "WM_Moonlight", "WM_Sunset", "WM_ColaRevolver";
		Player.WeaponSlot 5, "WM_Rifle", "WM_M16";
		Player.WeaponSlot 6, "WM_SMG", "WM_Tec9";
		Player.WeaponSlot 0, "WM_BFG", "WM_BFGHeavy", "WM_BFGRifle", "WM_Flamer", "WM_Flamethrower";
		Player.WeaponSlot 8, "WM_RocketLauncher", "WM_RPG", "WM_RotaryLauncher";
		Player.WeaponSlot 7, "WM_Chaingun", "WM_MachineGun", "WM_RotaryGun";
		Player.WeaponSlot 9, "WM_PlasmaRifle", "WM_PlasmaCarbine", "WM_Railgun", "WM_Bolter", "RS_VRGrenade";
	}
}

// ---------------------------------------------------------------- THE COMMANDS
//
//   wm_giveshotguns   both shotguns and 50 shells, each shotgun put straight
//                     into its own hand
//   wm_equippistols   this package's two test pistols back into their hands,
//                     if carried -- for going between the two without dying
//                     or restarting
//   wm_giverevolvers  Moonlight and Sunset, each into its own hand, and 60
//                     rounds (Clip, the reserve their speedloaders come from)
//   wm_givecola       the Cola revolver into the off hand, over Sunset
//   wm_giverifle      the Rifle into the main hand, and 60 rounds of Clip
//   wm_givessg        the super shotgun into the main hand, and 20 shells
//   wm_givedoublebarrel the double barrel into the off hand, and 20 shells
//   wm_givem16        the M16 into the main hand, and 60 rounds of Clip
//   wm_givesmg        the SMG into the main hand, and 60 rounds of Clip
//   wm_givetec9       the Tec9 into the off hand, and 64 rounds of Clip
//   wm_giveplasma     plasma rifle and plasma carbine into your hands (and 100 cells)
//   wm_giverailgun    railgun into the main hand (and 100 cells)
//   wm_givechaingun   chaingun into the main hand (and 100 rounds)
//   wm_givelaunchers  rocket launcher and rpg into your hands (and 12 rockets)
//   wm_givebfg        bfg and heavy bfg into your hands (and 320 cells)
//   wm_givechainsaws  chainsaw and heavy chainsaw into your hands
//   wm_giveflamers    flamer and flamethrower into your hands (and 200 cells)
//   wm_givemachinegun machine gun into the off hand (and 100 rounds, 6 grenades with rs grenade)
//   wm_giveassaultshotguns assault shotgun and bullpup pump into your hands (and 50 shells)
//   wm_givebolter     bolter into the off hand (and 100 cells)
//   wm_givebfgrifle   bfg rifle into the main hand (and 320 cells)
//   wm_giverotaries   rotary gun and rotary launcher into your hands (and 100 rounds, 12 rockets)
//   wm_givelongbar    longbar chainsaw into the main hand
//
// KEYCONF makes both console words; the menu page runs the same netevents.
//
// PUT IN THE HAND, NOT GIVEN AND LEFT. Once its spawn window has closed, the
// reload system only fills a hand that is holding NOTHING (system.zs Equip), so
// a plain `give` would leave both pistols up. PutInHand below is WM_System's
// EquipInstantly, copied because it is private there: setting the hand's
// weapon pointer is not enough -- SetPsprite is what hands the layer over.
class WM_PumpTestHandler : EventHandler
{
	// SPAWN WITH THE SHOTGUNS IN YOUR HANDS -- nobody types in a headset.
	//
	// The reload system spends its first 35 tics after a spawn putting carded guns
	// into hands, pistols first (their cards come first in this package's
	// WMCARD.txt). So this waits past that window, then puts a shotgun in each hand
	// the way wm_giveshotguns does.
	// Counted per player from PlayerSpawned; 0 means nothing pending. No field
	// initialisers: ZScript refuses them.
	const START_AFTER_TICS = 40;
	private int startTics[MAXPLAYERS];

	override void PlayerSpawned(PlayerEvent e)
	{
		if (e.PlayerNumber < 0 || e.PlayerNumber >= MAXPLAYERS) return;
		startTics[e.PlayerNumber] = START_AFTER_TICS;
		LogSlots(e.PlayerNumber);
	}

	// DIAGNOSTIC: one line per slot, so a headset run without typing still
	// proves the wheel has something to walk. Reads WeaponSlots the same way
	// the wheel does (SlotSize / GetWeapon), so this and the wheel can never
	// silently disagree about what a slot contains.
	private void LogSlots(int playerNum)
	{
		if (!playeringame[playerNum]) return;
		let player = players[playerNum];
		let pmo = player.mo;
		let wp = player.weapons;
		if (!pmo || !wp) return;

		for (int slot = 0; slot <= 9; slot++)
		{
			int n = wp.SlotSize(slot);
			if (n <= 0)
			{
				Console.Printf("WM: slot %d -- empty.", slot);
				continue;
			}
			String line = String.Format("WM: slot %d --", slot);
			for (int i = 0; i < n; i++)
			{
				Class<Weapon> ty = (Class<Weapon>)(wp.GetWeapon(slot, i));
				if (!ty) continue;
				bool owned = pmo.FindInventory(ty) != null;
				line.AppendFormat("%s %s(%s)", (i == 0) ? "" : ",", ty.GetClassName(), owned ? "owned" : "NOT OWNED");
			}
			Console.Printf("%s", line);
		}
	}

	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (startTics[i] <= 0) continue;
			startTics[i]--;
			if (startTics[i] > 0) continue;
			if (!playeringame[i]) continue;
			let pmo = players[i].mo;
			if (!pmo || pmo.health <= 0) continue;
			let cv = CVar.GetCVar("wm_pump_start_in_hands", players[i]);
			if (cv && !cv.GetBool())
			{
				Console.Printf("WM: spawn -- shotguns not put in hand (wm_pump_start_in_hands is off); pistols stay up.");
				continue;
			}
			let m37  = Weapon(pmo.FindInventory("WM_PumpM37"));
			let doom = Weapon(pmo.FindInventory("WM_PumpDoom"));
			// Neither carried: a start trimmed to Doom's (weaponset.zs), pistols stay up.
			if (!m37 && !doom) continue;
			PutInHand(pmo, m37, 0);
			PutInHand(pmo, doom, 1);
			Console.Printf("WM: spawn -- %s in the main hand, %s in the off hand, %d shells.",
				m37 ? "M37A2" : "NO M37A2 CARRIED", doom ? "Doom shotgun" : "NO DOOM SHOTGUN CARRIED",
				pmo.CountInv("Shell"));
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let pmo = players[e.Player].mo;
		if (!pmo || pmo.health <= 0) return;

		if (e.Name ~== "wm_giveshotguns")
		{
			pmo.GiveInventory("WM_PumpM37", 1);
			pmo.GiveInventory("WM_PumpDoom", 1);
			pmo.GiveInventory("Shell", 50);
			PutInHand(pmo, Weapon(pmo.FindInventory("WM_PumpM37")), 0);
			PutInHand(pmo, Weapon(pmo.FindInventory("WM_PumpDoom")), 1);
			Console.Printf("WM: M37A2 in the main hand, Doom shotgun in the off hand, %d shells in reserve.",
				pmo.CountInv("Shell"));
		}
		else if (e.Name ~== "wm_equippistols")
		{
			int put = PutByName(pmo, "WM_M4A3", 0) + PutByName(pmo, "WM_Pistolet", 1);
			Console.Printf("WM: %d test pistol(s) put back in hand.", put);
		}
		else if (e.Name ~== "wm_giverevolvers")
		{
			pmo.GiveInventory("WM_Moonlight", 1);
			pmo.GiveInventory("WM_Sunset", 1);
			pmo.GiveInventory("Clip", 60);
			int putRev = PutByName(pmo, "WM_Moonlight", 0) + PutByName(pmo, "WM_Sunset", 1);
			Console.Printf("WM: %d revolver(s) in hand -- Moonlight main, Sunset off -- %d rounds in reserve.",
				putRev, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_givecola")
		{
			pmo.GiveInventory("WM_ColaRevolver", 1);
			int putCola = PutByName(pmo, "WM_ColaRevolver", 1);
			Console.Printf("WM: %d Cola revolver in the off hand, %d rounds in reserve.", putCola, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_giverifle")
		{
			pmo.GiveInventory("WM_Rifle", 1);
			pmo.GiveInventory("Clip", 60);
			int putRifle = PutByName(pmo, "WM_Rifle", 0);
			Console.Printf("WM: %d rifle in the main hand, %d rounds in reserve.", putRifle, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_givessg")
		{
			pmo.GiveInventory("WM_SSG", 1);
			pmo.GiveInventory("Shell", 20);
			int putSSG = PutByName(pmo, "WM_SSG", 0);
			Console.Printf("WM: %d super shotgun in the main hand, %d shells in reserve.", putSSG, pmo.CountInv("Shell"));
		}
		else if (e.Name ~== "wm_givedoublebarrel")
		{
			pmo.GiveInventory("WM_DoubleBarrel", 1);
			pmo.GiveInventory("Shell", 20);
			int putDouble = PutByName(pmo, "WM_DoubleBarrel", 1);
			Console.Printf("WM: %d double barrel in the off hand, %d shells in reserve.", putDouble, pmo.CountInv("Shell"));
		}
		else if (e.Name ~== "wm_givem16")
		{
			pmo.GiveInventory("WM_M16", 1);
			pmo.GiveInventory("Clip", 60);
			int putM16 = PutByName(pmo, "WM_M16", 0);
			Console.Printf("WM: %d M16 in the main hand, %d rounds in reserve.", putM16, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_givetec9")
		{
			pmo.GiveInventory("WM_Tec9", 1);
			pmo.GiveInventory("Clip", 64);
			int putTec9 = PutByName(pmo, "WM_Tec9", 1);
			Console.Printf("WM: %d Tec9 in the off hand, %d rounds in reserve.", putTec9, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_givesmg")
		{
			pmo.GiveInventory("WM_SMG", 1);
			pmo.GiveInventory("Clip", 60);
			int putSMG = PutByName(pmo, "WM_SMG", 0);
			Console.Printf("WM: %d SMG in the main hand, %d rounds in reserve.", putSMG, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_giveplasma")
		{
			pmo.GiveInventory("WM_PlasmaRifle", 1);
			pmo.GiveInventory("WM_PlasmaCarbine", 1);
			pmo.GiveInventory("Cell", 100);
			int putPlasma = PutByName(pmo, "WM_PlasmaRifle", 0) + PutByName(pmo, "WM_PlasmaCarbine", 1);
			Console.Printf("WM: %d of the plasma family in hand -- plasma rifle main, plasma carbine off -- %d Cell in reserve.", putPlasma, pmo.CountInv("Cell"));
		}
		else if (e.Name ~== "wm_giverailgun")
		{
			pmo.GiveInventory("WM_Railgun", 1);
			pmo.GiveInventory("Cell", 100);
			int putRailgun = PutByName(pmo, "WM_Railgun", 0);
			Console.Printf("WM: %d of the railgun family in hand -- railgun main -- %d Cell in reserve.", putRailgun, pmo.CountInv("Cell"));
		}
		else if (e.Name ~== "wm_givechaingun")
		{
			pmo.GiveInventory("WM_Chaingun", 1);
			pmo.GiveInventory("Clip", 100);
			int putChaingun = PutByName(pmo, "WM_Chaingun", 0);
			Console.Printf("WM: %d of the chaingun family in hand -- chaingun main -- %d Clip in reserve.", putChaingun, pmo.CountInv("Clip"));
		}
		else if (e.Name ~== "wm_givelaunchers")
		{
			pmo.GiveInventory("WM_RocketLauncher", 1);
			pmo.GiveInventory("WM_RPG", 1);
			pmo.GiveInventory("RocketAmmo", 12);
			int putLaunchers = PutByName(pmo, "WM_RocketLauncher", 0) + PutByName(pmo, "WM_RPG", 1);
			Console.Printf("WM: %d of the launchers family in hand -- rocket launcher main, RPG off -- %d RocketAmmo in reserve.", putLaunchers, pmo.CountInv("RocketAmmo"));
		}
		else if (e.Name ~== "wm_givebfg")
		{
			pmo.GiveInventory("WM_BFG", 1);
			pmo.GiveInventory("WM_BFGHeavy", 1);
			pmo.GiveInventory("Cell", 320);
			int putBfg = PutByName(pmo, "WM_BFG", 0) + PutByName(pmo, "WM_BFGHeavy", 1);
			Console.Printf("WM: %d of the bfg family in hand -- BFG main, heavy BFG off -- %d Cell in reserve.", putBfg, pmo.CountInv("Cell"));
		}
		else if (e.Name ~== "wm_givechainsaws")
		{
			pmo.GiveInventory("WM_Chainsaw", 1);
			pmo.GiveInventory("WM_ChainsawHeavy", 1);
			int putChainsaws = PutByName(pmo, "WM_Chainsaw", 0) + PutByName(pmo, "WM_ChainsawHeavy", 1);
			Console.Printf("WM: %d of the chainsaws family in hand -- chainsaw main, heavy chainsaw off.", putChainsaws);
		}
		else if (e.Name ~== "wm_giveflamers")
		{
			pmo.GiveInventory("WM_Flamer", 1);
			pmo.GiveInventory("WM_Flamethrower", 1);
			pmo.GiveInventory("Cell", 200);
			int putFlamers = PutByName(pmo, "WM_Flamer", 0) + PutByName(pmo, "WM_Flamethrower", 1);
			Console.Printf("WM: %d of the flamers family in hand -- flamer main, flamethrower off -- %d Cell in reserve.", putFlamers, pmo.CountInv("Cell"));
		}
		else if (e.Name ~== "wm_givemachinegun")
		{
			pmo.GiveInventory("WM_MachineGun", 1);
			pmo.GiveInventory("Clip", 100);
			Class<Inventory> nadeMachinegun = (Class<Inventory>)(Object.FindClass("RSVG_Ammo", "Inventory"));
			if (nadeMachinegun) pmo.GiveInventory(nadeMachinegun, 6);
			int putMachinegun = PutByName(pmo, "WM_MachineGun", 1);
			Console.Printf("WM: %d of the machinegun family in hand -- machine gun off -- %d Clip in reserve.", putMachinegun, pmo.CountInv("Clip"));
		}
		// THE MEATGRINDER FAMILY (meatgrinder.zs): a row a pair of hands, or a gun.
		else if (e.Name ~== "wm_giveassaultshotguns")
		{
			pmo.GiveInventory("WM_AssaultShotgun", 1);
			pmo.GiveInventory("WM_BullpupPump", 1);
			pmo.GiveInventory("Shell", 50);
			int putAssault = PutByName(pmo, "WM_AssaultShotgun", 0) + PutByName(pmo, "WM_BullpupPump", 1);
			Console.Printf("WM: %d of the MeatGrinder shotguns in hand -- assault shotgun main, bullpup pump off -- %d Shell in reserve.", putAssault, pmo.CountInv("Shell"));
		}
		else if (e.Name ~== "wm_givebolter")
		{
			pmo.GiveInventory("WM_Bolter", 1);
			pmo.GiveInventory("Cell", 100);
			int putBolter = PutByName(pmo, "WM_Bolter", 1);
			Console.Printf("WM: %d bolter in the off hand, %d Cell in reserve.", putBolter, pmo.CountInv("Cell"));
		}
		else if (e.Name ~== "wm_givebfgrifle")
		{
			pmo.GiveInventory("WM_BFGRifle", 1);
			pmo.GiveInventory("Cell", 320);
			int putBfgRifle = PutByName(pmo, "WM_BFGRifle", 0);
			Console.Printf("WM: %d BFG rifle in the main hand, %d Cell in reserve.", putBfgRifle, pmo.CountInv("Cell"));
		}
		else if (e.Name ~== "wm_giverotaries")
		{
			pmo.GiveInventory("WM_RotaryGun", 1);
			pmo.GiveInventory("WM_RotaryLauncher", 1);
			pmo.GiveInventory("Clip", 100);
			pmo.GiveInventory("RocketAmmo", 12);
			int putRotaries = PutByName(pmo, "WM_RotaryGun", 0) + PutByName(pmo, "WM_RotaryLauncher", 1);
			Console.Printf("WM: %d of the rotaries in hand -- rotary gun main, rotary launcher off -- %d Clip, %d RocketAmmo in reserve.", putRotaries, pmo.CountInv("Clip"), pmo.CountInv("RocketAmmo"));
		}
		else if (e.Name ~== "wm_givelongbar")
		{
			pmo.GiveInventory("WM_LongbarChainsaw", 1);
			int putLongbar = PutByName(pmo, "WM_LongbarChainsaw", 0);
			Console.Printf("WM: %d longbar chainsaw in the main hand.", putLongbar);
		}
		// RS_GRENADE'S AND RS_SHIELDSAW'S WEAPONS, BY NAME: this package names no
		// class of either mod, so it still loads without them, and the row says so.
		else if (e.Name ~== "wm_givegrenade")
		{
			Class<Inventory> nade = (Class<Inventory>)(Object.FindClass("RS_VRGrenade", "Inventory"));
			Class<Inventory> nadeAmmo = (Class<Inventory>)(Object.FindClass("RSVG_Ammo", "Inventory"));
			if (!nade)
			{
				Console.Printf("WM: RS_Grenade is not loaded -- no grenade to give.");
				return;
			}
			pmo.GiveInventory(nade, 1);
			if (nadeAmmo && pmo.CountInv(nadeAmmo) < 10) pmo.GiveInventory(nadeAmmo, 10 - pmo.CountInv(nadeAmmo));
			int putNade = PutByName(pmo, "RS_VRGrenade", 0);
			Console.Printf("WM: %d grenade in the main hand, %d grenades carried.", putNade, nadeAmmo ? pmo.CountInv(nadeAmmo) : 0);
		}
		else if (e.Name ~== "wm_giveshieldsaw")
		{
			// GIVEN, NOT PUT IN HAND. RS_ShieldSaw keeps its own stowed / drawn /
			// flying state and draws the shield off your forearm itself; a gun-style
			// put-in-hand would draw it while that state still said stowed. Its slot
			// table is rebuilt the way its own grant does.
			Class<Inventory> saw = (Class<Inventory>)(Object.FindClass("RS_ShieldSaw", "Inventory"));
			if (!saw)
			{
				Console.Printf("WM: RS_ShieldSaw is not loaded -- no ShieldSaw to give.");
				return;
			}
			bool hadSaw = pmo.FindInventory(saw) != null;
			pmo.GiveInventory(saw, 1);
			WeaponSlots.SetupWeaponSlots(pmo);
			Console.Printf("WM: ShieldSaw %s -- draw it with its own key or gesture.", hadSaw ? "already carried" : "carried on your forearm");
		}
	}

	// BY NAME AT RUN TIME. The pistols are this package's own now (pistols.zs), but
	// a pistol not carried -- given away, or a player class without them -- should
	// say so in the console, and this stays the one lookup for both hands.
	private int PutByName(PlayerPawn pmo, String className, int hand)
	{
		Class<Inventory> ic = (Class<Inventory>)(Object.FindClass(className, "Inventory"));
		Weapon w = null;
		if (ic) w = Weapon(pmo.FindInventory(ic));
		if (!w)
		{
			Console.Printf("WM: %s is not carried -- nothing put in the %s hand.", className, (hand == 0) ? "main" : "off");
			return 0;
		}
		PutInHand(pmo, w, hand);
		return 1;
	}

	// ONE WAY A GUN GETS INTO A HAND: the reload system's (WM_System.PutGunInHand, RS_VR_Reload
	// 36794c6), which swaps and binds both hands' rigs on the spot -- a bind left to the next
	// WorldTick let that tic's pull be answered by the gun that was there before. The spawn put-in-
	// hand, every wm_give* row and catch-to-equip (weaponset.zs, WM_PairPickup.CatchInto) all come
	// through this door.
	static void PutInHand(PlayerPawn pmo, Weapon weap, int hand)
	{
		let sys = WM_System(EventHandler.Find("WM_System"));
		if (sys) sys.PutGunInHand(pmo, weap, hand);
	}
}
