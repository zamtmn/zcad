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
  gzundoCmdChgMethods,zcmultiobjectcreateundocommand,

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

implementation
var
  p3dpl:pgdbobjpolyline;

function _3DPoly_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult; //< Команда построитель полилинии начало
begin
  p3dpl:=nil;
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  ZCMsgCallBackInterface.TextMessage(rscmFirstPoint,TMWOHistoryOut);
  drawings.GetCurrentDWG^.wa.param.processObjConstruct:=true;
  result:=cmd_ok;
end;

Procedure _3DPoly_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
var
    domethod,undomethod:tmethod;
    cc:integer;
begin
     drawings.GetCurrentDWG^.wa.param.processObjConstruct:=false;
  if p3dpl<>nil then
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                              ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
                                              //p3dpl^.YouDeleted;
                                              cc:=pCommandRTEdObject(_self)^.UndoTop;
                                              PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.ClearFrom(cc);
                                              p3dpl:=nil;
                                         end
                                      else
                                      begin
                                        cc:=pCommandRTEdObject(_self)^.UndoTop;
                                        PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.ClearFrom(cc);

                                        SetObjCreateManipulator(domethod,undomethod);
                                        with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,domethod,undomethod,1) do
                                        begin
                                             AddObject(p3dpl);
                                             comit;
                                        end;
                                        drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                                        p3dpl:=nil;
                                      end;
  //Freemem(pointer(p3dpl));
end;


function _3DPoly_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
    dc:TDrawContext;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    p3dpl := Pointer({drawings.GetCurrentROOT^.ObjArray.CreateInitObj}drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBPolylineID,{drawings.GetCurrentROOT}drawings.GetCurrentDWG^.GetConstructObjRoot));
    zcSetEntPropFromCurrentDrawingProp(p3dpl);
    p3dpl^.AddVertex(wc);
    p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
    //drawings.GetCurrentROOT^.ObjArray.ObjTree.AddObjectToNodeTree(p3dpl);
    //drawings.GetCurrentROOT^.ObjArray.ObjTree.{AddObjectToNodeTree(p3dpl)}CorrectNodeBoundingBox(p3dpl);   vbnvbn
    //drawings.GetCurrentROOT^.AddObjectToObjArray(addr(p3dpl));

    //if assigned(PrepareObject)then
    //PrepareObject(drawings.GetUndoStack,drawings.GetUnitsFormat,SysUnit^.TypeName2PTD('GDBObjPolyline'),p3dpl,drawings.GetCurrentDWG);
    end;

  end
end;

function _3DPoly_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
  domethod,undomethod:tmethod;
  polydata:tpolydata;
  dc:TDrawContext;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=drawings.GetCurrentDWG^.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)<>0 then begin
    if (p3dpl^.VertexArrayInOCS.count>1) and vertexeq(wc,p3dpl^.VertexArrayInWCS.getData(0)) then begin
      p3dpl^.Closed:=true;
      commandmanager.executecommandend;
    end else begin
      polydata.index:=p3dpl^.VertexArrayInOCS.count;
      polydata.wc:=wc;
      domethod:=tmethod(@p3dpl^.InsertVertex);
      undomethod:=tmethod(@p3dpl^.DeleteVertex);
      with specialize GUCmdChgMethods<TPolyData>.CreateAndPush(polydata,domethod,undomethod,PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,@drawings.AfterNotAutoProcessGDB) do
      begin
        //AutoProcessGDB:=false;
        comit;
      end;
      p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
      p3dpl^.RenderFeedback(drawings.GetCurrentDWG^.pcamera^.POSCOUNT,drawings.GetCurrentDWG^.pcamera^,@drawings.GetCurrentDWG^.myGluProject2,dc);
      result:=1;
      zcRedrawCurrentDrawing;
    end;
  end;
end;

procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@_3DPoly_com_CommandStart,@_3DPoly_com_CommandEnd,{nil}@_3DPoly_com_CommandEnd,nil,@_3DPoly_com_BeforeClick,@_3DPoly_com_AfterClick,nil,nil,'3DPoly',0,0);
end;
procedure Finalize;
begin
end;
initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  startup;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.
