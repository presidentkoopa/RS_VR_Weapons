# WW2 — mesh scan, stats and archetypes

The owner, 2026-09-18: a World War 2 weapon set called **WW2**, calibrated against Brutal Wolfenstein's
damage and rate of fire, ballistics mine.

Source, all in one place: `E:\DOOMWork\VR_WeaponSetRebuild\WeaponSets\BrutalWolf` — `Models\` for the
meshes, `Actors\Weaps\*.txt` for the numbers.

**Cards themselves are the reload lane's** (card.zs, parser.zs, card_lint, the generator). This document
is the three things that feed them: the scan, the stats and the archetype assignment.

> **Correction to the first version of this file.** It said all ten WW2 meshes were a single welded
> surface and none could be carded. That was measured against `RS_ModelSwapper\.gen\ww2\`, which is a
> different and much poorer export, and it was reached from surface counts without splitting islands —
> the exact mistake that once hid the M16's charging handle. The real source below is nothing like it.

---

## 1. THE SCAN

`E:\DOOMWork\tools\card_skeleton.py` does this already — island splitting, rigid fits, grab points, hand
seats, renders and a draft card in WMCARD grammar. Islands below are its `islands()` at frame 0.

| Gun | frames | surfaces | islands (per surface) | body / action / magazine |
|---|---|---|---|---|
| **STG44** | 10 | **23** | 31, then 21 singletons, 2 | Named in full: `Low_STG_Low` body, `Low_Zatvor_Low` **bolt**, `Low_Magazin_Low` **magazine**, plus hammer, safety, barrel, stock, gas piston. Richest mesh in the set. |
| **Tommy** | 11 | 4 | Base 20, Bolt 3, Trigga 1, Magazine 12 | Textbook — body / action / magazine already named. |
| **Garand** | 14 | 5 | Bullet_pack 9, Gun 37, 1, 1, 1 | `Bullet_pack` **is the en-bloc clip, already its own surface.** |
| **Shotgun** (TrenchGun) | 29 | 7 | Runko 42, pump 3, eject 1, trigger ×2, Cube 3, Cylinder 2 | `pump` and `eject` named. |
| **MG42** | 15 | 5 | 1, **127**, 23, 3, 5 | The 127-island surface is the belt — a link per island. |
| **MP40** | 10 | 7 | 44, 2, 6, 1, 1, 1, 1 | Seven surfaces, names generic; islands to be fitted. |
| **PP41** | 10 | 7 | 30, 6, 2, 2, 1, 1, 1 | `Circle` (6 islands) is very likely the drum. |
| **BAR** | 10 | 6 | 34, 1, 1, 1, 1, 1 | |
| **Kar98** | 26 | 11 | 35, 4, 2, 2, 2, 2, 2, 1, 1 | Eleven surfaces, all named `SMDImporter_Mesh_…`. Parts are there; identifying which is the bolt needs the fit, not the name. |
| **Luger** | 13 | 6 | 10, 2, 1, 1, 1, 1 | |
| **1911** | 10 | 5 | 15, 4, 1, 1, 1 | |
| **Flame** | 10 | 1 | 5 | One surface, five islands — the only one that may not make three parts. |

**Three-surface minimum: met by eleven of twelve.** The Flammenwerfer is the single open question, and a
flamethrower arguably has no action and no magazine anyway — it has a tank and a valve. That is a design
question, not something to work around.

---

## 2. THE STATS

From `Actors\Weaps\*.txt`. Damage is `A_FireBullets`' damage argument. Cadence is tics from the firing
line to `A_ReFire` / `Goto Ready` — shot to ready.

**Numbers only.** No code, sprites, sounds, class names or state tables. Our names are the historical
ones.

| Our gun | dmg | shot→ready | ~shots/sec | source lump |
|---|---|---|---|---|
| Colt M1911 | 15–18 | 3 | 11.7 | `1911.txt` |
| Luger P08 | 12 | 3 | 11.7 | `LUGER.txt` |
| MP40 | 12 | 2 | 17.5 | `MP40.txt` |
| Thompson | 15 | 3 | 11.7 | `THOMP.txt` |
| PPSh-41 | 15 | 2 | 17.5 | `PPSH41.txt` |
| StG 44 | 20 | 2 | 17.5 | `STG44.txt` |
| Kar98k | 40 | 9 | 3.9 | `KAR98.txt` |
| M1 Garand | 30 | 8 | 4.4 | `M1GARAND.txt` |
| BAR | 30–40 | 7 | 5.0 | `BAR.txt` |
| MG42 | 37 | 3 | 11.7 | `mg42.txt` |
| Chaingun | 28 | 4 | 8.8 | `CHAINGUN.txt` |
| Trench gun | 12 (per pellet) | 7 | 5.0 | `TRENCHGUN.txt` |

`LUGERX2`, `MP40AMBO`, `STG44AMBO` are akimbo variants — noted, not planned.

---

## 3. ARCHETYPES — nine covered, three genuinely new

**Covered by what we already have:**

| Gun | Archetype |
|---|---|
| 1911, Luger | `01_pistol` — slide + detachable magazine |
| MP40, Thompson, PPSh-41 | `07_smg` |
| StG 44 | `05_rifle` — select fire, detachable magazine |
| BAR | `05_rifle` — a magazine MG is a heavy rifle mechanically |
| Trench gun | `02_pump` |
| Flammenwerfer | `13_flamethrower` |

### NEW — bolt action (Kar98k)
`02_pump` is a **linear slide**: one part, one axis, one distance. A bolt is four motions on two axes in
a fixed order — **lift** (hinge about the bore), **pull** (slide back), **push** (forward), **turn down**
(hinge) — and the rifle is only ready when all four have happened *in sequence*. `dof`/`dof2` can carry
two motions on one part; neither can refuse the second until the first completes. **That ordering is the
archetype.** First cut: two parts, `bolthandle` (hinge) and `boltbody` (slide), the slide gated on the
hinge being open — which needs a `needs` condition between parts, and the verb layer already has that
vocabulary.

### NEW — en-bloc clip (M1 Garand)
No detachable magazine. A clip of eight is pressed into a fixed internal well and **the empty clip ejects
itself on the last round**. `role = feed` assumes a magazine that leaves as an object when you pull it.
This is a feed that *arrives* as an object and leaves on its own, on a condition. The mesh already has it
as `Bullet_pack`, so the model side is free — it is the verb that is new.

### NEW or adapted — belt feed (MG42)
`09_chaingun` is the nearest and it is a spin-up rotary; the MG42 is a belt over a fixed barrel under a
side-hinged top cover. The 127-island surface is the belt, one link per island, which is exactly what a
consuming belt wants. Recommend deciding **after** the top cover and belt are fitted — what is separable
will settle whether this is chaingun-minus-spin or its own thing.

---

## 4. BALLISTICS — six recipes, not twelve guns

By calibre, as recipes in RS_Ballistics, with that lane. Nothing per-gun written into the guns.

| Calibre | Guns | Character |
|---|---|---|
| 9×19 | Luger, MP40 | small flash, light brass, snappy |
| .45 ACP | 1911, Thompson | fat slow round, heavy brass, a shove not a snap |
| 7.62×25 | PPSh-41 | thin bright flash, light kick, highest rate in the set |
| 7.92×33 Kurz | StG 44 | intermediate on every axis |
| 7.92×57 | Kar98k, MG42 | big flash, long brass, hardest kick we have |
| .30-06 | Garand, BAR | heavy, and the Garand's **en-bloc ping** as its own sound event |

The Kar98k is the set's shape in one gun — 40 damage at 3.9/s against the MP40's 12 at 17.5. Protect that
spread through tuning.

---

**Status:** scan, stats and archetypes done. Cards are the reload lane's from here.
