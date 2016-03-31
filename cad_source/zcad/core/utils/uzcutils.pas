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

unit uzcutils;
{$INCLUDE def.inc}


interface
uses uzeutils,LCLProc,zcmultiobjectcreateundocommand,uzeentitiesmanager,uzepalette,
     uzeentityfactory,uzgldrawcontext,uzcdrawing,uzestyleslinetypes,uzcsysvars,
     uzestyleslayers,sysutils,uzbtypesbase,uzbtypes,uzcdrawings,varmandef,
     uzeconsts,UGDBVisibleOpenArray,uzeentgenericsubentry,uzeentity,
     uzeentblockinsert,uzbmemman,uzcinterface;

  {**Добавление в чертеж примитива с обвязкой undo
    @param(PEnt Указатель на добавляемый примитив)
    @param(Drawing Чертеж куда будет добавлен примитив)}
  procedure zcAddEntToDrawingWithUndo(const PEnt:PGDBObjEntity;var Drawing:TZCADDrawing);

  {**Добавление в текущий чертеж примитива с обвязкой undo
    @param(PEnt Указатель на добавляемый примитив)}
  procedure zcAddEntToCurrentDrawingWithUndo(const PEnt:PGDBObjEntity);

  procedure zcAddEntToCurrentDrawingConstructRoot(const PEnt: PGDBObjEntity);

  procedure zcClearCurrentDrawingConstructRoot;

  {**Получение "описателя" выбраных примитивов в текущем "корне" текущего чертежа
    @return(Указатель на первый выбранный примитив и общее количество выбраных примитивов)}
  function zcGetSelEntsDeskInCurrentRoot:TSelEntsDesk;

  {**Выставление общих свойств примитива в соответствии с настройками текущего чертежа.
     Слой, Тип линии, Вес линии, Цвет, Масштаб типа линии
    @param(PEnt Указатель на примитив)}
  procedure zcSetEntPropFromCurrentDrawingProp(const PEnt: PGDBObjEntity);

  {**Помещение в стек undo маркера начала команды. Используется для группировки
     операций отмены. Допускаются вложеные команды. Количество маркеров начала и
     конца должно совпадать
    @param(CommandName Имя команды. Будет показано в окне истории при отмене\повторе)}
  procedure zcStartUndoCommand(CommandName:GDBString);

  {**Помещение в стек undo маркера конца команды. Используется для группировки
     операций отмены. Допускаются вложеные команды. Количество маркеров начала и
     конца должно совпадать}
  procedure zcEndUndoCommand;

  {**Показать параметры команды. Пока только в инспекторе объектов, потом может
     добавлю возможность показа и редактирования параметров в командной строке
    @param(PDataTypeDesk Указатель на описание структуры параметров (обычно то что возвращает SysUnit^.TypeName2PTD))
    @param(PInstance Указатель на параметры)}
  procedure zcShowCommandParams(const PDataTypeDesk:PUserTypeDescriptor;const PInstance:Pointer);

  {**Завершить показ параметров команды, вернуть содержиммое инспектора к умолчательному состоянию}
  procedure zcHideCommandParams();

function GDBInsertBlock(own:PGDBObjGenericSubEntry;BlockName:GDBString;p_insert:GDBVertex;
                        scale:GDBVertex;rotate:GDBDouble;needundo:GDBBoolean=false
                        ):PGDBObjBlockInsert;

function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: GDBDouble; s: pansichar):PGDBObjBlockInsert;
implementation
function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: GDBDouble; s: pansichar):PGDBObjBlockInsert;
var
  pb:pgdbobjblockinsert;
  nam:gdbstring;
  DC:TDrawContext;
  CreateProc:TAllocAndInitAndSetGeomPropsFunc;
