unit DEVICE_SS_NETWIFICEILING;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0WIFI.0';
   NMO_BaseName:='WIFI';
   DB_link:='WIFI';
   BTY_TreeCoord:='PLAN_Сетевое оборудование_Точка доступа WIFI (потолочная)';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
