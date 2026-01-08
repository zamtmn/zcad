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

{**Модуль утилит зкада}
unit uzcutils;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeutils,LCLProc,zcmultiobjectcreateundocommand,uzepalette,uzeentityfactory,
  uzgldrawcontext,uzcdrawing,uzestyleslinetypes,uzcsysvars,uzestyleslayers,
  SysUtils,uzeTypes,uzcdrawings,varmandef,uzeconsts,
  UGDBVisibleOpenArray,uzeentgenericsubentry,uzeentity,uzegeometrytypes,
  uzeentblockinsert,uzcinterface,gzctnrVectorTypes,uzeentitiesmanager,
  uzegeometry,zcmultiobjectchangeundocommand,uzeEntBase,UGDBVisibleTreeArray;

  {**Добавление в чертеж примитива с обвязкой undo
    @param(PEnt Указатель на добавляемый примитив)
    @param(Drawing Чертеж куда будет добавлен примитив)}
  procedure zcAddEntToDrawingWithUndo(const PEnt:PGDBObjBaseEntity;var Drawing:TZCADDrawing);

  procedure zcMoveEntsFromConstructRootToCurrentDrawingWithUndo(CommandName:String);

  procedure zcTransformSelectedEntsInDrawingWithUndo(CommandName:String;Transform:TzeTypedMatrix4d);

  {**Добавление в текущий чертеж примитива с обвязкой undo
    @param(PEnt Указатель на добавляемый примитив)}
  procedure zcAddEntToCurrentDrawingWithUndo(const PEnt:PGDBObjEntity);

  procedure zcAddEntToCurrentDrawingConstructRoot(const PEnt: PGDBObjEntity);

  procedure zcClearCurrentDrawingConstructRoot;
  procedure zcFreeEntsInCurrentDrawingConstructRoot;

  {**Получение "описателя" выбраных примитивов в текущем "корне" текущего чертежа
    @return(Указатель на первый выбранный примитив и общее количество выбраных примитивов)}
  function zcGetSelEntsDeskInCurrentRoot:TSelEntsDesk;

  {**Выставление свойств для примитива в соответствии с настройками текущего чертежа
  процедуры устанавливающие свойства должны быть заранее зарегистрированные с помощью
  zeRegisterEntPropSetter
    @param(PEnt Указатель на примитив)}
  procedure zcSetEntPropFromCurrentDrawingProp(const PEnt: PGDBObjEntity);

  {**Помещение в стек undo маркера начала команды. Используется для группировки
     операций отмены. Допускаются вложеные команды. Количество маркеров начала и
     конца должно совпадать
    @param(CommandName Имя команды. Будет показано в окне истории при отмене\повторе)
    @param(PushStone Поместить в стек ундо "камень". Ундо не сможет пройти через него пока не завершена текущая команда)}
  procedure zcStartUndoCommand(CommandName:String;PushStone:boolean=false);overload;
  procedure zcStartUndoCommand(var Drawing:TZCADDrawing;CommandName:String;PushStone:boolean=false);overload;

  {**Помещение в стек undo маркера конца команды. Используется для группировки
     операций отмены. Допускаются вложеные команды. Количество маркеров начала и
     конца должно совпадать}
  procedure zcEndUndoCommand;overload;
  procedure zcEndUndoCommand(var Drawing:TZCADDrawing);overload;

  procedure zcUndoPushStone(var Drawing:TZCADDrawing);

  {**Добавление в стек undo маркера начала команды при необходимости
    @param(UndoStartMarkerPlaced Флаг установки маркера: false - маркер еще не поставлен, ставим маркер, поднимаем флаг. true - ничего не делаем)
    @param(CommandName Имя команды. Будет показано в окне истории при отмене\повторе)
    @param(PushStone Поместить в стек ундо "камень". Ундо не сможет пройти через него пока не завершена текущая команда)}
  procedure zcPlaceUndoStartMarkerIfNeed(var UndoStartMarkerPlaced:boolean;const CommandName:String;PushStone:boolean=false);

  {**Добавление в стек undo маркера конца команды при необходимости
    @param(UndoStartMarkerPlaced Флаг установки маркера начала: true - маркер начала поставлен, ставим маркер конца, сбрасываем флаг. false - ничего не делаем)}
  procedure zcPlaceUndoEndMarkerIfNeed(var UndoStartMarkerPlaced:boolean);

  {**Показать параметры команды. Пока только в инспекторе объектов, потом может
     добавлю возможность показа и редактирования параметров в командной строке
    @param(PDataTypeDesk Указатель на описание структуры параметров (обычно то что возвращает SysUnit^.TypeName2PTD))
    @param(PInstance Указатель на параметры)}
  procedure zcShowCommandParams(const PDataTypeDesk:PUserTypeDescriptor;const PInstance:Pointer);

  {**Завершить показ параметров команды, вернуть содержиммое инспектора к умолчательному состоянию}
  procedure zcHideCommandParams();

  {**Перерисовать окно текущего чертежа}
  procedure zcRedrawCurrentDrawing();

  {**Выбрать примитив}
  procedure zcSelectEntity(pp:PGDBObjEntity);

