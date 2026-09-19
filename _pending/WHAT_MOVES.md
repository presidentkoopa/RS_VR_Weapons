# ==========================================================================
# SUPERSEDED -- READ cardkit/motion_parts.py INSTEAD. This file is kept for its numbers,
# not for its method, and its method has a known flaw.
#
# THIS SUBTRACTS A TRANSLATION (the largest surface's own displacement) to get motion relative
# to the gun. A TRANSLATION CANNOT REMOVE A ROTATION. Viewmodel idles tilt, and under a tilt a
# vertex at the muzzle travels far further than one at the grip -- so on any gun whose animation
# rotates, this reports parts moving that are not moving against the weapon at all.
#
# The card lane hit the identical wall subtracting a median displacement and got all 1724 Auto 9
# vertices reported as movers. The fix is a RIGID FIT -- solve the transform that carries frame 0
# onto each later frame, iterate until it locks onto the gun's own frame, and whatever the
# transform cannot explain is a real part. That is motion_parts.py and it works per VERTEX, which
# is the thing neither this nor prep_wm could do: look INSIDE one surface.
#
# WHERE THIS FILE IS STILL RIGHT: it was validated independently against the 1911 and reproduced
# exactly -- 703-vertex slide along the bore, 169-vertex magazine straight down, all five surfaces
# named `model`. Guns whose idle does not rotate read correctly here.
#
# AND THE TRAP THAT PRODUCED IT, worth keeping at the top of anything: 193 of the 194 meshes IN
# THE PACK are single-frame, because a _wm IS the shipped rest pose. Audit "what moves" by reading
# _wm files and you conclude the whole package is static and every magazine is missing. Read the
# SOURCE for motion. Never the _wm.
# ==========================================================================

# WHAT ACTUALLY MOVES -- every source mesh, every surface, across every frame.
#
# THE _wm MESHES IN THE PACK ARE 193 OF 194 SINGLE-FRAME: they are rest-pose exports and carry
# NO motion at all. Every measurement anyone has taken off them is a still photograph. The
# animation is in the ORIGINALS, up to 250 frames, and this reads those.
#
# A part is what it DOES. A magazine drops straight down and out. A slide or bolt travels
# rearward ALONG THE BORE. A trigger barely moves its centre at all because it turns about a
# pin. Those signatures are unmistakable in motion and ambiguous at rest, which is why naming
# parts from a still frame has cost us a picatinny rail, a trigger guard and 253 false alarms.
#
# BORE = the longest axis of the largest surface. Displacement is the furthest any frame moves
# a surface's centroid from its resting position.

==================================================================================================
## bwolf -- 17 meshes
==================================================================================================
1911\1911.md3                            frames=10   5 surfaces, 3 MOVE against the body
    model                      verts=1401   still
    model                      verts=55     still
    model                      verts=159    SLIDE/BOLT  (forward along the bore, 0.5)
    model                      verts=703    SLIDE/BOLT  (rearward along the bore, 4.3)
    model                      verts=169    MAGAZINE    (straight down and out, 13.5)

Axe\Axe.md3                              frames=11   4 surfaces, 3 MOVE against the body
    Blade_low                  verts=428    SLIDE/BOLT  (rearward along the bore, 19.7)
    Handle_low                 verts=491    rises       (28.3)
    Rings_low                  verts=136    rises       (46.3)
    Straps_low                 verts=636    still

BAR\bar.md3                              frames=10   6 surfaces, 5 MOVE against the body
    BAR                        verts=5328   still
    BAR                        verts=269    MAGAZINE    (straight down and out, 17.0)
    BAR                        verts=66     MAGAZINE    (straight down and out, 0.7)
    BAR                        verts=80     SLIDE/BOLT  (rearward along the bore, 13.0)
    BAR                        verts=54     SLIDE/BOLT  (rearward along the bore, 4.0)
    BAR                        verts=205    SLIDE/BOLT  (rearward along the bore, 4.0)

Chaingun\Chaingun.md3                    frames=17   4 surfaces, 2 MOVE against the body
    mag_cover                  verts=7886   still
    mag_cover                  verts=84     SLIDE/BOLT  (forward along the bore, 0.5)
    mag_cover                  verts=1339   MAGAZINE    (straight down and out, 43.7)
    mag_cover                  verts=824    still

Flame\Flame.md3                          frames=10   1 surfaces, 0 MOVE against the body
    Cube                       verts=1763   still

