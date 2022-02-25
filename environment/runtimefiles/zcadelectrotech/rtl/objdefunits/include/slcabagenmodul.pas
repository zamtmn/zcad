unit slcabagenmodul;
interface
uses system,devices;
var

SLCABAGEN_SLTypeagen:String;(*'Имя суперлинии/трассы монтажа кабеля'*)

SLCABAGEN_HeadDeviceName:String;(*'Имя головного устройства'*)

SLCABAGEN_NGHeadDevice:String;(*'Номер группы в головном устройстве'*)

//SLCABAGEN_CableRoutingNodes:String;(*'Промежуточные узлы прокладки кабеля от устройсва/УУ до головного устройства. Множественность через ~ '*)

SLCABAGEN_ControlUnitName:String;(*'Имя узла управления устройствами'*)

SLCABAGEN_NGControlUnit:String;(*'Номер группы в узле управления устройствами'*)

//SLCABAGEN_NGControlUnitNodes:String;(*'Промежуточные узлы прокладки кабеля от устройсва до УУ. Множественность через ~ '*)

SLCABAGEN_TypeCableRouting:TTypeCableRouting;(*'НЕРАБОТАЕТ. НЕТ ПОНИМАНИЯ ЧТО ЭТО. Прокладка кабеля одиночная/групповая.'*)

SLCABAGEN_DevConnectMethod:TDevConnectMethod;(*'Соединение устройств выполняется'*)

//SLCABAGEN_inerNodeWithoutConnection:Boolean;(*'Промежуточный узел. К головному стройству кабель не прокладывается'*)

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
