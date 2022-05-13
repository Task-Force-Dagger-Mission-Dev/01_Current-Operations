// Custom Airdrops for Simplex Support Services
// Author: klausman
// License: Apache 2 (https://www.apache.org/licenses/LICENSE-2.0)
//
// There is no need to edit this file. For more info see sss_airdrops.sqf

 private ["_l", "_idx", "_bt", "_bl", "_bi", "_code", "_boxes"];

_boxes = _this select 0;
 _idx = 0;
 _l = [];
 {
   _bl = _x select 0;  // Type (class)
   _bt = _x select 1;  // Label (as shown to players)
   _bi = _x select 2;  // Icon

   _code = format ["[""bi"", _this, %1] call compile preprocessFileLineNumbers ""pa\sss_airdrops.sqf""; ", _idx];

   _l pushBack [_bt, _bl, _bi, compile _code];
   _idx = _idx + 1;
 } foreach _boxes;

_l; // DO NOT REMOVE THIS LINE!
