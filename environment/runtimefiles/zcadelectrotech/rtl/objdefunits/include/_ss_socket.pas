unit _ss_socket;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objgroup;
usescopy blocktype;
var
   Device_Type:TDeviceType;(*'Тип устройства'*) 

   AmountI:Integer;(*'Количество'*)
   
   EL_Cab_AddLength:Double;(*'Добавлять к длине кабеля'*)
implementation
begin
   BTY_TreeCoord:='PLAN_SS_SSSOCKETS_UNCAT';
   Device_Type:=TDT_SensorPS;
   NMO_Template:='@@[NMO_BaseName]@@[GC_HDGroup]';
   EL_Cab_AddLength:=0.1;
   AmountI:=1;


   SerialConnection:=1;
   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_HDGroup:='0';
end.
