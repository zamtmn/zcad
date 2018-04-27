unit DEVICE_SPDS_AXIS;
interface
uses system;
usescopy objname;
var
  MISC_Vertical:TGDB3StateBool;
implementation
begin
   NMO_Prefix:='';
   NMO_BaseName:='1';
   NMO_Suffix:='';
   MISC_Vertical:=T3SB_Default;
end.