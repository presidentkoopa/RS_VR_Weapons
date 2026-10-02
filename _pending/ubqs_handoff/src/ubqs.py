#!/usr/bin/env python3
"""ubqs.py -- ULTRA BADASS QUESTSABER: one standalone lightsaber add-on for stock QuestZDoom 17.x.

    python ubqs.py <SW_Models_Wardusted.pk3> <saber sound folder> <out folder>

Writes UltraBadassQuestSaber.pk3. Load it AFTER SW_VR_Wardusted.pk3 or SW_VR_Xim.pk3 (or on plain Doom).
It replaces the mod's saber -- Wardust's `Lightsaber`, Xim's chainsaw-saber, and the earlier SW QuestSaber's
-- on the map and in your hands. It does not need SW_QuestSaber_<Mod>.pk3 and should not be loaded with it.

THE HILT is Wardust's saber (models/sw/saber/saber_anim.md3 in SW_Models_Wardusted.pk3), the one the owner
already plays with; the blades and every frame are built here (sw_saberplus.build_mesh, with two more frames:
T flat and lit -- the saber in the air -- and U flat and dark -- the saber lying on the floor).

WHAT IS NEW over SW QuestSaber (the owner, 10-01):
  THE THROW is a real model in the room: it spins out flat (ubqs_throw_spin), cuts and turns shots on the way,
    comes back (or drops: ubqs_throw), and a saber that stops somewhere falls, lies flat and SHUTS OFF. Fire or
    alt fire calls it back -- a Force pull: it lights, lifts and flies to your hand. Walk over it to take it.
  ALT is tap / hold by default: tap lights the second blade, hold throws.
  DEFLECT tests the swept blade (where it was last tic, between, now) against the shot's whole path, so a fast
    swing no longer lets bolts through, and sends them where you LOOK, onto the enemy in your gaze
    (ubqs_deflect_aim; or back at the shooter; or a mirror bounce off the blade).
  BLOCK: hitscan (rifles, pistols) is stopped by a lit blade facing the shooter -- always when you swing,
    ubqs_block percent of the time when you hold still -- and can go back at them as a bolt.
  BURN: a blade pushed into a wall or floor sparks and scorches it. CLASH: your two blades crossing.
  LIGHT, optimised for the Quest (ubqs_lights): every light is ONE attached light on a reused actor, moved and
    never respawned, re-attached only when its colour or radius changes. Quest (default): one per saber, and when
    your two blades are close only one. Flashes (hits, blocks, clashes) reuse one light per saber for a few tics.
    Sparks are particles -- no light at all.
  EIGHT COLOURS, five sizes, the second saber for your off hand, start with it -- all in the menu.
"""
import io
import math
import os
import sys
import wave
import zipfile

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.argv, _argv = sys.argv[:1], sys.argv          # make_sw_vrplus reads argv at import
import make_sw_vrplus as VP                         # noqa: E402  (read_md3, write_md3, saber poses, clear_png)
import sw_saberplus as SP                           # noqa: E402  (build_mesh)
sys.argv = _argv

MODELS_PK3 = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "SW_Models_Wardusted.pk3")
SND_DIR = sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, "snd")
OUT_DIR = sys.argv[3] if len(sys.argv) > 3 else os.path.join(HERE, "..", "build")
PK3 = "UltraBadassQuestSaber.pk3"

# ---- the look ------------------------------------------------------------------------------------------
SIZES = [0.70, 0.85, 1.00, 1.15, 1.30]
COLORS = [("B", "Blue", (70, 140, 255)), ("G", "Green", (60, 255, 90)), ("R", "Red", (255, 40, 35)),
          ("P", "Purple", (175, 70, 255)), ("Y", "Yellow", (255, 225, 50)), ("O", "Orange", (255, 130, 25)),
          ("C", "Cyan", (40, 235, 255)), ("W", "White", (235, 240, 255))]
HUD_SCALE = 1.608            # the HUD saber block's own (make_sw_stock build_hud)
HUD_OFFSET = (0.0, -29.0, -8.0)
WORLD_LEN = 36.0             # map units, pommel to tip, for the thrown / floor saber
BLADE_WORLD = 26.0           # map units of blade for the hit line, at size 1.00
# THE FRONT BLADE IN THE MESH at rest (frame A), off its core surface: the emitter and the tip, (md3 x, z)
EMIT = (5.111, 6.091)
TIP = (37.940, 45.216)
REST_FRAME = 0               # Wardust's saber_anim.md3: its rest pose is frame 0

# THE FRAMES: (letter, yaw, up, width, extension). SW QuestSaber's twenty, then U: flat and dark.
FRAMES = list(SP.FRAMES) + [("U", 0.0, 0.0, 1.0, 0.02)]
LET = [f[0] for f in FRAMES]
FR = {f[0]: i for i, f in enumerate(FRAMES)}
# THE TWIRL (the owner, 10-01: "have the dual bladed saber spin 360 in the player's hand"): ten more md3
# frames, the staff upright and turned about the hand's forward axis 0, 36, ... 324 degrees -- a full turn, so
# the engine's frame blending runs forward from the last back to the first. Their own sprite (V<size><col>X,
# frames A-J), because a sprite has only 26 letters and the saber's own name already uses 21.
TWIRL_STEPS = 10
TWIRL = [("tw%d" % k, 1000.0 + k * 360.0 / TWIRL_STEPS, 90.0, 1.0, 1.0) for k in range(TWIRL_STEPS)]
TW0 = len(FRAMES)                                   # the md3 frame the twirl starts at


def pose_tw(v, yaw, up):
    """VP.saber_pose, and the twirl: a yaw of 1000 + t is the staff upright, turned t degrees about +X."""
    if yaw < 999.0:
        return VP.saber_pose(v, yaw, up)
    t = math.radians(yaw - 1000.0)
    x, y, z = VP.saber_pose(v, 0.0, 90.0)
    return (x, y * math.cos(t) - z * math.sin(t), y * math.sin(t) + z * math.cos(t))


def png(img):
    b = io.BytesIO()
    img.save(b, "PNG")
    return b.getvalue()


