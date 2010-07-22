unit objmaterial;
interface
uses system;
var
   GC_HeadDevice:GDBString;
   GC_HDShortName:GDBString;
   GC_HDGroup:GDBInteger;

   SerialConnection:GDBInteger;
   GC_NumberInGroup:GDBInteger;
implementation
begin
   SerialConnection:=1;
   GC_NumberInGroup:=0;
   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_HDGroup:=0;
end.
