#!/usr/bin/env python3
"""Generate the lightsaber BLADE -- a mesh and its textures. The hilt is somebody else's model; the
blade is ours, because in Jedi Academy the blade was never a model at all.

    python _pending/tools/gen_saber_blade.py [--color blue|green|red|purple|yellow]

Writes models/starwars/lightsaber/blade.md3 and blade_core.png / blade_mid.png / blade_glow.png.

WHY A MODEL, WHEN THE BRIEF SAID THE BLADE WAS BALLISTICS'. The question to ballistics was whether
the trail path could draw a beam that stays lit and follows the hand every frame. The shieldsaw had
already answered it: its glow is an ADDITIVE MESH on a prop that follows the hand through MODELDEF's
FollowMainHand -- placed by the RENDERER, at draw rate, so it cannot lag the hand the way anything
moved by the playsim does. A blade is exactly that shape. So the blade BODY is a mesh here, and what
goes ON it -- the swing smear, the clash, the sparks where it touches a wall -- stays ballistics'.

THREE NESTED SHELLS, ALL ADDITIVE, AND THAT IS THE WHOLE LOOK. A white core, a bright coloured shell
round it, a dim coloured halo round that. Looking through the middle of the blade you cross all
three and add them to white-hot; at the edge you only cross the halo. So the blade falls off from a
hot centre to a soft coloured edge with no shader at all -- just geometry and addition.

NINE FRAMES, RETRACTED TO FULL. Frame 0 is the blade folded into the emitter; frame 8 is its whole
length. The weapon's ignite and retract states step through them and the world prop copies the
frame across, the same way the shieldsaw's state machine drives its blade spin. So ignition EXTENDS
out of the emitter and retracts back into it, instead of popping.

SIZED OFF OUR OWN GUNS, NOT GUESSED. A ~20 cm pistol draws ~35 units here, so a 28 cm hilt is
Scale ~3.1 on the 15.9-unit mesh, and a three-foot blade is ~51 units in the mesh's own space.
"""
import math
import os
import struct
import sys

HERE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(HERE, "models", "starwars", "lightsaber")

# THE HILT, MEASURED (saber_w.md3): long on Z, -12.31 .. +3.61, centred on the axis. The emitter is
# the +Z end -- JK's sabers throw the blade along +Z from the top of the hilt.
EMITTER_Z = 3.61
BLADE_LEN = 51.0          # mesh units; x Scale 3.1 = ~158 drawn = a three-foot blade
SIDES = 16
FRAMES = 9                # 0 retracted .. 8 full
RINGS = 6                 # along the length, so the blade can taper and round its tip

# (surface name, radius, texture) -- inner to outer
SHELLS = [("core", 0.30, "blade_core.png"),
          ("mid",  0.58, "blade_mid.png"),
          ("glow", 1.00, "blade_glow.png")]

# EVERY COLOUR AT ONCE, because the owner wants to pick (2026-09-21: "im going to want to customize
# colors and have two of these"). The ORDER IS THE CVAR'S VALUE -- rs_saber_color 0 is blue -- and
# the weapon code, the MODELDEF and the menu all read it off this one list, so it cannot drift.
COLORS = [
    ("blue",   (110, 165, 255)),
    ("green",  (90, 255, 110)),
    ("red",    (255, 55, 45)),
    ("purple", (190, 90, 255)),
    ("yellow", (255, 225, 80)),
    ("orange", (255, 140, 40)),
    ("cyan",   (80, 245, 255)),
    ("white",  (235, 240, 255)),
]


def encode_normal(n):
    """MD3's packed lat/lng normal."""
    x, y, z = n
    if abs(x) < 1e-6 and abs(y) < 1e-6:
        return (0 << 8) | 0 if z > 0 else (0 << 8) | 128
    lng = int(math.atan2(y, x) * 255 / (2 * math.pi)) & 0xFF
    lat = int(math.acos(max(-1.0, min(1.0, z))) * 255 / (2 * math.pi)) & 0xFF
    return (lat << 8) | lng


