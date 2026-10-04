// ============================================================================================================
// THE BREACH GLOCK -- the first rigged IQM gun (the owner, 2026-09-15: "Yes, start it"; "Let's make it 17").
// ZeroDoomThirty's BREACH Weapons (licenses/breach_weapons_CREDIT.txt): glockrerig.iqm, whose slide, trigger and magazine are
// bones moved by their joints (WMCARD.breach). Its mesh, skin, sounds, icon and shot are Breach's; the seat and the card's
// numbers are measured here (tools/). Its muzzle flash, smoke and brass are RS_Ballistics' -- nothing 2D but the icon.
//
// THE SHOT IS BREACH'S GLOCK: glock.zs fires A_FireBullets(3, 3, 1, 20) aimed -- one bullet, 3 degrees either way, 20 x 1d3 --
// ready again 6 tics later, semi-auto; one bullet on a fresh pull flies dead on (FirstShotsAccurate 1). VR aims down the gun, so
// the aimed (ADS) numbers. ITS LOOK IS ITS OWN: RS_Ballistics' 'glock17' round, flash, brass and recoil -- the showpiece 9mm.
// ============================================================================================================

class WM_BreachGlock : WM_Gun
{
	Default
	{
		WM_Gun.ShotSpread 3.0, 3.0;
		WM_Gun.ShotDamage 20, 60;
		WM_Gun.FireTics 6;
		WM_Gun.FirstShotsAccurate 1;
		WM_Gun.RoundProfile "glock17";
		WM_Gun.FlashProfile "glock17";
		WM_Gun.EjectaProfile "glock17";
		WM_Gun.RecoilProfile "glock17";
		Weapon.SelectionOrder 150;
		Weapon.SlotNumber 2;
		Inventory.PickupMessage "Glock";
		Tag "Glock";
		// Breach's own icon (graphics/GLOKA0.png): the weapon wheel shows AltHUDIcon first, then Icon.
		Inventory.Icon "GLOKA0";
		Inventory.AltHUDIcon "GLOKA0";
	}
}

// WHAT IT IS DRAWN AS: MODELDEF binds glockrerig.iqm and the main hand to it.
class WM_PropBreachGlock : WM_Prop {}
