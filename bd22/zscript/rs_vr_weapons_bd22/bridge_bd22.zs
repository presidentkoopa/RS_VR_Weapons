// ============================================================================
// THE BD22 SET'S BRIDGE -- what you get when you walk over a gun.
//
// TWO JOBS, AND THE SECOND ONE IS THE POINT.
//
//   1. DOOM'S OWN PICKUPS become these guns, always. That is what makes this set work
//      with nothing loaded but Doom: the shotgun on the floor of E1M1 hands you BD's
//      shotgun in your hand, not Doom's sprite.
//
//   2. BRUTAL DOOM'S OWN PICKUPS become these guns TOO, but only when Brutal Doom is
//      actually loaded. Then this stops being a replacement for Doom's arsenal and
//      becomes the 3D weapon set FOR Brutal Doom -- its maps, its monsters, its
//      balance, its guns, in your hands.
//
// HOW IT KNOWS. `Marker()` names a class that exists ONLY in the parent mod;
// `parentLoaded` is the engine answering whether that class resolves. BrutalPistol is
// Brutal Doom's own sidearm and nothing else defines it.
//
// THE NAMES BELOW ARE READ OUT OF THE MOD ITSELF -- brutal22test6.pk3's
// actors/Weapons/*.dec, 81 weapon-parented actors, of which these are the guns. They
// are not guessed, and a guessed swap is worse than no swap: it hands the player the
// wrong weapon and quietly changes what the mod is.
//
// MAPPED BY ROLE. MG42 goes to BD_Buzzsaw because Hitler's Buzzsaw IS the MG42 -- the
// mesh is HitlersBuzzsaw.md3 and the actor is MG42. Naming alone would have missed it.
//
// WHAT IS DELIBERATELY NOT SWAPPED:
//   Devastator, IncendiaryLauncher, NukeLauncher, Sniper -- Brutal Doom has these and
//   this set has no mesh for any of them. Leaving them alone means the mod's own
//   sprite weapon stays, which is honest. Replacing them with a lookalike would hand
//   the player a rocket launcher and call it a nuke.
//   The DUALS (DualPistols, DualSMG, DualMP40, DualRifles, DualPlasmaRifles) -- in VR
//   you hold two guns, one per hand. A welded pair is the desktop answer to a problem
//   we do not have.
// ============================================================================

class BD22_Bridge : WM_SetBridge
{
	// Brutal Doom's own sidearm: present only when Brutal Doom itself is loaded.
	override String Marker() { return "BrutalPistol"; }
	// WITH BRUTAL DOOM LOADED, ANSWER FOR EVERY CLASS -- there is nothing to pick.
	//
	// Loading Brutal Doom AND this set IS the choice. And it had to be this way regardless:
	// Brutal Doom writes the `playerclass` cvar itself (the owner's ini came back as
	// `playerclass=$TAGBD_CLASS_PISTOL`), that name matches no class of ours, so
	// D_PlayerClassToInt returns -1 and the engine falls back to class 0, which is Vanilla.
	// With Brutal Doom in the load order this set's own class could never be selected at all.
	//
	// The gate still stands with Brutal Doom absent, where several sets map DOOM's pickups and
	// must not fight over them. Nothing else maps BD's class names, so this costs them nothing.
	override String SetClass() { return parentLoaded ? "" : "WM_PlayerBD22"; }

