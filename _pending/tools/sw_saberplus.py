#!/usr/bin/env python3
"""SW SaberPlus -- the mods' lightsaber, rebuilt as a ZScript weapon, inside SW_VR_Xim / SW_VR_Wardusted.

Called by make_sw_vrplus.py (build()), which hands it the pack's file dict and MODELDEF lines. Targets stock
QuestZDoom 17.x (derived from the same UZDoom line as the owner's engine; its zscript is "4.14.2" and it gives
scripts AttackPos / AttackAngle / AttackPitch / AttackRoll, the off-hand set, and the off-hand weapon slot).

The owner, 2026-09-29: "an options menu ... at least to scale the saber ... an alt fire of a second blade, or an
alt fire that throws the saber ... give them two sabers and have the sabers deflect incoming enemy attacks".

WHAT IT IS
  SWSP_Saber / SWSP_SaberOff  the saber, main hand / off hand. Replaces Wardusted's `Lightsaber` and Xim's
                              `Chainsaw` (only when the loaded strings call it a lightsaber) -- on the map and in
                              inventory -- while `sw_saberplus` is on. The mods' own sabers keep their HUD models.
  THE LOOK                    one md3: hilt, a front blade and a back blade, 20 frames (poses, ignition, the
                              throw). SIZE, COLOUR and the SECOND BLADE are picked by which SPRITE the psprite
                              shows (`S<size><colour><S|D>`), each sprite a MODELDEF block with its own Scale and
                              skins -- MODELDEF cannot read a cvar, a sprite name can be chosen per tic.
  FIRE                        a slash, alternating overhead / sideways; cuts what the blade sweeps.
  SWINGING THE CONTROLLER     cuts too: the blade tip's speed, measured from AttackPos tic to tic.
  ALT FIRE                    `sw_saber_alt` 0: the second blade, out of the pommel (on / off);
                              1: throw it -- it spins out, rips through what it meets, and comes back to the hand.
  DEFLECT                     a lit blade turns missiles that cross it back at whoever fired them.
  TWO SABERS                  `sw_saber_dual`: a second saber for the off hand, its own colour.
  IGNITION                    the blade extends when drawn and retracts when put away.
  LIGHT                       a short chain of attenuated lights up the blade, fading to the tip (`sw_saberlights`).
  NETPLAY                     playsim only; size / colour / alt mode are userinfo cvars, everything else server.
"""
import io
import math

# ---- sizes, colours ----------------------------------------------------------------------------------
SIZES = [0.70, 0.85, 1.00, 1.15, 1.30]
COLORS = [("B", "blue", (110, 165, 255)), ("G", "green", (90, 255, 110)),
          ("R", "red", (255, 55, 45)), ("P", "purple", (190, 90, 255))]
HUD_SCALE = 1.608                 # the HUD saber block's own (make_sw_stock build_hud, s2)
HUD_OFFSET = (0.0, -29.0, -8.0)
WORLD_LEN = 36.0                  # map units, pommel to tip, for the thrown / floor saber
BLADE_WORLD = 26.0                # map units of blade for the hit line, at size 1.00

# ---- the frames: (letter, yaw, up, width, extension) --------------------------------------------------
REST = (0.0, 50.0)
FRAMES = [
    ("A", 0.0, 50.0, 1.00, 1.0), ("B", 0.0, 50.0, 1.14, 1.0), ("C", 0.0, 50.0, 0.93, 1.0),   # idle shimmer
    ("D", -20.0, 72.0, 1.0, 1.0), ("E", -5.0, 90.0, 1.0, 1.0), ("F", 5.0, 80.0, 1.0, 1.0),     # overhead chop
    ("G", 10.0, 60.0, 1.0, 1.0), ("H", 12.0, 28.0, 1.0, 1.0), ("I", 8.0, 12.0, 1.0, 1.0),
    ("J", 35.0, 55.0, 1.0, 1.0), ("K", 45.0, 35.0, 1.0, 1.0), ("L", 15.0, 20.0, 1.0, 1.0),    # side cut
    ("M", -30.0, 15.0, 1.0, 1.0),
    ("N", 0.0, 50.0, 1.0, 0.10), ("O", 0.0, 50.0, 1.0, 0.35), ("P", 0.0, 50.0, 1.0, 0.70),   # ignition
    ("Q", 0.0, 50.0, 1.0, 0.92), ("R", 0.0, 50.0, 1.0, 0.02),                                  # R: unlit
    ("S", 0.0, 50.0, 1.0, -1.0),                                                               # S: thrown
    ("T", 0.0, 0.0, 1.0, 1.0),                                                                 # T: flat
]
HIDDEN = (60.0, 0.0, 18.0)

# ---- the light chain ---------------------------------------------------------------------------------
CHAIN = [(0.10, 30, 36, 1.00, "pulselight", 0.53), (0.38, 28, 34, 0.85, "flickerlight2", 0.13),
         (0.66, 22, 27, 0.60, "pulselight", 0.37), (0.92, 13, 17, 0.38, "flickerlight2", 0.09),
         (0.50, 40, 48, 0.95, "pulselight", 0.45)]


def _png(img):
    b = io.BytesIO()
    img.save(b, "PNG")
    return b.getvalue()


