# Build RS_VR_Weapons.pk3
#
# ---- THE SIX SHAPES A CHECK MISSES --------------------------------------------------------
#
# Every one of these shipped, every one passed the checks we had, and every one was found by a
# human noticing something sideways rather than by a tool. Read this before trusting a green.
#
#   1. A DECLARATION THAT WAS NEVER MADE. Thirteen cards declared no magmodel, so there was
#      nothing to resolve, and card_lint returned 0 in all three modes. Every gun in both sets
#      dropped an M4A3 PISTOL magazine -- with the correct drop sound, which made it read as
#      finished. A verifier can check a declaration RESOLVES; it cannot check one is PRESENT.
#
#   2. A REFERENCE WITH NO DEFINITION. The RTCW sheet named rtcw_* ballistics profiles that were
#      never built -- 68 of them. Seventeen guns firing with no flash, no smoke, no brass and no
#      round look. card_lint checked SOUND names against SNDINFO and profile names against
#      nothing at all. It reads RSBDEFS now.
#
#   3. A FILE WITH NO REFERENCE. 563 KiB of stray .jpg, 3.64 MiB per add-on of the base's own
#      tree packed twice, and the P38 and Nebelwerfer -- two whole guns nobody can select, 9.02
#      MiB. Every check ran reference -> file and nothing ran file -> reference. That check is
#      below, and on its first honest run it found a TEXTURES lump left dangling by the filter
#      that fixed the duplication.
#
#   4. A CHECK COMPARING THE WRONG THINGS. A normals comparison concatenated surfaces in FILE
#      order against the lift's order, so a clean magazine reported as corrupt. A check that
#      cries wolf is worse than no check, because the next real one is not believed.
#
#   5. A CHECK THAT PARSES AND THEREFORE NEVER LOOKS. -norun proves scripts PARSE. It cannot see
#      a VM abort and it cannot see a gun drawing the wrong object. An add-on compile-checked
#      without the base pack has never really been checked at all.
#
#   6. A COMPARISON BETWEEN VALUES OF DIFFERENT PROVENANCE. Ranking feed candidates by travel
#      picked the furthest -- but an ESTIMATED distance is the part's own LENGTH, and a part is
#      routinely longer than the stroke that frees it. So the invented number beat the measured
#      one: the StG44 carded a 36.674 estimate over a 25.860 measured slide and its magazine
#      pulled out THROUGH ITS OWN BARREL. The check was right; the ranking was mixing measured
#      and invented and had no idea. Two numbers are comparable only when they mean the same
#      thing.
#
#   7. A TOOL THAT CANNOT SEE A THING, REPORTING IT AS ABSENT. The consistency gate could not
#      read RS_Modern at all -- that set declares its profiles as ZScript class properties
#      rather than in a WMSHEET -- so it reported a COMPLETE ten-gun set as not existing rather
#      than as unchecked. Absence rendering as plausible, inside the tool built to catch absence
#      rendering as plausible.
#
#      AND IT COST REAL DAMAGE THE SAME NIGHT. The same gate flagged models/ww2/P38 and
#      models/ww2/Nebelwerfer as unreferenced weight -- true, they were -- and I took the label
#      and wrote them up as "two guns nobody can select" and "dead weight". THEY WERE THE
#      OWNER'S OWN WORK: one he was asked to go and find, one he built. Nothing referenced them
#      because nobody had CARDED them, and the answer was to finish them, not to exclude them.
#      I never asked why nothing referenced them.
#
#      ASK WHETHER YOUR TOOL CAN SEE A THING BEFORE YOU BELIEVE ITS ABSENCE -- and when it
#      reports something as unused, ask why it is unused before you call it waste.
#
# THE PREVENTIVE HALF OF SHAPE 2, from the ballistics lane: ANY NEW KEY THAT REACHES THE
# SIMULATION GETS A `none` WHEN IT IS BORN, not after it ships. A key that is simply absent
# cannot be told apart from one nobody got to; a key that says `none` has been decided.
#
# And one that is not a shape but is how two of these were found: A FIX THAT CHANGES NOTHING IS
# EVIDENCE. Reload fixed one of the two places the feed axis is decided, saw no improvement at
# all, and that is what sent them to find the second.
#
# The test guns for the VR reload system, and their models. Loads AFTER the
# reload system; nothing in the reload system may name anything in here.
#
# Entry-by-entry ZipArchive with forward slashes and an ALLOWLIST, as the
# reload system's own build does: Compress-Archive writes backslashes SLADE will
# not open, and a lump name ignores its extension, so a stray .bak in the root
# can silently shadow the real lump.
#
# THE MENU IS LINTED FIRST (tools/menu_lint.py): a slider on a cvar nothing
# reads, a placement set missing a name, or a class MODELDEF or a card names
# that no ZScript here declares fails the build before it reaches a headset.
#
# STAGED, THEN INSTALLED: the pk3 is packed to a scratch folder and compile-checked there, and only a
# pass copies it over the installed RS_VR_Weapons.pk3 in the owner's load order. A pk3 with a script
# error must never sit where the owner launches from (the build lane, 2026-09-13).
#
# -NoCompileCheck skips the last step, which runs doomxr.exe -norun -- and so installs NOTHING: the
# pack stays staged (for a build lock, when the exe is mid-link).
# -Set picks WHICH PLAYER CLASSES the packed MAPINFO offers at New Game, and nothing else -- see
# the header note. Both (the default) is exactly what this script has always produced, so every
# existing caller and the owner's own load order are untouched.
# -Set Plus builds the VANILLA+ ADD-ON instead of the base. The default builds the base, which is
# what this script has always produced and what the owner's load order names.
#
# THE TWO ARE NOT INTERCHANGEABLE AND THE ADD-ON IS NOT STANDALONE. It carries no meshes, no sounds
# and no shared gun classes -- those are the base's, and defining any of them in both archives is a
# fatal, global load error the moment the two are loaded together. Load the base, then the add-on.
param([switch]$NoCompileCheck, [ValidateSet('Base', 'Plus', 'WW2', 'RTCW')][string]$Set = 'Base')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# THE RELOAD SYSTEM this package's classes derive from (WM_Gun, WM_Prop) and whose
# WM_LooseMag / WM_LooseRound this MODELDEF draws -- the one line to change when it
# is renamed.
$reloadPk3 = 'E:\DOOMWork\RS_VR_Reload\RS_VR_Reload.pk3'