Garand\garand.md3                        frames=14   5 surfaces, 4 MOVE against the body
    Bullet_pack                verts=2787   rises       (11.4)
    Gun                        verts=18322  still
    Gun                        verts=287    SLIDE/BOLT  (rearward along the bore, 10.0)
    Gun                        verts=564    SLIDE/BOLT  (rearward along the bore, 10.1)
    Gun                        verts=302    MAGAZINE    (straight down and out, 1.3)

Grenade\Grenade.md3                      frames=12   1 surfaces, 0 MOVE against the body
    base_low                   verts=3865   still

Kar98\Kar98.md3                          frames=26   11 surfaces, 10 MOVE against the body
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=5347   still
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=338    SLIDE/BOLT  (forward along the bore, 43.4)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=357    SLIDE/BOLT  (rearward along the bore, 11.8)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=891    SLIDE/BOLT  (rearward along the bore, 11.8)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=1075   SLIDE/BOLT  (rearward along the bore, 12.1)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=64     MAGAZINE    (straight down and out, 1.5)
    Cube                       verts=24     SLIDE/BOLT  (forward along the bore, 43.4)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=338    SLIDE/BOLT  (forward along the bore, 43.4)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=338    SLIDE/BOLT  (forward along the bore, 43.4)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=338    SLIDE/BOLT  (forward along the bore, 43.4)
    SMDImporter_Mesh_v_kar98k_kar98_reference verts=338    SLIDE/BOLT  (forward along the bore, 43.4)

Knife\Knife.md3                          frames=11   1 surfaces, 0 MOVE against the body
    nfie                       verts=2940   still

Luger\luger.md3                          frames=13   6 surfaces, 5 MOVE against the body
    SMDImporter_Mesh_v_lugerp08_p08_reference verts=3382   still
    SMDImporter_Mesh_v_lugerp08_p08_reference verts=879    SLIDE/BOLT  (rearward along the bore, 3.1)
    SMDImporter_Mesh_v_lugerp08_p08_reference verts=303    SLIDE/BOLT  (rearward along the bore, 4.5)
    SMDImporter_Mesh_v_lugerp08_p08_reference verts=611    SLIDE/BOLT  (rearward along the bore, 5.1)
    SMDImporter_Mesh_v_lugerp08_p08_reference verts=183    SLIDE/BOLT  (rearward along the bore, 0.5)
    SMDImporter_Mesh_v_lugerp08_p08_reference verts=554    MAGAZINE    (straight down and out, 17.2)

MG42\MG42.md3                            frames=15   5 surfaces, 4 MOVE against the body
    Cylinder                   verts=60     SLIDE/BOLT  (rearward along the bore, 0.5)
    Cylinder                   verts=14851  still
    Cylinder                   verts=3317   MAGAZINE    (straight down and out, 15.5)
    Cylinder                   verts=226    SLIDE/BOLT  (rearward along the bore, 15.9)
    Cylinder                   verts=518    SLIDE/BOLT  (rearward along the bore, 10.0)

MP40\MP40.md3                            frames=10   7 surfaces, 4 MOVE against the body
    MP40                       verts=11685  still
    Object001                  verts=608    MAGAZINE    (straight down and out, 0.4)
    MP40                       verts=456    still
    MP40                       verts=404    still
    MP40                       verts=1214   MAGAZINE    (straight down and out, 12.0)
    MP40                       verts=100    SLIDE/BOLT  (rearward along the bore, 0.6)
    MP40                       verts=191    SLIDE/BOLT  (forward along the bore, 12.0)

PP41\PP41.md3                            frames=10   7 surfaces, 3 MOVE against the body
    ppsh-41_3_low              verts=201    SLIDE/BOLT  (forward along the bore, 7.6)
    ppsh-41_3_low              verts=8337   still
    ppsh-41_3_low              verts=306    still
    ppsh-41_3_low              verts=204    still
    ppsh-41_3_low              verts=227    SLIDE/BOLT  (rearward along the bore, 0.7)
    ppsh-41_3_low              verts=168    still
    Circle                     verts=1695   MAGAZINE    (straight down and out, 11.0)

