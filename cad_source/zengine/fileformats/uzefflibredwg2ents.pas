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
  uzeentline,uzeentity,uzgldrawcontext,
  uzeffLibreDWG;
implementation
type
  PDwg_Entity_LINE=^Dwg_Entity_LINE;
  PDwg_Object_LAYER=^Dwg_Object_LAYER;

procedure AddLayer(var ZContext:TZDrawingContext;var dwg:Dwg_Data; var DWGObject:Dwg_Object;PLayer:PDwg_Object_LAYER);
var
  pobj:PGDBObjEntity;
  b:boolean;
  name:string;
begin
  name:=pchar(PLayer^.name);
  name:=pchar(DWGObject.tio.&object^.tio.layer^.name);
  //b:=DWGObject.tio.&object^.tio.layer^.&on;
  //DWGObject.tio.&object^.tio.layer^.&on;
  pobj:=pobj;
end;

procedure AddLineEntity(var ZContext:TZDrawingContext;var dwg:Dwg_Data; var DWGObject:Dwg_Object;PLine:PDwg_Entity_LINE);
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
