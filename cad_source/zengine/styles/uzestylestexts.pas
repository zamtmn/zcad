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
uses LCLProc,uzbpaths,uzefontmanager,sysutils,
     uzefont,uzestrconsts,UGDBNamedObjectsArray,uzeNamedObject,
     uzeLogIntf,gzctnrVectorTypes;
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
                    { Поиск стиля текста по имени файла шрифта (FontFile).
                      Используется при разборе proxy-объектов, где сохранено
                      имя файла шрифта (например, "times.ttf"), а не имя стиля.
                      Возвращает nil, если стиль с таким FontFile не найден. }
                    function FindStyleByFont(const FontFileName:String):PGDBTextStyle;
                    { Поиск стиля текста по имени typeface (FontFamily).
                      Используется при разборе proxy-объектов (OpCode=38
                      UnicodeText2), где сохранено читаемое имя шрифта
                      ("Times New Roman"), а в таблице стилей это значение
                      хранится в поле FontFamily (группа 1000 расширенных
                      данных). Возвращает nil, если стиль не найден. }
                    function FindStyleByTypeface(const TypefaceName:String):PGDBTextStyle;
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
{ Возвращает имя файла без расширения.
  Используется для сравнения шрифтов, когда в одном источнике хранится
  полное имя файла ("times.ttf"), а в другом только базовое имя ("times"
  или "txt"). }
function StripFontExtension(const FontFileName:String):String;
begin
  Result:=ChangeFileExt(FontFileName,'');
end;

{ Поиск стиля текста по имени файла шрифта (FontFile).
  Используется при разборе proxy-объектов: в бинарном потоке сохранено
  имя файла шрифта ("times.ttf" или "txt.shx"), а в таблице стилей
  чертежа — либо то же имя, либо имя без расширения ("txt"). Поэтому
  сначала выполняется точное сравнение, затем — сравнение базовых имён
  без расширений. Сравнение выполняется без учёта регистра.
  Стили-служебные элементы типов линий (UsedInLTYPE=true) пропускаются. }
function GDBTextStyleArray.FindStyleByFont(const FontFileName:String):PGDBTextStyle;
var
  pStyle:PGDBTextStyle;
  ir:itrec;
  FontBase,StyleBase:String;
begin
  result:=nil;
  if FontFileName='' then Exit;
  FontBase:=StripFontExtension(FontFileName);
  pStyle:=beginiterate(ir);
  while pStyle<>nil do
  begin
    if not pStyle^.UsedInLTYPE then
    begin
      { Точное сравнение имён файлов }
      if (Length(pStyle^.FontFile)=Length(FontFileName))
        and (CompareText(pStyle^.FontFile,FontFileName)=0) then
      begin
        result:=pStyle;
        Exit;
      end;
      { Сравнение базовых имён (без расширения) — AutoCAD в proxy
        graphic часто пишет "txt.shx", тогда как в таблице стилей
        имя хранится как "txt". }
      StyleBase:=StripFontExtension(pStyle^.FontFile);
      if (StyleBase<>'') and (FontBase<>'')
        and (Length(StyleBase)=Length(FontBase))
        and (CompareText(StyleBase,FontBase)=0) then
      begin
        result:=pStyle;
        Exit;
      end;
    end;
    pStyle:=iterate(ir);
  end;
end;

{ Поиск стиля по имени typeface (FontFamily в GDBTextStyle).
  Используется при разборе proxy-объектов OpCode=38 (UnicodeText2), где
  AutoCAD сохраняет человекочитаемое имя шрифта (например "Times New Roman")
  в поле TypeFace. В таблице стилей ZCAD это значение хранится в FontFamily
  (читается из расширенных данных STYLE, группа 1000 под регистрацией "ACAD").
  Сравнение выполняется без учёта регистра.
  Стили-служебные элементы типов линий (UsedInLTYPE=true) пропускаются. }
function GDBTextStyleArray.FindStyleByTypeface(const TypefaceName:String):PGDBTextStyle;
var
  pStyle:PGDBTextStyle;
  ir:itrec;
begin
  result:=nil;
  if TypefaceName='' then Exit;
  pStyle:=beginiterate(ir);
  while pStyle<>nil do
  begin
    if not pStyle^.UsedInLTYPE then
      if (pStyle^.FontFamily<>'')
        and (Length(pStyle^.FontFamily)=Length(TypefaceName))
        and (CompareText(pStyle^.FontFamily,TypefaceName)=0) then
      begin
        result:=pStyle;
        Exit;
      end;
    pStyle:=iterate(ir);
  end;
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