STG44\STG44.md3                          frames=10   23 surfaces, 15 MOVE against the body
    Low_STG_Low                verts=4589   still
    Low_Krishka_Osnovnaya_Low  verts=49     still
    Low_Magazin_Low            verts=855    MAGAZINE    (straight down and out, 14.0)
    Low_Nachalo_Gazovogo_Porshnya_Low verts=642    rises       (1.4)
    Low_Planka_Low             verts=661    rises       (0.5)
    Low_Priklad_Low            verts=346    MAGAZINE    (straight down and out, 1.0)
    Low_Stvolniy_Pricel_Low    verts=393    rises       (1.8)
    Low_Ceve_Low               verts=849    rises       (0.9)
    Low_Gazoviu_Porshen_Low    verts=565    rises       (1.0)
    Low_Karabin_Low            verts=85     rises       (1.3)
    Low_Knopka_S_Rebram_Low    verts=96     still
    Low_Kolco_Vozle_Priklada_Low verts=312    MAGAZINE    (straight down and out, 0.4)
    Low_Koleso_Planka_Low      verts=497    rises       (0.4)
    Low_Krishka_Low            verts=448    still
    Low_Kyrok_Low              verts=104    SLIDE/BOLT  (rearward along the bore, 0.5)
    Low_Malaya_Knopochka_Low   verts=30     still
    Low_Predoxranitel_Low      verts=216    still
    Low_Pruzina_Osnovnaya_Low  verts=10     SLIDE/BOLT  (rearward along the bore, 9.0)
    Low_Pruzina_Malaya_Low     verts=18     rises       (0.4)
    Low_Stvol_Low              verts=204    rises       (1.6)
    Low_Val_Low                verts=68     still
    Low_Zatvor_Low             verts=176    SLIDE/BOLT  (rearward along the bore, 9.0)
    Low_STG_Low                verts=262    still

Shotgun\Shotgun.md3                      frames=29   7 surfaces, 6 MOVE against the body
    Cube                       verts=342    MAGAZINE    (straight down and out, 2.2)
    Cylinder                   verts=152    rises       (3.1)
    eject                      verts=304    SLIDE/BOLT  (rearward along the bore, 7.3)
    pump                       verts=1220   SLIDE/BOLT  (rearward along the bore, 6.9)
    Runko                      verts=18929  still
    trigger                    verts=106    MAGAZINE    (straight down and out, 2.3)
    trigger                    verts=831    MAGAZINE    (straight down and out, 19.7)

TEMP\TEMP.md3                            frames=16   1 surfaces, 0 MOVE against the body
    Index Controller           verts=62034  still

Tommy\Tommy.md3                          frames=11   4 surfaces, 3 MOVE against the body
    Base                       verts=4495   still
    Bolt                       verts=320    SLIDE/BOLT  (forward along the bore, 9.2)
    Trigga                     verts=132    SLIDE/BOLT  (rearward along the bore, 0.7)
    Magazine                   verts=2093   MAGAZINE    (straight down and out, 14.0)

==================================================================================================
## aliens -- 22 meshes
==================================================================================================
weapons\flamer\m260b.md3                 frames=20   3 surfaces, 2 MOVE against the body
    m260b                      verts=3225   still
    m260b_canister             verts=174    MAGAZINE    (straight down and out, 186.1)
    m260b_trigger              verts=37     moves       (4.9, 20% along bore)

weapons\grenade\satchel_charge.md3       frames=6    4 surfaces, 3 MOVE against the body
    satchel_cover              verts=92     SLIDE/BOLT  (rearward along the bore, 3.7)
    satchel_pocket             verts=164    moves       (2.2, 66% along bore)
    satchel                    verts=276    moves       (2.4, 24% along bore)
    satchel_charge             verts=345    still

weapons\knife\knife.md3                  frames=19   1 surfaces, 0 MOVE against the body
    knife                      verts=518    still

weapons\mech\mechaloader_spark.md3       frames=11   20 surfaces, 19 MOVE against the body
    spark_ball1                verts=136    still
    spark_ball2                verts=71     moves       (2.3, 6% along bore)
    spark3                     verts=54     moves       (50.8, 18% along bore)
    spark4                     verts=46     moves       (46.8, 0% along bore)
    spark2                     verts=52     moves       (62.4, 1% along bore)
    spark5                     verts=56     moves       (70.8, 3% along bore)
    spark1                     verts=44     moves       (68.1, 5% along bore)
    spark8                     verts=54     moves       (62.4, 9% along bore)
    spark9                     verts=46     moves       (39.6, 0% along bore)
    spark7                     verts=52     moves       (70.0, 9% along bore)
    spark10                    verts=54     moves       (68.5, 8% along bore)
    spark6                     verts=44     moves       (62.8, 9% along bore)
    spark12                    verts=54     moves       (40.7, 4% along bore)
    spark14                    verts=52     moves       (64.5, 3% along bore)
    spark11                    verts=56     moves       (64.9, 10% along bore)
    spark13                    verts=54     moves       (50.4, 17% along bore)
    spark15                    verts=46     moves       (68.6, 9% along bore)
    spark16                    verts=52     moves       (29.4, 0% along bore)
    spark17                    verts=44     moves       (70.6, 3% along bore)
    spark18                    verts=54     moves       (61.7, 8% along bore)

