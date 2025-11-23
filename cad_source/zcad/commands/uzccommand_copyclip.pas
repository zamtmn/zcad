{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
{$mode delphi}
unit uzcCommand_CopyClip;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  SysUtils,
  LCLType,LazUTF8,Clipbrd,
  uzbpaths,
  uzeentity,
  uzeffdxf,uzeffdxfsupport,
  gzctnrVectorTypes,
  uzgldrawcontext,
  uzcdrawings,
  uzccommandsabstract,uzccommandsimpl,
  uzegeometry,uzegeometrytypes,uzcCommand_Duplicate,
  uzcFileStructure;

const
  ZCAD_DXF_CLIPBOARD_NAME='DXF2000@ZCADv0.9';

procedure ReCreateClipboardDWG;
procedure CopyToClipboard;
function CopyClip_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;

implementation

var
  CopyClipFile:ansistring;

procedure CopyToClipboard;
var
  s:ansistring;
  suni:unicodestring;
  zcformat:TClipboardFormat;
begin
  if fileexists(utf8tosys(CopyClipFile)) then
    SysUtils.deletefile(CopyClipFile);
  s:=GetTempFileName(GetTempPath,'Z$C','dxf');
  //s:=GetTempPath+'Z$C'+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)
  //   +inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+'.dxf';
  CopyClipFile:=s;
  savedxf2000(s,ConcatPaths([GetRoCfgsPath,CFScomponentsDir,CFSemptydxfFile]),
    ClipboardDWG^,ZCCodePage2SysCP(drawings.GetCurrentDwg^.DXFCodePage));
  s:=s+#0;
  suni:=unicodestring(s);
  Clipboard.Open;
  Clipboard.Clear;
  zcformat:=RegisterClipboardFormat(ZCAD_DXF_CLIPBOARD_NAME);
  clipboard.AddFormat(zcformat,s[1],length(s));

  zcformat:=RegisterClipboardFormat('AutoCAD.r16');
  clipboard.AddFormat(zcformat,s[1],length(s)*sizeof(s[1]));

  zcformat:=RegisterClipboardFormat('AutoCAD.r18');
  clipboard.AddFormat(zcformat,suni[1],length(suni)*sizeof(suni[1]));
  Clipboard.Close;
end;

procedure ReCreateClipboardDWG;
begin
  if ClipboardDWG<>nil then begin
    ClipboardDWG.done;
    Freemem(ClipboardDWG);
  end;
  ClipboardDWG:=drawings.CreateDWG('$(DistribPath)/rtl/dwg/DrawingVars.pas','');
  //ClipboardDWG.DimStyleTable.AddItem('Standart',pds);
end;

function CopyClip_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pobj,pobjcopy:pGDBObjEntity;
  ir:itrec;
  DC:TDrawContext;
  SelectedAABB:TBoundingBox;
  m:TzeTypedMatrix4d;
begin
  ClipboardDWG.pObjRoot.ObjArray.Free;
  dc:=drawings.GetCurrentDwg^.CreateDrawingRC(False,[DCODrawable]);

  if GetSelectedEntsAABB(drawings.GetCurrentROOT.ObjArray,SelectedAABB) then begin
    ReCreateClipboardDWG;
    m:=CreateTranslationMatrix(-SelectedAABB.LBN{-(SelectedAABB.RTF+SelectedAABB.LBN)/2});
    pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pobj<>nil then
      repeat
        if pobj.selected then begin
          pobjcopy:=drawings.CopyEnt(drawings.GetCurrentDWG,ClipboardDWG,pobj);
          pobjcopy^.Formatentity(drawings.GetCurrentDWG^,dc);
          pobjcopy^.transform(m);
          //pobjcopy^.Formatentity(drawings.GetCurrentDWG^,dc);
        end;
        pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pobj=nil;
    copytoclipboard;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CopyClipFile:='Empty';
  CreateZCADCommand(@Copyclip_com,'CopyClip',CADWG or CASelEnts,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
