//////////////////////////////////////////////////////////
// JBOY_addEHFallFromVehicle.sqf 
// By: johnnyboy
// dummy = [dude] execVM "Scripts\JBOY_addEHFallFromVehicle.sqf";
// Put this in vehicle's init (if passengers all in the vehicle):
// {dummy = [_x] execVM "Scripts\JBOY_addEHFallFromVehicle.sqf";} foreach crew vehicle this;
// When killed, units in certain vehicle positions fall out.  Use for offroads, hummingbirds and zodiacs.
// This effect only occurs if helicopter is in air, and if offroads/zodiacs are moving.
//////////////////////////////////////////////////////////
_unit = _this select 0;
if (isPlayer _unit) exitwith {};
_unit addEventHandler ["Killed", 
{
    params ["_cvictim", "_ckiller"];
	if (isPlayer _cvictim) exitwith {};
    [_cvictim] spawn 
    {
        _cvictim = _this select 0;
        _veh = vehicle _cvictim;
        // We only execute the FallFromVehicle code for certain positions in certain vehicles
        if ((typeof _veh in ["B_Heli_Light_01_F"] and (_veh getCargoIndex _cvictim in [2,3,4,5])) or  // In hummingbird, only guys on benches fall
             (_veh isKindOf "Offroad_01_base_F"  and ((_veh getCargoIndex _cvictim in [0,1,2]) or (driver _veh) == _cvictim) and speed _veh >5) or   // In Offroad, only driver, front passenger, and 2 rear guys near tailgate
             (_veh isKindOf "Rubber_duck_base_F" and (_veh getCargoIndex _cvictim in [1,0]) and speed _veh >5)  // On zodiac, only 2 guys on sides of boat fall out
			or ((typeof _veh) iskindof "Boat_F" and boundingbox _veh select 1 select 1 < 9.5 and "vn" in typeOf _veh and speed _veh >5) // all small Prairie Fire boats
			 ) 
        then {
            _cargoIndex = _veh getCargoIndex _cvictim;
            _grp = createGroup CIVILIAN;
            _invisibleDude = objnull;
            _invisibleDude = _grp createUnit ["C_man_polo_2_F_afro",[100,0,0],[],0,"NONE"];
            hideObjectGlobal _invisibleDude;
            _invisibleDude allowDamage False;
            _invisibleDude setCaptive True;
            
            sleep .35; // allow time to see death animation in vehicle, then boot him out
            _invisibleDude moveInCargo [_veh, _cargoIndex];
            _pos = getpos _invisibleDude;
			_cvictim setpos (_pos vectorAdd [0,0,.5]);
			_cvictim addForce [_cvictim vectorModelToWorld [0,200*(selectRandom [-1,1]),500], _cvictim selectionPosition "head"];
             [_cvictim,selectRandom ["Grunt","Grunt","Grunt","Grunt","Grunt","Pain"]] call JBOY_Speak;
			sleep .2;
            deleteVehicle _invisibleDude;
               _pos2 = getpos _cvictim;
               // position falling dead dude close to original sitting position
               if (_veh isKindOf "Rubber_duck_base_F") then {
                  _cvictim setpos [_pos2 select 0, (_pos2 select 1)+1, (_pos2 select 2) + .5]; 
                  sleep .2;
                  // bullet to create splash effect when body hits water
                  _splashBullet = "B_408_Ball" createVehicle [10,10000,0];
                  _splashBullet enableCollisionWith _cvictim;
                  _splashBullet setmass 50;
                  _splashBullet setpos (_cvictim modelToWorld [0,.1,.2]);
                  _splashBullet setvelocity [0,0,-1000];
              };
               if (_veh isKindOf "Offroad_01_base_F") then {
                  _cvictim setpos [_pos2 select 0, (_pos2 select 1)-1, (_pos2 select 2) + .6]; 
                  sleep .2;
                  // bullet to create dust effect when body hits water
                  _splashBullet = "B_408_Ball" createVehicle [10,10000,0];
                  _splashBullet enableCollisionWith _cvictim;
                  _splashBullet setmass 50;
                  _splashBullet setpos (_cvictim modelToWorld [0,.1,.2]);
                  _splashBullet setvelocity [0,0,-1000];
               };
//            };
        };
    };
}];
