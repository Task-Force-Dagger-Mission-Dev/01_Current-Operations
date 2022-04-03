// JBOY_boatMove.sqf
// _n = [boat1,20] spawn JBOY_boatMoveWaypoints;

if (!isServer)  exitwith {};
params["_veh","_cruiseSpeed"];

//player sidechat str ["start boat move",_veh, _cruiseSpeed];
	_veh engineOn true;
	_driver = driver _veh;
	_destPos = _veh getVariable "JBOY_boatDestPos";
	_veh setVariable ["JBOY_boatBusyMoving", true, true];
	_veh setVariable ["cruiseSpeed", _cruiseSpeed, true];
	_veh setVariable ["cruiseDir", vectorDir _veh, true];

	_option = '';
	{_option=_x; {_x disableAI _option;} foreach crew _veh;} foreach ["PATH","MOVE","FSM"];
	{_x allowFleeing 0;} foreach crew _veh;

	_grp = group _driver;
	_veh setVariable ["JBOY_currentVelocityModelSpace", velocityModelSpace _veh, true];
	_veh setVariable ["JBOY_boatBusyTurning", true, true];
	_veh setVariable ["currVel",  velocity _veh, true];
	_vms = _veh setVariable ["JBOY_i",0,true]; // counter used for mod function in eachFrame so setVectorDirAndUp happens every other frame
	_veh addEventHandler ["animDone", 
	{
		_dmy = 0;
	}];
// Function to call a Mission Event handler that calls a function.  Arguments are passed to the function
// by adding them to a MissionNameSpace variable whose name is a string plus the EH ID.
fnc_jboyAddMissionEventHandler = 
{
    params ["_args","_fnc"];
	
    private _thisEventHandler = addMissionEventHandler [
        'EachFrame',
        format [
            '_thisEventHandler call %1',
            _fnc
        ]
    ];
    missionNamespace setVariable ["ncb_gv_ehIdArgs_" + (_thisEventHandler toFixed 0),_args];
    _thisEventHandler
};

