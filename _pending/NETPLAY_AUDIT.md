# RS_VR_Weapons — netplay audit, 2026-09-18

Asked for by the build lane after the owner found the carded fire path desyncs. The question: every
site where **gameplay** (ammo, damage, spawning a playsim actor, weapon state) is keyed to
`consoleplayer` or to a pose that only exists on one machine, rather than to the weapon's owner.

Twenty-three `consoleplayer` uses in this package. Nineteen are presentation and correct. The four
that matter do not use `consoleplayer` at all — they read **VR hand poses**, which is the same bug
wearing different clothes: `OffhandPos`, `AttackPos`, `HandAngle()` and their kin are written by the
local VR device and are stand-ins for every other player on every other machine.

Three of the four are mine, written today.

---

## REAL — gameplay decided from an input that exists on one machine

### 1. The ShieldSaw's guard reflects missiles from local hand poses
`zscript/rs_shieldsaw/rs_shieldsaw.zs` — `sweepDeflect()` / `guardPlane()` / `deflect()`

`RS_ShieldSaw.Tick()` runs on every machine for every player. `guardPlane()` builds the shield's face
from `HandPos()`, `HandAngle()`, `HandPitch()` (held) or `owner.OffhandPos` (forearm-stowed).
`sweepDeflect()` then sweeps for missiles and `deflect()` **writes `mo.Vel`, `mo.target`, `mo.angle`
and `mo.pitch`** — full playsim mutation, decided from a pose that is only real on the owner's
machine. Each peer turns a different set of missiles, in different directions, and the kill credit
lands on different players.

Worst of the four: it mutates other actors, so it diverges the whole playsim, not just one weapon.

**Also:** the stowed guard's position comes from `rs_ss_mount_fwd / side / frac / drop / yaw / mode`,
which are **`user`** cvars. Even with poses fixed, two players with different mount sliders would
guard different volumes. These decide a collision test and belong in `server`.

*(Written 2026-09-18, commit 939859a. The class it replaced had the same flaw — it placed a
`+SHOOTABLE` actor from the same poses — so this is not a regression, but it is not fixed either.)*

### 2. Lock-on picks targets from local hand poses
`zscript/rs_shieldsaw/rs_shieldsaw.zs` — `acquire()`

Reached from `A_ShieldSweep` in the psprite state machine, which runs on every machine. It measures
the cone from `HandPos()` / `HandAngle()` / `HandPitch()` and pushes winners into `locks`. That list
**is the thrown shield's route**, so the disc visits different enemies on different machines.

### 3. The thrown shield homes and lands on a local hand pose
`zscript/rs_shieldsaw/rs_shieldsaw_actors.zs` — `steerHome()` and the catch test in `Tick()`

`steerHome()` steers at `master.OffhandPos` every tic, and the landing test compares the missile's
position against it. A live missile's trajectory and the tic it is destroyed on both differ per
machine.

### 4. `WM_PairPickup`'s Vanilla+ branch — **verified clean, listed so nobody re-checks it**
`zscript/rs_vr_weapons/weaponset.zs`

`SetOf(toucher)` and `PlusList()` key off the **toucher**, not `consoleplayer`, and `GiveAmmoFor` /
`GunForHand` take the player passed in. The three `consoleplayer` reads in this file are the floor
look, the flight look, and a catch handler gated on `|| multiplayer` returning early. No change
needed.

---

## PRESENTATION — correct as written, listed so they are not "fixed"

| Site | What it is |
|---|---|
| `rs_vrgrenade.zs:250, 915, 949` | The netplay gates themselves: only the thrower's machine reads its own gestures, then sends `rsvg-arm` / `rsvg-throw`. **This is the pattern the ShieldSaw should copy.** |
| `rs_vrgrenade.zs:141, 146` | `Flag()` / `Num()` read `players[consoleplayer]`. Safe *because* every grenade cvar that reaches gameplay — gravity, bounce, friction, fuse, cook, blast, dud, impact, throw_min — is declared `server` and therefore identical everywhere. The `user` ones it reads (spin, flash, light, psprite, face reach) are presentation or gesture-local. Fragile by shape, correct by discipline. |
| `rs_vrgrenade.zs:1571–1604` | The config migration, and the server-cvar corrections are additionally gated on `!multiplayer`. |
| `rs_shieldsaw.zs:394`, `rs_shieldsaw_state.zs:71, 764` | Haptics and marker brightness — local effects that must be console-gated. |
| `rs_shieldsaw_state.zs:457–494` | `pollLocalGrip` — console-local edge detection that sends net events. Correct by design. |
| `rs_shieldsaw_world.zs:76, 144` | The world prop that draws the held shield. |
| `unmaker.zs:173` | Beam anchor slot; the comment already says nothing reaches the playsim. |
| `weaponset.zs:240, 344, 870` | Floor look, flight look, and a single-player-only catch handler. |

---

## The shape of the fix, for whoever takes it

The grenade already solves this and is three files away: **the machine that owns the pose decides,
and sends the decision**; every machine acts on the event. `rsvg-throw` carries the measured velocity
as three ints rather than letting each peer measure its own.

For the shield that means the anchor of a deflection, the lock list, and the home point have to be
either networked or derived from playsim state. The cheapest honest fix for 1 and 2 is the grenade's:
decide on the owner's machine, send `rs-ss-deflect` / `rs-ss-lock` with the actor and the vector. 3 is
different — a missile steering at a hand every tic cannot be evented per tic, and probably has to home
on the pawn rather than the hand.

**Not started. Not mine to start** — the build lane owns the netplay correctness of the fire path and
asked for this audit, not for fixes, and said explicitly it is working in the shared files right now.
