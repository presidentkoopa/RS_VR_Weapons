"""RS_Modern's BREACH set sounds, from BREACH Weapons' own files (licenses/breach_weapons_CREDIT.txt).

FIRE: Breach plays each gun's shot as two sounds at once (its zscript: one on channel 6, one on channel 5, some at
their own volume). A card has one fire sound, so each pair is mixed into one MONO file -- mono so the engine places it
at the gun -- the main layer at its Breach volume, the other at 0.6 x its Breach volume (as the Glock's), resampled to
44.1 kHz if a layer is not, then soft-limited so it never clips (below the knee untouched).
COPIES: the reload, rack, shell and casing sounds each gun plays, byte for byte, with a .wav extension added.
Refuses to overwrite a copy that is already there; the fire mixes are always rewritten. No 2D art is taken.
    python make_breach_sounds.py
"""
import array, math, os, shutil, wave

B = "E:/DOOMWork/VR_WeaponSetRebuild/WeaponSets/Breach-weapons/sounds/"
M = "E:/DOOMWork/RS_Modern/sounds/breach/"
RATE = 44100

# gun: (main layer, its volume), (second layer, its Breach volume) -- from each Breach zscript's Fire state
FIRE = {
    "glocks":  (("GLOCKSF1", 1.0), ("GLOCKSF2", 1.0)),
    "kimber":  (("KIMBER1", 1.0), ("KIMBER2", 1.0)),
    "mk18":    (("MK18", 1.0), ("MK182", 1.0)),
    "mk18s":   (("MK18S", 1.0), ("MK18S2", 1.7)),
    "g36c":    (("G36", 0.9), ("MK18S2", 1.3)),
    "mcx":     (("MCX", 1.0), ("TRIGGER", 1.0)),
    "mp5":     (("MP5", 1.0), ("TRIGGER", 1.0)),
    "hk416s":  (("HK416", 0.9), ("MK18S2", 1.3)),
    "benelli": (("BENELLI", 1.0), ("BENELLI2", 1.0)),
}
COPIES = ["CLIPOUT", "CLIPIN", "CMAGOUT", "CMAGIN", "BOLTBACK", "BOLTCLOSE", "PUMP1", "LSHELL1", "SSHELL1", "CLICK"]


def read_mono(path):
    # NOT WAV DATA (Breach's BENELLI is Ogg Vorbis): ffmpeg decodes it to 16-bit mono 44.1 kHz first.
    with open(path, "rb") as fh:
        if fh.read(4) != b"RIFF":
            tmp = os.path.join(os.environ.get("TEMP", "."), "breach_decode_" + os.path.basename(path) + ".wav")
            import subprocess
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", path, "-ac", "1", "-ar", str(RATE), "-acodec", "pcm_s16le", tmp], check=True)
            path = tmp
    w = wave.open(path, "rb")
    ch, rate, width, n = w.getnchannels(), w.getframerate(), w.getsampwidth(), w.getnframes()
    raw = w.readframes(n)
    w.close()
    if width == 2:
        a = array.array("h", raw)
    elif width == 1:
        a = [(b - 128) * 256 for b in raw]           # 8-bit WAV is unsigned
    else:
        raise SystemExit("%s: %d-byte samples, expected 8- or 16-bit" % (path, width))
    mono = [sum(a[i:i + ch]) / ch for i in range(0, len(a), ch)]
    if rate != RATE:
        n2 = int(len(mono) * RATE / rate)
        mono = [mono[min(len(mono) - 1, int(i * rate / RATE))] for i in range(n2)]
    return mono


KNEE, FULL = 26000.0, 32000.0


def limit(x):
    ax = abs(x)
    return x if ax <= KNEE else math.copysign(KNEE + (FULL - KNEE) * math.tanh((ax - KNEE) / (FULL - KNEE)), x)


os.makedirs(M, exist_ok=True)
for gun, ((f1, v1), (f2, v2)) in FIRE.items():
    a1, a2 = read_mono(B + f1), read_mono(B + f2)
    n = max(len(a1), len(a2))
    mix = [(a1[i] * v1 if i < len(a1) else 0.0) + (a2[i] * 0.6 * v2 if i < len(a2) else 0.0) for i in range(n)]
    over = sum(1 for x in mix if abs(x) > KNEE)
    out = array.array("h", [int(round(limit(x))) for x in mix])
    w = wave.open(M + gun + "_fire.wav", "wb")
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(RATE)
    w.writeframes(out.tobytes())
    w.close()
    print("%-8s fire: %s x%.2f + %s x%.2f -> %.2f s, %d of %d samples bent under the limit" % (gun, f1, v1, f2, 0.6 * v2, n / RATE, over, n))

for src in COPIES:
    dst = M + src.lower() + ".wav"
    if os.path.exists(dst):
        print("already there: %s" % dst)
        continue
    with open(B + src, "rb") as fh:
        if fh.read(4) != b"RIFF":
            raise SystemExit("%s is not WAV data" % src)
    shutil.copyfile(B + src, dst)
    print("copied %s -> %s" % (src, dst))
