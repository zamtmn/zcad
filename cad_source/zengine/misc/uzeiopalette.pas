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

unit uzeiopalette;
{$INCLUDE zengineconfig.inc}
interface
uses uzbpaths,uzepalette,uzcstrconsts,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,{$IFNDEF DELPHI}FileUtil,uzbLogIntf,{$ENDIF}{log,}sysutils,
     uzctnrVectorBytesStream,gstack;
type
  TPaletteStack=TStack<TGDBPalette>;
var
  PaletteStack:TPaletteStack=nil;
procedure readpalette(const filename:string);
procedure PushAndSetNewPalette(const NewPalette:TGDBPalette);
procedure PopPalette;
implementation
procedure PushAndSetNewPalette(const NewPalette:TGDBPalette);
begin
  if PaletteStack=nil then
    PaletteStack:=TPaletteStack.Create;
  PaletteStack.Push(palette);
  palette:=NewPalette;
end;
procedure PopPalette;
begin
  if PaletteStack<>nil then begin
    palette:=PaletteStack.Top;
    PaletteStack.Pop
  end else
    zDebugLn('{E}PopPalette: PaletteStack not created');
end;


procedure readpalette;
var
  i,code:Integer;
  line,sub:String;
  f:TZctnrVectorBytes;
begin
  f.InitFromFile(ConcatPaths([GetRoCfgsPath,filename]));
  while f.notEOF do
    begin
      line:=f.readString;
      if line<>'' then
      if line[1]<>';' then
        begin
          sub:=GetPredStr(line,'=');
          val(sub,i,code);

          sub:=GetPredStr(line,',');
          val(sub,palette[i].RGB.r,code);

          sub:=GetPredStr(line,',');
          val(sub,palette[i].RGB.g,code);

          sub:=GetPredStr(line,':');
          val(sub,palette[i].RGB.b,code);
          palette[i].RGB.a:=255;
          if line<>'' then
                          palette[i].name:={$IFNDEF DELPHI}InterfaceTranslate('rgbcolorname~'+line,{$ELSE}({$ENDIF}line)
                      else
                          palette[i].name:=format(rsColorNum,[i]);
        end;
    end;
  f.done;
end;
initialization
  readpalette('components/palette.rgb');
end.
