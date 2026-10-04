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
{$mode delphi}
unit uzcCommand_ElCable;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  LazUTF8,
  uzsbVarmanDef,
  uzeconsts,
  uzcLog,
  Varman,
  uzccablemanager,uzcdialogsfiles,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcutils,
  uzcinterface,
  uzeentity,uzcentnet,uzcentcable,
  uzeGeometryTypes,
  uzelongprocesssupport,
  uzcEnitiesVariablesExtender,
  uzcbillofmaterial,
  uzcdrawings,uzbPaths,uzcTranslations,UUnitManager,
  uzglviewareadata,uzccommand_line2,uzcsysvars,uzccomdraw,zcmultiobjectcreateundocommand,
  uzcdrawing,uzglviewareaabstract,uzeSnap,uzctnrVectorStrings,gzctnrVectorTypes,uzeentsubordinated,
  uzeentcurve,gzUndoCmdChgMethods,uzcCommand_ElExternalKZ;

implementation

type
  TELCableComParam=record
    Traces:TEnumData;(*'Trace'*)
    PCable:Pointer;(*'Cabel (pointer)'*)
    PTrace:Pointer;(*'Trace (pointer)'*)
  end;
  PTELCableComParam=^TELCableComParam;

var
  pcabcom:pCommandRTEdObjectPlugin;
  cabcomparam:TELCableComParam;
  p3dpl:PGDBObjCable;

function GetEntName(pu:PGDBObjGenericWithSubordinated):string;
var
  pvn:pvardesk;
  pentvarext:TVariablesExtender;
begin
  Result:='';
  pentvarext:=pu^.GetExtension<TVariablesExtender>;
  pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
  if (pvn<>nil) then begin
    Result:=pstring(pvn^.Data.Addr.Instance)^;
  end;
end;


procedure cabcomformat;
var
  s:string;
  ir_inGDB:itrec;
  currentobj:PGDBObjNet;
begin
  cabcomparam.Traces.Enums.Free;
  cabcomparam.PTrace:=nil;

  CurrentObj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
    repeat
      if CurrentObj^.GetObjType=GDBNetID then begin
        s:=getentname(CurrentObj);
        if s<>'' then begin
          cabcomparam.Traces.Enums.PushBackData(s);
          if cabcomparam.Traces.Selected=cabcomparam.Traces.Enums.Count-1 then
            cabcomparam.PTrace:=CurrentObj;

        end;
      end;
      CurrentObj:=drawings.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
    until CurrentObj=nil;

  s:='**Напрямую**';
  cabcomparam.Traces.Enums.PushBackData(s);
end;

function _Cable_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  s:string;
  ir_inGDB:itrec;
  currentobj:PGDBObjNet;
begin
  p3dpl:=nil;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  cabcomparam.Pcable:=nil;
  cabcomparam.PTrace:=nil;
  cabcomparam.Traces.Enums.Free;
  CurrentObj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
    repeat
      if CurrentObj^.GetObjType=GDBNetID then begin
        s:=getentname(CurrentObj);
        if s<>'' then begin
          cabcomparam.Traces.Enums.PushBackData(s);
          if CurrentObj^.Selected then begin
            cabcomparam.Traces.Selected:=cabcomparam.Traces.Enums.Count-1;
          end;

          if cabcomparam.Traces.Selected=cabcomparam.Traces.Enums.Count-1 then
            cabcomparam.PTrace:=CurrentObj;

        end;
      end;
      CurrentObj:=drawings.GetCurrentROOT.ObjArray.iterate(ir_inGDB);
    until CurrentObj=nil;

  s:='**Напрямую**';
  cabcomparam.Traces.Enums.PushBackData(s);
  zcShowCommandParams(SysUnit.TypeName2PTD('CommandRTEdObject'),pcabcom);



  zcUI.TextMessage('Первая точка:',TMWOHistoryOut);
  Result:=cmd_ok;
end;

