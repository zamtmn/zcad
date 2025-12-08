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
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$MODE OBJFPC}{$H+}
unit uzccommand_3dpoly;
{$INCLUDE zengineconfig.inc}

interface

uses
  gzUndoCmdChgMethods,zcmultiobjectcreateundocommand,
  uzcdrawing,uzgldrawcontext,
  uzeentityfactory,
  uzcsysvars,
  uzcstrconsts,
  uzccommandsabstract,
  uzccommandsmanager,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  uzglviewareadata,
  uzcinterface,
  uzegeometry,
  uzeconsts,
  uzegeometrytypes,
  uzeentpolyline,
  uzcLog;

var
  p3dplESP:TEntitySetupProc;

function _3DPoly_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
procedure _3DPoly_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
function _3DPoly_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
function _3DPoly_com_AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;

implementation

var
  p3dpl:pgdbobjpolyline;

function _3DPoly_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
  //< Команда построитель полилинии начало
begin
  p3dpl:=nil;
  p3dplESP:=nil;
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or
    (MRotateCamera));
  zcUI.TextMessage(rscmFirstPoint,TMWOHistoryOut);
  drawings.GetCurrentDWG^.wa.param.processObjConstruct:=True;
  Result:=cmd_ok;
end;

procedure _3DPoly_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
var
  domethod,undomethod:tmethod;
  cc:integer;
begin
  drawings.GetCurrentDWG^.wa.param.processObjConstruct:=False;
  if p3dpl<>nil then
    if p3dpl^.VertexArrayInOCS.Count<2 then begin
      zcUI.Do_GUIaction(
        nil,zcMsgUIReturnToDefaultObject);
      //p3dpl^.YouDeleted;
      cc:=pCommandRTEdObject(_self)^.UndoTop;
      PTZCADDrawing(
        drawings.GetCurrentDWG)^.UndoStack.ClearFrom(cc);
      p3dpl:=nil;
    end else begin
      cc:=pCommandRTEdObject(_self)^.UndoTop;
      PTZCADDrawing(
        drawings.GetCurrentDWG)^.UndoStack.ClearFrom(cc);

      if assigned(p3dplESP) then
        p3dplESP(ESSSetEntity,p3dpl);

      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(
          PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,domethod,undomethod,1) do begin
        AddObject(p3dpl);
        comit;
      end;
      drawings.GetCurrentDWG^.
        ConstructObjRoot.ObjArray.Count:=0;
      p3dpl:=nil;
    end;

  if assigned(p3dplESP) then
    p3dplESP(ESSCommandEnd,nil);
end;


function _3DPoly_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
var
  dc:TDrawContext;
begin
  Result:=mclick;
  if (button and MZW_LBUTTON)<>0 then begin
    if p3dpl=nil then begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      p3dpl:=Pointer({drawings.GetCurrentROOT^.ObjArray.CreateInitObj}
        drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(
        GDBPolylineID,{drawings.GetCurrentROOT}drawings.GetCurrentDWG^.GetConstructObjRoot));
      zcSetEntPropFromCurrentDrawingProp(p3dpl);
      p3dpl^.AddVertex(wc);
      if assigned(p3dplESP) then
        p3dplESP(ESSSetConstructEntity,p3dpl);
      p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
    end;
  end;
end;

function _3DPoly_com_AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
var
  domethod,undomethod:tmethod;
  polydata:tpolydata;
  dc:TDrawContext;
begin
  Result:=mclick;
  p3dpl^.vp.Layer:=drawings.GetCurrentDWG^.GetCurrentLayer;
  p3dpl^.vp.lineweight:=sysvar.dwg.DWG_CLinew^;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)<>0 then begin
    if (p3dpl^.VertexArrayInOCS.Count>1) and
      vertexeq(wc,p3dpl^.VertexArrayInWCS.getData(0)) then begin
      p3dpl^.Closed:=True;
      if assigned(p3dplESP) then
        p3dplESP(ESSSetConstructEntity,p3dpl);
      commandmanager.executecommandend;
    end else begin
      polydata.index:=p3dpl^.VertexArrayInOCS.Count;
      polydata.wc:=wc;
      domethod:=tmethod(@p3dpl^.InsertVertex);
      undomethod:=tmethod(@p3dpl^.DeleteVertex);
      with specialize GUCmdChgMethods<TPolyData>.CreateAndPush(
          polydata,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,@drawings.AfterNotAutoProcessGDB) do begin
        //AutoProcessGDB:=false;
        comit;
      end;
      if assigned(p3dplESP) then
        p3dplESP(ESSSetConstructEntity,p3dpl);
      p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
      //p3dpl^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
      Result:=1;
      zcRedrawCurrentDrawing;
    end;
  end;
end;

procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@_3DPoly_com_CommandStart,@_3DPoly_com_CommandEnd,
    {nil}@_3DPoly_com_CommandEnd,nil,@_3DPoly_com_BeforeClick,@_3DPoly_com_AfterClick,
    nil,nil,'3DPoly',0,0);
end;

procedure Finalize;
begin
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  startup;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  finalize;
end.