def build_mesh(old_surfs, rest_frame, read_pose, write_md3):
    """The saber md3: hilt (5 surfaces), front blade (core, inner, colour), back blade (the same, mirrored
    through the grip), 20 frames. Returns (bytes, surface count, overall length in mesh units)."""
    pose, unpose = read_pose
    base = [([unpose(v, *REST) for v in s["frames"][rest_frame][0]],
             [unpose(n, *REST) for n in s["frames"][rest_frame][1]]) for s in old_surfs]
    hilt = list(range(5))
    blade = [5, 6, 7]                                       # core, inner, colour (the halos drew nothing)
    e = min(v[0] for i in blade for v in base[i][0])       # the emitter: where the blade starts
    p = min(v[0] for i in hilt for v in base[i][0])        # the pommel
    tip = max(v[0] for i in blade for v in base[i][0])

    surfs = []
    for i in hilt:
        surfs.append(dict(name=old_surfs[i]["name"][:63], shader="saber.jpg", tris=old_surfs[i]["tris"],
                          st=old_surfs[i]["st"], src=i, kind="hilt"))
    for i in blade:
        surfs.append(dict(name="front%d" % i, shader="blade.png", tris=old_surfs[i]["tris"],
                          st=old_surfs[i]["st"], src=i, kind="front"))
    for i in blade:   # mirrored, so its winding flips
        surfs.append(dict(name="back%d" % i, shader="blade.png",
                          tris=[(a, c, b) for (a, b, c) in old_surfs[i]["tris"]],
                          st=old_surfs[i]["st"], src=i, kind="back"))

    def vert(s, v, width, ext):
        x, y, z = v
        if s["kind"] == "hilt":
            return v
        # A BLADE STILL IN THE EMITTER IS THIN: it shoots out narrow and fills in, and an unlit one leaves
        # no coloured cap on the hilt
        w = width * min(1.0, ext * 4.0)
        y, z = y * w, z * w
        if s["kind"] == "front":
            return (e + (x - e) * ext, y, z)
        return (p - (x - e) * ext, y, z)                     # the back blade leaves the pommel

    for s in surfs:
        s["frames"] = []
    for letter, yaw, up, width, ext in FRAMES:
        for s in surfs:
            vs, ns = base[s["src"]]
            if ext < 0:
                s["frames"].append(([HIDDEN] * len(vs), ns))
                continue
            vv = [pose(vert(s, v, width, max(ext, 0.02)), yaw, up) for v in vs]
            nn = [pose(n if s["kind"] != "back" else (-n[0], n[1], n[2]), yaw, up) for n in ns]
            s["frames"].append((vv, nn))
    out = [dict(name=s["name"], shader=s["shader"], tris=s["tris"], st=s["st"], frames=s["frames"]) for s in surfs]
    length = (tip - e) * 2 + (e - p)                         # both blades and the hilt
    return write_md3("swsp_saber", out, len(FRAMES)), len(out), (tip - p)