// crew members shout when reacting to first contact
fnc_jboyBoatReactToContact =
{
	params["_veh"];
	if !((typeof _veh) iskindof "Boat_F") exitwith {};
	[crew _veh #0,selectRandom ["TakeCover","GoProne_1","EnemyDetected_1","Contacte_1","UnderFiree_1"]] call JBOY_Speak;
	sleep .8;
	if ({alive _x} count crew _veh > 1) then 
	{
		[crew _veh #1,selectRandom ["EnemyDetected_2","EnemyDetected_4","EnemyDetected_8","EnemyDetected_9","EndangeredE_1","EndangeredE_2","EndangeredE_3"]] call JBOY_Speak;
	};
	sleep 1;
	if ({alive _x} count crew _veh > 2) then 
	{
		[crew _veh #2,selectRandom ["Contacte_2","Contacte_3","CombatGenerice_1","CombatGenerice_2","CombatGenerice_3","CombatGenerice_4"]] call JBOY_Speak;
	};
	if (alive driver _veh 
		and (boundingbox _veh select 1 select 1 < 9.5 and "vn" in typeOf _veh) // must be one of the Vietnamese small boats 
		and selectRandom [false,false,false,true] ) then // 25% chance to attach smoke to back of boat to obscure getaway
	{
		sleep 2;
		[driver _veh,selectRandom ["ThrowingSmokee_1","ThrowingSmokee_2"]] call JBOY_Speak; 
		sleep 2;
		_smoke = (selectRandom ["SmokeShell","SmokeShell","SmokeShellRed","SmokeShellYellow"]) createVehicle [0,0,0];
		_smoke attachto [_veh,[.15,.4,-.3],"volant_bracket"]; // attach just below deck so don't see canister jerking around
	};
};

fnc_jboyBoatMoveEH = 
{
    // the var is an array that is passed immediately to params
    missionNamespace getVariable ("ncb_gv_ehIdArgs_" + (_thisEventHandler toFixed 0)) params ["_veh","_cruiseSpeed"];
		_cruiseSpeed = _veh getVariable "cruiseSpeed";
		_increment = .01;
		if (behaviour driver _veh == 'COMBAT') then 
		{
			_increment = .01;
			_cruiseSpeed = _veh getVariable "JBOY_maxSpeed";
			if (_veh getVariable "JBOY_firstContact") then
			{
				_veh setVariable ["JBOY_firstContact", false, true];
				_n=[_veh] spawn fnc_jboyBoatReactToContact;
			};
		};
_reverse = _veh getVariable "JBOY_reverse";
if (_reverse) then {_cruiseSpeed = _cruiseSpeed * -1; _increment = _increment * -1;};
		_cruiseDir = _veh getVariable "cruiseDir";
		_destPos = _veh getVariable "JBOY_boatDestPos";
		_distance = 15;
		if (_veh getVariable "JBOY_waypointType"=="GETOUT") then // Don't end getout wps early, we want boat to beach itself
		{
			_distance = 1;
		};
		
		if (!alive _veh or _veh getVariable "CruiseControlAbort" 
			or !(surfaceIsWater getPosASLVisual _veh)
			or (getPosASLVisual _veh) distance _destPos < _distance
			or ({alive _x} count crew _veh == 0
			or !alive driver _veh)
			or isPlayer driver _veh
				//or _currentWP < currentWaypoint _grp
			) then 
		{
			_veh setVariable ["JBOY_boatBusyMoving", false, true];
			_veh removeAllEventHandlers "AnimDone";
			removeMissionEventHandler ["EachFrame",_this];
			missionNamespace setVariable ["ncb_gv_ehIdArgs_" + (_thisEventHandler toFixed 0),nil];
		} else
		{
			if (alive _veh and _veh getVariable "CruiseControlOn" 
			//and alive (driver _veh)
			) then 
			{
				// accelerate vehicle to cruise speed
				if (speed _veh < abs(_cruiseSpeed) and getpos _veh select 2 < .4
				) then
				{

					_courseCorrection = 0;
					_vms = [0, (velocityModelSpace _veh # 1)+_increment, 0];
					_veh setVelocityModelSpace _vms;  // accelerate incrementally to reach cruise speed
					_veh setVariable ["JBOY_currentVelocityModelSpace", _vms, true];
				};
				_destPos = _veh getVariable "JBOY_boatDestPos";
				if !(_reverse) then // do not change direction when in reverse
				{
					_veh setVariable ["JBOY_boatBusyTurning", true, true];
					//player groupchat str ["Start Turn Boat",_veh];
					_destPos =  _veh getVariable "JBOY_boatDestPos";
					_degreesToRotate = _veh getRelDir _destPos;
					_posOrneg = 1;
					if (_degreesToRotate > 180) then
					{
						_posOrneg = -1;
					};
					_increment = .5;
					if (speed _veh < 10) then {_increment = .3;};

					//while {abs(getDir _veh - ([_veh, _destPos] call BIS_fnc_dirTo)) > .5
					if (_veh getRelDir _destPos > 2) then
					{
						_i = _veh getVariable "JBOY_i";
						_i = _i + 1;
						_vms = _veh setVariable ["JBOY_i",_i,true];
						if (_i mod 2 == 0 ) then // this is an attempt to prevent stopping while turning
						{
							_vms = _veh getVariable "JBOY_currentVelocityModelSpace"; // get velocityModelSpace before setDir, because setDir clears velocity
							_dir = (getDir _veh + (_increment * _posOrneg));
							_heading = [getpos _veh, ([_veh, 10, _dir] call BIS_fnc_relPos)] call BIS_fnc_vectorFromXToY;
							_veh setVectorDirAndUp [_heading,vectorUp _veh]; 

							_veh setVelocityModelSpace _vms; // keep boat moving by using previous VMS value (since setDir and setVectorDirAndUp stop velocity)
						};
					};
					_veh setVariable ["JBOY_boatBusyTurning", false, true];
				};
			};
		 };
		//systemchat format ["speed _veh=%1",str (speed _veh)];
};
_id = [[_veh,_cruiseSpeed],"fnc_jboyBoatMoveEH"] call fnc_jboyAddMissionEventHandler;
