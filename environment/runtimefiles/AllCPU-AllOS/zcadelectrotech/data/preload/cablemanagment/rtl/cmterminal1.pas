unit CMTerminal1;
interface
uses system;
usescopy CMTerminalName;
usescopy CMTerminalNameTemplate;
usescopy CMTerminalNumber;
implementation
begin
   NMO_TerminalName:='1';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=1;
end.