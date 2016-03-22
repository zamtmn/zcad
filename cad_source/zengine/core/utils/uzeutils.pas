{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit uzeutils;
{$INCLUDE def.inc}
interface
uses
gdbase,GDBasetypes,uzeentity,geometry,uzeentgenericsubentry;
type
  {**Структура описатель выбраных примитивов
    @member(PFirstSelectedEnt Указатель на первый выбраный примитив в чертеже)
    @member(SelectedEntsCount Общее количество выбраных примитивов в чертеже)}
  TSelEntsDesk=record
                 PFirstSelectedEnt:PGDBObjEntity;
                 SelectedEntsCount:GDBInteger;
               end;

  {**Получение "описателя" выбраных примитивов в "корне"
    @param(Root "Корневой" примитив владелец)
    @return(Указатель на первый выбранный примитив и общее количество выбраных примитивов)}
  function zeGetSelEntsDeskInRoot(var Root:GDBObjGenericSubEntry):TSelEntsDesk;

  {**Процедура счетчик, если слой примитива PInstance равен PCounted, то Counter инкрементируется
     используется для подсчета количества ссылок на слой в примитивах}
  procedure LayerCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);

  {**Процедура счетчик, если тип линии примитива PInstance равен PCounted, то Counter инкрементируется
     используется для подсчета количества ссылок на тип линии в примитивах}
  procedure LTypeCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);

implementation
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
procedure LayerCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if PCounted=PGDBObjEntity(PInstance)^.vp.Layer then
                                  inc(Counter);
end;
procedure LTypeCounter(const PInstance,PCounted:GDBPointer;var Counter:GDBInteger);
begin
     if PCounted=PGDBObjEntity(PInstance)^.vp.LineType then
                                  inc(Counter);
end;
begin
end.
