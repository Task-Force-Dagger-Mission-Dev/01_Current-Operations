if (player getVariable ["isSneaky",false]) then {
    [player] execVM "INC_undercover\Scripts\initUCR.sqf";
};

player enableStamina false;   
player setCustomAimCoef 0.0;