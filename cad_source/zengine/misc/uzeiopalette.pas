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

unit uzeiopalette;
{$INCLUDE def.inc}
interface
uses uzbpaths,uzepalette,uzcstrconsts,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,{$IFNDEF DELPHI}FileUtil,LCLProc,{$ENDIF}{log,}sysutils,
     UGDBOpenArrayOfByte,uzbtypesbase,uzbtypes;
procedure readpalette(filename:string);
implementation
procedure readpalette;
var
  i,code:GDBInteger;
  line,sub:GDBString;
  f:GDBOpenArrayOfByte;
begin
  f.InitFromFile(ProgramPath+filename);
  while f.notEOF do
    begin
      line:=f.readGDBString;
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
