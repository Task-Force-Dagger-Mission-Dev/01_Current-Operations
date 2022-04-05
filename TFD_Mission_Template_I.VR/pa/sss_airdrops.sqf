// Custom Airdrops for Simplex Support Services
// Author: klausman
// License: Apache 2 (https://www.apache.org/licenses/LICENSE-2.0)
//
// Usage: 
// - Add this script and the two companion scripts (sss_airdrops_bi.sqf and
//   sss_airdrops_gl.sqf) to your mission in a subfolder called `pa`
// - edit box contents as indicated below, then add a SSS Logistics
//   Airdrop module to your mission and add this line in `List function`:
//   ["gl"] call compile preprocessFileLineNumbers "pa\sss_airdrops.sqf"
//
private ["_mode", "_boxes"];
_mode = _this select 0;

[format ["Called in mode %1", _mode], "SSS CADS", [false, true, true]] call CBA_fnc_debug;


// BOX DEFINITIONS START

// FORMAT
// This should be an array of box definitions. Each Box definition has these
// components:
//
// [
//  "In-game Label",
//  "Box Classname",
//  "Icon", 
//  ["Smoke", "Chemlight"],
//  [
//   ["some object class", N],
//   ["some other object class", N]
//  ]
// ]
//
// Label is what the players see in the logistics menu
// Box Classname is the box type, e.g. Box_NATO_Ammo_F. Vehicles work
//   the same way as boxes (including setting their inventory).
// Icon is used in the logistics menu and optional
// The Smoke or Chemlight list is a list of throwables that will be
//   spawned once the box hits the ground. Leave as [] for no markers.
// The next line sets the contents of the box. Note these are arrays of
//   classnames and numbers, setting the object and count of them (N).
//
// Example (two boxes of the same type, but with different contents,
// with the second getting a orange smoke shell on touchdown):
_boxes = [
  
  ["Standard Resupply", "B_supplyCrate_F", "", ["SmokeShellOrange"],
   [
    ["rhsusf_200Rnd_556x45_M855A1_mixed_soft_pouch", 10],
    ["Tier1_30Rnd_556x445_Mk318Mod0_EMag", 50],
    ["Tier1_30Rnd_556x445_M856_EMag", 50],
    ["Tier1_15Rnd_9x19_FMJ", 15],
    ["Tier1_30Rnd_762x35_300BLK_EMag", 40],
    ["rhsusf_50Rnd_762x51_m61_ap", 10],
    ["rhsusf_50Rnd_762x51_m62_tracer", 10],
    ["rhsusf_50Rnd_762x51", 10],
    ["rhsusf_mag_15Rnd_9x19_FMJ", 15],
    ["rhsusf_mag_7x45acp_MHP", 15],
    ["1Rnd_HE_Grenade_shell", 20],
    ["rhs_mag_maaws_HE", 5],
    ["rhs_mag_maaws_HEDP", 5],
    ["rhs_mag_maaws_HEAT", 5],
    ["SmokeShell", 20],
    ["HandGrenade", 10],
    ["ACE_M84", 10],
    ["ACE_SpareBarrel", 3],
    ["DemoCharge_Remote_Mag", 6],
    ["ClaymoreDirectionalMine_Remote_Mag", 6],
    ["ACE_elasticBandage", 100],
    ["ACE_packingBandage", 100],
    ["ACE_quikclot", 100],
    ["ACE_epinephrine", 70],
    ["ACE_morphine", 70],
    ["ACE_splint", 50],
    ["ACE_tourniquet", 50],
    ["ACE_salineIV_250", 30],
    ["ACE_salineIV_500", 30],
    ["ACE_salineIV", 15]
   ]
  ]
];

// BOX DEFINITIONS END -- no need to edit below this line

if (_mode == "bi")  
    exitWith {
	[_this select 1, _this select 2, _boxes] call 
	compile preprocessFileLineNumbers "pa\sss_airdrops_bi.sqf";
  };
  
if (_mode == "gl") 
    exitWith {
	[_boxes] 
	call compile preprocessFileLineNumbers "pa\sss_airdrops_gl.sqf";
  };
