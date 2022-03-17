// Custom Airdrops for Simplex Support Services
// Author: klausman
// License: Apache 2 (https://www.apache.org/licenses/LICENSE-2.0)
//
// There is no need to edit this file. For more info see sss_airdrops.sqf

private ["_box", "_boxidx", "_boxdef", "_mags", "_weaps", "_items", "_boxes", "_smokes", "_packs"];

_box = _this select 0;
_boxidx = _this select 1;
_boxes = _this select 2;

_boxdef = _boxes select _boxidx;

_stuff = _boxdef select 4;

[format ["Intializing box %1 (type %2, %3)", _box, _boxidx, _boxdef], "SSS CADS", [false, true, false]] call CBA_fnc_debug;

clearItemCargoGlobal     _box;
clearWeaponCargoGlobal   _box;
clearMagazineCargoGlobal _box;
clearBackpackCargoGlobal _box;

{
  _thing = _x # 0;
  _count = _x # 1;
  private _isBackpack = [_thing] call ace_backpacks_fnc_isBackpack;
  private _itemType = ([_thing] call ace_common_fnc_getItemType) select 0;

  switch (true) do {
      case (_isBackpack): {
	  _object addBackpackCargoGlobal [_thing, _count];
      };
      case (_itemType == "weapon"): {
	  _object addWeaponCargoGlobal [_thing, _count];
      };
      case (_itemType == "magazine"): {
	  _object addMagazineCargoGlobal [_thing, _count];
      };
      default {
	  _object addItemCargoGlobal [_thing, _count]; //default "item"
      };
  };
} foreach _stuff;

_smokes =  _boxdef select 3;
if (count _smokes > 0) then {
  [
   {isNull (_this select 0)|| {getPos (_this select 0) select 2 < 2}},  // Condition
   { // Code
    private _pos = getpos (_this select 0);
    private _smks = _this select 1;
    [format ["Popping smoke at %1 (one each of %2)", _pos, _smks], "SSS CADS", [false, true, true]] call CBA_fnc_debug;
    {_x createVehicle _pos;} foreach _smks;
   },
   [_this select 0, _smokes]] // Params
   call CBA_fnc_waitUntilAndExecute;
};
