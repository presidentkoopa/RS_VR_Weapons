# Vanilla+ weapon set: draft

Doc only, weapons lane, 2026-09-14. For the build lane (doomwork-5e) to relay when the owner turns to Vanilla+.

## 0. Built with the owner (09-14, later the same day)

The owner led it. Where this draft's proposals below differ, **these decisions win**:

- **How a game becomes Vanilla+:** a player class. "load doom, new game, choose class": `WM_PlayerPlus` ("Vanilla+") beside
  `WM_Player` ("Vanilla"), MAPINFO PlayerClasses. There is no `wm_weapon_set` switch.
- **The guns:**
  - Vanilla+ gets its own version of each of the 16 Vanilla guns: "not truly clones, we will tune each one's damage and
    rof ... we will add secondary fires".
  - Each is `WM_VP_<gun>`, **only a Weapon Card** in `WMSHEET.plus_*`: `model =` the Vanilla gun's Model Card, a `class`
    block for the class writer, and the Vanilla numbers to start from. No inheritance from the Vanilla class.
  - Plus the SMG, Tec9, Rifle, M16, Moonlight, Sunset, Cola Revolver, Flamer, Flamethrower and the Railgun.
  - Next: tune them three at a time.
- **Pickups:** one gun per pickup, the next on the pickup's list you don't carry (the owner's standing rule). Each class
  gets its own set's guns from the same pickup (`WM_PairPickup.PlusGuns`).
  - The families go on the common pickups: Shotgun gets the revolvers and SMGs, Chaingun the rifles, Plasma Rifle the
    flamers (and the Railgun).
  - A gun on another ammo than its pickup's comes with its own (twice that ammo's small pickup).
- **The M16:** in the off hand, the Rifle's partner. Its card was changed by the reload lane.

- **Mechanics** (alt fires, the one-handed pump toss, speedloaders, archetype work) are the reload lane's plan:
  `RS_VR_Reload/VANILLA_PLUS_MECHANICS.md` (uzdxrema-63, drafting).
- **Looks** come from the ballistics lane's coverage list (uzdxrema-45, 09-14).
- **Sounds, hands, slots, ammo and mesh sources** come from the classes, WMCARD.txt, SNDINFO.txt and ASSET_PROVENANCE.md.

**What the owner asked for:** the same models plus "the newer SMG, revolver, rifle, flamethrower, grenade launcher and maybe
one more; modern guns and alt fires".

---

## 1. Where things stand

- **Vanilla:** 16 guns on Doom's 8 weapon pickups as pairs, the Bullpup Pump on the Super Shotgun pickup, plus the grenade
  and the ShieldSaw.
- **The Double Barrel left the set on 09-14** (the owner: "too many shotguns"). Its class, card, mesh and give command stay.
- **Every gun below is already wired:** class, card, mesh, placement page and arsenal give row. None is on a Doom pickup,
  so today they come only from the test arsenal (`wm_start_arsenal`) or the arsenal page.

## 2. The Vanilla+ guns

"Borrowed" = another gun's sounds. "Legacy" = the ballistics lane's older generic profile: it works, but has no identity.
Grabs: the reload lane's read of each card's ESTIMATE marks (uzdxrema-63, 09-14); "partly" names what is still estimated.

