// ==========================================================================
// THE RTCW SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why seventeen of them are seventeen lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. WMCARD.rtcw names every prop WW2_PropRT_<gun>,
// so these classes are named that way too -- a prop class whose name does not match the
// card's `prop =` line resolves to nothing and the gun draws as a one-pixel sprite. The
// WW2_ prefix on an RTCW set reads oddly and is worth the reload lane renaming at some
// point; until the card changes, matching it is what works.
// ==========================================================================
class RT_Prop : WM_Prop {}

class WW2_PropRT_BAR : RT_Prop {}
class WW2_PropRT_Browning : RT_Prop {}
class WW2_PropRT_Colt : RT_Prop {}
class WW2_PropRT_FG42 : RT_Prop {}
class WW2_PropRT_G43 : RT_Prop {}
class WW2_PropRT_HDM : RT_Prop {}
class WW2_PropRT_Luger : RT_Prop {}
class WW2_PropRT_Mauser : RT_Prop {}
class WW2_PropRT_MG42 : RT_Prop {}
class WW2_PropRT_Mosin : RT_Prop {}
class WW2_PropRT_MP34 : RT_Prop {}
class WW2_PropRT_MP40 : RT_Prop {}
class WW2_PropRT_StG44 : RT_Prop {}
class WW2_PropRT_PPSh : RT_Prop {}
class WW2_PropRT_Sten : RT_Prop {}
class WW2_PropRT_Thompson : RT_Prop {}
class WW2_PropRT_TT33 : RT_Prop {}
