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
  uzeentgenericsubentry,uzedrawingsimple,
  uzbstrproc,
  uzestyleslayers,
  uzeentline,uzeentity,//uzgldrawcontext,
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

initialization
  ZCDWGParser.RegisterDWGObjectLoadProc(DWG_TYPE_LAYER,@AddLayer);
  ZCDWGParser.RegisterDWGObjectLoadProc(DWG_TYPE_LTYPE,@AddLineType);
  ZCDWGParser.RegisterDWGObjectLoadProc(DWG_TYPE_BLOCK_HEADER,@AddBlockHeader);

  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_LINE,@AddLineEntity);
  ZCDWGParser.RegisterDWGEntityLoadProc(DWG_TYPE_BLOCK,@AddBlock);
finalization
end.
