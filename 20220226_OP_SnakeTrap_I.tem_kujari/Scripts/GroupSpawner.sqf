//nul = execVM "GroupSpawner.sqf";
//this addaction ["spawn AI", "GroupSpawner.sqf"];

//_crew1 = [];

//_airframe1 = [];
//_crew1 = creategroup WEST;
//_airframe1 = [getMarkerPos "marker", bearing, "vehicle classname", _crew1] call BIS_fnc_spawnVehicle;
//_team1 = [];

_allPlayers = allUnits select {isPlayer _x && {alive _x} && {!(_x isKindOf "HeadlessClient_F")}};
_player = selectRandom _allPlayers;
_team1 = [];
_team2 = [];



if (isServer) then {
//_team1 = [_pos1, east, "rhs_bmp2_vdv",[],[],[],[],[],0] call BIS_fnc_spawnGroup;

_team1 = [getmarkerpos "ins1", east, ["UK3CB_ADE_O_LAT", 
"UK3CB_ADE_O_RIF_1", 
"UK3CB_ADE_O_ENG", 
"UK3CB_ADE_O_DEM", 
"UK3CB_ADE_O_SL", 
"UK3CB_ADE_O_TL", 
"UK3CB_ADE_O_MD", 
"UK3CB_ADE_O_MK"],[],[],[],[],[],0] call BIS_fnc_spawnGroup;

_wp1 = _team1 addWaypoint [position _player];
    _wp1 setWaypointType "SAD";
    _wp1 setWaypointSpeed "FULL";
    _wp1 setWaypointBehaviour "AWARE";
    -wp1 setWaypointFormation "COLUMN";

_team2 = [getmarkerpos "ins2", east, ["UK3CB_ADE_O_BRDM2_HQ"],[],[],[],[],[],0] call BIS_fnc_spawnGroup;

_wp2 = _team2 addWaypoint [position _player];
    _wp2 setWaypointType "SAD";
    _wp2 setWaypointSpeed "FULL";
    _wp2 setWaypointBehaviour "AWARE";
    -wp2 setWaypointFormation "COLUMN";

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