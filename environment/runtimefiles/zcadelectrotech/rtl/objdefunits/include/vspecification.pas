unit vspecification;
interface
uses system;

var
   VSPECIFICATION_Position:String;(*'Позиция'*)
   VSPECIFICATION_Name:String;(*'Наименование'*)
   VSPECIFICATION_Brand:String;(*'Марка'*)
   VSPECIFICATION_Article:String;(*'Код изделия'*)
   VSPECIFICATION_Factoryname:String;(*'Завод-изготовитель'*)
   VSPECIFICATION_Unit:String;(*'Единица измерения'*)
   VSPECIFICATION_Сount:Double;(*'Количество'*)
   VSPECIFICATION_Weight:String;(*'Масса_Текст'*)
   VSPECIFICATION_Note:String;(*'Примечание'*)
   VSPECIFICATION_Grouping:String;(*'Группирование'*)
   VSPECIFICATION_Belong:String;(*'Принадлежит'*)

implementation
begin
   VSPECIFICATION_Position:='??';
   VSPECIFICATION_Name:='';
   VSPECIFICATION_Brand:='';
   VSPECIFICATION_Article:='';
   VSPECIFICATION_Factoryname:='';
   VSPECIFICATION_Unit:='';
   VSPECIFICATION_Сount:=1;
   VSPECIFICATION_Weight:='';
   VSPECIFICATION_Note:='';
   VSPECIFICATION_Grouping:='??';
   VSPECIFICATION_Belong:='';
end.
