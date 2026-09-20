# One pistol slide oval, true for every pistol

**The owner, 2026-09-20:** *"i'll be fucked if i'm going to adjust things like slide ovals and
magazine ovals for each fucking gun. i want a way to make blanket pistol adjustments, blanket
shotgun adjustments, etc. when i declare one pistol slide oval that oval is true for all pistols
unless i want to override per gun."*

For the reload lane. The rig reads `grabsize` and `grabradius`; this asks it to read one more kind
of block, and it makes 191 lines of copied number disappear.

---

## The package already agrees with him, it just says so 191 times

Audited across every `WMCARD.*` in the package — 231 parts on 155 guns:

| what a part states | parts |
|---|---|
| `grabradius = 3.0`, that exact number | **191** |
| `grabradius` = anything else (2.0, 2.5) | 4 |
| a real `grabsize` oval of its own | 12 |
| **nothing at all** | **24** |

**Nobody ever chose 3.0 per gun.** It is a house default that was typed out once per part, and the
four exceptions are the only places anyone made a decision. Every `trigger` part in the package —
forty of them, across every type — states nothing at all.

So the thing being asked for is not a new concept. It is the concept that is already there, made
sayable once instead of 191 times.

## The shape

A block keyed by the card's `type` and the part's `role`, both of which already exist:

```
grabdefaults pistol
  action   = 3.2, 1.2, 0.9      # the slide oval on every pistol
  feed     = 1.9, 0.8, 0.6      # the magazine oval
  trigger  = 1.0, 0.8, 0.8
  support  = 3.0
end
```

Three numbers is an oval (along, across, up) as `grabsize` already is; one number is a radius as
`grabradius` already is. **A part that states its own wins**, which is the override half of the
request and needs no new syntax at all — it is what every card already does.

The resolution order, and it must be this way round:

    the part's own grabsize/grabradius  ->  grabdefaults <type>.<role>  ->  the house default

## Why this is the rig's and not a generator's

A generator could paste the numbers into 191 cards, and that would be wrong twice over. The cards
are MEASURED files — a pasted tuning value sitting next to a measured pivot is the exact confusion
this package keeps paying for — and the owner wants to **turn a knob**, not to re-run a tool and
rebuild ten packs to see whether a pistol slide feels better.

## What it touches

- `RS_VR_Reload/zscript/wm/parser.zs` — a third block kind beside `weapon` and `archetype`.
  The `archetype` refusals are the precedent for the error text: *"an archetype holds verb blocks
  only"* becomes *"grabdefaults holds one line per role"*.
- `RS_VR_Reload/zscript/wm/card.zs` — where the resolved value is read, so the fallback happens in
  one place rather than at each call site.
- `RS_VR_Weapons/WMCARD.txt` — the blocks themselves. Mine, and the audit above says what the
  numbers should start at.
- `RS_VR_Weapons/_pending/card_lint.py` — the key, so a typo cannot ship. Mine.

## The part that makes it worth doing twice over

**Back the defaults with cvars and he tunes them in the headset instead of in a file.** The
placement sliders shipped yesterday and are exactly this shape: ten cvars a gun, a generated page,
and the renderer reads them so they move live.

`wm_grab_pistol_action_x/y/z` is one page of sliders that moves **every pistol's slide grab at
once** — which is the sentence he actually wrote. Grab shapes are read by the playsim rather than
the renderer, so they will not move *while* the menu is open the way placement does; he drags,
closes, grabs. That is the honest limit and it should be said on the page rather than discovered.

Roughly 20 type/role pairs carry real weight, so this is ~60 cvars generated the same way
`make_cvarinfo.py` already generates 1,246.

## What I have ready

The audit above, per type and per role, with the distinct values each one currently holds — so the
starting numbers come off what is already in the package rather than out of the air. Say the word
and the `WMCARD.txt` blocks, the lint key and the slider page follow the moment the parser reads
them.

**Nothing in this is urgent enough to interrupt a build.** But 191 copies of one number is the
cheapest large cleanup left in the package, and the owner has now asked for it directly.
