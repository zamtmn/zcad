unit DEVICE_CONNECTOR_TERMINAL;
interface
uses system;
var
   SYS_Border:TShapeBorder;
   SYS_Class:TShapeClass;
   SYS_Group:TShapeGroup;
   TNAME_TERMName:String;
   TNAME_Number:Integer;
implementation
begin
   SYS_Border:=SB_Empty;
   SYS_Class:=SC_Connector;
   SYS_Group:=SG_El_Sch;
end.
