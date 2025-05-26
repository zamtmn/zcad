unit DEVICE_SS_CALLPANELIN;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0CPI.0';
   NMO_BaseName:='CPI';
   DB_link:='CPI';
   BTY_TreeCoord:='PLAN_Блок вызова встроенный';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
