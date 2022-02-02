unit DEVICE_PS_ARK_DEVICE;
interface
usescopy firesensor;
implementation
begin
   NMO_BaseName:='ARK';
   NMO_Prefix:='';
   NMO_Suffix:='??';
   NMO_Template:='@@[NMO_BaseName]@@[NMO_Prefix]@@[NMO_Suffix]';
   DB_link:='Прибор ОПС';
   BTY_TreeCoord:='PLAN_OPS_Прибор ОПС';
   Device_Type:=TDT_PriborOPS;
   EL_Cab_AddLength:=1.0;
   SerialConnection:=0;
   GC_HDShortName:='??';
   GC_HeadDevice:='??';
   GC_HDGroup:=0;
end.
