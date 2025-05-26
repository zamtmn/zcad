unit DEVICE_SCH_PID_SOURCE;
interface
uses system,devices;
usescopy objnamebase;
usescopy uentid;
usescopy objmaterial;
var
  DESC_MountingSite:String;(*'Место установки'*)
  DESC_MountingPartsShortName:String;(*'Имя закладной конструкции'*)
  DESC_MountingParts:String;(*'Закладная конструкция'*)
  DESC_MountingPartsType:String;(*'Тип закладной конструкции'*)
  DESC_MountingDrawing:String;(*'Чертеж установки'*)
  
  UNITPARAM_Environment:String;(*'Среда'*)
  UNITPARAM_ParameterMax:Double;(*'max Параметр'*)
  UNITPARAM_Parameter:Double;(*'Параметр'*)
  UNITPARAM_ParameterMin:Double;(*'min Параметр'*)
  UNITPARAM_Unit:String;(*'Ед. изм.'*)

  
  INSTRUMENT_Function:String;(*'Функция'*)
  INSTRUMENT_PIDLoop:String;(*'Контур'*)
  INSTRUMENT_PIDLine:String;(*'Линия'*)
  INSTRUMENT_Type:TCalculatedString;(*'Тип прибора'*)
  INSTRUMENT_ScaleMax:Double;(*'max Шкала прибора'*)
  INSTRUMENT_ScaleMin:Double;(*'min Шкала прибора'*)
  INSTRUMENT_Unit:String;(*'Ед. изм.'*)
  INSTRUMENT_OutSignal:String;(*'Выходной сигнал'*)

  
implementation
begin
  NMO_BaseName:='??';
  NMO_Template:='@@[NMO_BaseName]-@@[INSTRUMENT_PIDLoop]';

  ENTID_Representation:='GraphSymbol~onScheme';
  ENTID_Function:='Electrotechnics~Measuring_equipment';

  DB_link:='UnDevice';

  DESC_MountingSite:='??';
  DESC_MountingParts:='??';
  DESC_MountingDrawing:='??';
  DESC_MountingPartsType:String:='??';
  DESC_MountingPartsShortName:='??';

  UNITPARAM_ParameterMax:=0.0;
  UNITPARAM_Parameter:=0.0;
  UNITPARAM_ParameterMin:=0.0;
  UNITPARAM_Unit:='';

  INSTRUMENT_Function:='??';
  INSTRUMENT_PIDLoop:='xxxx';
  INSTRUMENT_PIDLine:='x.x';
  INSTRUMENT_Type.value:='??';
  INSTRUMENT_Type.format:='@@[NMO_BaseName]';
  INSTRUMENT_ScaleMax:=0.0;
  INSTRUMENT_ScaleMin:=0.0;
  INSTRUMENT_Unit:='';
  INSTRUMENT_OutSignal:='??';
end.