// ==========================================================================
// THE RTCW SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why seventeen of them are seventeen lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. WMCARD.ww2 names every prop BW_PropWW2_<gun>,
// so these classes are named that way too -- a prop class whose name does not match the
// card's `prop =` line resolves to nothing and the gun draws as a one-pixel sprite. The
// BW_ prefix on an RTCW set reads oddly and is worth the reload lane renaming at some
// point; until the card changes, matching it is what works.
// ==========================================================================
class WW2_Prop : WM_Prop {}

class BW_PropWW2_BAR : WW2_Prop {}
class BW_PropWW2_Browning : WW2_Prop {}
class BW_PropWW2_Colt : WW2_Prop {}
class BW_PropWW2_FG42 : WW2_Prop {}
class BW_PropWW2_G43 : WW2_Prop {}
class BW_PropWW2_HDM : WW2_Prop {}
class BW_PropWW2_Luger : WW2_Prop {}
class BW_PropWW2_Mauser : WW2_Prop {}
class BW_PropWW2_MG42 : WW2_Prop {}
class BW_PropWW2_Mosin : WW2_Prop {}
class BW_PropWW2_MP34 : WW2_Prop {}
class BW_PropWW2_MP40 : WW2_Prop {}
class BW_PropWW2_StG44 : WW2_Prop {}
class BW_PropWW2_PPSh : WW2_Prop {}
class BW_PropWW2_Sten : WW2_Prop {}
class BW_PropWW2_Thompson : WW2_Prop {}
class BW_PropWW2_TT33 : WW2_Prop {}
