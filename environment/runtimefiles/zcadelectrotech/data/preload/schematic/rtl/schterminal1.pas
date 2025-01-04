unit SCHTerminal1;
interface
uses system;
usescopy SCHTerminalName;
usescopy SCHTerminalNameTemplate;
usescopy SCHTerminalNumber;
implementation
begin
   NMO_TerminalName:='1';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=1;
end.