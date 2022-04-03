// boatMove.sqf
// Only use this when vehicle is traveling straight.
// _n = [boat1,5] spawn JBOY_boatMoveWaypoints;
/* TODO:
- support reverse to get off shore
- Verify transport unload works
- Make Hold work.
- Add in offset optional parameter for wp position
- Explosions addForce to boat
-- suspend setVelocityModelSpace
-- addForce to push up and away from grenade
-- end suspend svms
- Danger Reactions:
-- Increase speed to max and carry on.
-- Turn toward danger, beach it and fight.
-- Turn toward opposite shore.
-- Go swimming
-- Power thru, and pullover and go back to hunt.

Notes:
- If driver killed and next driver not in same group, then waypoints lost and boat will get stuck.

*/
JBOY_boatMoveWaypoints = 
{
	params["_veh",["_speed",0],["_xOffset",0]];
	if (_veh getVariable ["JBOY_boatBusyMoving",false]) exitwith {};
	if !((typeof _veh) iskindof "Boat_F") exitwith {};
	
	_veh setVariable ["JBOY_boatBusyMoving", true, true];
	_veh setVariable ["JBOY_boatBusyTurning", false, true];
	_veh setVariable ["JBOY_boatCrew", crew _veh, true];
	_veh setVariable ["JBOY_firstContact", true, true];
	// CruiseControlAbort=false; 
	// CruiseControlOn = true;
	_veh setVariable ["CruiseControlAbort", false, true];
	_veh setVariable ["CruiseControlOn", true, true];
	_driver = driver _veh;
	_grp = group _driver;
	_prevWaypoint = -1;
	_lastPos = [];
	_helper = "Sign_Sphere25cm_F" createVehicle [10,10000,0];
	hideObjectGlobal _helper;
	_veh setVariable ["JBOY_boatHelper", true, true];

	{
		if (_x == driver _veh or (selectRandom [true,true,false])) then
		{
			[_x] execVM "JBOY\JBOY_addEHFallFromVehicle.sqf";
		};
	} foreach crew _veh; // units fall from vehicle 
	
	_LimitedFactor = .25;
	_NormalFactor = .5;
	_FullFactor = .75;
	_setSpeedBySpeedMode = false;
	_reverse = false;
	_maxSpeed = getNumber (configfile >> "CfgVehicles" >> typeOf _veh >> "maxspeed");
	_veh setVariable ["JBOY_maxSpeed",_maxSpeed, true];

	if (_speed == 0) then {_setSpeedBySpeedMode = true;};
	
	_currWP = currentwaypoint _grp;
	while {alive _veh 
		and count waypoints _grp > 1
		and {alive _x} count crew _veh > 0
		//and _prevWaypoint < _currWP
		and surfaceIsWater getPosASLVisual _veh
		and currentwaypoint _grp < (count waypoints _grp)-1
		and !isPlayer driver _veh
		and waypointType [_grp,_currWP] in ['MOVE','TALK','CYCLE','GETOUT']
		} do
	{
		_grp lockWp true;
		_destPos = waypointPosition [_grp,_currWP];
		_helper setpos _destpos;
		_helper setDir ([_veh,_helper] call BIS_fnc_dirTo);
		_destPos = _helper modelToWorld [_xOffset,0,0];
		_veh setVariable ["JBOY_boatBusyMoving", true, true];
		_veh setVariable ["JBOY_boatDestPos", _destPos, true];
		_veh setVariable ["JBOY_reverse", false, true];
		if ("reverse" in (waypointDescription [_grp,_currWP])) then {_veh setVariable ["JBOY_reverse", true, true];};

		_prevWaypoint = _currWP;
		if (_setSpeedBySpeedMode) then
		{
			_speedMode = speedMode _grp;
			switch (_speedMode) do   
			{  
				case "LIMITED": {_speed = _maxSpeed * _LimitedFactor;};
				case "NORMAL":  {_speed = _maxSpeed * _NormalFactor;};
				case "FULL":    {_speed = _maxSpeed * _FullFactor;};
			};
		};
		if (behaviour driver _veh == "COMBAT") then {_speed = _maxSpeed;} else {_veh setVariable ["JBOY_firstContact", true, true];};

		_nul = [_veh, _speed] spawn {params["_veh","_speed"];_d = [_veh,_speed] execvm "JBOY\JBOY_boatMove.sqf";};
		sleep 4;
		_future = time + 30; // if not moved in 30 seconds, then boat is stuck
		_lastPos = getPosASLVisual  _veh;
//diag_log str ["b4 waituntil",_prevWaypoint,_destPos, getpos _veh,"_speed",_speed,speed _veh, speedMode _grp];
		waitUntil {sleep .2; !alive _veh 
				// or !(_currentWaypoint == currentwaypoint _grp) 
				or !(_veh getVariable "JBOY_boatBusyMoving")
				or (time > _future and (getPosASLVisual _veh) distance _lastPos < 3)
				};
if (vehicle player isEqualTo _veh) then {diag_log str ["after waitUntil JBOY_boatBusyMoving=",_veh, _veh getVariable "JBOY_boatBusyMoving",_currWP,waypointType [_grp,_currWP],(getPosASLVisual _veh) distance _lastPos];};
		_grp lockwp false;
		[_grp,_currWP] setWaypointCompletionRadius 30;
		_currWP = _currWP+1;
		if (waypointType [_grp,_currWP] == 'CYCLE') then
		{
			_cyclePos = waypointPosition [group _veh,_currWp]; 
			_arr=[waypoints group _veh, {_x select 1 < _currWp}] call BIS_fnc_conditionalSelect;  
			_newArr = _arr apply {_x select 1, [waypointPosition _x distance _cyclePos,_x select 1] }; 
			_newArr sort true; 
			if (count _newArr > 0) then {_currWP = _newArr select 0 select 1; }; // waypoint index closest to cycle waypoint
		};
		_talker = leader driver _veh;
		if !(isNull gunner _veh) then {_talker = gunner _veh;};
		_talker setVariable ["JBOY_speaker",speaker _talker,true]; // prevent voice spam calling out every waypoint
		_talker setSpeaker "NoVoice";
		_grp setCurrentWaypoint [_grp, _currWP];
		[_talker] spawn {params["_unit"];sleep 1; _unit setSpeaker (_unit getVariable "JBOY_speaker");};
	}; // end while
	_veh setVariable ["JBOY_boatBusyMoving", false, true];

	{_option=_x; {_x enableAI _option;} foreach (_veh getVariable "JBOY_boatCrew");} foreach ["PATH","MOVE","FSM"];
	if !(surfaceIsWater getPosASLVisual _veh) then {{moveOut _x; unassignVehicle _x; sleep .5; } foreach (_veh getVariable "JBOY_boatCrew"); _grp leaveVehicle _veh;};
};
/*
// [boat1, ] spawn JBOY_turnBoat;
JBOY_turnBoat = 
{
	params["_veh","_targetPos"];
	//_dirTo = [_veh, _targetPos] call BIS_fnc_dirTo;
	_veh setVariable ["JBOY_boatBusyTurning", true, true];
player groupchat str ["Start Turn Boat",_veh];
	_degreesToRotate = _veh getRelDir _targetPos;
	_posOrneg = 1;
	if (_degreesToRotate > 180) then
	{
		_posOrneg = -1;
	};
	_increment = .5;
	_i = 0;

	//while {abs(getDir _veh - ([_veh, _targetPos] call BIS_fnc_dirTo)) > .5
	while {_veh getRelDir _targetPos > 2
		and alive _veh
		and surfaceIsWater getPosASLVisual _veh
		and !(isPlayer driver _veh)
		and alive driver _veh} do
	{
		_i = _i + 1;
//		if (speed _veh >= 6 or true ) then // this is an attempt to prevent stopping while turning
		if (_i mod 2 == 0 ) then // this is an attempt to prevent stopping while turning
		{
			_vms = _veh getVariable "JBOY_currentVelocityModelSpace"; // get velocityModelSpace before setDir, because setDir clears velocity
			_veh setdir (getDir _veh + (_increment * _posOrneg));
			_veh setVelocityModelSpace _vms; // keep boat moving by using previous VMS value after setDir stops the boat
		};
		sleep .003;
	};
	_veh setVariable ["JBOY_boatBusyTurning", false, true];
player groupchat str ["End Turn Boat",_veh];
};
*/
/*
_dir = (getDir _veh + (_increment * _posOrneg));
//_veh setdir (getDir _veh + (_increment * _posOrneg));
_heading = [getpos _veh, ([_veh, 10, _dir] call BIS_fnc_relPos)] call BIS_fnc_vectorFromXToY;
_veh setVectorDir _heading; 
// _velocity = [_heading, floor(_speed)] call BIS_fnc_vectorMultiply; 
// _veh setVelocity _velocity;


// _n = [boat1,15] spawn JBOY_boatMove;
JBOY_boatMoveOld = 
{
	params["_veh","_speed"];
hint str ["start boat move",_veh, _speed];
	//diag_log ["_this",_this];
	CruiseControlAbort = false;  // set this true externally to stop cruise control
	CruiseControlOn = true;      // toggle this externally to control when setVelocityModeSpace is applied to vehicle
	_veh engineOn true;
	_driver = driver _veh;
	// _destPos = waypointPosition [group _driver, currentwaypoint group _driver];
	// CruiseVeh setVariable ["JBOY_boatDestPos", _destPos, true];
	_destPos = _veh getVariable "JBOY_boatDestPos";
cwp setpos _destPos;
	CruiseVeh = _veh;
	CruiseVeh setVariable ["JBOY_boatBusyMoving", true, true];
	CruiseVeh setVariable ["cruiseSpeed", _speed, true];
	CruiseVeh setVariable ["cruiseDir", vectorDir _veh, true];
	systemchat str [CruiseVeh,CruiseVeh getVariable "cruiseSpeed"];
	
	// make driver retarded so he won't veer off course
	{_driver disableAI _x} foreach ["TARGET","AUTOTARGET","SUPPRESSION","AUTOCOMBAT","COVER","PATH","MOVE","FSM"];
	_driver allowFleeing 0;
	_driver setBehaviour "CARELESS";
	_driver setCombatMode "BLUE";        

	_grp = group _driver;
	_currentWP = currentwaypoint _grp;
	[_veh, (waypointPosition [group _driver, currentwaypoint group _driver])] spawn JBOY_turnBoat;
	_veh addEventHandler ["animDone", 
	{
		// pos1 = pos2; 
		// pos2 = pos2 vectorAdd [0,0,0.75]
		_dmy = 0;
	}];
	onEachFrame
	{
		_veh = CruiseVeh;
		_speed = CruiseVeh getVariable "cruiseSpeed";
		_cruiseDir = CruiseVeh getVariable "cruiseDir";
		_destPos = CruiseVeh getVariable "JBOY_boatDestPos";
		_distance = 0;
		if (!alive _veh or CruiseControlAbort 
			or !(surfaceIsWater getPosASLVisual _veh)
			or (getPosASLVisual _veh) distance _destPos < 15
				//or _currentWP < currentWaypoint _grp
			) then 
		{
			onEachFrame {}; 
	systemchat str ["end boat move",_veh];
			CruiseVeh setVariable ["JBOY_boatBusyMoving", false, true];
			_veh removeAllEventHandlers "animDone";
		} else
		{
			if (alive _veh and CruiseControlOn) then 
			{
				// accelerate vehicle to cruise speed
				// setDir and setVectorDir not compatible with setVelocityModelSpace, so how to slowly alter course?
				if (speed _veh < _speed and getpos _veh select 2 < .2
				) then
				{
					_courseCorrection = 0;
					_veh setVelocityModelSpace [0, (velocityModelSpace _veh # 1)+.01, 0];  // accelerate incrementally to reach cruise speed
				};
			};
	systemchat format ["boat speed = %1, cruise speed=%2", speed _veh, _speed];
		 };
		//systemchat format ["speed _veh=%1",str (speed _veh)];
	};
};
*/