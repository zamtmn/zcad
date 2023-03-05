unit DEVICE_PS_VENT;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0B0.0';
   NMO_BaseName:='B';
   DB_link:='B';
   BTY_TreeCoord:='PLAN_OPS_Вентилятор';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';
end.
