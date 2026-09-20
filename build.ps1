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
#      AND IT COST REAL DAMAGE THE SAME NIGHT. The same gate flagged models/bwolf/P38 and
#      models/bwolf/Nebelwerfer as unreferenced weight -- true, they were -- and I took the label
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
param([switch]$NoCompileCheck, [ValidateSet('Base', 'Plus', 'BWolf', 'WW2', 'Aliens', 'Cola', 'HacX', 'Robocop', 'Blood', 'Bloom')][string]$Set = 'Base')
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
$isBWolf   = ($Set -eq 'BWolf')
$isWW2     = ($Set -eq 'WW2')
$isAliens  = ($Set -eq 'Aliens')
$isCola    = ($Set -eq 'Cola')
$isHacX    = ($Set -eq 'HacX')
$isRobocop = ($Set -eq 'Robocop')
$isBlood   = ($Set -eq 'Blood')
# BLOOM HAS ITS OWN CARDS NOW (the owner, 2026-09-20: "every set is its own set of cards"). It
# used to be the second set with none -- its sheet named `model = BL_*`, so its guns drew as
# BLOOD'S props off Blood's placement cvars, and tuning a Bloom gun moved the Blood one. WMCARD.bloom
# gives each gun its own id and its own prop and inherits the rest with `base =`, so the meshes and
# every measured number still live on Blood's cards and are not copied anywhere.
$isBloom   = ($Set -eq 'Bloom')
# EVERY SET BUT THE BASE IS AN ADD-ON and they pack the same shape -- own root lumps out of a source
# folder, own sheets, own zscript folder, AddPlayerClasses, nothing shared duplicated.
$isAddon   = ($isPlus -or $isBWolf -or $isWW2 -or $isAliens -or $isCola -or $isHacX -or $isRobocop -or $isBlood -or $isBloom)
$addonDir  = if ($isBWolf) { 'bwolf' } elseif ($isWW2) { 'ww2' } elseif ($isPlus) { 'plus' }
            elseif ($isAliens) { 'aliens' } elseif ($isCola) { 'cola' }
            elseif ($isHacX) { 'hacx' } elseif ($isRobocop) { 'robocop' } elseif ($isBlood) { 'blood' } elseif ($isBloom) { 'bloom' } else { '' }
$pk3Name   = if ($isBWolf) { 'RS_VR_Weapons_BWolf.pk3' } elseif ($isWW2) { 'RS_VR_Weapons_WW2.pk3' }
            elseif ($isPlus) { 'RS_VR_Weapons_Plus.pk3' } elseif ($isAliens) { 'RS_VR_Weapons_Aliens.pk3' }
            elseif ($isCola) { 'RS_VR_Weapons_Cola.pk3' } elseif ($isHacX) { 'RS_VR_Weapons_HacX.pk3' }
            elseif ($isRobocop) { 'RS_VR_Weapons_Robocop.pk3' } elseif ($isBlood) { 'RS_VR_Weapons_Blood.pk3' } elseif ($isBloom) { 'RS_VR_Weapons_Bloom.pk3' }
            else { 'RS_VR_Weapons.pk3' }
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
& python 'E:\DOOMWork\tools\menu_lint.py' $root --prefix 'wm_pump,wm_moonlight,wm_sunset,wm_cola,wm_rifle,wm_ssg,wm_doublebarrel,wm_m16,wm_tec9,wm_smg,wm_railgun,wm_plasmarifle,wm_plasmarifleblue,wm_plasmacarbine,wm_chaingun,wm_machinegun,wm_rocketlauncher,wm_rpg,wm_bfg,wm_bfgheavy,wm_chainsaw,wm_chainsawheavy,wm_flamer,wm_flamethrower,wm_assaultshotgun,wm_bullpuppump,wm_bolter,wm_bfgrifle,wm_rotarygun,wm_rotarylauncher,wm_longbarchainsaw,wm_unmaker,ae_flamer,ae_knife,ae_m37a2,ae_m4a3,ae_powerloader,ae_pulserifle,ae_satchel,ae_smartgun,bl_dynamite,bl_flaregun,bl_lifeleech,bl_lighter,bl_napalm,bl_pitchfork,bl_shotgun,bl_sigil,bl_spraycan,bl_teslagun,bl_tommygun,bl_voodoo,bw_1911,bw_axe,bw_bar,bw_chaingun,bw_flamethrower,bw_garand,bw_grenade,bw_kar98,bw_knife,bw_luger,bw_mg42,bw_mp40,bw_nebelwerfer,bw_p38,bw_ppsh,bw_shotgun,bw_stg44,bw_tommy,bw_ww2_bar,bw_ww2_browning,bw_ww2_colt,bw_ww2_fg42,bw_ww2_g43,bw_ww2_hdm,bw_ww2_luger,bw_ww2_mauser,bw_ww2_mg42,bw_ww2_mosin,bw_ww2_mp34,bw_ww2_mp40,bw_ww2_ppsh,bw_ww2_sten,bw_ww2_stg44,bw_ww2_thompson,bw_ww2_tt33,cl_carddeck,cl_frypan,cl_jackhammer,cl_ks23,cl_particlegun,cl_plasmagun,cl_revolver,cl_sidewinder,hx_cryogun,hx_melee,hx_nuker,hx_pistol,hx_reznator,hx_stick,hx_tazer,hx_uzi,hx_zooka,rc_auto9,rc_chaingun,rc_chainsaw,rc_cobra,rc_ksg,rc_m27,rc_m32,rc_shotgun,bm_dynamite,bm_flaregun,bm_lifeleech,bm_napalm,bm_pitchfork,bm_shotgun,bm_spraycan,bm_teslagun,bm_tommygun,bm_voodoo' --dep (Split-Path $reloadPk3) --dep 'E:\DOOMWork\UZDXREMA\wadsrc\static'
if ($LASTEXITCODE -ne 0) { throw "menu lint failed -- see above." }

