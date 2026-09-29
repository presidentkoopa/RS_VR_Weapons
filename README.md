# RS_VR_Weapons

**Two weapon sets for DoomXR, and not one gun in them is a sprite.**

Every gun here is a real object in the world. It hangs off your controller, not off
the camera. Its magazine is a separate piece of geometry that leaves the gun when you
pull it, falls, and lands on the floor with a round count you can read. Its bolt is a
part your other hand can grab and rack. When you look down at it from the side, you
are looking at the side of it.

That is the whole idea, and everything below follows from it.

---

## Why a world weapon is a different thing from a viewmodel

A conventional Doom weapon — and a conventional VR Doom weapon — is a picture drawn
over the camera. It is flat, it faces you, and it is the same size whether your hand
is at your chest or stretched out. It has no back. You cannot look at its ejection
port because there is no ejection port; there is a frame of animation in which brass
appears.

A world weapon is an actor with geometry, and the difference is not cosmetic:

**You reload it with your hands, not with a button.** Your off hand goes to the
magazine well, takes the magazine, drops it — it falls, it bounces, it stays on the
floor — and then goes to the pouch on your chest for another. Every gun drops its own
magazine, and a dropped magazine still holding rounds glows so you can tell it from an
empty one you already threw away.

**One in the chamber is real.** Reload with a round still chambered and you keep it.
Reload dry and you have to rack the bolt. The gun knows which, because the chamber is
a place in the model rather than a number.

**Every gun articulates.** 104 parts across 37 model cards are individually driven:
slides that travel the bore, magazines that drop, triggers that turn about their pin,
forends that pump, break actions that hinge open, cylinders that swing out and index.
Each one is a named surface in the mesh with a measured axis and a measured travel,
not a frame of animation somebody drew.

**The gun is where your hand is.** Not where the camera is. You can hold a rifle low
and fire it from the hip. You can hold a pistol out sideways. You can bring your other
hand to the forend and actually be holding the forend. Two guns, one in each hand, is
just two guns — not a special "akimbo" weapon somebody had to build.

**It has weight.** 26 guns carry a real weight in pounds, empty, and it feeds the
recoil: the Pistolet is 1.89 lb, the M37 pump 5.71, the machine gun 25.00, the chaingun
35.00. The same cartridge out of a light gun and a heavy one kicks differently because
the arithmetic says so, not because somebody tuned two numbers.

**It can be thrown.** Anything the card marks as throwable measures the real velocity
and spin of your arm. An axe tumbles the way your wrist turned it — throw it underarm
and it rotates the other way.

---

## The sets

Every set is its own pk3. Load the base and then whichever others you want; each adds a
row to the New Game screen, and in netplay a server can carry all of them at once.

| Set | Guns | What it is |
|---|---|---|
| **Vanilla** | 16 | Doom's own arsenal, and nothing else. Every gun replaces the one it stands in for. |
| **Vanilla+** | 34 | Alt fires, off-hand options, and the guns Doom never had. Needs the base. |
| **BD22** | 25 | Brutal Doom v22's arsenal in worldspace. Standalone, and needs Brutal Doom loaded beside it. |

**Vanilla is a straight swap.** Doom's pickups hand you these guns in place of the
sprites, one for one, so a map that gives you a shotgun gives you the M37 and nothing
about the map has to know. Vanilla+ adds to that rather than replacing it: its guns get
generated classes and their own slots, and the vanilla set stays loadable and plays the
same underneath.

### BD22, and why it is shaped differently

**BD22 lives in `bd22/` and builds to its own pk3.** It is not an add-on to the base the
way Vanilla+ is: it carries all of its own MODELDEF, CVARINFO, MENUDEF, meshes, skins and
sound definitions, because its guns are not Doom's guns and nothing in the base describes
them. It still derives from the base for the framework — `WM_Gun`, `WM_Prop`,
`WM_SetBridge` — since a class defined in two archives is a fatal load error.

**It needs Brutal Doom loaded beside it**, and that is the point rather than a
limitation. With plain Doom its bridge swaps Doom's own pickups for these guns. With
Brutal Doom loaded the bridge notices and swaps *its* guns too, so the set becomes the
3D arsenal for Brutal Doom's own maps, monsters and balance. Its guns launch Brutal
Doom's own projectiles and play its own sounds, read out of that mod at build time
rather than reimplemented.

**Its pack carries two companions.** Brutal Doom's KEYCONF opens with
`clearplayerclasses`, which deletes our player class before the menu is built, so there
is no row to pick: `RS_VR_BD22_Players.pk3` supplies the player with our guns as start
items and `RS_VR_BD22_Slots.pk3` puts them on the number keys.

Built by WeaponForge from `sets/bd22/set.py` — see `bd22/BD22_STATE.md` for what is
measured, what is a decision, and `bd22/RULINGS.txt` for the guns whose magazines are
not in the mesh.

---

## How a gun is built

A gun is two cards and no code.

**The model card** (`WMCARD.*`) says how the object moves: which surface is the
magazine, how far the bolt travels and along which axis, where the grab points are,
which way the break action swings. It is *measured off the mesh*, frame by frame,
rather than authored — a magazine is whatever drops straight down and out, a slide is
whatever travels the bore.

