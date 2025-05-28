unit DEVICE_PS_MICSONAR;
interface
usescopy firesensor;
implementation
begin
   NMO_Name:='0MIC.0';
   NMO_BaseName:='MIC';
   DB_link:='MIC';
   BTY_TreeCoord:='PLAN_SONAR_Микрофон';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName].@@[NMO_Suffix]';
end.
