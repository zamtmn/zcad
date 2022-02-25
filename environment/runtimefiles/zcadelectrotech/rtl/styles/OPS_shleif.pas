unit OPS_shleif;
interface
uses System,cables;
var
  SUMMARY_StyleName:String;(*'Стиль'*)
  NC_StyleDef:Boolean;(*'Метка определения стиля'*)
  NMO_Name:String;(*'Обозначение'*)
  NMO_BaseName:String;(*'Короткое Имя'*)
  NMO_Prefix:String;(*'Префикс'*)
  NMO_PrefixTemplate:String;(*'Шаблон префикса'*)
  NMO_Suffix:String;(*'Суффикс'*)
  NMO_SuffixTemplate:String;(*'Шаблон суффикса'*)
  NMO_Template:String;(*'Шаблон Обозначения'*)
  GC_HeadDevice:String;(*'Головноге устройство'*)
  GC_HeadDeviceTemplate:String;(*'Шаблон головного устройства'*)
  GC_HDShortName:String;(*'Короткое имя головного устройства'*)
  GC_HDShortNameTemplate:String;(*'Шаблон короткого имени головного устройства'*)
  GC_HDGroup:String;(*'Группа в головном устройстве'*)
  GC_HDGroupTemplate:String;(*'Шаблон группы'*)
  SerialConnection:Integer;
  GC_NumberInGroup:Integer;(*'Номер устройства в группе'*)
  GC_Metric:String;
  DB_link:String;(*'Материал'*)
  LENGTH_RoundTo:Integer;(*'Округлять до'*)
  LENGTH_Add:Double;(*'Добавить к длине'*)
  LENGTH_Scale:Double;(*'Масштаб'*)
  CABLE_Type:TCableType;(*'Тип'*)
  CABLE_Segment:Integer;(*'Сегмент'*)
  CABLE_WireCount:Integer;(*'Число жил'*)
  CABLE_TotalCD:Integer;(*'Подключено устройств'*)
  AmountD:Double;(*'Длина'*)
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