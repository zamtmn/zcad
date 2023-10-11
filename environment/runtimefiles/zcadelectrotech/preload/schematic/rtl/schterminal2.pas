unit SCHTerminal2;
interface
uses system;
usescopy SCHTerminalName;
usescopy SCHTerminalNameTemplate;
usescopy SCHTerminalNumber;
implementation
begin
   NMO_TerminalName:='2';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=2;
end.