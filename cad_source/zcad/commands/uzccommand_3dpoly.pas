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
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$MODE OBJFPC}
unit uzccommand_3dpoly;
{$INCLUDE def.inc}

interface
uses
  gzctnrvector,uzglviewareageneral,zcobjectchangeundocommand2,zcmultiobjectchangeundocommand,
  gzctnrvectortypes,zcmultiobjectcreateundocommand,uzeentitiesmanager,uzgldrawercanvas,
  uzcoimultiobjects,uzcenitiesvariablesextender,uzcdrawing,uzepalette,
  uzctextenteditor,uzgldrawcontext,usimplegenerics,UGDBPoint3DArray,
  uzeentpoint,uzeentitiestree,gmap,gvector,garrayutils,gutil,UGDBSelectedObjArray,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,uzccomdrawdase,
  printers,graphics,uzeentdevice,uzeentwithlocalcs,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,uzeentabstracttext,uzestylestexts,
  uzccommandsabstract,uzbstrproc,
  uzbtypesbase,uzccommandsmanager,uzccombase,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzeffdxf,
  uzcinterface,
  uzegeometry,
  uzbmemman,
  uzeconsts,
  uzbgeomtypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzeentsubordinated,uzeentblockinsert,uzeentpolyline,uzclog,gzctnrvectordata,
  math,uzeenttable,uzctnrvectorgdbstring,
  uzeentcurve,uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,LazLogger;

implementation
var
  p3dpl:pgdbobjpolyline;

function _3DPoly_com_CommandStart(operands:TCommandOperands):TCommandResult; //< Команда построитель полилинии начало
begin
  p3dpl:=nil;
  drawings.GetCurrentDWG^.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  ZCMsgCallBackInterface.TextMessage(rscmFirstPoint,TMWOHistoryOut);
  drawings.GetCurrentDWG^.wa.param.processObjConstruct:=true;
  result:=cmd_ok;
end;

Procedure _3DPoly_com_CommandEnd(_self:pointer);
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
                                        with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,domethod,undomethod,1)^ do
                                        begin
                                             AddObject(p3dpl);
                                             comit;
                                        end;
                                        drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.Count := 0;
                                        p3dpl:=nil;
                                      end;
  //gdbfreemem(pointer(p3dpl));
end;


function _3DPoly_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
var
    dc:TDrawContext;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin
    dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    p3dpl := GDBPointer({drawings.GetCurrentROOT^.ObjArray.CreateInitObj}drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBPolylineID,{drawings.GetCurrentROOT}drawings.GetCurrentDWG^.GetConstructObjRoot));
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

function _3DPoly_com_AfterClick(wc: GDBvertex; mc: GDBvertex2DI; var button: GDBByte;osp:pos_record;mclick:GDBInteger): GDBInteger;
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
      with PushCreateTGObjectChangeCommand2(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,polydata,tmethod(domethod),tmethod(undomethod))^ do
      begin
        AutoProcessGDB:=false;
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
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
