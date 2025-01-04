unit DEVICE_SS_NETWORKSWITCH;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0SWITCH.0';
   NMO_BaseName:='SWITCH';
   DB_link:='SWITCH';
   BTY_TreeCoord:='PLAN_Сетевое оборудование_Сетевой коммутатор';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