def wav(x, sr=22050):
    x = x / (np.max(np.abs(x)) + 1e-9) * 0.9
    b = io.BytesIO()
    with wave.open(b, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((x * 32767).astype("<i2").tobytes())
    return b.getvalue()


def synth_sounds():
    """The four new sounds, synthesized (the rest are Wardust's saber set, as SW QuestSaber used)."""
    sr = 22050
    rng = np.random.default_rng(1138)

    def env(n, a, d):
        t = np.arange(n) / sr
        return np.minimum(t / a, 1.0) * np.exp(-t / d)

    def tone(f, dur, d):
        n = int(dur * sr)
        return np.sin(2 * math.pi * f * np.arange(n) / sr) * env(n, 0.002, d)

    def noise(dur, d, smooth=1):
        n = int(dur * sr)
        x = rng.standard_normal(n)
        if smooth > 1:
            x = np.convolve(x, np.ones(smooth) / smooth, "same")
        return x * env(n, 0.002, d)
    n = int(0.45 * sr)
    # CLASH: two blades -- a bright crackle over a ringing hum burst
    crack = rng.standard_normal(n) * (rng.random(n) < 0.08) * env(n, 0.001, 0.12) * 2.0
    clash = crack + 0.8 * noise(0.45, 0.08) + 0.6 * tone(140, 0.45, 0.25) + 0.4 * tone(2350, 0.45, 0.06)
    # BURN: a sizzle -- crackling high noise
    burn = noise(0.35, 0.18) - noise(0.35, 0.18, 8) + rng.standard_normal(int(0.35 * sr)) * (rng.random(int(0.35 * sr)) < 0.03)
    # CATCH: a hilt slapping into a palm
    catch = 0.9 * noise(0.12, 0.02, 6) + 0.5 * tone(220, 0.12, 0.04)
    # DROP: a metal hilt on stone -- two clinks
    clink = tone(2600, 0.25, 0.05) + 0.6 * tone(3900, 0.25, 0.03) + 0.4 * tone(5100, 0.25, 0.02)
    drop = np.concatenate([clink, 0.5 * clink[: int(0.15 * sr)]])
    # THE BLADE LOCK (Empire's end: two blades pressed together): one second of electric snarl -- a 120 Hz
    # buzz, crackling bursts and a sizzle -- made periodic (its tail crossfaded into its head) so it loops.
    n = sr
    t = np.arange(n) / sr
    buzz = np.sign(np.sin(2 * math.pi * 120 * t)) * 0.25 + np.sin(2 * math.pi * 240 * t) * 0.2
    crackle = rng.standard_normal(n) * (rng.random(n) < 0.035) * 2.5
    crackle = np.convolve(crackle, np.exp(-np.arange(60) / 8.0), "same")
    sizzle = rng.standard_normal(n)
    sizzle = sizzle - np.convolve(sizzle, np.ones(5) / 5, "same")
    am = 0.6 + 0.4 * np.abs(np.sin(2 * math.pi * 7.3 * t))
    loop = (buzz * am + crackle + 0.45 * sizzle * am)
    k = int(0.15 * sr)
    fade = np.linspace(0, 1, k)
    loop[:k] = loop[:k] * fade + loop[-k:] * (1 - fade)
    loop = loop[:n - k]
    # THE CRACK: the electric snap laid under each clash -- a hard transient, a spray of crackles, a falling buzz
    m = int(0.5 * sr)
    tt = np.arange(m) / sr
    snap = rng.standard_normal(m) * env(m, 0.0005, 0.015) * 3.0
    spray = rng.standard_normal(m) * (rng.random(m) < 0.06) * env(m, 0.001, 0.18) * 2.5
    fall = np.sign(np.sin(2 * math.pi * np.cumsum(180 - 100 * tt / 0.5) / sr)) * env(m, 0.002, 0.2) * 0.5
    crack = snap + spray + fall
    # THE FORCE PUSH: a deep pressure wave -- a sub-bass thump that swells, air rushing past, a ripple on top
    n = int(1.1 * sr)
    t = np.arange(n) / sr
    f = 70 - 35 * t / 1.1
    thump = np.sin(2 * math.pi * np.cumsum(f) / sr) * env(n, 0.03, 0.35) * 1.4
    air = rng.standard_normal(n)
    air = np.convolve(air, np.ones(30) / 30, "same") * (np.minimum(t / 0.08, 1.0) * np.exp(-t / 0.45)) * 3.0
    ripple = np.sin(2 * math.pi * 420 * t + 6 * np.sin(2 * math.pi * 9 * t)) * env(n, 0.01, 0.12) * 0.25
    push = np.tanh((thump + air + ripple) * 1.3)
    # LOCK: a short rising double tick
    lock = np.concatenate([tone(1900, 0.05, 0.02), tone(2850, 0.07, 0.03)])
    # THE FORCE PULL: the push run backwards -- air rushing IN to the hand, the thump landing at the end
    pull = np.flip(push) * np.minimum(np.arange(len(push)) / (0.6 * sr), 1.0)
    # THE GRIP: one second of choking pressure, looped -- a sub-bass throb, a tight strangled whine, grit
    n = sr
    t = np.arange(n) / sr
    throb = np.sin(2 * math.pi * 48 * t) * (0.6 + 0.4 * np.sin(2 * math.pi * 3 * t))
    whine = np.sin(2 * math.pi * (620 + 25 * np.sin(2 * math.pi * 5 * t)) * t) * 0.12
    grit = np.convolve(rng.standard_normal(n), np.ones(12) / 12, "same") * 0.9 * (0.5 + 0.5 * np.sin(2 * math.pi * 3 * t + 1))
    grip = np.tanh((throb + whine + grit) * 1.2)
    k = int(0.12 * sr)
    fade = np.linspace(0, 1, k)
    grip[:k] = grip[:k] * fade + grip[-k:] * (1 - fade)
    grip = grip[:n - k]

    # THE TRAINING REMOTE: little droid chirps, a charging rise, the sting's zap, a sad warble when hit
    def chirp(f0, f1, dur, vib=0.0):
        n = int(dur * sr)
        tt = np.arange(n) / sr
        f = f0 + (f1 - f0) * tt / dur + vib * np.sin(2 * math.pi * 30 * tt)
        return np.sin(2 * math.pi * np.cumsum(f) / sr) * env(n, 0.003, dur * 0.6)
    gap = np.zeros(int(0.03 * sr))
    beeps = [np.concatenate([chirp(1800, 2600, 0.06), gap, chirp(2400, 1500, 0.08)]),
             np.concatenate([chirp(2200, 2200, 0.04), gap, chirp(2200, 2200, 0.04), gap, chirp(3000, 2000, 0.07)]),
             np.concatenate([chirp(1400, 3200, 0.12, 300), gap, chirp(2600, 2400, 0.05)])]
    charge = chirp(900, 2900, 0.28) * 0.7
    m = int(0.16 * sr)
    tt = np.arange(m) / sr
    zap = np.sin(2 * math.pi * np.cumsum(2200 - 1700 * tt / 0.16) / sr) * env(m, 0.001, 0.07) + noise(0.16, 0.02) * 0.3
    sad = chirp(1600, 500, 0.45, 220)
    out = {"clash": wav(clash), "burn": wav(burn), "catch": wav(catch), "drop": wav(drop), "lock": wav(lock),
           "bladelock": wav(loop), "crack": wav(crack), "push": wav(push), "pull": wav(pull), "grip": wav(grip),
           "rcharge": wav(charge), "rfire": wav(zap), "rsad": wav(sad)}
    for i, b in enumerate(beeps):
        out["rbeep%d" % (i + 1)] = wav(b)
    return out


def burn_png():
    """The scorch a blade leaves: a dark ragged smear (DECALDEF shades it)."""
    im = Image.new("L", (32, 32), 0)
    d = ImageDraw.Draw(im)
    d.ellipse((8, 4, 24, 28), fill=255)
    im = im.filter(ImageFilter.GaussianBlur(3))
    return png(im.convert("RGB"))


def lock_pngs():
    """THE LOCK MARK: a glowing diamond, four frames of a slow pulse (drawn additive, fullbright)."""
    out = {}
    for i, L in enumerate("ABCD"):
        k = 0.75 + 0.25 * math.sin(i * math.pi / 2)
        im = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        pts = [(24, 3), (45, 24), (24, 45), (3, 24)]
        col = (int(255 * k), int(210 * k), int(80 * k), 255)
        d.polygon(pts, outline=col, width=4)
        d.polygon([(24, 16), (32, 24), (24, 32), (16, 24)], fill=(int(255 * k), int(240 * k), int(200 * k), 255))
        im = im.filter(ImageFilter.GaussianBlur(0.8))
        b = io.BytesIO()
        im.save(b, "PNG")
        out[L] = b.getvalue()
    return out


def flash_png():
    """THE CLASH FLASH: a white-hot core, eight long spikes and a soft glow -- drawn additive."""
    W = 128
    y, x = np.mgrid[0:W, 0:W] - (W - 1) / 2.0
    r = np.hypot(x, y) / (W / 2.0)
    a = np.arctan2(y, x)
    core = np.exp(-(r / 0.10) ** 2)
    glow = np.exp(-(r / 0.38) ** 2) * 0.45
    spikes = (np.abs(np.cos(4 * a)) ** 40) * np.exp(-r / 0.35) * 0.9
    spikes2 = (np.abs(np.cos(4 * a + math.pi / 4)) ** 60) * np.exp(-r / 0.2) * 0.5
    v = np.clip(core + glow + spikes + spikes2, 0, 1)
    rgb = np.dstack([v, v * 0.97, v * 0.9 + 0.1 * glow])
    img = Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8), "RGB")
    b = io.BytesIO()
    img.save(b, "PNG")
    return b.getvalue()