	override void Configure()
	{
		if (parentLoaded)
		{
			// ---- BRUTAL DOOM'S OWN WEAPON CLASSES, one for one ----------------------
			Swap("BrutalPistol",          "BD_Pistol");
			Swap("Revolver",              "BD_Revolver");
			Swap("Shot_Gun",              "BD_Shotgun");
			Swap("SSG",                   "BD_SSG");
			Swap("AssaultShotgun",        "BD_AssaultShotgun");
			Swap("MP40",                  "BD_MP40");
			Swap("BrutalSMG",             "BD_SMG");
			Swap("Rifle",                 "BD_Rifle");
			Swap("MG42",                  "BD_Buzzsaw");     // the Buzzsaw IS the MG42
			Swap("MiniGun",               "BD_Minigun");
			Swap("Rocket_Launcher",       "BD_RPG");
			Swap("GrenadeLauncher",       "BD_M79");
			Swap("HellishMissileLauncher","BD_Hellish");
			Swap("Plasma_Gun",            "BD_Plasma");
			Swap("RailGun",               "BD_Railgun");
			Swap("FlameCannon",           "BD_FlameCannon");
			Swap("Flamethrower2",         "BD_Flamethrower");
			Swap("BIG_FUCKING_GUN",       "BD_BFG");
			Swap("BFG10k",                "BD_BFG10k");
			Swap("Unmaker",               "BD_Unmaker");
			Swap("Chain_saw",             "BD_Chainsaw");
			Swap("BrutalAxe",             "BD_Axe");
			Swap("DSweap",                "BD_Dragonslayer");
			Swap("HandGrenades",          "BD_Grenade");

			// ---- ITS AMMO, BACK TO DOOM'S (2026-09-28) ------------------------------
			//
			// This used to say "its ammo needs no swap". It does. Brutal Doom's
			// actors/MISC/Ammo.dec REPLACES every one of Doom's ammo classes:
			//     Clip2 replaces Clip        ClipBox2 replaces ClipBox
			//     AmmoShell replaces Shell   AmmoShellBox replaces ShellBox
			//     AmmoCell replaces Cell     AmmoCellPack replaces CellPack
			//     AmmoRocket replaces RocketAmmo   AmmoRocketBox replaces RocketBox
			// Every gun on this set's sheet draws on Doom's Clip/Shell/Cell/RocketAmmo,
			// so with Brutal Doom loaded the reserve was ALWAYS ZERO: the guns that fire
			// from reserve clicked dry and nothing could reload. The Brutal Wolfenstein
			// bridge hit the same wall and solved it the same way.
			//
			// Final (the base class sets it), so Brutal Doom's `replaces` never gets the
			// spawn back. Its own sub-kinds (Easy/Realism/EZ boxes) and zombie drops go
			// to the matching Doom pickup too.
			Swap("Clip2",            "Clip");
			Swap("EasyClip2",        "Clip");
			Swap("Clip1Drop",        "Clip");
			Swap("ClipBox2",         "ClipBox");
			Swap("RealismAmmoBox",   "ClipBox");
			Swap("EasyAmmoBox",      "ClipBox");
			Swap("AmmoShell",        "Shell");
			Swap("AmmoShellBox",     "ShellBox");
			Swap("AmmoShellBoxEZ",   "ShellBox");
			Swap("AmmoCell",         "Cell");
			Swap("AmmoCellPack",     "CellPack");
			Swap("AmmoRocket",       "RocketAmmo");
			Swap("AmmoRocketBox",    "RocketBox");
			Swap("AmmoRocketBoxEZ",  "RocketBox");
			Swap("AmmoSuply",        "Backpack");   // BD's backpack fills BD ammo; ours fills Doom's
		}

		// ---- AND DOOM'S OWN, BY ROLE, whether or not Brutal Doom is loaded ----------
		Swap("Pistol",         "BD_Pistol");
		Swap("Shotgun",        "BD_Shotgun");
		Swap("SuperShotgun",   "BD_SSG");
		Swap("Chaingun",       "BD_Minigun");
		Swap("RocketLauncher", "BD_RPG");
		Swap("PlasmaRifle",    "BD_Plasma");
		Swap("BFG9000",        "BD_BFG");
		Swap("Chainsaw",       "BD_Chainsaw");
	}

