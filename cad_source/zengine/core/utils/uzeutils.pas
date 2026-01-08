{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}

{**Модуль утилит движка}
unit uzeutils;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzepalette,uzestyleslinetypes,uzestyleslayers,uzedrawingsimple,
  gzctnrVectorTypes,uzeTypes,uzeentity,uzegeometry,
  uzeentgenericsubentry,gzctnrSTL,uzbLogIntf;
type
  TEntPropSetterFromDrawing=procedure(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);
  TEntPropSetters=TMyVector<TEntPropSetterFromDrawing>;
  {**Структура описатель выбраных примитивов
    @member(PFirstSelectedEnt Указатель на первый выбраный примитив в чертеже)
    @member(SelectedEntsCount Общее количество выбраных примитивов в чертеже)}
  TSelEntsDesk=record
                 PFirstSelectedEnt:PGDBObjEntity;
                 SelectedEntsCount:Integer;
               end;
  procedure zeRegisterEntPropSetter(proc:TEntPropSetterFromDrawing);

  {**Получение "описателя" выбраных примитивов в "корне"
    @param(Root "Корневой" примитив владелец)
    @return(Указатель на первый выбранный примитив и общее количество выбраных примитивов)}
  function zeGetSelEntsDeskInRoot(var Root:GDBObjGenericSubEntry):TSelEntsDesk;

  {**Выставление свойств примитива в соответствии с настройками чертежа.
     процедура выполняет все зарегистрированные TEntPropSetterFromDrawing с
     помощью zeRegisterEntPropSetter для примитива. Поумолчанию зарегистрирована
     только zeSetEntPropFromDrawingProp
    @param(PEnt Указатель на примитив)
    @param(Drawing Чертеж откуда будут взяты настройки)}
  procedure zeSetEntPropFromDrawingProp(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);

  {**Выставление базовых свойств примитива в соответствии с настройками чертежа.
     Слой, Тип линии, Вес линии, Цвет, Масштаб типа линии
    @param(PEnt Указатель на примитив)
    @param(Drawing Чертеж откуда будут взяты настройки)}
  procedure zeSetBaseEntPropFromDrawingProp(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);

  {**Выставление общих свойств примитива
     Слой, Тип линии, Вес линии, Цвет
     надо сюда добавить масштаб типа линии
    @param(PEnt Указатель на примитив)
    @param(PLayer Указатель на слой)
    @param(PLT Указатель на тип линий)
    @param(LW Вес линий)
    @param(Color Цвет)}
  procedure zeSetEntityProp(const PEnt:PGDBObjEntity;const PLayer:PGDBLayerProp;const PLT:PGDBLtypeProp;const LW:TGDBLineWeight;const Color:TGDBPaletteColor);

  procedure zeAddEntToRoot(const PEnt: PGDBObjEntity; var Root:GDBObjGenericSubEntry);

  {**Процедура счетчик, если слой примитива PInstance равен PCounted, то Counter инкрементируется.
     используется для подсчета количества ссылок на слой в примитивах}
  procedure LayerCounter(const PInstance,PCounted:Pointer;var Counter:Integer);

  {**Процедура счетчик, если тип линии примитива PInstance равен PCounted, то Counter инкрементируется.
     используется для подсчета количества ссылок на тип линии в примитивах}
  procedure LTypeCounter(const PInstance,PCounted:Pointer;var Counter:Integer);
implementation
var
   EntPropSetters:TEntPropSetters;
procedure zeAddEntToRoot(const PEnt: PGDBObjEntity; var Root:GDBObjGenericSubEntry);
begin
  Root.AddMi(@PEnt);
end;
function zeGetSelEntsDeskInRoot(var Root:GDBObjGenericSubEntry):TSelEntsDesk;
var
    pv:pGDBObjEntity;
    ir:itrec;
begin
  result.PFirstSelectedEnt:=nil;
  result.SelectedEntsCount:=0;

  pv:=Root.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
    begin
         if result.SelectedEntsCount=0 then
                                result.PFirstSelectedEnt:=pv;
         inc(result.SelectedEntsCount);
    end;
  pv:=Root.ObjArray.iterate(ir);
  until pv=nil;
end;
procedure zeRegisterEntPropSetter(proc:TEntPropSetterFromDrawing);
begin
 EntPropSetters.PushBack(proc);
end;
procedure zeSetBaseEntPropFromDrawingProp(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);
begin
     PEnt^.vp.Layer:=Drawing.currentLayer;
     PEnt^.vp.LineType:=Drawing.CurrentLType;
     PEnt^.vp.LineWeight:=Drawing.CurrentLineW;
     PEnt^.vp.color:=Drawing.CColor;
     PEnt^.vp.LineTypeScale:=Drawing.CLTScale;
end;
procedure zeSetEntPropFromDrawingProp(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);
var
 i:integer;
begin
     for i:=0 to EntPropSetters.Size-1 do
       EntPropSetters[i](PEnt,Drawing);
end;
procedure zeSetEntityProp(const PEnt:PGDBObjEntity;const PLayer:PGDBLayerProp;const PLT:PGDBLtypeProp;const LW:TGDBLineWeight;const Color:TGDBPaletteColor);
begin
     PEnt^.vp.Layer:=PLayer;
     PEnt^.vp.LineType:=PLT;
     PEnt^.vp.LineWeight:=LW;
     PEnt^.vp.color:=Color;
end;
procedure LayerCounter(const PInstance,PCounted:Pointer;var Counter:Integer);
begin
     if PCounted=PGDBObjEntity(PInstance)^.vp.Layer then
                                  inc(Counter);
end;
procedure LTypeCounter(const PInstance,PCounted:Pointer;var Counter:Integer);
begin
     if PCounted=PGDBObjEntity(PInstance)^.vp.LineType then
                                  inc(Counter);
end;
initialization
begin
  EntPropSetters:=TEntPropSetters.Create;
  zeRegisterEntPropSetter(zeSetBaseEntPropFromDrawingProp);
end;
finalization
  zDebugln('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  EntPropSetters.Destroy;
end.
