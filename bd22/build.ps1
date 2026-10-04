# =============================================================================
# RS_VR_BD22 -- pack Brutal Doom v22's guns into a loadable pk3.
#
#     powershell -File E:\DOOMWork\RS_VR_BD22\build.ps1
#     powershell -File E:\DOOMWork\RS_VR_BD22\build.ps1 -NoCompileCheck
#
# WHY THIS SET HAS ITS OWN BUILD. RS_VR_Weapons' build.ps1 knows two shapes: the base
# pack, and an add-on that brings only root lumps out of a <set>/ folder and leans on
# the base for its MODELDEF, CVARINFO, MENUDEF and meshes. This set is neither. It
# carries ALL of its own -- 25 guns, their meshes, their skins, BD's own reload foley --
# and RS_VR_Weapons now holds Vanilla and Vanilla+ and nothing else, by instruction.
#
# WHAT IT STILL NEEDS BESIDE IT, and this is not a gap in the packing:
#   RS_VR_Weapons.pk3   WM_Gun, WM_Prop, WM_Player, WM_SetBridge -- the gun FRAMEWORK.
#                       A class defined in two archives is a fatal, global load error,
#                       so this pack cannot carry its own copy; it derives from them.
#   RS_VR_Reload.pk3    the reload system itself, which reads WMCARD.bd22.
#
# IT DOES NOT NEED BRUTAL DOOM. With plain Doom the bridge swaps Doom's own pickups for
# these guns. With Brutal Doom loaded the bridge notices and swaps ITS guns too.
#
# THE VERIFY STEP IS NOT DECORATION. A MODELDEF block naming a file that is not in the
# zip is valid to GZDoom and draws nothing, silently -- that is how sixteen WW2 models
# once shipped that nothing addressed. Every mesh and skin the card names is checked to
# be IN the archive, not merely on disk.
# =============================================================================
param([switch]$NoCompileCheck)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pk3  = Join-Path $root 'RS_VR_BD22.pk3'
$stage = Join-Path $env:TEMP 'rs_vr_bd22_stage'

# ---- WHAT GOES IN. Everything the game reads, and nothing else: no build script, no
# working notes, no .bak files left by a tool.
$include = @('MAPINFO.txt','MODELDEF.txt','CVARINFO.txt','MENUDEF.txt','SNDINFO.txt','RSBDEFS.txt',
             'WMCARD.bd22','WMSHEET.bd22','zscript.txt','zscript','models','sounds')

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory $stage -Force | Out-Null
foreach ($i in $include) {
    $src = Join-Path $root $i
    if (-not (Test-Path $src)) { throw "missing from the pack: $i" }
    Copy-Item $src (Join-Path $stage $i) -Recurse -Force
}
# A .bak is a tool's leftover, never content.
Get-ChildItem $stage -Recurse -Include '*.bak','*.orig' | Remove-Item -Force -ErrorAction SilentlyContinue

if (Test-Path $pk3) { Remove-Item $pk3 -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $pk3)

# ---- VERIFY: every mesh and skin the CARD names is actually in the archive.
$zip = [System.IO.Compression.ZipFile]::OpenRead($pk3)
$entries = @{}
foreach ($e in $zip.Entries) { $entries[$e.FullName.Replace('\','/').ToLower()] = $true }
$card = Get-Content (Join-Path $root 'WMCARD.bd22') -Raw
$refs = [regex]::Matches($card, '(?m)^\s*(?:model|skin|magmodel|magskin|roundmodel|roundskin)\s*=\s*"([^"]+)"\s*"([^"]+)"')
$missing = @()
foreach ($m in $refs) {
    $p = ($m.Groups[1].Value + '/' + $m.Groups[2].Value).Replace('\','/').ToLower()
    if (-not $entries.ContainsKey($p)) { $missing += $p }
}
$count = $zip.Entries.Count
$zip.Dispose()
if ($missing.Count -gt 0) {
    throw ("verification failed: the card names " + $missing.Count + " file(s) not in the pk3, first: " + $missing[0])
}
Write-Host ("RS_VR_BD22.pk3  --  {0} entries, verified; {1} mesh/skin references resolve" -f $count, $refs.Count)

if ($NoCompileCheck) { Write-Host 'compile check skipped -- NOT verified as loadable'; exit 0 }

$check = 'E:\DOOMWork\tools\compile_check.ps1'
if (-not (Test-Path $check)) { Write-Host "no compile_check.ps1 -- skipped"; exit 0 }
# CALLED DIRECTLY, NOT VIA `powershell -File`: -File flattens an array into separate
# positional arguments, so the second pk3 lands in -TimeoutSec and the check dies.
# BRUTAL DOOM IS CHECKED WITH IT, because the bridge and the Players/Slots pk3s are
# written against Brutal Doom's class names. (The guns no longer say `replaces` --
# ZScript cannot replace a DECORATE class, and that keyword stopped the pack loading.)
#
# THE PATH WAS BROKEN. It read ...\BD22 ModelDefs<backspace>rutal22test6... -- a tool
# had turned "\b" into a backspace character -- so the check never actually loaded
# Brutal Doom. It points at the copy beside this script now.
& $check -Files @(
    (Join-Path $root 'brutal22test6.pk3'),
    'E:\DOOMWork\RS_Ballistics\RS_Ballistics.pk3',
    'E:\DOOMWork\RS_VR_Reload\RS_VR_Reload.pk3',
    'E:\DOOMWork\RS_VR_Weapons\RS_VR_Weapons.pk3',
    $pk3)
exit $LASTEXITCODE
