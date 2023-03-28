unit DEVICE_SS_VCAMTC;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='BKH0';
   NMO_BaseName:='BKH';
   DB_link:='Камера в термокожухе';
   BTY_TreeCoord:='PLAN_SS_Камера в термокожухе';
   NMO_Template:='@@[NMO_BaseName]@@[GC_HDShortName].@@[GC_HDGroup]';
end.
