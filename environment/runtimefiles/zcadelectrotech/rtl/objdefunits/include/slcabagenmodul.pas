unit slcabagenmodul;
interface
uses system,devices;
var

SLCABAGEN_HeadDeviceName:GDBString;(*'Головное устройство..Множественность через ~ '*)

SLCABAGEN_CableRoutingNodes:GDBString;(*'Промежуточные узлы прокладки кабеля.Множественность через ~ '*)

SLCABAGEN_NGHeadDevice:GDBString;(*'Номер группы в головном устройстве.Множественность через ~ '*)

SLCABAGEN_SLTypeagen:GDBString;(*'Имя суперлинии по которой будет вестись прокладка.Множественность через ~ '*)

SLCABAGEN_TypeCableRouting:TTypeCableRouting;(*'Прокладка кабеля одиночная/групповая'*)

SLCABAGEN_DevConnectMethod:TDevConnectMethod;(*'Соединение устройств выполняется'*)

implementation
begin

   SLCABAGEN_HeadDeviceName:='???';
   SLCABAGEN_CableRoutingNodes:='-';
   SLCABAGEN_NGHeadDevice:='???';
   SLCABAGEN_SLTypeagen:='???';
   SLCABAGEN_SLTest:='???';
   SLCABAGEN_TypeCableRouting:=TDT_GroupRouting;
   SLCABAGEN_DevConnectMethod:=TDT_CableConnectParallel;
   
end.
