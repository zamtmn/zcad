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

unit uzestylestexts;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses LCLProc,uzbpaths,uzefontmanager,sysutils,uzbtypes,uzegeometry,
     uzbstrproc,uzefont,uzestrconsts,UGDBNamedObjectsArray,uzeNamedObject,
     uzeLogIntf;
type

  GDBTextStyleProp=record
    size:double;
    oblique:double;
    wfactor:double;
  end;
  PGDBTextStyleProp=^GDBTextStyleProp;

  PGDBTextStyleObjInsp=Pointer;
  PPGDBTextStyleObjInsp=^PGDBTextStyleObjInsp;

  GDBTextStyle=object(GDBNamedObject)
    FontFile:string;
    FontFamily:string;
    pfont:PGDBfont;
    prop:GDBTextStyleProp;
    UsedInLTYPE:boolean;
    destructor Done;virtual;
  end;
  PGDBTextStyle=^GDBTextStyle;




PGDBTextStyleArray=^GDBTextStyleArray;
GDBTextStyleArray= object(GDBNamedObjectsArray<PGDBTextStyle,GDBTextStyle>)
                    constructor init(m:Integer);
                    constructor initnul;

                    function addstyle(const StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean;const LogProc:TZELogProc=nil):PGDBTextStyle;
                    function setstyle(const StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean):PGDBTextStyle;
                    procedure internalsetstyle(var style:GDBTextStyle;const AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean;const LogProc:TZELogProc=nil);
                    function FindStyle(const StyleName:String;ult:Boolean):PGDBTextStyle;
                    procedure freeelement(PItem:PT);virtual;
                    function CorrectNilledTextStyle(pts:PGDBTextStyle):PGDBTextStyle;
              end;
  TTextStyle = class(TNamedObject)
    public
      FontFile:String;
      FontFamily:String;
      pfont: PGDBfont;
      prop:GDBTextStyleProp;
      UsedInLTYPE:Boolean;
  end;
implementation
destructor GDBTextStyle.Done;
begin
     inherited;
     FontFile:='';
     FontFamily:='';
end;
procedure GDBTextStyleArray.freeelement;
begin
  PGDBTextStyle(PItem).name:='';
  PGDBTextStyle(PItem).FontFile:='';
  PGDBTextStyle(PItem).FontFamily:='';
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

function GDBTextStyleArray.CorrectNilledTextStyle(pts:PGDBTextStyle):PGDBTextStyle;
begin
  if pts<>nil then
    result:=pts
  else
    result:=getAddres('Standard');
    {todo: централизовать все строки с dxf терминами наподобии 'Standard'}
end;

procedure GDBTextStyleArray.internalsetstyle(var style:GDBTextStyle;const AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean;const LogProc:TZELogProc=nil);
begin
  style.FontFile:=AFontFile;
  style.FontFamily:=AFontFamily;
  style.UsedInLTYPE:=USedInLT;

  {if pos('.',AFontFile)=0 then
                             AFontFile:=AFontFile+'.shx';}

  style.pfont:=FontManager.addFont(AFontFile,AFontFamily);
  if not assigned(style.pfont) then
    if USedInLT then begin
      if @LogProc<>nil then
        LogProc(ZESGeneral,ZEMsgWarning,format(fontnotfound,[{Tria_AnsiToUtf8}(style.Name),AFontFile,AFontFamily]))
    end else begin
      if @LogProc<>nil then
        LogProc(ZESGeneral,ZEMsgWarning,format(fontnotfoundandreplace,[{Tria_AnsiToUtf8}(style.Name),AFontFile,AFontFamily]));
      style.pfont:=pbasefont;
    end;
  style.prop:=tp;
end;

function GDBTextStyleArray.setstyle(const StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean):PGDBTextStyle;
var
   ps:PGDBTextStyle;
begin
  ps:=(FindStyle(StyleName,USedInLT));
  result:=ps;
  if ps<>nil then
    internalsetstyle(ps^,AFontFile,AFontFamily,tp,USedInLT);
end;
function GDBTextStyleArray.addstyle(const StyleName,AFontFile,AFontFamily:String;tp:GDBTextStyleProp;USedInLT:Boolean;const LogProc:TZELogProc=nil):PGDBTextStyle;
var ts:PGDBTextStyle;
begin
  Getmem(pointer(ts),sizeof(GDBTextStyle));
  ts.init(stylename);
  internalsetstyle(ts^,AFontFile,AFontFamily,tp,USedInLT,LogProc);
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
