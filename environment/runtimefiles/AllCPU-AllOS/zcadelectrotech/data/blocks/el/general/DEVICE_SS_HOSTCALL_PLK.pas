unit DEVICE_SS_HOSTCALL_PLK;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0PLC0.0';
   NMO_BaseName:='PLC';
   DB_link:='PLC';
   BTY_TreeCoord:='PLAN_SS_HOSTCALL_Палатный контроллер';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
