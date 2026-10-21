unit CMTerminal3;
interface
uses system;
usescopy CMTerminalName;
usescopy CMTerminalNameTemplate;
usescopy CMTerminalNumber;
implementation
begin
   NMO_TerminalName:='3';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=3;
end.