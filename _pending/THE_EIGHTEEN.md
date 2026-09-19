# THE EIGHTEEN -- per-surface centroid, extent, and position relative to the BORE.
#
# Asked for by the card lane: the one thing that separates a magazine from a sight without
# opening every mesh. The bore line is the card's own `barrel` direction through the body's
# centroid; dz is the surface centroid's height above (+) or below (-) that line, and dy its
# offset to the side. A magazine hangs BELOW. A sight, rail or carry handle sits ABOVE.
#
# NOTHING HERE IS A RECOMMENDATION TO CARD ANYTHING. Uncarded is the correct default -- the rig
# only touches surfaces a card names (rig.zs:1188), so a named-and-then-unused surface is the
# one that disappears. This is measurement, for you to judge.

## HX_Nuker        type=launcher     models/hacx/nuker\nuker_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   bolt                     free       3586    -17.52   -0.16    7.94     59.97  26.78  34.61  ABOVE bore
   bolt2                    free         52    -14.94    0.01    3.27      0.97   0.23   2.38  ABOVE bore
   bolt3                    free       2382     19.17    0.00    9.92     27.09  21.03   8.98  ABOVE bore
   bolt4                    CARDED      675     20.69   -0.01   13.54     26.77  22.41  17.50  ABOVE bore
   body                     free        310      3.81    0.00    0.00     21.19  19.72   6.11  on the bore
   bolt5                    free         96     28.95    0.00    8.52      1.97  13.78   6.28  ABOVE bore

## HX_Reznator     type=plasma       models/hacx/reznator\reznator_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free       3600     -7.74    0.00    0.00     31.44  16.30  16.70  on the bore
   Cube                     free       3153     10.38    4.74    0.03     13.31   6.80  10.78  on the bore, left side
   Cylinder                 free        562     -1.43    4.71   -0.00      4.41   4.39  18.39  on the bore, left side
   bolt                     CARDED      383    -10.63    0.15    8.21      4.62   3.41   0.31  ABOVE bore

## HX_Tazer        type=pistol       models/hacx/tazer\tazer_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free      15325     -0.14    0.00    0.00     27.61   4.53  19.97  on the bore
   bolt                     CARDED      184     11.80   -0.84    0.23      2.09   0.72   3.28  on the bore

## HX_Zooka        type=launcher     models/hacx/zooka\zooka_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   bolt                     CARDED      298    -14.80    0.00    2.45     62.14   2.72   2.72  ABOVE bore
   body                     free       4657    -22.37    0.00    0.00     80.94  41.22  23.55  on the bore
   bolt2                    free        140    -17.41   -0.01    2.31     44.59  42.22   0.53  ABOVE bore
   casing                   free        140      2.33   -0.01    2.53      0.00   0.00   0.00  ABOVE bore
   casing2                  free        234    -30.91   -0.01   -5.34      1.30   0.81   3.44  BELOW bore
   bolt3                    free       5851     17.16   -0.01    1.54     27.78  41.84   7.59  ABOVE bore
   bolt4                    free        676     25.99   -0.02    2.48     12.58   3.28   3.28  ABOVE bore

## RC_Auto9        type=pistol       models/robocop/auto9\auto9_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free       1724      0.00    0.00    0.00     41.02   4.06  21.25  on the bore

## RC_Chaingun     type=chaingun     models/robocop/chaingun\chaingun_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   barrel                   free        102     20.91    1.34   -2.18     34.92  11.33  11.31  BELOW bore
   body                     free       1126     -1.46    0.00    0.00     68.91  20.38  22.52  on the bore
   Fins_right               free        112      2.89   -8.37   -3.64      9.34   7.89   8.64  BELOW bore, right side
   barrel2                  free        102     20.91   16.69   -2.18     34.92  11.34  11.31  BELOW bore, left side
   Chaingun_left            free       1283     -2.39   19.06   -0.20     68.91  20.25  22.52  on the bore, left side
   Fins_left                free        112      2.89   26.37   -3.64      9.34   7.91   8.64  BELOW bore, left side
   Chaingun_left_bulge      free         25     -8.32    9.62   -2.71     15.70   3.72   9.38  BELOW bore, left side

