unit DEVICE_SS_NAMEDEV;
interface
usescopy firesensor;
var
 VNameDev:String;(*'Визуальное имя'*)
implementation
begin
   NMO_Name:='0DEV.0';
   NMO_BaseName:='DEV';
   DB_link:='DEV';
   BTY_TreeCoord:='PLAN_Произвольное имя устройства';
   VNameDev:='IDev';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
