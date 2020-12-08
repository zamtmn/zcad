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
unit uzccomexample;

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

  sysutils, math,

  uzccominteractivemanipulators,

  URecordDescriptor,TypeDescriptors,
  uzbgeomtypes,

  uzcinterface,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия
  uzventsuperline,UUnitManager,uzbpaths,uzctranslations,

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeenttext,

  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  uzegeometry,

  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzbtypesbase,uzbtypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  uzestyleslayers,
  varmandef,
  Varman,UBaseTypeDescriptor,uzbstrproc,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzcstrconsts,       //resouce strings

  gzctnrvectortypes,uzcenitiesvariablesextender,

  uzclog;             //log system
                      //система логирования
resourcestring
  rscmSelectEntityWithMainFunction='Select entity with main function';
  rscmSelectLinkedEntity='Select linked entity';

implementation
//** блаблабла
function isRDIMHorisontal(p1,p2,p3,nevp3:gdbvertex):integer;
var
   minx,maxx,miny,maxy:GDBDouble;
begin
  minx:=min(p1.x,p2.x);
  maxx:=max(p1.x,p2.x);
  miny:=min(p1.y,p2.y);
  maxy:=max(p1.y,p2.y);
  if (minx<=p3.x)and (p3.x<=maxx) and (miny<=p3.y)and (p3.y<=maxy) then
    begin
     if (minx<=nevp3.x)and(nevp3.x<=maxx)and(miny<=nevp3.y)and(nevp3.y<=maxy)
     then
         result:=0
     else
         begin
              if (minx>nevp3.x)or(nevp3.x>maxx)then
                  result:=2
                else
                  result:=1;

         end;
    end
    else
     result:=0;
end;

{ "command" function, they must all have a description of the
    function name(operands:TCommandOperands):TCommandResult;
  after the registration, it will be available from the interface }
{ "командная" функция, все они должны иметь описание
    function name(operands:TCommandOperands):TCommandResult;
  после соответствующей регистрации она будет доступна из интерфейса программ }

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

function InsertDevice_com(operands:TCommandOperands):TCommandResult;
var
    pdev:PGDBObjDevice;
    p1:gdbvertex;
    rc:TDrawContext;
begin
    if commandmanager.get3dpoint('Specify insert point:',p1) then
    begin
      //проверяем наличие блока PS_DAT_SMOKE и устройства DEVICE_PS_DAT_SMOKE в чертеже и копируем при необходимости
      //этот момент кривой - AddBlockFromDBIfNeed должна быть функцией чтоб было понятно - есть блок или нет, хотя это можно проверить отдельно
      drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
      //создаем примитив
      pdev:=AllocEnt(GDBDeviceID);
      pdev^.init(nil,nil,0);
      //настраивает
      pdev.Name:='PS_DAT_SMOKE';
      pdev^.Local.P_insert:=p1;
      //строим переменную часть примитива (та что может редактироваться)
      pdev.BuildVarGeometry(drawings.GetCurrentDWG^);
      //строим постоянную часть примитива
      pdev.BuildGeometry(drawings.GetCurrentDWG^);
      //"форматируем"
      rc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      pdev.FormatEntity(drawings.GetCurrentDWG^,rc);
      //дальше как обычно
      zcSetEntPropFromCurrentDrawingProp(pdev);
      zcAddEntToCurrentDrawingWithUndo(pdev);
      zcRedrawCurrentDrawing;
    end;
    result:=cmd_ok;
end;
function ExampleCreateLayer_com(operands:TCommandOperands):TCommandResult;
var
    pproglayer:PGDBLayerProp;
    pnevlayer:PGDBLayerProp;
    pe:PGDBObjEntity;
const
    createdlayername='hohoho';
