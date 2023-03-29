unit DEVICE_SS_VCAM;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='BK0';
   NMO_BaseName:='BK';
   DB_link:='Камера внутренняя';
   BTY_TreeCoord:='PLAN_SS_Камера внутренняя';
   NMO_Template:='@@[NMO_BaseName]@@[GC_HDShortName].@@[GC_HDGroup]';
end.
