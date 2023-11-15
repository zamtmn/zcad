unit DEVICE_SS_METER;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0FE.0';
   NMO_BaseName:='FE';
   DB_link:='FE';
   BTY_TreeCoord:='PLAN_АСКУЭ_Счетчик';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