def add(files, o, z, mod, read_md3, write_md3, pose_fns, clear_png, rest_frame, default_color):
    """Everything SaberPlus puts in a pack. `mod` is "wardusted" or "xim". Appends MODELDEF lines to `o`,
    files to `files`, and returns (zscript, cvarinfo, menudef, mapinfo, gldefs, sndinfo) texts."""
    from PIL import Image
    folder = "models/swsp"
    old = read_md3(z.read("models/sw/saber/saber_anim.md3"))
    md3, nsurf, full_len = build_mesh(old, rest_frame, pose_fns, write_md3)
    files[folder + "/swsp_saber.md3"] = md3
    files[folder + "/saber.jpg"] = z.read("models/sw/saber/saber.jpg")
    files[folder + "/clear.png"] = clear_png()
    Image.new("RGB", (8, 8), (255, 255, 255)).save(b := io.BytesIO(), "PNG")
    files[folder + "/blade_core.png"] = b.getvalue()
    files[folder + "/blade_bm.png"] = b.getvalue()
    for tag, name, (r, g, bl) in COLORS:
        inner = tuple(int(255 * 0.72 + ch * 0.28) for ch in (r, g, bl))
        files[folder + "/blade_inner_%s.png" % name] = _png(Image.new("RGB", (8, 8), inner))
        files[folder + "/blade_mid_%s.png" % name] = _png(Image.new("RGB", (8, 8), (r, g, bl)))

    world_scale = WORLD_LEN / full_len
    letters = [f[0] for f in FRAMES]

    def skins(col, double):
        tag, name, _ = col
        sk = [(i, "saber.jpg") for i in range(5)]
        sk += [(5, "blade_core.png"), (6, "blade_inner_%s.png" % name), (7, "blade_mid_%s.png" % name)]
        if double:
            sk += [(8, "blade_core.png"), (9, "blade_inner_%s.png" % name), (10, "blade_mid_%s.png" % name)]
        else:
            sk += [(8, "clear.png"), (9, "clear.png"), (10, "clear.png")]
        return sk

    def sprite_lumps(spr, lets):
        for L in lets:
            files["sprites/swsp/%s%s0.png" % (spr, L)] = clear_png()

    o.append("// ==== SW SABERPLUS: the scripted saber -- a block per size x colour x one/two blades ====")
    variants = []
    for si, s in enumerate(SIZES):
        for col in COLORS:
            for dbl in (False, True):
                variants.append(("S%d%s%s" % (si + 1, col[0], "D" if dbl else "S"), s, col, dbl))
    # the placeholder the states name, drawn as the mod's default colour, size 1.00, one blade
    dcol = [c for c in COLORS if c[1] == default_color][0]
    variants.append(("SWSP", 1.0, dcol, False))
    for cls in ("SWSP_Saber", "SWSP_SaberOff"):
        for spr, s, col, dbl in variants:
            sc = HUD_SCALE * s
            o += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "swsp_saber.md3"']
            o += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins(col, dbl)]
            o += ["\tScale %.3f %.3f %.3f" % (-sc, sc, sc), "\tOffset %.1f %.1f %.1f" % HUD_OFFSET, ""]
            o += ["\tFrameIndex %s %s 0 %d" % (spr, L, i) for i, L in enumerate(letters)]
            o += ["}", ""]
    for spr, s, col, dbl in variants:
        sprite_lumps(spr, letters)
    # THROWN: spinning flat, in the world, in its colour; and the FLOOR pickup
    for col in COLORS:
        for dbl in (False, True):
            spr = "T%s%s_" % (col[0], "D" if dbl else "S")
            spr = spr[:4].replace("_", "W")
            o += ["Model SWSP_Thrown", "{", '\tPath "%s"' % folder, '\tModel 0 "swsp_saber.md3"']
            o += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins(col, dbl)]
            o += ["\tScale %.3f %.3f %.3f" % ((world_scale,) * 3), "\tZOffset 4", "\tROTATING",
                  "\tRotation-Speed 45", "", "\tFrameIndex %s A 0 %d" % (spr, letters.index("T")), "}", ""]
            sprite_lumps(spr, "A")
    for cls in ("SWSP_Saber", "SWSP_SaberOff"):
        o += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "swsp_saber.md3"']
        o += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins(dcol, False)]
        o += ["\tScale %.3f %.3f %.3f" % ((world_scale,) * 3), "\tZOffset 10", "\tROTATING",
              "\tRotation-Speed 3", "", "\tFrameIndex SWPK A 0 %d" % letters.index("T"), "}", ""]
    sprite_lumps("SWPK", "A")

    # ---- lights ----------------------------------------------------------------------------------------
    gl = ["// SW SABERPLUS -- the blade is fullbright, and a chain of lights fades up it.", ""]
    for tag, name, _ in COLORS:
        for sk in ("blade_core.png", "blade_inner_%s.png" % name, "blade_mid_%s.png" % name):
            gl += ['brightmap texture "%s/%s"' % (folder, sk), "{", '\tmap "%s/blade_bm.png"' % folder, "}", ""]
    for tag, name, (r, g, bl) in COLORS:
        rgb = (r / 255.0, g / 255.0, bl / 255.0)
        for k, (t, s1, s2, br, kind, iv) in enumerate(CHAIN):
            ln = "SWSP_L%s%d" % (tag, k)
            gl += ["%s %s" % (kind, ln), "{", "\tcolor %.3f %.3f %.3f" % tuple(c * br for c in rgb),
                   "\tsize %d" % s1, "\tsecondarySize %d" % s2, "\tinterval %.2f" % iv, "\tattenuate 1", "}", "",
                   "object %s" % ln, "{", "\tframe SL%s%dA { light %s }" % (tag, k, ln), "}", ""]
            files["sprites/swsp/SL%s%dA0.png" % (tag, k)] = clear_png()
    gldefs = "\n".join(gl)

    # ---- sounds ----------------------------------------------------------------------------------------
    snd = ["// SW SABERPLUS -- Wardust's saber set, as RS_Lightsaber carries it."]
    import os
    sdir = "/home/claude/swsp_snd"
    for fn in sorted(os.listdir(sdir)):
        files["sounds/swsp/" + fn] = open(os.path.join(sdir, fn), "rb").read()
    snd += ["swsp/on       sounds/swsp/dssabreu.wav", "swsp/off      sounds/swsp/dssabreu.wav",
            "$volume swsp/off 0.6", "swsp/hum      sounds/swsp/dssabrei.wav",
            "swsp/deflect  sounds/swsp/dssawhit.wav"]
    for n in range(1, 6):
        snd.append("swsp/swing%d  sounds/swsp/dssabre%d.mp3" % (n, n))
    snd.append("$random swsp/swing { swsp/swing1 swsp/swing2 swsp/swing3 swsp/swing4 swsp/swing5 }")
    for n in range(1, 4):
        snd.append("swsp/hit%d    sounds/swsp/lsabhit%d.mp3" % (n, n))
        snd.append("swsp/wall%d   sounds/swsp/lsabhtw%d.mp3" % (n, n))
    snd.append("$random swsp/hit { swsp/hit1 swsp/hit2 swsp/hit3 }")
    snd.append("$random swsp/wall { swsp/wall1 swsp/wall2 swsp/wall3 }")
    sndinfo = "\n".join(snd) + "\n"

    # ---- cvars, menu -----------------------------------------------------------------------------------
    cidx = [c[1] for c in COLORS].index(default_color)
    cvarinfo = "\n".join([
        "// SW SABERPLUS. The look and the alt fire are yours (userinfo: every machine sees your choice);",
        "// what it does to the game is the server's.",
        "user float  sw_saber_size      = 1.0;",
        "user int    sw_saber_color     = %d;" % cidx,
        "user int    sw_saber_color_off = %d;" % (1 if cidx != 1 else 0),
        "user int    sw_saber_alt       = 0;",
        "server bool sw_saberplus       = true;",
        "server bool sw_saber_dual      = true;",
        "server bool sw_saber_start     = true;",
        "server bool sw_saber_deflect   = true;",
        "server float sw_saber_damage   = 30.0;",
        "server int  sw_saberlights     = 2;", ""])
    menudef = "\n".join([
        'OptionValue "SWSP_Colors"', "{"] + ['\t%d, "%s"' % (i, c[1].capitalize()) for i, c in enumerate(COLORS)] + ["}",
        'OptionValue "SWSP_Alt"', "{", '\t0, "Second blade (double-bladed)"', '\t1, "Throw it (it comes back)"', "}",
        'OptionValue "SWSP_Lights"', "{", '\t0, "Off"', '\t1, "Simple"', '\t2, "Full (fades up the blade)"', "}",
        'OptionMenu "SWSP_Options"', "{", '\tTitle "SW QUESTSABER"',
        '\tOption "Use the new saber", "sw_saberplus", "OnOff"',
        '\tOption "Start with the saber", "sw_saber_start", "OnOff"',
        '\tStaticText ""',
        '\tSlider "Size", "sw_saber_size", 0.7, 1.3, 0.15, 2',
        '\tOption "Colour", "sw_saber_color", "SWSP_Colors"',
        '\tOption "Off-hand colour", "sw_saber_color_off", "SWSP_Colors"',
        '\tOption "Alt fire", "sw_saber_alt", "SWSP_Alt"',
        '\tStaticText ""',
        '\tOption "Deflect shots", "sw_saber_deflect", "OnOff"',
        '\tOption "Second saber in your off hand", "sw_saber_dual", "OnOff"',
        '\tOption "Blade light", "sw_saberlights", "SWSP_Lights"',
        '\tSlider "Damage", "sw_saber_damage", 10, 100, 5, 0',
        '\tStaticText ""',
        '\tStaticText "Fire slashes. Swinging your arm cuts too.", "DarkGray"',
        '\tStaticText "A lit blade knocks shots back at whoever fired them.", "DarkGray"',
        "}", 'AddOptionMenu "OptionsMenu"', "{", '\tSubmenu "SW QuestSaber", "SWSP_Options"', "}", ""])
    mapinfo = 'GameInfo\n{\n\tAddEventHandlers = "SWSP_Bridge"\n}\n'
    zs = zscript(mod, letters)
    return zs, cvarinfo, menudef, mapinfo, gldefs, sndinfo


