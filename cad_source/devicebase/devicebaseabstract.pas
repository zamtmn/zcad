unit devicebaseabstract;
{$INCLUDE def.inc}
interface
uses zcadsysvars,{$IFNDEF DELPHI}fileutil,{$ENDIF}strproc,strmy,gdbasetypes,gdbase,UUnitManager,varman,{varmandef,}sysutils,typedescriptors,URecordDescriptor,UObjectDescriptor,shared;
type
{REGISTEROBJECTTYPE DbBaseObject}
{REGISTEROBJECTTYPE ElDeviceBaseObject}
{REGISTEROBJECTTYPE CableDeviceBaseObject}
{EXPORT+}
TOborudCategory=(_misc(*'**Разное'*),
                 _elapp(*'**Электроаппараты'*),
                 _ppkop(*'**Приборы приемноконтрольные ОПС'*),
                 _detsmokesl(*'**Извещатель дымовой шлейфовый'*),
                 _kables(*'**Кабельная продукция'*));
TEdIzm=(_sht(*'**шт.'*),
        _m(*'**м'*));
PDbBaseObject=^DbBaseObject;        
DbBaseObject=object(GDBaseObject)
                       Category:TOborudCategory;(*'**Категория'*)(*oi_readonly*)
                       Group:GDBString;(*'**Группа'*)
                       Position:GDBString;(*'**Позиция'*)(*oi_readonly*)
                       NameShort:GDBString;(*'**Короткое название'*)(*oi_readonly*)
                       Name:GDBString;(*'**Название'*)(*oi_readonly*)
                       NameFull:GDBString;(*'**Полное название'*)(*oi_readonly*)
                       Description:GDBString;(*'**Описание'*)(*oi_readonly*)
                       ID:GDBString;(*'**Идентификатор'*)(*oi_readonly*)
                       Standard:GDBString;(*'**Технический документ'*)(*oi_readonly*)
                       OKP:GDBString;(*'**Код ОКП'*)(*oi_readonly*)
                       EdIzm:TEdIzm;(*'**Ед. изм.'*)(*oi_readonly*)
                       Manufacturer:GDBString;(*'**Производитель'*)(*oi_readonly*)
                       TreeCoord:GDBString;(*'**Позиция в дереве БД'*)(*oi_readonly*)
                       PartNumber:GDBString;(*'**Каталожный номер'*)(*oi_readonly*)
                       constructor initnul;
                 end;
{EXPORT-}
implementation
uses log;
constructor DbBaseObject.initnul;
begin
     Inherited initnul;
     Category:=_misc;
     EdIzm:=_sht;
     Position:='';
     NameShort:='';
     Name:='';
     NameFull:='';
     ID:='';
     Standard:='';
     OKP:='';
     Manufacturer:='';
     TreeCoord:='';
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDeviceBase.initialization');{$ENDIF}
end.