procedure _Cable_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
begin
  if p3dpl<>nil then begin
    PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushEndMarker;
    if p3dpl^.VertexArrayInOCS.Count<2 then begin
      zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
      p3dpl^.YouDeleted(drawings.GetCurrentDWG^);
      PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.KillLastCommand;
    end;
  end;
  cabcomparam.PCable:=nil;
  cabcomparam.PTrace:=nil;
  //Freemem(pointer(p3dpl));
end;

function _Cable_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
var
  pvd:pvardesk;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
  pcablevarext:TVariablesExtender;
begin
  Result:=mclick;
  if (button and MZW_LBUTTON)<>0 then begin
    if p3dpl=nil then begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
      p3dpl:=Pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCableID,drawings.GetCurrentROOT));
      zcSetEntPropFromCurrentDrawingProp(p3dpl);
      drawings.standardization(p3dpl,GDBCableID);
      pcablevarext:=p3dpl^.GetExtension<TVariablesExtender>;
      pcablevarext.entityunit.copyfrom(units.findunit(GetSupportPaths,InterfaceTranslate,'cable'));
      pvd:=pcablevarext.entityunit.FindVariable('NMO_Suffix');
      pstring(pvd^.Data.Addr.Instance)^:=IntToStr(drawings.GetCurrentDWG.numerator.getnumber('CableNum',True));
      p3dpl^.AddVertex(wc);
      p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);

      PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStartMarker('Create cable');
      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,tmethod(domethod),tmethod(undomethod),1) do begin
        AddObject(p3dpl);
        comit;
      end;
      PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStone;
      drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count:=0;
      cabcomparam.Pcable:=p3dpl;
    end;
  end;
end;

function _Cable_com_AfterClick(const Context:TZCADCommandContext;wc:TzePoint3d;mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
var
  plastw:PzePoint3d;
  polydata:tpolydata;
  domethod,undomethod:tmethod;
  DC:TDrawContext;
begin
  Result:=mclick;
  p3dpl^.vp.Layer:=drawings.GetCurrentDWG.GetCurrentLayer;
  p3dpl^.vp.lineweight:=sysvar.dwg.DWG_CLinew^;
  drawings.standardization(p3dpl,GDBCableID);
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then begin
    if cabcomparam.PTrace=nil then begin
      polydata.index:=p3dpl^.VertexArrayInWCS.Count;
      polydata.wc:=wc;
      tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
      tmethod(domethod).Data:=p3dpl;
      tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
      tmethod(undomethod).Data:=p3dpl;
      with GUCmdChgMethods<TPolyData>.CreateAndPush(polydata,domethod,undomethod,(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack),
          drawings.AfterAutoProcessGDB) do begin
        comit;
      end;
      p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
      drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
    end else begin
      plastw:=p3dpl^.VertexArrayInWCS.getDataMutable(p3dpl^.VertexArrayInWCS.Count-1);
      rootbytrace(plastw^,wc,cabcomparam.PTrace,p3dpl,False);
      p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
      drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
    end;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count:=0;
    Result:=1;
    zcRedrawCurrentDrawing;
  end;
end;

function _Cable_com_Hd(mclick:integer):TCommandResult;
begin
  Result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  if SysUnit<>nil then begin
    SysUnit.RegisterType(TypeInfo(TELCableComParam));
    SysUnit.SetTypeDesk(TypeInfo(TELCableComParam),['Traces','PCable','PTrace'],[FNProgram]);
    SysUnit.SetTypeDesk(TypeInfo(TELCableComParam),['Traces','Cabel (pointer)','Trace (pointer)'],
      [FNUser]);
    SysUnit.RegisterType(TypeInfo(PTELCableComParam));
  end;

  pcabcom:=CreateCommandRTEdObjectPlugin(@_Cable_com_CommandStart,_Cable_com_CommandEnd,nil,
    @cabcomformat,@_Cable_com_BeforeClick,@_Cable_com_AfterClick,@_Cable_com_Hd,nil,'EL_Cable',0,0);

  pcabcom^.SetCommandParam(@cabcomparam,'PTELCableComParam');
  cabcomparam.Traces.Enums.init(10);
  cabcomparam.PTrace:=nil;

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  cabcomparam.Traces.Enums.done;
end.