begin
    if commandmanager.getentity(rscmSelectSourceEntity,pe) then
    begin
      pproglayer:=BlockBaseDWG.LayerTable.getAddres(createdlayername);//ищем описание слоя в библиотеке
                                                                      //возможно оно найдется, а возможно вернется nil
      pnevlayer:=drawings.GetCurrentDWG.LayerTable.createlayerifneedbyname(createdlayername,pproglayer);//эта процедура сначала ищет описание слоя в чертеже
                                                                                                        //если нашла - возвращает его
                                                                                                        //не нашла, если pproglayer не nil - создает такойде слой в чертеже
                                                                                                        //и только если слой в чертеже не найден pproglayer=nil то возвращает nil
      if pnevlayer=nil then //предидущие попытки обламались. в чертеже и в библиотеке слоя нет, тогда создаем новый
        pnevlayer:=drawings.GetCurrentDWG.LayerTable.addlayer(createdlayername{имя},ClWhite{цвет},-1{вес},true{on},false{lock},true{print},'???'{описание},TLOLoad{режим создания - в данном случае неважен});
      pe^.vp.Layer:=pnevlayer;
    end;
    result:=cmd_ok;
end;

function LinkDevices_com(operands:TCommandOperands):TCommandResult;
var
    pobj: pGDBObjEntity;
    pmainobj: pGDBObjEntity;
    ir:itrec;

    pCentralVarext,pVarext:PTVariablesExtender;
    UndoStartMarkerPlaced:boolean;
begin
  // UndoStartMarkerPlaced:=false;
  pmainobj:=nil;
  repeat
    if pmainobj=nil then
      if not commandmanager.getentity(rscmSelectEntityWithMainFunction,pmainobj) then
        exit(cmd_ok);
    pCentralVarext:=pmainobj^.GetExtension(typeof(TVariablesExtender));
    if pCentralVarext=nil then begin
      pmainobj:=nil;
      ZCMsgCallBackInterface.TextMessage('Please select device with variables',TMWOSilentShowError);
    end;
  until pCentralVarext<>nil;

  repeat
    if not commandmanager.getentity(rscmSelectLinkedEntity,pobj) then
      exit(cmd_ok);
    pVarext:=pobj^.GetExtension(typeof(TVariablesExtender));
    if pVarext=nil then begin
      ZCMsgCallBackInterface.TextMessage('Please select device with variables',TMWOSilentShowError);
    end else begin
      pCentralVarext^.addDelegate({pmainobj,}pobj,pVarext);
    end;
  until false;

  result:=cmd_ok;
