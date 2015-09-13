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
uses gdbentityfactory,gdbdrawcontext,ugdbdrawing,ugdbltypearray,zcadsysvars,UGDBLayerArray,sysutils,gdbasetypes,gdbase, {OGLtypes,}
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
function addblockinsert(own:PGDBObjGenericSubEntry;pva: PGDBObjEntityOpenArray; point: gdbvertex; scale, angle: GDBDouble; s: pansichar):pgdbobjblockinsert;export;
//procedure setdefaultproperty(pprop: PGDBProperty);
//procedure reformatmtext(pm: pgdbmtext);
//procedure reformattext(pt: pgdbtext);
//procedure reformatlwpolyline(pp: pgdblwpolyline);
function getgdb: GDBPointer; export;
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

function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;args:array of const): PGDBObjEntity;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;args:array of const): PGDBObjEntity;
var
   p:gdbvertex;
implementation
uses
    log;
function ENTF_CreateLine(owner:PGDBObjGenericSubEntry;args:array of const): PGDBObjEntity;
begin
  if assigned(_StandartLineCreateProcedure)then
                                               begin
                                                   result:=_StandartLineCreateProcedure(owner,args);
                                               end
                                           else
                                               begin
                                                    result:=nil;
                                                    programlog.LogOutStr('ENTF_CreateLine: Line entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
function ENTF_CreateCircle(owner:PGDBObjGenericSubEntry;args:array of const): PGDBObjEntity;
begin
  if assigned(_StandartCircleCreateProcedure)then
                                               begin
                                                   result:=_StandartCircleCreateProcedure(owner,args);
                                               end
                                           else
                                               begin
                                                    result:=nil;
                                                    programlog.LogOutStr('ENTF_CreateCircle: Circle entity not registred',lp_OldPos,LM_Error);
                                               end;
end;
procedure AddEntToCurrentDrawingWithUndo(PEnt:PGDBObjEntity);
var
    domethod,undomethod:tmethod;
begin
     SetObjCreateManipulator(domethod,undomethod);
     with PTDrawing(gdb.GetCurrentDWG)^.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
     begin
          AddObject(PEnt);
          comit;
     end;
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
      with ptdrawing(gdb.GetCurrentDWG)^.UndoStack.PushMultiObjectCreateCommand(tmethod(domethod),tmethod(undomethod),1)^ do
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
{procedure GDBObjSetLineProp(var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:GDBInteger;LW: GDBSmallint; p1, p2: GDBvertex);
begin
  GDBObjSetEntityProp(pobjline,layeraddres,LTAddres,color,LW);
  pobjline.CoordInOCS.lBegin := p1;
  pobjline.CoordInOCS.lEnd := p2;
end;

procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LW: GDBSmallint; p1, p2: GDBvertex); export;
begin
  pobjline^.init(own,layeraddres, LW, p1, p2);
end;}
{procedure GDBObjSetCircleProp(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LTAddres:PGDBLtypeProp;color:GDBInteger;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble);
begin
     GDBObjSetEntityProp(pobjcircle,layeraddres,LTAddres,color,LW);
     pobjcircle.Local.p_insert := p;
     pobjcircle.Radius := rr;
end;

procedure GDBObjCircleInit(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble);
begin
  pobjcircle^.init(gdb.GetCurrentROOT,layeraddres, LW, p, rr);
end;}
function getgdb: GDBPointer; export;
begin
  result := @gdb;
end;


procedure setdefaultproperty(pvo:pgdbobjEntity);
begin
  pvo^.selected := false;
  pvo^.Visible:=gdb.GetCurrentDWG.pcamera.VISCOUNT;
  pvo^.vp.layer :=gdb.GetCurrentDWG.LayerTable.GetCurrentLayer;
  pvo^.vp.lineweight := sysvar.dwg.DWG_CLinew^;
end;