# THE GUN CLASS WRITER: every Weapon Card with a `class` block gets its small class written
# (zscript/rs_vr_weapons/generated_guns.zs), so a new gun is only its card.
# PER SET: the Vanilla+ guns' classes belong to the add-on's own lump, because a class defined in
# both archives is fatal when they are loaded together. --sheets base skips WMSHEET.plus_*; --sheets
# plus takes only those.
& python (Join-Path $root '_pending\tools\make_gun_classes.py') --sheets $(if ($addonDir) { $addonDir } else { 'base' })
if ($LASTEXITCODE -ne 0) { throw "gun class writer refused a Weapon Card -- see above" }
# THE WEAPON CARDS LINT before anything packs: known keys, a class and a Model Card for every gun, a capacity the
# model can hold (_pending/card_lint.py --sheets).
& python (Join-Path $root '_pending' | Join-Path -ChildPath 'card_lint.py') --sheets | Select-Object -Last 1
if ($LASTEXITCODE -ne 0) { throw "a Weapon Card failed card_lint --sheets -- run it for the list" }

# AND THE LIVE MODEL CARDS -- WMCARD.*, the ones the engine actually reads.
#
# THIS BUILD HAS NEVER RUN THIS AND THAT IS THE WHOLE POINT OF ADDING IT. card_lint has a --wmcard
# mode that lints the shipped cards, and nothing called it: the build ran --sheets (the weapon
# cards, mine) and the bare form (which reads _pending/*.md, the DRAFTS). So every "issues: 23" any
# lane has reported was about documents nobody loads, while the cards the game reads went unchecked
# from the day the mode was written.
#
# WHAT IT FOUND ON ITS FIRST HONEST RUN: 37 dead sound names in WMCARD.bwolf. The BWolf/WW2 rename
# moved that set's SNDINFO to the `bwolf/` prefix and the cards kept saying `ww2/`, so EVERY RELOAD
# IN THE SET WAS SILENT -- every magazine in and out, every bolt, every rack, and the Garand's
# en-bloc ping, which is the most recognisable sound in the set. A sound name that resolves to
# nothing plays nothing and says nothing, exactly like a dead ballistics profile.
#
# REPORTS, DOES NOT THROW, AND ONLY FOR NOW. Sets that are carded but whose ZScript is not written
# yet legitimately fail its class and prop checks, and failing the build on those would block the
# work that fixes them. Make it a throw once every carded set has its classes. This is shape 5 in
# the header above -- a check that parses and therefore never looks -- with the twist that it was
# looking hard at the wrong file.
Write-Output "  ---- live model cards (WMCARD.*) ----"
& python (Join-Path $root '_pending' | Join-Path -ChildPath 'card_lint.py') --wmcard | Select-Object -Last 1