# WEAPONS THE MOD LETS YOU PICK WITH NO AMMO (+AMMO_OPTIONAL): Wardusted starts you "holding" the thermal
# detonator and the mines with none of either -- an empty hand in slot 8. The owner, 09-29: "why do i even
# switch to shit i don't have". While sw_skip_empty is on, those drop out of the weapon cycle until you pick
# up ammo, and you leave them the moment you throw the last one -- plain Doom rules.
MENU_NAME = {"wardusted": "Wardusted VR Weapon Options", "xim": "Xim VR Weapon Options"}
NO_EMPTY = {"wardusted": ("RebelThermalDetonator", "ProximityMines")}


def zscript(mod, letters):
    yaw = ", ".join("%.1f" % f[1] for f in FRAMES)
    up = ", ".join("%.1f" % f[2] for f in FRAMES)
    ext = ", ".join("%.2f" % f[4] for f in FRAMES)
    cols = ", ".join('"%s"' % c[0] for c in COLORS)
    sizes = ", ".join("%.2f" % s for s in SIZES)
    chain_t = ", ".join("%.2f" % c[0] for c in CHAIN)
    mod_saber = "Lightsaber" if mod == "wardusted" else "Chainsaw"
    need_xim = "true" if mod == "xim" else "false"
    reg = []
    for si in range(len(SIZES)):
        reg.append("\t\t" + " ".join("S%d%s%s A 0;" % (si + 1, c[0], d) for c in COLORS for d in "SD"))
    reg.append("\t\t" + " ".join("T%s%sW A 0;" % (c[0], d) for c in COLORS for d in "SD"))
    register = "\n".join(reg)
    return r'''version "4.10"

// ==========================================================================================================
// SW SABERPLUS -- GENERATED by RS_VR_Weapons/_pending/tools/sw_saberplus.py (via make_sw_vrplus.py).
// The mod's lightsaber as a ZScript weapon for stock QuestZDoom 17.x. See the tool's header for the design.
// ==========================================================================================================

// ---- THE FRAMES the md3 was built with: A-C idle shimmer, D-I overhead chop, J-M side cut, N-Q ignition,
// R unlit, S thrown (out of sight), T flat. Pose = the blade raised `up` from the aim, swung `yaw` left.
class SWSP_Data
{
	static double Yaw(int f) { static const double T[] = { %(yaw)s }; return T[clamp(f, 0, %(n)d)]; }
	static double Up(int f)  { static const double T[] = { %(up)s }; return T[clamp(f, 0, %(n)d)]; }
	static double Ext(int f) { static const double T[] = { %(ext)s }; return T[clamp(f, 0, %(n)d)]; }
	static String Col(int c) { String t = "%(colstr)s"; return t.Mid(clamp(c, 0, %(nc)d), 1); }
	static double Size(int s) { static const double T[] = { %(sizes)s }; return T[clamp(s, 0, 4)]; }
	static double ChainT(int k) { static const double T[] = { %(chain_t)s }; return T[clamp(k, 0, 4)]; }
	// THE SEGMENTS' CLOSEST APPROACH (Ericson 5.1.9): segment a0..a0+da against the origin..db
	static double SegSeg(Vector3 a0, Vector3 da, Vector3 db)
	{
		double a = da dot da, e = db dot db, f = db dot a0;
		double s = 0, t = 0;
		if (a <= 0.000001 && e <= 0.000001) return a0.Length();
		if (a <= 0.000001) t = clamp(f / e, 0.0, 1.0);
		else
		{
			double c = da dot a0;
			if (e <= 0.000001) s = clamp(-c / a, 0.0, 1.0);
			else
			{
				double b = da dot db, den = a * e - b * b;
				s = (den != 0) ? clamp((b * f - c * e) / den, 0.0, 1.0) : 0.0;
				t = (b * s + f) / e;
				if (t < 0) { t = 0; s = clamp(-c / a, 0.0, 1.0); }
				else if (t > 1) { t = 1; s = clamp((b - c) / a, 0.0, 1.0); }
			}
		}
		return (a0 + da * s - db * t).Length();
	}
}

class SWSP_Light : Actor
{
	Default { +NOINTERACTION +NOGRAVITY +NOBLOCKMAP +DONTSPLASH +NOTONAUTOMAP }
	States { Spawn: TNT1 A -1; Stop; }
}
'''.replace("%(yaw)s", yaw).replace("%(up)s", up).replace("%(ext)s", ext).replace("%(colstr)s", "".join(c[0] for c in COLORS)) \
       .replace("%(sizes)s", sizes).replace("%(chain_t)s", chain_t).replace("%(n)d", str(len(FRAMES) - 1)) \
       .replace("%(nc)d", str(len(COLORS) - 1)) + light_classes() + WEAPON.replace("%MODSABER%", mod_saber) \
       .replace("%NEEDXIM%", need_xim).replace("%REGISTER%", register)



