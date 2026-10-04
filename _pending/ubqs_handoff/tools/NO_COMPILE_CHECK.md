# You cannot compile-check UBQS on this machine. Do not spend a run finding out.

**`E:\DOOMWork\tools\main_boottest\main_boottest.ps1` cannot load this mod, and never will.** Proved
10-02 against build 78 with an empty load order:

```
Script error, "UltraBadassQuestSaber_b78.pk3:zscript.txt" line 152:
Unknown identifier 'HmdPosition'
```

`zscript.txt:152` reads `p.mo.HmdPosition`. That member exists in **stock QuestZDoom 17.3** (it is in
`C:\Users\Command\Desktop\qzdoom-17-3-Windows-64bit\qzdoom.exe`) and **does not exist in our fork**,
`E:\DOOMWork\UZDXREMA` — nothing under `wadsrc/static/zscript/` declares it. The line is original to
the mod and predates every build in `build/`; it is not damage from a patch.

So the two engines are not substitutes in either direction, and the failure is mutual:

| | stock QZD 17.3 (what UBQS ships for) | our fork (what the boot test runs) |
| --- | --- | --- |
| `HmdPosition` | yes | **no** — load aborts at line 152 |
| `PSprite.NoDraw` | **no** — cost build 56 a load failure | yes |

The second row is the same mistake in the other direction: `NoDraw` was verified against our fork,
shipped, and failed on his headset. **The engine a check runs against must be the engine the mod runs
on**, and for UBQS no runnable copy of that engine may be launched here — the owner's standing rule is
never to launch the game, and a scratch `-config` does not prevent VR from starting.

## What CAN be proved offline, and what each thing proves

Run all three on every build. Together they catch the whole class of error that has actually bitten
this mod; none of them is a compile.

| tool | what it proves |
| --- | --- |
| `tools/check_engine_members.py <pk3>` | every `.Something` the mod touches exists in **stock** QZD. This is the one that would have caught `NoDraw`. It over-reports actor flags, vector swizzles and the mod's own fields, so **diff it against the previous build** and look only at what is new. |
| `tools/cvar_audit.py <pk3>` | no dead cvars, no menu rows pointing at nothing, and every cvar read where it can keep its promise. "Read exactly once" is the `ubqs_throw` shape — a cvar that is read, so not dead, but read somewhere useless. |
| a structural lint | braces/parens/brackets balance, and every call site of a changed signature has a legal argument count. **Strip comments BEFORE quotes** or every apostrophe in English prose (`don't`, `the blade's own line`) opens a char literal that closes on the next one and swallows the code between — which reads as a brace imbalance that is not there. |

## Say "checked", never "fixed"

None of the above is a compile and none of it is a play test. The owner has called this out directly:
*"it compiles"* and *"it works"* are not the same claim, and presenting the first as the second is
lying to him. For UBQS the honest ceiling is **"statically checked against the stock engine, not
compiled and not tested"** — his headset is the only thing on the far side of that line.
