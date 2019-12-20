unit DEVICE_EL_LIGHT_SWITH;
interface
uses system,devices;
usescopy objname;
usescopy slcabagenmodul;
var
SVName:GDBString;(*'Специальная имя для работы velec модуля'*)
SVNodeSeparate:TDevNodeSeparateMethod;(*'Наличие на устройстве ответвительной коробки'*)
implementation
begin
NMO_Name:='??';
NMO_Prefix:='';
NMO_Suffix:='';
NMO_BaseName:='QS';
NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';
SVName:='@@[NMO_Name]';
SVNodeSeparate:=TDT_NodeSeparateNeighbor;
end.

