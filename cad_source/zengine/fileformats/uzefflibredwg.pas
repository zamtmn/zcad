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

unit uzeffLibreDWG;
{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
interface
uses
  LCLProc,
  SysUtils,
  dwg,
  uzeffmanager,uzeentgenericsubentry,uzbtypes,uzedrawingsimple,
  uzelongprocesssupport,uzeentline,uzeentity,uzgldrawcontext,
  gzctnrSTL;
type
  TDWGObjectLoadProc=procedure(owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing;var DC:TDrawContext;var dwg:Dwg_Data; var DWGObject:Dwg_Object);
procedure addfromdwg(filename:String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
implementation

type
  PTDWGObjectData=^TDWGObjectData;
  TDWGObjectData=record
    LP:TDWGObjectLoadProc;
    procedure Create;
  end;
  TDWGObjectsDataDic=specialize GKey2DataMap<DWG_OBJECT_TYPE,TDWGObjectData>;

var
  DWGObjectsDataDic:TDWGObjectsDataDic=nil;
procedure TDWGObjectData.Create;
begin
  LP:=nil;
end;
procedure RegisterDWGObjectLoadProc(const DOT:DWG_OBJECT_TYPE;const LP:TDWGObjectLoadProc);
var
  pdod:PTDWGObjectData;
  dod:TDWGObjectData;
begin
  if DWGObjectsDataDic=nil then
    DWGObjectsDataDic:=TDWGObjectsDataDic.Create;
  if DWGObjectsDataDic.MyGetMutableValue(DOT,pdod) then begin
    if pdod^.LP<>nil then
      raise Exception.Create(format('DWGObjectData.LP already registred for %d',[DOT]))
    else
      pdod^.LP:=LP;
  end else begin
    dod.Create;
    dod.LP:=LP;
    DWGObjectsDataDic.RegisterKey(DOT,dod);
  end;
end;
procedure AddLineEntity(owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing;var DC:TDrawContext;var dwg:Dwg_Data; var DWGObject:Dwg_Object);
var
  pobj:PGDBObjEntity;
begin
  pobj := AllocAndInitLine(drawing.pObjRoot);
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.x:=DWGObject.tio.entity^.tio.line^.start.x;
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.y:=DWGObject.tio.entity^.tio.line^.start.y;
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.z:=DWGObject.tio.entity^.tio.line^.start.x;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.x:=DWGObject.tio.entity^.tio.line^.&end.x;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.y:=DWGObject.tio.entity^.tio.line^.&end.y;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.z:=DWGObject.tio.entity^.tio.line^.&end.x;
  drawing.pObjRoot^.AddMi(@pobj);
  PGDBObjEntity(pobj)^.BuildGeometry(drawing);
  PGDBObjEntity(pobj)^.formatEntity(drawing,dc);
end;

procedure parseDwg_Data(owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing;var dwg:Dwg_Data);
var
  i:BITCODE_BL;
  lph:TLPSHandle;
  pobj:PGDBObjEntity;
  DC:TDrawContext;
  pdod:PTDWGObjectData;
begin
  lph:=lps.StartLongProcess('Create entinies',nil,dwg.num_objects);
  DC:=drawing.CreateDrawingRC;
  if DWGObjectsDataDic<>nil then begin
    for i := 0 to dwg.num_objects do begin
      if DWGObjectsDataDic.MyGetMutableValue(dwg.&object[i].fixedtype,pdod) then begin
        if pdod^.LP<>nil then
          pdod^.LP(owner,LoadMode,drawing,DC,dwg,dwg.&object[i]);
      end;
      {case dwg.&object[i].fixedtype of
        DWG_TYPE_LAYER:begin
        end;
        DWG_TYPE_Line:begin
          pobj := AllocAndInitLine(drawing.pObjRoot);
          PGDBObjLine(pobj)^.CoordInOCS.lBegin.x:=dwg.&object[i].tio.entity^.tio.line^.start.x;
          PGDBObjLine(pobj)^.CoordInOCS.lBegin.y:=dwg.&object[i].tio.entity^.tio.line^.start.y;
          PGDBObjLine(pobj)^.CoordInOCS.lBegin.z:=dwg.&object[i].tio.entity^.tio.line^.start.x;
          PGDBObjLine(pobj)^.CoordInOCS.lEnd.x:=dwg.&object[i].tio.entity^.tio.line^.&end.x;
          PGDBObjLine(pobj)^.CoordInOCS.lEnd.y:=dwg.&object[i].tio.entity^.tio.line^.&end.y;
          PGDBObjLine(pobj)^.CoordInOCS.lEnd.z:=dwg.&object[i].tio.entity^.tio.line^.&end.x;
          drawing.pObjRoot^.AddMi(@pobj);
          PGDBObjEntity(pobj)^.BuildGeometry(drawing);
          PGDBObjEntity(pobj)^.formatEntity(drawing,dc);
        end;
      end;}
      lps.ProgressLongProcess(lph,i);
    end;
  end;
  lps.EndLongProcess(lph);
end;

procedure addfromdwg(filename:String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  dwg:Dwg_Data;
  Success:integer;
  lph:TLPSHandle;
begin
  try
    DebugLn('{WH}LibreDWG: Not yet implement');
    try
      LoadLibreDWG;
    except
      on E : Exception do begin
        debugln('{EHM}LibreDWG: ',E.Message);
        exit;
      end;
    end;
    fillchar(dwg,sizeof(dwg),0);
    dwg.opts:=0;
    DebugLn(['{WH}try load file: ',ansistring(filename)]);
    lph:=lps.StartLongProcess('LibreDWG.dwg_read_file',nil);
    Success:=dwg_read_file(pchar(ansistring(filename)),@dwg);
    lps.EndLongProcess(lph);
    DebugLn(['{WH}Success: ',Success]);
    {DebugLn(['{WH}header.version: ',dwg.header.version]);
    DebugLn(['{WH}header.from_version: ',dwg.header.from_version]);
    DebugLn(['{WH}header.zero_5[0]: ',dwg.header.zero_5[0]]);
    DebugLn(['{WH}header.zero_5[1]: ',dwg.header.zero_5[1]]);
    DebugLn(['{WH}header.zero_5[2]: ',dwg.header.zero_5[2]]);
    DebugLn(['{WH}header.zero_5[3]: ',dwg.header.zero_5[3]]);
    DebugLn(['{WH}header.zero_5[4]: ',dwg.header.zero_5[4]]);
    DebugLn(['{WH}header.is_maint: ',dwg.header.is_maint]);
    DebugLn(['{WH}header.zero_one_or_three: ',dwg.header.zero_one_or_three]);
    DebugLn(['{WH}header.unknown_3: ',dwg.header.unknown_3]);
    DebugLn(['{WH}header.numheader_vars: ',dwg.header.numheader_vars]);
    DebugLn(['{WH}header.thumbnail_address: ',dwg.header.thumbnail_address]);
    DebugLn(['{WH}header.dwg_version: ',dwg.header.dwg_version]);
    DebugLn(['{WH}header.maint_version: ',dwg.header.maint_version]);
    DebugLn(['{WH}header.codepage: ',dwg.header.codepage]);}

    parseDwg_Data(owner,LoadMode,drawing,dwg);
    dwg_free(@dwg);
  finally
  end;
end;
initialization
  Ext2LoadProcMap.RegisterExt('dwg','AutoCAD DWG files via LibreDWG (*.dwg)',@addfromdwg);
  RegisterDWGObjectLoadProc(DWG_TYPE_Line,@AddLineEntity);
  //nExt2LoadProcMap.RegisterExt('dxf','AutoCAD DXF files via LibreDWG (*.dxf)',@addfromdwg);
finalization
  if assigned(DWGObjectsDataDic)then
    FreeAndNil(DWGObjectsDataDic);
end.
