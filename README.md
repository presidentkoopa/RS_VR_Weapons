# RS_VR_Weapons

**Ten weapon sets for DoomXR, and not one of them is a sprite.**

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

**Every gun articulates.** 376 surfaces across the package are individually driven:
slides that travel the bore, magazines that drop, triggers that turn about their pin,
forends that pump, break actions that open, cylinders that index. A Kar98's stripper
clip is five separate rounds that leave one at a time. A Garand's en-bloc clip pings
out on the last shot, because that is what a Garand does.

**The gun is where your hand is.** Not where the camera is. You can hold a rifle low
and fire it from the hip. You can hold a pistol out sideways. You can bring your other
hand to the forend and actually be holding the forend. Two guns, one in each hand, is
just two guns — not a special "akimbo" weapon somebody had to build.

**It has weight.** 75 guns carry a real published weight in pounds, empty, and it
feeds the recoil: a Luger is 1.70 lb, a PPSh 10.30, an M56 Smartgun 39.00. The same
cartridge out of a 9 lb rifle and a 25 lb machine gun kicks differently because the
arithmetic says so, not because somebody tuned two numbers.

**It can be thrown.** Anything the card marks as throwable measures the real velocity
and spin of your arm. An axe tumbles the way your wrist turned it — throw it underarm
and it rotates the other way.

---

## The ten sets

Every set is its own pk3. Load the base and then as many as you like; each adds a row
to the New Game screen, and in netplay a server can carry all of them at once.

| Set | Guns | What it is |
|---|---|---|
| **Vanilla** | 16 | Doom's own arsenal, and nothing else. |
| **Vanilla+** | 34 | Alt fires, off-hand options, and the guns Doom never had. |
| **BWolf** | 33 | Brutal Wolfenstein's arsenal, on its own numbers — plus a left-hand twin of every gun. |
| **WW2** | 17 | Our own take on the period. Plays with BWolf's in the off hand. |
| **Aliens** | 8 | Colonial Marines. Pulse Rifle, Smartgun, incinerator, Power Loader. |
| **Cola 3** | 8 | KS-23, Jackhammer, particle accelerator, frying pan. |
| **HacX** | 9 | The 1997 total conversion's cyberpunk arsenal. |
| **Robocop** | 8 | Murphy's Auto 9, the Cobra, ED-209's chaingun. |
| **Blood** | 12 | Caleb's. Flare gun, sawn-off, Tesla cannon, voodoo doll, dynamite. |
| **Bloom** | 10 | The Doom/Blood crossover — Blood's meshes on Bloom's own numbers. |

**They detect the mod they came from.** Load Brutal Wolfenstein and the BWolf set
replaces its guns one for one. Load ZBloody Hell and the Blood set does the same. Load
neither and Doom's own pickups hand you the set instead, mapped by role — a map that
gives you a chaingun gives you a Tommy gun.

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

Nothing else is needed. A new gun is a mesh and two card entries, and the ZScript
class is generated. That is why ten sets and 150 guns exist rather than ten.

---

## What it runs on

Load in this order. Each one needs the ones above it.

1. **[RS_Ballistics](https://github.com/presidentkoopa/RS_Ballistics)** — what a shot
   looks like. Muzzle flashes, smoke, brass, tracers, beams, flame, impacts and the
   recoil arithmetic. 1165 profiles.
2. **[RS_VR_Reload](https://github.com/presidentkoopa/RS_VR_Reload)** — the rig that
   reads the model cards and drives the parts.
3. **RS_VR_Weapons** — this. The base pack first, then any sets you want.

Sets that borrow another pack's geometry need that pack too: Vanilla+ needs the base,
Bloom needs Blood.

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
.\build.ps1 -Set Plus      # or BWolf, WW2, Aliens, Cola, HacX, Robocop, Blood, Bloom
```

Each build lints the menus, lints both kinds of card, generates the gun classes and
the MODELDEF, packs to a scratch folder, compile-checks the pk3 *with everything it
depends on loaded*, and only installs on a pass. A pack with a script error never
reaches the folder you launch from.

It also refuses to ship a pack carrying a file nothing references, or a card naming a
file that is not in the archive. Both of those are silent failures otherwise: a model
bound to a missing sprite draws nothing and says nothing.