def shell_frames(radius):
    """One shell: vertices for every frame, plus its triangles and uv. Tapers slightly to a
    rounded tip so the end of the blade is not a flat-cut tube."""
    verts_per_frame = []
    for f in range(FRAMES):
        t = f / float(FRAMES - 1)
        length = BLADE_LEN * t
        vs = []
        for r in range(RINGS):
            s = r / float(RINGS - 1)
            z = EMITTER_Z + length * s
            # full radius along the blade, rounding in over the last ring to a soft tip
            rad = radius * (1.0 if s < 0.8 else max(0.15, math.cos((s - 0.8) / 0.2 * math.pi / 2)))
            for k in range(SIDES):
                a = 2 * math.pi * k / SIDES
                vs.append(((math.cos(a) * rad, math.sin(a) * rad, z),
                           (math.cos(a), math.sin(a), 0.0)))
        # the tip apex
        vs.append(((0.0, 0.0, EMITTER_Z + length + radius * 0.4), (0.0, 0.0, 1.0)))
        verts_per_frame.append(vs)
    tris = []
    for r in range(RINGS - 1):
        for k in range(SIDES):
            a = r * SIDES + k
            b = r * SIDES + (k + 1) % SIDES
            c = (r + 1) * SIDES + k
            d = (r + 1) * SIDES + (k + 1) % SIDES
            tris += [(a, c, b), (b, c, d)]
    apex = RINGS * SIDES
    top = (RINGS - 1) * SIDES
    for k in range(SIDES):
        tris.append((top + k, apex, top + (k + 1) % SIDES))
    uv = []
    for r in range(RINGS):
        for k in range(SIDES):
            uv.append((k / float(SIDES), r / float(RINGS - 1)))
    uv.append((0.5, 1.0))
    return verts_per_frame, tris, uv


def pack_surface(name, shader, vpf, tris, uv):
    nv = len(vpf[0])
    hdr = 108
    o_sh = hdr
    o_tri = o_sh + 68
    o_st = o_tri + len(tris) * 12
    o_xyz = o_st + nv * 8
    o_end = o_xyz + nv * FRAMES * 8
    b = bytearray()
    b += b"IDP3" + name.encode().ljust(64, b"\0")
    b += struct.pack("<iiiiiiiiii", 0, FRAMES, 1, nv, len(tris), o_tri, o_sh, o_st, o_xyz, o_end)
    b += shader.encode().ljust(64, b"\0") + struct.pack("<i", 0)
    for t in tris:
        b += struct.pack("<iii", *t)
    for u, v in uv:
        b += struct.pack("<ff", u, v)
    for vs in vpf:
        for (x, y, z), n in vs:
            b += struct.pack("<hhhH", int(round(x * 64)), int(round(y * 64)), int(round(z * 64)),
                             encode_normal(n))
    assert len(b) == o_end
    return bytes(b)


def write_md3(path):
    surfaces = []
    for name, radius, tex in SHELLS:
        vpf, tris, uv = shell_frames(radius)
        surfaces.append(pack_surface(name, tex, vpf, tris, uv))
    frames = bytearray()
    for f in range(FRAMES):
        t = f / float(FRAMES - 1)
        top = EMITTER_Z + BLADE_LEN * t + 1.0
        r = SHELLS[-1][1]
        frames += struct.pack("<3f3f3ff", -r, -r, EMITTER_Z, r, r, top, 0, 0, 0,
                              max(top, 1.0))
        frames += ("blade%d" % f).encode().ljust(16, b"\0")
    o_frames = 108
    o_surf = o_frames + len(frames)
    body = b"".join(surfaces)
    o_end = o_surf + len(body)
    hdr = b"IDP3" + struct.pack("<i", 15) + b"saber_blade".ljust(64, b"\0")
    hdr += struct.pack("<iiiiiiiii", 0, FRAMES, 0, len(surfaces), 0, o_frames, o_surf, o_surf, o_end)
    data = hdr + bytes(frames) + body
    assert len(data) == o_end
    open(path, "wb").write(data)


