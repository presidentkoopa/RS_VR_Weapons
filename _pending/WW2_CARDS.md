# WW2 — the card plan

The owner, 2026-09-18: *"I WANT A WORLD WAR 2 WEAPON SET CALIBRATED AGAINST BRUTAL WOLF 5.0 DAMAGE AND
ROF VALUES. BALLISTIC DATA I LEAVE TO YOUR CREATIVITY."* The set is called **WW2**. It is a set in the
sense Vanilla, Vanilla+ and Modern already are — an add-on pack with its own player class and its own
Weapon Cards, stacking on the Vanilla base.

---

## 1. THE BLOCKER, AND IT IS THE WHOLE JOB

**All ten WW2 meshes are a single welded surface each.** Measured, not assumed:

| mesh | frames | surfaces |
|---|---|---|
| 1911, luger | 61 | **1** |
| mp40 | 48 | **1** |
| m1a1 (Thompson) | 53 | **1** |
| kar98k | 44 | **1** |
| stg44 | 51 | **1** |
| garand | 37 | **1** |
| mg42 | 98 | **1** |
| m12 (trench gun) | 48 | **1** |
| flammenwerfer | 15 | **1** |

A Model Card names *surfaces* so a hand can grab a slide or a magazine. With one surface there is
nothing to name: **not one of these can be carded as it stands.** Their animation is baked into frames
of the whole gun, exactly like `nade.md3` was before `grenade_wm.md3` was cut out of it.

So the real cost of WW2 is **ten mesh splits**, not ten cards. The cards are an afternoon once the
meshes are split; the splitting is the project. Our existing guns went through exactly this
(`_pending/CHAINGUN_CARDS.md`, `BFG_CARDS.md`) — split by triangle connectivity into islands, then each
part's motion measured by Kabsch fit against frame 0 with the body's own motion removed.

**The splitter is gone.** It lived at a scratch path (`SP\wm_split.py`) that no longer exists.
`E:\DOOMWork\tools\md3.py` still has the *measuring* half — `part_motion`, `rigid_fit`, `best_travel`,
`usable_frames` — and `md3_write.py` can write meshes back out. What is missing is island detection:
connected components over the triangle graph. That is a day's work and it is the first thing to build.

Recommendation: **rebuild the splitter first, prove it on the 1911** (61 frames, a slide and a magazine,
and we already have a carded 1911-pattern pistol in `WMCARD.01_pistol` to check the answer against), then
run the other nine.

---

## 2. THE NUMBERS — source recorded per weapon

Taken from **Brutal Wolfenstein `ZMC-BWV7.0.pk3`** at the owner's direction (they said 5.0; 7.0 is what
is on this machine, and they said "they're up to 8.x now so I'm sure it'll be fine"). Damage is
`A_FireBullets`' damage argument; cadence is the tic sum of the fire cycle to `A_ReFire`.

**Numbers only.** No code, no sprites, no sounds, no class names, no state tables — those stay theirs.
Our names are the historical ones, which is what the set wants anyway.

| Our gun | Archetype | dmg | spread hip / aimed | cycle | ~shots/sec | source lump |
|---|---|---|---|---|---|---|
| Colt M1911 | pistol | 30 | 2,2 / 0,0 | 4 | 8.8 | `actors/weaps/1911.txt` |
| Luger P08 | pistol | 25 | 2,2 / 0,0 | 3 | 11.7 | `LUGER.txt` |
| Walther P38 | pistol | 25 | 2,2 / 0,0 | 3 | 11.7 | `P38.txt` |
| MP40 | smg | 25 | 5,3 / 1,1 | 3 | 11.7 | `MP40.txt` |
| PPSh-41 | smg | 20 | 5,4 / 2,2 | 3 | 11.7 | `PPSH41.txt` |
| StG 44 | rifle | 40 | 2,1 / 1,0 | 3 | 11.7 | `STG44.txt` |
| Kar98k | **bolt action (new)** | 80 | 0,0 | 10 | 3.5 | `KAR98.txt` |
| M1 Garand | **en-bloc (new)** | 60 | 4,5 / 1,1 | 7 | 5.0 | `M1GARAND.txt` |
| G43 | rifle | 60 | 2,1 / 1,0 | 3 | 11.7 | `G43.txt` |
| MG42 | belt MG | 40 | 5,4 | 16 | 2.2 | `CHAINGUN.txt` |
| FG42 | rifle | 40 | 4,2 / 2,1 | 2 | 17.5 | `FG42.txt` |
| BAR | rifle | 65 | 2,3 / 1,1 | 7 | 5.0 | `BAR.txt` |

