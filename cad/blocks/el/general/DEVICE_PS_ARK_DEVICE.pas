unit DEVICE_PS_ARK_DEVICE;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy blocktype;
usescopy objgroup;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   DB_link:='Прибор ОПС';

   BTY_TreeCoord:='PLAN_OPS_Прибор ОПС';
   Device_Type:=TDT_PriborOPS;
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';
   EL_Cab_AddLength:=0.1;

   NMO_Prefix:='';
   NMO_BaseName:='ARK';
   NMO_Suffix:='??';



   SerialConnection:=1;
   GC_HDShortName:='??';
   GC_HeadDevice:='??';
   GC_HDGroup:=0;
end.