$root      = $PSScriptRoot
$installed = Join-Path $root 'RS_VR_Weapons.pk3'   # reassigned below once $pk3Name is known
$stage     = Join-Path $env:TEMP 'rs_vr_weapons_stage'
New-Item -ItemType Directory -Force $stage | Out-Null
$isPlus    = ($Set -eq 'Plus')
$isWW2     = ($Set -eq 'WW2')
$isRTCW    = ($Set -eq 'RTCW')
# EVERY SET BUT THE BASE IS AN ADD-ON and they pack the same shape -- own root lumps out of a source
# folder, own sheets, own zscript folder, AddPlayerClasses, nothing shared duplicated.
$isAddon   = ($isPlus -or $isWW2 -or $isRTCW)
$addonDir  = if ($isWW2) { 'ww2' } elseif ($isRTCW) { 'rtcw' } elseif ($isPlus) { 'plus' } else { '' }
$pk3Name   = if ($isWW2) { 'RS_VR_Weapons_WW2.pk3' } elseif ($isRTCW) { 'RS_VR_Weapons_RTCW.pk3' } elseif ($isPlus) { 'RS_VR_Weapons_Plus.pk3' } else { 'RS_VR_Weapons.pk3' }
$out       = Join-Path $stage $pk3Name

# THE BASE CLEARS AND ESTABLISHES; THE ADD-ON APPENDS. gi.cpp:370-371 registers `addplayerclasses`
# and `playerclasses` against one array, the first additive and the second replacing. The base uses
# the replacing form so the IWAD's own marine leaves the New Game screen; every add-on uses the
# additive one, so any number of sets can be loaded together and each adds one row.
#
# The base's line is rewritten INTO THE ZIP rather than on disk: a working tree carrying a half-built
# MAPINFO would let a set be left selected by accident and the next build would ship it unknowing.
# The add-on's MAPINFO is its own file (plus/MAPINFO.txt) because it shares nothing with the base's.
$playerClasses = if ($isAddon) { $null } else { '    PlayerClasses = "WM_Player"' }

# --prefix: every stem THIS package declares cvars under -- the shotguns' sets and
# wm_pump_start_in_hands (wm_pump), one placement set per revolver, and the
# rifle's (wm_rifle). Add a
# gun's stem here when you add its CVARINFO set, or the lint drops its set and
# calls every slider on its page dead (E7). The pistols add no cvars -- their
# blocks read the reload system's per-hand seats wm_main / wm_off, which that
# package declares and lints. --dep: MODELDEF here draws the reload system's
# WM_LooseMag and WM_LooseRound, and Doom's own ammo classes (Clip, Shell, ...),
# so the reload system's classes and the engine's own ZScript count as declared.
& python 'E:\DOOMWork\tools\menu_lint.py' $root --prefix 'wm_pump,wm_moonlight,wm_sunset,wm_cola,wm_rifle,wm_ssg,wm_doublebarrel,wm_m16,wm_tec9,wm_smg,wm_railgun,wm_plasmarifle,wm_plasmarifleblue,wm_plasmacarbine,wm_chaingun,wm_machinegun,wm_rocketlauncher,wm_rpg,wm_bfg,wm_bfgheavy,wm_chainsaw,wm_chainsawheavy,wm_flamer,wm_flamethrower,wm_assaultshotgun,wm_bullpuppump,wm_bolter,wm_bfgrifle,wm_rotarygun,wm_rotarylauncher,wm_longbarchainsaw,wm_unmaker' --dep (Split-Path $reloadPk3) --dep 'E:\DOOMWork\UZDXREMA\wadsrc\static'
if ($LASTEXITCODE -ne 0) { throw "menu lint failed -- see above." }

# THE GUN CLASS WRITER: every Weapon Card with a `class` block gets its small class written
# (zscript/rs_vr_weapons/generated_guns.zs), so a new gun is only its card.
# PER SET: the Vanilla+ guns' classes belong to the add-on's own lump, because a class defined in
# both archives is fatal when they are loaded together. --sheets base skips WMSHEET.plus_*; --sheets
# plus takes only those.
& python (Join-Path $root '_pending\tools\make_gun_classes.py') --sheets $(if ($isWW2) { 'ww2' } elseif ($isRTCW) { 'rtcw' } elseif ($isPlus) { 'plus' } else { 'base' })
if ($LASTEXITCODE -ne 0) { throw "gun class writer refused a Weapon Card -- see above" }
# THE WEAPON CARDS LINT before anything packs: known keys, a class and a Model Card for every gun, a capacity the
# model can hold (_pending/card_lint.py --sheets).
& python (Join-Path $root '_pending' | Join-Path -ChildPath 'card_lint.py') --sheets | Select-Object -Last 1
if ($LASTEXITCODE -ne 0) { throw "a Weapon Card failed card_lint --sheets -- run it for the list" }

