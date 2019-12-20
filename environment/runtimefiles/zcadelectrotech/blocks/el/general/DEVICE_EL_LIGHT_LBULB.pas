unit DEVICE_EL_LIGHT_LBULB;
interface
uses system,devices;
usescopy objname;
usescopy slcabagenmodul;
var
SVName:GDBString;(*'Специальная имя для работы velec модуля'*)
SVNodeSeparate:TDevNodeSeparateMethod;(*'Наличие на устройстве ответвительной коробки'*)
implementation
begin
     BTY_TreeCoord:='PLAN_EM_типа светильник2?';
     NMO_BaseName:='HL';
     SVName:='@@[NMO_Name]';
     SVNodeSeparate:=TDT_NodeSeparateInside;
end.
