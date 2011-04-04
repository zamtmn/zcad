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

unit UGDBTextStyleArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,SysInfo,UGDBOpenArrayOfData, {oglwindowdef,}sysutils,gdbase, geometry,
     gl,strproc,varmandef,shared,UGDBSHXFont;
type
  //ptextstyle = ^textstyle;
{EXPORT+}
PGDBTextStyleProp=^GDBTextStyleProp;
  GDBTextStyleProp=record
                    size:GDBDouble;(*saved_to_shd*)
                    oblique:GDBDouble;(*saved_to_shd*)
                    wfactor:GDBDouble;(*saved_to_shd*)
              end;
  PGDBTextStyle=^GDBTextStyle;
  GDBTextStyle = record
    name: GDBAnsiString;(*saved_to_shd*)
    dxfname: GDBAnsiString;(*saved_to_shd*)
    pfont: PGDBfont;
    prop:GDBTextStyleProp;(*saved_to_shd*)
  end;
GDBTextStyleArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBTextStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;

                    function addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
                    function setstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
                    function FindStyle(StyleName:GDBString):GDBInteger;
                    procedure freeelement(p:GDBPointer);virtual;
              end;
{EXPORT-}
implementation
uses UGDBDescriptor,io,log;
procedure GDBTextStyleArray.freeelement;
begin
  PGDBTextStyle(p).name:='';
  PGDBTextStyle(p).dxfname:='';
end;
constructor GDBTextStyleArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBTextStyle);
end;
constructor GDBTextStyleArray.init;
begin
  //Size := sizeof(GDBTextStyle);
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBTextStyle));
  //addlayer('0',cgdbwhile,lwgdbdefault);
end;

{procedure GDBLayerArray.clear;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     if count>0 then
     begin
          tlp:=parray;
          for i:=0 to count-1 do
          begin
               tlp^.name:='';
               inc(tlp);
          end;
     end;
  count:=0;
end;}
{function GDBLayerArray.getLayerIndex(name: GDBString): GDBInteger;
var
  i: GDBInteger;
begin
  result := 0;
  for i := 0 to count - 1 do
    if PGDBLayerPropArray(Parray)^[i].name = name then
    begin
      result := i;
      exit;
    end;
end;}
function GDBTextStyleArray.setstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
var ts:GDBTextStyle;
    ff:gdbstring;
    ps:PGDBTextStyle;
    //p:GDBPointer;
begin
  ts.name:=stylename;
  ts.dxfname:=FontFile;

  if pos('.',FontFile)=0 then
                             FontFile:=FontFile+'.shx';

  ts.pfont:=FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,FontFile));
  if not assigned(ts.pfont) then
                                begin
                                     shared.LogError('Для стиля "'+Tria_AnsiToUtf8(stylename)+'" не найден шрифт "'+FontFile+'", заменен на альтернативный');
                                     ts.pfont:=pbasefont;
                                end;

  //ts.pfont:=FontManager.addFonf(FontFile);
  //ts.pfont:=FontManager.{FindFonf}getAddres(FontFile);
  //if ts.pfont=nil then ts.pfont:=FontManager.getAddres('normal.shx');
  ts.prop:=tp;
  //result:=add(@ts);
  ps:=getelement(FindStyle(StyleName));
  ps^:=ts;
  //pointer(ts.name):=nil;
  //pointer(ts.dxfname):=nil;
end;
function GDBTextStyleArray.addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
var ts:GDBTextStyle;
    ff:gdbstring;
    //p:GDBPointer;
begin
  ts.name:=stylename;
  ts.dxfname:=FontFile;

  if pos('.',FontFile)=0 then
                             FontFile:=FontFile+'.shx';

  ts.pfont:=FontManager.addFonf(FindInPaths(sysvar.PATH.Fonts_Path^,FontFile));
  if not assigned(ts.pfont) then
                                begin
                                     shared.LogError('Для стиля "'+Tria_AnsiToUtf8(stylename)+'" не найден шрифт "'+FontFile+'", заменен на альтернативный');
                                     ts.pfont:=pbasefont;
                                end;

  //ts.pfont:=FontManager.addFonf(FontFile);
  //ts.pfont:=FontManager.{FindFonf}getAddres(FontFile);
  //if ts.pfont=nil then ts.pfont:=FontManager.getAddres('normal.shx');
  ts.prop:=tp;
  result:=add(@ts);
  pointer(ts.name):=nil;
  pointer(ts.dxfname):=nil;
end;
function GDBTextStyleArray.FindStyle;
var
  pts:pGDBTextStyle;
  i:GDBInteger;
begin
  StyleName:=uppercase(StyleName);
  result:=-1;
  if count=0 then exit;
  pts:=parray;
  for i:=0 to count-1 do
  begin
       if uppercase(pts^.name)=stylename then begin
                                       result:=i;
                                       exit;
                                  end;
       inc(pts);
  end;
end;

{function GDBLayerArray.CalcCopactMemSize2;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     result:=0;
     objcount:=count;
     if count=0 then exit;
     result:=result;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          result:=result+sizeof(GDBByte)+sizeof(GDBSmallint)+sizeof(GDBWord)+length(tlp^.name);
          inc(tlp);
     end;
end;
function GDBLayerArray.SaveToCompactMemSize2;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     result:=0;
     if count=0 then exit;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          PGDBByte(pmem)^:=tlp^.color;
          inc(PGDBByte(pmem));
          PGDBSmallint(pmem)^:=tlp^.lineweight;
          inc(PGDBSmallint(pmem));
          PGDBWord(pmem)^:=length(tlp^.name);
          inc(PGDBWord(pmem));
          Move(GDBPointer(tlp.name)^, pmem^,length(tlp.name));
          inc(PGDBByte(pmem),length(tlp.name));
          inc(tlp);
     end;
end;
function GDBLayerArray.LoadCompactMemSize2;
begin
     {inherited LoadCompactMemSize(pmem);
     Coord:=PGDBLineProp(pmem)^;
     inc(PGDBLineProp(pmem));
     PProjPoint:=nil;
     format;}
//end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBTextStyleArray.initialization');{$ENDIF}
end.