# THE ADD-ON BRINGS ONLY ITS OWN TWO, out of plus/, and they are packed AT THE ZIP ROOT. It declares
# no MODELDEF, CVARINFO, MENUDEF, KEYCONF, SNDINFO or language: every one of those is the base's, and
# a second copy would either replace the base's outright (MAPINFO-style keys) or define the same
# thing twice.
# WW2 brings a MODELDEF of its own as well, because it ships meshes. MODELDEF blocks accumulate
# across archives, so it sits beside the base's rather than replacing it.
# CREDITS SHIP WITH THE SET, not in a doc beside it. The models are community work used unaltered
# and the artists' names travel inside the pk3 -- that is the deal.
$rootLumps = if ($isWW2) { @('ww2/zscript.txt', 'ww2/MAPINFO.txt', 'ww2/MODELDEF.txt', 'ww2/CREDITS.txt', 'ww2/SNDINFO.txt') }
             elseif ($isRTCW) { @('rtcw/zscript.txt', 'rtcw/MAPINFO.txt', 'rtcw/MODELDEF.txt', 'rtcw/CREDITS.txt') }
             elseif ($isPlus) { @('plus/zscript.txt', 'plus/MAPINFO.txt') }
             else { @('zscript.txt', 'MAPINFO.txt', 'MODELDEF.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'KEYCONF.txt', 'SNDINFO.txt', 'language.txt', 'TRNSLATE.txt') }
$files = @()
foreach ($l in $rootLumps) {
    $p = Join-Path $root $l
    if (-not (Test-Path $p)) { throw "missing required lump: $l" }
    $files += Get-Item $p
}
# THE CARDS AND SHEETS: every root WMCARD.* and WMSHEET.* file (one lump name each, read in order).
# EACH SET'S OWN CARDS, filtered once here so the pack and the mesh-reference verifier below can
# never disagree about which cards this pk3 is answerable for. WMCARD.ww2 is the WW2 pack's;
# every other WMCARD.* is the base's.
$cardFiles  = @(Get-ChildItem -Path $root -File -Filter 'WMCARD.*' | Sort-Object Name |
                Where-Object { (($_.Name -eq 'WMCARD.ww2') -eq $isWW2) -and (($_.Name -eq 'WMCARD.rtcw') -eq $isRTCW) })
# THE SHEETS SPLIT WITH THE CLASSES THEY DESCRIBE. WMSHEET.plus_* is the add-on's; every other sheet
# is the base's. A sheet in both archives would be read twice.
# Each set takes its own sheets only. The base takes everything that is nobody else's.
$sheetFiles = @(Get-ChildItem -Path $root -File -Filter 'WMSHEET.*' | Sort-Object Name | Where-Object {
                  $mine = ($_.Name -like 'WMSHEET.plus_*') -or ($_.Name -eq 'WMSHEET.ww2') -or ($_.Name -eq 'WMSHEET.rtcw')
                  if ($isRTCW) { $_.Name -eq 'WMSHEET.rtcw' }
                  elseif ($isWW2) { $_.Name -eq 'WMSHEET.ww2' }
                  elseif ($isPlus) { $_.Name -like 'WMSHEET.plus_*' }
                  else { -not $mine } })
if (-not $isPlus -and $cardFiles.Count -eq 0) { throw 'missing required lump: no WMCARD.* file' }
if ($sheetFiles.Count -eq 0) { throw "no WMSHEET.* files for -Set $Set" }
# WMCARD.ww2 is the WW2 pack's; every other WMCARD.* is the base's.
if (-not $isPlus) { $files += $cardFiles }
$files += $sheetFiles
# TEXTURES.*: Vanilla+'s floor pickup sprites (TEXTURES.vp_pickups), one TEXTURES lump each.
#
# THE BASE ONLY, and this was WRONG until the add-on asset filter landed: every non-Plus set
# shipped this lump, and once the add-ons correctly stopped packing graphics/ it became a
# TEXTURES lump naming art that is not in the archive with it. A dangling reference, created by
# fixing the duplication around it -- and found by the file -> reference check on its first
# honest run, which is the whole argument for having one.
if (-not $isAddon) { $files += @(Get-ChildItem -Path $root -File -Filter 'TEXTURES.*' | Sort-Object Name) }
# ZSCRIPT: each set takes only its own folder. zscript/rs_vr_weapons_plus is the add-on's.
$files += Get-ChildItem -Path (Join-Path $root 'zscript') -Recurse -File -Filter *.zs | Where-Object {
              $inPlus = $_.FullName -like '*\rs_vr_weapons_plus\*'
              $inWW2  = $_.FullName -like '*\rs_vr_weapons_ww2\*'
              $inRTCW = $_.FullName -like '*\rs_vr_weapons_rtcw\*'
              if ($isRTCW) { $inRTCW } elseif ($isWW2) { $inWW2 } elseif ($isPlus) { $inPlus }
              else { -not ($inPlus -or $inWW2 -or $inRTCW) } }
# MESHES: WW2 takes models/ww2 and only that; the base takes everything that is not another set's.
if (-not $isPlus) { $files += Get-ChildItem -Path (Join-Path $root 'models') -Recurse -File | Where-Object {
                      # JPEG IS THE RTCW SET'S ONLY, and deliberately not general. Its skins ship as
                      # wpn_base.jpg rather than PNG and GZDoom reads either, so the set needs it --
                      # but allowing .jpg everywhere swept two UNREFERENCED files into the base pack
                      # (models/ammo_hand/berettam9.jpg and its _HD twin, 563 KB between them) that
                      # no MODELDEF or card names. The verifier only catches a reference with no
                      # file, never a file with no reference, so that would have ridden along unseen.
                      ($_.Extension -in '.md3', '.png', '.obj' -or ($isRTCW -and $_.Extension -in '.jpg', '.jpeg')) -and
                      (($_.FullName -like '*\models\ww2\*') -eq $isWW2) -and
                      (($_.FullName -like '*\models\rtcw\*') -eq $isRTCW) } }
# AND A SET PACKS ONLY THE MESHES ITS CARD NAMES.
#
# THE WW2 PACK SHIPPED THE P38 AND THE NEBELWERFER -- 11 files, 9.02 MiB, two whole guns that
# nobody has carded and nobody can select. They are among the seventeen the set deliberately does
# NOT have, and their meshes were swept in because this took the whole models/<set> folder.
# The source folders stay: those are future guns. The PACK stops carrying what no card names.
if ($isAddon -and $addonDir) {
    $cardRefs = @{}
    foreach ($line in ($cardFiles | ForEach-Object { Get-Content $_.FullName })) {
        $t = ($line -replace '#.*$', '').Trim()
        if ($t -match '^(model|skin|magmodel|magskin|magskinempty|roundmodel|roundskin)\s*=\s*"([^"]+)"\s+"([^"]+)"') {
            $cardRefs[("$($Matches[2])/$($Matches[3])").ToLowerInvariant()] = $true
        }
    }
    $files = $files | Where-Object {
        $rel = ($_.FullName.Substring($root.Length + 1)) -replace ([regex]::Escape([char]92)), '/'
        (-not ($rel -like 'models/*')) -or $cardRefs.ContainsKey($rel.ToLowerInvariant()) }
}
# THE SOUND, SPRITE AND GRAPHICS TREES ARE THE BASE PACK'S. An add-on takes ONLY its own set
# folder under sounds/ and none of the rest.
#
# BOTH ADD-ONS SHIPPED 216 ENTRIES BYTE-IDENTICAL TO THE BASE -- 3.64 MiB each, 7.3 MiB across the
# two -- because this packed the whole of sounds/, sprites/ and graphics/ into every non-Plus set.
# Harmless at load (same lump names, the later archive wins) and it was found by comparing CRCs
# against the base by hand, not by any check. Dead weight is not a size problem on a local
# install; it is how the NEXT stray file hides.
$soundsAll = Get-ChildItem -Path (Join-Path $root 'sounds') -Recurse -File |
             Where-Object { $_.Extension -in '.ogg', '.wav' -or $_.FullName -like '*\sounds\rs_grenade\*' }
if ($isAddon) {
    # its own folder only -- sounds/ww2/... for WW2, and RTCW has none of its own because its
    # guns point at sound NAMES the base already defines.
    if ($addonDir) { $files += $soundsAll | Where-Object { $_.FullName -like "*\sounds\$addonDir\*" } }
} else {
    # AND THE BASE TAKES NONE OF THEIRS. sounds/ww2/ is the WW2 set's; without this exclusion the
    # base grew by exactly those 82 files the moment that folder appeared -- the same duplication
    # in the other direction, and the reason to state it as "everything that is nobody else's"
    # rather than "everything".
    $files += $soundsAll | Where-Object { $_.FullName -notlike '*\sounds\ww2\*' -and $_.FullName -notlike '*\sounds\rtcw\*' }
    # RS_Grenade's and RS_ShieldSaw's sprites (folded in 09-14), and the art TEXTURES.* builds
    # sprites from (graphics/vp_pickups: RS_Main's RS_GH pickup art). Base only.
    $files += Get-ChildItem -Path (Join-Path $root 'sprites')  -Recurse -File
    $files += Get-ChildItem -Path (Join-Path $root 'graphics') -Recurse -File
}

# KEYCONF WITH A BYTE ORDER MARK SILENTLY KILLS ITS FIRST ALIAS.
$kb = [System.IO.File]::ReadAllBytes((Join-Path $root 'KEYCONF.txt'))
if ($kb.Length -ge 3 -and $kb[0] -eq 0xEF -and $kb[1] -eq 0xBB -and $kb[2] -eq 0xBF) { throw "KEYCONF.txt starts with a UTF-8 BOM -- its first alias would do nothing" }

if (Test-Path $out) { Remove-Item $out -Force }
$fs  = [System.IO.File]::Open($out, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
$mapinfoSwapped = $false
foreach ($f in $files) {
    $rel = ($f.FullName.Substring($root.Length + 1)) -replace ([regex]::Escape([char]92)), '/'
    # plus/ is a SOURCE folder, not a path in the pk3: its two lumps are the add-on's root lumps.
    if ($addonDir -and $rel -like "$addonDir/*") { $rel = $rel.Substring($addonDir.Length + 1) }
    $e = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $st = $e.Open()
    if ($playerClasses -and $rel -eq 'MAPINFO.txt') {
        # ONE SET ONLY. The New Game class list is the whole of what a set is, so it is the whole of
        # what changes. Matched on the assignment rather than the value, so a later edit to the class
        # names here does not silently stop being rewritten.
        $text = [System.IO.File]::ReadAllText($f.FullName)
        $new  = [regex]::Replace($text, '(?m)^\s*PlayerClasses\s*=.*$', $playerClasses)
        if ($new -eq $text) { throw "MAPINFO.txt has no PlayerClasses line to rewrite for -Set $Set" }
        $b = [System.Text.Encoding]::UTF8.GetBytes($new)
        $mapinfoSwapped = $true
    } else {
        $b = [System.IO.File]::ReadAllBytes($f.FullName)
    }
    $st.Write($b, 0, $b.Length); $st.Dispose()
}
if ($playerClasses -and -not $mapinfoSwapped) { throw "MAPINFO.txt was never packed -- -Set $Set would have shipped both classes" }
$zip.Dispose(); $fs.Dispose()

# VERIFY RATHER THAN TRUST: a model that fails to pack is SILENT -- it resolves
# to nothing and simply draws nothing.
$check = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = @($check.Entries | ForEach-Object { $_.FullName })
$check.Dispose()
# THE ADD-ON DECLARES ALMOST NOTHING, so it is verified against its own short list.
$must = if ($isPlus) { @('zscript.txt','MAPINFO.txt') }
        elseif ($isWW2) { @('zscript.txt','MAPINFO.txt','MODELDEF.txt','WMCARD.ww2','WMSHEET.ww2') }
        elseif ($isRTCW) { @('zscript.txt','MAPINFO.txt','MODELDEF.txt','WMCARD.rtcw','WMSHEET.rtcw') }
        else {
@('zscript.txt','MODELDEF.txt','CVARINFO.txt','MENUDEF.txt','MAPINFO.txt','KEYCONF.txt','SNDINFO.txt',
          'zscript/rs_vr_weapons/pistols.zs','zscript/rs_vr_weapons/shotguns.zs','zscript/rs_vr_weapons/loadout.zs',
          'zscript/rs_vr_weapons/weaponset.zs',
          'models/pistols/m4a3.md3','models/pistols/m4a3.png','models/pistols/pistolet.md3','models/pistols/WPN-9mm.png',
          'models/pistols/wm_m4a3_mag.md3','models/pistols/wm_pistolet_mag.md3',
          'models/pistols/bullet.md3','models/pistols/bullet.png',
          'sounds/pistols/PFIRE01.ogg','sounds/pistols/PFIRE02.ogg','sounds/pistols/PFIRE03.ogg',
          'sounds/pistols/PCOUT.ogg','sounds/pistols/PCIN.ogg','sounds/pistols/PSLID.ogg','sounds/pistols/PSNAP.ogg',
          'sounds/pistols/9mmshoot.wav','sounds/pistols/9mmclip1.wav','sounds/pistols/9mmclip2.wav','sounds/pistols/9mmslide.wav',
          'sounds/rifles/RIFIRE1.ogg','sounds/rifles/RIFIRE2.ogg','sounds/rifles/RIFIRE3.ogg','sounds/rifles/RCOUT.ogg',
          'sounds/rifles/RCIN.ogg','sounds/rifles/RCKBCK.ogg','sounds/rifles/RCKFWD.ogg',
          'sounds/revolvers/SINGLE1.ogg','sounds/revolvers/SINGLE2.ogg','sounds/revolvers/DBOPN.ogg',
          'sounds/revolvers/DBCLS.ogg','sounds/revolvers/DBLOD.ogg',
          'models/shotguns/AE_Shotgun/m37a2.md3','models/shotguns/AE_Shotgun/m37a2.png',
          'models/shotguns/Shotgun/shotgun.md3','models/shotguns/Shotgun/WPN-GUNS-k1.png',
          'models/shotguns/Shotgun/wm_shotshell.md3',
          'models/shotguns/SuperShotgun/ssg.md3','models/shotguns/SuperShotgun/WPN-GUNS-k1.png',
          'models/shotguns/DoubleBarrel/doublebarrel_wm.md3','models/shotguns/DoubleBarrel/wm_doublebarrel_shell.md3',
          'models/shotguns/DoubleBarrel/ssg_HD.png','models/shotguns/DoubleBarrel/shells.png',
          'sounds/shotguns/DoubleBarrel/ssgfire.ogg','sounds/shotguns/DoubleBarrel/DSDBOPN.ogg',
          'sounds/shotguns/DoubleBarrel/DSDBCLS.ogg','sounds/shotguns/DoubleBarrel/CLIPINSS.ogg',
          'zscript/rs_vr_weapons/revolvers.zs',
          'models/revolvers/Revolver/rev_wm.md3','models/revolvers/Revolver/wm_speedloader.md3',
          'models/revolvers/Revolver/WPN-REV.png','models/revolvers/Revolver/WPN-REV2.png',
          'models/revolvers/Cola_Revolver/revolver.md3','models/revolvers/Cola_Revolver/revolver.png',
          'models/revolvers/Cola_Revolver/wm_cola_rounds.md3',
          'zscript/rs_vr_weapons/rifles.zs','zscript/rs_vr_weapons/ssg.zs',
          'models/rifles/Rifle/Rifle.md3','models/rifles/Rifle/Rifle.png','models/rifles/Rifle/wm_rifle_mag.md3',
          'models/rifles/M16/m16_wm.md3','models/rifles/M16/WPN-M16-k1.png','models/rifles/M16/wm_m16_mag.md3',
          'zscript/rs_vr_weapons/smgs.zs',
          'models/smgs/Tec9/tec9_wm.md3','models/smgs/Tec9/tec9.png','models/smgs/Tec9/wm_tec9_mag.md3',
          'models/smgs/SMG/smg_wm.md3','models/smgs/SMG/smg.png','models/smgs/SMG/wm_smg_mag.md3',
          'zscript/rs_vr_weapons/railguns.zs',
          'models/railguns/Railgun/railgun_wm.md3','models/railguns/Railgun/railgun.png','models/railguns/Railgun/wm_railgun_mag.md3',
          'zscript/rs_vr_weapons/plasma.zs',
          'models/plasma/PlasmaRifle/plasmarifle_wm.md3','models/plasma/PlasmaRifle/wm_plasmarifle_cell.md3','models/plasma/PlasmaRifle/PlasmaRifle.png',
          'models/plasma/PlasmaCarbine/plasmacarbine_wm.md3','models/plasma/PlasmaCarbine/wm_plasmacarbine_cell.md3','models/plasma/PlasmaCarbine/plasmacarbine.png',
          'zscript/rs_vr_weapons/chainguns.zs',
          'models/chainguns/ChaingunGH/chaingungh_wm.md3','models/chainguns/ChaingunGH/Minigun.png','models/chainguns/Chaingun/cg_ammoclip.md3','models/chainguns/Chaingun/chaingun_HD.png',
          'models/chainguns/MachineGun/machinegun_wm.md3','models/chainguns/MachineGun/wm_machinegun_mag.md3','models/chainguns/MachineGun/Machinegun.png',
          'zscript/rs_vr_weapons/launchers.zs',
          'models/launchers/RPG/rpg_wm.md3','models/launchers/RPG/rpg.png','models/launchers/RPG/wm_rpg_mag.md3','models/launchers/RPG/wm_rocket.md3',
          'zscript/rs_vr_weapons/bfg.zs',
          'models/bfg/BFG/bfg9000.png','models/bfg/BFG/bfg9000_off.png',
          'models/bfg/BFGHeavy/bfgheavy_wm.md3','models/bfg/BFGHeavy/wm_bfgheavy_cell.md3','models/bfg/BFGHeavy/bfg.png',
          'zscript/rs_vr_weapons/chainsaws.zs',
          'models/chainsaws/Chainsaw/chainsaw_wm.md3','models/chainsaws/Chainsaw/chainsaw.png',
          'models/chainsaws/ChainsawHeavy/chainsaw_heavy_wm.md3','models/chainsaws/ChainsawHeavy/chainsaw.png',
          'zscript/rs_vr_weapons/flamers.zs',
          'zscript/rs_vr_weapons/meatgrinder.zs',
          'models/shotguns/AssaultShotgunGH/assaultshotgun_wm.md3','models/shotguns/AssaultShotgunGH/wm_assaultshotgun_mag.md3','models/shotguns/AssaultShotgunGH/AssaultShotgun.png',
          'models/shotguns/BullpupPump/bullpuppump_wm.md3','models/shotguns/BullpupPump/ssg.png',
          'models/plasma/Bolter/bolter_wm.md3','models/plasma/Bolter/wm_bolter_mag.md3','models/plasma/Bolter/bolter.png',
          'models/bfg/BFGRifle/bfgrifle_wm.md3','models/bfg/BFGRifle/BFG_9k.png',
          'models/chainguns/RotaryGun/rotarygun_wm.md3','models/chainguns/RotaryGun/Chaingun.png',
          'models/launchers/RotaryLauncher/rotarylauncher_wm.md3','models/launchers/RotaryLauncher/RPG.png',
          'models/chainsaws/LongbarChainsaw/longbarchainsaw_wm.md3','models/chainsaws/LongbarChainsaw/Saw.png',
          'zscript/rs_vr_weapons/unmaker.zs','models/unmaker/Unmaker/unmaker_wm.md3','models/unmaker/Unmaker/Unmaker.png','TRNSLATE.txt',
          'models/flamers/Flamer/flamer_wm.md3','models/flamers/Flamer/wm_flamer_can.md3','models/flamers/Flamer/flamer.png',
          'models/flamers/Flamethrower2/flamethrower2_wm.md3','models/flamers/Flamethrower2/wm_flamethrower2_can.md3','models/flamers/Flamethrower2/Flamethrower2.png',
          'models/grenades/nade.md3','models/grenades/nade.png','sounds/launchers/RLGCY.ogg',
          'language.txt','zscript/rs_grenade/rs_vrgrenade.zs','zscript/rs_grenade/rs_blast.zs','models/grenade/nade.md3','sounds/rs_grenade/GPIN','sprites/JGRNA0',
          'zscript/rs_shieldsaw/rs_shieldsaw.zs','zscript/rs_shieldsaw/rs_shieldsaw_state.zs','zscript/rs_shieldsaw/rs_shieldsaw_world.zs','sprites/SSAWA0.png',
          'sounds/chainguns/MGFIRE.ogg','sounds/chainguns/MGCHAIN.ogg','sounds/chainguns/MGLOAD.ogg','sounds/chainguns/MGSTRT.ogg','sounds/chainguns/MGSPIN.ogg','sounds/chainguns/MGSTOP.ogg',
          'sounds/launchers/RLFIRE.ogg','sounds/launchers/RLCOUT.ogg','sounds/launchers/RLCIN.ogg','sounds/launchers/RLCYCL.ogg',
          'sounds/plasma/PLFIRE1.ogg','sounds/plasma/PLFIRE2.ogg','sounds/plasma/PLFIRE3.ogg','sounds/plasma/PLCOUT.ogg','sounds/plasma/PLCIN.ogg','sounds/plasma/PLCHRG.ogg','sounds/plasma/PLBEEP.ogg','sounds/plasma/PLALTF.ogg',
          'sounds/bfg/BFGFIRE.ogg','sounds/bfg/BFGPFR.ogg','sounds/bfg/BFGCHRG.ogg','sounds/bfg/BFGOPN.ogg','sounds/bfg/BFGCOUT.ogg','sounds/bfg/BFGCLS.ogg','sounds/bfg/BFGCLI01.ogg','sounds/bfg/BFGCLI02.ogg','sounds/bfg/BFGCLI03.ogg',
          'sounds/chainsaws/CSTRT.ogg','sounds/chainsaws/CSIDLE.ogg','sounds/chainsaws/CSLOOP.ogg','sounds/chainsaws/CSTOP.ogg','sounds/chainsaws/CSOFF.ogg','sounds/chainsaws/CSZIP.ogg','sounds/chainsaws/SAWCORD.wav','sounds/chainsaws/CSHIT1.ogg','sounds/chainsaws/CSHIT2.ogg','sounds/chainsaws/CSHIT3.ogg','sounds/chainsaws/CSIDLE_HEAVY.wav','sounds/chainsaws/DSSAWIDL_LONGBAR.wav',
          'sounds/magdrops/DSAOUNC1.ogg','sounds/magdrops/DSAOUNC2.ogg','sounds/magdrops/DSAOUNC3.ogg',
          'TEXTURES.vp_pickups','graphics/vp_pickups/HBRIA0.png','graphics/vp_pickups/SMGZA0.png') }
foreach ($m in $must) {
    if ($names -notcontains $m) { throw "verification failed: $m missing" }
}

# EVERY MESH AND SKIN A MODELDEF BLOCK OR A CARD NAMES IS IN THIS PK3. The
# compile check cannot see this: -norun exits before models load. Lump names
# are case-insensitive, so the comparison is too.
#
# THE BASE ONLY. The add-on ships no MODELDEF, no Model Cards and no meshes -- every one of them is
# the base's -- so there is nothing here for it to resolve and the base's own references are not its
# to answer for.
$lower = @($names | ForEach-Object { $_.ToLowerInvariant() })
if ($isPlus) {
    Write-Output "$pk3Name  --  $($names.Count) entries, verified (add-on: no MODELDEF, no meshes of its own)"
} else {
$refs = @()
$path = ''
$modeldefPath = if ($isWW2) { Join-Path $root 'ww2\MODELDEF.txt' } elseif ($isRTCW) { Join-Path $root 'rtcw\MODELDEF.txt' } else { Join-Path $root 'MODELDEF.txt' }
foreach ($line in (Get-Content $modeldefPath)) {
    $t = ($line -replace '//.*$', '').Trim()
    if ($t -match '^Path\s+"([^"]+)"') { $path = $Matches[1] }
    elseif ($t -match '^(Model|Skin)\s+\d+\s+"([^"]+)"') { $refs += ("MODELDEF", "$path/$($Matches[2])") }
}
foreach ($line in ($cardFiles | ForEach-Object { Get-Content $_.FullName })) {
    $t = ($line -replace '#.*$', '').Trim()
    if ($t -match '^(model|skin|magmodel|magskin|roundmodel|roundskin)\s*=\s*"([^"]+)"\s+"([^"]+)"') {
        $refs += ("WMCARD $($Matches[1])", "$($Matches[2])/$($Matches[3])")
    }
}
for ($i = 0; $i -lt $refs.Count; $i += 2) {
    if ($lower -notcontains $refs[$i + 1].ToLowerInvariant()) { throw "verification failed: $($refs[$i]) names $($refs[$i + 1]), which is not in the pk3" }
}
Write-Output "$pk3Name  --  $($names.Count) entries, verified; $($refs.Count / 2) mesh/skin references resolve"

# ---- AND NOW THE OTHER DIRECTION: EVERY FILE MUST HAVE A REFERENCE ---------------------------
#
# THE FIFTH SHAPE, AND THE LAST ONE. Everything above runs REFERENCE -> FILE. Nothing ran
# FILE -> REFERENCE, and three separate strays shipped through that gap, every one found by a
# human looking sideways rather than by a check:
#
#   563 KiB  two unreferenced .jpg swept into the base by a widened extension filter, caught
#            by noticing the pack had grown
#   3.64 MiB per add-on, the base's whole sound/sprite/graphics tree packed twice, caught by
#            comparing CRCs against the base by hand
#   9.02 MiB the P38 and Nebelwerfer meshes -- two guns nobody has carded and nobody can
#            select -- caught by a consistency gate looking for something else
#
# A pack is not verified until both directions are. Dead weight is not a size problem on a local
# install; it is how the NEXT stray hides.
#
# READ THIS BEFORE TREATING THE ORPHAN LIST AS A DELETE LIST -- IT IS NOT ONE.
# THIS CHECK KNOWS ABOUT MODELDEF BLOCKS, CARDS, SHEETS AND SNDINFO ENTRIES AND NOTHING ELSE.
# An asset addressed from ZScript by path, or named by a DIFFERENT package's MODELDEF, is
# referenced perfectly well and will still be reported here -- and the report will be WRONG.
# A check is only as good as the reference sources it knows about.
#
# So an orphan is a QUESTION, not a verdict: go and find out who names it before removing it.
# That is not hypothetical caution -- the base's 78 were nearly taken for cleanup on the day
# this was written, and only a search across every live package settled it.
$namesBy = @{}
foreach ($i in 0..([Math]::Max($refs.Count - 2, 0))) { if ($i % 2 -eq 1) { $namesBy[$refs[$i].ToLowerInvariant()] = $true } }
# SNDINFO names a file per line: `<logical>  <path>`; TEXTURES and sprite lumps are named by
# LUMP rather than by path, so anything under sprites/ or graphics/ answers to its own stem.
foreach ($sf in @($rootLumps | Where-Object { $_ -match 'SNDINFO' })) {
    foreach ($line in (Get-Content (Join-Path $root $sf))) {
        $t = ($line -replace '//.*$', '').Trim()
        if ($t -match '^[$]?[A-Za-z0-9/_]+\s+([A-Za-z0-9/_.]+)\s*$') {
            $v = $Matches[1].ToLowerInvariant()
            $namesBy[$v] = $true
            foreach ($e in @('.ogg', '.wav', '.flac', '.mp3')) { $namesBy[$v + $e] = $true }
        }
    }
}
$orphans = @()
foreach ($n in $names) {
    $l = $n.ToLowerInvariant()
    # lumps, cards, sheets and code answer for themselves; sprites and graphics are addressed by
    # lump name from TEXTURES and from ZScript states, not by path.
    if ($l -match '\.(txt|zs|md)$' -or $l -notmatch '/') { continue }
    if ($l -like 'sprites/*' -or $l -like 'graphics/*' -or $l -like 'sounds/rs_grenade/*') { continue }
    if (-not $namesBy.ContainsKey($l)) { $orphans += $n }
}
if ($orphans.Count -gt 0) {
    $mb = [Math]::Round((($orphans | ForEach-Object { (Get-Item (Join-Path $root $_)).Length } | Measure-Object -Sum).Sum / 1MB), 2)
    Write-Output "  ORPHANS -- $($orphans.Count) packed file(s), $mb MiB, that NOTHING names:"
    foreach ($o in ($orphans | Select-Object -First 12)) { Write-Output "    $o" }
    if ($orphans.Count -gt 12) { Write-Output "    ... and $($orphans.Count - 12) more" }
    # HARD FAIL FOR A SET, LOUD REPORT FOR THE BASE, and the asymmetry is deliberate.
    #
    # A set's contents are fully described by its own card, so an orphan there is always a
    # mistake and both of tonight's were. THE BASE IS DIFFERENT: it has 78 orphans, 15.43 MiB,
    # led by models/ammo_hand -- and nothing in ANY live package names them. Only an archived
    # _old/ devbuild does. They are almost certainly dead, but "almost certainly" is not a
    # reason to drop 15 MiB out of the pack the owner actually plays, an hour before they test.
    #
    # So it prints every build and cannot be forgotten, and it does not block. Triage the list,
    # then turn this into a throw for the base too.
    if ($isAddon) {
        throw "verification failed: $($orphans.Count) packed file(s) are named by no MODELDEF block, card, sheet or SNDINFO entry -- pack what is referenced"
    }
    Write-Output "  (base: NOT fatal yet -- these need triage before this becomes a throw)"
}
}

# Each set installs beside its siblings under its own name, so all three can sit in the owner's
# folder and the load order picks one.
$installed = Join-Path $root $pk3Name

if ($NoCompileCheck) { Write-Output "compile check SKIPPED (-NoCompileCheck) -- packed to $out, NOT installed"; return }

# PROVE IT COMPILES, through the shared hidden check (hidden -norun, scratch
# config copy, scratch working directory -- see its header). The reload system
# first, then this package.
#
# IN PROCESS, not a child `powershell -File`: -File passes every argument as one
# string, so an array cannot reach -Files that way. compile_check.ps1's `exit`
# ends only that script and sets $LASTEXITCODE here.
if (-not (Test-Path $reloadPk3)) { throw "no reload system pk3 at $reloadPk3 -- build it first" }
# RS_BALLISTICS FIRST: the flamethrowers call its RSB_Flame for their flame (flamers.zs), a
# compile-time reference, so it loads before this package here as in the owner's order.
$ballisticsPk3 = 'E:\DOOMWork\RS_Ballistics\RS_Ballistics.pk3'
if (-not (Test-Path $ballisticsPk3)) { throw "no RS_Ballistics pk3 at $ballisticsPk3 -- the flamethrowers need it" }
# AN ADD-ON IS NOT A MOD ON ITS OWN: it derives from the base pack (WM_Gun, WM_Player,
# WM_SetBridge) and cannot compile without it, exactly as it cannot RUN without it. Checking one
# by itself reports "unknown base class" for every class it inherits -- which is the load order
# being wrong in the check, not a fault in the set. Base first, then the add-on, which is the
# owner's own order.
#
# THIS WAS MISSING, so no add-on set has ever had a valid compile check: every Plus and WW2 build
# was either checked without its parent (and failed for the wrong reason) or packed with
# -NoCompileCheck and never checked at all.
$checkFiles = @($ballisticsPk3, $reloadPk3)
if ($isAddon) {
    $basePk3 = Join-Path $root 'RS_VR_Weapons.pk3'
    if (-not (Test-Path $basePk3)) { throw "no base pk3 at $basePk3 -- build -Set Base first; an add-on cannot compile without it" }
    $checkFiles += $basePk3
}
$checkFiles += $out
& 'E:\DOOMWork\tools\compile_check.ps1' -Files $checkFiles
if ($LASTEXITCODE -ne 0) { throw "compile check FAILED -- see above; NOT installed, the owner's RS_VR_Weapons.pk3 is untouched" }
Copy-Item $out $installed -Force
Write-Output "installed $installed"
