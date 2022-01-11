//nul = execVM "GroupSpawner.sqf";
//this addaction ["spawn AI", "GroupSpawner.sqf"];

//_crew1 = [];

//_airframe1 = [];
//_crew1 = creategroup WEST;
//_airframe1 = [getMarkerPos "marker", bearing, "vehicle classname", _crew1] call BIS_fnc_spawnVehicle;
//_team1 = [];
_pos1 = (getmarkerpos "marker_29") vectorAdd [0,0,425];
_para = "B_Parachute_02_F";




if (isServer) then {
//_team1 = [_pos1, east, "rhs_bmp2_vdv",[],[],[],[],[],0] call BIS_fnc_spawnGroup;
_pos1 = (getmarkerpos "marker_29") vectorAdd [0,0,225];
_para = "B_Parachute_02_F";
_vehicle = "rhs_bmp2_vdv" createVehicle (getmarkerpos "marker_29");
createVehicleCrew _vehicle;
_vehicle setPosATL (_vehicle modelToWorld[0,0,225]);
_DropPos1 = getpos _vehicle;

_chute1 = createVehicle [_para, _vehicle, [], 0, "NONE"];
_vehicle attachTo [_chute1, [0, 0, 3]];

//_wp1 = _team1 addWaypoint [getmarkerpos "wp1_1", 0];
    //_wp1 setWaypointType "MOVE";
    //_wp1 setWaypointSpeed "FULL";
    //_wp1 setWaypointBehaviour "AWARE";
    //_wp1 setWaypointFormation "LINE";
	
};

//_wp1 = _crew1 addWaypoint [getmarkerpos "wp1_1", 0];
//	_wp1 setWaypointType "TR UNLOAD"; 
//	_wp1 setWaypointSpeed "FULL";
//	_wp1 setwaypointstatements ["this land 'land'"];

//_mygroup = [getmarkerpos "EXAMPLE VARIABLE NAME", Side, ["Class_Name"],[],[],[],[],[],Spawn bearing] call BIS_fnc_spawnGroup;
//_wp1a = _mygroup addWaypoint [getmarkerpos "wp1_1", 0];

//sleep x;
//_mygroup = _mygroup;
//{_x assignAsCargo (_airframe1 select 0); _x moveInCargo (airframe1 select 0);} foreach units _mygroup;
// add }; at the end