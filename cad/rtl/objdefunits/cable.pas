unit cable;
interface
uses system,cables;
usescopy cablename;
var
   DB_link:GDBString;(*'Материал'*)

   LENGTH_RoundTo:GDBInteger;(*'Округлять до'*)
   LENGTH_Add:GDBDouble;(*'Добавить к длине'*)
   LENGTH_Scale:GDBDouble;(*'Масштаб'*)

   GC_HeadDevice:GDBString;(*'Головное устройство'*)
   GC_HDShortName:GDBString;(*'Короткое имя головного устройства'*)
   GC_HDGroup:GDBInteger;(*'Группа в головном устройстве'*)

   CABLE_Type:TCableType;(*'Тип'*)
   CABLE_Segment:GDBInteger;(*'Сегмент'*)
   CABLE_WireCount:GDBInteger;(*'Число жил'*)
   CABLE_TotalCD:GDBInteger;(*'Подключено устройств'*)

   AmountD:GDBDouble;(*'Длина'*)

implementation
begin
   CABLE_Type:=TCT_Control;
   Amount:=0.0;
   LENGTH_RoundTo:=0;
   LENGTH_Add:=4.0;
   Segment:=0;
   LENGTH_Scale:=0.1;
   NMO_Name:='unnamed';
   CABLE_Material:='не задан 7х0.75';
   CABLE_WireCount:=0;

   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_HDGroup:=0;
   CABLE_TotalCD:=0;
end.
