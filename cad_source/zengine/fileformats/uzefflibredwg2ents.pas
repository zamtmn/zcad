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
  LCLProc,
  SysUtils,
  dwg,
  uzeentgenericsubentry,uzbtypes,uzedrawingsimple,
  uzbstrproc,
  uzestyleslayers,
  uzeentline,uzeentity,uzgldrawcontext,
  uzeffLibreDWG;
implementation
type
  PDwg_Entity_LINE=^Dwg_Entity_LINE;
  PDwg_Object_LAYER=^Dwg_Object_LAYER;

procedure AddLayer(var ZContext:TZDrawingContext;var DWGContext:TDWGContext;var DWGObject:Dwg_Object;PDWGLayer:PDwg_Object_LAYER);
var
  player:PGDBLayerProp;
  name:string;
begin
  BITCODE_T2Text(PDWGLayer^.name,DWGContext,name);
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
  (*      _dwg_object_LAYER = record
          {$define BITCODE_XXlaytype:=BITCODE_RC}
          COMMON_TABLE_FIELDS;
          {$undef BITCODE_XXlaytype}
          frozen : BITCODE_B;
          &on : BITCODE_B;
          frozen_in_new : BITCODE_B;
          locked : BITCODE_B;
          plotflag : BITCODE_B;
          linewt : BITCODE_RC;
          color : BITCODE_CMC;
          plotstyle : BITCODE_H;
          material : BITCODE_H;
          ltype : BITCODE_H;
          visualstyle : BITCODE_H;
        end;
  *)
end;

procedure AddLineEntity(var ZContext:TZDrawingContext;var DWGContext:TDWGContext;var DWGObject:Dwg_Object;PLine:PDwg_Entity_LINE);
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
  RegisterDWGObjectLoadProc(DWG_TYPE_Layer,@AddLayer);
  RegisterDWGEntityLoadProc(DWG_TYPE_Line,@AddLineEntity);
finalization
end.
