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

function GetEntName(pu:PGDBObjGenericWithSubordinated):String;
var
   pvn:pvardesk;
   pentvarext:TVariablesExtender;
begin
     result:='';
     pentvarext:=pu^.GetExtension<TVariablesExtender>;
     pvn:=pentvarext.entityunit.FindVariable('NMO_Name');
     if (pvn<>nil) then
                                      begin
                                           result:=pstring(pvn^.data.Addr.Instance)^;
                                      end;
end;


procedure cabcomformat;
var
   s:String;
   ir_inGDB:itrec;
   currentobj:PGDBObjNet;
begin
  cabcomparam.Traces.Enums.free;
  cabcomparam.PTrace:=nil;

  CurrentObj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if CurrentObj^.GetObjType=GDBNetID then
           begin
                s:=getentname(CurrentObj);
                if s<>'' then
                begin
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
   s:String;
   ir_inGDB:itrec;
   currentobj:PGDBObjNet;
begin
  p3dpl:=nil;
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  cabcomparam.Pcable:=nil;
  cabcomparam.PTrace:=nil;
  cabcomparam.Traces.Enums.free;
  //cabcomparam.Traces.Selected:=-1;
  CurrentObj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if CurrentObj^.GetObjType=GDBNetID then
           begin
                s:=getentname(CurrentObj);
                if s<>'' then
                begin
                     cabcomparam.Traces.Enums.PushBackData(s);
                     if CurrentObj^.Selected then
                     begin
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
  result:=cmd_ok;
end;
Procedure _Cable_com_CommandEnd(const Context:TZCADCommandContext;_self:pointer);
begin
  if p3dpl<>nil then
  begin
  PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushEndMarker;
  if p3dpl^.VertexArrayInOCS.Count<2 then
                                         begin
                                              zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
                                              p3dpl^.YouDeleted(drawings.GetCurrentDWG^);
                                              PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.KillLastCommand;
                                         end;
  end;
  cabcomparam.PCable:=nil;
  cabcomparam.PTrace:=nil;
  //Freemem(pointer(p3dpl));
end;
function _Cable_com_BeforeClick(const Context:TZCADCommandContext;wc: TzePoint3d; mc: TzePoint2i; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var
   pvd:pvardesk;
   domethod,undomethod:tmethod;
   DC:TDrawContext;
   pcablevarext:TVariablesExtender;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if p3dpl=nil then
    begin
      dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
    p3dpl := Pointer(drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateInitObj(GDBCableID,drawings.GetCurrentROOT));
    //p3dpl := Pointer(drawings.GetCurrentROOT.ObjArray.CreateinitObj(GDBCableID,drawings.GetCurrentROOT));
    zcSetEntPropFromCurrentDrawingProp(p3dpl);
    drawings.standardization(p3dpl,GDBCableID);
    //p3dpl^.init(@drawings.GetCurrentDWG.ObjRoot,drawings.LayerTable.GetCurrentLayer, sysvar.dwg.DWG_CLinew^);

    //uunitmanager.units.loadunit(expandpath('*blocks\el\cable.pas'),@p3dpl^.ou);
    pcablevarext:=p3dpl^.GetExtension<TVariablesExtender>;
    pcablevarext.entityunit.copyfrom(units.findunit(GetSupportPaths,InterfaceTranslate,'cable'));
    //pvd:=p3dpl^.ou.FindVariable('DB_link');
    //pstring(pvd^.Instance)^:='Кабель ??';

    {pvd:=p3dpl.ou.FindVariable('NMO_BaseName');
    pstring(pvd^.Instance)^:=drawings.numerator.getnamenumber('К');}
    //pvd:=p3dpl.ou.FindVariable('NMO_Prefix');
    //pstring(pvd^.Instance)^:='';

    //pvd:=p3dpl.ou.FindVariable('NMO_BaseName');
    //pstring(pvd^.Instance)^:='@';

    pvd:=pcablevarext.entityunit.FindVariable('NMO_Suffix');
    pstring(pvd^.data.Addr.Instance)^:=inttostr(drawings.GetCurrentDWG.numerator.getnumber('CableNum',true));
    //p3dpl^.bp.Owner:=@drawings.GetCurrentDWG.ObjRoot;
    //drawings.GetCurrentDWG.ObjRoot.ObjArray.add(addr(p3dpl));
    //GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjCable'),p3dpl);
    p3dpl^.AddVertex(wc);
    p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);

    PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStartMarker('Create cable');
    SetObjCreateManipulator(domethod,undomethod);
    with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,tmethod(domethod),tmethod(undomethod),1) do
    begin
         AddObject(p3dpl);
         comit;
    end;
    PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStone;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count:=0;

    //drawings.GetCurrentROOT.ObjArray.ObjTree.{AddObjectToNodeTree(p3dpl)}CorrectNodeTreeBB(p3dpl);

    cabcomparam.Pcable:=p3dpl;
    //GDBobjinsp.setptr(SysUnit.TypeName2PTD('GDBObjCable'),p3dpl);
    end;
  end
