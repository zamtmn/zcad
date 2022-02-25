unit DEVICE_KIP_DEVICE;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
var
  NMO_Type:String;(*'Тип'*)
  DESC_MountingSite:String;(*'Место установки'*)//полное название места установки
  DESC_MountingParts:String;(*'Закладная конструкция'*)
  DESC_MountingDrawing:String;(*'Чертеж установки'*)

  DESC_MountingPartsType:String;(*'Тип закладной конструкции'*)
  DESC_MountingPartsShortName:String;(*'Имя закладной конструкции'*)

  DESC_Function:String;(*'Функция'*)
  DESC_OutSignal:String;(*'Выходной сигнал'*)

  UNITPARAM_Environment:String;(*'Среда'*)
  UNITPARAM_ParameterMax:Double;(*'max Параметр'*)
  UNITPARAM_Parameter:Double;(*'Параметр'*)
  UNITPARAM_ParameterMin:Double;(*'min Параметр'*)
  UNITPARAM_Unit:String;(*'Еденицы измерения'*)
  
implementation
begin
   BTY_TreeCoord:='Схема_KIPIA_Устройства_Устройство общее';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Type:='-?-';
   NMO_Prefix:='';
   NMO_BaseName:='B';
   NMO_Suffix:='??';

   DB_link:='Датчик';

end.
