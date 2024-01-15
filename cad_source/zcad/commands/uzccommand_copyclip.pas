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
unit uzccommand_copyclip;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  LCLType,LazUTF8,Clipbrd,
  uzbpaths,
  uzeentity,
  uzeffdxf,
  gzctnrVectorTypes,
  uzgldrawcontext,
  uzcdrawings,
  uzccommandsabstract,uzccommandsimpl;

const
  ZCAD_DXF_CLIPBOARD_NAME='DXF2000@ZCADv0.9';

procedure ReCreateClipboardDWG;
procedure CopyToClipboard;
function CopyClip_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

var
  CopyClipFile:AnsiString;

procedure CopyToClipboard;
var
  s:ansistring;
  suni:unicodestring;
  I:integer;
  zcformat:TClipboardFormat;
begin
  if fileexists(utf8tosys(CopyClipFile)) then
    SysUtils.deletefile(CopyClipFile);
  s:=temppath+'Z$C'+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)
     +inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+inttohex(random(15),1)+'.dxf';
  CopyClipFile:=s;
  savedxf2000(s,ProgramPath + 'components/empty.dxf',ClipboardDWG^);
  s:=s+#0;
  suni:=s;
  //setlength(suni,length(s)*2+2);
  //fillchar(suni[1],length(suni),0);
  //for I := 1 to length(s) do
  //  suni[i*2-1]:=s[i];
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
  ClipboardDWG:=drawings.CreateDWG('*rtl/dwg/DrawingVars.pas','');
  //ClipboardDWG.DimStyleTable.AddItem('Standart',pds);
end;

function CopyClip_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   pobj: pGDBObjEntity;
   ir:itrec;
   DC:TDrawContext;
   NeedReCreateClipboardDWG:boolean;
begin
   ClipboardDWG.pObjRoot.ObjArray.free;
   dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
   NeedReCreateClipboardDWG:=true;
   pobj:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
   if pobj<>nil then
   repeat
          begin
              if pobj.selected then
              begin
                   if NeedReCreateClipboardDWG then
                                                   begin
                                                        ReCreateClipboardDWG;
                                                        NeedReCreateClipboardDWG:=false;
                                                   end;
                drawings.CopyEnt(drawings.GetCurrentDWG,ClipboardDWG,pobj).Formatentity(drawings.GetCurrentDWG^,dc);
              end;
          end;
          pobj:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
   until pobj=nil;

   copytoclipboard;

   result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CopyClipFile:='Empty';
  CreateZCADCommand(@Copyclip_com,'CopyClip',CADWG or CASelEnts,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
