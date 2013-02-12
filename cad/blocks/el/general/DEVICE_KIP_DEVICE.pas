unit DEVICE_OS_KNOPKA;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
var
  NMO_Type:GDBString;(*'Тип'*)
  DESC_MountingSite:GDBString;(*'Место установки'*)
  DESC_MountingParts:GDBString;(*'Чертеж установки'*)
  DESC_MountingDrawing:GDBString;(*'Сокр. чертеж установки'*)
  DESC_Function:GDBString;(*'Функция'*)

  UNITPARAM_Environment:GDBString;(*'Среда'*)
  UNITPARAM_ParameterMax:GDBDouble;(*'max Параметр'*)
  UNITPARAM_Parameter:GDBDouble;(*'Параметр'*)
  UNITPARAM_ParameterMin:GDBDouble;(*'min Параметр'*)
  UNITPARAM_Unit:GDBString;(*'Еденицы измерения'*)
  
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