	// ---- AND THE GUNS THE PLAYER IS HANDED, WHICH NEVER TOUCH THE FLOOR ----------
	//
	// WHY THIS EXISTS AND NO OTHER SET NEEDS IT.
	//
	// CheckReplacement only sees things that SPAWN IN THE WORLD. Brutal Doom's player is
	// given its arsenal directly -- actors/PlayerClasses/23Player.dec:
	//     Player.StartItem "Rifle"
	//     Player.StartItem "Melee_Attacks"
	// -- so those weapons never spawn as pickups and nothing above ever sees them. You
	// start the map holding Brutal Doom's own sprite guns and the bridge has done nothing
	// wrong; it was never asked.
	//
	// AND YOU CANNOT SIDESTEP IT BY PICKING THIS SET ON THE CLASS SCREEN, because Brutal
	// Doom's KEYCONF opens with `clearplayerclasses` and then adds its own five. KEYCONF
	// is read after MAPINFO, so WM_PlayerBD22 is DELETED before the menu is built. With
	// Brutal Doom loaded there is no row to pick -- which is exactly why SetClass() above
	// returns empty while parentLoaded.
	//
	// So the swap has to happen at the PLAYER: when one spawns, take Brutal Doom's guns
	// out of its inventory and put this set's in their place.
	//
	// THE TABLE IS DUPLICATED HERE ON PURPOSE. WM_SetBridge keeps its own swaps private,
	// so this cannot read them; stating them twice is better than widening a base class
	// every other set depends on. If a line is added to Configure() above, add it here.
	private void SwapCarried(PlayerPawn pmo)
	{
		static const String FROM[] = {
			"BrutalPistol", "Revolver", "Shot_Gun", "SSG", "AssaultShotgun", "MP40",
			"BrutalSMG", "Rifle", "MG42", "MiniGun", "Rocket_Launcher", "GrenadeLauncher",
			"HellishMissileLauncher", "Plasma_Gun", "RailGun", "FlameCannon",
			"Flamethrower2", "BIG_FUCKING_GUN", "BFG10k", "Unmaker", "Chain_saw",
			"BrutalAxe", "DSweap", "HandGrenades" };
		static const String TO[] = {
			"BD_Pistol", "BD_Revolver", "BD_Shotgun", "BD_SSG", "BD_AssaultShotgun", "BD_MP40",
			"BD_SMG", "BD_Rifle", "BD_Buzzsaw", "BD_Minigun", "BD_RPG", "BD_M79",
			"BD_Hellish", "BD_Plasma", "BD_Railgun", "BD_FlameCannon",
			"BD_Flamethrower", "BD_BFG", "BD_BFG10k", "BD_Unmaker", "BD_Chainsaw",
			"BD_Axe", "BD_Dragonslayer", "BD_Grenade" };

		// THE GUN IN HAND HAS TO BE RE-SELECTED. Destroying the weapon the player is holding
		// (or about to raise) does not raise the replacement: the engine falls back to
		// whatever else is carried -- Brutal Doom's Melee_Attacks, a sprite -- and the new
		// 3D gun sits unselected in the inventory. So note which swapped gun was in hand
		// and select its replacement afterwards. (2026-09-27, "I start with sprite weapons")
		Class<Weapon> selectAfter = null;
		Weapon ready = null;
		Weapon pending = null;
		if (pmo.player != null)
		{
			ready = pmo.player.ReadyWeapon;
			pending = pmo.player.PendingWeapon;
		}

		int swapped = 0;
		for (int i = 0; i < FROM.Size(); i++)
		{
			Class<Inventory> had = (Class<Inventory>)(Object.FindClass(FROM[i], "Inventory"));
			if (!had) continue;                       // that gun is not in this build
			let item = pmo.FindInventory(had);
			if (!item) continue;                      // the player was not given it
			Class<Inventory> want = (Class<Inventory>)(Object.FindClass(TO[i], "Inventory"));
			if (!want)
			{
				// NOT SILENT. Our class missing means the gun framework did not load.
				Console.Printf("\cgBD22: cannot swap %s -- class %s does not exist. Is the reload system pack loaded?", FROM[i], TO[i]);
				continue;
			}
			if (item == ready || item == pending) selectAfter = (Class<Weapon>)(want);
			swapped++;
			// ORDER MATTERS. Give first, then destroy: a player whose ReadyWeapon is
			// destroyed with nothing to fall back on comes up empty-handed.
			if (!pmo.FindInventory(want)) pmo.GiveInventory(want, 1);
			item.Destroy();
		}
		// NOTHING SWAPPED MEANS NOTHING TO DO, AND THAT MATTERS BECAUSE THIS RUNS ON A
		// TIMER. Rebuilding the slot table is not free and it is not inert: it re-runs
		// weapon selection, which the reload system feels as the gun in your hand
		// changing -- and it answers with a haptic pulse. Called unconditionally once a
		// second, that is a buzz in the controller from the moment a level loads, for
		// ever, whatever you are holding. The owner felt it immediately (2026-09-27).
		//
		// So the slot rebuild and the re-select belong to an ACTUAL swap, not to the
		// sweep that went looking for one.
		if (swapped == 0) return;

		// The slot table was built during player setup, before these gives -- without a
		// rebuild the guns are carried and in no slot at all.
		WeaponSlots.SetupWeaponSlots(pmo);

		if (selectAfter != null && pmo.player != null)
		{
			let w = Weapon(pmo.FindInventory(selectAfter));
			if (w) pmo.player.PendingWeapon = w;
		}
	}

