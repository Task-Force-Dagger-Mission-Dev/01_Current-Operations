attachgun = {
 _vehicles = nearestObjects [_this, ["Car","Truck"], 8];
 if (count _vehicles==0) then {
  hint format ["No vehicle within 3 meters."];
 } else {
  if (_this doorPhase 'fold_arty' == 1) then {
   _this attachto [(_vehicles select 0),[0,-5,-2.5]];
   removeAllActions _this;
   _this addAction["Detach from truck",{(_this select 0) call detachgun;},[],1.5,true,true,"","true",3];
  } else {
   hint format ["Gun is not folded, can't attach"];
  };
 };
};

detachgun = {
 if (_this doorPhase 'fold_arty' == 1) then {  
detach _this;
  removeAllActions _this;
  _this addAction["Attach to truck",{(_this select 0) call attachgun;},[],1.5,true,true,"","true",3];
 } else {
  hint format ["Gun is not folded, can't detach"];
 };
};