FG42, BAR, PPSh-41 and the P38 have **no mesh** in the addon — numbers recorded for when one appears.
The Thompson and the trench gun **have meshes but no BW entry**; theirs will have to be reasoned from
their neighbours (Thompson ≈ MP40 at .45, trench gun from our own pump cards).

---

## 3. ARCHETYPES — two genuinely new, one open

**Covered by what we have:** pistols (`01_pistol`: slide + magazine), SMGs (`07_smg`), the selective-fire
rifles (`05_rifle`), the trench gun (`02_pump`), the Flammenwerfer (`13_flamethrower`).

### Bolt action — NEW, and the interesting one
`02_pump` is a **linear slide**: one part, one axis, one distance. A bolt is four motions in sequence on
two axes — **lift** (hinge, ~90° about the bore), **pull** (slide back), **push** (slide forward), **turn
down** (hinge back) — and the gun is only ready when all four have happened in order. Our `dof` / `dof2`
pair can express two motions on one part, but not an ordered four-stroke where the second is refused
until the first completes. That ordering is the archetype, and it is why a bolt cannot be a pump with a
longer throw.

Cheapest honest first cut: **two parts** — `bolthandle` (hinge) and `boltbody` (slide) — with the slide
gated on the hinge being open. That needs a `needs` condition between parts, which the verb layer already
has the vocabulary for.

### En-bloc clip — NEW
The Garand has **no detachable magazine**. A clip of eight is pressed down into a fixed internal well and
the empty clip is ejected on the last round. `role = feed` assumes a magazine that leaves as an object.
This is a feed that *arrives* as an object and leaves as a different one.

### Belt-fed MG — open
`09_chaingun` is the nearest but it is a spin-up rotary. The MG42 is a belt over a fixed barrel with a
side-hinged top cover. Might be `09_chaingun` minus the spin, might want its own. **Decide after the mesh
is split** — 98 frames says the animation has a lot in it, and what is actually separable will settle it.

---

## 4. BALLISTICS — mine, and by calibre rather than by gun

Six calibres cover all twelve, so these are six recipes and not twelve. Round, flash, ejecta and recoil
profiles go to RS_Ballistics as recipes; nothing per-gun is written into the guns.

| Calibre | Guns | Character |
|---|---|---|
| 9×19 Parabellum | Luger, P38, MP40 | small flash, light brass, snappy low recoil |
| .45 ACP | M1911, Thompson | fat slow round, heavy brass, a shove rather than a snap |
| 7.62×25 Tokarev | PPSh-41 | thin bright flash, very light kick, high rate |
| 7.92×33 Kurz | StG 44 | intermediate — between the SMGs and the rifles on every axis |
| 7.92×57 Mauser | Kar98k, MG42 | big flash, long brass, heavy recoil; the Kar98k's is the hardest kick in the set |
| .30-06 | Garand, BAR, FG42 | as heavy, with the Garand's **en-bloc ping** as its own sound event |

The Kar98k at 80 damage and 3.5/sec is the set's shape in one gun: it should hit like nothing else we
have and make you pay for it in cycle time. That is worth protecting through tuning.

---

## 5. ORDER OF WORK

1. Rebuild the mesh splitter (island detection over the triangle graph). Prove on the 1911.
2. Split the ten. Measure each part with `md3.py`'s existing fit machinery.
3. Model Cards, through `card_lint`.
4. Weapon Cards with the table above; classes via `make_gun_classes`, no hand-written cards.
5. The bolt-action and en-bloc archetypes, with the reload lane.
6. Ballistics recipes with that lane.
7. `WW2` as an add-on pack — its own player class and `AddPlayerClasses`, stacking on the Vanilla base
   exactly as Vanilla+ and Modern do.

**Not started.** Design only, per the lane's "design before code", and the engine is on hold for checks.