def write_textures():
    """The core is white-hot and shared by every colour; mid and glow are one pair per colour."""
    from PIL import Image
    Image.new("RGB", (8, 8), (255, 255, 255)).save(os.path.join(OUT, "blade_core.png"))
    for name, (r, g, b) in COLORS:
        # MID: the colour, bright. GLOW: the colour, dim -- the soft edge of the halo.
        Image.new("RGB", (8, 8), (r, g, b)).save(os.path.join(OUT, "blade_mid_%s.png" % name))
        Image.new("RGB", (8, 8), (r // 4, g // 4, b // 4)).save(os.path.join(OUT, "blade_glow_%s.png" % name))


def write_modeldef():
    """One blade prop class per colour and hand, each the same mesh in its own skins. GENERATED --
    the colour list above is the only place a colour is named."""
    o = ["// " + "=" * 74,
         "// THE LIGHTSABER BLADES -- one prop class per colour and hand.",
         "//",
         "// GENERATED by _pending/tools/gen_saber_blade.py. DO NOT EDIT -- change COLORS there.",
         "//",
         "// ONE MESH, EVERY COLOUR. blade.md3 is three nested shells (core / mid / glow) and a colour",
         "// is nothing but which skins those shells wear, so each colour is a class that differs only",
         "// in its SurfaceSkin lines. The world handler spawns the one rs_saber_color names, and a",
         "// change to that cvar swaps it live.",
         "//",
         "// FRAMES 0-8 ARE IGNITION. SBLD A is the blade folded into the emitter and SBLD I its whole",
         "// length; the weapon's state steps through them and the handler copies the frame across.",
         "//",
         "// THE HILT AND THE BLADE SHARE ONE SET OF PLACEMENT SLIDERS (rs_saber / rs_saber_off), so",
         "// they turn together and the blade always leaves the emitter.",
         "//",
         "// PitchOffset 90 TURNS THE HILT'S OWN AXIS ONTO THE CONTROLLER'S. The mesh is long on Z --",
         "// hilt below, blade up -- and a held saber points where the controller points. That sign",
         "// was decided OUTSIDE a headset, which is exactly what has been wrong all week: if the blade",
         "// points back at you, the Pitch slider on the saber's placement page fixes it LIVE.",
         "// " + "=" * 74, ""]
    for hand, follow in (("", "FollowMainHand"), ("Off", "FollowOffHand")):
        # THE HILT. Does not animate -- every ignition frame shows the same hilt.
        o += ["Model RS_SaberHilt%s" % hand,
              "{",
              '\tPath "models/starwars/lightsaber"',
              '\tModel 0 "saber_w.md3"',
              '\tSkin 0 "saber.jpg"',
              "\tScale 3.10 3.10 3.10",
              "\tPitchOffset 90",
              "\tNOAUTOREVERSE",
              "\t%s" % follow,
              "\tPlacementCVars rs_saber%s" % ("_off" if hand else ""),
              ""]
        for f in range(FRAMES):
            o.append("\tFrameIndex SBLD %s 0 0" % "ABCDEFGHI"[f])
        o += ["}", ""]
    # THE FLOOR PICKUP: the hilt lying on the ground, turning. On its own sprite, SBLP, so that
    # naming these classes in MODELDEF draws NOTHING in the hand -- the psprite shows SBLD, which no
    # block here names for the weapon class, and only the world props draw a held saber.
    for cls in ("RS_Lightsaber", "RS_LightsaberOff"):
        o += ["Model %s" % cls,
              "{",
              '	Path "models/starwars/lightsaber"',
              '	Model 0 "saber_w.md3"',
              '	Skin 0 "saber.jpg"',
              "	Scale 3.10 3.10 3.10",
              "	PitchOffset 90",
              "	ZOffset 6",
              "	ROTATING",
              "",
              "	FrameIndex SBLP A 0 0",
              "}", ""]
    for hand, follow in (("", "FollowMainHand"), ("Off", "FollowOffHand")):
        for i, (name, _) in enumerate(COLORS):
            o += ["Model RS_SaberBlade%s_%s" % (hand, name.capitalize()),
                  "{",
                  '\tPath "models/starwars/lightsaber"',
                  '\tModel 0 "blade.md3"',
                  '\tSurfaceSkin 0 0 "blade_core.png"',
                  '\tSurfaceSkin 0 1 "blade_mid_%s.png"' % name,
                  '\tSurfaceSkin 0 2 "blade_glow_%s.png"' % name,
                  "\tScale 3.10 3.10 3.10",
                  "\tPitchOffset 90",
                  "\tNOAUTOREVERSE",
                  "\t%s" % follow,
                  "\tPlacementCVars rs_saber%s" % ("_off" if hand else ""),
                  ""]
            for f in range(FRAMES):
                o.append("\tFrameIndex SBLD %s 0 %d" % ("ABCDEFGHI"[f], f))
            o += ["}", ""]
    # SPLICED INTO THE BASE MODELDEF BETWEEN MARKERS, not written to a file of its own. The build
    # packs root lumps off an ALLOWLIST, so a MODELDEF.lightsaber.txt would never have shipped --
    # and the base MODELDEF is otherwise hand-maintained, so everything outside the markers is
    # left exactly as it is.
    BEGIN = "// ---- BEGIN LIGHTSABER BLADES (generated by _pending/tools/gen_saber_blade.py) ----"
    END = "// ---- END LIGHTSABER BLADES ----"
    path = os.path.join(HERE, "MODELDEF.txt")
    text = open(path, encoding="utf-8").read()
    block = BEGIN + "\n" + "\n".join(o) + "\n" + END
    if BEGIN in text:
        text = text[:text.index(BEGIN)] + block + text[text.index(END) + len(END):]
    else:
        text = text.rstrip("\n") + "\n\n" + block + "\n"
    open(path, "w", encoding="utf-8", newline="\n").write(text)


def write_zscript():
    """The blade prop classes themselves -- one per colour and hand, all identical but for name."""
    o = ["// GENERATED by _pending/tools/gen_saber_blade.py. DO NOT EDIT -- change COLORS there.",
         "//",
         "// Every blade class, one per colour and hand. They differ only in name: the MODELDEF block",
         "// with the same name is what gives each its colour.", ""]
    for hand in ("", "Off"):
        for name, _ in COLORS:
            o.append("class RS_SaberBlade%s_%s : RS_SaberBladeProp {}" % (hand, name.capitalize()))
    o += ["",
          "// THE COLOUR LIST, IN rs_saber_color ORDER. Read by the handler to pick a class.",
          "struct RS_SaberColors",
          "{",
          "\tstatic String ClassFor(int idx, bool off)",
          "\t{",
          "\t\tstatic const String NAMES[] = { %s };" % ", ".join('"%s"' % n.capitalize() for n, _ in COLORS),
          "\t\tidx = clamp(idx, 0, NAMES.Size() - 1);",
          '\t\treturn String.Format("RS_SaberBlade%s_%s", off ? "Off" : "", NAMES[idx]);',
          "\t}",
          "",
          "\t// THE LIGHT'S COLOUR, per blade colour, so the walls glow what the blade is.",
          "\tstatic Color LightFor(int idx)",
          "\t{",
          # BUILT FROM ITS THREE CHANNELS, not cast from one packed int: a Color and an int are not
          # the same type in ZScript, and a cast that compiles is not proof it means the same thing.
          "\t\tstatic const int R[] = { %s };" % ", ".join(str(c[0]) for _, c in COLORS),
          "\t\tstatic const int G[] = { %s };" % ", ".join(str(c[1]) for _, c in COLORS),
          "\t\tstatic const int B[] = { %s };" % ", ".join(str(c[2]) for _, c in COLORS),
          "\t\tidx = clamp(idx, 0, R.Size() - 1);",
          "\t\treturn Color(R[idx], G[idx], B[idx]);",
          "\t}",
          "",
          "\tstatic int Count() { return %d; }" % len(COLORS),
          "}", ""]
    path = os.path.join(HERE, "zscript", "rs_lightsaber", "rs_lightsaber_blades.zs")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", newline="\n").write("\n".join(o))


def write_placeholders():
    """SBLD A-I: one-pixel placeholder sprites. Not drawn -- the model is -- but a state whose sprite
    has no lump is refused, the same reason the shieldsaw carries 1x1 placeholders."""
    from PIL import Image
    sp = os.path.join(HERE, "sprites", "starwars")
    os.makedirs(sp, exist_ok=True)
    for f in "ABCDEFGHI":
        Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(os.path.join(sp, "SBLD%s0.png" % f))
    Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(os.path.join(sp, "SBLPA0.png"))


def main():
    os.makedirs(OUT, exist_ok=True)
    write_md3(os.path.join(OUT, "blade.md3"))
    write_textures()
    write_modeldef()
    write_zscript()
    write_placeholders()
    print("blade.md3: %d shells, %d frames, %.0f units; %d colours x 2 hands"
          % (len(SHELLS), FRAMES, BLADE_LEN, len(COLORS)))


if __name__ == "__main__":
    main()