def light_classes():
    out = []
    for tag, name, _ in COLORS:
        for k in range(len(CHAIN)):
            out.append("class SWSP_L%s%d : SWSP_Light { States { Spawn: SL%s%d A -1; Stop; } }" % (tag, k, tag, k))
    return "\n".join(out) + "\n\n"


WEAPON = r'''
// ==========================================================================================================
// THE SABER
// ==========================================================================================================
class SWSP_SaberBase : Weapon abstract
{
	int  frameNow;           // the frame on screen (SWSP_Data), which decides the pose, and whether it is lit
	bool back;               // the second blade, out of the pommel
	int  slashNo;            // alternates the two slashes
	SWSP_Thrown thrown;      // in the air; null in the hand
	private Vector3 lastTip;
	private bool    lastTipOk;
	private Array<Actor> cutWho;
	private Array<int>   cutWhen;
	private Array<Actor> litBy;   // 5 slots. Not "lights": ZScript names ignore case, and Lights() is the method
	private int     lightCol;
	private bool    humming;
	private int     swingQuiet;

	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 2100;
		Weapon.Kickback 0;
		Weapon.BobStyle "Smooth";
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOAUTOAIM
		+WEAPON.NOAUTOFIRE
		Inventory.PickupMessage "You got a lightsaber!";
		Tag "Lightsaber";
		Obituary "%o was cut down by %k's lightsaber.";
	}

	// ---- settings --------------------------------------------------------------------------------------
	private double UF(String n, double fb)
	{
		CVar c = null;
		if (owner && owner.player) c = CVar.GetCVar(n, owner.player);
		else c = CVar.FindCVar(n);
		if (!c) return fb;
		return c.GetFloat();
	}
	private int UInt(String n, int fb)
	{
		CVar c = null;
		if (owner && owner.player) c = CVar.GetCVar(n, owner.player);
		else c = CVar.FindCVar(n);
		if (!c) return fb;
		return c.GetInt();
	}
	private double SF(String n, double fb)
	{
		let c = CVar.FindCVar(n);
		return c ? c.GetFloat() : fb;
	}
	int SizeIdx()
	{
		double s = UF("sw_saber_size", 1.0);
		int best = 2;
		double d = 99;
		for (int i = 0; i < 5; i++)
		{
			double dd = abs(SWSP_Data.Size(i) - s);
			if (dd < d) { d = dd; best = i; }
		}
		return best;
	}
	int ColIdx() { return UInt(bOffhandWeapon ? "sw_saber_color_off" : "sw_saber_color", 0); }
	String SpriteNow() { return String.Format("S%d%s%s", SizeIdx() + 1, SWSP_Data.Col(ColIdx()), back ? "D" : "S"); }

	// ---- what the psprite shows: this saber's size / colour / blades, at frame f -------------------------
	action void A_SWShow(int f)
	{
		if (invoker.thrown) f = 18;                     // S: in the air, nothing in the hand
		invoker.frameNow = f;
		let psp = player.FindPSprite(invoker.bOffhandWeapon ? PSP_OFFHANDWEAPON : PSP_WEAPON);
		if (!psp) return;
		Name sn = invoker.SpriteNow();
		psp.Sprite = GetSpriteIndex(sn);
		psp.Frame = f;
	}
	action void A_SWReady(int f)
	{
		A_SWShow(f);
		A_WeaponReady(invoker.thrown ? WRF_NOPRIMARY : 0);
	}
	action void A_SWOn()  { A_StartSound("swsp/on", CHAN_WEAPON); }
	action void A_SWOff() { A_StartSound("swsp/off", CHAN_WEAPON); }
	action void A_SWSlashStart()
	{
		invoker.slashNo++;
		A_StartSound("swsp/swing", CHAN_WEAPON);
	}
	action state A_SWWhichSlash()
	{
		if ((invoker.slashNo & 1) == 0) return ResolveState("SlashB");
		return null;
	}
	// A SLASH'S CUT: whatever the blade is in, this frame, at a slash's speed
	action void A_SWCut() { invoker.CutAlong(22.0); }

	// ---- ALT FIRE: the second blade, or the throw -----------------------------------------------------------
	action void A_SWAlt()
	{
		if (invoker.thrown) return;
		if (invoker.UInt("sw_saber_alt", 0) == 0)
		{
			invoker.back = !invoker.back;
			A_StartSound(invoker.back ? "swsp/on" : "swsp/off", CHAN_WEAPON);
			return;
		}
		invoker.Throw();
	}

	// ---- THE HAND ----------------------------------------------------------------------------------------
	Vector3 HandPos()
	{
		Vector3 p = bOffhandWeapon ? owner.OffhandPos : owner.AttackPos;
		if (p == (0, 0, 0)) p = owner.Vec3Offset(0, 0, owner.player ? owner.player.viewheight * 0.8 : 40.0);
		return p;
	}
	private double HA() { return (bOffhandWeapon ? owner.OffhandAngle : owner.AttackAngle) + 90.0; }
	private double HP() { return -(bOffhandWeapon ? owner.OffhandPitch : owner.AttackPitch); }
	private double HR() { return bOffhandWeapon ? owner.OffhandRoll : owner.AttackRoll; }
	Vector3 Aim()
	{
		double a = HA(), p = HP();
		return (cos(p) * cos(a), cos(p) * sin(a), -sin(p));
	}
	// THE BLADE'S DIRECTION for the frame on screen: the aim raised `up` about the wrist, swung `yaw` left
	Vector3 BladeDir()
	{
		double a = HA(), r = HR();
		Vector3 f = Aim();
		Vector3 flatRight = (sin(a), -cos(a), 0);
		Vector3 levelUp = flatRight cross f;
		Vector3 upv = levelUp * cos(r) - flatRight * sin(r);
		Vector3 right = flatRight * cos(r) + levelUp * sin(r);
		double yw = SWSP_Data.Yaw(frameNow), u = SWSP_Data.Up(frameNow);
		return f * (cos(u) * cos(yw)) - right * (cos(u) * sin(yw)) + upv * sin(u);
	}
	double BladeLen() { return 26.0 * SWSP_Data.Size(SizeIdx()) * max(SWSP_Data.Ext(frameNow), 0.0); }
	bool Lit() { return !thrown && SWSP_Data.Ext(frameNow) > 0.5 && InHand(); }
	bool InHand()
	{
		if (!owner || !owner.player) return false;
		return bOffhandWeapon ? (owner.player.OffhandWeapon == self) : (owner.player.ReadyWeapon == self);
	}

	// ---- EVERY TIC ---------------------------------------------------------------------------------------
	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner || !owner.player) return;
		int ch = bOffhandWeapon ? 21 : 20;
		if (!Lit())
		{
			if (humming) { owner.A_StopSound(ch); humming = false; }
			lastTipOk = false;
			Lights(false);
			return;
		}
		if (!humming) { owner.A_StartSound("swsp/hum", ch, CHANF_LOOPING, 0.5); humming = true; }

		Vector3 hand = HandPos(), dir = BladeDir();
		double len = BladeLen();
		Vector3 tip = hand + dir * len;
		double speed = lastTipOk ? (tip - lastTip).Length() : 0.0;
		lastTip = tip;
		lastTipOk = true;
		owner.A_SoundPitch(ch, 1.0 + clamp(speed / 40.0, 0.0, 0.5));

		// SWUNG FOR REAL: the controller moving the blade cuts, and whooshes
		if (speed >= 10.0)
		{
			CutAlong(speed);
			if (swingQuiet <= 0) { owner.A_StartSound("swsp/swing", CHAN_AUTO, 0, 0.8); swingQuiet = 10; }
		}
		if (swingQuiet > 0) swingQuiet--;

		let dc = CVar.FindCVar("sw_saber_deflect");
		if (!dc || dc.GetBool())
		{
			Deflect(hand, dir, len);
			if (back) Deflect(hand, -dir, len);
		}
		Lights(true);
	}

	// ---- CUT: whatever the blade is in ------------------------------------------------------------------
	void CutAlong(double speed)
	{
		Vector3 hand = HandPos(), dir = BladeDir();
		double len = BladeLen();
		CutLine(hand, dir, len, speed);
		if (back) CutLine(hand, -dir, len, speed);
	}
	private void CutLine(Vector3 base, Vector3 dir, double len, double speed)
	{
		if (len < 1) return;
		Vector3 mid = base + dir * (len * 0.5);
		double reach = len * 0.5 + 48.0;
		let it = BlockThingsIterator.CreateFromPos(mid.x, mid.y, mid.z - reach, reach * 2.0, reach, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || mo == owner || !mo.bShootable || mo.health <= 0) continue;
			if (mo.bFriendly && owner.player) continue;
			if (mo.player && !deathmatch) continue;
			int i = cutWho.Find(mo);
			if (i < cutWho.Size() && level.maptime - cutWhen[i] < 8) continue;
			Vector3 c = level.Vec3Diff(base, (mo.pos.xy, mo.pos.z + mo.height * 0.5));
			Vector3 blade = dir * len;
			double t = clamp((c dot blade) / (len * len), 0.0, 1.0);
			Vector3 gap = c - blade * t;
			if ((gap.xy).Length() > mo.radius + 3.0 || abs(gap.z) > mo.height * 0.5 + 3.0) continue;
			int dmg = int(SF("sw_saber_damage", 30.0) * clamp(speed / 20.0, 0.5, 2.0));
			Vector3 at = level.Vec3Offset(base, blade * t);
			if (!mo.bNoBlood) mo.SpawnBlood(at, VectorAngle(dir.x, dir.y), dmg);
			mo.DamageMobj(self, owner, dmg, 'Saber', DMG_THRUSTLESS);
			owner.A_StartSound(mo.bNoBlood ? "swsp/wall" : "swsp/hit", CHAN_AUTO);
			if (i < cutWho.Size()) cutWhen[i] = level.maptime;
			else { cutWho.Push(mo); cutWhen.Push(level.maptime); }
		}
		for (int k = cutWho.Size() - 1; k >= 0; k--)
			if (!cutWho[k] || cutWho[k].health <= 0) { cutWho.Delete(k); cutWhen.Delete(k); }
	}

	// ---- DEFLECT: a missile crossing the blade goes back where it came from --------------------------------
	void Deflect(Vector3 base, Vector3 dir, double len)
	{
		if (len < 1) return;
		Vector3 mid = base + dir * (len * 0.5);
		double reach = len * 0.5 + 160.0;          // fast bolts cover a lot of ground in a tic
		let it = BlockThingsIterator.CreateFromPos(mid.x, mid.y, mid.z - reach, reach * 2.0, reach, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || !mo.bMissile || mo == owner || mo.target == owner || mo is "SWSP_Thrown") continue;
			Vector3 p0 = level.Vec3Diff(base, mo.pos);
			if (SWSP_Data.SegSeg(p0, mo.vel, dir * len) > mo.radius + 4.0) continue;
			BatBack(mo);
		}
	}
	void BatBack(Actor mo)
	{
		Actor shooter = mo.target;
		double sp = max(mo.Speed, mo.vel.Length());
		if (sp <= 0) sp = 10;
		Vector3 d;
		if (shooter && shooter != owner && shooter.health > 0)
			d = level.Vec3Diff(mo.pos, (shooter.pos.xy, shooter.pos.z + shooter.height * 0.5));
		else
			d = -mo.vel;
		if (d.Length() < 0.001) d = -mo.vel;
		d = d.Unit();
		mo.target = owner;
		if (mo.bSeekerMissile) mo.tracer = shooter;
		mo.vel = d * sp;
		mo.angle = VectorAngle(d.x, d.y);
		mo.pitch = -asin(clamp(d.z, -1.0, 1.0));
		owner.A_StartSound("swsp/deflect", CHAN_AUTO);
	}

	// ---- THE THROW ---------------------------------------------------------------------------------------
	void Throw()
	{
		Vector3 hand = HandPos();
		let t = SWSP_Thrown(Actor.Spawn("SWSP_Thrown", hand));
		if (!t) return;
		t.target = owner;
		t.master = owner;
		t.launcher = self;
		t.col = ColIdx();
		t.dbl = back;
		Vector3 d = Aim();
		t.vel = d * t.Speed;
		t.angle = VectorAngle(d.x, d.y);
		thrown = t;
		owner.A_StartSound("swsp/swing", CHAN_WEAPON);
	}

	// ---- THE LIGHT UP THE BLADE ---------------------------------------------------------------------------
	private void Lights(bool on)
	{
		int mode = int(SF("sw_saberlights", 2));
		int col = ColIdx();
		if (litBy.Size() < 5) litBy.Resize(5);
		if (col != lightCol) { KillLights(); lightCol = col; }
		if (!on || mode <= 0) { KillLights(); return; }
		Vector3 hand = HandPos(), dir = BladeDir();
		double len = BladeLen();
		for (int k = 0; k < 5; k++)
		{
			bool want = (mode >= 2) ? (k < 4) : (k == 4);
			if (!want) { if (litBy[k]) { litBy[k].Destroy(); litBy[k] = null; } continue; }
			Vector3 at = hand + dir * (len * SWSP_Data.ChainT(k));
			if (!litBy[k])
			{
				String cls = String.Format("SWSP_L%s%d", SWSP_Data.Col(col), k);
				litBy[k] = Actor.Spawn(cls, at);
			}
			else litBy[k].SetOrigin(at, true);
		}
	}
	private void KillLights()
	{
		for (int k = 0; k < litBy.Size(); k++) { if (litBy[k]) litBy[k].Destroy(); litBy[k] = null; }
	}
	override void OnDestroy()
	{
		KillLights();
		Super.OnDestroy();
	}
	override void DetachFromOwner()
	{
		KillLights();
		if (owner) owner.A_StopSound(bOffhandWeapon ? 21 : 20);
		humming = false;
		Super.DetachFromOwner();
	}

	States
	{
	Spawn:
		SWPK A -1;
		Stop;
	Select:
		SWSP R 1 { A_SWShow(17); A_Raise(12); }
		Loop;
	Deselect:
		SWSP Q 1 { A_SWShow(16); A_SWOff(); }
		SWSP P 1 A_SWShow(15);
		SWSP O 1 A_SWShow(14);
		SWSP N 1 A_SWShow(13);
	DeselectLoop:
		SWSP R 1 { A_SWShow(17); A_Lower(12); }
		Loop;
	Ready:
		SWSP N 2 { A_SWShow(13); A_SWOn(); }
		SWSP O 2 A_SWShow(14);
		SWSP P 2 A_SWShow(15);
		SWSP Q 2 A_SWShow(16);
	ReadyLoop:
		SWSP AAA 1 A_SWReady(0);
		SWSP BBB 1 A_SWReady(1);
		SWSP CCC 1 A_SWReady(2);
		Loop;
	Fire:
		SWSP A 0 A_SWSlashStart();
		SWSP A 0 A_SWWhichSlash();
		SWSP D 2 A_SWShow(3);
		SWSP E 2 A_SWShow(4);
		SWSP F 2 { A_SWShow(5); A_SWCut(); }
		SWSP G 2 { A_SWShow(6); A_SWCut(); }
		SWSP H 2 { A_SWShow(7); A_SWCut(); }
		SWSP I 3 A_SWShow(8);
		Goto ReadyLoop;
	SlashB:
		SWSP J 2 A_SWShow(9);
		SWSP K 2 { A_SWShow(10); A_SWCut(); }
		SWSP L 2 { A_SWShow(11); A_SWCut(); }
		SWSP M 3 { A_SWShow(12); A_SWCut(); }
		Goto ReadyLoop;
	AltFire:
		SWSP A 1 { A_SWShow(0); A_SWAlt(); }
		SWSP A 11 A_SWShow(0);
		Goto ReadyLoop;
	// NEVER ENTERED. The engine registers a sprite name only when some state uses it (sprites.cpp
	// R_InitSpriteDefs), and MODELDEF stops the game on a name it does not know -- so every size x colour
	// x blades name the psprite is switched to, and the thrown saber's, is named here once.
	Register:
%REGISTER%
		Stop;
	}
}

class SWSP_Saber : SWSP_SaberBase {}
class SWSP_SaberOff : SWSP_SaberBase
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
		Weapon.SelectionOrder 2101;
		Weapon.SlotNumber -1;        // never on a number key: the bridge draws it into the off hand itself
	}
}

// ==========================================================================================================
// THE THROWN SABER: spins out, rips through, comes back to the hand that threw it
// ==========================================================================================================
class SWSP_Thrown : Actor
{
	SWSP_SaberBase launcher;
	int  col;
	bool dbl;
	int  age;

	Default
	{
		Radius 10;
		Height 10;
		Speed 24;
		Projectile;
		+RIPPER
		+NOEXTREMEDEATH
		+DONTSPLASH
		BounceType "Doom";
		BounceCount 999;
		BounceFactor 1.0;
		WallBounceFactor 1.0;
		DamageFunction (15);
		DamageType "Saber";
		Obituary "%o was cut down by %k's thrown lightsaber.";
	}
	States
	{
	Spawn:
		SWPK A 1;
		Loop;
	Death:
		SWPK A 1;
		Stop;
	}
	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		Name sn = String.Format("T%s%sW", SWSP_Data.Col(col), dbl ? "D" : "S");
		sprite = GetSpriteIndex(sn);
		frame = 0;
		age++;
		if (age % 8 == 1) A_StartSound("swsp/swing", CHAN_BODY, 0, 0.7);
		// the saber left its owner's hands in flight (dropped, taken): nothing to come home to
		if (!launcher || !launcher.owner || !master || age > 175) { if (launcher) launcher.thrown = null; Destroy(); return; }
		// A SPINNING DISC OF BLADE: missiles that cross it go back too
		let it = BlockThingsIterator.Create(self, 40);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!mo || !mo.bMissile || mo == self || mo.target == master || mo is "SWSP_Thrown") continue;
			if (Distance3D(mo) < 26 + mo.radius) launcher.BatBack(mo);
		}
		if (age < 18) return;
		// HOME: to the hand, wherever it has gone
		Vector3 to = level.Vec3Diff(pos, launcher.HandPos());
		double d = to.Length();
		if (d < 28)
		{
			launcher.thrown = null;
			master.A_StartSound("swsp/deflect", CHAN_AUTO, 0, 0.5);
			Destroy();
			return;
		}
		bNOCLIP = (age > 60);           // a saber stuck behind a wall walks home through it
		vel = to / d * 28.0;
	}
}

// ==========================================================================================================
// THE BRIDGE: the mod's saber becomes this one -- on the map and in the hand -- while sw_saberplus is on
// ==========================================================================================================
class SWSP_Bridge : EventHandler
{
	private int ximKnown;

	private bool On()
	{
		let c = CVar.FindCVar("sw_saberplus");
		return !c || c.GetBool();
	}
	private bool ModSaberIsSaber()
	{
		if (!%NEEDXIM%) return true;
		if (ximKnown == 0)
		{
			String s = StringTable.Localize("$GOTCHAINSAW");
			s = s.MakeLower();
			ximKnown = (s.IndexOf("lightsaber") >= 0) ? 1 : 2;
		}
		return ximKnown == 1;
	}
	private class<Weapon> ModClass()
	{
		String n = "%MODSABER%";
		class<Actor> c = n;
		return (class<Weapon>)(c);
	}

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!On() || e.IsFinal || !ModSaberIsSaber()) return;
		let mc = ModClass();
		if (mc && e.Replacee == mc) e.Replacement = "SWSP_Saber";
	}

	override void WorldTick()
	{
		if ((level.maptime % 5) != 0) return;
		let dc = CVar.FindCVar("sw_saber_dual");
		bool dual = dc && dc.GetBool();
		let stc = CVar.FindCVar("sw_saber_start");
		bool start = stc && stc.GetBool();
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let p = players[i];
			if (On() && ModSaberIsSaber())
			{
				let mc = ModClass();
				Weapon theirs = null;
				if (mc) theirs = Weapon(p.mo.FindInventory(mc, true));
				if (theirs && !(theirs is "SWSP_SaberBase"))
				{
					bool held = (p.ReadyWeapon == theirs) || (p.PendingWeapon == theirs);
					p.mo.RemoveInventory(theirs);
					theirs.Destroy();
					if (!p.mo.FindInventory("SWSP_Saber")) p.mo.GiveInventory("SWSP_Saber", 1);
					let ours = Weapon(p.mo.FindInventory("SWSP_Saber"));
					if (held && ours) p.PendingWeapon = ours;
				}
			}
			// START WITH IT (sw_saber_start): every player, every map, from the first tic they are alive
			if (On() && start && p.health > 0 && !p.mo.FindInventory("SWSP_Saber"))
				p.mo.GiveInventory("SWSP_Saber", 1);
			// THE SECOND SABER, for the off hand, while the server allows it and you carry the first
			if (dual && p.mo.FindInventory("SWSP_Saber") && !p.mo.FindInventory("SWSP_SaberOff"))
				p.mo.GiveInventory("SWSP_SaberOff", 1);
			// ...AND DRAWN. Owning an OFFHANDWEAPON is not holding it: QZD only puts a weapon in the off hand
			// when it is brought up as PendingWeapon (PlayerPawn.BringUpWeapon, player.zs). With the off hand
			// empty and nothing else switching, bring ours up there.
			if (dual && p.health > 0 && p.OffhandWeapon == null && p.PendingWeapon == WP_NOCHANGE)
			{
				let off = Weapon(p.mo.FindInventory("SWSP_SaberOff"));
				if (off && !off.bTwoHanded && !(p.ReadyWeapon && p.ReadyWeapon.bTwoHanded))
				{
					off.bOffhandWeapon = true;
					p.PendingWeapon = off;
					p.mo.BringUpWeapon();
				}
			}
		}
	}
}
'''