# ---- COMBATFX: the owner's own effect sprites (E:\DOOMWork\_old\RS_Main\Sprites\CombatFX, asked for by name,
# 10-01: "use ... CombatFX to spice up this saber. no engine-generated particles"). Copied into cfx/ here.
CFX_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cfx")
# (our sprite, [(source, frame letter)], mode, max size): mode "add" keeps the colour (drawn additive);
# "shade" makes it a grey mask the script tints (AddShaded: the blade's colour)
CFX = [
    ("UXSP", [("sparks/RSS3%s0.lmp" % c, c) for c in "ABCDEF"] + [("sparks/RSS3G0.png", "G")], "add", 190),
    ("UXST", [("blast/JSPKA0", "A")], "add", 128),
    ("UXLT", [("lightning/RSL2%s0.png" % c, L) for c, L in zip("GHIJ", "ABCD")], "add", 64),
    ("UXHF", [("hitflash/RSH0%s0.png" % c, L) for c, L in zip("ACEGIKMOQS", "ABCDEFGHIJ")], "shade", 96),
    ("UXRG", [("flares/RSF7%s0.png" % c, L) for c, L in zip("ABCDEFGHIJKLMNPQR", "ABCDEFGHIJKLMNOPQ")], "shade", 205),
    ("UXPL", [("plasma/RSP5%s0.png" % c, c) for c in "ABCDEF"], "add", 56),
    ("UXGL", [("flares/RSF4A0", "A")], "shade", 64),
    ("UXEM", [("trails/RST1A0.png", "A")], "add", 64),
    ("UXRE", [("flares/RSF8R0.png", "A")], "add", 128),
]


def cfx_load(path):
    import struct
    b = open(os.path.join(CFX_DIR, path), "rb").read()
    if b[:4] == b"\x89PNG":
        return Image.open(io.BytesIO(b)).convert("RGBA")
    pal = open(os.path.join(CFX_DIR, "PLAYPAL"), "rb").read()
    wd, ht, _, _ = struct.unpack("<HHhh", b[:8])
    im = np.zeros((ht, wd, 4), np.uint8)
    for x in range(wd):
        q = struct.unpack("<I", b[8 + 4 * x:12 + 4 * x])[0]
        last = -1
        while q + 1 < len(b) and b[q] != 255:             # (RSF7O0 is cut short: read what is there)
            top, ln = b[q], b[q + 1]
            if ht > 254 and top <= last:                  # a tall patch: the post's top is relative
                top += last
            last = top
            for k in range(ln):
                if top + k >= ht or q + 3 + k >= len(b):
                    break
                c = b[q + 3 + k]
                im[top + k, x, :3] = list(pal[c * 3:c * 3 + 3])
                im[top + k, x, 3] = 255
            q += ln + 4
    return Image.fromarray(im)