weapons\mech\mechloader.md3              frames=21   3 surfaces, 2 MOVE against the body
    MechCover                  verts=18     moves       (39.7, 60% along bore)
    MechArms.001               verts=3590   still
    MechGuard.001              verts=1245   moves       (39.7, 60% along bore)

weapons\pistol\m4a3.md3                  frames=20   5 surfaces, 4 MOVE against the body
    m4a3                       verts=1295   still
    m4a3_trigger               verts=20     rises       (1.1)
    m4a3_hammer                verts=72     MAGAZINE    (straight down and out, 7.4)
    m4a3_slide                 verts=459    SLIDE/BOLT  (rearward along the bore, 9.5)
    m4a3_magazine              verts=88     MAGAZINE    (straight down and out, 66.0)

weapons\rifle\m41a.md3                   frames=36   5 surfaces, 4 MOVE against the body
    m41a_trigger               verts=39     moves       (7.7, 34% along bore)
    m41a_pump                  verts=448    SLIDE/BOLT  (rearward along the bore, 14.2)
    m41a_body                  verts=4647   still
    m41a_bolt                  verts=108    moves       (10.2, 66% along bore)
    m41a_magazine              verts=75     moves       (80.8, 22% along bore)

weapons\shotgun\m37a2.md3                frames=29   4 surfaces, 3 MOVE against the body
    m37a2                      verts=1000   still
    m37a2_pump                 verts=381    SLIDE/BOLT  (rearward along the bore, 13.0)
    m37a2_trigger              verts=46     moves       (5.6, 22% along bore)
    shell                      verts=188    moves       (10.3, 33% along bore)

weapons\smartgun\m56.md3                 frames=28   6 surfaces, 5 MOVE against the body
    smartgun                   verts=4132   still
    smartgun_trigger           verts=51     rises       (20.9)
    smartgun_switch            verts=26     MAGAZINE    (straight down and out, 5.7)
    smartgun_magazine          verts=335    SLIDE/BOLT  (rearward along the bore, 34.5)
    smartgun_mag_handle        verts=307    SLIDE/BOLT  (rearward along the bore, 36.7)
    smartgun_switch2           verts=70     MAGAZINE    (straight down and out, 4.3)

weapons\smartgun\smart_hud.md3           frames=4    1 surfaces, 0 MOVE against the body
    mg_hud                     verts=4      still

==================================================================================================
## cola -- 27 meshes
==================================================================================================
puff.md3                                 frames=250  1 surfaces, 0 MOVE against the body
    Cube                       verts=60     still

weapons\cards\card_deck.md3              frames=11   4 surfaces, 3 MOVE against the body
    Card_1                     verts=24     SLIDE/BOLT  (forward along the bore, 16.0)
    Card_2                     verts=24     SLIDE/BOLT  (forward along the bore, 16.0)
    Card_deck                  verts=24     SLIDE/BOLT  (forward along the bore, 16.0)
    mesh                       verts=730    still

weapons\frypan\fry_pan.md3               frames=5    2 surfaces, 1 MOVE against the body
    mesh                       verts=366    still
    fry_pan                    verts=311    moves       (52.3, 29% along bore)

weapons\piledriver\jackhammer.md3        frames=20   2 surfaces, 1 MOVE against the body
    jackhammer                 verts=777    still
    cylinder                   verts=217    MAGAZINE    (straight down and out, 10.0)

weapons\pistol\revolver.md3              frames=55   7 surfaces, 6 MOVE against the body
    Revolver                   verts=1260   still
    Magazine_rod               verts=127    moves       (4.1, 68% along bore)
    Bullet_set                 verts=900    rises       (23.6)
    Bullet_holes               verts=540    rises       (13.2)
    Magazine.wheel             verts=368    moves       (6.8, 53% along bore)
    Hammer                     verts=108    rises       (18.8)
    Trigger                    verts=42     rises       (14.6)

weapons\shotgun\shotgun.md3              frames=21   5 surfaces, 4 MOVE against the body
    ks-23                      verts=3473   still
    trigger                    verts=40     moves       (2.8, 18% along bore)
    pump                       verts=971    SLIDE/BOLT  (rearward along the bore, 6.7)
    prong                      verts=108    rises       (1.3)
    shell                      verts=188    MAGAZINE    (straight down and out, 10.4)

