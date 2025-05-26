unit DEVICE_SS_CALLTABLO;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0CT.0';
   NMO_BaseName:='CT';
   DB_link:='CT';
   BTY_TreeCoord:='PLAN_Табло вызова';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
