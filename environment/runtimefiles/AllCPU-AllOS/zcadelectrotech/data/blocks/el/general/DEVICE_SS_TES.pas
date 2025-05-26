unit DEVICE_SS_TES;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='ТЭС0';
   NMO_BaseName:='ТЭС';
   DB_link:='Терминал экстренной связи';
   BTY_TreeCoord:='PLAN_SS_Терминал экстренной связи';
   NMO_Template:='@@[NMO_BaseName]@@[GC_HDShortName].@@[GC_HDGroup]';
end.
