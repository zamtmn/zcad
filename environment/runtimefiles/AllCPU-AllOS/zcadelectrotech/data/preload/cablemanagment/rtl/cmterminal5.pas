unit CMTerminal5;
interface
uses system;
usescopy CMTerminalName;
usescopy CMTerminalNameTemplate;
usescopy CMTerminalNumber;
implementation
begin
   NMO_TerminalName:='5';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=5;
end.