end;
(*
function matchprop_com(operands:TCommandOperands):TCommandResult;
var
    ps,pd:PGDBObjEntity;
    SourceObjType:TObjID;
    isSourceObjText:boolean;
    dc:TDrawContext;
    UndoStartMarkerPlaced:boolean;
    drawing:PTZCADDrawing;
    EntChange:boolean;
const
    CommandName='MatchProp';
function isTextEnt(ObjType:TObjID):boolean;
begin
     if (ObjType=GDBtextID)
     or(ObjType=GDBMTextID)then
                               result:=true
                           else
                               result:=false;
end;

begin
    UndoStartMarkerPlaced:=false;
    if commandmanager.getentity(rscmSelectSourceEntity,ps) then
    begin
         zcShowCommandParams(SysUnit^.TypeName2PTD('TMatchPropParam'),@MatchPropParam);
         drawing:=PTZCADDrawing(drawings.GetCurrentDWG);
         dc:=drawing^.CreateDrawingRC;
         SourceObjType:=ps^.GetObjType;
         isSourceObjText:=isTextEnt(SourceObjType);
         while commandmanager.getentity(rscmSelectDestinationEntity,pd) do
         begin
              EntChange:=false;
              if MatchPropParam.ProcessLayer then
                if pd^.vp.Layer<>ps^.vp.Layer then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.Layer)^ do
                    begin
                         pd^.vp.Layer:=ps^.vp.Layer;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineType then
                if pd^.vp.LineType<>ps^.vp.LineType then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineType)^ do
                    begin
                         pd^.vp.LineType:=ps^.vp.LineType;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineWeight then
                if pd^.vp.LineWeight<>ps^.vp.LineWeight then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineWeight)^ do
                    begin
                         pd^.vp.LineWeight:=ps^.vp.LineWeight;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessColor then
                if pd^.vp.color<>ps^.vp.Color then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.color)^ do
                    begin
                         pd^.vp.color:=ps^.vp.Color;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if MatchPropParam.ProcessLineTypeScale then
                if pd^.vp.LineTypeScale<>ps^.vp.LineTypeScale then
                  begin
                    zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                    with PushCreateTGChangeCommand(drawing.UndoStack,pd^.vp.LineTypeScale)^ do
                    begin
                         pd^.vp.LineTypeScale:=ps^.vp.LineTypeScale;
                         ComitFromObj;
                    end;
                    EntChange:=true;
                  end;
              if (isSourceObjText)and(isTextEnt(pd^.GetObjType))then
              begin
                if MatchPropParam.TextParams.ProcessTextStyle then
                  if PGDBObjText(pd)^.TXTStyleIndex<>PGDBObjText(ps)^.TXTStyleIndex then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.TXTStyleIndex)^ do
                      begin
                           PGDBObjText(pd)^.TXTStyleIndex:=PGDBObjText(ps)^.TXTStyleIndex;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextSize then
                  if PGDBObjText(pd)^.textprop.size<>PGDBObjText(ps)^.textprop.size then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.size)^ do
                      begin
                           PGDBObjText(pd)^.textprop.size:=PGDBObjText(ps)^.textprop.size;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextOblique then
                  if PGDBObjText(pd)^.textprop.Oblique<>PGDBObjText(ps)^.textprop.Oblique then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.Oblique)^ do
                      begin
                           PGDBObjText(pd)^.textprop.Oblique:=PGDBObjText(ps)^.textprop.Oblique;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextWFactor then
                  if PGDBObjText(pd)^.textprop.wfactor<>PGDBObjText(ps)^.textprop.wfactor then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.wfactor)^ do
                      begin
                           PGDBObjText(pd)^.textprop.wfactor:=PGDBObjText(ps)^.textprop.wfactor;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
                if MatchPropParam.TextParams.ProcessTextJustify then
                  if PGDBObjText(pd)^.textprop.justify<>PGDBObjText(ps)^.textprop.justify then
                    begin
                      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,CommandName);
                      with PushCreateTGChangeCommand(drawing.UndoStack,PGDBObjText(pd)^.textprop.justify)^ do
                      begin
                           PGDBObjText(pd)^.textprop.justify:=PGDBObjText(ps)^.textprop.justify;
                           ComitFromObj;
                      end;
                      EntChange:=true;
                    end;
              end;
              if EntChange then
                begin
                  pd^.FormatEntity(drawings.GetCurrentDWG^,dc);
                  zcRedrawCurrentDrawing;
                end;
         end;
         zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
         zcHideCommandParams;
    end;
    result:=cmd_ok;
end;

*)

initialization
{ тут регистрация функций в интерфейсе зкада}

{ function DrawAlignedDim_com will be available by the name of DimAligned,
  to run requires open drawing  ie when typing in command line "DimAligned"
  executed DrawAlignedDim_com  }
{ функция DrawAlignedDim_com будет доступна по имени DimAligned,
  для запуска требует наличия открытого чертежа
  т.е. при наборе в комстроке DimAligned выполнится DrawAlignedDim_com }

     CreateCommandFastObjectPlugin(@InsertDevice_com,    'ID',   CADWG,0);

     CreateCommandFastObjectPlugin(@ExampleCreateLayer_com,'ExampleCreateLayer',   CADWG,0);

     CreateCommandFastObjectPlugin(@LinkDevices_com,'LD',   CADWG,0);
end.
