# The machine gun, revised: bullets from the reserve, reload the grenade launcher

2026-09-13. The owner: "make that machinegun a 'only reloading the grenade launcher' and have
the bullets just come from reserve. Consider integrating with RS Grenade for resources ... we
can use those grenades for the over under."

This supersedes the MachineGun card in CHAINGUN_CARDS.md, where the box was the magazine.

## How it plays

1. **The machine gun fires from the Clip reserve.** Hold the trigger: 5 x 1d3 every 4 tics, the
   chaingun's. No box to swap; the ammo box is drawn as part of the gun.
2. **The underbarrel launcher is the reload.**
   - Press its latch and slide the tube forward: the breech opens, and a spent case in it is
     thrown out (as the card's brass).
   - Squeeze in the pouch for ONE grenade, taken from RS_Grenade's grenade ammo `RSVG_Ammo`, and
     let go of it at the breech. With the breech shut the pouch says to open it first.
   - Slide the tube home.
   - The open breech stops only the launcher: the machine gun keeps firing with it open.
3. **Fire the grenade on the alt-fire button** (the engine's AltFire), with the other hand on the
   gun. Its launcher trigger is drawn pulled while the button is held.
   - One pull, one grenade. During full auto it goes out between shots.
   - It flies as `WM_LauncherGrenade` (chainguns.zs, live and self-contained): a projectile that
     goes off on impact with RS_Grenade's own blast, sounds and damage (A_Explode 85/200, then
     75/255, credited to the shooter).
   - Inside 96 map units it is a dud and drops RS_Grenade's grenade pickup, so the grenade comes
     back.
   - A dry click says why: no support grip, the breech open, or nothing live in the chamber.
4. **RS_Grenade is a soft dependency, looked up by name.** Without it:
   - the round explodes with Doom's rocket sound and no effect actor;
   - a dud drops nothing;
   - the pouch says it has no grenades to hand, and hands nothing.

## The launcher, measured (machinegun_wm.md3's space, rest; the donor's frame 10)

| Part | Surface | Motion | Grab |
|---|---|---|---|
| tube | `launchertube` 3470v, 2 islands, x 5.23..39.16 | **slide 9.504 along (1, 0, 0.001)**, frames 19-35, fit 0.0088 (CHAINGUN_CARDS.md) | under its front, (30.0, -0.27, -9.75), ESTIMATE along x |
| latch | `launcherlatch` 104v | **hinge 18.93° about (0, -1, 0) through (0.801, 0, -8.229)**, sign checked (+ misses 0.0011, - 0.695) | (0.52, -0.34, -10.30), its lowest band |
| trigger | `launchertrigger` 106v | **hinge 19.99° about (0, 1, 0) through (-2.177, 0, -7.864)**, sign checked (+ misses 0.0011, - 0.943) | (-1.95, -0.34, -10.89) |
| frame | `launcher` 1014v, static, x -5.39..5.25, z -12.23..-2.67 | — | support, ESTIMATE: its underside, (0.0, -0.30, -12.2) |

**The bore and the breech**
- **Bore:** tube cross-sections at x 10, 20 and 25 centre on **y -0.266, z -7.17**, inner radius
  **2.22-2.30**, which is 1.53 map units across at 0.34.
- **Muzzle:** the tube's front face is at **x 39.156**. On the bore that is (39.16, -0.27, -7.17),
  barrel (1, 0, 0).
- **Breech:** at rest the tube's rear face is at **x 5.234**, against the frame's front face
  (x 5.25). Slid 9.504 forward it stands at **x 14.74**, which opens a 9.5-unit breech on the bore
  line.

**The loose round:** RS_Grenade's `nade.md3` (copied to models/grenades/). It is 9.3 mesh units
across, so roundscale **0.165** makes it the bore's 1.53 map units. ESTIMATE.

## The card

The second barrel is uzdxrema-11's G-UBL grammar, installed in RS_VR_Reload.pk3 09-13 15:02:30
with no names changed. **LIVE 2026-09-13** through `_pending/tools/merge_live.py machinegun`;
RS_VR_Weapons.pk3 compiled against it. Cards parse at map start, not under -norun, so in game
look for these:
- no line reading `WM ERROR refused ... "barrel launcher (WM_MachineGun)"`;
- on bind, `off hand: WM_MachineGun barrel launcher -- on altfire, fires WM_LauncherGrenade from gl`;
- gl listed as a slotted store.

```
# ======================================================== MACHINE GUN -- OFF HAND
# RS_ModelSwapper's belt-fed machine gun as machinegun_wm.md3. THE BULLETS COME FROM THE
# RESERVE; THE RELOAD IS THE UNDERBARREL GRENADE LAUNCHER. _pending/MACHINEGUN_UBL.md.
weapon "WM_MachineGun"
  type      = chaingun
  hand      = off
  prop      = "WM_PropMachineGun"
  model     = "models/chainguns/MachineGun" "machinegun_wm.md3"
  skin      = "models/chainguns/MachineGun" "Machinegun.png"

  firesfrom = reserve      # the bullets, from Weapon.AmmoType1 (Clip); gl below is the launcher's
  hands     = 2            # for both barrels

  muzzle    = 43.95, -0.24, 3.98
  barrel    = 1, 0, 0
  ejectport = -4.0, -3.7, 0.5          # ESTIMATE
  ejectdir  = -0.3, -0.9, 0.4          # ESTIMATE

  # THE LAUNCHER'S LOOSE ROUND: RS_Grenade's grenade, sized to the bore. ESTIMATE scale.
  roundmodel = "models/grenades" "nade.md3"
  roundskin  = "models/grenades" "nade.png"
  roundscale = 0.165

  # A BELT LINK WITH EVERY CASE: it is a belt-fed gun. The chaingun's link (FU's cg_ammoclip.md3)
  # on the chaingun's skin; its rounds are the chaingun's size, so the same 0.34.
  linkmodel = "models/chainguns/Chaingun" "cg_ammoclip.md3"
  linkskin  = "models/chainguns/Chaingun" "chaingun_HD.png"
  linkscale = 0.34

  firesound   = "wm/chaingun/fire"
  drysound    = "wm/dry"
  opensound   = "wm/ubl/cycle"
  closesound  = "wm/ubl/cycle"
  loadsound   = "wm/ubl/cycle"
  casingsound = "wm/casing"
end

# THE GRENADE CHAMBER: one round, the launcher's alone (its barrel's `from`). A fired round
# stays in it SPENT until the breech opens.
store gl
  kind  = slotted
  slots = 1
end

# THE TUBE slides forward to open the breech.
part launchertube
  subject = foregrip
  surface = launchertube
  grab       = 30.0, -0.27, -9.75     # ESTIMATE along x
  grabradius = 3.0
  dof
    kind     = slide
    axis     = 1, 0, 0.001
    distance = 9.504
  end
end

# THE LATCH: press it to free the tube.
part launcherlatch
  surface = launcherlatch
  grab       = 0.52, -0.34, -10.30
  grabradius = 2.0
  dof
    kind    = hinge
    axis    = 0, -1, 0
    degrees = 18.93
    pivot   = 0.801, 0, -8.229
  end
end

# THE LAUNCHER'S OWN TRIGGER: the barrel's `trigger`, drawn pulled while the alt button is
# held. No role, and no verb moves it.
part launchertrigger
  surface = launchertrigger
  dof
    kind    = hinge
    axis    = 0, 1, 0
    degrees = 19.99
    pivot   = -2.177, 0, -7.864
  end
end

part trigger
  role    = trigger
  surface = trigger
  dof
    kind     = slide
    axis     = -1, 0, -0.008
    distance = 0.598
  end
end

part support
  role    = support
  subject = support
  grab       = 0.0, -0.30, -12.2      # ESTIMATE: under the launcher's frame
  grabradius = 3.0
end

# THE BREECH. Opening it throws the spent case out of gl. It stops only the launcher (the
# barrel's needs = shut:breech), so the machine gun fires with it open.
open breech
  part    = launchertube
  latch   = launcherlatch
  latchreturn = spring    # an M203-style latch snaps back when let go; the tube stays free a second
  openat  = 0.85
  closeat = 0.05
  rest    = stay
  onopen  = ejectall
  from    = gl
end

load grenade
  into    = gl
  slot    = next
  subject = round
  at      = 5.24, -0.27, -7.17        # the tube's rear face on the bore; rides the tube
  size    = 2.0, 2.0, 2.0
  dir     = 1, 0, 0
  rides   = launchertube
  needs   = open:breech
end

# THE UNDERBARREL LAUNCHER: a second barrel on the alt-fire button, fed from gl.
barrel launcher
  input     = altfire
  trigger   = launchertrigger
  from      = gl
  shotclass = "WM_LauncherGrenade"
  ammo      = "RSVG_Ammo"             # what the pouch hands for `load grenade`, by name
  muzzle    = 39.16, -0.27, -7.17     # the tube's front face on the bore
  barrel    = 1, 0, 0
  firesound = "wm/ubl/launch"
  needs     = shut:breech
end
```

## G-UBL — what was asked, and what the reload lane made of it

| Asked | Landed as |
|---|---|
| `firesfrom = reserve` beside a slotted store | reserve still refuses stores and verbs, **except** a store a barrel's `from` names and the verbs that work only it: load into it, eject from it, an open with `onopen = ejectall` from it |
| a second barrel: trigger, input, store, ShotClass, muzzle, barrel, fire sound | the `barrel <id>` block: `input` (altfire only, one per card), `trigger`, `from` (declared, not detach, not mag / chamber, not shared), `shotclass` and `ammo` by name, `muzzle`, `barrel`, `firesound`, `firetics` (unset 19), `casing` |
| an open verb that gates only its own barrel | `needs = shut:<open verb>` on the barrel; without it an open verb still stops the whole gun |
| the pouch hands the named ammo | with the breech open and room in gl, one grenade from the barrel's `ammo`; a live grenade thrown out goes back to it when walked over or pouched |
| no casing on the shot | a fired round stays SPENT in gl; `onopen = ejectall` throws it |

## Not done, and why

- **No sound for the launch itself.** combatfx has no grenade-launcher thump; the rocket
  launcher's shot stands in (`wm/ubl/launch`).
- **The spent 40 mm case is thrown as the card's brass**, WM_Casing, which is pistol-sized. There
  is no key for a second casing per store; `casing = none` on the barrel would throw nothing.
- **The grenade leaves from the firing hand**, like every WM_Gun shot; the barrel's muzzle and
  barrel place the flash and sparks only.
- **The launcher's round in the chamber** could show through `roundsurface` if the mesh had one.
  It does not, so nothing is drawn in the breech.
- **RS_Grenade is not edited.** Its lane closed on 2026-09-04 (HANDOFF.md). The integration reads
  it by name only.
