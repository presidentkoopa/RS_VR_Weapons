// ==========================================================================
// THE XIM SET'S PROPS -- one per gun, the actor its card names (WMCARD.xim, written by
// _pending/tools/make_sw_sets.py). A prop is a drawing and carries no behaviour; a name that does not
// match its card's `prop =` line draws the gun as a one-pixel sprite, silently.
//
// ITS OWN, NOT THE WARDUSTED SET'S, though several share a mesh with it: every set owns its cards
// (the owner, 2026-09-20), and a class defined in two packs is fatal the moment both load.
// ==========================================================================
class XM_Prop : WM_Prop {}

class XM_PropPistol : XM_Prop {}
class XM_PropShotgun : XM_Prop {}
class XM_PropSuperShotgun : XM_Prop {}
class XM_PropChaingun : XM_Prop {}
class XM_PropRocketLauncher : XM_Prop {}
class XM_PropPlasmaRifle : XM_Prop {}
class XM_PropThermal : XM_Prop {}
