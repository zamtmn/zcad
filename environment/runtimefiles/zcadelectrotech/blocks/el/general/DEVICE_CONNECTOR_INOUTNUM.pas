unit DEVICE_CONNECTOR_INOUTNUM;
interface
usescopy connector;
var
  ONELINEDIAGRAM_TYPECONNECT:string; (*'Тип соединения in / out'*)
  ONELINEDIAGRAM_NUMCONNECT:integer; (*'Номер соединения'*)
implementation
begin
  ONELINEDIAGRAM_TYPECONNECT:='out';
  ONELINEDIAGRAM_NUMCONNECT:=1;
  Cable_AddLength:=0;
end.
