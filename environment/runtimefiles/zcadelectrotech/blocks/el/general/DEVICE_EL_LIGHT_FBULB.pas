unit DEVICE_EL_LIGHT_FBULB;
interface
uses system,devices;
usescopy objname;
usescopy slcabagenmodul;
var
SVName:GDBString;(*'Специальная имя для работы velec модуля'*)
SVNodeSeparate:TDevNodeSeparateMethod;(*'Наличие на устройстве ответвительной коробки'*)
implementation
begin
     BTY_TreeCoord:='PLAN_EM_типа светильник1?';
     SVName:='@@[NMO_Name]';
     NMO_BaseName:='HL';
     SVNodeSeparate:=TDT_NodeSeparateInside;
end.
