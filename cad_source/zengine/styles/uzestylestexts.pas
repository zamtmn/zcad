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

unit uzestylestexts;
{$INCLUDE def.inc}
interface
uses LCLProc,uzbpaths,uzefontmanager,uzbtypesbase,sysutils,uzbtypes,uzegeometry,
     uzbstrproc,uzefont,uzestrconsts,UGDBNamedObjectsArray,uzbmemman;
type
  //ptextstyle = ^textstyle;
{REGISTEROBJECTTYPE GDBTextStyleArray}
{EXPORT+}
PGDBTextStyleProp=^GDBTextStyleProp;
  GDBTextStyleProp=packed record
                    size:GDBDouble;(*saved_to_shd*)
                    oblique:GDBDouble;(*saved_to_shd*)
                    wfactor:GDBDouble;(*saved_to_shd*)
              end;
  PPGDBTextStyleObjInsp=^PGDBTextStyleObjInsp;
  PGDBTextStyleObjInsp=GDBPointer;
  PGDBTextStyle=^GDBTextStyle;
  GDBTextStyle = {$IFNDEF DELPHI}packed{$ENDIF}object(GDBNamedObject)
    dxfname: GDBAnsiString;(*saved_to_shd*)
    pfont: PGDBfont;
    prop:GDBTextStyleProp;(*saved_to_shd*)
    UsedInLTYPE:GDBBoolean;
    destructor Done;virtual;
  end;
PGDBTextStyleArray=^GDBTextStyleArray;
GDBTextStyleArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray{-}<PGDBTextStyle,GDBTextStyle>{//})(*OpenArrayOfData=GDBTextStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;

                    function addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp;USedInLT:GDBBoolean):PGDBTextStyle;
                    function setstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp;USedInLT:GDBBoolean):PGDBTextStyle;
                    function FindStyle(StyleName:GDBString;ult:GDBBoolean):PGDBTextStyle;
                    procedure freeelement(PItem:PT);virtual;
              end;
{EXPORT-}
implementation
destructor GDBTextStyle.Done;
begin
     inherited;
     dxfname:='';
end;
procedure GDBTextStyleArray.freeelement;
begin
  PGDBTextStyle(PItem).name:='';
  PGDBTextStyle(PItem).dxfname:='';
end;
constructor GDBTextStyleArray.initnul;
begin
  inherited initnul;
  //objsizeof:=sizeof(GDBTextStyle);
  //size:=sizeof(GDBTextStyle);
end;
constructor GDBTextStyleArray.init;
begin
  //Size := sizeof(GDBTextStyle);
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m{,sizeof(GDBTextStyle)});
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
function GDBTextStyleArray.setstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp;USedInLT:GDBBoolean):PGDBTextStyle;
var
   ps:PGDBTextStyle;
begin
  ps:=(FindStyle(StyleName,USedInLT));
  ps.name:=stylename;
  ps.dxfname:=FontFile;
  ps.UsedInLTYPE:=USedInLT;

  if pos('.',FontFile)=0 then
                             FontFile:=FontFile+'.shx';

  ps.pfont:=FontManager.addFonf(FindInPaths(sysvarPATHFontsPath,FontFile));
  if not assigned(ps.pfont) then
                                begin
                                     debugln('{WHM}'+fontnotfoundandreplace,[Tria_AnsiToUtf8(stylename),FontFile]);
                                     ps.pfont:=pbasefont;
                                end;

  //ps.pfont:=FontManager.addFonf(FontFile);
  //ps.pfont:=FontManager.{FindFonf}getAddres(FontFile);
  //if ps.pfont=nil then ps.pfont:=FontManager.getAddres('normal.shx');
  ps.prop:=tp;
  result:=ps;
  //result:=add(@ts);
  //pointer(ts.name):=nil;
  //pointer(ts.dxfname):=nil;
end;
function GDBTextStyleArray.addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp;USedInLT:GDBBoolean):{GDBInteger}PGDBTextStyle;
var ts:PGDBTextStyle;
    //ff:gdbstring;
    //p:GDBPointer;
begin
  GDBGetmem({$IFDEF DEBUGBUILD}'{ED59B789-33EF-487E-9E1D-711F5988A194}',{$ENDIF}pointer(ts),sizeof(GDBTextStyle));
  ts.init(stylename);
  //ts.name:=stylename;
  ts.dxfname:=FontFile;
  ts.UsedInLTYPE:=USedInLT;

  if pos('.',FontFile)=0 then
                             FontFile:=FontFile+'.shx';

  ts.pfont:=FontManager.addFonf(FindInPaths(sysvarPATHFontsPath,FontFile));
  if not assigned(ts.pfont) then
                                begin
                                     debugln('{WHM}'+fontnotfoundandreplace,[Tria_AnsiToUtf8(stylename),FontFile]);
                                     ts.pfont:=pbasefont;
                                end;

  //ts.pfont:=FontManager.addFonf(FontFile);
  //ts.pfont:=FontManager.{FindFonf}getAddres(FontFile);
  //if ts.pfont=nil then ts.pfont:=FontManager.getAddres('normal.shx');
  ts.prop:=tp;
  result:=pointer(getDataMutable(PushBackData(ts)));
  //pointer(ts.name):=nil;
  //pointer(ts.dxfname):=nil;
end;
function GDBTextStyleArray.FindStyle;
begin

  result:=getAddres(stylename);
  if result<>nil then
                  if result^.UsedInLTYPE<>ult then
                                               result:=nil;
  {StyleName:=uppercase(StyleName);
  result:=nil;
  if count=0 then exit;
  result:=parray;
  for i:=0 to count-1 do
  begin
        if (uppercase(result^.name)=stylename)and(result^.UsedInLTYPE=ult) then begin
                                       result:=result;
                                       exit;
                                  end;
       inc(result);
  end;}
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
end.
