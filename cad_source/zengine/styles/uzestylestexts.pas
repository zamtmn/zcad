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
{$INCLUDE zengineconfig.inc}
interface
uses LCLProc,uzbpaths,uzefontmanager,sysutils,uzbtypes,uzegeometry,
     uzbstrproc,uzefont,uzestrconsts,UGDBNamedObjectsArray;
type
  //ptextstyle = ^textstyle;
{EXPORT+}
PGDBTextStyleProp=^GDBTextStyleProp;
{REGISTERRECORDTYPE GDBTextStyleProp}
  GDBTextStyleProp=record
                    size:Double;(*saved_to_shd*)
                    oblique:Double;(*saved_to_shd*)
                    wfactor:Double;(*saved_to_shd*)
              end;
  PPGDBTextStyleObjInsp=^PGDBTextStyleObjInsp;
  PGDBTextStyleObjInsp=Pointer;
  PGDBTextStyle=^GDBTextStyle;
  {REGISTEROBJECTTYPE GDBTextStyle}
  GDBTextStyle = object(GDBNamedObject)
    FontFile:String;(*saved_to_shd*)
    FontFamily:String;(*saved_to_shd*)
    pfont: PGDBfont;
    prop:GDBTextStyleProp;(*saved_to_shd*)
    UsedInLTYPE:Boolean;
    destructor Done;virtual;
  end;
PGDBTextStyleArray=^GDBTextStyleArray;
{REGISTEROBJECTTYPE GDBTextStyleArray}
GDBTextStyleArray= object(GDBNamedObjectsArray{-}<PGDBTextStyle,GDBTextStyle>{//})(*OpenArrayOfData=GDBTextStyle*)
                    constructor init(m:Integer);
                    constructor initnul;

                    function addstyle(StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean):PGDBTextStyle;
                    function setstyle(StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean):PGDBTextStyle;
                    procedure internalsetstyle(var style:GDBTextStyle;AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean);
                    function FindStyle(StyleName:String;ult:Boolean):PGDBTextStyle;
                    procedure freeelement(PItem:PT);virtual;
              end;
{EXPORT-}
implementation
destructor GDBTextStyle.Done;
begin
     inherited;
     FontFile:='';
end;
procedure GDBTextStyleArray.freeelement;
begin
  PGDBTextStyle(PItem).name:='';
  PGDBTextStyle(PItem).FontFile:='';
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
  inherited init(m);
  //addlayer('0',cgdbwhile,lwgdbdefault);
end;

{procedure GDBLayerArray.clear;
var i:Integer;
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
{function GDBLayerArray.getLayerIndex(name: String): Integer;
var
  i: Integer;
begin
  result := 0;
  for i := 0 to count - 1 do
    if PGDBLayerPropArray(Parray)^[i].name = name then
    begin
      result := i;
      exit;
    end;
end;}
procedure GDBTextStyleArray.internalsetstyle(var style:GDBTextStyle;AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean);
begin
  style.FontFile:=AFontFile;
  style.FontFamily:=AFontFamily;
  style.UsedInLTYPE:=USedInLT;

  {if pos('.',AFontFile)=0 then
                             AFontFile:=AFontFile+'.shx';}

  style.pfont:=FontManager.addFont(AFontFile,AFontFamily);
  if not assigned(style.pfont) then
    if USedInLT then
      debugln('{WHM}'+fontnotfound,[Tria_AnsiToUtf8(style.Name),AFontFile,AFontFamily])
    else begin
      debugln('{WHM}'+fontnotfoundandreplace,[Tria_AnsiToUtf8(style.Name),AFontFile,AFontFamily]);
      style.pfont:=pbasefont;
    end;
  style.prop:=tp;
end;

function GDBTextStyleArray.setstyle(StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean):PGDBTextStyle;
var
   ps:PGDBTextStyle;
begin
  ps:=(FindStyle(StyleName,USedInLT));
  result:=ps;
  if ps<>nil then
    internalsetstyle(ps^,AFontFile,AFontFamily,tp,USedInLT);
end;
function GDBTextStyleArray.addstyle(StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean):{Integer}PGDBTextStyle;
var ts:PGDBTextStyle;
begin
  Getmem(pointer(ts),sizeof(GDBTextStyle));
  ts.init(stylename);
  internalsetstyle(ts^,AFontFile,AFontFamily,tp,USedInLT);
  result:=pointer(getDataMutable(PushBackData(ts)));
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
var i:Integer;
    tlp:PGDBLayerProp;
begin
     result:=0;
     objcount:=count;
     if count=0 then exit;
     result:=result;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          result:=result+sizeof(Byte)+sizeof(SmallInt)+sizeof(Word)+length(tlp^.name);
          inc(tlp);
     end;
end;
function GDBLayerArray.SaveToCompactMemSize2;
var i:Integer;
    tlp:PGDBLayerProp;
begin
     result:=0;
     if count=0 then exit;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          PByte(pmem)^:=tlp^.color;
          inc(PByte(pmem));
          PGDBSmallint(pmem)^:=tlp^.lineweight;
          inc(PGDBSmallint(pmem));
          PGDBWord(pmem)^:=length(tlp^.name);
          inc(PGDBWord(pmem));
          Move(Pointer(tlp.name)^, pmem^,length(tlp.name));
          inc(PByte(pmem),length(tlp.name));
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
