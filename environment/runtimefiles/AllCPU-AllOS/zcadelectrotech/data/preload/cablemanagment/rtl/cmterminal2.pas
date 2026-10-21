unit CMTerminal2;
interface
uses system;
usescopy CMTerminalName;
usescopy CMTerminalNameTemplate;
usescopy CMTerminalNumber;
implementation
begin
   NMO_TerminalName:='2';
   NMO_TerminalNameTemplate:='@@[TERMINAL_Number]';
   TERMINAL_Number:=2;
end.