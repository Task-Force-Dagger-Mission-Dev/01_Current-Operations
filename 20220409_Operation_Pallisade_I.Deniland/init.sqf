// JIP Check (This code should be placed first line of init.sqf file)
if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};

//Exec Vcom AI function
[] execVM "Vcom\VcomInit.sqf";
[] execVM "Unit\Anti_cheat\CheatInit.sqf";
[] execVM "Unit\TowArtillery.sqf";

call compile preprocessFile "JBOY\boatMove.sqf";
JBOY_Speak =  compile preprocessFileLineNumbers "JBOY\JBOY_Speak.sqf";
JBOY_PainGrunt =  compile preprocessFileLineNumbers "JBOY\JBOY_PainGrunt.sqf";
JBOY_BreatheSfx =  compile preprocessFileLineNumbers "JBOY\JBOY_BreatheSfx.sqf";
JBOY_PainSfx =  compile preprocessFileLineNumbers "JBOY\JBOY_PainSfx.sqf";
JBOY_Lip =  compile preprocessFileLineNumbers "JBOY\JBOY_Lip.sqf";



//////////////////////View Distance Settings///////////////////////////////////////////////////////////////////////////////////////////

CHVD_allowNoGrass = false;
CHVD_maxView = 6000;
CHVD_maxObj = 6000;



