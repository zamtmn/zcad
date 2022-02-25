unit connector;
interface
uses system,connectors,devices;
var
   DeviceClass:TDeviceClass;(*'Класс устройства'*)
   Connector_Type:TConnectorType;(*'Тип соединения'*)
   Border_Type:TConnectorBorderType;(*'Граница подрезки'*)

   Connector_Name:String;(*'Имя соединения'*)
   Connector_Junction:Boolean;(*'Возможность ответвления'*)

   Cable_AddLength:Double;(*'Добавить к длине'*)
implementation
begin
     Connector_Junction:=false;
end.
