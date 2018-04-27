unit connector;
interface
uses system,connectors,devices;
var
   DeviceClass:TDeviceClass;(*'Класс устройства'*)
   Connector_Type:TConnectorType;(*'Тип соединения'*)
   Border_Type:TConnectorBorderType;(*'Граница подрезки'*)

   Connector_Name:GDBString;(*'Имя соединения'*)
   Connector_Junction:GDBBoolean;(*'Возможность ответвления'*)

   Cable_AddLength:GDBDouble;(*'Добавить к длине'*)
implementation
begin
     Connector_Junction:=false;
end.