function GDBInsertBlock(own:PGDBObjGenericSubEntry;BlockName:String;p_insert:TzePoint3d;
                        scale:TzePoint3d;rotate:Double;needundo:Boolean=false
                        ):PGDBObjBlockInsert;

function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityTreeArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;LW:TGDBLineWeight;color:TGDBPaletteColor;
                                point: TzePoint3d; scale, angle: Double; AName: String):PGDBObjBlockInsert;
function zcGetRealSelEntsCount:integer;
implementation
function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityTreeArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;LW:TGDBLineWeight;color:TGDBPaletteColor;
                                point: TzePoint3d; scale, angle: Double; AName: String):PGDBObjBlockInsert;
var
  DC:TDrawContext;
begin
  Result:=PGDBObjBlockInsert(ENTF_CreateBlockInsert(owner,ownerarray,
                                layeraddres,LTAddres,LW,color,
                                AName,point,scale, angle));
  if Result=nil then exit;
  //setdefaultproperty(Result);
  Result.pattrib := nil;
  Result^.BuildGeometry(drawings.GetCurrentDWG^);
  Result^.BuildVarGeometry(drawings.GetCurrentDWG^);
  DC:=drawings.GetCurrentDWG^.CreateDrawingRC;
  Result^.formatEntity(drawings.GetCurrentDWG^,dc);
  ownerarray.ObjTree.CorrectNodeBoundingBox(Result^,ownerarray.Count=1);
end;
function zcGetRealSelEntsCount:integer;
var
  pobj: pGDBObjEntity;
  ir:itrec;
begin
  result:=0;

  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.selected then
    inc(result);
  pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj=nil;
end;
procedure zcAddEntToDrawingWithUndo(const PEnt:PGDBObjBaseEntity;var Drawing:TZCADDrawing);
var
    domethod,undomethod:tmethod;
begin
     SetObjCreateManipulator(domethod,undomethod);
     with PushMultiObjectCreateCommand(Drawing.UndoStack,tmethod(domethod),tmethod(undomethod),1) do
     begin
          AddObject(PEnt);
          comit;
     end;
end;
procedure zcAddEntToCurrentDrawingWithUndo(const PEnt:PGDBObjEntity);
begin
     zcAddEntToDrawingWithUndo(PEnt,PTZCADDrawing(drawings.GetCurrentDWG)^);
end;
procedure zcMoveEntsFromConstructRootToCurrentDrawingWithUndo(CommandName:String);
var
  pcd:PTZCADDrawing;
  pobj: pGDBObjEntity;
  ir:itrec;
begin
  pcd:=PTZCADDrawing(drawings.GetCurrentDWG);
  pcd^.UndoStack.PushStartMarker(CommandName);
  pobj:=pcd^.GetConstructObjRoot.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    zcAddEntToDrawingWithUndo(pobj,pcd^);
    pobj^.State:=pobj^.State-[ESConstructProxy];
  pobj:=pcd^.GetConstructObjRoot.ObjArray.iterate(ir);
  until pobj=nil;
  pcd^.UndoStack.PushEndMarker;
  pcd^.ConstructObjRoot.ObjArray.Clear;
end;

procedure zcTransformSelectedEntsInDrawingWithUndo(CommandName:String;Transform:TzeTypedMatrix4d);
var
  pcd:PTZCADDrawing;
  pobj: pGDBObjEntity;
  ir:itrec;
  dc:TDrawContext;
  im:TzeTypedMatrix4d;
  count:integer;
  m:tmethod;
begin
  pcd:=PTZCADDrawing(drawings.GetCurrentDWG);
  count:=0;
  pobj:=pcd^.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.Selected then
      inc(count);
  pobj:=pcd^.GetCurrentROOT.ObjArray.iterate(ir);
  until pobj=nil;
  if count>0 then begin
    im:=Transform;
    uzegeometry.MatrixInvert(im);
    pcd^.UndoStack.PushStartMarker(CommandName);
    dc:=pcd^.CreateDrawingRC;
    with PushCreateTGMultiObjectChangeCommand(@pcd^.UndoStack,Transform,im,Count) do begin
      pobj:=pcd^.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pobj<>nil then
      repeat
        if pobj^.Selected then begin
          m.Code:=pointer(pobj^.Transform);
          m.Data:=pobj;
          AddMethod(m);
          dec(pobj^.vp.LastCameraPos);
          pobj^.Formatentity(drawings.GetCurrentDWG^,dc);
        end;
      pobj:=pcd^.GetCurrentROOT.ObjArray.iterate(ir);
      until pobj=nil;
      comit;
    end;
    pcd^.UndoStack.PushEndMarker;
  end;
end;

procedure zcStartUndoCommand(var Drawing:TZCADDrawing; CommandName:String;PushStone:boolean=false);
begin
  Drawing.UndoStack.PushStartMarker(CommandName);
  if PushStone then
    Drawing.UndoStack.PushStone;
