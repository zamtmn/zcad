unit SCHTerminal5;
interface
uses system;
usescopy SCHTerminalName;
usescopy SCHTerminalNameTemplate;
usescopy SCHTerminalNumber;
implementation
begin
   NMO_TerminalName:='5';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=5;
end.