| Gun | Hand | Slot | Ammo | Mesh from | Sounds | Looks (RS_Ballistics) | Grabs |
|---|---|---|---|---|---|---|---|
| Moonlight | main | 4 | Clip (speedloaders) | ModelSwapper MS_Revolver | shared revolver set, the same as Sunset and Cola | legacy flash; shared .357 round and brass | partly: grab sizes |
| Sunset | off | 4 | Clip | ModelSwapper MS_Revolver2 | shared revolver set | as Moonlight | measured |
| Cola Revolver | off | 4 | Clip | ModelSwapper MS_Cola_Revolver | shared revolver set | as Moonlight | partly: load-gate sizes |
| Rifle | main | 5 | Clip | ModelSwapper rifle | its own | legacy flash; 7.62 round with a glow wake; shared brass | partly: eject point, support grab |
| M16 | main | 5 | Clip | ModelSwapper MS_Rifle | borrowed: the Rifle's whole set | legacy flash; 5.56 round as the Rifle's | partly: eject port, support grab |
| SMG | main | 6 | Clip | ModelSwapper SMG | borrowed: M4A3 fire, Rifle mag and rack | legacy flash; its own plain .45 round | partly: eject point, slide travel, support grab |
| Tec9 | off | 6 | Clip | ModelSwapper MS_MG_Tec9 | borrowed: the 9mm Handgun's whole set | legacy flash; its own plain 9mm round | partly: eject point, support grab |
| Railgun | main | 9 | Cell | ModelSwapper RailGun | own names, plasma files (alt fire and cell) | **finished**: own flash, trail, impact | partly: slide radius and detach (the SMG's), support grab |
| Flamer | main | 0 | Cell | ModelSwapper MS_AE_Flamer | no fire sound on the card; plasma cell sounds | **finished**: own flame; no flash by design | partly: support grab |
| Flamethrower | off | 0 | Cell | Force Unleashed incinerator | as Flamer | **finished**: own napalm | partly: tank part, a hinge radius |
| Assault Shotgun | main | 3 | Shell | RS_Main RS_GH_AssaultShotgun | borrowed: Doom's shotgun, Rifle mag and rack | legacy flash; shared buckshot and hull | partly: eject port point and side |
| Machine Gun's grenade launcher (alt fire) | on the off-hand MG | 7 | grenades | the MG's | **own** (09-14) | own launcher flash; the grenade is RS_Grenade's | measured 09-14 |
| Bolter | off | 9 | Cell | ModelSwapper MS_MG_Bolter | borrowed: plasma fire and cell | legacy flash; the Plasma Rifle's ball | measured |
| BFG Rifle | main | 0 | Cell | RS_Main MeatGrinder | none on the card; class charge sound | legacy flash; the BFG's ball | partly: cell centre and pull-out |
| Rotary Gun | main | 7 | Clip | RS_Main MeatGrinder | borrowed: the Chaingun's set | legacy flash; rifle round, not the chaingun's tracers | partly: eject port, support grab |
| Rotary Launcher | off | 8 | Rockets | RS_Main MeatGrinder | fire only, no reload sounds | legacy flash; the rocket launcher's rocket | partly: which tube fires, support grab |
| Longbar Chainsaw | main | 1 | none | RS_Main MeatGrinder | own idle; cut shared | the Chainsaw's cut | partly: where the support hand goes |
| Unmaker | main | 0 | Cell (100-cell skull) | RS_Main RS_GH_Unmaker | **own**: beam spin-up, loop, wind-down | **finished**: own flash, hot spot, melt | partly: support grab spot |
| Double Barrel (left Vanilla 09-14) | off | none | Shell | Force Unleashed ssg | its own | its own flash | measured 09-14 |

## 3. Hands: which guns pair

- **Main hand only:** Moonlight, Rifle, M16, SMG, Railgun, Flamer, Assault Shotgun, BFG Rifle, Rotary Gun, Longbar, Unmaker.
- **Can go in the off hand:** Sunset, Cola, Tec9, Flamethrower, Bolter, Rotary Launcher, Double Barrel.
- **Natural pairs, same ammo:**
  - Moonlight + Sunset (Cola as the other off-hand revolver)
  - SMG + Tec9
  - Railgun + Bolter
  - Flamer + Flamethrower
  - Assault Shotgun + Double Barrel, if it comes back
- **Snags:**
  - The Rifle and the M16 are both main-hand only.
  - The BFG Rifle and the Unmaker are both main-hand only.
  - The Rotary Gun (Clip) and Rotary Launcher (rockets) mix ammo.
  - The Longbar's only off-hand partner is the vanilla Heavy Chainsaw.

## 4. How a Vanilla+ game starts and hands out guns

**Proposal (weapons lane, ZScript only, not built):**
- **One server switch** on the weapon-set page, `wm_weapon_set`: Vanilla / Vanilla+ / Test arsenal. It replaces
  `wm_start_arsenal`; "Test arsenal" is today's "on".
- **The start:** Doom's, as in Vanilla: fists, M4A3 and 9mm Handgun, 50 Clip.
- **Pickups:**
  - Each Doom weapon pickup keeps its Vanilla pair and gains Vanilla+ pairs.
  - In a Vanilla+ game, each pickup takes one of its pairs from its spawn number: the same number catch-to-equip's network
    events already use.
  - Every machine picks the same pair, with no random numbers, and a map shows old and new guns side by side.
  - A dropped weapon follows the same rule.

| Doom pickup | Vanilla pair | Vanilla+ pairs |
|---|---|---|
| Pistol | M4A3 + 9mm Handgun | Moonlight + Sunset |
| Shotgun | M37 + Doom pump | Assault Shotgun + Double Barrel (choice 7) |
| Super Shotgun | Super Shotgun + Bullpup Pump | unchanged |
| Chaingun | Chaingun + Machine Gun | SMG + Tec9; Rifle + M16 (choice 2); Rotary Gun + Machine Gun |
| Rocket Launcher | Rocket Launcher + RPG | Rocket Launcher + Rotary Launcher |
| Plasma Rifle | Plasma Rifle + Plasma Carbine | Railgun + Bolter; Flamer + Flamethrower |
| BFG | BFG + Heavy BFG | BFG Rifle + Heavy BFG |
| Chainsaw | Chainsaw + Heavy Chainsaw | Longbar + Heavy Chainsaw |

- **The Unmaker:** on no pickup (choice 3).
- **The grenade launcher:**
  - The Machine Gun's underbarrel launcher is already live; the owner kept it in Vanilla (VANILLA_PARITY F5).
  - Vanilla+ is where it gets its alt-fire polish (reload lane).
  - A standalone launcher would be a new gun (choice 5).
- **Build shape:** WM_PairPickup holds a list of pairs, WM_WeaponSet reads `wm_weapon_set`, and ApplyStart trims per set.
- **Netplay:** a server cvar and the spawn number only. No local reads, no consoleplayer.

## 5. Work per gun before Vanilla+ ships

- **Sounds (weapons lane):** give each borrowed set its own, from RS_Main's per-weapon folders, picked by measurement as for
  Vanilla:
  - the three revolvers, which all sound alike;
  - M16, SMG, Tec9, Assault Shotgun, Bolter and Rotary Gun;
  - the BFG Rifle (nothing on its card);
  - the Rotary Launcher (no reload sounds);
  - the flamers (no fire sound on the card: check the flame shots);
  - the Railgun (plasma files).
- **Looks (ballistics lane's list):**
  - own flashes for the three revolvers (a cylinder-gap blast each, with gap smoke), Rifle, M16, SMG, Tec9, Assault Shotgun
    (full auto), Bolter, BFG Rifle and Rotary Launcher;
  - the Rifle a vapour trail instead of the glow wake, and the M16 its own round;
  - the Bolter a heavy-bolt subclass;
  - the BFG Rifle a charge look;
  - the Rotary Gun the chaingun's tracers and a spin-up flash;
  - the Longbar its own cut, or the Heavy Chainsaw's;
  - a smoke thread on the launcher grenade, if RS_Grenade gives a hook.
  - The Railgun, flamers and Unmaker are finished.
- **Cards (reload lane):** measure the ESTIMATE grabs as was done for Vanilla on 09-14, plus the mechanics plan's alt fires.

## 6. Later and parked

- **The model swap:** the Force Unleashed Plasma Carbine and Chaingun meshes become RS_Main's RS_GH_Plasma and RS_GH_Minigun.
  - One small batch once the model pause lifts: mesh, MODELDEF and card geometry via the reload lane.
  - Class, card and part ids are kept for the bake ledger. The owner mentioning it again is the go.
- **RS_Main batch 1** (MP40, M9, Trench Gun, Sawed-Off, M79 grenade launcher, Gatling Gun, Tank Flamethrower, Shot Revolver):
  - Their meshes were built, then parked in the weapons lane's session scratch folder.
  - That folder is temporary: move them somewhere durable if they're wanted.
- **The unused assault shotgun mesh** (`models/shotguns/AssaultShotgun/*`, ASSET_PROVENANCE row 32):
  - An authored mod's mesh, "carried, drawn by nothing", still packed.
  - The Assault Shotgun draws RS_GH_AssaultShotgun now. Recommend dropping it from the pk3.
- **The one-handed pump toss:** reload lane.

## 7. Choices for the owner

1. **How Vanilla+ hands out the new guns.** Recommend: Doom's own pickups, each giving either its classic pair or a new pair,
   mixed through every map, and the same for everyone in netplay.
2. **The two rifles.** The Rifle and the M16 both only go in your main hand, so they can't come as a pair. Recommend: let the
   M16 go in the off hand.
3. **The Unmaker.** Recommend: a rare find (at most one an episode, or on secret levels), not on the BFG pickup.
4. **How a Vanilla+ game starts.** Recommend: like Doom (fists, M4A3, 9mm Handgun), the same as Vanilla.
5. **The grenade launcher.** Recommend: the machine gun's underbarrel launcher for now; a standalone launcher from RS_Main's M79
   after the model pause.
6. **The "maybe one more".** Recommend: the Railgun. It's built and its looks are finished.
7. **The Double Barrel.** Recommend: back in Vanilla+ as the Assault Shotgun's off-hand partner, rather than gone for good.
8. **What gets polished first.** Recommend: the guns that borrow the most (the three revolvers, the SMG, Tec9 and M16), then the
   MeatGrinder guns.
