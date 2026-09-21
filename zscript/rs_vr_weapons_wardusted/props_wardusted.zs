// ==========================================================================
// THE WARDUSTED SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the controller.
// It carries no behaviour. THE NAMES ARE THE CARD'S (WMCARD.wardusted, written by
// _pending/tools/make_sw_sets.py): a prop whose name does not match its card's `prop =` line resolves
// to nothing and the gun draws as a one-pixel sprite -- silently.
// ==========================================================================
class WD_Prop : WM_Prop {}

class WD_PropDL44 : WD_Prop {}
class WD_PropDarkBlaster : WD_Prop {}
class WD_PropE22 : WD_Prop {}
class WD_PropE11 : WD_Prop {}
class WD_PropZ6 : WD_Prop {}
class WD_PropDLT19 : WD_Prop {}
class WD_PropBowcaster : WD_Prop {}
class WD_PropConcussion : WD_Prop {}
class WD_PropDisruptor : WD_Prop {}
class WD_PropSniper : WD_Prop {}
class WD_PropAssaultCannon : WD_Prop {}
class WD_PropThermal : WD_Prop {}
class WD_PropMines : WD_Prop {}