def cfx_sprites():
    """Every CombatFX frame as our own sprite lump: centred (grAb at the middle -- an effect sits ON its spot),
    shrunk to what a Quest needs, and for "shade" ones turned into a grey mask the script colours."""
    from PIL import PngImagePlugin
    import struct
    out = {}
    for spr, frames, mode, mx in CFX:
        for src, L in frames:
            im = cfx_load(src)
            if max(im.size) > mx:
                im.thumbnail((mx, mx), Image.LANCZOS)
            a = np.asarray(im, float) / 255.0
            if mode == "shade":
                g = (a[..., :3].max(axis=2) * a[..., 3])
                g = np.clip(g / max(g.max(), 1e-6), 0, 1)
                rgb = np.dstack([g, g, g])
                alpha = np.ones_like(g)
            else:
                rgb = a[..., :3] * a[..., 3:4]                # additive: black is nothing
                alpha = np.ones(a.shape[:2])
            arr = np.dstack([rgb, alpha])
            img = Image.fromarray((np.clip(arr, 0, 1) * 255).astype(np.uint8), "RGBA").convert("RGB")
            info = PngImagePlugin.PngInfo()
            info.add(b"grAb", struct.pack(">ii", img.size[0] // 2, img.size[1] // 2))
            bio = io.BytesIO()
            img.save(bio, "PNG", pnginfo=info)
            out["sprites/ubqs/%s%s0.png" % (spr, L)] = bio.getvalue()
    return out


# ---- THE BEAM'S GLOW SHELL (the owner, 10-01: "can the tube itself not give off an emissive glow? something
# soft and bloomy?"). QuestZDoom runs no bloom on the headset and cannot draw the HUD saber additive, so the
# glow is its own model in the world: N planes crossed about the beam's axis (model +Z, 0..64 units, 1 unit
# either side), drawn ADDITIVE and fullbright by UBQS_BeamGlow, which lays it along the beam every tic. The
# texture is the light: a hot white core across the width falling off soft to nothing, soft at both ends.
GLOW_Q = (2, 3, 4, 6)          # planes per quality step
import volglow as VG               # noqa: E402  (the volumetric capsule glow: shells agent)
import vgsplit as VGS              # noqa: E402  (its core / halo split)
import vgface as VGF               # noqa: E402  (build 51: the smooth, viewer-facing shells that replace it)
VG_TIERS = ("low", "med", "high", "ultra")


def beamglow_md3(nplanes):
    tris, st, verts = [], [], []
    for k in range(nplanes):
        a = math.pi * k / nplanes
        c, sn = math.cos(a), math.sin(a)
        base = len(verts)
        for (x, y, z, u, t) in ((-c, -sn, 0.0, 0.0, 1.0), (c, sn, 0.0, 1.0, 1.0),
                                (-c, -sn, 64.0, 0.0, 0.0), (c, sn, 64.0, 1.0, 0.0)):
            verts.append((x, y, z))
            st.append((u, t))
        # both faces: an additive shell has no back
        tris += [(base, base + 1, base + 2), (base + 1, base + 3, base + 2),
                 (base, base + 2, base + 1), (base + 1, base + 2, base + 3)]
    norms = [(0.0, 0.0, 1.0)] * len(verts)
    return VP.write_md3("beamglow", [{"name": "glow", "shader": "beamglow.png", "tris": tris, "st": st,
                                      "frames": [(verts, norms)]}], 1)


def beamglow_png(rgb):
    W, H = 32, 128
    x = (np.arange(W) + 0.5) / W * 2.0 - 1.0                  # -1..1 across
    v = 1.0 - (np.arange(H) + 0.5) / H                         # 0 at the base (bottom row), 1 at the tip
    across = np.exp(-(x / 0.22) ** 2) * 1.0 + np.exp(-(x / 0.55) ** 2) * 0.45
    across *= np.clip(1.0 - x * x, 0, 1)
    ends = np.clip(v / 0.10, 0, 1) * np.clip((1.0 - v) / 0.18, 0, 1)
    ends = ends * ends * (3 - 2 * ends)
    g = np.clip(np.outer(ends, across), 0, 1)                  # H x W
    col = np.array(rgb, float) / 255.0
    core = np.clip(np.outer(ends, np.exp(-(x / 0.16) ** 2)), 0, 1)[..., None]
    c = col * (1 - core * 0.7) + core * 0.7                    # white-hot in the middle, the colour round it
    img = np.clip(g[..., None] * c, 0, 1)
    # THE DARK EDGE IS NOT THERE (the owner, 10-01: black lines round the blades). A held model is drawn with
    # an alpha test (hw_weapon.cpp: gl_mask_threshold) and writes depth where it draws: so the near-black rim of
    # each strip, opaque, blacked out whatever was drawn after it. Where the glow is that faint it is now fully
    # transparent -- skipped, no depth -- and only light that is really there is drawn.
    alpha = (img.max(axis=2) > 0.06).astype(float)
    rgba = np.dstack([img, alpha])
    return png(Image.fromarray((rgba * 255).astype(np.uint8), "RGBA"))


# ---- THE GLOW IN THE HAND (the owner, 10-01: "this effect is amazing ... but it lags"). A world actor moves
# 35 times a second; the saber in your hand is drawn every frame from the controller. So the glow is drawn
# THE SAME WAY: a second HUD layer of the saber (UBQS_SaberBase.A_UBShow puts it up), its own model -- this
# shell, baked onto the blade for every frame of the saber's mesh -- and that layer drawn ADDITIVE. Same
# transform, same frame, same instant as the blade: it cannot lag.
GLOW_HALF = 2.2       # mesh units either side of the beam (about 3.5 cm at size 1)
GLOW_DOWN = 1.5       # mesh units the glow starts below the emitter, into the hilt's mouth
GLOW_PLANES = 3


def glow_md3(md3):
    """The shell, frame by frame on the saber's own front blade (its core surface) and, as a second surface, on
    the back blade (the front through the hilt's centre)."""
    import struct as _st
    data = md3
    nsurf, o_surf = _st.unpack("<i", data[84:88])[0], _st.unpack("<i", data[100:104])[0]
    off, core = o_surf, None
    for _ in range(nsurf):
        f = _st.unpack("<4s64s10i", data[off:off + 108])
        sname, snf, nv, o_xyz, o_send = f[1].rstrip(b"\0").decode("latin1"), f[3], f[5], f[10], f[11]
        if sname.startswith("front5"):
            core = []
            for fr in range(snf):
                b0 = off + o_xyz + fr * nv * 8
                core.append(np.array([_st.unpack("<3h", data[b0 + 8 * i:b0 + 8 * i + 6]) for i in range(nv)], float) / 64.0)
        off += o_send
    assert core is not None
    nfr = len(core)

    def shell(sign):
        tris, st = [], []
        for k in range(GLOW_PLANES):
            b = 4 * k
            st += [(0.0, 1.0), (1.0, 1.0), (0.0, 0.0), (1.0, 0.0)]
            tris += [(b, b + 1, b + 2), (b + 1, b + 3, b + 2), (b, b + 2, b + 1), (b + 1, b + 2, b + 3)]
        frames = []
        for V in core:
            c = V.mean(axis=0)
            _, _, vt = np.linalg.svd(V - c)
            ax = vt[0]
            t = (V - c) @ ax
            p0, p1 = c + ax * t.min(), c + ax * t.max()
            if np.linalg.norm(p0) > np.linalg.norm(p1):
                p0, p1 = p1, p0
            L = np.linalg.norm(p1 - p0)
            verts = []
            if L < 0.5:
                verts = [tuple(p0 * sign)] * (4 * GLOW_PLANES)
            else:
                a = (p1 - p0) / L
                u = np.cross(a, [0.0, 1.0, 0.0])
                if np.linalg.norm(u) < 0.1:
                    u = np.cross(a, [1.0, 0.0, 0.0])
                u /= np.linalg.norm(u)
                v = np.cross(a, u)
                q0 = p0 - a * GLOW_DOWN
                for k in range(GLOW_PLANES):
                    ang = math.pi * k / GLOW_PLANES
                    d = (u * math.cos(ang) + v * math.sin(ang)) * GLOW_HALF
                    for pt in (q0 - d, q0 + d, p1 - d, p1 + d):
                        verts.append(tuple(pt * sign))
            frames.append((verts, [(0.0, 0.0, 1.0)] * len(verts)))
        return {"name": "glowF" if sign > 0 else "glowB", "shader": "beamglow.png", "tris": tris, "st": st,
                "frames": frames}
    return VP.write_md3("ubqs_glow", [shell(1.0), shell(-1.0)], nfr)


# ---- THE EMITTER STUB (build 50 -- the owner: "this effect is so good we can get rid of the tube itself, if we
# could only lock down the beam out of the hilt"). With the tube off, the hand layer keeps a short piece of the
# blade -- its own three surfaces (white core, inner, colour), cut off STUB world units above the emitter, frame
# by frame -- drawn from the controller with the hilt, so the beam visibly leaves the hilt with zero lag. Opaque
# textures only (the hand layer is alpha-tested and occludes world FX): it stays as thin as the tube was.
STUB_LENS = (2, 4, 6)          # world units at size 1 (ubqs_glow_stub picks the nearest; 0 = none)
STUB_MESH_PER_WORLD = 1.0 / (HUD_SCALE * 0.34)   # mesh units per world unit (vr_weaponScale 1, 34 units/m)
# BUILD 51 (the owner's headset shot: "the stub is a thin white stick, narrower than the glow core"): the stub's
# white core and pale inner layer are widened round the beam's axis so its outside (0.171 -> 0.33 world units at
# size 1) matches the new glow's white core (vgface.py: white out to ~0.33), and the core visibly runs on out of it.
STUB_WIDEN = 0.33 / 0.171


def stub_md3(md3, length_world):
    """The saber's hilt (surfaces 0-4) and, unless length_world is 0, its six blade surfaces (front5-7, back5-7)
    with each blade's vertices beyond length_world of its emitter pulled back onto that length, per frame
    (ignition / unlit frames keep their own shorter blade). ONE model, so it cannot come apart from the hilt
    (a second model in the block did: GZDoom posed the hilt by another frame)."""
    surfs = VP.read_md3(md3)
    by = {sf["name"]: sf for sf in surfs}
    out = [dict(sf) for sf in surfs[:5]]
    if length_world > 0:
        L = length_world * STUB_MESH_PER_WORLD
        for side in ("front", "back"):
            core = [np.array(v, float) for v, _ in by[side + "5"]["frames"]]
            for k in (5, 6, 7):
                sf = by["%s%d" % (side, k)]
                nfr = []
                for fi, (verts, norms) in enumerate(sf["frames"]):
                    C = core[fi]
                    c = C.mean(axis=0)
                    _, _, vt = np.linalg.svd(C - c)
                    ax = vt[0]
                    tt = (C - c) @ ax
                    p0, p1 = c + ax * tt.min(), c + ax * tt.max()
                    if np.linalg.norm(p0) > np.linalg.norm(p1):      # the emitter end is the one nearer the hilt
                        ax = -ax
                        p0, p1 = p1, p0
                    V = np.array(verts, float)
                    along = (V - p0) @ ax
                    V = p0 + np.outer(along, ax) + (V - p0 - np.outer(along, ax)) * STUB_WIDEN
                    over = np.clip((V - p0) @ ax - L, 0, None)
                    W = V - np.outer(over, ax)
                    nfr.append(([tuple(v) for v in W], norms))
                out.append(dict(sf, name="stub%s%d" % (side[0], k), frames=nfr))
    return VP.write_md3("ubqs_stub", out, len(out[0]["frames"]))


REMOTE_DIR = os.path.join(HERE, "remote")
REMOTE_MD3 = REMOTE_DIR + "/thermal_wm.md3"


def remote_textures():
    """The remote's skins at 512 (Quest): the thermal's plating in cool bare steel; the lit one with the lamp
    band (where the thermal's lit skin differs from its plain one) burning red; and that band as brightmap."""
    base = Image.open(REMOTE_DIR + "/thermal.png").convert("RGB").resize((512, 512), Image.LANCZOS)
    lit = Image.open(REMOTE_DIR + "/thermal_lit.png").convert("RGB").resize((512, 512), Image.LANCZOS)
    b = np.asarray(base, float) / 255.0
    l = np.asarray(lit, float) / 255.0
    g = b.mean(axis=2, keepdims=True)
    g = np.clip((g - 0.5) * 1.15 + 0.5, 0, 1)
    steel = np.clip(g * np.array([0.92, 0.96, 1.04]), 0, 1)
    diff = np.abs(l - b).sum(axis=2)
    hot = l[..., 0] - l[..., 2]                          # the thermal's lamps burn orange: red well over blue
    band = (np.clip((diff - 0.35) * 3.0, 0, 1) * np.clip((hot - 0.35) * 3.0, 0, 1))[..., None]
    red = np.array([1.0, 0.12, 0.06]) * (0.55 + 0.45 * l.max(axis=2, keepdims=True))
    litimg = steel * (1 - band) + red * band
    bm = np.repeat(band, 3, axis=2)
    out = []
    for a in (steel, litimg, bm):
        out.append(png(Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), "RGB")))
    return out


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    z = zipfile.ZipFile(MODELS_PK3)
    files = {}
    folder = "models/ubqs"

    # ---- THE MESH ----------------------------------------------------------------------------------------
    SP.FRAMES = FRAMES + TWIRL                          # build_mesh reads its module's FRAMES
    old = VP.read_md3(z.read("models/sw/saber/saber_anim.md3"))
    md3, nsurf, full_len = SP.build_mesh(old, REST_FRAME, (pose_tw, VP.saber_unpose), VP.write_md3)
    files[folder + "/ubqs_saber.md3"] = md3
    files[folder + "/ubqs_glow.md3"] = glow_md3(md3)
    for sl in (0,) + STUB_LENS:
        files[folder + "/ubqs_stub%d.md3" % sl] = stub_md3(md3, sl)
    files[folder + "/saber.jpg"] = z.read("models/sw/saber/saber.jpg")
    files[folder + "/clear.png"] = VP.clear_png()
    white = png(Image.new("RGB", (8, 8), (255, 255, 255)))
    files[folder + "/blade_core.png"] = white
    files[folder + "/blade_bm.png"] = white
    for tag, name, (r, g, b) in COLORS:
        inner = tuple(int(255 * 0.72 + ch * 0.28) for ch in (r, g, b))
        files[folder + "/blade_inner_%s.png" % tag] = png(Image.new("RGB", (8, 8), inner))
        files[folder + "/blade_mid_%s.png" % tag] = png(Image.new("RGB", (8, 8), (r, g, b)))
    world_scale = WORLD_LEN / full_len

    def skins(tag, double):
        sk = [(i, "saber.jpg") for i in range(5)]
        sk += [(5, "blade_core.png"), (6, "blade_inner_%s.png" % tag), (7, "blade_mid_%s.png" % tag)]
        if double:
            sk += [(8, "blade_core.png"), (9, "blade_inner_%s.png" % tag), (10, "blade_mid_%s.png" % tag)]
        else:
            sk += [(8, "clear.png"), (9, "clear.png"), (10, "clear.png")]
        return sk

    sprites = set()
    md = ["// " + "=" * 100,
          "// ULTRA BADASS QUESTSABER -- GENERATED by ubqs.py. Stock QuestZDoom MODELDEF keys only.",
          "// A block per size x colour x one/two blades: MODELDEF cannot read a cvar, a sprite name can be chosen",
          "// per tic (UBQS_SaberBase.SpriteNow).",
          "// " + "=" * 100, ""]
    variants = [("S%d%s%s" % (si + 1, c[0], "D" if dbl else "S"), s, c[0], dbl)
                for si, s in enumerate(SIZES) for c in COLORS for dbl in (False, True)]
    variants.append(("UBSP", 1.0, "B", False))         # the name the states carry before A_UBShow picks
    for cls in ("UBQS_Saber", "UBQS_SaberOff"):
        for spr, s, tag, dbl in variants:
            sc = HUD_SCALE * s
            md += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "ubqs_saber.md3"']
            md += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins(tag, dbl)]
            md += ["\tScale %.3f %.3f %.3f" % (-sc, sc, sc), "\tOffset %.1f %.1f %.1f" % HUD_OFFSET, ""]
            md += ["\tFrameIndex %s %s 0 %d" % (spr, L, i) for i, L in enumerate(LET)]
            md += ["}", ""]
    for spr, _, _, _ in variants:
        sprites |= {(spr, L) for L in LET}
    # TUBE OFF (ubqs_blade_tube 0, the default): the blade surfaces skinned clear (alpha 0: alpha-tested away,
    # no depth, nothing occluded) -- here simply left out of the model -- the hilt kept, the emitter stub added.
    # Prefix K: no stub; L / M / N: the 2 / 4 / 6 unit stub (UBQS_SaberBase.SpriteNow picks).
    def stub_skins(tag, double):
        # the white core and the pale inner layer only (the opaque colour layer would hide the white): white-hot,
        # tinted at the rim, as thin as the tube's inner layer
        sk = [(i, "saber.jpg") for i in range(5)]
        sk += [(5, "blade_core.png"), (6, "blade_inner_%s.png" % tag), (7, "clear.png")]
        sk += [(8, "blade_core.png"), (9, "blade_inner_%s.png" % tag), (10, "clear.png")] if double \
            else [(8, "clear.png"), (9, "clear.png"), (10, "clear.png")]
        return sk
    for cls in ("UBQS_Saber", "UBQS_SaberOff"):
        for pre, sl in (("K", 0), ("L", 2), ("M", 4), ("N", 6)):
            for si, s_ in enumerate(SIZES):
                for c in COLORS:
                    for dbl in (False, True):
                        spr = "%s%d%s%s" % (pre, si + 1, c[0], "D" if dbl else "S")
                        sc = HUD_SCALE * s_
                        md += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "ubqs_stub%d.md3"' % sl]
                        md += ['\tSurfaceSkin 0 %d "%s"' % x for x in stub_skins(c[0], dbl)[:5 if sl == 0 else 11]]
                        md += ["\tScale %.3f %.3f %.3f" % (-sc, sc, sc), "\tOffset %.1f %.1f %.1f" % HUD_OFFSET, ""]
                        md += ["\tFrameIndex %s %s 0 %d" % (spr, L, i) for i, L in enumerate(LET)]
                        md += ["}", ""]
                        sprites |= {(spr, L) for L in LET}
    tw_letters = "ABCDEFGHIJ"[:TWIRL_STEPS]
    for cls in ("UBQS_Saber", "UBQS_SaberOff"):
        for si, s_ in enumerate(SIZES):
            for c in COLORS:
                spr = "V%d%sX" % (si + 1, c[0])
                sc = HUD_SCALE * s_
                md += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "ubqs_saber.md3"']
                md += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins(c[0], True)]
                md += ["\tScale %.3f %.3f %.3f" % (-sc, sc, sc), "\tOffset %.1f %.1f %.1f" % HUD_OFFSET, ""]
                md += ["\tFrameIndex %s %s 0 %d" % (spr, L, TW0 + k) for k, L in enumerate(tw_letters)]
                md += ["}", ""]
                sprites |= {(spr, L) for L in tw_letters}
    # THE SABER OUT OF THE HAND: flat, lit (A) or dark (B), turned by the actor's own angle and pitch
    for tag, _, _ in COLORS:
        for dbl in (False, True):
            spr = "U%s%sT" % (tag, "D" if dbl else "S")
            md += ["Model UBQS_Thrown", "{", '\tPath "%s"' % folder, '\tModel 0 "ubqs_saber.md3"']
            md += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins(tag, dbl)]
            md += ["\tScale %.3f %.3f %.3f" % ((world_scale,) * 3), "\tZOffset 1.5", "\tUSEACTORPITCH",
                   "\tUSEACTORROLL", "", "\tFrameIndex %s A 0 %d" % (spr, FR["T"]),
                   "\tFrameIndex %s B 0 %d" % (spr, FR["U"]), "}", ""]
            sprites |= {(spr, "A"), (spr, "B")}
    sprites.add(("UBST", "A"))
    # THE SABER LYING ON THE MAP: dark, hovering, turning slowly
    for cls in ("UBQS_Saber", "UBQS_SaberOff"):
        md += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "ubqs_saber.md3"']
        md += ['\tSurfaceSkin 0 %d "%s"' % x for x in skins("B", False)]
        md += ["\tScale %.3f %.3f %.3f" % ((world_scale,) * 3), "\tZOffset 10", "\tROTATING",
               "\tRotation-Speed 3", "", "\tFrameIndex UBPK A 0 %d" % FR["U"], "}", ""]
    sprites |= {("UBPK", "A"), ("UBQL", "A")}
    # THE TRAINING REMOTE: the thermal detonator's shell (RS_StarWars, tools/make_thermal.py), reskinned bare
    # steel; its lamp band burns red as it charges (B). 15.1 units across in the mesh -> 7 map units (20 cm).
    files[folder + "/remote.md3"] = open(REMOTE_MD3, "rb").read()
    rtex, rlit, rbm = remote_textures()
    files[folder + "/remote.png"], files[folder + "/remote_lit.png"], files[folder + "/remote_bm.png"] = rtex, rlit, rbm
    md += ["Model UBQS_Remote", "{", '\tPath "%s"' % folder, '\tModel 0 "remote.md3"', '\tSkin 0 "remote.png"',
           '\tModel 1 "remote.md3"', '\tSkin 1 "remote_lit.png"', "\tScale 0.46 0.46 0.46", "\tZOffset 4",
           "\tFrameIndex UBRM A 0 0", "\tFrameIndex UBRM B 1 0", "}", ""]
    sprites |= {("UBRM", "A"), ("UBRM", "B")}
    # THE GLOW LAYER'S BLOCKS: the saber's own HUD numbers, the shell's skin in the chosen glow colour
    for cls in ("UBQS_Saber", "UBQS_SaberOff"):
        for si, s_ in enumerate(SIZES):
            for c in COLORS:
                for dbl in (False, True):
                    spr = "G%d%s%s" % (si + 1, c[0], "D" if dbl else "S")
                    sc = HUD_SCALE * s_
                    md += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "ubqs_glow.md3"',
                           '\tSurfaceSkin 0 0 "beamglow_%s.png"' % c[0],
                           '\tSurfaceSkin 0 1 "%s"' % ("beamglow_%s.png" % c[0] if dbl else "clear.png"),
                           "\tScale %.3f %.3f %.3f" % (-sc, sc, sc), "\tOffset %.1f %.1f %.1f" % HUD_OFFSET, ""]
                    md += ["\tFrameIndex %s %s 0 %d" % (spr, L, i) for i, L in enumerate(LET)]
                    md += ["}", ""]
                    sprites |= {(spr, L) for L in LET}
    for i, (tag, _, rgbc) in enumerate(COLORS):
        files[folder + "/beamglow_%s.png" % tag] = beamglow_png(rgbc)   # (the unused hand-layer glow blocks' skin)
    # THE WORLD GLOW: the shells agent's VOLUMETRIC capsules (volglow.py) -- nested closed additive capsules,
    # a radial staircase of the target profile from any angle, the hilt fade in fixed units. One actor per
    # blade (UBQS_BeamGlow), model +Z = the blade, z 0 = the emitter, built for a 26-unit blade: Scale.Y =
    # length / 26, Scale.X = the radius. ubqs_glow_quality 1-4 -> low / med / high / ultra = sprites UBV1-4,
    # frame = colour.
    # SPLIT IN TWO (vgsplit.py) so the motion fade can take the white CORE away in a fast swing and leave the
    # coloured HALO round the zero-lag hand-layer tube: sprites UBC1-4 (core) and UBH1-4 (halo), frame = colour.
    assert [c[0] for c in VG.COLORS] == [c[0] for c in COLORS]
    for k, tier in enumerate(VG_TIERS):
        for part, letter in (("core", "C"), ("halo", "H")):
            files[folder + "/vg%s_%s.md3" % (part, tier)] = VGF.part_md3(tier, part)
            spr = "UB%s%d" % (letter, k + 1)
            # ONE BLOCK PER COLOUR: a block draws EVERY model it lists on every frame
            for i, (tag, _, rgbc) in enumerate(COLORS):
                files[folder + "/vg%s_%s_%s.png" % (part, tier, tag)] = VGF.part_png(rgbc, tier, part)
                # (build 51: + USEACTORROLL -- UBQS_BeamGlow.Place rolls the shells to face the eye, vgface.py)
                md += ["Model UBQS_BeamGlow", "{", '\tPath "%s"' % folder, '\tModel 0 "vg%s_%s.md3"' % (part, tier),
                       '\tSkin 0 "vg%s_%s_%s.png"' % (part, tier, tag), "\tScale 1.0 1.0 1.0", "\tUSEACTORPITCH",
                       "\tUSEACTORROLL",
                       "\tFrameIndex %s %s 0 0" % (spr, chr(ord("A") + i)), "}", ""]
            sprites |= {(spr, chr(ord("A") + i)) for i in range(len(COLORS))}
    # THE BARE FORCE HAND: Ermac's hand (Rusted Legacy; ../hand/CREDIT.txt), on Ermac's own HUD numbers.
    # A relaxed, B fist (gripping), C open (reaching with the Force).
    hand_dir = os.path.join(os.path.dirname(HERE), "hand")
    files[folder + "/ermac_hand.md3"] = open(os.path.join(hand_dir, "ermac_hand.md3"), "rb").read()
    files[folder + "/ermac_hand.png"] = open(os.path.join(hand_dir, "ermac_hand.png"), "rb").read()
    md += ["Model UBQS_ForceHand", "{", '\tPath "%s"' % folder, '\tModel 0 "ermac_hand.md3"',
           '\tSkin 0 "ermac_hand.png"', "\tScale -1.0 1.0 1.0", "\tOffset 0.0 -24.0 -10.0",
           "\tFrameIndex UBFH A 0 0", "\tFrameIndex UBFH B 0 1", "\tFrameIndex UBFH C 0 3", "}", ""]
    sprites |= {("UBFH", "A"), ("UBFH", "B"), ("UBFH", "C")}
    lock_frames = lock_pngs()
    files["MODELDEF"] = "\n".join(md).encode()
    clear = VP.clear_png()
    for spr, L in sprites:
        files["sprites/ubqs/%s%s0.png" % (spr, L)] = clear
    files["sprites/ubqs/UBCFA0.png"] = flash_png()
    files.update(cfx_sprites())
    for L, data in lock_frames.items():
        files["sprites/ubqs/UBLK%s0.png" % L] = data

    # ---- GLDEFS: the blade is light, not paint ------------------------------------------------------------
    gl = ["// ULTRA BADASS QUESTSABER -- the blade's skins are fullbright. Its LIGHTS are not here: they are",
          "// attached by script (UBQS_Light.Look), any colour, any radius, no table.", ""]
    for sk in ["blade_core.png"] + ["blade_%s_%s.png" % (k, c[0]) for c in COLORS for k in ("inner", "mid")]:
        gl += ['brightmap texture "%s/%s"' % (folder, sk), "{", '\tmap "%s/blade_bm.png"' % folder, "}", ""]
    for tag, _, _ in COLORS:
        gl += ['brightmap texture "%s/beamglow_%s.png"' % (folder, tag), "{", '\tmap "%s/blade_bm.png"' % folder, "}", ""]
    gl += ['brightmap texture "%s/remote_lit.png"' % folder, "{", '\tmap "%s/remote_bm.png"' % folder, "}", ""]
    files["GLDEFS"] = "\n".join(gl).encode()

    # ---- DECALDEF: the scorch --------------------------------------------------------------------------------
    files["graphics/UBQSBURN.png"] = burn_png()
    files["DECALDEF"] = (b'decal UBQS_Burn\n{\n\tpic UBQSBURN\n\tshade "10 06 02"\n\tx-scale 0.22\n'
                         b'\ty-scale 0.32\n\trandomflipx\n\trandomflipy\n}\n')

    # ---- SOUNDS ------------------------------------------------------------------------------------------------
    for fn in sorted(os.listdir(SND_DIR)):
        files["sounds/ubqs/" + fn] = open(os.path.join(SND_DIR, fn), "rb").read()
    for k, v in synth_sounds().items():
        files["sounds/ubqs/ubqs_%s.wav" % k] = v
    snd = ["// ULTRA BADASS QUESTSABER -- Wardust's saber set, and four synthesized (clash, burn, catch, drop).",
           "ubqs/on       sounds/ubqs/dssabreu.wav", "ubqs/off      sounds/ubqs/dssabreu.wav", "$volume ubqs/off 0.6",
           "ubqs/hum      sounds/ubqs/dssabrei.wav", "ubqs/deflect  sounds/ubqs/dssawhit.wav"]
    snd += ["ubqs/swing%d  sounds/ubqs/dssabre%d.mp3" % (n, n) for n in range(1, 6)]
    snd.append("$random ubqs/swing { ubqs/swing1 ubqs/swing2 ubqs/swing3 ubqs/swing4 ubqs/swing5 }")
    for n in range(1, 4):
        snd += ["ubqs/hit%d    sounds/ubqs/lsabhit%d.mp3" % (n, n), "ubqs/wall%d   sounds/ubqs/lsabhtw%d.mp3" % (n, n)]
    snd += ["$random ubqs/hit { ubqs/hit1 ubqs/hit2 ubqs/hit3 }", "$random ubqs/wall { ubqs/wall1 ubqs/wall2 ubqs/wall3 }"]
    snd += ["ubqs/%s  sounds/ubqs/ubqs_%s.wav" % (k, k) for k in ("burn", "drop", "lock", "bladelock", "crack", "push",
                                                                  "pull", "grip", "rcharge", "rfire", "rsad",
                                                                  "rbeep1", "rbeep2", "rbeep3")]
    snd += ["$random ubqs/rbeep { ubqs/rbeep1 ubqs/rbeep2 ubqs/rbeep3 }", "$volume ubqs/grip 0.7"]
    # THE CLASH: Jedi Academy's own blade-on-blade hits (Wardust ships them as LSABHIT), with the electric crack
    # laid under them by the script; the spin of a thrown saber, and the catch, are Jedi Academy's too
    snd += ["ubqs/clash%d  sounds/ubqs/lsabhit%d.mp3" % (n, n) for n in range(1, 5)]
    snd.append("$random ubqs/clash { ubqs/clash1 ubqs/clash2 ubqs/clash3 ubqs/clash4 }")
    snd += ["ubqs/spin%d  sounds/ubqs/sbrspn%d.wav" % (n, n) for n in range(5)]
    snd.append("$random ubqs/spin { ubqs/spin0 ubqs/spin1 ubqs/spin2 ubqs/spin3 ubqs/spin4 }")
    snd += ["ubqs/catch  sounds/ubqs/sabrcth.mp3", "$volume ubqs/bladelock 0.9", "$limit ubqs/clash 3"]
    snd += ["$limit ubqs/burn 2", "$limit ubqs/swing 3", "$volume ubqs/burn 0.6"]
    files["SNDINFO"] = ("\n".join(snd) + "\n").encode()

    # ---- SETTINGS ------------------------------------------------------------------------------------------------
    files["CVARINFO"] = "\n".join([
        "// ULTRA BADASS QUESTSABER. Your look and your alt fire are yours (userinfo: every machine sees your",
        "// choice); what it does to the game is the server's.",
        "user float   ubqs_size          = 1.0;",
        "user int     ubqs_color         = 0;",
        "user int     ubqs_color_off     = 2;",
        "user int     ubqs_alt           = 1;",
        "user int     ubqs_deflect_aim   = 1;",
        "user int     ubqs_throw         = 0;",
        "user float   ubqs_throw_spin    = 14.0;",
        "user int     ubqs_throw_plane   = 0;",
        "user int     ubqs_throw_double  = 1;",
        "user float   ubqs_throw_min     = 1.5;",
        "user float   ubqs_contact       = 3.5;",
        "user float   ubqs_blade_glow    = 0.6;",
        "user float   ubqs_glow_width    = 1.2;",
        "user int     ubqs_blade_glow_color = -1;",
        "user float   ubqs_blade_glow_height = 0.0;",
        "user int     ubqs_glow_quality  = 3;      // world glow: 1 low, 2 med, 3 high, 4 ultra",
        "user bool    ubqs_glow_predict  = true;   // the world glow placed ahead (motion prediction)",
        "user float   ubqs_glow_lead     = 1.0;     // how much of its lag to lead (1 = all; 0-2) -- b50: 1.0 (sim_real.py)",
        "user int     ubqs_glow_dots     = 0;      // the old soft dots inside the glow shell",
        "user int     ubqs_glow_motionfade = 1;    // fast swings: the white core fades, the halo widens",
        "user bool    ubqs_blade_tube    = false;  // the solid blade tube in the hand (off: the glow is the blade)",
        "user float   ubqs_glow_stub     = 4.0;    // with the tube off: the hand's emitter stub, units (0, 2, 4, 6)",
        "user float   ubqs_contact_hilt  = 0.75;",
        "user int     ubqs_diag          = 0;   // 1 blade-line dots, 2 glow telemetry (log + overlay)",
        "user int     ubqs_trail         = 1;",
        "user int     ubqs_locks         = 5;",
        "user float   ubqs_lock_cone     = 14.0;",
        "user int     ubqs_lights        = 1;",
        "user int     ubqs_twirl         = 2;",
        "user int     ubqs_flick         = 1;",
        "user float   ubqs_flick_deg     = 65.0;",
        "user int     ubqs_autoignite    = 1;",
        "user int     ubqs_join          = 1;",
        "user int     ubqs_force_gestures = 1;",
        "user float   ubqs_force_gesture = 2.0;",
        "user int     ubqs_remote_level  = 2;",
        "user int     ubqs_remote_sting  = 2;",
        "server bool  ubqs_on            = true;",
        "server bool  ubqs_start         = true;",
        "server bool  ubqs_dual          = true;",
        "server bool  ubqs_chainsaw      = false;",
        "server int   ubqs_deflect       = 1;",
        "server int   ubqs_block         = 70;",
        "server float ubqs_block_cone    = 75.0;",
        "server int   ubqs_block_return  = 1;",
        "server int   ubqs_block_damage  = 20;",
        "server int   ubqs_burn          = 1;",
        "server int   ubqs_crossguard    = 1;",
        "server float ubqs_push_power    = 1.0;",
        "server float ubqs_push_range    = 448.0;",
        "server float ubqs_push_damage   = 8.0;",
        "server float ubqs_push_cooldown = 1.5;",
        "server float ubqs_damage        = 30.0;",
        "server float ubqs_throw_range   = 512.0;",
        "server bool  ubqs_force_hand    = true;",
        "server float ubqs_pull_range    = 768.0;",
        "server float ubqs_grip_mass     = 600.0;",
        "server float ubqs_grip_damage   = 6.0;",
        "server float ubqs_grip_fling    = 3.5;",
        "server float ubqs_grip_slam     = 3.0;",
        "server int   ubqs_force_jump    = 1;",
        "server float ubqs_jump_power    = 1.0;", ""]).encode()
    cols = ['\t%d, "%s"' % (i, c[1]) for i, c in enumerate(COLORS)]
    files["MENUDEF"] = "\n".join(
        ['OptionValue "UBQS_Colors"', "{"] + cols + ["}",
         'OptionValue "UBQS_Alt"', "{", '\t1, "Force push"', '\t0, "Second blade on / off"', "}",
         'OptionValue "UBQS_GlowColors"', "{", '\t-1, "Same as the blade"'] + cols + ["}",
         'OptionValue "UBQS_Plane"', "{", '\t0, "My wrist decides"', '\t1, "Flat (disc)"', '\t2, "End over end"', "}",
         'OptionValue "UBQS_Aim"', "{", '\t1, "Where I look (onto the enemy)"', '\t0, "Back at the shooter"',
         '\t2, "Bounce off the blade"', "}",
         'OptionValue "UBQS_Throw"', "{", '\t0, "Comes back"', '\t1, "Drops (call it back)"', "}",
         'OptionValue "UBQS_Twirl"', "{", '\t0, "Off"', '\t1, "Slow"', '\t2, "Fast"', "}",
         'OptionValue "UBQS_Lights"', "{", '\t0, "Off"', '\t1, "Quest (one per saber)"', '\t2, "Rich (two)"',
         '\t3, "PC (three)"', "}",
         'OptionMenu "UBQS_Options"', "{", '\tTitle "ULTRA BADASS QUESTSABER"',
         '\tOption "Use this saber", "ubqs_on", "OnOff"',
         '\tOption "Start with it", "ubqs_start", "OnOff"',
         '\tOption "Second saber in your off hand", "ubqs_dual", "OnOff"',
         '\tStaticText ""', '\tStaticText "YOUR SABER", "Gold"',
         '\tOption "Colour", "ubqs_color", "UBQS_Colors"',
         '\tOption "Off-hand colour", "ubqs_color_off", "UBQS_Colors"',
         '\tSlider "Size", "ubqs_size", 0.7, 1.3, 0.15, 2',
         '\tOption "Alt fire", "ubqs_alt", "UBQS_Alt"',
         '\tOption "Thrown saber", "ubqs_throw", "UBQS_Throw"',
         '\tSlider "Throw spin", "ubqs_throw_spin", 4, 40, 2, 0',
         '\tOption "Throw spins", "ubqs_throw_plane", "UBQS_Plane"',
         '\tSlider "How hard you must throw (lower = easier)", "ubqs_throw_min", 1, 8, 0.5, 1',
         '\tOption "Second blade lights when thrown", "ubqs_throw_double", "OnOff"',
         '\tSlider "Enemies one throw locks", "ubqs_locks", 1, 8, 1, 0',
         '\tSlider "Lock-on cone (degrees)", "ubqs_lock_cone", 6, 30, 1, 0',
         '\tOption "Deflected shots go", "ubqs_deflect_aim", "UBQS_Aim"',
         '\tOption "Blade light", "ubqs_lights", "UBQS_Lights"',
         '\tOption "Swing trail", "ubqs_trail", "OnOff"',
         '\tSlider "Blade glow", "ubqs_blade_glow", 0, 1, 0.05, 2',
         '\tSlider "Blade glow width", "ubqs_glow_width", 0.4, 3, 0.1, 1',
         '\tOption "Blade glow colour", "ubqs_blade_glow_color", "UBQS_GlowColors"',
         '\tOption "Blade glow: motion prediction", "ubqs_glow_predict", "OnOff"',
         '\tSlider "Blade glow: prediction lead (tics)", "ubqs_glow_lead", 0, 2, 0.05, 2',
         '\tOption "Blade glow: soft dots inside", "ubqs_glow_dots", "OnOff"',
         '\tOption "Blade glow: core fades in fast swings", "ubqs_glow_motionfade", "OnOff"',
         '\tOption "Solid blade tube in the hand", "ubqs_blade_tube", "OnOff"',
         '\tSlider "Emitter stub (no tube), units", "ubqs_glow_stub", 0, 6, 2, 0',
         '\tSlider "Blade contact: how close beams must come", "ubqs_contact", 0.5, 10, 0.25, 2',
         '\tSlider "Blade contact: dead zone above the hilts", "ubqs_contact_hilt", 0, 8, 0.25, 2',
         '\tStaticText ""', '\tStaticText "THE FORCE (off hand)", "Gold"',
         '\tOption "Off-hand Force gestures", "ubqs_force_gestures", "OnOff"',
         '\tSlider "Gesture snap needed (lower = easier)", "ubqs_force_gesture", 1, 6, 0.5, 1',
         '\tStaticText "Hold off-hand alt (or the trigger with no off-hand saber), then:", "DarkGray"',
         '\tStaticText "thrust = push, yank back = pull, hold on an enemy = grip (move it, fling it).", "DarkGray"',
         '\tStaticText "Hold jump with a saber out = Force jump.", "DarkGray"',
         '\tStaticText ""', '\tStaticText "TRAINING REMOTE", "Gold"',
         '\tCommand "Summon / dismiss the training remote", "netevent ubqs_remote"',
         '\tControl "Key: summon / dismiss remote", "ubqs_remote_toggle"',
         '\tSlider "Remote level", "ubqs_remote_level", 1, 3, 1, 0',
         '\tSlider "Remote sting damage (0 = none)", "ubqs_remote_sting", 0, 10, 1, 0',
         '\tStaticText ""', '\tStaticText "THE GAME", "Gold"',
         '\tOption "Deflect shots", "ubqs_deflect", "OnOff"',
         '\tSlider "Block bullets (held still), %", "ubqs_block", 0, 100, 5, 0',
         '\tOption "Blocked bullets fly back", "ubqs_block_return", "OnOff"',
         '\tOption "Blade burns walls", "ubqs_burn", "OnOff"',
         '\tOption "Cross guard (blades crossed = no damage from the front)", "ubqs_crossguard", "OnOff"',
         '\tSlider "Force push strength", "ubqs_push_power", 0.25, 3, 0.25, 2',
         '\tSlider "Force push reach", "ubqs_push_range", 128, 1024, 32, 0',
         '\tSlider "Force push cooldown (seconds)", "ubqs_push_cooldown", 0.25, 5, 0.25, 2',
         '\tSlider "Damage", "ubqs_damage", 10, 100, 5, 0',
         '\tSlider "Throw range", "ubqs_throw_range", 192, 1024, 64, 0',
         '\tOption "Doom\'s chainsaw becomes a saber too", "ubqs_chainsaw", "OnOff"',
         '\tOption "Bare Force hand when there is no off-hand saber", "ubqs_force_hand", "OnOff"',
         '\tSlider "Grip lifts up to mass", "ubqs_grip_mass", 0, 1000, 50, 0',
         '\tSlider "Grip choke damage per second", "ubqs_grip_damage", 0, 30, 1, 0',
         '\tSlider "Grip fling strength", "ubqs_grip_fling", 1, 8, 0.5, 1',
         '\tOption "Force jump", "ubqs_force_jump", "OnOff"',
         '\tSlider "Force jump power", "ubqs_jump_power", 0.5, 2, 0.25, 2',
         '\tStaticText ""',
         '\tStaticText "Swing your arm: the blade cuts what it passes through.", "DarkGray"',
         '\tStaticText "Fire: hold and sweep to mark enemies. Throw: let go of fire mid forward throw.", "DarkGray"',
         '\tStaticText "Alt: Force push. Cross your blades in an X or + to block everything in front.", "DarkGray"',
         '\tStaticText "Thrown: fire or alt calls it back. Walk over it to pick it up.", "DarkGray"',
         "}", 'AddOptionMenu "OptionsMenu"', "{", '\tSubmenu "Ultra Badass QuestSaber", "UBQS_Options"', "}", ""]).encode()
    files["MAPINFO"] = b'GameInfo\n{\n\tAddEventHandlers = "UBQS_Bridge", "UBQS_Telemetry"\n}\n'
    # Wardust's KEYCONF rewrites slot 1 with SetSlot; AddSlot runs after it and puts the saber back on key 1.
    # THE REMOTE'S KEY: in Options > Customize Controls under its own heading, and in the saber's own menu
    files["KEYCONF"] = (b"AddSlotDefault 1 UBQS_Saber\n"
                        b"alias ubqs_remote_toggle \"netevent ubqs_remote\"\n"
                        b"addkeysection \"Ultra Badass QuestSaber\" ubqs_keys\n"
                        b"addmenukey \"Summon / dismiss training remote\" ubqs_remote_toggle\n")

    names = sorted({spr for spr, _ in sprites})
    register = "\n".join("\t\t" + " ".join("%s A 0;" % n for n in names[i:i + 10]) for i in range(0, len(names), 10))
    # ---- ZSCRIPT ------------------------------------------------------------------------------------------------
    tpl = open(os.path.join(HERE, "ubqs_zscript.txt")).read()
    files["zscript.txt"] = (tpl % dict(
        ncol=len(COLORS), nf=len(FRAMES) - 1,
        yaw=", ".join("%.1f" % f[1] for f in FRAMES), up=", ".join("%.1f" % f[2] for f in FRAMES),
        ext=", ".join("%.2f" % f[4] for f in FRAMES), colstr="".join(c[0] for c in COLORS),
        rgb=", ".join("0x%02X%02X%02X" % c[2] for c in COLORS), sizes=", ".join("%.2f" % s for s in SIZES),
        blade_world=BLADE_WORLD, fr_s=FR["S"], fr_r=FR["R"], fr_q=FR["Q"], fr_p=FR["P"], fr_o=FR["O"],
        fr_n=FR["N"], register=register, tw0=TW0, twn=TWIRL_STEPS,
        hud_sc=HUD_SCALE, hud_oy=HUD_OFFSET[1], hud_oz=HUD_OFFSET[2],
        emit_mx=EMIT[0], emit_mz=EMIT[1], tip_mx=TIP[0], tip_mz=TIP[1])).encode()

    dest = os.path.join(OUT_DIR, PK3)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as zo:
        for k in sorted(files):
            zo.writestr(k, files[k])
    print("%s: %d entries, %.1f MB, %d frames, %d surfaces, world scale %.3f"
          % (dest, len(files), os.path.getsize(dest) / 1e6, len(FRAMES), nsurf, world_scale))


if __name__ == "__main__":
    main()
