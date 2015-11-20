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

unit GDBManager;
{$INCLUDE def.inc}


interface
uses LCLProc,zcmultiobjectcreateundocommand,zeentitiesmanager,gdbpalette,zeentityfactory,gdbdrawcontext,ugdbdrawing,ugdbltypearray,zcadsysvars,UGDBLayerArray,sysutils,gdbasetypes,gdbase, {OGLtypes,}
     UGDBDescriptor,varmandef,gdbobjectsconstdef,
     UGDBVisibleOpenArray,GDBGenericSubEntry,gdbEntity,
     GDBBlockInsert,
     memman;
type
    TSelObjDesk=record
                      PFirstObj:PGDBObjEntity;
                      Count:GDBInteger;
                end;
//procedure addtext(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; h, angle: GDBDouble; s: pansichar; js: GDBByte); export;
//procedure addarc(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; startangle, endangle, r: GDBDouble); export;
//procedure setdefaultproperty(pprop: PGDBProperty);
//procedure reformatmtext(pm: pgdbmtext);
//procedure reformattext(pt: pgdbtext);
//procedure reformatlwpolyline(pp: pgdblwpolyline);
//procedure reformat(obj:PGDBproperty); export;
//procedure CopyGDBObject(dest,source:PGDBproperty);export;
//procedure GDBFreeMemGDBObject(source:PGDBproperty);export;
//procedure GDBGetMemGDBObject(source:PGDBproperty);export;
function GetSelOjbj:TSelObjDesk;
procedure GDBObjSetEntityCurrentProp(const pobjent: PGDBObjEntity); export;

{procedure GDBObjSetLineProp(var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:GDBInteger;LW: GDBSmallint; p1, p2: GDBvertex); export;
procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LW: GDBSmallint; p1, p2: GDBvertex); export;}

{procedure GDBObjCircleInit(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble); export;
procedure GDBObjSetCircleProp(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:GDBInteger;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble); export;}

function GDBInsertBlock(own:PGDBObjGenericSubEntry;BlockName:GDBString;p_insert:GDBVertex;
                        scale:GDBVertex;rotate:GDBDouble;needundo:GDBBoolean=false
                        ):PGDBObjBlockInsert;
procedure AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
procedure UndoCommandStartMarker(CommandName:GDBString);
procedure UndoCommandEndMarker;

function old_ENTF_CreateBlockInsert(owner:PGDBObjGenericSubEntry;ownerarray: PGDBObjEntityOpenArray;
                                layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:TGDBPaletteColor;LW:TGDBLineWeight;
                                point: gdbvertex; scale, angle: GDBDouble; s: pansichar):PGDBObjBlockInsert;

var
   p:gdbvertex;
implementation
//uses
//    log;
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
                               GDBObjSetEntityProp(pb,layeraddres,LTAddres,color,LW);
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
  pb^.BuildGeometry(gdb.GetCurrentDWG^);
  pb^.BuildVarGeometry(gdb.GetCurrentDWG^);
  DC:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pb^.formatEntity(gdb.GetCurrentDWG^,dc);
  owner.ObjArray.ObjTree.CorrectNodeTreeBB(pb);
  result:=pb;
end;

procedure AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
var
    domethod,undomethod:tmethod;
begin
     SetObjCreateManipulator(domethod,undomethod);
     with PushMultiObjectCreateCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
     begin
          AddObject(PEnt);
          comit;
     end;
end;
procedure UndoCommandStartMarker(CommandName:GDBString);
begin
     PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushStartMarker(CommandName);
end;
procedure UndoCommandEndMarker;
begin
     PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushEndMarker;
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
  result.init(gdb.GetCurrentROOT,gdb.GetCurrentDWG^.LayerTable.GetCurrentLayer,0);
  result^.Name:=BlockName;
  result^.vp.ID:=GDBBlockInsertID;
  result^.Local.p_insert:=p_insert;
  result^.scale:=scale;
  result^.CalcObjMatrix;
  result^.setrot(rotate);
  result^.rotate:=rotate;
  tb:=pointer(result^.FromDXFPostProcessBeforeAdd(nil,gdb.GetCurrentDWG^));
  if tb<>nil then begin
                       tb^.bp:=result^.bp;
                       result^.done;
                       gdbfreemem(pointer(result));
                       result:=pointer(tb);
  end;
  if needundo then
  begin
      SetObjCreateManipulator(domethod,undomethod);
      with PushMultiObjectCreateCommand(PTDrawing(gdb.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),1)^ do
      begin
           AddObject(result);
           comit;
      end;
  end
  else
     own.ObjArray.add(addr(result));
  result^.CalcObjMatrix;
  result^.BuildGeometry(gdb.GetCurrentDWG^);
  result^.BuildVarGeometry(gdb.GetCurrentDWG^);
  DC:=gdb.GetCurrentDWG^.CreateDrawingRC;
  result^.FormatEntity(gdb.GetCurrentDWG^,dc);
  if needundo then
  begin
  gdb.GetCurrentROOT^.ObjArray.ObjTree.CorrectNodeTreeBB(result);
  result^.Visible:=0;
  result^.RenderFeedback(gdb.GetCurrentDWG^.pcamera^.POSCOUNT,gdb.GetCurrentDWG^.pcamera^,gdb.GetCurrentDWG^.myGluProject2,dc);
  end;
end;

function GetSelOjbj:TSelObjDesk;
var
    pv:pGDBObjEntity;
    ir:itrec;
begin
     result.PFirstObj:=nil;
     result.Count:=0;

     pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);

  if pv<>nil then
  repeat
    if pv^.Selected then
    begin
         if result.Count=0 then
                                result.PFirstObj:=pv;
         inc(result.count);
    end;
  pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;
end;
procedure GDBObjSetEntityCurrentProp(const pobjent: PGDBObjEntity);
begin
     pobjent^.vp.Layer:=sysvar.dwg.DWG_CLayer^;
     pobjent^.vp.LineType:=sysvar.dwg.DWG_CLType^;
     pobjent^.vp.LineWeight:=sysvar.dwg.DWG_CLinew^;
     pobjent^.vp.color:=sysvar.dwg.DWG_CColor^;
end;

procedure setdefaultproperty(pvo:pgdbobjEntity);
begin
  pvo^.selected := false;
  pvo^.Visible:=gdb.GetCurrentDWG.pcamera.VISCOUNT;
  pvo^.vp.layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  pvo^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
end;

begin
    {$IFDEF DEBUGINITSECTION}LogOut('GDBmanager.initialization');{$ENDIF}
  p.x := 10;
  p.y := 20;
  p.z := 30;
  //a.init(nil,0, 10, p, p);
  //a.init(nil,0, 10, p, p);
end.
