unit DEVICE_SS_COMPUTER;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0PC.0';
   NMO_BaseName:='PC';
   DB_link:='PC';
   BTY_TreeCoord:='PLAN_Компьютер';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
