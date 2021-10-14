unit slcabagenmodul;
interface
uses system,devices;
var

SLCABAGEN_SLTypeagen:GDBString;(*'Имя суперлинии/трассы монтажа кабеля'*)

SLCABAGEN_HeadDeviceName:GDBString;(*'Имя головного устройства'*)

SLCABAGEN_NGHeadDevice:GDBString;(*'Номер группы в головном устройстве'*)

//SLCABAGEN_CableRoutingNodes:GDBString;(*'Промежуточные узлы прокладки кабеля от устройсва/УУ до головного устройства. Множественность через ~ '*)

SLCABAGEN_ControlUnitName:GDBString;(*'Имя узла управления устройствами'*)

SLCABAGEN_NGControlUnit:GDBString;(*'Номер группы в узле управления устройствами'*)

//SLCABAGEN_NGControlUnitNodes:GDBString;(*'Промежуточные узлы прокладки кабеля от устройсва до УУ. Множественность через ~ '*)

SLCABAGEN_TypeCableRouting:TTypeCableRouting;(*'НЕРАБОТАЕТ. НЕТ ПОНИМАНИЯ ЧТО ЭТО. Прокладка кабеля одиночная/групповая.'*)

SLCABAGEN_DevConnectMethod:TDevConnectMethod;(*'Соединение устройств выполняется'*)

//SLCABAGEN_inerNodeWithoutConnection:GDBBoolean;(*'Промежуточный узел. К головному стройству кабель не прокладывается'*)

implementation
begin

   SLCABAGEN_SLTypeagen:='???';
   SLCABAGEN_HeadDeviceName:='???';
   SLCABAGEN_NGHeadDevice:='???';
   //SLCABAGEN_CableRoutingNodes:='-';
   SLCABAGEN_ControlUnitName:='-';
   SLCABAGEN_NGControlUnit:='-';
   //SLCABAGEN_NGControlUnitNodes:='-';
   SLCABAGEN_SLTest:='???';
   SLCABAGEN_TypeCableRouting:=TDT_GroupRouting;
   SLCABAGEN_DevConnectMethod:=TDT_CableConnectParallel;
   //SLCABAGEN_inerNodeWithoutConnection:=false;
   
end.