end;

procedure zcStartUndoCommand(CommandName:String;PushStone:boolean=false);
begin
  zcStartUndoCommand(PTZCADDrawing(drawings.GetCurrentDWG)^,CommandName,PushStone);
end;
procedure zcAddEntToCurrentDrawingConstructRoot(const PEnt: PGDBObjEntity);
begin
  zeAddEntToRoot(PEnt,drawings.GetCurrentDWG^.ConstructObjRoot);
end;
procedure zcClearCurrentDrawingConstructRoot;
begin
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
end;
procedure zcFreeEntsInCurrentDrawingConstructRoot;
begin
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.free;
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
end;
procedure zcEndUndoCommand(var Drawing:TZCADDrawing);
begin
  Drawing.UndoStack.PushEndMarker;
end;
procedure zcUndoPushStone(var Drawing:TZCADDrawing);
begin
  Drawing.UndoStack.PushStone;
end;
procedure zcEndUndoCommand;
begin
  zcEndUndoCommand(PTZCADDrawing(drawings.GetCurrentDWG)^);
end;
procedure zcPlaceUndoStartMarkerIfNeed(var UndoStartMarkerPlaced:boolean;const CommandName:String;PushStone:boolean=false);
begin
    if UndoStartMarkerPlaced then exit;
    zcStartUndoCommand(CommandName,PushStone);
    UndoStartMarkerPlaced:=true;
end;
procedure zcPlaceUndoEndMarkerIfNeed(var UndoStartMarkerPlaced:boolean);
begin
    if not UndoStartMarkerPlaced then exit;
    zcEndUndoCommand;
    UndoStartMarkerPlaced:=false;
end;
procedure zcShowCommandParams(const PDataTypeDesk:PUserTypeDescriptor;const PInstance:Pointer);
begin
  zcUI.Do_PrepareObject(nil,drawings.GetUnitsFormat,
                        PDataTypeDesk,PInstance,
                        drawings.GetCurrentDWG);
end;
procedure zcHideCommandParams();
begin
  zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  {if assigned(ReturnToDefaultProc)then
      ReturnToDefaultProc;}
end;
procedure zcRedrawCurrentDrawing();
begin
  zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
end;
procedure zcSelectEntity(pp:PGDBObjEntity);
begin
  pp^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.Selector);
  drawings.CurrentDWG.wa.param.SelDesc.LastSelectedObject:=pp;
end;
function GDBInsertBlock(own:PGDBObjGenericSubEntry;//владелец
                        BlockName:String;       //имя блока
                        p_insert:TzePoint3d;        //точка вставки
                        scale:TzePoint3d;           //масштаб
                        rotate:Double;          //поворот
                        needundo:Boolean=false  //завернуть в ундо
                        ):PGDBObjBlockInsert;
var
  tb:PGDBObjBlockInsert;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
begin
  result := Pointer(own.ObjArray.CreateObj(GDBBlockInsertID));
  result.init(drawings.GetCurrentROOT,drawings.GetCurrentDWG^.GetCurrentLayer,0);
  result^.Name:=BlockName;
  //result^.vp.ID:=GDBBlockInsertID;
  result^.Local.p_insert:=p_insert;
  result^.scale:=scale;
  result^.CalcObjMatrix;
  result^.setrot(rotate);
  result^.rotate:=rotate;
  tb:=pointer(result^.FromDXFPostProcessBeforeAdd(nil,drawings.GetCurrentDWG^));
  if tb<>nil then begin
                       tb^.bp:=result^.bp;
                       result^.done;
                       Freemem(pointer(result));
                       result:=pointer(tb);
  end;
  if needundo then
  begin
      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1) do
      begin
           AddObject(result);
           comit;
      end;
  end
  else
     own.ObjArray.AddPEntity(result^);
  result^.CalcObjMatrix;
  result^.BuildGeometry(drawings.GetCurrentDWG^);
  result^.BuildVarGeometry(drawings.GetCurrentDWG^);
  DC:=drawings.GetCurrentDWG^.CreateDrawingRC;
  result^.FormatEntity(drawings.GetCurrentDWG^,dc);
  if needundo then
  begin
  drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeBoundingBox(result^);
  result^.Visible:=0;
  //result^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
  end;
end;
function zcGetSelEntsDeskInCurrentRoot:TSelEntsDesk;
begin
  result:=zeGetSelEntsDeskInRoot(drawings.GetCurrentROOT^);
end;
procedure zcSetEntPropFromCurrentDrawingProp(const PEnt: PGDBObjEntity);
begin
     zeSetEntPropFromDrawingProp(PEnt,drawings.GetCurrentDWG^)
end;

procedure setdefaultproperty(pvo:pgdbobjEntity);
begin
  pvo^.selected := false;
  pvo^.Visible:=drawings.GetCurrentDWG.pcamera.VISCOUNT;
  pvo^.vp.layer :=drawings.GetCurrentDWG.GetCurrentLayer;
  pvo^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
end;

begin
end.
