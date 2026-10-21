unit CMTerminal4;
interface
uses system;
usescopy CMTerminalName;
usescopy CMTerminalNameTemplate;
usescopy CMTerminalNumber;
implementation
begin
   NMO_TerminalName:='4';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=4;
end.