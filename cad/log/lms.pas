interface
uses System,cables;
var
  NMO_Name:GDBString;(*'Обозначение'*)
  NMO_BaseName:GDBString;(*'Короткое Имя'*)
  NMO_Prefix:GDBString;(*'Префикс'*)
  NMO_PrefixTemplate:GDBString;(*'Шаблон префикса'*)
  NMO_Suffix:GDBString;(*'Суффикс'*)
  NMO_SuffixTemplate:GDBString;(*'Шаблон суффикса'*)
  NMO_Template:GDBString;(*'Шаблон Обозначения'*)
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
  NMO_Name:='ШР4-1';
  NMO_BaseName:='@';
  NMO_Prefix:='';
  NMO_PrefixTemplate:='';
  NMO_Suffix:='';
  NMO_SuffixTemplate:='';
  NMO_Template:='@@[NMO_Prefix]@@[GC_HeadDevice]-@@[GC_HDGroup]@@[NMO_Suffix]';
  DB_link:='Кабель ??';
  LENGTH_RoundTo:=0;
  LENGTH_Add:=4.0;
  LENGTH_Scale:=0.1;
  GC_HeadDevice:='ШР4';
  GC_HDShortName:='4';
  GC_HDGroup:=1;
  CABLE_Type:=TCT_Control;
  CABLE_Segment:=0;
  CABLE_WireCount:=0;
  CABLE_TotalCD:=3;
  AmountD:=12.0;
end.