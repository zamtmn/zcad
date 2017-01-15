unit DEVICE_PS_ARK_DEVICE;
interface
uses system,devices;
usescopy objname;
usescopy blocktype;
usescopy slcabagenmodul;
var
   Device_Type:TDeviceType;(*'Тип устройства'*) 

   DB_link:GDBString;(*'Материал'*)
   
   GC_HeadDevice:GDBString;
   GC_HDShortName:GDBString;
   GC_HDGroup:GDBInteger;
   GC_Metric:GDBString;
   GC_NumberInGroup:GDBInteger;

   SerialConnection:GDBInteger;


   EL_Cab_AddLength:GDBDouble;(*'Добавлять к длине кабеля'*)
implementation
begin
   DB_link:='Прибор ОПС';

   BTY_TreeCoord:='PLAN_OPS_Прибор ОПС';
   Device_Type:=TDT_PriborOPS;
   NMO_Template:='@@[NMO_BaseName]@@[NMO_Prefix]@@[NMO_Suffix]';
   EL_Cab_AddLength:=1.0;

   NMO_Prefix:='';
   NMO_BaseName:='ARK';
   NMO_Suffix:='??';



   SerialConnection:=0;
   GC_HDShortName:='??';
   GC_HeadDevice:='??';
   GC_HDGroup:=0;
end.
