"""PROPOSED brace points for the five Breach rifles -- a report, not a card edit (2026-09-18).

WHY: their support points came from the centroid of Breach's LEFT-HAND joints projected onto the gun's mid-plane. That
is a palm centre inside where a hand is, not a place on the gun, and it lands 4-6 units off any surface
(breach_bindpoints.py). A rotation fix layered on a position that is five units off the gun would bake the error in.

WHAT THIS PROPOSES: the nearest outer wall under the bore -- a measured surface, from the 32 rays the bind pass already
fires -- carried back into the card's own space so the owner sees a diff of card numbers rather than bind-space maths.

THE CARDS ARE NOT TOUCHED. The body lane holds this until the owner picks a direction.

    python rifle_brace_report.py        # -> points_bind/RIFLE_BRACE_PROPOSAL.md
"""
import json, os
import numpy as np
import breach_bindpoints as B

RIFLES = ["WM_BreachMK18", "WM_BreachMK18S", "WM_BreachHK416S", "WM_BreachMCX", "WM_BreachG36C"]
OUT = B.OUT + "RIFLE_BRACE_PROPOSAL.md"

if __name__ == "__main__":
    fr, guns, rows = B.frames(), {g["cls"]: g for g in B.cards()}, []
    for cls in RIFLES:
        g = guns[cls]
        j = json.load(open(B.OUT + cls + ".json"))
        sup = j["points"].get("grab:support")
        wall = (sup or {}).get("nearest_wall")
        if not wall:
            print("!! %s has no wall" % cls)
            continue
        r = B.rig(B.M + g["dir"] + "/" + g["iqm"], fr[cls.replace("WM_", "WM_Prop")])
        # back into the card's space, through the joint the brace sits on
        pal = r["pal"][r["J"][sup["joint"]]]
        proposed = (pal @ np.r_[np.array(wall["at"], float), 1.0])[:3]
        cur = np.array(sup["drawn"], float)
        nrm_drawn = pal[:3, :3] @ np.array(wall["normal"], float)
        nrm_drawn /= (np.linalg.norm(nrm_drawn) or 1.0)
        rows.append((cls, cur, proposed, float(np.linalg.norm(proposed - cur)), wall, sup["joint"], nrm_drawn))

    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# Proposed brace points for the five Breach rifles -- REPORT ONLY (2026-09-18)\n\n"
                 "Their current support points are a palm centre from Breach's left-hand joints, projected onto the "
                 "gun's mid-plane. They sit 4-6 units off any surface. Proposed below is the nearest outer wall under "
                 "the bore -- a measured place on the mesh -- carried back into the card's own space.\n\n"
                 "**Nothing here is applied.** The cards are untouched until the owner picks a direction; this is the "
                 "diff they would be looking at.\n\n"
                 "| Gun | Current `grab` | Proposed | Moves by | Off the mesh now | Surface normal there |\n"
                 "|---|---|---|---|---|---|\n")
        for cls, cur, prop, d, wall, joint, nrm in rows:
            fh.write("| %s | %s | %s | **%.2f** | %.2f | %s |\n"
                     % (cls.replace("WM_Breach", ""), ", ".join("%.3f" % x for x in cur),
                        ", ".join("%.3f" % x for x in prop), d, wall["dist"],
                        ", ".join("%.3f" % x for x in nrm)))
        fh.write("\n## What to look at\n\n"
                 "- `Moves by` is how far the brace hand would shift. It is roughly half a hand, which is what a palm "
                 "centre is.\n"
                 "- The normal is the way that surface faces, in the card's space, so the hand's turn comes from the "
                 "gun rather than from a per-type constant.\n"
                 "- The pistols, the MP5 and the Benelli are NOT in this table: their brace points came off gun "
                 "geometry and already sit within 0.3-1.5 of a surface.\n")
    print("wrote %s (%d rifle(s))" % (OUT, len(rows)))
    for cls, cur, prop, d, wall, joint, nrm in rows:
        print("  %-18s moves %.2f   off the mesh %.2f" % (cls, d, wall["dist"]))