## RC_Cobra        type=launcher     models/robocop/cobra\cobra_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   bolt                     CARDED     3871     85.37   -0.07    7.45     68.20   6.81   4.02  ABOVE bore
   cobra_leg_right          free        246     -6.04   -6.66   -1.68     46.66   9.12   9.31  BELOW bore, right side
   cobra_leg_left           free        252     -7.63    7.68   -1.69     46.64  10.81   9.30  BELOW bore, left side
   body                     free       4659    -69.24    0.00    0.00    144.08  14.52  31.11  on the bore
   bolt2                    free         85    -52.93   -0.12   -3.36      2.83   1.11   5.75  BELOW bore

## RC_KSG          type=pump         models/robocop/ksg\ksg_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   back                     free       2817    -21.03   -0.01   -2.00     49.48   5.69  25.58  BELOW bore
   body                     free       2949      9.14    0.00    0.00     58.03   6.89  26.75  on the bore
   barrel                   free        950     35.22   -0.00    0.77      3.89   6.72   6.62  ABOVE bore
   trigger                  CARDED      129     -8.94   -0.00   -7.93      2.73   0.66   4.11  BELOW bore

## RC_M27          type=rifle        models/robocop/m27\m27_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free       1917      0.12    0.00    0.00     82.94   6.50  29.61  on the bore
   m27_top                  free       1524     -4.38   -0.01    8.19     60.03   7.67  10.67  ABOVE bore
   m27_nozzle               free         98     45.36   -0.02   -4.29     15.09   2.39   2.62  BELOW bore
   m27_extra_fins           free        880     11.10   -0.01   -2.40     52.94   5.28  20.34  BELOW bore
   m27_trigger_guard        CARDED      762     -1.21   -0.01   -5.41     21.34   3.53  13.20  BELOW bore
   m27_nuts                 free       1191     -4.65   -0.01   10.88     38.72   7.19   5.56  ABOVE bore
   bolt                     CARDED      840     -5.17   -0.00    9.58     15.72   3.12   0.08  ABOVE bore
   bolt2                    free        300     10.20   -0.01    6.51      1.52   6.20   1.86  ABOVE bore
   trigger                  CARDED       36     -2.01   -0.01   -3.64      1.92   0.62   3.48  BELOW bore

## RC_Shotgun      type=pump         models/robocop/shotgun\shotgun_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free       2823     -0.84    0.00    0.00    103.09   4.53  22.89  on the bore
   forend                   CARDED      256      9.29   -0.01   -2.41     27.19   6.56   6.34  BELOW bore

## BL_LifeLeech    type=plasma       models/blood/lifeleech\lifeleech_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   bolt                     free        574      3.16    0.16    8.96     28.11  13.09  14.42  ABOVE bore
   body                     free         30    -21.13    0.00    0.00     17.61   2.75   7.92  on the bore
   lifeleech_handle         free         36    -34.59   -0.29   -4.41      7.94   4.81   6.06  BELOW bore
   bolt2                    CARDED        8      8.69    0.09   10.73      2.92   6.55   1.88  ABOVE bore

## BL_Shotgun      type=breakaction  models/blood/shotgun\shotgun_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free        117     -8.53    0.00    0.00     12.31   8.11  19.86  on the bore
   bolt                     free        317      8.93   -0.04    3.27     31.92   8.95  15.62  ABOVE bore
   forend                   CARDED       86     -3.63   -0.26   -2.00      3.25   0.50   2.16  BELOW bore
   forend2                  free         88     -3.59    0.36   -2.40      3.16   0.52   4.31  BELOW bore
   forend3                  free        161     -3.62    0.03   -2.52      3.73   1.55   8.98  BELOW bore
   bolt2                    free         33     -9.16    2.69    1.31      3.41   1.30   2.77  ABOVE bore, left side
   bolt3                    free         34     -9.22   -3.06    1.33      3.45   1.92   2.59  ABOVE bore, right side

