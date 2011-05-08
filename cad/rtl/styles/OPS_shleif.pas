unit OPS_shleif;
interface
uses System,cables;
var
  SUMMARY_StyleName:GDBString;(*'Стиль'*)
  NC_StyleDef:GDBBoolean;(*'Метка определения стиля'*)
  NMO_Name:GDBString;(*'Обозначение'*)
  NMO_BaseName:GDBString;(*'Короткое Имя'*)
  NMO_Prefix:GDBString;(*'Префикс'*)
  NMO_PrefixTemplate:GDBString;(*'Шаблон префикса'*)
  NMO_Suffix:GDBString;(*'Суффикс'*)
  NMO_SuffixTemplate:GDBString;(*'Шаблон суффикса'*)
  NMO_Template:GDBString;(*'Шаблон Обозначения'*)
  GC_HeadDevice:GDBString;(*'Головноге устройство'*)
  GC_HeadDeviceTemplate:GDBString;(*'Шаблон головного устройства'*)
  GC_HDShortName:GDBString;(*'Короткое имя головного устройства'*)
  GC_HDShortNameTemplate:GDBString;(*'Шаблон короткого имени головного устройства'*)
  GC_HDGroup:GDBString;(*'Группа в головном устройстве'*)
  GC_HDGroupTemplate:GDBString;(*'Шаблон группы'*)
  SerialConnection:GDBInteger;
  GC_NumberInGroup:GDBInteger;(*'Номер устройства в группе'*)
  GC_Metric:GDBString;
  DB_link:GDBString;(*'Материал'*)
  LENGTH_RoundTo:GDBInteger;(*'Округлять до'*)
  LENGTH_Add:GDBDouble;(*'Добавить к длине'*)
  LENGTH_Scale:GDBDouble;(*'Масштаб'*)
  CABLE_Type:TCableType;(*'Тип'*)
  CABLE_Segment:GDBInteger;(*'Сегмент'*)
  CABLE_WireCount:GDBInteger;(*'Число жил'*)
  CABLE_TotalCD:GDBInteger;(*'Подключено устройств'*)
  AmountD:GDBDouble;(*'Длина'*)
implementation
begin
  SUMMARY_StyleName:='ОПС_Адресный шлейф';
  NC_StyleDef:=true;
  NMO_Name:='';
  NMO_BaseName:='Ш';
  NMO_Prefix:='';
  NMO_PrefixTemplate:='@@[GC_NumberInGroup]';
  NMO_Suffix:='1';
  NMO_SuffixTemplate:='';
  NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';
  GC_HeadDevice:='5';
  GC_HeadDeviceTemplate:='@@[NMO_Prefix]';
  GC_HDShortName:='5';
  GC_HDShortNameTemplate:='@@[NMO_Prefix]';
  GC_HDGroup:='1';
  GC_HDGroupTemplate:='';
  SerialConnection:=1;
  GC_NumberInGroup:=1;
  GC_Metric:='шлейф';
  DB_link:='';
  LENGTH_RoundTo:=0;
  LENGTH_Add:=4.0;
  LENGTH_Scale:=0.1;
  CABLE_Type:=TCT_ShleifOPS;
  CABLE_Segment:=0;
  CABLE_WireCount:=0;
  CABLE_TotalCD:=9;
  AmountD:=0.0;
end.