# THE ADD-ON BRINGS ONLY ITS OWN TWO, out of plus/, and they are packed AT THE ZIP ROOT. It declares
# no MODELDEF, CVARINFO, MENUDEF, KEYCONF, SNDINFO or language: every one of those is the base's, and
# a second copy would either replace the base's outright (MAPINFO-style keys) or define the same
# thing twice.
# WW2 brings a MODELDEF of its own as well, because it ships meshes. MODELDEF blocks accumulate
# across archives, so it sits beside the base's rather than replacing it.
# CREDITS SHIP WITH THE SET, not in a doc beside it. The models are community work used unaltered
# and the artists' names travel inside the pk3 -- that is the deal.
# AND A CVARINFO, WHICH IS THE ONE THAT WAS MISSING. The comment above was written when an add-on
# really did declare none, and it stopped being true twice: first MODELDEF, then SNDINFO, and both
# times the line above was left saying otherwise. CVARINFO accumulates across archives exactly like
# those two, so a set's lump sits beside the base's.
#
# WITHOUT IT A SET'S GUNS HAVE NO PLACEMENT SLIDERS AT ALL, which is not a missing luxury: every
# tuned set in the base pack carries `_yaw = -90.0`, so a gun with no set draws ninety degrees off.
# Thirty-five guns shipped that way in BWolf and WW2 and the owner found it wearing the headset.
#
# BWOLF AND WW2 USED TO HAVE THEIR OWN HAND-WRITTEN LISTS HERE AND THAT IS EXACTLY HOW THEY LOST
# THEIR MENUS. The $addonDir branch below was written later and grows a lump the moment a set ships
# one; a frozen list does not. MENUDEF was generated for all eight sets, six of them packed it, and
# the two oldest -- the two the owner actually had open in the headset -- silently did not, because
# their lists were written before the file existed. There is now ONE list for every add-on but
# Plus, so a new lump cannot reach six sets and miss two again.
$rootLumps = if ($isPlus) { @('plus/zscript.txt', 'plus/MAPINFO.txt', 'plus/MODELDEF.txt') }
             elseif ($addonDir) {
                 # OFF $addonDir, NOT A BRANCH PER SET. Three lumps every set has, and the rest
                 # only when that set actually ships them.
                 #
                 # A SET THAT BORROWS ANOTHER PACK'S MODEL CARDS HAS NO MODELDEF AND NO CVARINFO,
                 # and demanding them would be demanding a copy of somebody else's. Bloom is the
                 # case: it names `model = BL_*` on every gun, so the meshes, the props and the
                 # placement sliders are all the Blood pack's. Vanilla+ is the same shape against
                 # the base pack -- one pack's guns, another pack's geometry.
                 #
                 # SNDINFO is optional for the opposite reason: a set carded before its sounds are
                 # harvested has none, and demanding one would block the work that finds them.
                 $l = @("$addonDir/zscript.txt", "$addonDir/MAPINFO.txt", "$addonDir/CREDITS.txt")
                 foreach ($opt in @('MODELDEF.txt', 'CVARINFO.txt', 'SNDINFO.txt', 'MENUDEF.txt')) {
                     if (Test-Path (Join-Path $root "$addonDir/$opt")) { $l += "$addonDir/$opt" }
                 }
                 $l
             }
             else { @('zscript.txt', 'MAPINFO.txt', 'MODELDEF.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'KEYCONF.txt', 'SNDINFO.txt', 'language.txt', 'TRNSLATE.txt') }
$files = @()
foreach ($l in $rootLumps) {
    $p = Join-Path $root $l
    if (-not (Test-Path $p)) { throw "missing required lump: $l" }
    $files += Get-Item $p
}
# THE CARDS AND SHEETS: every root WMCARD.* and WMSHEET.* file (one lump name each, read in order).
# EACH SET'S OWN CARDS, filtered once here so the pack and the mesh-reference verifier below can
# never disagree about which cards this pk3 is answerable for. WMCARD.bwolf is the WW2 pack's;
# every other WMCARD.* is the base's.
# EVERY SET THAT OWNS A CARD AND A SHEET, AS A LIST. Written as a chain of -eq tests it had to be
# edited in four places per new set, and the base swallowed any set nobody remembered -- which is
# how the base pack came to name models/bloom/flaregun/flaregun_wm.md3, a mesh belonging to a set
# it does not ship. A set missing from this list is now the ONLY thing that can go wrong, and it
# fails loudly on the first build instead of silently packing another set's guns.
#
# Plus is deliberately absent: it owns no WMCARD (it borrows the base's) and its sheets are the
# WMSHEET.plus_* wildcard below rather than one name.
$setCards = @('bwolf', 'ww2', 'aliens', 'cola', 'hacx', 'robocop', 'blood', 'bloom')
$mySet    = if ($addonDir -and $addonDir -ne 'plus') { $addonDir } else { '' }
$cardFiles  = @(Get-ChildItem -Path $root -File -Filter 'WMCARD.*' | Sort-Object Name |
                Where-Object {
                    $suffix = $_.Name -replace '^WMCARD\.', ''
                    if ($setCards -contains $suffix) { $suffix -eq $mySet } else { $mySet -eq '' } })
# THE SHEETS SPLIT WITH THE CLASSES THEY DESCRIBE. WMSHEET.plus_* is the add-on's; every other sheet
# is the base's. A sheet in both archives would be read twice.
# Each set takes its own sheets only. The base takes everything that is nobody else's.
# OFF THE SAME LIST AS THE CARDS, for the same reason. The base takes every sheet that is nobody
# else's; each set takes exactly its own.
$sheetFiles = @(Get-ChildItem -Path $root -File -Filter 'WMSHEET.*' | Sort-Object Name | Where-Object {
                  $suffix = $_.Name -replace '^WMSHEET\.', ''
                  $someSets = ($_.Name -like 'WMSHEET.plus_*') -or ($setCards -contains $suffix)
                  if ($isPlus) { $_.Name -like 'WMSHEET.plus_*' }
                  elseif ($mySet) { $suffix -eq $mySet }
                  else { -not $someSets } })
# EVERY SET IS ITS OWN SET OF CARDS (the owner, 2026-09-20). Bloom used to be the second
# exception here and is not any more: it has WMCARD.bloom, ten cards that inherit Blood's
# measurements with `base =` and state their own id and their own prop -- so its guns are its own
# objects, with their own placement cvars and their own sliders, while not one measured number is
# copied. Plus is the one that remains, and only because its thirty-four guns are the BASE PACK'S
# guns by design: a Vanilla+ shotgun IS the vanilla shotgun with different numbers, and the owner
# has tuned those placements by hand in the headset.
if (-not $isPlus -and $cardFiles.Count -eq 0) { throw 'missing required lump: no WMCARD.* file' }
if ($sheetFiles.Count -eq 0) { throw "no WMSHEET.* files for -Set $Set" }
# WMCARD.bwolf is the WW2 pack's; every other WMCARD.* is the base's.
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
              $inWW2  = $_.FullName -like '*\rs_vr_weapons_bwolf\*'
              $inRTCW = $_.FullName -like '*\rs_vr_weapons_ww2\*'
              # EVERY SET FOLDER OFF ITS OWN NAME, not a variable per set. The base takes what is
              # nobody else's; each set takes exactly its own folder. The old chain needed a new
              # branch AND a new term in the base's exclusion for every set, and the second was the
              # one that got forgotten -- which drops another set's classes into the base pack,
              # where a class defined twice is a fatal, GLOBAL load error.
              #
              # NOTE the folder names are the zscript ones: rs_vr_weapons_ww2 is the WW2 SET, and
              # rs_vr_weapons_bwolf is BWolf's. They read backwards against the old $inWW2/$inRTCW
              # variables above, which are left from before the rename and are why this is now
              # derived from $addonDir rather than spelled out.
              $setDirs = @('plus','bwolf','ww2','aliens','cola','hacx','robocop','blood','bloom')
              $f = $_.FullName
              if ($addonDir) { $f -like "*\rs_vr_weapons_$addonDir\*" }
              else { -not ($setDirs | Where-Object { $f -like "*\rs_vr_weapons_$_\*" }) } }
# MESHES: WW2 takes models/bwolf and only that; the base takes everything that is not another set's.
# WHICH MESHES THIS PACK SHIPS: the ones ITS OWN MODELDEF and ITS OWN cards name, and nothing
# else. Asking "which folder is it in" was the old question and it was the wrong one -- Vanilla+'s
# twenty-seven guns live in the shared models/ tree, so the base swept them all up and shipped
# 20.4 MB of guns it never hands out while Vanilla+ came to 13 KB of text.
$mdForPack = if ($addonDir) { "$addonDir/MODELDEF.txt" } else { 'MODELDEF.txt' }
$wanted = @{}
$mdPath = ''
# A PACK WITH NO MODELDEF SHIPS NO MESHES, which is not a failure -- it is what a set that borrows
# another pack's model cards looks like. Bloom names `model = BL_*` on every gun and Vanilla+ names
# the base pack's, so for both of them the correct answer to "which meshes do you ship" is none.
$mdFull = Join-Path $root $mdForPack
$mdLines = @()
if (Test-Path $mdFull) { $mdLines = Get-Content $mdFull }
foreach ($line in $mdLines) {
    $t = ($line -replace '//.*$', '').Trim()
    if ($t -match '^Path\s+"([^"]+)"') { $mdPath = $Matches[1] }
    elseif ($t -match '^(Model|Skin)\s+\d+\s+"([^"]+)"') { $wanted["$mdPath/$($Matches[2])".ToLowerInvariant()] = $true }
}
# and the loose magazines and rounds its own cards name, which no MODELDEF block mentions
foreach ($line in ($cardFiles | ForEach-Object { Get-Content $_.FullName })) {
    $t = ($line -replace '#.*$', '').Trim()
    if ($t -match '^(magmodel|magskin|magskinempty|roundmodel|roundskin|linkmodel|linkskin)\s*=\s*"([^"]+)"\s+"([^"]+)"') {
        $wanted["$($Matches[2])/$($Matches[3])".ToLowerInvariant()] = $true
    }
}
# THE ADD-ON DECLARES ALMOST NOTHING, so it is verified against its own short list.
# BWolf and WW2 had frozen lists here too, for the same reason and with the same result: the check
# that is meant to catch a missing lump was itself written before half the lumps existed. One list.
$must = if ($isPlus) { @('zscript.txt','MAPINFO.txt') }
        elseif ($addonDir -and $addonDir -ne 'plus') {
            # THREE THAT EVERY SET HAS, AND ITS OWN SHEET. The rest are demanded only when the set
            # actually owns them -- a set that borrows another pack's model cards has no MODELDEF,
            # no CVARINFO and no WMCARD of its own, and requiring them would be requiring a copy of
            # somebody else's geometry. Bloom is that set: every gun names `model = BL_*`.
            $m = @('zscript.txt','MAPINFO.txt',"WMSHEET.$addonDir")
            foreach ($opt in @('MODELDEF.txt','CVARINFO.txt','SNDINFO.txt','MENUDEF.txt')) {
                if (Test-Path (Join-Path $root "$addonDir/$opt")) { $m += $opt }
            }
            if (Test-Path (Join-Path $root "WMCARD.$addonDir")) { $m += "WMCARD.$addonDir" }
            $m
        }
        else {
@('zscript.txt','MODELDEF.txt','CVARINFO.txt','MENUDEF.txt','MAPINFO.txt','KEYCONF.txt','SNDINFO.txt',
          'zscript/rs_vr_weapons/pistols.zs','zscript/rs_vr_weapons/shotguns.zs','zscript/rs_vr_weapons/loadout.zs',
          'zscript/rs_vr_weapons/weaponset.zs',
          'models/vanilla/pistols/m4a3.md3','models/vanilla/pistols/m4a3.png','models/vanilla/pistols/pistolet.md3','models/vanilla/pistols/WPN-9mm.png',
          'models/vanilla/pistols/wm_m4a3_mag.md3','models/vanilla/pistols/wm_pistolet_mag.md3',
          'models/vanilla/pistols/bullet.md3','models/vanilla/pistols/bullet.png',
          'sounds/pistols/PFIRE01.ogg','sounds/pistols/PFIRE02.ogg','sounds/pistols/PFIRE03.ogg',
          'sounds/pistols/PCOUT.ogg','sounds/pistols/PCIN.ogg','sounds/pistols/PSLID.ogg','sounds/pistols/PSNAP.ogg',
          'sounds/pistols/9mmshoot.wav','sounds/pistols/9mmclip1.wav','sounds/pistols/9mmclip2.wav','sounds/pistols/9mmslide.wav',
          'sounds/rifles/RIFIRE1.ogg','sounds/rifles/RIFIRE2.ogg','sounds/rifles/RIFIRE3.ogg','sounds/rifles/RCOUT.ogg',
          'sounds/rifles/RCIN.ogg','sounds/rifles/RCKBCK.ogg','sounds/rifles/RCKFWD.ogg',
          'sounds/revolvers/SINGLE1.ogg','sounds/revolvers/SINGLE2.ogg','sounds/revolvers/DBOPN.ogg',
          'sounds/revolvers/DBCLS.ogg','sounds/revolvers/DBLOD.ogg',
          'models/vanilla/shotguns/AE_Shotgun/m37a2.md3','models/vanilla/shotguns/AE_Shotgun/m37a2.png',
          'models/vanilla/shotguns/Shotgun/shotgun.md3','models/vanilla/shotguns/Shotgun/WPN-GUNS-k1.png',
          'models/vanilla/shotguns/Shotgun/wm_shotshell.md3',
          'models/vanilla/shotguns/SuperShotgun/ssg.md3','models/vanilla/shotguns/SuperShotgun/WPN-GUNS-k1.png',
          'models/vanilla/shotguns/DoubleBarrel/doublebarrel_wm.md3','models/vanilla/shotguns/DoubleBarrel/wm_doublebarrel_shell.md3',
          'models/vanilla/shotguns/DoubleBarrel/ssg_HD.png','models/vanilla/shotguns/DoubleBarrel/shells.png',
          'sounds/shotguns/DoubleBarrel/ssgfire.ogg','sounds/shotguns/DoubleBarrel/DSDBOPN.ogg',
          'sounds/shotguns/DoubleBarrel/DSDBCLS.ogg','sounds/shotguns/DoubleBarrel/CLIPINSS.ogg',
          'zscript/rs_vr_weapons/revolvers.zs',
          'models/vanilla/revolvers/Revolver/rev_wm.md3','models/vanilla/revolvers/Revolver/wm_speedloader.md3',
          'models/vanilla/revolvers/Revolver/WPN-REV.png','models/vanilla/revolvers/Revolver/WPN-REV2.png',
          'models/vanilla/revolvers/Cola_Revolver/revolver.md3','models/vanilla/revolvers/Cola_Revolver/revolver.png',
          'models/vanilla/revolvers/Cola_Revolver/wm_cola_rounds.md3',
          'zscript/rs_vr_weapons/rifles.zs','zscript/rs_vr_weapons/ssg.zs',
          'models/vanilla/rifles/Rifle/Rifle.md3','models/vanilla/rifles/Rifle/Rifle.png','models/vanilla/rifles/Rifle/wm_rifle_mag.md3',
          'models/vanilla/rifles/M16/m16_wm.md3','models/vanilla/rifles/M16/WPN-M16-k1.png','models/vanilla/rifles/M16/wm_m16_mag.md3',
          'zscript/rs_vr_weapons/smgs.zs',
          'models/vanilla/smgs/Tec9/tec9_wm.md3','models/vanilla/smgs/Tec9/tec9.png','models/vanilla/smgs/Tec9/wm_tec9_mag.md3',
          'models/vanilla/smgs/SMG/smg_wm.md3','models/vanilla/smgs/SMG/smg.png','models/vanilla/smgs/SMG/wm_smg_mag.md3',
          'zscript/rs_vr_weapons/railguns.zs',
          'models/vanilla/railguns/Railgun/railgun_wm.md3','models/vanilla/railguns/Railgun/railgun.png','models/vanilla/railguns/Railgun/wm_railgun_mag.md3',
          'zscript/rs_vr_weapons/plasma.zs',
          'models/vanilla/plasma/PlasmaRifle/plasmarifle_wm.md3','models/vanilla/plasma/PlasmaRifle/wm_plasmarifle_cell.md3','models/vanilla/plasma/PlasmaRifle/PlasmaRifle.png',
          'models/vanilla/plasma/PlasmaCarbine/plasmacarbine_wm.md3','models/vanilla/plasma/PlasmaCarbine/wm_plasmacarbine_cell.md3','models/vanilla/plasma/PlasmaCarbine/plasmacarbine.png',
          'zscript/rs_vr_weapons/chainguns.zs',
          'models/vanilla/chainguns/ChaingunGH/chaingungh_wm.md3','models/vanilla/chainguns/ChaingunGH/Minigun.png','models/vanilla/chainguns/Chaingun/cg_ammoclip.md3','models/vanilla/chainguns/Chaingun/chaingun_HD.png',
          'models/vanilla/chainguns/MachineGun/machinegun_wm.md3','models/vanilla/chainguns/MachineGun/wm_machinegun_mag.md3','models/vanilla/chainguns/MachineGun/Machinegun.png',
          'zscript/rs_vr_weapons/launchers.zs',
          'models/vanilla/launchers/RPG/rpg_wm.md3','models/vanilla/launchers/RPG/rpg.png','models/vanilla/launchers/RPG/wm_rpg_mag.md3','models/vanilla/launchers/RPG/wm_rocket.md3',
          'zscript/rs_vr_weapons/bfg.zs',
          'models/vanilla/bfg/BFG/bfg9000.png','models/vanilla/bfg/BFG/bfg9000_off.png',
          'models/vanilla/bfg/BFGHeavy/bfgheavy_wm.md3','models/vanilla/bfg/BFGHeavy/wm_bfgheavy_cell.md3','models/vanilla/bfg/BFGHeavy/bfg.png',
          'zscript/rs_vr_weapons/chainsaws.zs',
          'models/vanilla/chainsaws/Chainsaw/chainsaw_wm.md3','models/vanilla/chainsaws/Chainsaw/chainsaw.png',
          'models/vanilla/chainsaws/ChainsawHeavy/chainsaw_heavy_wm.md3','models/vanilla/chainsaws/ChainsawHeavy/chainsaw.png',
          'zscript/rs_vr_weapons/flamers.zs',
          'zscript/rs_vr_weapons/meatgrinder.zs',
          'models/vanilla/shotguns/AssaultShotgunGH/assaultshotgun_wm.md3','models/vanilla/shotguns/AssaultShotgunGH/wm_assaultshotgun_mag.md3','models/vanilla/shotguns/AssaultShotgunGH/AssaultShotgun.png',
          'models/vanilla/shotguns/BullpupPump/bullpuppump_wm.md3','models/vanilla/shotguns/BullpupPump/ssg.png',
          'models/vanilla/plasma/Bolter/bolter_wm.md3','models/vanilla/plasma/Bolter/wm_bolter_mag.md3','models/vanilla/plasma/Bolter/bolter.png',
          'models/vanilla/bfg/BFGRifle/bfgrifle_wm.md3','models/vanilla/bfg/BFGRifle/BFG_9k.png',
          'models/vanilla/chainguns/RotaryGun/rotarygun_wm.md3','models/vanilla/chainguns/RotaryGun/Chaingun.png',
          'models/vanilla/launchers/RotaryLauncher/rotarylauncher_wm.md3','models/vanilla/launchers/RotaryLauncher/RPG.png',
          'models/vanilla/chainsaws/LongbarChainsaw/longbarchainsaw_wm.md3','models/vanilla/chainsaws/LongbarChainsaw/Saw.png',
          'zscript/rs_vr_weapons/unmaker.zs','models/vanilla/unmaker/Unmaker/unmaker_wm.md3','models/vanilla/unmaker/Unmaker/Unmaker.png','TRNSLATE.txt',
          'models/vanilla/flamers/Flamer/flamer_wm.md3','models/vanilla/flamers/Flamer/wm_flamer_can.md3','models/vanilla/flamers/Flamer/flamer.png',
          'models/vanilla/flamers/Flamethrower2/flamethrower2_wm.md3','models/vanilla/flamers/Flamethrower2/wm_flamethrower2_can.md3','models/vanilla/flamers/Flamethrower2/Flamethrower2.png',
          'models/vanilla/grenades/nade.md3','models/vanilla/grenades/nade.png','sounds/launchers/RLGCY.ogg',
          'language.txt','zscript/rs_grenade/rs_vrgrenade.zs','zscript/rs_grenade/rs_blast.zs','models/vanilla/grenade/nade.md3','sounds/rs_grenade/GPIN','sprites/JGRNA0',
          'zscript/rs_shieldsaw/rs_shieldsaw.zs','zscript/rs_shieldsaw/rs_shieldsaw_state.zs','zscript/rs_shieldsaw/rs_shieldsaw_world.zs','sprites/SSAWA0.png',
          'sounds/chainguns/MGFIRE.ogg','sounds/chainguns/MGCHAIN.ogg','sounds/chainguns/MGLOAD.ogg','sounds/chainguns/MGSTRT.ogg','sounds/chainguns/MGSPIN.ogg','sounds/chainguns/MGSTOP.ogg',
          'sounds/launchers/RLFIRE.ogg','sounds/launchers/RLCOUT.ogg','sounds/launchers/RLCIN.ogg','sounds/launchers/RLCYCL.ogg',
          'sounds/plasma/PLFIRE1.ogg','sounds/plasma/PLFIRE2.ogg','sounds/plasma/PLFIRE3.ogg','sounds/plasma/PLCOUT.ogg','sounds/plasma/PLCIN.ogg','sounds/plasma/PLCHRG.ogg','sounds/plasma/PLBEEP.ogg','sounds/plasma/PLALTF.ogg',
          'sounds/bfg/BFGFIRE.ogg','sounds/bfg/BFGPFR.ogg','sounds/bfg/BFGCHRG.ogg','sounds/bfg/BFGOPN.ogg','sounds/bfg/BFGCOUT.ogg','sounds/bfg/BFGCLS.ogg','sounds/bfg/BFGCLI01.ogg','sounds/bfg/BFGCLI02.ogg','sounds/bfg/BFGCLI03.ogg',
          'sounds/chainsaws/CSTRT.ogg','sounds/chainsaws/CSIDLE.ogg','sounds/chainsaws/CSLOOP.ogg','sounds/chainsaws/CSTOP.ogg','sounds/chainsaws/CSOFF.ogg','sounds/chainsaws/CSZIP.ogg','sounds/chainsaws/SAWCORD.wav','sounds/chainsaws/CSHIT1.ogg','sounds/chainsaws/CSHIT2.ogg','sounds/chainsaws/CSHIT3.ogg','sounds/chainsaws/CSIDLE_HEAVY.wav','sounds/chainsaws/DSSAWIDL_LONGBAR.wav',
          'sounds/magdrops/DSAOUNC1.ogg','sounds/magdrops/DSAOUNC2.ogg','sounds/magdrops/DSAOUNC3.ogg',
          'TEXTURES.vp_pickups','graphics/vp_pickups/HBRIA0.png','graphics/vp_pickups/SMGZA0.png') }

# AND ANYTHING THE PACK'S OWN REQUIRED-FILE LIST DEMANDS. That list is a reference too -- a
# hand-written one -- and models/vanilla/shotguns/Shotgun/wm_shotshell.md3 is named by NOTHING ELSE in any
# package: no card, no MODELDEF, no ZScript. It may be dead or it may be reached a way none of our
# checks can see, and dropping a loose shotgun shell to find out is not a trade worth making.
foreach ($m in $must) { if ($m -like 'models/*') { $wanted[$m.ToLowerInvariant()] = $true } }
$files += Get-ChildItem -Path (Join-Path $root 'models') -Recurse -File | Where-Object {
    $rel = ($_.FullName.Substring($root.Length + 1)) -replace ([regex]::Escape([char]92)), '/'
    $wanted.ContainsKey($rel.ToLowerInvariant()) }
if ($false) { $files += Get-ChildItem -Path (Join-Path $root 'models') -Recurse -File | Where-Object {
                      # JPEG IS THE RTCW SET'S ONLY, and deliberately not general. Its skins ship as
                      # wpn_base.jpg rather than PNG and GZDoom reads either, so the set needs it --
                      # but allowing .jpg everywhere swept two UNREFERENCED files into the base pack
                      # (models/shared/ammo_hand/berettam9.jpg and its _HD twin, 563 KB between them) that
                      # no MODELDEF or card names. The verifier only catches a reference with no
                      # file, never a file with no reference, so that would have ridden along unseen.
                      ($_.Extension -in '.md3', '.png', '.obj' -or ($isWW2 -and $_.Extension -in '.jpg', '.jpeg')) -and
                      (($_.FullName -like '*\models\bwolf\*') -eq $isBWolf) -and
                      (($_.FullName -like '*\models\ww2\*') -eq $isWW2) } }
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
    # its own folder only -- sounds/bwolf/... for WW2, and RTCW has none of its own because its
    # guns point at sound NAMES the base already defines.
    if ($addonDir) { $files += $soundsAll | Where-Object { $_.FullName -like "*\sounds\$addonDir\*" } }
} else {
    # AND THE BASE TAKES NONE OF THEIRS. sounds/bwolf/ is the WW2 set's; without this exclusion the
    # base grew by exactly those 82 files the moment that folder appeared -- the same duplication
    # in the other direction, and the reason to state it as "everything that is nobody else's"
    # rather than "everything".
    # EVERY SET FOLDER, AS A LIST. Adding a set is one entry here; it used to be one more -notlike
    # in a chain, and the base silently grew by exactly 82 files the first time a set folder
    # appeared without this being updated -- then by 160 more when Aliens and Cola landed, which
    # is how this list came to exist rather than a third -notlike.
    $setSoundDirs = @('bwolf', 'rtcw', 'ww2', 'aliens', 'cola')
    $files += $soundsAll | Where-Object {
                  $f = $_.FullName
                  -not ($setSoundDirs | Where-Object { $f -like "*\sounds\$_\*" }) }
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
# THE MODELDEF THIS PACK ACTUALLY SHIPS, off $addonDir rather than a per-set chain. Written as a
# chain it named the BASE's MODELDEF for any set not listed, so a new set verified its meshes
# against the wrong file and failed on Vanilla's pistol -- a set the verifier could not see,
# reporting a fault that was not there.
$modeldefPath = if ($addonDir) { Join-Path $root "$addonDir\MODELDEF.txt" } else { Join-Path $root 'MODELDEF.txt' }
# AND A PACK WITH NO MODELDEF NAMES NO MESHES, so there is nothing for this to verify. That is the
# correct state for a set that borrows another pack's model cards, not a missing file.
$mdVerify = @()
if (Test-Path $modeldefPath) { $mdVerify = Get-Content $modeldefPath }
foreach ($line in $mdVerify) {
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
# A SET MAY NAME A MESH THAT LIVES IN THE PACK IT DEPENDS ON, and Bloom is the case: its ten guns
# are Blood's objects with Bloom's numbers, so its cards inherit Blood's meshes with `base =` and
# its MODELDEF names models/blood/*. Packing those a second time is the THIRD SHAPE in this file's
# own header -- another pack's tree duplicated, megabytes of it -- so the answer is not to ship
# them but to CHECK THE PACK THAT DOES.
#
# THIS IS NOT A BYPASS AND MUST NEVER BECOME ONE. The reference is still proved to resolve, and it
# is proved against the INSTALLED dependency -- the same file the owner loads -- rather than waved
# past. A set naming a mesh nobody ships still fails here exactly as before, and a missing
# dependency is a hard failure rather than a silent skip.
$depPk3 = if ($isBloom) { Join-Path $root 'RS_VR_Weapons_Blood.pk3' } else { '' }
$depLower = @()
if ($depPk3) {
    if (-not (Test-Path $depPk3)) { throw "-Set $Set needs $(Split-Path -Leaf $depPk3) installed to verify its mesh references, and it is not there" }
    $dz = [System.IO.Compression.ZipFile]::OpenRead($depPk3)
    $depLower = @($dz.Entries | ForEach-Object { $_.FullName.ToLowerInvariant() })
    $dz.Dispose()
}
$viaDep = 0
for ($i = 0; $i -lt $refs.Count; $i += 2) {
    $want = $refs[$i + 1].ToLowerInvariant()
    if ($lower -contains $want) { continue }
    if ($depLower -contains $want) { $viaDep++; continue }
    throw "verification failed: $($refs[$i]) names $($refs[$i + 1]), which is not in the pk3"
}
$depNote = if ($viaDep) { ", $viaDep of them in $(Split-Path -Leaf $depPk3)" } else { '' }
Write-Output "$pk3Name  --  $($names.Count) entries, verified; $($refs.Count / 2) mesh/skin references resolve$depNote"

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
# OFF BY ONE, AND IT DROPPED THE LAST REFERENCE EVERY TIME. `$refs` is a flat list of
# (what named it, what it named) pairs, so the values sit at the ODD indices and the last of them
# is at Count-1. This loop ran to Count-2 and never reached it.
#
# It surfaced on HacX: the final reference collected was the Zooka's `roundskin`, so bolt.png was
# reported as a file NOTHING NAMES while the card two lines up named it plainly. A check that is
# wrong by exactly one, at the end, is the worst kind -- it is right about everything you spot-check
# and wrong about the one thing you did not, and it cries wolf rather than staying silent, which is
# how a real orphan gets waved through next time.
$namesBy = @{}
for ($i = 1; $i -lt $refs.Count; $i += 2) { $namesBy[$refs[$i].ToLowerInvariant()] = $true }
# SNDINFO names a file per line: `<logical>  <path>`; TEXTURES and sprite lumps are named by
# LUMP rather than by path, so anything under sprites/ or graphics/ answers to its own stem.
foreach ($sf in @($rootLumps | Where-Object { $_ -match 'SNDINFO' })) {
    foreach ($line in (Get-Content (Join-Path $root $sf))) {
        $t = ($line -replace '//.*$', '').Trim()
        # THE PATH CHARACTER CLASS IS WIDE ON PURPOSE. It was [A-Za-z0-9/_.] and Cola 3 shipped a
        # folder called `showdown!` -- so eight named, shipped, perfectly good sounds matched
        # nothing here and were reported as files nothing names. Shape 7 again, in miniature: the
        # check could not SEE the line, and said the file was unreferenced rather than unreadable.
        # A path character this does not know must never read as an absent reference.
        if ($t -match '^[$]?[A-Za-z0-9/_]+\s+([A-Za-z0-9/_.!+@~$%^&(){}\[\];,''`-]+)\s*$') {
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
    # led by models/shared/ammo_hand -- and nothing in ANY live package names them. Only an archived
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
    # AN ADD-ON OF AN ADD-ON NEEDS ITS PARENT TOO. Bloom borrows the Blood pack's model cards, its
    # meshes and its props, and BM_SprayCan derives from BL_SprayCan -- so checking Bloom without
    # Blood reports every one of its guns as undefined, which is the load order being wrong in the
    # check rather than a fault in the set. That is the same mistake as compile-checking any add-on
    # without the base, which cost us every Plus and WW2 build for weeks.
    if ($isBloom) {
        $bloodPk3 = Join-Path $root 'RS_VR_Weapons_Blood.pk3'
        if (-not (Test-Path $bloodPk3)) { throw "no Blood pk3 at $bloodPk3 -- build -Set Blood first; Bloom borrows its cards, meshes and props" }
        $checkFiles += $bloodPk3
    }
}
$checkFiles += $out
& 'E:\DOOMWork\tools\compile_check.ps1' -Files $checkFiles
if ($LASTEXITCODE -ne 0) { throw "compile check FAILED -- see above; NOT installed, the owner's RS_VR_Weapons.pk3 is untouched" }
Copy-Item $out $installed -Force
Write-Output "installed $installed"
