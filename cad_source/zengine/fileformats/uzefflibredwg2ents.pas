{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file GPL-3.0.txt, included in this distribution,                 *
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

unit uzeffLibreDWG2Ents;
{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}
interface
uses
  uzbLogIntf,
  SysUtils,
  dwg,dwgproc,
  uzeentgenericsubentry,{uzbtypes,}uzedrawingsimple,
  uzbstrproc,
  uzestyleslayers,
  uzeentline,uzeentcircle,uzeentpolyline,uzeentlwpolyline,uzegeometry,uzeentity,//uzgldrawcontext,
  uzeffLibreDWG,
  uzeffmanager;
implementation
//type
  //PDwg_Entity_LINE=^Dwg_Entity_LINE;
  //PDwg_Object_LAYER=^Dwg_Object_LAYER;

procedure AddLayer(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PDWGLayer:PDwg_Object_LAYER);
var
  player:PGDBLayerProp;
  name:string;
begin
  BITCODE_T2Text(PDWGLayer^.name,DWGContext,name);
  zDebugLn(['{WH}Layer: ',name]);
  if DWGContext.DWGVer>R_2006 then
    name:=Tria_Utf8ToAnsi(name);
  player:=ZContext.PDrawing^.LayerTable.MergeItem(name,ZContext.LoadMode);
  if player<>nil then begin
    player^.init(name);
    player^.color:=PDWGLayer^.color.index;
    player^.lineweight:=PDWGLayer^.linewt;
    //LT:Pointer;
    player^._on:=(PDWGLayer^.&on<>0);
    player^._lock:=(PDWGLayer^.locked<>0);
    player^._print:=(PDWGLayer^.plotflag<>0);
    //desk:AnsiString;
  end;
end;

procedure AddLineType(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PDWGLType:PDwg_Object_LTYPE);
var
  //player:PGDBLayerProp;
  name:string;
begin
  BITCODE_T2Text(PDWGLType^.name,DWGContext,name);
  zDebugLn(['{WH}LineType: ',name]);
end;

procedure AddBlockHeader(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PDWGBlock_Header:PDwg_Object_BLOCK_HEADER);
var
  name:string;
begin
  BITCODE_T2Text(PDWGBlock_Header^.name,DWGContext,name);
  zDebugLn(['{WH}BlockHeader: ',name]);
end;

procedure AddBlock(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PDWGBlock_Header:PDwg_Object_BLOCK_HEADER);
var
  name:string;
begin
  BITCODE_T2Text(PDWGBlock_Header^.name,DWGContext,name);
  zDebugLn(['{WH}Block: ',name]);
end;

procedure AddLineEntity(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PLine:PDwg_Entity_LINE);
var
  pobj:PGDBObjEntity;
begin
  pobj := AllocAndInitLine(ZContext.PDrawing^.pObjRoot);
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.x:=PLine^.start.x;
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.y:=PLine^.start.y;
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.z:=PLine^.start.x;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.x:=PLine^.&end.x;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.y:=PLine^.&end.y;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.z:=PLine^.&end.x;
  ZContext.PDrawing^.pObjRoot^.AddMi(@pobj);
  //PGDBObjEntity(pobj)^.BuildGeometry(drawing);
  //PGDBObjEntity(pobj)^.formatEntity(drawing,dc);
end;

procedure AddCircleEntity(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PCircle:PDwg_Entity_CIRCLE);
var
  pobj:PGDBObjEntity;
begin
  pobj := AllocAndInitCircle(ZContext.PDrawing^.pObjRoot);
  PGDBObjCircle(pobj)^.Local.p_insert.x:=PCircle^.center.x;
  PGDBObjCircle(pobj)^.Local.p_insert.y:=PCircle^.center.y;
  PGDBObjCircle(pobj)^.Local.p_insert.z:=PCircle^.center.z;
  PGDBObjCircle(pobj)^.Radius:=PCircle^.radius;
  ZContext.PDrawing^.pObjRoot^.AddMi(@pobj);
end;

procedure Add3DPolylineEntity(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PPolyline:PDwg_Entity_POLYLINE_3D);
var
  pobj:PGDBObjEntity;
  i:integer;
  v:GDBVertex;
begin
  pobj := AllocAndInitPolyline(ZContext.PDrawing^.pObjRoot);
  if PPolyline^.num_owned>0 then begin
    for i:=0 to PPolyline^.num_owned-1 do begin
      v.x:=PPolyline^.vertices[i]^.point.x;
      v.y:=PPolyline^.vertices[i]^.point.y;
      v.z:=PPolyline^.vertices[i]^.point.z;
      PGDBObjPolyline(pobj)^.VertexArrayInOCS.PushBack(v);
    end;
  end;
  PGDBObjPolyline(pobj)^.Closed:=(PPolyline^.flag and 1)=1;
  ZContext.PDrawing^.pObjRoot^.AddMi(@pobj);
end;

procedure AddLWPolylineEntity(var ZContext:TZDrawingContext;var DWGContext:TDWGCtx;var DWGObject:Dwg_Object;PLWPolyline:PDwg_Entity_LWPOLYLINE);
var
  pobj:PGDBObjEntity;
  i:integer;
  v2d:GDBvertex2D;
begin
  pobj := AllocAndInitLWpolyline(ZContext.PDrawing^.pObjRoot);
  if PLWPolyline^.num_points>0 then begin
    for i:=0 to PLWPolyline^.num_points-1 do begin
      v2d.x:=PLWPolyline^.points[i].x;
      v2d.y:=PLWPolyline^.points[i].y;
      PGDBObjLWPolyline(pobj)^.Vertex2D_in_OCS_Array.PushBack(v2d);
    end;
  end;
  PGDBObjLWPolyline(pobj)^.Closed:=(PLWPolyline^.flag and 1)=1;
  ZContext.PDrawing^.pObjRoot^.AddMi(@pobj);
end;

initialization
  ZCDWGParser.RegisterDWGObjectLoadProc(DWG_TYPE_LAYER,@AddLayer);
  ZCDWGParser.RegisterDWGObjectLoadProc(DWG_TYPE_LTYPE,@AddLineType);
  ZCDWGParser.RegisterDWGObjectLoadProc(DWG_TYPE_BLOCK_HEADER,@AddBlockHeader);

  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_LINE,@AddLineEntity);
  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_CIRCLE,@AddCircleEntity);
  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_POLYLINE_3D,@Add3DPolylineEntity);
  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_LWPLINE,@AddLWPolylineEntity);
  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_BLOCK,@AddBlock);
finalization
end.