weapons\shotgun\shotgun_right.md3        frames=21   5 surfaces, 4 MOVE against the body
    ks-23                      verts=3473   still
    trigger                    verts=40     SLIDE/BOLT  (forward along the bore, 9.3)
    pump                       verts=971    rises       (12.3)
    prong                      verts=108    rises       (2.0)
    shell                      verts=188    MAGAZINE    (straight down and out, 10.4)

weapons\sidewinder\sidewinder.md3        frames=45   6 surfaces, 5 MOVE against the body
    bolt                       verts=174    SLIDE/BOLT  (rearward along the bore, 9.6)
    smr                        verts=5835   still
    trigger                    verts=34     SLIDE/BOLT  (rearward along the bore, 0.5)
    loading_bay                verts=90     MAGAZINE    (straight down and out, 0.7)
    display                    verts=138    MAGAZINE    (straight down and out, 1.0)
    plate                      verts=40     MAGAZINE    (straight down and out, 0.4)

weapons\sidewinder\sw_ammo_fire.md3      frames=14   5 surfaces, 1 MOVE against the body
    belt_ammo6                 verts=121    still
    belt_ammo2                 verts=139    SLIDE/BOLT  (forward along the bore, 0.4)
    belt_ammo3                 verts=140    still
    belt_ammo4                 verts=141    still
    belt_ammo5                 verts=139    still

weapons\sidewinder\sw_ammo_fire2.md3     frames=14   4 surfaces, 0 MOVE against the body
    belt_ammo6                 verts=121    still
    belt_ammo3                 verts=140    still
    belt_ammo4                 verts=141    still
    belt_ammo5                 verts=139    still

weapons\sidewinder\sw_ammo_fire3.md3     frames=14   3 surfaces, 0 MOVE against the body
    belt_ammo6                 verts=121    still
    belt_ammo4                 verts=141    still
    belt_ammo5                 verts=139    still

weapons\sidewinder\sw_ammo_fire4.md3     frames=14   2 surfaces, 0 MOVE against the body
    belt_ammo6                 verts=121    still
    belt_ammo5                 verts=139    still

weapons\sidewinder\sw_ammo_fire5.md3     frames=14   1 surfaces, 0 MOVE against the body
    belt_ammo6                 verts=121    still

weapons\sidewinder\sw_ammo_full_reload.md3 frames=6    5 surfaces, 4 MOVE against the body
    ammo1                      verts=141    still
    ammo2                      verts=139    rises       (7.2)
    ammo3                      verts=141    moves       (13.8, 0% along bore)
    ammo4                      verts=139    moves       (16.8, 0% along bore)
    ammo5                      verts=119    moves       (17.1, 0% along bore)

weapons\sidewinder\sw_ammo_reload.md3    frames=20   5 surfaces, 4 MOVE against the body
    ammo1                      verts=141    still
    ammo2                      verts=139    moves       (5.0, 0% along bore)
    ammo3                      verts=141    moves       (10.1, 0% along bore)
    ammo4                      verts=139    moves       (13.7, 0% along bore)
    ammo5                      verts=119    moves       (16.7, 0% along bore)

weapons\toothpastelaser\particlegun.md3  frames=2    4 surfaces, 1 MOVE against the body
    AmmoClip                   verts=143    still
    Trigger                    verts=38     SLIDE/BOLT  (rearward along the bore, 1.1)
    Base                       verts=3387   still
    Stock                      verts=149    still

==================================================================================================
## blood -- 38 meshes
==================================================================================================
flaregun\flaregun.md3                    frames=23   3 surfaces, 2 MOVE against the body
    flaregun                   verts=291    still
    flaregun_trigger_guard     verts=182    moves       (5.5, 74% along bore)
    flaregun_trigger           verts=52     moves       (5.4, 75% along bore)

hand\hand.md3                            frames=7    1 surfaces, 0 MOVE against the body
    caleb_hand                 verts=232    still

lifeleech\lifeleech.md3                  frames=20   4 surfaces, 3 MOVE against the body
    lifeleech                  verts=574    still
    lifeleech_grip             verts=30     SLIDE/BOLT  (rearward along the bore, 1.9)
    lifeleech_handle           verts=36     SLIDE/BOLT  (rearward along the bore, 1.9)
    eye_glow2                  verts=8      SLIDE/BOLT  (rearward along the bore, 4.7)