{procedure addtext(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; h, angle: GDBDouble; s: pansichar; js: GDBByte);
var
  temp: PGDBGDBPointer;
  objnum: GDBInteger;
begin
  //exit;
  objnum := popa^.count;
  GDBGetMem(temp, sizeof(GDBText));
  setdefaultproperty(@popa^.propertyarray[objnum]);
  popa^.propertyarray[objnum].id := GDBTextID;
  popa^.propertyarray[objnum].layer := 0;
  popa^.propertyarray[objnum].pobject := temp;
  PGDBtext(temp)^.angle := angle * 180 / pi;
  PGDBtext(temp)^.size := h;
  PGDBtext(temp)^.oblique := 12;
  PGDBtext(temp)^.justify := js;
  PGDBtext(temp)^.wfactor := 0.65;
  GDBPointer(PGDBtext(temp)^.content) := nil;
  PGDBtext(temp)^.content := s;
  PGDBtext(temp)^.p_insert := point;
  PGDBtext(temp)^.p_draw := point;
  reformattext(pgdbtext(temp));
  inc(popa^.count);
end;

procedure addarc(popa: PGDBOpenArrayProperty_GDBWord; point: gdbvertex; startangle, endangle, r: GDBDouble);
var
  temp, temp2: PGDBGDBPointer;
  objnum: GDBInteger;
begin
  //exit;
  objnum := popa^.count;
  GDBGetMem(temp, sizeof(GDBArc));
  setdefaultproperty(@popa^.propertyarray[objnum]);
  popa^.propertyarray[objnum].id := GDBArcID;
  popa^.propertyarray[objnum].layer := 1;
  popa^.propertyarray[objnum].pobject := temp;

  PGDBarc(temp)^.startangle := startangle;
  PGDBarc(temp)^.endangle := endangle;
  PGDBarc(temp)^.r := r;
  PGDBarc(temp)^.x := point.x;
  PGDBarc(temp)^.y := point.y;
  PGDBarc(temp)^.z := point.z;
  inc(popa^.count);
end;}

function addblockinsert(own:PGDBObjGenericSubEntry;pva: PGDBObjEntityOpenArray; point: gdbvertex; scale, angle: GDBDouble; s: pansichar):pgdbobjblockinsert;
var
  //temp, temp2: PGDBByte;
  //i, objnum: GDBInteger;
  pb:pgdbobjblockinsert;
  nam:gdbstring;
  DC:TDrawContext;
begin
  result:=nil;
  if pos(DevicePrefix, uppercase(s))=1  then
                                         begin
                                         GDBPointer(pb):=pva^.CreateInitObj(GDBDeviceID,gdb.GetCurrentROOT);
                                         //pgdbobjdevice(pb)^.initnul;
                                         nam:=copy(s,8,length(s)-7);
                                         end
                                     else
                                         begin
                                              GDBPointer(pb):=pva^.CreateInitObj(GDBBlockInsertID,gdb.GetCurrentROOT);
                                              //pb.initnul;
                                              nam:=s;
                                         end;
  if pb=nil then exit;
  pb.bp.ListPos.Owner:={gdb.GetCurrentROOT}own;
  setdefaultproperty(pb);
  pb^.Local.P_insert := point;
  pb^.scale.x := scale;
  pb^.scale.y := scale;
  pb^.scale.z := scale;
  GDBPointer(pb^.name) := nil;
  pb^.name := nam;
  pb.index := -1;
  //pb.rotate := angle;
  pb.pattrib := nil;
  pb^.index:=gdb.GetCurrentDWG.BlockDefArray.getindex(pansichar(nam));
  //pb^.format;
  //pb^.ObjArray.init(1000);
  pb^.CalcObjMatrix;
  pb.setrot(angle);
  pb.rotate:=angle;
  pb^.BuildGeometry(gdb.GetCurrentDWG^);
  pb^.BuildVarGeometry(gdb.GetCurrentDWG^);
  DC:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pb^.formatEntity(gdb.GetCurrentDWG^,dc);
  gdb.GetCurrentROOT.ObjArray.ObjTree.CorrectNodeTreeBB(pb);
  //own.AddObjectToObjArray(addr(pb));
  result:=pb;
  {for i := 0 to GDB.BlockDefArray.count - 1 do
  begin
    if GDB.BlockDefArray.PArray[i].name = s then
      pb^.index := i
  end;}
end;




begin
    {$IFDEF DEBUGINITSECTION}LogOut('GDBmanager.initialization');{$ENDIF}
  p.x := 10;
  p.y := 20;
  p.z := 30;
  //a.init(nil,0, 10, p, p);
  //a.init(nil,0, 10, p, p);
end.
