unit cable;
interface
uses system,cables;
usescopy cablename;
usescopy objgroup;
usescopy objmaterial;
var
   LENGTH_RoundTo:Integer;(*'Округлять до'*)
   LENGTH_Add:Double;(*'Добавить к длине'*)
   LENGTH_Scale:Double;(*'Масштаб'*)
   LENGTH_KReserve:Double;(*'Коэфф. запаса'*)

   CABLE_Type:TCableType;(*'Тип'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   CABLE_Segment:Integer;(*'Сегмент'*)
   CABLE_WireCount:Integer;(*'Число жил'*)
   CABLE_TotalCD:Integer;(*'Подключено устройств'*)
   CABLE_AutoGen:Boolean;(*'Автоматически сгенерирован'*)

   AmountD:Double;(*'Длина'*)
  

implementation
begin
   LENGTH_RoundTo:=0;
   LENGTH_Add:=0.0;
   LENGTH_Scale:=0.1;
   LENGTH_KReserve:=1.2;

   CABLE_Type:=TCT_Control;
   CABLE_MountingMethod:='-';
   CABLE_Segment:=0;
   CABLE_WireCount:=0;
   CABLE_TotalCD:=0;
   CABLE_AutoGen:=false;

   AmountD:=0.0;

   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_HDGroup:=0;
end.