napalm\napalm.md3                        frames=13   4 surfaces, 3 MOVE against the body
    napalm                     verts=446    still
    napalm_bottom              verts=12     SLIDE/BOLT  (forward along the bore, 3.1)
    napalm_handle              verts=69     MAGAZINE    (straight down and out, 7.1)
    napalm_trigger             verts=6      MAGAZINE    (straight down and out, 5.2)

pitchfork\pitchfork.md3                  frames=11   1 surfaces, 0 MOVE against the body
    pitchfork                  verts=130    still

shotgun\shotgun.md3                      frames=33   7 surfaces, 6 MOVE against the body
    sg_body                    verts=117    MAGAZINE    (straight down and out, 15.2)
    sg_barrel                  verts=317    still
    sg_trigger                 verts=86     moves       (18.1, 75% along bore)
    sg_trigger2                verts=88     moves       (18.5, 74% along bore)
    sg_trigger_bracket         verts=161    moves       (18.6, 74% along bore)
    sg_bolt2                   verts=33     MAGAZINE    (straight down and out, 13.8)
    sg_bolt1                   verts=34     MAGAZINE    (straight down and out, 13.8)

shotgun\shotgun_shell.md3                frames=33   2 surfaces, 0 MOVE against the body
    sg_shell1                  verts=34     still
    sg_shell2                  verts=34     still

spraycan\spraycan.md3                    frames=43   2 surfaces, 1 MOVE against the body
    lighter                    verts=77     SLIDE/BOLT  (forward along the bore, 133.7)
    spraycan                   verts=132    still

teslagun\tesla_arc.md3                   frames=250  1 surfaces, 0 MOVE against the body
    Plane                      verts=4      still

teslagun\tesla_bolt.md3                  frames=47   1 surfaces, 0 MOVE against the body
    tesla_shockbolt            verts=64     still

teslagun\tesla_spark.md3                 frames=47   1 surfaces, 0 MOVE against the body
    teslarifle_spark           verts=36     still

teslagun\teslagun.md3                    frames=47   2 surfaces, 1 MOVE against the body
    teslarifle                 verts=420    still
    teslarifl_barrel           verts=42     rises       (5.6)

tnt\lighter.md3                          frames=5    1 surfaces, 0 MOVE against the body
    Lighterarm                 verts=77     still

tnt\tnt.md3                              frames=2    1 surfaces, 0 MOVE against the body
    TNT                        verts=113    still

tnt\tntspark.md3                         frames=10   3 surfaces, 1 MOVE against the body
    spark01                    verts=13     moves       (0.9, 42% along bore)
    spark02                    verts=17     still
    spark03                    verts=17     still

tommygun\tommygun.md3                    frames=19   4 surfaces, 3 MOVE against the body
    tommy                      verts=482    still
    tommy_handle               verts=52     moves       (6.8, 31% along bore)
    tommy_trigger_guard        verts=30     MAGAZINE    (straight down and out, 5.7)
    tommy_trigger              verts=8      MAGAZINE    (straight down and out, 5.3)

voodoo\voodoo_doll.md3                   frames=18   3 surfaces, 2 MOVE against the body
    voodoo_doll.001            verts=94     still
    voodoo_doll_head.001       verts=88     rises       (4.5)
    voodoo_doll_legs.001       verts=86     MAGAZINE    (straight down and out, 1.7)

zippo\zippo.md3                          frames=9    2 surfaces, 1 MOVE against the body
    zippo                      verts=65     still
    zippo_lid                  verts=32     moves       (7.2, 22% along bore)

zippo\zippo_flame.md3                    frames=5    1 surfaces, 0 MOVE against the body
    zippo_flame                verts=7      still

==================================================================================================
## robocop -- 28 meshes
==================================================================================================
weapons\auto9\auto9.md3                  frames=12   1 surfaces, 0 MOVE against the body
    auto9                      verts=1724   still

weapons\auto9\auto9_flash.md3            frames=12   4 surfaces, 0 MOVE against the body
    flash1                     verts=4      still
    flash2                     verts=17     still
    flash3                     verts=4      still
    flash4                     verts=4      still

weapons\auto9\auto9_hand.md3             frames=12   1 surfaces, 0 MOVE against the body
    robohand                   verts=444    still

weapons\chaingun\chaingun.md3            frames=6    7 surfaces, 0 MOVE against the body
    Barrel_right               verts=102    still
    Chaingun_right             verts=1126   still
    Fins_right                 verts=112    still
    Barrel_left                verts=102    still
    Chaingun_left              verts=1283   still
    Fins_left                  verts=112    still
    Chaingun_left_bulge        verts=25     still

