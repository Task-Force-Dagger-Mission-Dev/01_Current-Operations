// JIP Check (This code should be placed first line of init.sqf file)
if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};

//Exec Vcom AI function
[] execVM "Unit\Anti_cheat\CheatInit.sqf";
[] execVM "Unit\TowArtillery.sqf";

//Convoy Scripts
[] execVM "convoy\convoyInit.sqf";




//////////////////////View Distance Settings///////////////////////////////////////////////////////////////////////////////////////////

CHVD_allowNoGrass = false;
CHVD_maxView = 6000;
CHVD_maxObj = 6000;



