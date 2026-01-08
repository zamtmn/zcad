unit uzcdevicebaseabstract;
{$INCLUDE zengineconfig.inc}
interface
uses uzcsysvars,{$IFNDEF DELPHI}fileutil,{$ENDIF}uzbstrproc,//strmy,
     uzeTypes,UUnitManager,varman,sysutils,typedescriptors,uzclog;
type
TOborudCategory=(_misc(*'**Разное'*),
                 _elapp(*'**Электроаппараты'*),
                 _ppkop(*'**Приборы приемноконтрольные ОПС'*),
                 _detsmokesl(*'**Извещатель дымовой шлейфовый'*),
                 _kables(*'**Кабельная продукция'*));
TEdIzm=(_sht(*'**шт.'*),
        _m(*'**м'*));

DbBaseObject= object(GDBaseObject)
                       Category:TOborudCategory;(*'**Категория'*)
                       Group:String;(*'**Группа'*)
                       Position:String;(*'**Позиция'*)
                       NameShort:String;(*'**Короткое название'*)
                       Name:String;(*'**Название'*)
                       NameFull:String;(*'**Полное название'*)
                       Description:String;(*'**Описание'*)
                       ID:String;(*'**Идентификатор'*)
                       Standard:String;(*'**Технический документ'*)
                       OKP:String;(*'**Код ОКП'*)
                       EdIzm:TEdIzm;(*'**Ед. изм.'*)
                       Manufacturer:String;(*'**Производитель'*)
                       TreeCoord:String;(*'**Позиция в дереве БД'*)
                       PartNumber:String;(*'**Каталожный номер'*)
                       constructor initnul;
                 end;
PDbBaseObject=^DbBaseObject;



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
