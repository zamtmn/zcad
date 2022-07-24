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

unit uzeffLibreDWG;
{$INCLUDE zengineconfig.inc}
{$MODE OBJFPC}{$H+}
interface
uses
  LCLProc,
  SysUtils,
  dwg,
  uzeffmanager,uzeentgenericsubentry,uzbtypes,uzedrawingsimple,
  uzelongprocesssupport,uzeentline,uzeentity,uzgldrawcontext;
procedure addfromdwg(filename:String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
implementation
procedure addfromdwg(filename:String;owner:PGDBObjGenericSubEntry;LoadMode:TLoadOpt;var drawing:TSimpleDrawing);
var
  dwg:Dwg_Data;
  Success:integer;
  i:BITCODE_BL;
  tl:BITCODE_BS;
  lph:TLPSHandle;
  pobj:PGDBObjEntity;
  DC:TDrawContext;
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
    DebugLn('{WH}loaded!');
    DebugLn(['{WH}header.version: ',dwg.header.version]);
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
    DebugLn(['{WH}header.codepage: ',dwg.header.codepage]);

    lph:=lps.StartLongProcess('Create entinies',nil,dwg.num_objects);
    DC:=drawing.CreateDrawingRC;
    for i := 0 to dwg.num_objects do begin
      case dwg.&object[i].fixedtype of
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
      end;
      lps.ProgressLongProcess(lph,i);
    end;
    lps.EndLongProcess(lph);
    dwg_free(@dwg);
    FreeLibreDWG;
  finally
  end;
end;
begin
     Ext2LoadProcMap.RegisterExt('dwg','AutoCAD DWG files via LibreDWG (*.dwg)',@addfromdwg);
end.
