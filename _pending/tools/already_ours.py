#!/usr/bin/env python3
"""Does this weapon set's mesh already exist somewhere in the pack?

    python _pending/tools/already_ours.py <folder of .md3 files>

Run this BEFORE carding any new set. It answers the only question that matters first: which of
these meshes do we already own, carded, tested and in the owner's headset?

WHY IT EXISTS. Brutal Doom v21 is the quarry the Vanilla and Vanilla+ sets were cut from, and
nobody noticed until a setconfig had been written with NINETEEN guns in it, SIX of which were
already Vanilla's. Carding one of those again produces a second, worse copy of a gun the owner has
already tuned by hand -- against his standing rule that Vanilla, Vanilla+ and Breach are never
regenerated.

    39 meshes in the BD21 pack.  15 were already ours.  The set is ten guns, not twenty-six.

MATCH ON THE TOTAL VERTEX COUNT. Not on the filename, not on the bytes, not on the bounding box,
and -- this is the one that fooled me -- NOT on the sorted list of per-surface counts.

    THE BYTES CHANGE because a _wm is a re-export.
    THE BOX CHANGES because a _wm is RE-ORIGINED and often RESCALED.
    THE SURFACE LIST CHANGES because our own pipeline CARVES AND MERGES:
        RPG         13 surfaces in the source -> 10 in ours   (three merged)
        minigun      6 -> 3          AssaultShotgun  7 -> 5
        Plasma       4 -> 3          Machinegun      6 -> 7   (one carved IN)
    THE TOTAL IS CONSERVED by every one of those operations.

A carve splits a surface and a merge joins two; neither creates or destroys a vertex. So the sorted
per-surface list looks like the safer, more specific key and is in fact the one thing that cannot
survive our own tools. It missed six of the fifteen.

AND CHECK THE WHOLE PACK, NOT JUST VANILLA. Hitler's Buzzsaw -- 18972 vertices, two undifferentiated
`Cylinder` surfaces -- is the BWolf set's MG42, already carved into trigger, body, magazine and two
bolts. A search limited to the vanilla tree would have sent it back for a carve that already exists.

ONE MORE MATCHING RULE, FROM THAT SAME GUN: EXPECT THE BOUNDING BOX TO DIFFER ON THE AXIS THE PARTS
TRAVEL ALONG. The Buzzsaw's box is 140.8 x 24.7 x 26.0 and ours is 140.8 x 27.8 x 26.1 -- x and z
agree to a tenth and y does not, because our _wm is one frame at rest and the source has three. The
bolt and magazine sit differently at a different frame, which moves the box without moving a vertex.

A DIFFERENT QUESTION THIS DOES NOT ANSWER: whether a mesh SHOULD be carded at all. Fake scopes
(three 8-vertex quads for a sniper), fused akimbo guns, viewmodel hands and boots exist to work
around something flatscreen lacks. IF THE MESH EXISTS TO WORK AROUND SOMETHING VR DOES NOT HAVE, VR
DOES NOT NEED THE MESH -- we have two hands and a body with legs.
"""
import glob
import os
import struct
import sys


def mesh_info(path):
    """(total vertices, [(surface name, verts)], frames) or None if it will not read."""
    try:
        d = open(path, "rb").read()
        if d[:4] != b"IDP3":
            return None
        # MD3 header: 4 ident, 4 version, 64 name, then nine ints -- flags, frames, tags,
        # surfaces, skins, and four offsets. Frames is the second of those nine (76), surfaces
        # the fourth (84), and ofs_surfaces the eighth (100).
        nframes = struct.unpack_from("<i", d, 76)[0]
        nsurf = struct.unpack_from("<i", d, 84)[0]
        off = struct.unpack_from("<i", d, 100)[0]
        surfs = []
        for _ in range(nsurf):
            name = d[off + 4:off + 68].split(b"\0")[0].decode("latin1")
            nverts = struct.unpack_from("<i", d, off + 68 + 12)[0]
            end = struct.unpack_from("<i", d, off + 68 + 36)[0]
            surfs.append((name, nverts))
            off += end
        return sum(v for _, v in surfs), surfs, nframes
    except Exception:
        return None


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    here = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    # EVERY CARDED MESH IN THE PACK, not just the vanilla tree -- see the header.
    ours = {}
    for p in glob.glob(os.path.join(here, "models", "**", "*.md3"), recursive=True):
        i = mesh_info(p)
        if i:
            ours.setdefault(i[0], []).append(os.path.relpath(p, here))

    have, new = [], []
    for p in sorted(glob.glob(os.path.join(sys.argv[1], "**", "*.md3"), recursive=True)):
        i = mesh_info(p)
        if not i:
            continue
        total, surfs, nframes = i
        name = os.path.splitext(os.path.basename(p))[0]
        if total in ours:
            have.append((name, total, len(surfs), ours[total][0]))
        else:
            new.append((name, total, len(surfs), nframes))

    print("ALREADY OURS -- borrow the card, do NOT re-card: %d" % len(have))
    for n, t, ns, o in have:
        print("   %-20s %7d verts, %2d surf   ->  %s" % (n, t, ns, o))
    print()
    print("NOT IN THE PACK -- candidates to card: %d" % len(new))
    for n, t, ns, nf in new:
        print("   %-20s %7d verts, %2d surf, %3d frames" % (n, t, ns, nf))
    print()
    print("Judge the second list before carding it: a fake scope, a fused akimbo gun, a viewmodel")
    print("hand or a boot is a flatscreen workaround, and VR has hands and legs already.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