## BL_Sigil        type=bfg          models/blood/sigil\sigil_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   sigil_left               free        112     18.19   10.79    0.76     30.28   8.94   5.17  ABOVE bore, left side
   sigil_right              free        111     17.42   -9.83    0.64     30.28   8.44   4.77  on the bore, right side
   sigil_top                free         92     22.11    0.33    1.02     31.11  11.64   5.23  ABOVE bore
   sigil_left_socket        free         82      4.01    9.90    0.78      5.92   9.66   6.17  ABOVE bore, left side
   bolt                     CARDED       82      3.85   -9.79    0.83      6.09   9.62   6.17  ABOVE bore, right side
   sigil_top_socket         free         64      4.98    0.06    0.34      5.73   9.38   6.17  on the bore
   sigil_base               free        130      0.82   -0.13    0.78     10.84  27.39   6.41  ABOVE bore
   bolt2                    free         24     -1.27    0.27    3.91      3.08   8.52   3.56  ABOVE bore
   bolt3                    free         36     -2.26    9.42    2.88      4.06   3.45   3.06  ABOVE bore, left side
   bolt4                    free         20     -2.65   -9.38    2.47      3.38   3.27   3.34  ABOVE bore, right side
   bolt5                    free         93     -3.73    0.27    2.39      2.31   7.64   5.73  ABOVE bore
   sigil_pipe               free        157     -1.65   -0.38    3.70      3.31  20.39   3.67  ABOVE bore
   body                     free        445    -11.67    0.00    0.00     26.72  31.28   5.39  on the bore
   bolt6                    free         32     -2.22   11.13    1.19      5.22   5.23   4.89  ABOVE bore, left side
   bolt7                    free         30     -2.37  -10.95    1.23      3.94   4.59   4.70  ABOVE bore, right side
   sigil_handle_right_socket free         24    -20.16   -9.68    0.82      2.72   3.42   1.95  ABOVE bore, right side
   sigil_handle_left_socket free         24    -19.96   10.48    0.82      2.77   3.47   1.95  ABOVE bore, left side

## CL_Jackhammer   type=pump         models/cola/jackhammer\jackhammer_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free        777      3.16    0.00    0.00     79.22  13.91  23.94  on the bore
   bolt                     CARDED      217    -11.28   -6.31    5.62      2.44   4.66   9.70  ABOVE bore, right side

## CL_KS23         type=pump         models/cola/shotgun\shotgun_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free       3473     -2.64    0.00    0.00     90.53   4.33  17.69  on the bore
   mag                      free         40    -11.05   -0.00   -3.50      0.59   0.36   1.41  BELOW bore
   forend                   CARDED      971      9.33   -0.01    1.32     38.38   5.98   8.14  ABOVE bore
   mag2                     free        108     -1.99    0.06   -1.80      8.41   1.72   1.06  BELOW bore
   bolt2                    free        188      4.22    0.01    3.86      5.64   2.12   2.11  ABOVE bore

## AE_M37A2        type=pump         models/aliens/m37a2\m37a2_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   body                     free       1000     -4.94    0.00    0.00     62.62  35.12  14.56  on the bore
   forend                   CARDED      381     18.19    6.93    4.58     18.59   8.88   7.58  ABOVE bore, left side
   mag                      free         46    -15.69   -5.70   -1.79      1.89   3.98   1.02  BELOW bore, right side
   mag2                     free        188     -6.77    3.53    0.19      5.00   2.84   2.50  on the bore, left side

## BW_Shotgun      type=pump         models/bwolf/Shotgun\Shotgun_wm.md3
   surface                  state     verts        cx      dy      dz        sx     sy     sz  sits
   mag                      free        342    -24.82    0.03    4.35      0.61   1.69   0.86  ABOVE bore
   mag2                     free        152     35.58    0.02    4.27      2.72   1.34   1.53  ABOVE bore
   bolt                     free        304    -16.91   -1.58    2.17      8.02   1.16   2.84  ABOVE bore
   forend                   CARDED     1220     12.54    0.05   -0.83     16.69   4.50   4.48  BELOW bore
   body                     free      18929      0.28    0.00    0.00    102.83   4.84  20.03  on the bore
   mag3                     free        106    -26.23    0.04   -3.40      1.02   0.39   2.89  BELOW bore
   casing                   free        831    -11.43    0.05    2.37      6.23   2.38   2.39  ABOVE bore