begin
  result:=nil;
  if pos(DevicePrefix, uppercase(s))=1  then
                                            begin
                                                nam:=copy(s,length(DevicePrefix)+1,length(s)-length(DevicePrefix));
                                                CreateProc:=_StandartDeviceCreateProcedure;
                                            end
                                        else
                                            begin
                                                 nam:=s;
                                                 CreateProc:=_StandartBlockInsertCreateProcedure;
                                            end;
  if assigned(CreateProc)then
                           begin
                               PGDBObjEntity(pb):=CreateProc(owner,[point.x,point.y,point.z,scale,angle,nam]);
                               zeSetEntityProp(pb,layeraddres,LTAddres,color,LW);
                               if ownerarray<>nil then
                                               ownerarray^.add(@pb);
                           end
                       else
                           begin
                                pb:=nil;
                                debugln('{E}ENTF_CreateBlockInsert: BlockInsert entity not registred');
                                //programlog.LogOutStr('ENTF_CreateBlockInsert: BlockInsert entity not registred',lp_OldPos,LM_Error);
                           end;
  if pb=nil then exit;
  //setdefaultproperty(pb);
  pb.pattrib := nil;
  pb^.BuildGeometry(drawings.GetCurrentDWG^);
  pb^.BuildVarGeometry(drawings.GetCurrentDWG^);
  DC:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pb^.formatEntity(drawings.GetCurrentDWG^,dc);
  owner.ObjArray.ObjTree.CorrectNodeTreeBB(pb);
  result:=pb;
end;
procedure zcAddEntToDrawingWithUndo(const PEnt:PGDBObjEntity;var Drawing:TZCADDrawing);
var
    domethod,undomethod:tmethod;
begin
     SetObjCreateManipulator(domethod,undomethod);
     with PushMultiObjectCreateCommand(Drawing.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
     begin
          AddObject(PEnt);
          comit;
     end;
end;
procedure zcAddEntToCurrentDrawingWithUndo(const PEnt:PGDBObjEntity);
begin
     zcAddEntToDrawingWithUndo(PEnt,PTZCADDrawing(drawings.GetCurrentDWG)^);
end;
procedure zcStartUndoCommand(CommandName:GDBString);
begin
     PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker(CommandName);
end;
procedure zcAddEntToCurrentDrawingConstructRoot(const PEnt: PGDBObjEntity);
begin
  zeAddEntToRoot(PEnt,drawings.GetCurrentDWG^.ConstructObjRoot);
end;
procedure zcClearCurrentDrawingConstructRoot;
begin
  drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Clear;
end;
procedure zcEndUndoCommand;
begin
     PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
end;
procedure zcShowCommandParams(const PDataTypeDesk:PUserTypeDescriptor;const PInstance:Pointer);
begin
  if assigned(SetGDBObjInspProc)then
      SetGDBObjInspProc(nil,drawings.GetUnitsFormat,
                        PDataTypeDesk,PInstance,
                        drawings.GetCurrentDWG);
end;
procedure zcHideCommandParams();
begin
  if assigned(ReturnToDefaultProc)then
      ReturnToDefaultProc(drawings.GetUnitsFormat);
end;
function GDBInsertBlock(own:PGDBObjGenericSubEntry;//владелец
                        BlockName:GDBString;       //имя блока
                        p_insert:GDBVertex;        //точка вставки
                        scale:GDBVertex;           //масштаб
                        rotate:GDBDouble;          //поворот
                        needundo:GDBBoolean=false  //завернуть в ундо
                        ):PGDBObjBlockInsert;
var
  tb:PGDBObjBlockInsert;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
begin
  result := GDBPointer(own.ObjArray.CreateObj(GDBBlockInsertID));
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
                       gdbfreemem(pointer(result));
                       result:=pointer(tb);
  end;
  if needundo then
  begin
      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
      begin
           AddObject(result);
           comit;
      end;
  end
  else
     own.ObjArray.add(addr(result));
  result^.CalcObjMatrix;
  result^.BuildGeometry(drawings.GetCurrentDWG^);
  result^.BuildVarGeometry(drawings.GetCurrentDWG^);
  DC:=drawings.GetCurrentDWG^.CreateDrawingRC;
  result^.FormatEntity(drawings.GetCurrentDWG^,dc);
  if needundo then
  begin
  drawings.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(result);
  result^.Visible:=0;
  result^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
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