weapons\chainsaw\chainsaw.md3            frames=45   2 surfaces, 1 MOVE against the body
    chainsaw_blade             verts=441    moves       (5.4, 5% along bore)
    chainsaw_hand              verts=1159   still

weapons\cobra\cobra.md3                  frames=4    5 surfaces, 2 MOVE against the body
    cobra_barrel               verts=3871   SLIDE/BOLT  (rearward along the bore, 28.7)
    cobra_leg_right            verts=246    still
    cobra_leg_left             verts=252    still
    cobra_body                 verts=4659   still
    cobra_trigger              verts=85     SLIDE/BOLT  (rearward along the bore, 1.2)

weapons\cobra\cobra_scope.md3            frames=4    5 surfaces, 0 MOVE against the body
    cobra_scope                verts=737    still
    cobra_scope_buttons        verts=43     still
    cobra_scope_glass          verts=26     still
    cobra_scope_stand          verts=14     still
    cobra_scope_viewfinder     verts=216    still

weapons\cobra\roboscope.md3              frames=10   3 surfaces, 1 MOVE against the body
    robocope1                  verts=4      still
    robocope2                  verts=4      still
    robocope3                  verts=4      moves       (53.9, 0% along bore)

weapons\fist\robohand.md3                frames=15   2 surfaces, 1 MOVE against the body
    robohand                   verts=597    still
    robospike                  verts=7      SLIDE/BOLT  (forward along the bore, 28.9)

weapons\ksg\ksg.md3                      frames=5    4 surfaces, 3 MOVE against the body
    back                       verts=2817   MAGAZINE    (straight down and out, 0.9)
    front                      verts=2949   still
    barrel                     verts=950    rises       (0.8)
    trigger                    verts=129    SLIDE/BOLT  (rearward along the bore, 0.9)

weapons\m27\m27_rifle.md3                frames=2    9 surfaces, 0 MOVE against the body
    m27_body                   verts=1917   still
    m27_top                    verts=1524   still
    m27_nozzle                 verts=98     still
    m27_extra_fins             verts=880    still
    m27_trigger_guard          verts=762    still
    m27_nuts                   verts=1191   still
    m27_grids                  verts=840    still
    m27_fins                   verts=300    still
    m27_trigger                verts=36     still

weapons\m32\m32.md3                      frames=37   9 surfaces, 8 MOVE against the body
    trigger_plate              verts=65     MAGAZINE    (straight down and out, 8.1)
    trigger_guard              verts=177    MAGAZINE    (straight down and out, 9.2)
    magazine_back              verts=365    MAGAZINE    (straight down and out, 7.8)
    gun_barrel                 verts=3426   still
    magazine_bracket_front     verts=81     SLIDE/BOLT  (forward along the bore, 4.5)
    magazine                   verts=484    MAGAZINE    (straight down and out, 4.9)
    gun_body                   verts=183    MAGAZINE    (straight down and out, 13.7)
    magazine_bracket           verts=44     MAGAZINE    (straight down and out, 6.8)
    trigger                    verts=70     MAGAZINE    (straight down and out, 6.2)

weapons\shotgun\shotgun.md3              frames=9    2 surfaces, 1 MOVE against the body
    shotgun                    verts=2823   still
    pump                       verts=256    SLIDE/BOLT  (rearward along the bore, 14.7)

weapons\shotgun\shotgun_flash.md3        frames=9    2 surfaces, 0 MOVE against the body
    flash1                     verts=4      still
    flash2                     verts=17     still

weapons\shotgun\shotgun_hand.md3         frames=9    1 surfaces, 0 MOVE against the body
    robohand                   verts=444    still

==================================================================================================
## hacx -- 13 meshes
==================================================================================================
Cryogun\cryogun.md3                      frames=11   5 surfaces, 4 MOVE against the body
    body_low                   verts=5079   still
    chick_low                  verts=228    SLIDE/BOLT  (forward along the bore, 59.1)
    mag_low                    verts=186    SLIDE/BOLT  (forward along the bore, 33.6)
    body_low                   verts=148    SLIDE/BOLT  (forward along the bore, 31.5)
    body_low                   verts=632    SLIDE/BOLT  (rearward along the bore, 27.3)

Melee\melee.md3                          frames=6    1 surfaces, 0 MOVE against the body
    Cylinder                   verts=2388   still

