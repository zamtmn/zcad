unit SCHTerminal3;
interface
uses system;
usescopy SCHTerminalName;
usescopy SCHTerminalNameTemplate;
usescopy SCHTerminalNumber;
implementation
begin
   NMO_TerminalName:='3';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=3;
end.