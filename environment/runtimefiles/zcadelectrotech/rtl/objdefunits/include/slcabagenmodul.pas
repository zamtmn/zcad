unit slcabagenmodul;
interface
uses system,devices,cables;
var

SLCABAGEN1_SLTypeagen:String;(*'Имя суперлинии/трассы монтажа кабеля'*)

SLCABAGEN1_HeadDeviceName:String;(*'Имя головного устройства'*)

SLCABAGEN1_NGHeadDevice:String;(*'Номер группы в головном устройстве'*)

//SLCABAGEN_CableRoutingNodes:String;(*'Промежуточные узлы прокладки кабеля от устройсва/УУ до головного устройства. Множественность через ~ '*)

SLCABAGEN1_ControlUnitName:String;(*'Имя узла управления устройствами'*)

SLCABAGEN1_NGControlUnit:String;(*'Номер группы в узле управления устройствами'*)

//SLCABAGEN_NGControlUnitNodes:String;(*'Промежуточные узлы прокладки кабеля от устройсва до УУ. Множественность через ~ '*)

SLCABAGEN1_TypeCableRouting:TTypeCableRouting;(*'НЕРАБОТАЕТ. НЕТ ПОНИМАНИЯ ЧТО ЭТО. Прокладка кабеля одиночная/групповая.'*)

SLCABAGEN1_DevConnectMethod:TDevConnectMethod;(*'Соединение устройств выполняется'*)

SLCABAGEN1_CabConnectAddLength:Double;(*'Добавить к длине кабеля при подключении'*)

SLCABAGEN1_CabConnectMountingMethod:TDCableMountingMethod;(*'Метод монтажа кабеля при подключения'*)

//SLCABAGEN_inerNodeWithoutConnection:Boolean;(*'Промежуточный узел. К головному стройству кабель не прокладывается'*)

implementation
begin

   SLCABAGEN1_SLTypeagen:='???';
   SLCABAGEN1_HeadDeviceName:='???';
   SLCABAGEN1_NGHeadDevice:='???';
   //SLCABAGEN_CableRoutingNodes:='-';
   SLCABAGEN1_ControlUnitName:='-';
   SLCABAGEN1_NGControlUnit:='-';
   //SLCABAGEN_NGControlUnitNodes:='-';
   SLCABAGEN1_SLTest:='???';
   SLCABAGEN1_TypeCableRouting:=TDT_GroupRouting;
   SLCABAGEN1_DevConnectMethod:=TDT_CableConnectParallel;
   //SLCABAGEN_inerNodeWithoutConnection:=false;
   SLCABAGEN1_CabConnectAddLength:=0.1;
   SLCABAGEN1_CabConnectMountingMethod:='-';
   
end.
