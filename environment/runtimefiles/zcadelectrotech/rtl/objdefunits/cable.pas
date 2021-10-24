unit cable;
interface
uses system,cables;
usescopy cablename;
usescopy objgroup;
usescopy objmaterial;
var
   LENGTH_RoundTo:GDBInteger;(*'Округлять до'*)
   LENGTH_Add:GDBDouble;(*'Добавить к длине'*)
   LENGTH_Scale:GDBDouble;(*'Масштаб'*)
   LENGTH_KReserve:GDBDouble;(*'Коэфф. запаса'*)

   CABLE_Type:TCableType;(*'Тип'*)
   Cable_Mounting_Method:TDCableMountingMethod;(*'Метод монтажа'*)
   CABLE_Segment:GDBInteger;(*'Сегмент'*)
   CABLE_WireCount:GDBInteger;(*'Число жил'*)
   CABLE_TotalCD:GDBInteger;(*'Подключено устройств'*)
   CABLE_AutoGen:GDBBoolean;(*'Автоматически сгенерирован'*)

   AmountD:GDBDouble;(*'Длина'*)
   
   Cable_Mounting_Method:TDCableMountingMethod;(*'Метод монтажа'*)

implementation
begin
   CABLE_Type:=TCT_Control;
   Amount:=0.0;
   LENGTH_RoundTo:=0;
   LENGTH_Add:=0.0;
   LENGTH_KReserve:=1.2;
   Segment:=0;
   LENGTH_Scale:=0.1;
   CABLE_Material:='не задан ??;
   CABLE_WireCount:=0;
   Cable_Mounting_Method:='-';

   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_HDGroup:=0;
   CABLE_TotalCD:=0;
   CABLE_AutoGen:=false;
end.
