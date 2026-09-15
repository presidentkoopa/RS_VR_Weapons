# Vanilla+ tuning, round 1: the owner's design (2026-09-15)

The owner led this design with the weapons lane directly, in their words and multiple-choice answers.
- **The weapons lane:** writes each gun's numbers on its Weapon Card (WMSHEET.plus_*).
- **The mechanics below:** new reload-system code (RS_VR_Reload, the reload lane) and recoil work (RS_Ballistics, the
  ballistics lane).
- **Stat sources:** vanilla Doom for the Doom guns, RS_Main Uncommon for revolver / rifle / SMG / flamethrower / railgun.
  Never another mod's numbers.
- **Balance context:** the owner plays Project Babel monsters (maybe Malice later) on Brutal Difficulties' **Black Metal**:
  the player takes 1.5x damage, monsters have 0.8x health, FastMonsters, ammo 1x.

## 1. Rate of fire -- DONE (823591a, installed)

"I can fire a semi auto weapon about six times per second ... Pistol, Revolver, Rifle, one shot per pull."
- **Pistols (Vanilla+ Pistol, Handgun) and revolvers (Moonlight, Sunset, Cola):** `firetics = 6` (5.8 a second).
- **Rifle and M16:** start in single fire, `fullauto = false`, `firetics = 6`.

## 2. Accuracy is recoil (ballistics lane + reload lane)

- **Recoil is the source of every accuracy penalty.** The owner: "vanilla+ should take advantage of our more advanced
  ballistic shit, such as recoil. that should be the source of all accuracy penalties ... isn't that how it works IRL?"
  With `sv_rsb_recoil` on, a shot's kick moves the real aim and recovers. Burst and full auto stack kicks, so they go wide by
  themselves.
- **Two-handing tames recoil** (the owner: "Two handing the pistol negates the accuracy penalty, both alt fire and normal
  fire"). With the other hand on the gun's support grip, the kick is much smaller.
  - *Needs:* RS_Ballistics' recoil to take a per-shot "braced" scale.
  - *Who reads it:* the reload system, which already knows it (system.zs SupportHeld).
  - *The scale:* the ballistics lane proposes it.
- **Recoil off: spread fallback** (the owner's choice). With `sv_rsb_recoil` off, each quick shot widens the spread cone the
  way recoil would have, then it recovers, so bursts and full auto are never lasers. Two-handing shrinks it the same way.
- **Every Vanilla+ gunshot fires in a tight ROUND CONE with vertical spread** (the owner: "All Vanilla+ gunfire"; "i want to
  have some vertical spread too whereas traditional doom only has horizontal spread").
  - *Today:* weapon.zs 1031-1032 rolls yaw and pitch independently, which makes a box.
  - *Needs:* a sheet key for the cone shape (for example `spreadshape = cone`, radius from `shotspread`), and a uniform or
    triangular radius in a round pattern.
  - *Scope:* Vanilla's guns keep Doom's spread.

## 3. Alt fires (reload lane mechanics; the weapons lane writes the values)

| Gun(s) | Alt fire | Notes |
|---|---|---|
| **Pistol, Handgun** (Vanilla+) | **3-round burst** | "Slightly faster than it would be if i had done three pulls" -- a round every ~4 tics (three pulls at 6 tics = 18). Burst recoil stacks; two-handing tames it. |
| **Moonlight, Sunset, Cola Revolver** | **Fan the hammer** | "hold down fire, and fan with the opposing hand." One shot per sweep of the other hand across the hammer part (the cards have `role = hammer`). Cap about 8 a second (the owner's pick; "I can fan six times per second. Makes my hand tired"). Wider cone than an aimed shot. |
| **Rifle, M16** | **Select fire** | Start single. Alt cycles single -> 3-round burst -> full auto -> single ("altfire to switch to three shot burst. altfire again to full auto. repeat"). |
| **Steelgun** (Vanilla+) | **Slamfire** | Hold alt and work the pump: it fires every time the action closes. |
| **Shotgun** (Vanilla+) | **Slug toggle** | Alt switches buckshot / slug. A slug is ONE pellet carrying all seven pellets' damage, on the tight cone -- no new art or ammo type (the owner). |
| **Super Shotgun** (Vanilla+) | **One barrel at a time** | Each alt pull fires the next loaded barrel. |
| **Quad Super** (Vanilla+) | **Two shells at once** | ONE blast: the usual 20 pellets at DOUBLE damage, spends two shells, one flash and sound. Not 40 rounds, which is too heavy on RS_Ballistics' per-pellet effects. |
| **SMG, Tec9** | **Hold alt to shred** | Double rate while alt is held. The recoil stack makes it wild past close range; it empties a magazine quickly. |

The Chaingun, Machine Gun (its grenade launcher stays), launchers, plasma, BFGs and saws aren't in round 1.

## 4. Netplay (non-negotiable)

- **The fan gesture:** detected on the shooter's own machine from their hand movement (AttackVel / OffhandVel read zero in
  a netgame, so velocity can't be read anywhere else). It travels as a network event the shot fires from on every machine,
  as RS_Grenade's throw does.
- **Every other alt fire:** a button already in the ticcmd.
- **Fire mode, slug toggle and the braced state:** decided in the playsim from networked input, never from the console
  player.

## 5. The roster (the owner, 09-15)

- **Three pistols:** "Black Handgun, Blue Handgun, Pistol". The third wears "a blue skin in RS_Main VR Pistol". The weapons
  lane is checking which of our meshes that skin fits.
- **Two flame guns:** the owner: "i have two flamethrowers".
  - The RS_Main one (RS_GH_Flamethrower, WM_Flamethrower) stays the **Flamethrower**.
  - The other, WM_Flamer, is renamed the **FlameCannon**: display name only, class and card ids unchanged. Its mesh is
    RS_ModelSwapper's AE flamer; the Force Unleashed incinerator left the game on 09-14.
- **Later:** damage numbers, against Babel on Black Metal.
