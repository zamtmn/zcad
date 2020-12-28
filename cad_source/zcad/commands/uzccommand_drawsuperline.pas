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
{$mode delphi}//need delphi mode for disable type checking in interactive manipulators

{**Примерный модуль реализации чертежных команд (линия, круг, размеры и т.д.)
   Ничего не экспортирует, содержит некоторые команды доступные в зкаде}
unit uzccommand_drawsuperline;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE def.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

  sysutils,

  uzccominteractivemanipulators,

  uzbgeomtypes,

  uzcinterface,

  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия
  uzventsuperline,uzcenitiesvariablesextender,UUnitManager,uzbpaths,uzctranslations,

  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzbtypesbase,uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  uzestyleslayers,
  varmandef,
  Varman,UBaseTypeDescriptor,uzbstrproc,

  uzcstrconsts;       //resouce strings


type
PTDrawSuperlineParams=^TDrawSuperlineParams;
TDrawSuperlineParams=record
                         pu:PTUnit;                //рантайм юнит с параметрами суперлинии
                         LayerNamePrefix:GDBString;//префикс
                         ProcessLayer:GDBBoolean;  //выключатель
                     end;
var
   DrawSuperlineParams:TDrawSuperlineParams;

   function createSuperLine(p1,p2:GDBVertex;nameSL:string;changeLayer:boolean;LayerNamePrefix:string):TCommandResult;

implementation

function GetInteractiveLine(prompt1,prompt2:GDBString;out p1,p2:GDBVertex):GDBBoolean;
var
    pline:PGDBObjLine;
begin
    result:=false;
    if commandmanager.get3dpoint(prompt1,p1) then
    begin
         pline := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
         pline^.CoordInOCS.lBegin:=p1;
         InteractiveLineEndManipulator(pline,p1,false);
      if commandmanager.Get3DPointInteractive(prompt2,p2,@InteractiveLineEndManipulator,pline) then
      begin
           result:=true;
      end;
    end;
    drawings.GetCurrentDWG^.FreeConstructionObjects;
end;
function GetInteractiveLineFrom1to2(prompt2:GDBString;const p1:GDBVertex; out p2:GDBVertex):GDBBoolean;
var
    pline:PGDBObjLine;
begin
    pline := GDBPointer(drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,drawings.GetCurrentROOT));
    pline^.CoordInOCS.lBegin:=p1;
    InteractiveLineEndManipulator(pline,p1,false);
    result:=commandmanager.Get3DPointInteractive(prompt2,p2,@InteractiveLineEndManipulator,pline);
    drawings.GetCurrentDWG^.FreeConstructionObjects;
end;
function createSuperLine(p1,p2:GDBVertex;nameSL:string;changeLayer:boolean;LayerNamePrefix:string):TCommandResult;
var
    psuperline:PGDBObjSuperLine;
    pvarext:PTVariablesExtender;
    psu:ptunit;
    pvd:pvardesk;        //для нахождения имени суперлинии
    layername:gdbstring; //имя слоя куда будет помещена супелиния
    player:PGDBLayerProp;//указатель на слой куда будет помещена супелиния
begin
    psuperline := AllocEnt(GDBSuperLineID);
    psuperline^.init(nil,nil,0,p1,p2);
    pvarext:=psuperline^.GetExtension(typeof(TVariablesExtender));
    if pvarext<>nil then
    begin
      psu:=units.findunit(SupportPath,InterfaceTranslate,'superline');
      if psu<>nil then
        pvarext^.entityunit.copyfrom(psu);
    end;
    zcSetEntPropFromCurrentDrawingProp(psuperline);           //присваиваем умолчательные значения


    //если манипуляции со слоем включены и ранее был найден "юнит" с параметрами
    if (changeLayer)and(psu<>nil) then
    begin
      //ищем переменную 'NMO_Name'
      pvd:=psu.FindVariable('NMO_Name');
      pgdbstring(pvd^.data.Instance)^:=nameSL;
      //если найдена
      if pvd<>nil then
      begin
        //получаем желаемое имя слоя
        layername:=LayerNamePrefix+nameSL;
        //pvd.data.PTD^.GetValueAsString(pvd.data.Instance);
        //ищем описание слоя по имени

        player:=drawings.GetCurrentDWG.LayerTable.getAddres(Tria_Utf8ToAnsi(layername));
        //если найден - присваиваем, иначе ругаемя
        if player<>nil then
                           psuperline.vp.Layer:=player
                       else
                           ZCMsgCallBackInterface.TextMessage(format('Layer "%s" not found',[layername]),TMWOHistoryOut);
      end;
    end;
    //zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'DrawSuperLine');
    zcAddEntToCurrentDrawingWithUndo(psuperline);
    zcRedrawCurrentDrawing;
