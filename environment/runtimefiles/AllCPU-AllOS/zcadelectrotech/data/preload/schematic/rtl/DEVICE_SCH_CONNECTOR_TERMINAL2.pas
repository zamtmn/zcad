unit DEVICE_SCH_CONNECTION_NAME;
interface
uses system;
usescopy SCHDevName;
usescopy SCHTerminalName;
implementation
begin
   NMO_NetName:='X??';
   NMO_Prefix:='';
   NMO_Suffix:='??';
   NMO_Affix:='';
   NMO_BaseName:='X';
   NMO_NetNameTemplate:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';

   NMO_TerminalName:='??';
end.