Nuker\Nuker.md3                          frames=11   6 surfaces, 5 MOVE against the body
    Untitled                   verts=3586   still
    Untitled                   verts=52     rises       (10.6)
    Untitled                   verts=2382   SLIDE/BOLT  (rearward along the bore, 72.6)
    Untitled                   verts=675    SLIDE/BOLT  (rearward along the bore, 76.3)
    Untitled                   verts=310    SLIDE/BOLT  (rearward along the bore, 45.1)
    Untitled                   verts=96     SLIDE/BOLT  (rearward along the bore, 91.9)

Nuker\can.md3                            frames=2    4 surfaces, 0 MOVE against the body
    nET                        verts=192    still
    sIGN                       verts=160    still
    RIM                        verts=360    still
    cORE                       verts=312    still

Pistol\pistol.md3                        frames=11   6 surfaces, 5 MOVE against the body
    base                       verts=3088   still
    mag                        verts=562    rises       (5.9)
    slide                      verts=1166   SLIDE/BOLT  (rearward along the bore, 6.1)
    trigger                    verts=116    rises       (3.0)
    Cylinder                   verts=476    moves       (4.9, 0% along bore)
    Cylinder                   verts=528    MAGAZINE    (straight down and out, 4.8)

Reznator\Arc.md3                         frames=6    1 surfaces, 0 MOVE against the body
    Plane                      verts=8      still

Reznator\Reznator.md3                    frames=6    4 surfaces, 0 MOVE against the body
    Plane                      verts=3600   still
    Cube                       verts=3153   still
    Cylinder                   verts=562    still
    warning                    verts=383    still

Stick\Stick.md3                          frames=11   11 surfaces, 10 MOVE against the body
    Cylinder                   verts=320    SLIDE/BOLT  (rearward along the bore, 39.3)
    Cylinder                   verts=315    SLIDE/BOLT  (forward along the bore, 106.8)
    Cube                       verts=582    SLIDE/BOLT  (forward along the bore, 23.5)
    Cone                       verts=366    SLIDE/BOLT  (rearward along the bore, 60.1)
    Cube                       verts=86     SLIDE/BOLT  (forward along the bore, 9.1)
    Cube                       verts=138    SLIDE/BOLT  (forward along the bore, 15.9)
    Sphere                     verts=720    still
    Cube                       verts=414    SLIDE/BOLT  (forward along the bore, 48.3)
    Sphere                     verts=720    SLIDE/BOLT  (forward along the bore, 10.3)
    Sphere                     verts=336    SLIDE/BOLT  (forward along the bore, 25.9)
    Cylinder                   verts=96     SLIDE/BOLT  (forward along the bore, 34.7)

UZI\UZI.md3                              frames=16   16 surfaces, 13 MOVE against the body
    bolt                       verts=52     SLIDE/BOLT  (forward along the bore, 6.0)
    button                     verts=72     moves       (8.8, 0% along bore)
    clip                       verts=274    MAGAZINE    (straight down and out, 20.0)
    clipRelease                verts=36     moves       (19.0, 0% along bore)
    fireSelect                 verts=43     moves       (6.5, 0% along bore)
    handle                     verts=1950   still
    slide                      verts=182    SLIDE/BOLT  (rearward along the bore, 8.0)
    stock0                     verts=290    moves       (2.0, 0% along bore)
    stock1                     verts=647    moves       (9.2, 0% along bore)
    trigger                    verts=56     moves       (6.1, 0% along bore)
    Cube                       verts=148    moves       (3.7, 0% along bore)
    Cylinder                   verts=286    still
    Cylinder                   verts=88     moves       (2.6, 0% along bore)
    Cylinder                   verts=88     moves       (4.6, 0% along bore)
    Cylinder                   verts=282    still
    Cylinder                   verts=88     moves       (3.0, 0% along bore)

Zooka\Zooka.md3                          frames=11   7 surfaces, 6 MOVE against the body
    Bolt                       verts=298    moves       (87.8, 48% along bore)
    crossbow                   verts=4657   moves       (78.1, 13% along bore)
    Str_long                   verts=140    moves       (68.3, 13% along bore)
    Str_shrt                   verts=140    moves       (29.4, 13% along bore)
    Trigger                    verts=234    moves       (95.9, 13% along bore)
    crossbow                   verts=5851   still
    Bolt                       verts=676    moves       (158.6, 29% along bore)

tazer\tazer.md3                          frames=11   2 surfaces, 1 MOVE against the body
    Group49653                 verts=15325  still
    Group49653                 verts=184    SLIDE/BOLT  (rearward along the bore, 19.6)
