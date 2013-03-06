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

unit gdbentityfactory;
{$INCLUDE def.inc}


interface
uses memman,gdbobjectsconstdef,zcadsysvars,GDBase,GDBasetypes,GDBGenericSubEntry,gdbEntity,GDBCable,GDBDevice,
     GDBBlockInsert,GDBCircle,GDBArc,GDBPoint,GDBText,GDBMText,GDBLine,
     GDBPolyLine,GDBLWPolyLine,gdbellipse,GDB3DFace,GDBSolid,gdbspline;
function CreateInitObjFree(t:GDBByte;owner:PGDBObjGenericSubEntry):PGDBObjEntity;export;
function CreateObjFree(t: GDBByte): PGDBObjEntity;export;
implementation
uses
    log;
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
      end;
    GDBSplineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateInitObjFree.Spline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjSpline));
        PGDBObjSpline(temp).initnul(owner);
        PGDBObjSpline(temp).bp.ListPos.Owner:=owner;
      end;
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
      end;
    GDBSplineID: begin
        GDBGetMem({$IFDEF DEBUGBUILD}'{CreateObjFree.Spline}',{$ENDIF}GDBPointer(temp), sizeof(GDBObjSpline));
      end;
  end;
  result := temp;
end;
begin
    {$IFDEF DEBUGINITSECTION}LogOut('gdbentityfactory.initialization');{$ENDIF}
end.