end;

function DrawSuperLine_com(operands:TCommandOperands):TCommandResult;
var
    psuperline:PGDBObjSuperLine;
    p1,p2:gdbvertex;
    pvarext:PTVariablesExtender;
    psu:ptunit;
    UndoMarcerIsPlazed:boolean;

procedure createline;
var
    pvd:pvardesk;        //для нахождения имени суперлинии
    layername:gdbstring; //имя слоя куда будет помещена супелиния
    player:PGDBLayerProp;//указатель на слой куда будет помещена супелиния
begin
    psuperline := AllocEnt(GDBSuperLineID);
    psuperline^.init(nil,nil,0,p1,p2);
    pvarext:=psuperline^.GetExtension(typeof(TVariablesExtender));
    if pvarext<>nil then
    begin
      psu:=units.findunit(SupportPath,InterfaceTranslate,'superline');
      if psu<>nil then
        pvarext^.entityunit.copyfrom(psu);
    end;
    zcSetEntPropFromCurrentDrawingProp(psuperline);           //присваиваем умолчательные значения
    //если манипуляции со слоем включены и ранее был найден "юнит" с параметрами
    if (DrawSuperlineParams.ProcessLayer)and(psu<>nil) then
    begin
      //ищем переменную 'NMO_Name'
      pvd:=psu.FindVariable('NMO_Name');
      //если найдена
      if pvd<>nil then
      begin
        //получаем желаемое имя слоя
        layername:=DrawSuperlineParams.LayerNamePrefix+pvd.data.PTD^.GetValueAsString(pvd.data.Instance);
        //ищем описание слоя по имени

        player:=drawings.GetCurrentDWG.LayerTable.getAddres(Tria_Utf8ToAnsi(layername));
        //если найден - присваиваем, иначе ругаемя
        if player<>nil then
                           psuperline.vp.Layer:=player
                       else
                           ZCMsgCallBackInterface.TextMessage(format('Layer "%s" not found',[layername]),TMWOHistoryOut);
      end;
    end;
    zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'DrawSuperLine');
    zcAddEntToCurrentDrawingWithUndo(psuperline);
    zcRedrawCurrentDrawing;
end;

begin
    psu:=units.findunit(SupportPath,InterfaceTranslate,'superline');
    DrawSuperlineParams.pu:=psu;
    zcShowCommandParams(pointer(SysUnit^.TypeName2PTD('TDrawSuperlineParams')),@DrawSuperlineParams);
    UndoMarcerIsPlazed:=false;
    if GetInteractiveLine(rscmSpecifyFirstPoint,rscmSpecifySecondPoint,p1,p2) then
    begin
      createline;
      p1:=p2;
      while GetInteractiveLineFrom1to2(rscmSpecifySecondPoint,p1,p2)do
      begin
       createline;
       p1:=p2;
      end;
    end;
    zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
    result:=cmd_ok;
end;
initialization
     SysUnit.RegisterType(TypeInfo(TDrawSuperlineParams));//регистрируем тип данных в зкадном RTTI
     SysUnit.SetTypeDesk(TypeInfo(TDrawSuperlineParams),['SuperLineUnit','Layer name prefix','Layer change']);//даем человеческие имена параметрам
     DrawSuperlineParams.LayerNamePrefix:='SYS_SL_';//начальное значение префикса
     DrawSuperlineParams.ProcessLayer:=true;        //начальное значение выключателя
     CreateCommandFastObjectPlugin(@DrawSuperLine_com,   'DrawSuperLine',   CADWG,0);
end.
