unit DEVICE_SS_CALLPANEL;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0CP.0';
   NMO_BaseName:='CP';
   DB_link:='CP';
   BTY_TreeCoord:='PLAN_Блок вызова наружный';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
