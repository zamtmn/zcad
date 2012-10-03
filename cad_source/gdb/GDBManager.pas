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
uses zcadsysvars,gdbellipse,GDB3DFace,UGDBLayerArray,sysutils,gdbasetypes,gdbase, {OGLtypes,}
     UGDBDescriptor,varmandef,gdbobjectsconstdef,
     UGDBVisibleOpenArray,GDBGenericSubEntry,gdbEntity,GDBCable,GDBDevice,
     GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMText,GDBLine,
     GDBPolyLine,GDBLWPolyLine,memman,GDBSolid;
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
function CreateInitObjFree(t:GDBByte;owner:PGDBObjGenericSubEntry):PGDBObjEntity;export;
function CreateObjFree(t: GDBByte): PGDBObjEntity;export;
procedure GDBObjSetEntityProp(var pobjent: PGDBObjEntity;layeraddres:PGDBLayerProp;color:GDBInteger;LW: GDBSmallint); export;
procedure GDBObjSetLineProp(var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;color:GDBInteger;LW: GDBSmallint; p1, p2: GDBvertex); export;
procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LW: GDBSmallint; p1, p2: GDBvertex); export;
procedure GDBObjCircleInit(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble); export;
procedure GDBObjSetCircleProp(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;color:GDBInteger;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble); export;
var a: GDBObjLine;
  p: gdbvertex;
implementation
uses
    log;
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
procedure GDBObjSetEntityProp(var pobjent: PGDBObjEntity;layeraddres:PGDBLayerProp;color:GDBInteger;LW: GDBSmallint);
begin
     pobjent^.vp.Layer:=layeraddres;
     pobjent^.vp.LineWeight:=LW;
     pobjent^.vp.color:=color;
end;

procedure GDBObjSetLineProp(var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;color:GDBInteger;LW: GDBSmallint; p1, p2: GDBvertex);
begin
  GDBObjSetEntityProp(pobjline,layeraddres,color,LW);
  pobjline.CoordInOCS.lBegin := p1;
  pobjline.CoordInOCS.lEnd := p2;
end;

procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine;layeraddres:PGDBLayerProp;LW: GDBSmallint; p1, p2: GDBvertex); export;
begin
  pobjline^.init(own,layeraddres, LW, p1, p2);
end;
procedure GDBObjSetCircleProp(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;color:GDBInteger;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble);
begin
     GDBObjSetEntityProp(pobjcircle,layeraddres,color,LW);
     pobjcircle.Local.p_insert := p;
     pobjcircle.Radius := rr;
end;

procedure GDBObjCircleInit(var pobjcircle: PGDBObjCircle;layeraddres:PGDBLayerProp;LW: GDBSmallint; p: GDBvertex; RR: GDBDouble);
begin
  pobjcircle^.init(gdb.GetCurrentROOT,layeraddres, LW, p, rr);
end;
function CreateInitObjFree(t:GDBByte;owner:PGDBObjGenericSubEntry): PGDBObjEntity;export;
var temp: PGDBObjEntity;
begin
  temp := nil;
  case t of
    GDBLineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.line}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjLine));
        pgdbobjline(temp).initnul(owner);
      end;
    GDBTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.text}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjText));
        pgdbobjtext(temp).initnul(owner);
      end;
    GDBMTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.mtext}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjMText));
        pgdbobjMtext(temp).initnul(owner);
      end;
    GDBPolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.polyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpolyline));
        pgdbobjpolyline(temp).initnul(owner);
      end;
    GDBArcID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.arc}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjArc));
        pgdbobjArc(temp).initnul;
      end;
    GDBCircleID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.circle}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjCircle));
        pgdbobjCircle(temp).initnul;
      end;
    GDBlwpolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.lwpolyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjlwpolyline));
        pgdbobjLWPolyLine(temp).initnul;
      end;
    GDBPointID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.point}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpoint));
        pgdbobjpoint(temp).initnul(owner);
      end;
    GDBBlockInsertID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.blockinsert}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjBlockinsert));
        pgdbobjblockinsert(temp).initnul;
        pgdbobjblockinsert(temp).bp.ListPos.Owner:=owner;
      end;
    GDBDeviceID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.device}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjDevice));
        pgdbobjdevice(temp).initnul;
        pgdbobjdevice(temp).bp.ListPos.Owner:=owner;
      end;
    GDBCableID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.cable}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjDevice));
        pgdbobjcable(temp).initnul(owner);
        pgdbobjcable(temp).bp.ListPos.Owner:=owner;
      end;
    GDB3DfaceID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.3DFace}',{$ENDIF}GDBPointer(temp), sizeof(GDBObj3DFace));
        pGDBObj3DFace(temp).initnul(owner);
        pGDBObj3DFace(temp).bp.ListPos.Owner:=owner;
      end;
    GDBSolidID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.Solid}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjSolid));
        pGDBObjSolid(temp).initnul(owner);
        pGDBObjSolid(temp).bp.ListPos.Owner:=owner;
      end;
    GDBEllipseID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.Ellipse}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjEllipse));
        PGDBObjEllipse(temp).initnul{(owner)};
        PGDBObjEllipse(temp).bp.ListPos.Owner:=owner;
      end
  end;
  result := temp;
end;
function CreateObjFree(t:GDBByte): PGDBObjEntity;export;
var temp: PGDBObjEntity;
begin
  temp := nil;
  case t of
    GDBLineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.line}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjLine));
      end;
    GDBTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.text}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjText));
      end;
    GDBMTextID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.mtext}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjMText));
      end;
    GDBPolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.polyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpolyline));
      end;
    GDBCableID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.cable}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjCable));
      end;
    GDBArcID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.arc}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjArc));
      end;
    GDBCircleID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.circle}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjCircle));
      end;
    GDBlwpolylineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.lwpolyline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjlwpolyline));
      end;
    GDBPointID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.point}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjpoint));
      end;
    GDBBlockInsertID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.blockinsert}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjBlockinsert));
      end;
    GDBDeviceID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.device}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjDevice));
      end;
    GDBEllipseID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.Ellipse}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjEllipse));
      end
  end;
  result := temp;
end;
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
  pb^.BuildGeometry;
  pb^.BuildVarGeometry;
  pb^.format;
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
