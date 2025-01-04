unit SCHTerminal4;
interface
uses system;
usescopy SCHTerminalName;
usescopy SCHTerminalNameTemplate;
usescopy SCHTerminalNumber;
implementation
begin
   NMO_TerminalName:='4';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=4;
end.