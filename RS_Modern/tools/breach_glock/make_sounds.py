"""RS_Modern's Breach Glock sounds, from BREACH Weapons' own files (licenses/breach_weapons_CREDIT.txt).

  sounds/breach/glockfire.wav  Breach fires a Glock shot as TWO sounds at once: GLOCKF1 (the shot, mono) and GLOCKF2
                               (a stereo layer, two seconds). A card has one fire sound, so they are mixed into one
                               MONO file -- mono so the engine places it at the gun -- F1 at full, F2 at 0.6, then
                               soft-limited so it never clips.
  sounds/breach/hshell1..3.wav Breach's brass landing sounds (its brass.zs bounce sound), copied.
Copies keep every byte; only an extension is added. Refuses to overwrite a copy that is already there.
No 2D art is taken (the owner, 2026-09-15): Breach's icon, flash and smoke sprites stay out.
    python make_sounds.py
"""
import array, math, os, shutil, wave

B = "E:/DOOMWork/VR_WeaponSetRebuild/WeaponSets/Breach-weapons/"
M = "E:/DOOMWork/RS_Modern/"


def read_mono(path):
    w = wave.open(path, "rb")
    ch, rate, width, n = w.getnchannels(), w.getframerate(), w.getsampwidth(), w.getnframes()
    if width != 2:
        raise SystemExit("%s: %d-byte samples, expected 16-bit" % (path, width))
    a = array.array("h", w.readframes(n))
    w.close()
    return rate, [sum(a[i:i + ch]) / ch for i in range(0, len(a), ch)]


r1, f1 = read_mono(B + "sounds/GLOCKF1")
r2, f2 = read_mono(B + "sounds/GLOCKF2")
if r1 != r2:
    raise SystemExit("GLOCKF1 is %d Hz and GLOCKF2 %d Hz -- not mixed" % (r1, r2))
n = max(len(f1), len(f2))
mix = [(f1[i] if i < len(f1) else 0.0) + 0.6 * (f2[i] if i < len(f2) else 0.0) for i in range(n)]

# A SOFT LIMIT, NOT A GAIN. The two layers' peaks rarely line up, and scaling the whole mix down to fit its one loudest
# overlap left the shot at 61% of its own level. Below the knee a sample is untouched; above it, it bends smoothly
# toward full scale and never past it.
KNEE, FULL = 26000.0, 32000.0


def limit(x):
    a = abs(x)
    if a <= KNEE:
        return x
    return math.copysign(KNEE + (FULL - KNEE) * math.tanh((a - KNEE) / (FULL - KNEE)), x)


peak = max(abs(x) for x in mix)
over = sum(1 for x in mix if abs(x) > KNEE)
out = array.array("h", [int(round(limit(x))) for x in mix])
w = wave.open(M + "sounds/breach/glockfire.wav", "wb")
w.setnchannels(1)
w.setsampwidth(2)
w.setframerate(r1)
w.writeframes(out.tobytes())
w.close()
print("glockfire.wav: mono %d Hz, %.2f s; mix peak %.0f; %d of %d samples above the knee (%.0f) bent under %.0f"
      % (r1, n / r1, peak, over, n, KNEE, FULL))

for src, dst in (("sounds/HSHELL1", "sounds/breach/hshell1.wav"), ("sounds/HSHELL2", "sounds/breach/hshell2.wav"),
                 ("sounds/HSHELL3", "sounds/breach/hshell3.wav")):
    if os.path.exists(M + dst):
        print("already there: %s" % dst)
        continue
    os.makedirs(os.path.dirname(M + dst), exist_ok=True)
    shutil.copyfile(B + src, M + dst)
    print("copied %s -> %s" % (src, dst))
