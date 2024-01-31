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

unit uzeffttf;
{$INCLUDE zengineconfig.inc}
interface
uses uzefontmanager,EasyLazFreeType,uzefontttf,uzegeometry,
    uzefont,uzbstrproc,{$IFNDEF DELPHI}FileUtil,LCLProc,{$ENDIF}sysutils,
    uzctnrVectorBytes,uzefontttfpreloader;
type ptsyminfo=^tsyminfo;
     tsyminfo=record
                           number,size:word;
                     end;
function createnewfontfromttf(name:String;var pf:PGDBfont):Boolean;

implementation

function CreateTTFFontInstance:PTTFFont;
begin
     Getmem(result,sizeof(TTFFont));
     result^.init;
end;
function createnewfontfromttf(name:String;var pf:PGDBfont):Boolean;
var
  i:integer;
  chcode:integer;
  pttf:PTTFFont;
  si:TTTFSymInfo;
  TTFFileParams:TTTFFileParams;
begin
  TTFFileParams:=uzefontttfpreloader.getTTFFileParams(name);
  initfont(pf,extractfilename(name));
  pf^.fontfile:=name;
  pf^.font:=CreateTTFFontInstance;
  pttf:=pointer(pf^.font);
  result:=true;
  pttf^.ftFont.Hinted:=false;
  pttf^.ftFont.Name := name;
  pf^.family:=pttf^.ftFont.Information[ftiFamily];
  pf^.fullname:=pttf^.ftFont.Information[ftiFullName];

  pttf^.ftFont.TextWidth('');//It's just a guarantee font loading. I do not need to calculate the any width
  pttf^.ftFont.SizeInPoints:={pttf^.ftFont.SizeInPoints*10}10000;
  pf.font.unicode:=true;
  for i:=TTFFileParams.FirstCharIndex to TTFFileParams.LastCharIndex do begin
    chcode:=pttf^.ftFont.CharIndex[i];
    if chcode>0 then begin
      si.GlyphIndex:=chcode;
      si.PSymbolInfo:=nil;
      pttf^.MapChar.Insert(i,si);
    end;
  end;
end;
initialization
  RegisterFontLoadProcedure('ttf','TTF font',@createnewfontfromttf);
end.