end;

function _Cable_com_AfterClick(const Context:TZCADCommandContext;wc: TzePoint3d; mc: TzePoint2i; var button: Byte;osp:pos_record;mclick:Integer): Integer;
var //po:PGDBObjSubordinated;
    plastw:PzePoint3d;
    //tw1,tw2:TzePoint3d;
    //l1,l2:pgdbobjline;
    //pa:GDBPoint3dArray;
    polydata:tpolydata;
    domethod,undomethod:tmethod;
    DC:TDrawContext;
begin
  result:=mclick;
  p3dpl^.vp.Layer :=drawings.GetCurrentDWG.GetCurrentLayer;
  p3dpl^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
  drawings.standardization(p3dpl,GDBCableID);
  //p3dpl^.CoordInOCS.lEnd:= wc;
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  if (button and MZW_LBUTTON)<>0 then
  begin
    if cabcomparam.PTrace=nil then
    begin
         {polydata.nearestvertex:=p3dpl^.VertexArrayInWCS.Count;
         polydata.nearestline:=p3dpl^.VertexArrayInWCS.Count;
         polydata.dir:=1;}
         polydata.index:=p3dpl^.VertexArrayInWCS.Count;
         polydata.wc:=wc;
         tmethod(domethod).Code:=pointer(p3dpl.InsertVertex);
         tmethod(domethod).Data:=p3dpl;
         tmethod(undomethod).Code:=pointer(p3dpl.DeleteVertex);
         tmethod(undomethod).Data:=p3dpl;
         with GUCmdChgMethods<TPolyData>.CreateAndPush(polydata,domethod,undomethod,(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack),drawings.AfterAutoProcessGDB) do
         begin
              comit;
         end;
          {p3dpl^.AddVertex(wc);}
          p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
          //p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
          drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
    end
else begin
          plastw:=p3dpl^.VertexArrayInWCS.getDataMutable(p3dpl^.VertexArrayInWCS.Count-1);

          rootbytrace(plastw^,wc,cabcomparam.PTrace,p3dpl,false);

          (*pointer(l1):=cabcomparam.PTrace.GetNearestLine(plastw^);
          pointer(l2):=cabcomparam.PTrace.GetNearestLine(wc);
          tw1:=NearestPointOnSegment(plastw^,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
          if l1=l2 then
                       begin
                            if not IsPointEqual(tw1,plastw^) then
                                                                p3dpl^.AddVertex(tw1);
                            tw1:=NearestPointOnSegment(wc,l1.CoordInWCS.lBegin,l1.CoordInWCS.lEnd);
                            if not IsPointEqual(tw1,wc) then
                                                           p3dpl^.AddVertex(tw1);
                            p3dpl^.AddVertex(wc);
                            //l1:=l2;
                       end
                   else
                       begin
                            tw2:=NearestPointOnSegment(wc,l2.CoordInWCS.lBegin,l2.CoordInWCS.lEnd);
                            cabcomparam.PTrace.BuildGraf;
                            pa.init(100);
                            cabcomparam.PTrace.graf.FindPath(tw1,tw2,l1,l2,pa);
                            if not IsPointEqual(tw1,plastw^) then
                                                                p3dpl^.AddVertex(tw1);
                            pa.copyto(@p3dpl.VertexArrayInOCS);
                            plastw:=p3dpl^.VertexArrayInWCS.getDataMutable(p3dpl^.VertexArrayInWCS.Count-1);
                            if not IsPointEqual(tw2,plastw^) then
                                                                p3dpl^.AddVertex(tw2);
                            if not IsPointEqual(tw2,wc) then
                                                           p3dpl^.AddVertex(wc);
                            pa.done;
                       end;*)
        p3dpl^.Formatentity(drawings.GetCurrentDWG^,dc);
        //p3dpl^.RenderFeedback(drawings.GetCurrentDWG.pcamera^.POSCOUNT,drawings.GetCurrentDWG.pcamera^,drawings.GetCurrentDWG^.myGluProject2,dc);
        drawings.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeBoundingBox(p3dpl^);
     end;
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.Count := 0;
    result:=1;
    zcRedrawCurrentDrawing;
  end;
end;
function _Cable_com_Hd(mclick:Integer):TCommandResult;
begin
     //mclick:=mclick;//        asdf
     result:=cmd_ok;
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

  pcabcom:=CreateCommandRTEdObjectPlugin(@_Cable_com_CommandStart, _Cable_com_CommandEnd,nil,
    @cabcomformat,@_Cable_com_BeforeClick,@_Cable_com_AfterClick,@_Cable_com_Hd,nil,'EL_Cable',0,0);

  pcabcom^.SetCommandParam(@cabcomparam,'PTELCableComParam');
  cabcomparam.Traces.Enums.init(10);
  cabcomparam.PTrace:=nil;

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  cabcomparam.Traces.Enums.done;
end.
