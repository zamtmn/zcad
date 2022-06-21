unit uzcdevicebaseabstract;
{$INCLUDE zengineconfig.inc}
interface
uses uzcsysvars,{$IFNDEF DELPHI}fileutil,{$ENDIF}uzbstrproc,strmy,
     uzbtypes,UUnitManager,varman,sysutils,typedescriptors,uzclog;
type
{EXPORT+}
TOborudCategory=(_misc(*'**Разное'*),
                 _elapp(*'**Электроаппараты'*),
                 _ppkop(*'**Приборы приемноконтрольные ОПС'*),
                 _detsmokesl(*'**Извещатель дымовой шлейфовый'*),
                 _kables(*'**Кабельная продукция'*));
TEdIzm=(_sht(*'**шт.'*),
        _m(*'**м'*));
PDbBaseObject=^DbBaseObject;
{REGISTEROBJECTTYPE DbBaseObject}
DbBaseObject= object(GDBaseObject)
                       Category:TOborudCategory;(*'**Категория'*)(*oi_readonly*)
                       Group:String;(*'**Группа'*)
                       Position:String;(*'**Позиция'*)(*oi_readonly*)
                       NameShort:String;(*'**Короткое название'*)(*oi_readonly*)
                       Name:String;(*'**Название'*)(*oi_readonly*)
                       NameFull:String;(*'**Полное название'*)(*oi_readonly*)
                       Description:String;(*'**Описание'*)(*oi_readonly*)
                       ID:String;(*'**Идентификатор'*)(*oi_readonly*)
                       Standard:String;(*'**Технический документ'*)(*oi_readonly*)
                       OKP:String;(*'**Код ОКП'*)(*oi_readonly*)
                       EdIzm:TEdIzm;(*'**Ед. изм.'*)(*oi_readonly*)
                       Manufacturer:String;(*'**Производитель'*)(*oi_readonly*)
                       TreeCoord:String;(*'**Позиция в дереве БД'*)(*oi_readonly*)
                       PartNumber:String;(*'**Каталожный номер'*)(*oi_readonly*)
                       constructor initnul;
                 end;
{EXPORT-}
implementation
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
end.
