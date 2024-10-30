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
  uzbLogIntf, LazLoggerBase,
  SysUtils,
  dwg,dwgproc,
  uzeffmanager,
  uzelongprocesssupport,{uzgldrawcontext,}forms,
  uzcstrconsts,uzeLogIntf,
  LazUTF8;

type

  TZCADDWGParser=specialize GDWGParser<TZDrawingContext>;

var
  ZCDWGParser:TZCADDWGParser=nil;

implementation

procedure DebugDWG(dwg:PDwg_Data);
begin
  DebugLn(['{WH}header.version: '+DWG_V2Str(dwg^.header.version)]);
  zDebugLn(['{WH}header.from_version: ',DWG_V2Str(dwg^.header.from_version)]);
  if (dwg^.header.zero_5[0]=0)and(dwg^.header.zero_5[1]=0)and(dwg^.header.zero_5[2]=0)and(dwg^.header.zero_5[3]=0)and(dwg^.header.zero_5[4]=0)then
    zDebugLn(['{WH}header.zero_5: 0,0,0,0,0'])
  else
    zDebugLn(['{WHM}header.zero_5: ',dwg^.header.zero_5[0],',',dwg^.header.zero_5[1],',',dwg^.header.zero_5[2],',',dwg^.header.zero_5[3],',',dwg^.header.zero_5[4]]);
  zDebugLn(['{WH}header.is_maint: ',dwg^.header.is_maint]);
  zDebugLn(['{WH}header.zero_one_or_three: ',dwg^.header.zero_one_or_three]);
  zDebugLn(['{WH}header.unknown_3: ',dwg^.header.unknown_3]);
  zDebugLn(['{WH}header.numheader_vars: ',dwg^.header.numheader_vars]);
  zDebugLn(['{WH}header.thumbnail_address: ',dwg^.header.thumbnail_address]);
  zDebugLn(['{WH}header.dwg_version: ',dwg^.header.dwg_version]);
  zDebugLn(['{WH}header.maint_version: ',dwg^.header.maint_version]);
  zDebugLn(['{WH}header.codepage: ',dwg^.header.codepage]);
end;

procedure PLP(const Data:TData;const Counter:TCounter);
begin
 lps.ProgressLongProcess(TLPSHandle(Data),Counter);
end;

procedure addfromdwg(const filename:String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
var
  dwg:Dwg_Data;
  Success:integer;
  lph:TLPSHandle;
  //DC:TDrawContext;
begin
  try
    zDebugLn('{WH}%s',[rsNotYetImplemented]);
    try
      LoadLibreDWG;
    except
      on E : Exception do begin
        zDebugLn(['{EHM}LibreDWG: ',E.Message]);
        exit;
      end;
    end;
    fillchar(dwg,sizeof(dwg),0);
    dwg.opts:=0;
    zDebugLn(['{WH}try load file: ',ansistring(filename)]);
    lph:=lps.StartLongProcess('LibreDWG.dwg_read_file',nil);
    {$IFDEF WINDOWS}
    Success:=dwg_read_file(pchar(UTF8ToWinCP(filename)),@dwg);
    {$ELSE WINDOWS}
    Success:=dwg_read_file(pchar(ansistring(filename)),@dwg);
    {$ENDIF}
    lps.EndLongProcess(lph);
    zDebugLn(['{WH}Success: ',Success]);
    DebugDWG(@dwg);
    lph:=lps.StartLongProcess('Parse DWG data',nil,dwg.num_objects);
    ZCDWGParser.parseDwg_Data(ZCDCtx,dwg,@PLP,pointer(lph));
    lps.EndLongProcess(lph);
    dwg_free(@dwg);
  finally
  end;
end;
procedure addfromdxf(const filename:String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
var
  dwg:Dwg_Data;
  Success:integer;
  lph:TLPSHandle;
  //DC:TDrawContext;
begin
  try
    zDebugLn('{WH}%s',[rsNotYetImplemented]);
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
    zDebugLn(['{WH}try load file: ',ansistring(filename)]);
    lph:=lps.StartLongProcess('LibreDWG.dxf_read_file',nil);
    Success:=dxf_read_file(pchar(ansistring(filename)),@dwg);
    lps.EndLongProcess(lph);
    zDebugLn(['{WH}Success: ',Success]);
    DebugDWG(@dwg);
    lph:=lps.StartLongProcess('Parse DWG data',nil,dwg.num_objects);
    ZCDWGParser.parseDwg_Data(ZCDCtx,dwg,@PLP,pointer(lph));
    lps.EndLongProcess(lph);
    dwg_free(@dwg);
  finally
  end;
end;

initialization
  ZCDWGParser:=TZCADDWGParser.Create;

  Ext2LoadProcMap.RegisterExt('dwg','AutoCAD DWG files via LibreDWG (*.dwg)',@addfromdwg);
  Ext2LoadProcMap.RegisterExt('dxf','AutoCAD DXF files via LibreDWG (*.dxf)',@addfromdxf);
finalization
  if assigned(ZCDWGParser)then
    FreeAndNil(ZCDWGParser);
end.
