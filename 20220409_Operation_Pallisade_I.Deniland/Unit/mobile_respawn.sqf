while {true} do
{
	"blufor_respawn" setMarkerPos getPos vehicleName;
	sleep 0.5;
};

[missionNamespace, this] call BIS_fnc_addRespawnPosition;
//You can edit "missionNamespace" to ie. west, east etc. depending on who you want to be able to respawn.