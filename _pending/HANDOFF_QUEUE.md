# Weapons lane — handoffs waiting for a builder (2026-09-13)

> **UPDATE, later 2026-09-13.** The owner unpaused uzdxrema-11 (reload lane). Each lane now builds
> and compile-checks its own mod pk3; the engine is never built, and nothing is committed unless
> the owner says so.
>
> RS_VR_Weapons.pk3 was rebuilt by the weapons lane with build.ps1 and **COMPILED** against
> RS_VR_Reload.pk3 (08:21) with the 08:31 exe. That covers batches A, B and the launcher grenade
> and flame rounds. It is still **not committed**.
>
> `-norun` exits before models load, so MODELDEF lines are not proven by the check (the new
> blocks, and the grenade's PivotOffset).
>
> A backup of the previous pk3 is in the weapons session scratchpad `lead/pk3_backup/`.
>
> **PLASMA FAMILY LIVE (later 2026-09-13).** uzdxrema-11's step 1 compiled (RS_VR_Reload.pk3
> 14:17: firesfrom, casing, RoundsPerShot, ShotClass, ShotRail, RailColors). Then
> `merge_live.py plasma` did all of this:
> - put WM_PlasmaRifle and WM_PlasmaCarbine's cards into WMCARD
> - turned on AmmoType1 Cell and ShotClass PlasmaBall
> - added StartItems + Cell 300, slot 9, wm_giveplasma (event, alias, menu row)
>
> RS_VR_Weapons.pk3 rebuilt and COMPILED against that pk3. Card lint `--wmcard` passes all 14
> live cards. Not committed. The pre-plasma pk3 is in `lead/pk3_backup/pre_plasma/`.
>
> **RAILGUN, CHAINGUN, ROCKET LAUNCHER + RPG LIVE.** uzdxrema-11's `hands = 1 | 2` compiled
> (RS_VR_Reload.pk3 14:22). Then `merge_live.py railgun chaingun launchers` did all of this:
> - put their cards into WMCARD
> - turned on AmmoType1 Cell / Clip / RocketAmmo, ShotRail + RoundsPerShot 10 (railgun) and
>   ShotClass Rocket (launchers)
> - added StartItems + RocketAmmo 20, slots 7 / 8 / 9, and wm_giverailgun / wm_givechaingun /
>   wm_givelaunchers (event, alias, menu row)
>
> RS_VR_Weapons.pk3 rebuilt and COMPILED against it. Card lint passes all 18 live cards. Not
> committed. The pre-hands pk3 is in `lead/pk3_backup/pre_hands/`.
>
> **BFG + HEAVY BFG, CHAINSAW + HEAVY CHAINSAW LIVE.** uzdxrema-11's ChargeTics / ChargeSound,
> ShotSaw / SawSounds and the FireHeld / FireReleased hooks compiled (RS_VR_Reload.pk3 14:26).
> Then `merge_live.py bfg chainsaws` did all of this:
> - put their cards into WMCARD
> - turned on AmmoType1 Cell, RoundsPerShot 40, ShotClass BFGBall, ChargeTics 30 + ChargeSound
>   on the BFGs, and ShotSaw + SawSounds + ReadySound / UpSound on the saws
> - added StartItems, slots 0 and 1, and wm_givebfg / wm_givechainsaws
>
> RS_VR_Weapons.pk3 rebuilt and COMPILED. Card lint passes all 22 live cards. Not committed. The
> previous pk3 is in `lead/pk3_backup/pre_bfg_saw/`.
>
> **10 of 13 new guns live.** Still waiting: the flamers (uzdxrema-11's world-transform helpers,
> then the FireHeld / FireReleased overrides in flamers.zs) and the machine gun (G-UBL).
>
> **FLAMER + FLAMETHROWER LIVE.** uzdxrema-11's presentation helpers compiled (RS_VR_Reload.pk3
> 14:34), and its build now stages and swaps in only on a pass.
> - flamers.zs: WM_FlameGun : WM_Gun drives RSB_Flame.Stream / StopStream / Pilot from the
>   FireHeld / FireReleased / DoEffect hooks, and both guns derive from it.
> - `merge_live.py flamers` added the cards, AmmoType1 Cell, ShotClass WM_FlameShot /
>   WM_NapalmShot, StartItems, slot 0 and wm_giveflamers.
> - **RS_VR_Weapons now REQUIRES RS_Ballistics loaded before it**, since RSB_Flame is a
>   compile-time reference. build.ps1's compile check loads RS_Ballistics.pk3 first.
>
> The first build failed ("Too many arguments in call to stream"): the installed
> RS_Ballistics.pk3 (08:19) predates Stream's fuelShare / acrossAxis. The pre-flamers pk3 was
> restored at once, and the call uses the 7-argument form until uzdxrema-9f rebuilds its pk3.
> 9f's source is ready, but building in its lane needs the owner's yes, which it has asked for.
> The rebuild then COMPILED, and the full 11-mod load order COMPILED too. Not committed. Backup
> in `lead/pk3_backup/pre_flamers/`.
>
> **12 of 13 new guns live.** Left: the machine gun (G-UBL), then the 9-argument flame call.
>
> **THE BFG'S COVER GATES ITS CELL.** uzdxrema-11's static pass (RS_VR_Reload.pk3 14:38:07):
> - It fixed the two-stage cell: the well's mouth and a button drop now follow both stages.
> - It added `needs = open:<id>` to swap, and WM_BFG's `swap magwell` carries `needs = open:cover`.
> - card_lint allows it; 24 live cards pass.
> - WM_BFGHeavy's surfaceless cell seats on reaching the well, which is accepted: there is no mesh
>   to push.
>
> Rebuilt: COMPILED. Not committed. Backup in `lead/pk3_backup/pre_bfg_needs/`. Notes in
> BFG_CARDS.md "Grammar gaps" 1-4.
>
> **THE MACHINE GUN IS READY FOR G-UBL.** uzdxrema-11 sent the final names for its second-barrel
> grammar and is building it now.
> - MACHINEGUN_UBL.md's card now carries a real `barrel launcher` block (altfire, from gl,
>   shotclass WM_LauncherGrenade, ammo RSVG_Ammo, needs = shut:breech).
> - card_lint reads barrel blocks and mirrors uzdxrema-11's rules, including the reserve
>   exemptions.
> - merge_live's G-UBL gate detects the grammar in parser.zs, so no hand flip is needed.
> - `merge_live.py --dry machinegun` matches every anchor.
>
> **MACHINE GUN LIVE: 13 OF 13 NEW GUNS.** uzdxrema-11 installed G-UBL (RS_VR_Reload.pk3 09-13
> 15:02:30), with no names changed.
> - `merge_live.py machinegun` applied: card, AmmoType1 Clip, StartItem, slot 7, and
>   wm_givemachinegun (100 Clip, plus 6 RSVG_Ammo when RS_Grenade is loaded).
> - chainguns.zs's header was updated by hand.
> - Card lint passes 25 live cards. The build COMPILED.
> - Not committed. Backup, with the pre-merge source files, in `lead/pk3_backup/pre_machinegun/`.
>
> The card is unproven until map start, since cards don't parse under -norun. The in-game lines
> to look for are in MACHINEGUN_UBL.md "The card".
>
> Known looks, not blockers:
> - the spent 40 mm case is thrown as pistol brass;
> - the grenade leaves from the hand, not the tube.
>
> **G12 AND G11 ON THE CARDS** (uzdxrema-11: counted roundsurface 15:05, spinning parts 15:09).
> - **Rocket launcher:** rocket1-3 are `mag, 0..2`; the bore rocket goes last.
> - **RPG:**
>   - rocket1-6 are `mag, 0..5`;
>   - rocket7 is `part emptychamber`, role = hidden;
>   - `wm_rpg_mag.md3` had its rocket7 surface dropped byte for byte.
> - **Chaingun belt:**
>   - `chaingun_wm.md3`'s belt was split byte for byte into `belt`, `belt03`..`belt11`, by FU's
>     AmmoOverlay counts (`SP\chaingun\belt_count.py`, `belt_split.py`; tool
>     `lead/md3_raw.py`);
>   - on the magazine part they are roundsurfaces `mag, 0` and `mag, 2..10`.
> - **Chaingun barrels:** `part barrels` spins while the trigger is held (spinrate 15, spinup 4,
>   spindown 20 ESTIMATE, period 60), with spinupsound / spinsound / spindownsound.
> - **card_lint:**
>   - counted and slotted roundsurface bounds, and double-named surfaces;
>   - G11 spin refusals;
>   - G16 link keys, gated on parser.zs.
> - FU's `cg_ammoclip.md3` was copied for G16.
>
> Built: COMPILED, plus the full 11-mod load order. Not committed. Backup in
> `lead/pk3_backup/pre_g12/`.
>
> **G16, G13 AND G15 ON THE CARDS** (RS_VR_Reload.pk3 15:15:40 / 15:17:16 / 15:18:38):
> - **G16:** MODELDEF.txt's `WM_BeltLink` block is in; Chaingun and MachineGun throw
>   `cg_ammoclip.md3` links (chaingun_HD.png, 0.34).
> - **G13:**
>   - rack: index slide (0,-1,0) 8.955, from 3, steps 2; rocket1-3 `mag, 2..0`;
>   - drum: index hinge -51.43 about +x through (3.636, -4.562, 2.026); rocket1-6 `mag, 5..0`.
> - **G15:** `WM_Gun.ReleaseTics 20` on both plasma classes (plasma.zs header updated).
> - **card_lint:** index blocks (IndexKey / IndexProblem).
> - Drafts synced: ROCKET_CARDS, CHAINGUN_CARDS, MACHINEGUN_UBL, PLASMA_CARDS.
>
> Built: COMPILED, plus the full 11-mod load order. Not committed. Backup in
> `lead/pk3_backup/pre_g13_g16/`.
>
> **G14, sent to uzdxrema-11:** every loose magazine's stand is ONE rule, md3_write.extract's
> shortest rotation of the feed dof axis onto -z (stage one on a dof2).
> - Measured against 16 cards within 0.03° (`lead/measure_stand.py`, `stand_rule.py`).
> - Not measurable: Moonlight / Sunset speedloaders, BFGHeavy.
> - Flagged: mirrored props (Scale x < 0) against the unmirrored WM_LooseMag.
> - Its netplay step 8 (frandom in loose.zs) is next on its side.
>
> **FEEL_PLAN SECTIONS 1-3 IN THE ARCHETYPES** (uzdxrema-11, RS_VR_Reload.pk3 15:26:12, flick
> 15:27:45). No card here needed a line; Moonlight / Sunset / Cola / SSG inherit them.
> - `eject by = tilt` + `tiltaxis`, and `button = yes` on open / eject.
> - The breaktop extractor falls out by tilt.
> - Flick to close: `close = flick`, `flickaxis`, `flickscale`; wm_flick_close and
>   wm_flick_speed are on the Fire menu. Single-player only: in a netgame velocities read zero.
>
> card_lint:
> - The new keys and refusals.
> - Reads RS_VR_Reload/WMCARD.txt's `archetype` blocks, and `--wmcard` lints each one.
> - Merges each card's `mechanism` verbs before refs and rules.
> - 4 archetypes and 25 live cards pass; negative test `lead/test_verb_rules.py`, 17 cases.
> - Not mirrored: flickaxis = side on a part that does not move across (the rig's FlickSideSign;
>   watch Cola's crane bind line).
>
> **G14 INSTALLED** (RS_VR_Reload.pk3 15:33:31): a button-dropped magazine keeps its drawn turn,
> on the stand rule sent above.
> - Loose turn = GunWorld·M·Twist·Rᵀ·M, solved against the renderer's basis.
> - If the check misses by more than 0.05 it falls level with a WARN; send any such line to
>   uzdxrema-11.
> - Full 11-mod load order COMPILED against it. That closes f9's G11-G16.
>
> **ROW 3 (held and floor ammo sets per type) INSTALLED 15:39:57, AND LINKED HERE.**
> - Sets are `wm_ha_<profile>_<slot>`: slots main/off_mag, main/off_round, floor_mag, floor_round;
>   the chain is handprofile, then type, then default.
> - Pages are WM_HA_<Profile>; WM_MagMenu is now a hub.
> - MODELDEF: WM_LooseMag / WM_LooseRound PlacementCVars moved to wm_ha_default_floor_mag / _round
>   (the old wm_dropmag / wm_dropround are deprecated).
> - MENUDEF: 21 gun pages' ammo rows open their type's WM_HA_ page (`lead/ha_links.py`); every
>   target is checked as declared; hub pages keep WM_MagMenu.
> - Built; the full load order COMPILED. Backup in `lead/pk3_backup/pre_ha_sets/`.
> - GRAB OVALS per type are HELD for the owner: uzdxrema-11 is asking whether per-type slot
>   ovals (~3,000 cvars) or BUILD.md step 5's baked per-gun ovals (wm_bake).
>
> **ROW 7 INSTALLED 15:41:16:** a voxel clip becomes a magazine. No card changes.
>
> **CHAINSAW CS-G1 RIPCORD: plan OK'd, uzdxrema-11 building.**
> - A `start` verb (part, outat), card pullsound / startsound / idlesound / stopsound.
> - When installed: add `start ripcord` and the four sounds (wm/saw/cord, start, idle, stop) to
>   WM_Chainsaw's card, and drop its Weapon.ReadySound and UpSound.
> - The heavy saw is unchanged.
> - CS-G3 cord stays hidden (a per-vertex drive is engine work, for the owner's queue).
> - CS-G2 reach stays in the playsim (A_Saw), so it is dropped.
> - CS-G4 chain flip comes next.
>
> **CHAINSAWS FINISHED ON THE CARDS** (CS-G1 15:45:10, CS-G4 15:46:56).
> - **WM_Chainsaw ripcord:**
>   - `start ripcord` (outat 0.85), card pullsound / startsound / idlesound / stopsound
>     (wm/saw/cord, start, idle, stop);
>   - the class dropped ReadySound and UpSound;
>   - the ripcord hand reads the chainsaw type's slide seat.
> - **WM_Chainsaw chain:** it flips chain / chain2 at 1 tic, the donor's fire rate. chain2 was
>   added to chainsaw_wm.md3 byte for byte from the donor's frame 8 (`SP\chainsaw\chain2_build.py`;
>   only the 168 chain vertices move between frames 13 and 8).
> - **WM_ChainsawHeavy:** it flips chain / chain2 at 2 tics (FU's SAWG A/B); still no ripcord.
> - **card_lint:** the start verb (one per gun, needs a part, outat), the flip rules, the four
>   engine sound keys.
> - CS-G2 (reach) was dropped; CS-G3 (stretching cord) is engine work for the owner's queue.
>
> **BFG ART COPIED FOR THE METER:** bfg_meter2-7.png and bfg9000_off.png, byte-identical from FU's
> models/bfg9000/ (the donor of bfg_wm.md3, cleared). uzdxrema-11 was told to build `meterskins`
> (on the cover part's meter) and `magskinempty`; put them on WM_BFG's card when it lands.
>
> Built: COMPILED (225 entries). Backup in `lead/pk3_backup/pre_ripcord/` (pk3, chainsaw_wm.md3,
> WMCARD).
>
> **THE FLAMERS MAKE THE NINE-ARGUMENT CALL.** uzdxrema-9f installed RS_Ballistics.pk3 with
> `Stream(..., intensity, fuelShare, acrossAxis)` (pushed b5aa45d on its side):
> - napalm twin jets, sputter below 15% fuel, flame-out on StopStream;
> - a Preview row "Flamethrower running dry (sputter)".
>
> flamers.zs WM_FlameGun.FireHeld now passes FeedShare() and AcrossToWorld(), with (0,0,0) when
> there is no drawn gun. Built: COMPILED. Backup in `lead/pk3_backup/pre_flame9/`. This closes
> the 7-argument interim above.
>
> **BFG METER ON THE CARD** (RS_VR_Reload.pk3 16:16:24):
> - `part cover`: metersurface meter, meterskins "models/bfg/BFG" "bfg_meter%d.png", metersteps 7.
> - Card: magskinempty bfg9000_off.png.
> - card_lint mirrors the refusals and checks all seven meter files exist.
> - Donor note: FU's gauge showed the shot's charge-up (`charged` 1-7), ours shows the cell's
>   fill. The order agrees (7 is the top).
> - Built; full load order COMPILED. Backup in `lead/pk3_backup/pre_meter/`.
>
> **F3 LATCH INSTALLED** (16:18:15): `latch` / `latchat` on open and swap.
> - The machine gun's `open breech` latch = launcherlatch is now enforced; `latchreturn = spring`
>   was asked for and goes on when it lands.
> - **Flamethrower: ON THE CARD.**
>   - `part lever`: grab at the arm's lower end 51.04, 6.07, -17.06 (radius ESTIMATE); hinge 99.28.
>   - A declared `swap magwell` with SynthSwap's numbers (canister, mag, 0.9, 0.97, button, no hand
>     take), plus `latch = lever`, `latchat = 0.8`.
>   - card_lint: latch / latchat rules. Built: COMPILED.
>   - Draft and gap F3 in FLAMER_CARDS.md updated.
> - **Machine gun: `latchreturn = spring`** (installed 16:22:08) is on `open breech`, live and in
>   MACHINEGUN_UBL.md. The launcher latch snaps home when let go, and the tube stays free for
>   35 tics. card_lint: latchreturn is spring or stay, and only with a latch. Built: COMPILED.
>   Backup in `lead/pk3_backup/pre_latchreturn/`.
>
> **GRAB OVALS BAKED INTO THE CARD: INSTALLED** (RS_VR_Reload.pk3 16:30:13; its menu_lint passes).
> - Full 11-mod load order COMPILED against it.
> - All 71 Submenu targets on this package's pages are declared; WM_GrabMenu is unchanged.
> - After pasting a whole gun's bake, zero wm_grab_all: it is folded into every baked part.
>
> **THE SSG DUMPS LIKE A BREAK-TOP** (the owner, through uzdxrema-11; the archetype changed in
> RS_VR_Reload/WMCARD.txt):
> - `open break` lost onopen = ejectall and gained button = yes.
> - A new `eject extractor` (tilt down, at 0.10, from chambers, needs open:break, button).
> - card_lint passes the archetype and WM_SSG merged.
> - The SSG's card comment, gun-page help text (MENUDEF WM_SSGGun) and ssg.zs header were
>   rewritten to match: open by hand or button, tip past side to drop the hulls, flick up to shut.
> - Rebuilt: COMPILED. Re-run the full load-order check once uzdxrema-11's pk3 with the change is
>   installed.
>
> **"COUNTS AS CLOSED" THRESHOLDS INSTALLED** (RS_VR_Reload.pk3 16:49:21; 16:47:02 was the SSG
> archetype):
> - wm_feel_<type>_home / _shut; the effective homeat / closeat is the larger of card and slider.
> - Letting go inside home snaps the part home; the shotgun starts at 0.25.
> - Page WM_FeelMenu.
> - Linked here from the 12 gun pages with a hand-worked part (`lead/feel_links.py`): both pumps,
>   Moonlight, Sunset, Cola, Rifle, SSG, M16, Tec9, SMG, BFG (cover), MachineGun (breech).
> - Rebuilt: COMPILED. Backup in `lead/pk3_backup/pre_feel/`.
>
> Still coming from the owner through uzdxrema-11: a netplay spec (no card keys).
>
> **VR WEAPON SOUND SELECTION: a new companion package, E:\DOOMWork\RS_VR_SoundSelection** (the
> owner's order; not committed).
> - Options -> VR Weapon Sound Selection. Every gun, and every sound slot it can make (226).
> - Selecting a slot opens its KIND's family page (shotgun sounds for shotguns); selecting a sound
>   previews it and assigns it.
> - The library is all 1,265 RS_Main sounds (copied, with 143 random sets and its volumes), plus
>   ours and Doom's, listed by name.
> - Picks: `user string wm_snd_<gun>_<slot>`.
> - The HOOK that plays them is asked of uzdxrema-11: the gun owner's cvar at play time, empty =
>   the card's. Also asked: which slots really sound (slideback / slidefwd look unused).
> - build.ps1 generates, lints, packs, verifies and compile-checks: COMPILED after the reload
>   system and RS_VR_Weapons. MENUDEF is proven only in game.
> - Later, the owner's picks bake into WMCARD sound keys, copying only the chosen files.
> - **HOOK INSTALLED** by uzdxrema-11 (RS_VR_Reload.pk3 18:47:47, class WM_SoundPick through
>   WM_Rig.SlotSound).
>   - Slots corrected to what really plays: 194.
>   - slideback / slidefwd are never played, so the six cards' slideback/slidefwd keys became
>     rackapexsound / rackresetsound, and card_lint refuses the dead keys.
>   - Picks are `nosave` (per machine, still in the ini).
>   - No eject-action slot yet (owner asked).
>   - Both pk3s COMPILED.
> - **WEAPON SOUNDS ONLY** (the owner, shown 4,500 ART SOURCE sounds: "get those the fuck out of
>   there").
>   - The library is RS_Main's gun folders, ART SOURCE's gun folders + casings + LowAmmo (owner:
>     "yes add art source"), Doom's weapons/*, and ours: 948 files, 25.9 MB.
>   - Each gun opens its own kind first (30-97 sounds); handling, casings and magazines are shared
>     links.
>   - `eject` slot added (uzdxrema-11's ejectsound, 18:58:56) on SSG, Moonlight, Sunset and Cola.
>   - 198 slots in all. COMPILED.
> - **FORCE UNLEASHED CLEARED BY THE OWNER** ("yes", to this lane directly, 09-13).
>   - 122 FU gun sounds are in the companion, plus its common brass / shells / dry fire as shared.
>   - The addon ships CREDITS.txt and licenses/force_unleashed_MIT.txt.
>   - The owner wants the companion PACKAGED AS AN ADDON MOD, not only a tool.
>   - Library: 1,070 files, 28.8 MB.
>   - Compile check done after the session restart: the owner's 6-mod list + RS_VR_SoundSelection.pk3
>     COMPILED on engine 8d75af0c53 (doomxr.exe 09-13 20:13).
>
> **THE DOUBLE BARREL -- every Doom gun now has two** (after the restart; the owner's roster, "at least 2
> of every Doom gun"). Force Unleashed's super shotgun, owner-cleared, is the SSG's off-hand pair.
> - `models/shotguns/DoubleBarrel/doublebarrel_wm.md3`: frame 0 of ssg.md3 + ssg_shell.md3 copied byte for
>   byte (`SP\ssg2\build_mesh.py`), with the loose shell and the skins.
> - Card `WM_DoubleBarrel` on the breakaction archetype. Barrels hinge 36.96° through (29.29, 0, 11.78),
>   trigger 19.24°; both measured over 37 frames (`SP\ssg2\measure.py`, SSG_CANDIDATES.md "Double Barrel").
> - Class in ssg.zs (the SSG's vanilla shot), WM_PropDoubleBarrel, wm_doublebarrel placement set, its
>   gun page, slot 3, StartItem, wm_givedoublebarrel, and SNDINFO wm/dbarrel/*.
> - card_lint passes. RS_VR_Weapons.pk3 and RS_VR_SoundSelection.pk3 (now 26 guns) are built.
> - On engine 6997b2c308 (exe 09-13 23:02), the owner's 6-mod list + RS_VR_SoundSelection COMPILED.
>   Commit handed to doomwork-d3.
>
> **PAUSE POINT, 09-13 ~23:10: THE OWNER IS TESTING AND CALIBRATING THE INSTALLED BUILD** (doomwork-d3).
> - **NO INSTALLS** until d3 says testing is over. RS_VR_Weapons.pk3 (23:05:33) and RS_VR_SoundSelection.pk3
>   (23:05:38) stay as they are. Both build.ps1 install on a passing check, so DON'T RUN THEM during the pause.
>   Source or scratch work only.
> - Everything of this lane is committed (393c7d4, 69d3e28); only this note is new.
> - **merge_ballistics.py: APPLIED at d3's order** (RS_VR_Reload row 16 committed as 3bb743c; d3: the last install
>   before the owner tests, since without it every gun shows the pistol's round, flash and brass).
>   - 24 classes carry their Round / Flash / Ejecta (and the machine gun's AltFlash) profiles.
>   - The 15 `casingsound = "wm/casing"` lines are gone.
>   - card_lint 0 issues.
>   - Staged build COMPILED against RS_Ballistics c4a467d (23:04:18) and RS_VR_Reload (23:06:03), and
>     INSTALLED RS_VR_Weapons.pk3 23:08:49.
>   - Back to PAUSE after it: no installs until d3 says testing is over.
>   - The companion's "casing" slot labelled a gun's own sound as wm/casing; it is really the ejecta
>     profile's brass now. **FIXED IN SOURCE, NOT INSTALLED** (RS_VR_SoundSelection, uncommitted):
>     - generate.py reads RSBDEFS `ejecta` sounds and each class's WM_Gun.EjectaProfile; a casing slot's own
>       sound is the card's casingsound, else that profile's (unset: brass_45, as EjectaProfileOrDefault).
>       Shotguns rsb/casing/shell; M16, Pistolet, Tec9, chaingun small; the rest medium.
>     - The library's OUR PACKAGES gains "RS_Ballistics -- its casing sounds" (30), so a pick can go back
>       to them. Page ids after it shift by one (generated; nothing keys on them).
>     - Regenerated: 26 guns, 206 slots, 109 pages. menu_lint clean. No pk3 built.
>     - **INSTALLED 09-14** (the owner lifted the pause; built after uzdxrema-3a's P0 reload install 23:59:40, the
>       two lanes serializing the compile-check scratch folder): staged build COMPILED against RS_Ballistics,
>       RS_VR_Reload and RS_VR_Weapons (exe 09-13 23:02), 1077 entries, 28.8 MB. Commit handed to doomwork-d3.
> - **Owner verdict from the headset (via d3):** "the weapons are fuckin great... i am amazed, really." Every model
>   works and reloading works well. The hands and spheres need a lot of tailoring, which the owner will do LATER. So
>   there is no bake yet and the PAUSE HOLDS. Card ids and layout stay stable for that calibration.
> - **PAUSE LIFTED 09-14** (the owner: "spin it all back up, let's keep going"). Sound Selection casing fix committed
>   d8228b5; regenerated again after uzdxrema-3a's §8 (RS_VR_Reload 00:04:35 dropped WM_Bullet and wm/impact*) and
>   installed. Compile checks are SERIALIZED with uzdxrema-3a and uzdxrema-c5 (one shared scratch folder): say
>   "taking it" and "finished" every time.
> - **c5's SHOTCLASS SWAP, INSTALLED 09-14** (staged check COMPILED against RS_Ballistics 4cdcf79 + RS_VR_Reload
>   00:12:03; commit handed to d3): plasma "RSB_PlasmaBall",
>   launchers "RSB_Rocket", BFGs "RSB_BFGBall" (RS_Ballistics 4cdcf79 rsb/projectiles.zs; subclasses, gameplay
>   untouched). Headers rewritten (launchers/bfg lost their stale NOT CARRIED blocks). Comments naming WM_Bullet now
>   say the round profile's own 5 x 1d3 (3a: damage unchanged). WMCARD: one comment line, no ids touched.
> - **Owner 09-14, Vanilla / Vanilla+:** the guns we built serve both. Vanilla = vanilla behaviour, ONE GUN PER PICKUP.
>   Vanilla+ fires: one gun at a time, together. Extras' spawn rules later.
>   - **ONE GUN PER PICKUP: BUILT + INSTALLED, committed 3d7d059** (owner: "there will be an options menu but for now yes one gun per
>     pickup"). `zscript/rs_vr_weapons/weaponset.zs`: WM_WeaponSet.CheckReplacement turns Doom's 8 weapon classes
>     into WM_Pickup* (Doom's sprite; next gun of the pair not carried, main first; Doom's AmmoGive with Weapon's
>     drop / skill / deathmatch rules; ShouldStay as Weapon's). `server bool wm_start_arsenal = true` keeps the test
>     arsenal start; off trims a fresh start (token WM_StartApplied) to fists + both pistols + 50 Clip. MAPINFO adds
>     the handler. Staged check COMPILED (RS_Ballistics 98f44cc, RS_VR_Reload 00:12:03). Unproven in game (-norun
>     spawns no map). Not vanilla yet, told to the owner: the machine gun's launcher (Vanilla+?), the chaingun's
>     first shot spreads, the pistols fire once per pull.
> - **Owner 09-14: RS_Grenade and RS_ShieldSaw join our weapon set.** doomwork-d3 examines their models first; nothing
>   brought in before its report; neither mod is edited.
> - **PUBLISHED 09-14:** RS_VR_Weapons is public at github.com/presidentkoopa/RS_VR_Weapons (29ccc77), its own .git,
>   still tracked in E:\DOOMWork (owner: never remove or untrack a published mod). Commits go through the build lane
>   (doomwork-5e), inside that repo.
> - **WM_LauncherGrenade offset FIXED** (d3's model report, now `_pending/GRENADE_SHIELDSAW_MODEL_REPORT.md`):
>   MODELDEF PivotOffset was RS_Grenade's frame-0 base centre, which drew the frame-16 grenade 9.8 map units off
>   its actor; now 8.523 0 -1.719, frame 16's base centre x 0.3. RS_Grenade's own thrown grenade has the same bug,
>   reported to the owner by d3; not ours to fix.
> - **RS_Grenade / RS_ShieldSaw import: UNBLOCKED** (owner, via doomwork-5e): the ShieldSaw keeps its throw and
>   return (everything); the grenade builds on RS_Grenade (RSVG_* by name; call it RS_Grenade with the owner).
>   **MESHES DONE** (`_pending/THROWABLE_MESHES.md`): `models/grenades/grenade_wm.md3` (body / pin / lever, origin at
>   the body centre; pin slide +Y 24.65; lever hinge +Y through (2.08, -0.02, 7.02), 45°) and
>   `models/shieldsaw/ShieldSaw/shieldsaw_wm.md3` (back, rim, rimopen, face, bladesstowed, blades, blades2, blades3)
>   + its two HD skins. Byte-verified, rendered. Not referenced by MODELDEF yet, so no pk3 rebuild is needed. CARDS
>   wait on uzdxrema-63's THROWABLE archetype.
> - **The bake handover (deferred until the owner's tailoring):** uzdxrema-11/3a sends the `bake_defaults.py --ledger --cards` output. Paste each
>   entry's lines into its WMCARD part / load block (no id renames, no reflow), then card_lint, then a staged
>   build once installs are allowed, then hand the commit.
> - Checked: WM_PumpFlash's sliders (wm_main_muzzle_*, wm_off_muzzle_*, wm_eject_mirror_off) survive row 16
>   in the reload system's CVARINFO.
>
> **BUILDS ARE STAGED NOW** (the build lane's rule: never an uncompiled pk3 in the owner's load order).
> - RS_VR_Weapons/build.ps1 and RS_VR_SoundSelection/build.ps1 pack to %TEMP%\rs_vr_*_stage and
>   compile-check the staged pk3. Only a pass copies it over the installed one.
> - -NoCompileCheck (for a build lock) installs nothing.
> - Proven 23:05: both compiled against RS_Ballistics c4a467d (the flash profiles plasma / rocket /
>   bfg / rail / none) and installed.
>
> **BALLISTICS PROFILES, GATED:** `_pending/tools/merge_ballistics.py`.
> - It holds the ballistics lane's per-class table (uzdxrema-c5, 09-13), with WM_DoubleBarrel on the
>   SSG's profiles.
> - It applies only once weapon.zs declares RoundProfile / FlashProfile / EjectaProfile /
>   AltFlashProfile (the reload lane, uzdxrema-3a, applying RSB_CALL_SITES_HANDOFF.md) and RSBDEFS
>   has every named profile (c5's next pack).
> - `--check` / `--dry` show where it stands; run it bare when READY, then build.
> - It also drops `casingsound = "wm/casing"` from every card whose class names an EjectaProfile. With the
>   handoff applied a card's default casing sound is "", so the brass sounds like its RSBDEFS ejecta
>   profile (uzdxrema-3a's note). Only that exact line goes.
> - Install order (the ballistics lane): engine 2d done -> RS_Ballistics pack -> uzdxrema-3a's
>   RS_VR_Reload.pk3 with the four properties -> this patch -> build + compile check -> hand the commit.
>
> **ASSET PROVENANCE for the public repo:** `_pending/ASSET_PROVENANCE.md` lists every model and sound
> with its donor and what is recorded about its terms. Owner calls before the release:
> - the RS_ModelSwapper meshes have no licence recorded anywhere;
> - the Brutal Doom AssaultShotgun is carried but drawn by nothing;
> - Force Unleashed's MIT notice and credit need carrying;
> - README.md is out of date.
>
> **SAFE POINT, 09-13 ~20:45 (usage limit coming).**
> - NOTHING IN FLIGHT. RS_VR_Weapons and RS_VR_SoundSelection are committed (a58a3f9, 7e14d79).
> - Both pk3s are packed from their current sources and compile with the owner's load order.
> - WAITING ON THE OWNER:
>   - whether Options -> VR Weapon Sound Selection opens and its rows work (MENUDEF is proven only
>     in game);
>   - WM BAKE lines and sound picks, to bake as defaults. The bake tool is another lane's job;
>     WMCARD pastes are mine.
> - STANDING RULES:
>   - Don't rename WMCARD classes / part ids / load ids or reflow WMCARD while the owner calibrates.
>   - No engine builds; no autoloads.
>   - No compile checks while the build lane says the engine is building.
> - TO RESUME: read this file and memory rs-vr-soundselection. Companion changes go through
>   RS_VR_SoundSelection/build.ps1 (never hand-edit its lumps); gun cards through card_lint +
>   RS_VR_Weapons/build.ps1.
> - LICENCE FLAG (now SETTLED: the owner cleared FU) from uzdxrema-11: FU (E:/DOOMWork/_old/doom-force-unleashed_devbuild) credits Brutal
>   Doom for its sounds. It's not cleared for a public release. Copy nothing more from it or
>   E:/oldshit without the owner's clearance. The FU meshes and textures already here need the
>   owner's licence look before the public repos.
>
> **COMMITTED as bea1f67** by the build lane (doomwork-b9), on the owner's word: "commit, do
> stage 2, i will test and calibrate weapons and hands n shit and then we will bake those as the
> defaults, then we will make repos for VR Weapons and VR Reloading".
> - NOW (calibration): when the owner hands over WM BAKE lines or tuned values, bake them into
>   WMCARD and the CVARINFO defaults as directed, then build and compile-check. No commit until the
>   owner says.
> - LATER: separate repos for RS_VR_Weapons and RS_VR_Reload. Not yet.
> - WM_GrabMenu keeps its name, so the gun pages' links are unchanged.
> - One renderer-read scratch set for the selected part: wm_tune (seat), wm_tune_sh (placement),
>   wm_tune_r (ScaleCVar).
> - Rows: bake this part / every part of this gun / every part from its OLD per-slot tuning
>   (the old wm_gp_m0..o7 were archived, so they stay declared, deprecated), and clear.
> - Baked lines print on menu close to the console and log-debug.txt as `WM BAKE -- <class> ...`.
>   When the owner hands them over: paste into WMCARD and the drafts, then run card_lint.
>
> **uzdxrema-11's queue, in the order sent:**
> 1. FEEL_PLAN row 3: held-ammo / floor (wm_dropmag, wm_dropround) sets and grab ovals wm_gp_*, per
>    weapon type. When it lands, link each gun page to the new sets and run menu_lint E7.
> 2. Row 7: a voxel clip becomes a magazine.
> 3. Chainsaw: ripcord and cord, then saw reach and chain flip.
> 4. BFG SurfaceSkin meter.

The build lane (doomwork-f9) dropped out of the session list mid-work, possibly on an API usage
limit. The weapons lane never builds or commits. Everything below is source only, linted and
byte-checked, and waiting for whoever the owner names to pack, compile-check and commit.

Last committed weapons work: `93a50f1` (the railgun's live parts + new-family sounds).

**What doomwork-f9 itself left open** (theirs, not the weapons lane's):
- an engine rebuild. The glow lane reports doomxr.exe was rebuilt at 08:31, and round 2 batch A
  is committed as WIP a05e2eef79, with the rest uncommitted in UZDXREMA.
- `firesfrom = magazine`, written in RS_VR_Reload and not committed
- the tools fix below

---

## A. The new families' live parts (sent to f9 as handoffs 3 and 4; handoff 5 unsent)

All in the shared files at once, so commit them together.

**Files**
- **New class files** in zscript/rs_vr_weapons/: `plasma.zs`, `chainguns.zs`, `launchers.zs`,
  `bfg.zs`, `chainsaws.zs`, `flamers.zs`.
  - Classes only, with each gun's live stats.
  - Every pending property (AmmoType1, ShotClass, RoundsPerShot, ChargeTics, ShotSaw, the
    FireHeld/FireReleased overrides) is a comment. An unknown property is a fatal load error.
  - No StartItem, slot entry or "into the hand" row until the cards land.
- **`zscript.txt`**: #includes after railguns.zs.
- **`MODELDEF.txt`**: 12 prop blocks after WM_PropRailgun.
- **`CVARINFO.txt`**: 12 placement sets.
- **`MENUDEF.txt`**: WM_ArsenalTest gains 12 links; 12 LINT-LIVE gun pages.
- **`build.ps1`**: 12 stems in --prefix; every new .zs, model and skin in the verify list.
- **`ARSENAL_CANDIDATES.md`**: a "built" note per family.
- **`WMCARD.txt`**: comments only. The five hand-seat comments on the pumps, revolvers and SSG now
  name the per-type sets (`wm_hs_shotgun_*`, `wm_hs_revolver_*`, `wm_hs_breakaction_*`) instead of
  the retired `wm_main_*` / `wm_off_*` ones, as f9 asked after c688186.
- **`models/`**: plasma/, chainguns/, launchers/, bfg/, chainsaws/, flamers/.

| Family | Main hand | Off hand | Slot |
|---|---|---|---|
| Plasma | WM_PlasmaRifle (ModelSwapper) | WM_PlasmaCarbine (Force Unleashed) | 9 |
| Chaingun | WM_Chaingun (Force Unleashed) | WM_MachineGun (ModelSwapper) | 7 |
| Launcher | WM_RocketLauncher (Force Unleashed) | WM_RPG (ModelSwapper) | 8 |
| BFG | WM_BFG (Force Unleashed) | WM_BFGHeavy (ModelSwapper; no cell in the mesh) | 0 |
| Chainsaw | WM_Chainsaw (ModelSwapper; has a ripcord) | WM_ChainsawHeavy (Force Unleashed) | 1 |
| Flamethrower | WM_Flamer (ModelSwapper AE) | WM_Flamethrower (Force Unleashed incinerator) | 0 |

**Checks**
- menu_lint with build.ps1's own arguments: "321 cvars, 328 menu controls, 32 placement sets,
  every slider moves something", exit 0.
- Every patch anchor matched exactly once.

**Netplay:** class defaults and data only.
**Headset:** nothing carriable yet; WM_ArsenalTest and its sliders just open.

**Commit line:** `RS_VR_Weapons: plasma rifles, chainguns, rocket launchers, BFGs, chainsaws and
flamethrowers -- models, classes and placement pages (not carried until their cards land)`

**Cards** (in `_pending/*_CARDS.md` and `MACHINEGUN_UBL.md`) wait on firesfrom / casing /
hands / ShotClass / RoundsPerShot / ChargeTics / ShotSaw and the flame hooks. Every draft already
carries its `type = <family>` line.

**Static card lint, no build needed:** `_pending/card_lint.py`. It reads the drafts and checks:
- keys against parser.zs's own list
- model, skin and loose-part files
- surfaces against each mesh
- sounds against SNDINFO
- classes, and part / store / needs references
- the magazine-fed and two-handed rules
- grab points on the mesh

It also mirrors parser.zs FiresFromProblem for reserve / none / magazine, and the key values.
All 13 drafts pass with 0 issues (2026-09-13).

Pending, as expected:
- `hands = 2`, not yet in parser.zs
- the machine gun's `store gl` and `load grenade`, which today's parser refuses on a
  `firesfrom = reserve` card until the G-UBL second-barrel grammar exists

Run it again after any draft edit. `python card_lint.py --wmcard` checks the LIVE cards in
WMCARD.txt the same way; all 12 pass.

**Going live: `_pending/tools/merge_live.py`** (with `merge_lib.py` beside it). One command per
family, and each run does all of this:
- puts the card into WMCARD.txt, with its pending comments cleaned
- turns on the class's pending lines (AmmoType1, ShotClass, RoundsPerShot, ShotRail, ChargeTics,
  ShotSaw...)
- adds StartItems and starting Cell/RocketAmmo, slot entries (1 chainsaws, 7 chainguns,
  8 launchers, 9 plasma/railgun, 0 BFG/flamers) and slot logging 0-9
- adds the "into your hands" netevent, its KEYCONF alias and its WM_ArsenalTest menu row
- runs menu_lint

It is GATED on the RS_VR_Reload source containing every key and property that family uses:
- `--check` reports readiness
- `--dry` runs every edit in memory (all 8 families' anchors match, 2026-09-13)
- `--interim-onehanded` drops `hands = 2` while the parser lacks it

Readiness today, from the uncommitted reload source:

| Family | Status |
|---|---|
| plasma | READY |
| railgun, chaingun, launchers | waiting on `hands` only |
| bfg | waiting on ChargeTics, ChargeSound, hands |
| chainsaws | waiting on ShotSaw, SawSounds |
| flamers | waiting on FireHeld |
| machinegun | waiting on hands and G-UBL |

The flame rounds (WM_FlameShot 520 / WM_NapalmShot 380, Fire, 11-17 from RS_Main) are live in
flamers.zs, not compile-checked.

---

## B. Normals repair (tools/md3.py swapped the normal bytes)

`tools/md3.py` decoded MD3 normals with the high byte as polar in 2π/255 steps. GZDoom's
UnpackVector reads the high byte as azimuth, low as polar, π/128 steps. Every mesh written
through md3.py + md3_write had its normals rewritten. Positions and UVs were always exact, so
this is lighting only.

**Method, all in place. Only the 2-byte normal fields changed; originals are backed up in the
weapons session scratchpad `lead/normals_backup/`.**
- Split meshes: each vertex's donor short restored by exact (x, y, z, s, t), with an order queue
  for duplicates, one to one.
- Loose parts: a rigid fit to the source surface (index order; frame searched), then GZDoom
  decode → rotate → encode, or the raw short where the part was only moved.
- Verified by `normals_bytes.py`: every split mesh 100% equal to its donor.

**Split meshes** — % of vertices holding the donor's normal:

| File | Before | After |
|---|---|---|
| smgs/SMG/smg_wm.md3 (committed) | 18.1 | 100 |
| smgs/Tec9/tec9_wm.md3 (committed) | 11.8 | 100 |
| rifles/M16/m16_wm.md3 (committed) | 2.6 | 100 |
| railguns/Railgun/railgun_wm.md3 (committed) | 15.5 | 100 |
| revolvers/Revolver/rev_wm.md3 (committed; 4 surfaces moved, 6 rounds turned) | 41.9 | 100 |
| plasma/PlasmaRifle/plasmarifle_wm.md3 | 6.0 | 100 |
| plasma/PlasmaCarbine/plasmacarbine_wm.md3 | 47.4 | 100 |
| chainguns/Chaingun/chaingun_wm.md3 | 2.4 | 100 |
| chainguns/MachineGun/machinegun_wm.md3 | 1.4 | 100 |
| launchers/RocketLauncher/rocketlauncher_wm.md3 | 1.8 | 100 |
| launchers/RPG/rpg_wm.md3 | 3.0 | 100 |
| chainsaws/Chainsaw/chainsaw_wm.md3 | 0.7 | 100 |
| chainsaws/ChainsawHeavy/chainsaw_heavy_wm.md3 | 51.9 | 100 |
| flamers/Flamer/flamer_wm.md3 | 2.8 | 100 |
| flamers/Flamethrower/flamethrower_wm.md3 | 10.0 | 100 |
| bfg/BFG/bfg_wm.md3, bfg/BFGHeavy/bfgheavy_wm.md3 | 100 (raw from the start) | 100 |

**Loose parts** — % already equal to the correct short (before), and the fit:

| File | Before | Fit |
|---|---|---|
| smgs/SMG/wm_smg_mag.md3 (committed) | 26.5 | 0.0063 |
| smgs/Tec9/wm_tec9_mag.md3 (committed) | 49.1 | 0.0064 |
| rifles/M16/wm_m16_mag.md3 (committed) | 50.7 | 0.0061 |
| railguns/Railgun/wm_railgun_mag.md3 (committed) | 44.2 | 0.0000 |
| rifles/Rifle/wm_rifle_mag.md3 (committed) | 2.6 | 0.0059, Lipas at frame 3 |
| pistols/wm_m4a3_mag.md3 (committed; the reload lane's) | 0.0 | 0.0063 |
| pistols/wm_pistolet_mag.md3 (committed; the reload lane's) | 0.0 | 0.0064 |
| revolvers/Revolver/wm_speedloader.md3 (committed) | 0.0 | 0.0062, python.014 at frame 25 |
| revolvers/Cola_Revolver/wm_cola_rounds.md3 (committed) | 20.7 | 0.0000 |
| shotguns/Shotgun/wm_shotshell.md3 (committed) | 0.0 | 0.0083, shotshl at frame 12 |
| plasma/PlasmaRifle/wm_plasmarifle_cell.md3 | 47.1 | 0.0037 |
| plasma/PlasmaCarbine/wm_plasmacarbine_cell.md3 | 12.2 | 0.0064 |
| chainguns/MachineGun/wm_machinegun_mag.md3 | 48.7 | 0.0000 |
| launchers/RocketLauncher/wm_rocketlauncher_mag.md3 | 25.5 | 0.0000 |
| launchers/RocketLauncher/wm_rocket.md3 | 56.0 | 0.0000 |
| launchers/RPG/wm_rpg_mag.md3 | 10.3 | 0.0064 |
| launchers/RPG/wm_rocket.md3 | 51.3 | 0.0000 |
| flamers/Flamer/wm_flamer_can.md3 | 54.0 | a translation only, raw shorts |
| flamers/Flamethrower/wm_flamethrower_can.md3 | 50.5 | a translation only, raw shorts |
| chainguns/Chaingun/wm_chaingun_mag.md3 | rebuilt | the box and its **belt** baked together at the same origin (magcenter unchanged), raw shorts; the belt now falls with the box (f9's G17 note) |
| bfg/BFG/wm_bfg_cell.md3, bfg/BFGHeavy/wm_bfgheavy_cell.md3 | turned with GZDoom's maths by their helper | — |

**Not affected, checked:** models/ammo/*.md3 and models/ammo_hand/*.md3 are byte-identical to
Force Unleashed's files. RS_ModelSwapper's 34 meshes are clean (its lane checked: its tools
patch xyz only).

**Commit line:** `RS_VR_Weapons: every split and loose mesh's lighting normals restored to its
donor's (tools/md3.py had swapped the normal bytes)`

---

## C. The tools fix (doomwork-f9's, uncommitted in E:\DOOMWork)

`tools/md3.py` `_decode_normal` and `tools/md3_write.py` `decode_normal` / `encode_normal` now
use GZDoom's UnpackVector layout (high byte azimuth, low byte polar, π/128). The weapons lane
read the diff and it matches UnpackVector; the lane did not edit it. f9 planned to prove it with
a decode→encode round trip on donor meshes before committing.

**Commit line (f9's to confirm):** `tools: md3.py and md3_write decode and encode MD3 normals
exactly as GZDoom's UnpackVector`

---

## Open, for the reload lane when it returns

- G11-G17: queued by f9.
- The BFG/chainsaw gaps, sent in handoff 4, which never arrived:
  - swap gated by an open cover
  - open + firesfrom synthesis
  - two-stage magazine seating
  - a feed part with no surface
  - SurfaceSkin on a moving surface
  - pull-to-start ripcord
  - saw reach segment
  - stretching cord
  - chain flip
- Flamethrowers: FireHeld needs a model-to-world helper for nozzle and pilot points.
- The lever latch (F3) and the drop/well code reading only `dof` (F2) are in FLAMER_CARDS.md.
- **For tools/compile_check.ps1's owner** (uzdxrema-11 found it, 2026-09-13): its early-kill
  pattern lacks `pk3:zscript`, so a semantic compile error waits the full 180 s timeout instead of
  stopping at the error. The final pass/fail still catches it. Not edited by the weapons lane.
- **G-UBL, the machine gun's underbarrel grenade launcher** (the owner, after the handoffs):
  - the bullets come from the reserve; the reload is the launcher, loaded with RS_Grenade's
    grenades
  - Needs:
    - `firesfrom = reserve` alongside a slotted store
    - a second barrel on one card (trigger part, altfire input, its own store / ShotClass /
      muzzle)
    - an open verb that gates only its own barrel
    - the pouch handing out a named ammo class (RSVG_Ammo, soft)
  - Card and measurements: `_pending/MACHINEGUN_UBL.md`.
  - LIVE NOW, NOT COMPILE-CHECKED: `WM_LauncherGrenade` in chainguns.zs, a self-contained
    impact grenade using RS_Grenade's blast by name, plus its MODELDEF block,
    models/grenades/nade.md3 + nade.png (RS_Grenade's, copied), and SNDINFO wm/ubl/cycle +
    launch (sounds/launchers/RLGCY.ogg).
