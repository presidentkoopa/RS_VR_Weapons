# The new families — the lead's merge plan

2026-09-13. The owner's roster order: chaingun, plasma rifle, rocket launcher, BFG, railgun,
flamethrower x2 and chainsaw x2, at least two of each where models exist. Per-family
measurements and draft cards arrive in `_pending/<FAMILY>_CARDS.md`.

**What goes live now, and what waits:**
- Live, and linted: classes without the pending properties, MODELDEF blocks, placement cvars,
  pages.
- Waiting on cards: StartItems, WeaponSlots and the "into the hand" rows. A carried gun with no
  card would be a gun the reload system can't run.
- Cards and every pending class line stay here until the reload lane confirms each step has
  landed. An unknown property is a fatal load error; an unknown card key rejects the card.
  Spec: RS_VR_Reload/FEEL_PLAN.md, section 11 (card template) and 12 (headset tests).
- No `type = ...` lines until the reload lane says the key exists.

## The approved grammar (reload lane, 2026-09-13 — NOT YET IN CODE)

**Card keys (weapon block)**
- `firesfrom = chamber | magazine | reserve | none`
  - `chamber` (default): today's rules.
  - `magazine`: no chamber; each pull takes RoundsPerShot from the magazine. A cycle verb is
    refused, so the card has no `role = action` part.
  - `reserve`: no stores; each pull takes from Weapon.AmmoType1.
  - `none`: no ammo.
- `casing = yes | none` (default yes)
- `hands = 1 | 2`. A 2 needs a `role = support` part (subject = support, grab, grabradius); the
  trigger clicks unless the other hand holds it.
- The magazine part stays `role = feed`, subject = magazine, `take = no`, a slide dof with detach.
  The swap is synthesised from it, and drop-mag and seating key on it.

**WM_Gun properties**
- `WM_Gun.RoundsPerShot N` (default 1)
- `WM_Gun.ShotClass "Actor"` (default WM_Bullet)
- `WM_Gun.ShotRail true` (A_RailAttack; damage from ShotDamage, spread from ShotSpread)
- `WM_Gun.ShotSaw true` + `WM_Gun.SawSounds "full", "hit"`
- `WM_Gun.ChargeTics N` + `WM_Gun.ChargeSound "snd"`
- virtual hooks `FireHeld(int heldTics)` and `FireReleased(int heldTics)`
  - They call the ballistics lane's static RSB_Flame API:
    - `Stream(profile, owner, hand, nozzleAt, dir, carrierVel, intensity)` every held tic
    - `StopStream(owner, hand)` on release (not `Stop`, a reserved word)
    - `Pilot(profile, nozzleAt, dir)` every idle tic
  - Profiles `incinerator` (tight, reach 520) and `napalm` (wide, sticky, reach 380).
  - Flame sounds are theirs (rsb/flame/*). Hand 9 is their menu preview.

## Slots (0-9)

| Slot | Guns |
|---|---|
| 1 | fists, chainsaws |
| 2 | pistols |
| 3 | pump shotguns, SSG |
| 4 | revolvers |
| 5 | Rifle, M16 |
| 6 | SMG, Tec9 |
| 7 | chainguns |
| 8 | rocket launchers |
| 9 | plasma rifles, railguns |
| 0 | BFGs, flamethrowers |

Hands: the first gun of a family goes in the main hand, the second in the off hand.

## Per family (the owner's sources: vanilla, except flamethrower/rifle/SMG/revolver/railgun from RS_Main)

| Family | Source | Card | Class |
|---|---|---|---|
| Chaingun | vanilla: 5x1d3 every 4 tics, ±5.6° on refire | firesfrom = magazine, capacity 100, hands = 2 | AmmoType1 Clip, FullAuto true, FireTics 4, ShotSpread 5.6, 0 |
| Machine gun (the chaingun family's off hand) | vanilla chaingun for the bullets; its underbarrel launcher fires RS_Grenade's grenades (the owner) | firesfrom = reserve, hands = 2, and a SECOND BARREL (G-UBL, _pending/MACHINEGUN_UBL.md): store gl, open breech, load grenade | AmmoType1 Clip; launcher shot WM_LauncherGrenade (chainguns.zs, live), ammo RSVG_Ammo by name |
| Plasma rifle | vanilla: PlasmaBall every 3 tics held | firesfrom = magazine, capacity 50, casing = none | AmmoType1 Cell, ShotClass "PlasmaBall", FullAuto true, FireTics 3 |
| Rocket launcher | vanilla: Rocket about every 20 tics | firesfrom = magazine, capacity 6, casing = none, hands = 2 | AmmoType1 RocketAmmo, ShotClass "Rocket", FireTics 20 |
| BFG | vanilla: 30-tic charge, BFGBall, 40 cells | firesfrom = magazine, capacity 160 (4 shots, the lead's pick), casing = none, hands = 2 | AmmoType1 Cell, RoundsPerShot 40, ShotClass "BFGBall", ChargeTics 30, ChargeSound "wm/bfg/charge" |
| Railgun | RS_Main RS_GH_Railgun, Uncommon: 464-688, dead on, 10 of 50 cells, 2 a second | firesfrom = magazine, capacity 50, casing = none | AmmoType1 Cell, ShotRail true, ShotDamage 464, 688, RoundsPerShot 10, FireTics 18 |
| Flamethrower | RS_Main RS_GH_Flamethrower, Uncommon: 11-17, Accuracy 55-65 at 0.05, 17 a second | firesfrom = magazine (both models animate a canister; `reserve` is the fallback), casing = none, capacity from the helper | AmmoType1 Cell, FullAuto true, FireTics 2, ShotDamage 11, 17, ShotSpread 1.0, 0.33, FireHeld/FireReleased hooks |
| Chainsaw | vanilla: A_Saw 2x1d10 every 4 tics | firesfrom = none, casing = none | ShotSaw true, SawSounds "wm/saw/loop", "wm/saw/hit", FullAuto true, FireTics 4, ReadySound "wm/saw/idle", UpSound "wm/saw/start" |

The build lane's plan named Doom's weapons/bfgf, sawidle and sawup. The combatfx sets are
already in SNDINFO, so the lead uses those; the build lane can say otherwise.

## Sounds (SNDINFO, in; copied from RS_Main/sounds/combatfx)

- `wm/chaingun/*`: fire, magout, magin, spinup, spin, spindown
- `wm/rocket/*`: fire, magout, magin, cycle
- `wm/plasma/*`: fire, magout, magin, charge, beep
- `wm/rail/*`: fire (the plasma rifle's rail beam), magout, magin
- `wm/bfg/*`: fire, prefire, charge, open, magout, close, magdrop
- `wm/saw/*`: cord, start, idle, loop, stop, off, zip, hit
- `wm/magdrop/large`
- Flamethrower: no flame takes in combatfx. The ballistics lane's flame profile brings loop,
  start and stop.
