unit DEVICE_SS_CABLERESERVE;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0C.0';
   NMO_BaseName:='C';
   DB_link:='C';
   BTY_TreeCoord:='PLAN_Выпуск кабеля резерв';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