	// ---- NO TIMER (2026-09-28) ------------------------------------------------
	//
	// A once-a-second sweep used to live here. It rebuilt the weapon slots every
	// time it found something, and that rebuild re-selects the gun in your hand --
	// the reload system feels that as a gun change and buzzes the controller, once a
	// second, forever. RS_VR_BD22_Players.pk3 now hands out these guns at spawn and
	// RS_VR_BD22_Slots.pk3 puts them on the number keys, so nothing has to be chased.
	// PlayerSpawned below stays as a one-shot safety net.

	override void PlayerSpawned(PlayerEvent e)
	{
		// ASK THE ENGINE DIRECTLY, DO NOT READ parentLoaded.
		//
		// parentLoaded is only set inside WM_SetBridge.EnsureReady(), which the base class
		// calls from CheckReplacement -- i.e. the first time something SPAWNS that might be
		// replaced. A player spawning does not go through that path, so on the run that
		// matters parentLoaded is still false here and this handler returned immediately,
		// every single time. The guns were never swapped and Brutal Doom's own sprite
		// weapons stayed in the player's hands.
		//
		// FindClass is the same question EnsureReady asks, and it is safe to ask at any
		// point: every package's classes exist before anything spawns.
		if (Object.FindClass(Marker(), "Actor") == null) return;   // no Brutal Doom loaded
		if (e.PlayerNumber < 0 || e.PlayerNumber >= MAXPLAYERS) return;
		if (!playeringame[e.PlayerNumber]) return;
		let pmo = players[e.PlayerNumber].mo;
		if (pmo) SwapCarried(pmo);
	}

