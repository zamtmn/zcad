unit DEVICE_PS_SHUSONAR;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='SONAR.1';
   NMO_BaseName:='SONAR';
   DB_link:='SONAR';
   BTY_TreeCoord:='PLAN_SONAR_Шкаф речевого оповещения';
   NMO_Template:='@@[NMO_BaseName].@@[NMO_Suffix]';
end.