**The weapon card** (`WMSHEET.*`) says what the gun *is*: damage, spread, pellets,
rate of fire, its alt-fire discipline, its weight, which effects it uses.

Nothing else is needed. A new gun is a mesh and two card entries, and where a new class
is wanted it is generated from the sheet. That is why fifty guns exist rather than five.

### A worked example: the Pistolet

This is most of one gun. Nothing else about it exists anywhere.

**`WMCARD.01_pistol` — how the object moves.** Measured off the mesh, not authored:

```
weapon "WM_Pistolet"
  hand      = off
  type      = pistol
  model     = "models/vanilla/pistols" "pistolet.md3"
  skin      = "models/vanilla/pistols" "WPN-9mm.png"
  capacity  = 15
  magfamily = "pistol"                 # either pistol's magazine seats in either gun

  muzzle    = 14.16, -0.11, 1.59       # where the flash and the shot leave
  barrel    = 1, 0, 0                  # the bore, as a direction
  ejectport = 0.5, 1.2, 2.2            # where the brass comes out, and which way
  ejectdir  = -0.3, 0.9, 0.4

  magmodel  = "models/vanilla/pistols" "wm_pistolet_mag.md3"   # the magazine as its own
  magscale  = 0.459                                            # object, for when it is in
  magcenter = -3.336, -0.109, -3.870                           # your hand or on the floor
end

# 3.889 along -x at full travel (frame 7), fit 0.011.
part slide
  role       = action
  surface    = slide
  grab       = -4.87, -0.11, 2.60      # where a hand takes it
  grabradius = 3.0
  dof
    kind     = slide
    axis     = -1, 0, 0                # straight back along the bore
    distance = 3.889
    detach   = 0.95                    # 95% of the way back, it is free
  end
end

part magazine
  role       = feed
  take       = no                      # out by its button, in by the hand carrying one
  surface    = mag
  surface    = mag.001                 # one magazine the artist split in two
  grab       = -4.6, 0.0, -9.0
  grabradius = 3.0
  dof
    kind     = slide
    axis     = -0.31, 0, -0.95         # down and slightly back, out of the well
    distance = 10.0
    detach   = 0.9
  end
end
```

**`WMSHEET.pistols` — what the gun is.** Numbers, not geometry:

```
gun "WM_Pistolet"
  roundprofile         = "pistol_9mm"       # the cartridge, shared with everything 9mm
  flashprofile         = "pistol_9mm"       # its muzzle and smoke
  ejectaprofile        = "brass_9mm_pistolet"
  recoilprofile        = "pistol_9mm"
  capacity             = 15
  firesound            = "wm/pistolet/fire"
  baseweight           = 1.89               # pounds, EMPTY -- 2.30 loaded less 15 rounds
end
```

Between them: a gun you hold in your off hand, whose slide your other hand pulls 3.889
units straight back until it frees at 95%, whose magazine drops out of the well and
lands on the floor as its own object, which fires 9mm and weighs 1.89 lb empty — and
its weight is what its recoil is computed from.

A vanilla gun needs no ZScript and no class block: it stands in for Doom's pistol and
inherits its slot. A Vanilla+ gun adds a `class` block — slot, selection order, ammo,
hand, name — and the class is generated from it.

---

## What it runs on

Load in this order. Each one needs the ones above it.

1. **[RS_Ballistics](https://github.com/presidentkoopa/RS_Ballistics)** — what a shot
   looks like. Muzzle flashes, smoke, brass, tracers, beams, flame, impacts and the
   recoil arithmetic. 1165 profiles.
2. **[RS_VR_Reload](https://github.com/presidentkoopa/RS_VR_Reload)** — the rig that
   reads the model cards and drives the parts.
3. **RS_VR_Weapons** — this. The base pack first, then any sets you want.

Vanilla+ borrows the base pack's geometry, so it needs the base pack loaded too.

---

## Credits

**Every model in this package is somebody else's work, used unaltered, and every set
ships its own CREDITS.txt inside the pk3.** Nothing is re-textured, re-rigged or
re-exported beyond the rest-pose extraction the measuring pipeline needs. No mod's
code, sprites, class names or state tables are used — only meshes, and only with the
artists' names travelling alongside them.

Where a source pack's credits list exists it is carried in full and unedited. Where
one could not be found, the set says so rather than guessing at a name.

Muzzle flash, smoke and tracer art is never taken from a source mod, even where the
mod models it in 3D. Every gun gets its own RS_Ballistics profiles instead.

---

## Building

```
.\build.ps1 -Set Base
.\build.ps1 -Set Plus
```

Each build lints the menus, lints both kinds of card, generates the gun classes and
the MODELDEF, packs to a scratch folder, compile-checks the pk3 *with everything it
depends on loaded*, and only installs on a pass. A pack with a script error never
reaches the folder you launch from.

It also refuses to ship a pack carrying a file nothing references, or a card naming a
file that is not in the archive. Both of those are silent failures otherwise: a model
bound to a missing sprite draws nothing and says nothing.