	// ---- WHY WON'T IT FIRE (2026-09-28) -----------------------------------------
	//
	// Type  netevent bd22_why  in the console. It prints what is holding the trigger
	// right now, then prints again every time you pull the trigger for the next ten
	// seconds. Read-only: it changes nothing.
	private int whyUntil;
	private int whyLast;

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "bd22_why")) return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		whyUntil = level.maptime + 350;
		Why(e.Player, "asked");
	}

	// ---- THE PARENT'S ACS PUTS ITS OWN GUNS BACK IN YOUR HAND (2026-09-29) -------
	//
	// PARENT_AUDIT counts sixteen SetWeapon calls in Brutal Doom's ACS. Most of them
	// restore lastwep[] after one of its features runs -- a kick, a mantle, an
	// execution, dropping ammo -- and lastwep was captured as ITS OWN class, so the hand
	// comes back holding a sprite gun although the player never switched weapon.
	// WeapSelect.acs's TakeInventory can hand one back the same way. None of this goes
	// through CheckReplacement or PlayerSpawned, so nothing in this bridge saw it.
	//
	// THIS IS NOT THE TIMER THAT WAS REMOVED ABOVE, and the difference is the whole
	// point. The sweep ran unconditionally and rebuilt the weapon slots whenever it felt
	// like it, which re-selects the gun in your hand and buzzes the controller once a
	// second for ever. This asks one question -- is the thing in my hand one of OURS? --
	// and only then goes looking. SwapCarried already returns before the slot rebuild
	// when it finds nothing to swap, so on every ordinary tic this costs one `is` test
	// per player and changes nothing at all.
	//
	// ITS FEATURE WEAPONS ARE LEFT ALONE ON PURPOSE. Melee_Attacks, LedgeGrab,
	// ExecutionWeapon, AmmoDroper and the shield weapon are not in the swap table, so a
	// kick and a mantle still run exactly as the mod intends. Holding one of them is in
	// fact what triggers the look -- they are not WM_Guns either -- and SwapCarried then
	// fixes any of ITS GUNS the ACS left in the inventory without touching what is in
	// hand: selectAfter is set only when the swapped item WAS the held or pending one.
	// So the kick finishes, and the gun you come back to is ours.
	private void GuardAgainstParentACS()
	{
		if (Object.FindClass(Marker(), "Actor") == null) return;   // no parent mod loaded
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let pl = players[i].mo.player;
			if (!pl) continue;
			// Anything in hand that is not one of our guns means either the parent's ACS
			// has been at work or one of its features is running. Both want the sweep.
			bool foreign = (pl.ReadyWeapon   && !(pl.ReadyWeapon   is 'WM_Gun'))
			            || (pl.PendingWeapon && !(pl.PendingWeapon is 'WM_Gun'));
			if (foreign) SwapCarried(players[i].mo);
		}
	}

	override void WorldTick()
	{
		GuardAgainstParentACS();
		if (level.maptime > whyUntil) return;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let pl = players[i].mo.player;
			bool down = (pl.cmd.buttons & (BT_ATTACK | BT_OFFHANDATTACK)) != 0;
			if (down && level.maptime - whyLast >= 17)
			{
				whyLast = level.maptime;
				Why(i, "trigger");
			}
		}
	}

	private static String Cls(Object o) { return o ? String.Format("%s", o.GetClassName()) : "none"; }

	private static int Has(Actor a, String cls)
	{
		Class<Inventory> c = (Class<Inventory>)(Object.FindClass(cls, "Inventory"));
		if (!c) return -1;
		let it = a.FindInventory(c);
		return it ? it.Amount : 0;
	}

	private void Why(int pn, String why)
	{
		let pmo = players[pn].mo;
		let pl = pmo.player;
		Console.Printf("\cf[bd22_why %s] pawn %s  ready %s  pending %s  offhand %s",
			why, Cls(pmo), Cls(pl.ReadyWeapon), Cls(pl.PendingWeapon), Cls(pl.OffhandWeapon));

		int ws = pl.WeaponState;
		Console.Printf("  weaponstate: ready=%d  buttons=%x  attack=%d  frozen=%d totallyfrozen=%d",
			(ws & WF_WEAPONREADY) ? 1 : 0, pl.cmd.buttons,
			(pl.cmd.buttons & BT_ATTACK) ? 1 : 0,
			(pl.cheats & CF_FROZEN) ? 1 : 0, (pl.cheats & CF_TOTALLYFROZEN) ? 1 : 0);

		let psp = pl.FindPSprite(PSP_WEAPON);
		if (psp && psp.CurState && pl.ReadyWeapon)
		{
			let w = pl.ReadyWeapon;
			String where = "other";
			if (Actor.InStateSequence(psp.CurState, w.FindState("Ready")))      where = "Ready";
			else if (Actor.InStateSequence(psp.CurState, w.FindState("Fire")))  where = "Fire";
			else if (Actor.InStateSequence(psp.CurState, w.FindState("Select"))) where = "Select";
			else if (Actor.InStateSequence(psp.CurState, w.FindState("Deselect"))) where = "Deselect";
			Console.Printf("  weapon sprite state: %s (tics %d)", where, psp.Tics);
		}

		let sys = WM_System(EventHandler.Find("WM_System"));
		for (int h = 0; h < 2; h++)
		{
			let gun = sys ? sys.GunInHand(pn, h) : null;
			if (!gun) { Console.Printf("  hand %d: no carded gun", h); continue; }
			let ammo = gun.EnsureAmmo();
			Console.Printf("  hand %d: %s  canfire=%d  fireblocked=%d",
				h, Cls(gun), sys.CanFire(pn, h, 1, 1, gun) ? 1 : 0,
				(ammo && ammo.fireBlocked) ? 1 : 0);
		}

		Console.Printf("  reserve: Clip %d Shell %d Cell %d Rocket %d | BD: Clip2 %d AmmoShell %d AmmoCell %d AmmoRocket %d",
			Has(pmo, "Clip"), Has(pmo, "Shell"), Has(pmo, "Cell"), Has(pmo, "RocketAmmo"),
			Has(pmo, "Clip2"), Has(pmo, "AmmoShell"), Has(pmo, "AmmoCell"), Has(pmo, "AmmoRocket"));

		Console.Printf("  BD tokens: GoSpecial %d Kicking %d InAction %d BDWeaponAction %d Grabbing_A_Ledge %d GoFatality %d Reloading %d",
			Has(pmo, "GoSpecial"), Has(pmo, "Kicking"), Has(pmo, "InAction"), Has(pmo, "BDWeaponAction"),
			Has(pmo, "Grabbing_A_Ledge"), Has(pmo, "GoFatality"), Has(pmo, "Reloading"));
	}
}
