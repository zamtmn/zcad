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

unit uzeFFTTF;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzefontmanager,uzeFontFileFormatTTF,uzefont,
  {$IFNDEF DELPHI}FileUtil,LCLProc,{$ENDIF}sysutils,uzctnrVectorBytesStream,
  uzefontttfpreloader,uzeFontFileFormatTTFBackend;
type
  ptsyminfo=^tsyminfo;
  tsyminfo=record
    number,size:word;
  end;
function CreateNewfontFromTTF(const name:String;var pf:PGDBfont):Boolean;

implementation

function CreateNewfontFromTTF(const name:String;var pf:PGDBfont):Boolean;
var
  i:integer;
  chcode:integer;
  ttf:TZETFFFontImpl;
  si:TTTFSymInfo;
  TTFFileParams:TTTFFileParams;
begin
  TTFFileParams:=uzefontttfpreloader.getTTFFileParams(name);
  initfont(pf,extractfilename(name));
  pf^.fontfile:=name;
  pf^.font:=TZETFFFontImpl.Create;
  ttf:=pointer(pf^.font);
  result:=true;
  ttf.TTFImpl.Hinted:=false;
  ttf.TTFImpl.LoadFile(name);
  pf^.family:=ttf.TTFImpl.Family;
  pf^.fullname:=ttf.TTFImpl.FullName;

  //символ для замены отсутствующих символов
  ttf.DefaultChar:=TTFFileParams.DefaultChar;

  //символ 0 с глифом 0 на случай если DefaultChar врет
  si.GlyphIndex:=0;
  si.PSymbolInfo:=nil;
  ttf.MapChar.Insert(0,si);

  ttf.TTFImpl.SizeInPoints:=CTTFDefaultSizeInPoints;
  for i:=TTFFileParams.FirstCharIndex to TTFFileParams.LastCharIndex do begin
    chcode:=ttf.TTFImpl.CharIndex[i];
    if chcode>0 then begin
      si.GlyphIndex:=chcode;
      si.PSymbolInfo:=nil;
      ttf.MapChar.Insert(i,si);
    end;
  end;
end;
initialization
  RegisterFontLoadProcedure('ttf','TTF font',@createnewfontfromttf);
end.
