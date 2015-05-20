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

unit iottf;
{$INCLUDE def.inc}
interface
uses UGDBFontManager,EasyLazFreeType,ugdbttffont,geometry,{$IFNDEF DELPHI}intftranslations,{$ENDIF}
    ugdbfont,strproc,{$IFNDEF DELPHI}FileUtil,LCLProc,{$ENDIF}log,sysutils,
    UGDBOpenArrayOfByte,gdbasetypes,SysInfo,gdbase,memman;
type ptsyminfo=^tsyminfo;
     tsyminfo=packed record
                           number,size:word;
                     end;
function createnewfontfromttf(name:GDBString;var pf:PGDBfont):GDBBoolean;
implementation
uses
   shared;
function createnewfontfromttf(name:GDBString;var pf:PGDBfont):GDBBoolean;
var
   i:integer;
   chcode:integer;
   //k:gdbdouble;
   pttf:PTTFFont;
   si:TTTFSymInfo;
   Iterator:TMapChar.TIterator;
begin
    initfont(pf,extractfilename(name));
    pf^.fontfile:=name;
    pf.ItFFT;
    pttf:=pointer(pf^.font);
    result:=true;
    pttf^.ftFont.Hinted:=false;
    pttf^.ftFont.Name := name;
    pttf^.ftFont.TextWidth('');//It's just a guarantee font loading. I do not need to calculate the any width
    pttf^.ftFont.SizeInPoints:={pttf^.ftFont.SizeInPoints*10}10000;
    pf.font.unicode:=true;
    //k:=1;
    {$if FPC_FULlVERSION>=20701}
    //k:=1/pttf^.ftFont.CapHeight;
    {$ENDIF}
    for i:=0 to 65535 do
      begin
           chcode:=pttf^.ftFont.CharIndex[i];
           if chcode>0 then
                      begin
                           si.GlyphIndex:=chcode;
                           si.PSymbolInfo:=nil;
                           pttf^.MapChar.Insert(i,si);
                           //programlog.LogOutStr('TTF: Symbol index='+inttostr(si.GlyphIndex)+'; code='+inttostr(i),0);
                      end;
      end;
    {exit;}
    iterator:=pttf^.MapChar.Min;
    if assigned(iterator) then
    begin
    repeat
          si:=iterator.Value;
          chcode:=iterator.Key;

          cfeatettfsymbol(chcode,si,pttf);
          iterator.Value:=si;

    until {not iterator.next}true;
    iterator.Destroy;
    end;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('iottf.initialization');{$ENDIF}
  RegisterFontLoadProcedure('ttf','TTF font',@createnewfontfromttf);
end.
