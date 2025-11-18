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

unit uzeFontFileFormatTTFBackendFT;
{$INCLUDE zengineconfig.inc}
interface
uses
  sysutils,Types,
  uzeFontFileFormatTTFBackend,
  uzegeometrytypes,
  {todo: убрать после выхода нового fpc}
 {$IF FPC_FULLVERSION > 30204}
  freetypehdyn,ftfont
 {$ELSE}
  tmp322_freetypehdyn,tmp322_ftfont
 {$ENDIF}
 ;
const
  EmptyIndex=-1;
type
  TTTFBackendFreeType=Class(TTTFBackend)
    protected
      FreeTypeTTFImpl:TFreeTypeFont;
      GlyphInSlotIndex:Integer;

      FPointSize:single;
      FDPI:integer;

      function GetHinted:Boolean;override;
      procedure SetHinted(const AValue:Boolean);override;
      function GetFullName:String;override;
      function GetFamily:String;override;
      procedure SetSizeInPoints(const AValue:single);override;
      function GetSizeInPoints:single;override;
      function GetCharIndex(AUnicodeChar:integer):integer;override;

      //procedure SetDPI(const AValue:integer);
      //function GetDPI:integer;

      function GetAscent: single;override;
      function GetDescent: single;override;
      function GetkForGDISystemRender: single;override;
      function InternalGetCapHeight: single;override;
      function GetGlyph(Index: integer):TGlyphData;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;
      //property DPI: integer read GetDPI write SetDPI;
      procedure DoneGlyph(var GD:TGlyphData);override;

      function TTFImplDummyGlobalScale:Double;override;

      function GetGlyphBounds(GD:TGlyphData):TRect;override;
      function GetGlyphAdvance(GD:TGlyphData):Single;override;
      function GetGlyphContoursCount(GD:TGlyphData):Integer;override;
      function GetGlyphPointsCount(GD:TGlyphData):Integer;override;
      function GetGlyphPoint(GD:TGlyphData;np:integer):GDBvertex2D;override;
      function GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;override;
      function GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;override;
  end;

implementation
{TODO: нужен вариант функции с String}
function readFT_SfntNameU(var SfntName:TFT_SfntName):UnicodeString;
const
  maxstringlength=16000;
var
  len,i:integer;
  ts:string;
begin
  if SfntName.String_len=0 then
    result:=''
  else begin
    if SfntName.platform_id<>1 then begin
      if SfntName.String_len>maxstringlength then
        len:=maxstringlength
      else
        len:=SfntName.String_len div 2;
      result:='';
      setlength(result,len);
      system.Move(SfntName.aString^,result[1],len*2);
      for i:=1 to len do
        PWord(@result[i])^:=BEtoN(PWord(@result[i])^);
    end else begin
      if SfntName.String_len>maxstringlength then
        len:=maxstringlength
      else
        len:=SfntName.String_len;
      ts:='';
      setlength(ts,len);
      system.Move(SfntName.aString^,ts[1],len);
      result:=UnicodeString(ts);
    end;
  end;
end;

function readFT_SfntNameA(var SfntName:TFT_SfntName):AnsiString;
const
  maxstringlength=16000;
var
  len,i:integer;
  uresult:UnicodeString;
begin
  if SfntName.String_len=0 then
    result:=''
  else begin
    if SfntName.platform_id<>1 then begin
      if SfntName.String_len>maxstringlength then
        len:=maxstringlength
      else
        len:=SfntName.String_len div 2;
      uresult:='';
      setlength(uresult,len);
      system.Move(SfntName.aString^,uresult[1],len*2);
      for i:=1 to len do
        PWord(@uresult[i])^:=BEtoN(PWord(@uresult[i])^);
      result:=string(uresult);
    end else begin
      if SfntName.String_len>maxstringlength then
        len:=maxstringlength
      else
        len:=SfntName.String_len;
      result:='';
      setlength(result,len);
      system.Move(SfntName.aString^,result[1],len);
    end;
  end;
end;

function TTTFBackendFreeType.TTFImplDummyGlobalScale:Double;
var
  phead:PTT_Header;
  s1,s2:LongWord;
begin
  s1:=CTTFDefaultSizeInPoints*64*1{width}*96 div 72;
  phead:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  s2:=phead^.Units_Per_EM*64;
  phead:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if (PTT_Header(phead)^.Flags and 8)<>0 then
    s1:=(s1+32)and -64;
  result:=s1/s2
  //result:={6.51}853312/(256*64);
end;

function TTTFBackendFreeType.GetGlyph(Index: integer):TGlyphData;
begin
  if GlyphInSlotIndex<>Index then begin
    if FT_Load_Glyph(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),Index,FT_LOAD_DEFAULT)=0 then begin
      GlyphInSlotIndex:=Index;
      //FT_Get_Glyph(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph,Result.PG);
    end else
      raise Exception.CreateFmt('TTTFBackendFreeType.GetGlyph FT_Load_Glyph(%d)<>0', [Index]);
  end;
  PtrInt(Result.PG):=Index;
end;
procedure TTTFBackendFreeType.DoneGlyph(var GD:TGlyphData);
begin
  //FT_Done_Glyph(GD.PG);
end;

function TTTFBackendFreeType.GetGlyphBounds(GD:TGlyphData):TRect;
//var
  //BB:FT_BBox;
  //gm:FT_Glyph_Metrics;
begin
  GetGlyph(PtrInt(GD.PG));
  //BB:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).bbox;
  //gm:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.metrics;
  with FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.metrics do begin
    result.left:=horiBearingX;
    result.right:=horiBearingX+width;
    result.top:=horiBearingY;
    result.Bottom:=horiBearingY-height;
  end;
end;
function TTTFBackendFreeType.GetGlyphAdvance(GD:TGlyphData):Single;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.metrics.horiAdvance;
end;
function TTTFBackendFreeType.GetGlyphContoursCount(GD:TGlyphData):Integer;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.n_contours;
end;
function TTTFBackendFreeType.GetGlyphPointsCount(GD:TGlyphData):Integer;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.n_points;
end;
function TTTFBackendFreeType.GetGlyphPoint(GD:TGlyphData;np:integer):GDBvertex2D;
//var
//  sm:FT_Size_Metrics;
begin
  GetGlyph(PtrInt(GD.PG));
  //sm:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.face.size.metrics;
  with FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.points[np] do begin
    result.x:=x*64;
    result.y:=y*64;
  end;
end;
function TTTFBackendFreeType.GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;
begin
  GetGlyph(PtrInt(GD.PG));
  if (byte(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.tags[np]) and 1)<>0 then
    result:=[TTFPFOnCurve]
  else
    result:=[];
end;
function  TTTFBackendFreeType.GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;
begin
  GetGlyph(PtrInt(GD.PG));
  result:=FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID).glyph^.outline.contours[np];
end;
function TTTFBackendFreeType.GetAscent: single;
var
  p:pointer;
begin
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  if p<>nil then
    result:=PTT_OS(p)^.sTypoAscender
  else
    exit(0);
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if p<>nil then
    result:=result/PTT_Header(p)^.Units_Per_EM
  else
    exit(0);

  result:=result * FPointSize * FDPI / 72;
end;

function TTTFBackendFreeType.GetDescent: single;
var
  p:pointer;
begin
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  if p<>nil then
    result:=PTT_OS(p)^.sTypoDescender
  else
    exit(0);
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if p<>nil then
    result:=result/PTT_Header(p)^.Units_Per_EM
  else
    exit(0);

  result:=result * FPointSize * FDPI / 72;
end;

function TTTFBackendFreeType.GetkForGDISystemRender:single;
var
  sc,CapH:integer;
  p:pointer;
begin
  result:=2;
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  if p<>nil then begin
    if PTT_OS(p)^.version>=2 then begin
      if PTT_OS(p)^.sCapHeight<>0 then begin
        CapH:=PTT_OS(p)^.sCapHeight;
      end else
      CapH:=round(CalcCapHeight);
    end else
      CapH:=round(CalcCapHeight);
  end else
    CapH:=round(CalcCapHeight);

  if CapH=0 then
    exit(1);

  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  if p<>nil then begin
    sc:=PTT_OS(p)^.usWinAscent+PTT_OS(p)^.usWinDescent;
    if sc=0 then
      exit(1);
  end else
    exit(1);
  result:=sc/CapH;
end;

function TTTFBackendFreeType.InternalGetCapHeight:single;
var
  pos2,phead,phori:pointer;
begin
  pos2:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_OS2);
  phead:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),FT_SFNT_HEAD);
  if pos2<>nil then begin
    if PTT_OS(pos2)^.version>=2 then begin
      if PTT_OS(pos2)^.sCapHeight<>0 then begin
        Result:=PTT_OS(pos2)^.sCapHeight;
      end else
      Result:=CalcCapHeight;
    end else
      Result:=CalcCapHeight;
  end else
    Result:=CalcCapHeight;

  if phead<>nil then
    Result:=Result/PTT_Header(phead)^.Units_Per_EM
  else begin
    Result:=0;
    exit(0);
  end;

  result:=Result*FPointSize*FDPI/72;
end;


function TTTFBackendFreeType.GetCharIndex(AUnicodeChar:integer):integer;
begin
  result:=FT_Get_Char_Index(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),AUnicodeChar);
end;
function TTTFBackendFreeType.GetSizeInPoints:single;
begin
  result:=FPointSize;
end;

procedure TTTFBackendFreeType.SetSizeInPoints(const AValue:single);
//var
//  err:integer;
begin
  FPointSize:=AValue;
  FT_Set_Char_Size(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),round(64*AValue),round(64*AValue),600,600);
end;

function TTTFBackendFreeType.GetFullName:String;
var
  SfntName:TFT_SfntName;
begin
  SfntName:=Default(TFT_SfntName);
  FT_Get_Sfnt_Name(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),TT_NAME_ID_FULL_NAME,SfntName);
  result:=readFT_SfntNameA(SfntName);
end;
function TTTFBackendFreeType.GetFamily:String;
var
  SfntName:TFT_SfntName;
begin
  SfntName:=Default(TFT_SfntName);
  FT_Get_Sfnt_Name(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontID),TT_NAME_ID_FONT_FAMILY,SfntName);
  result:=readFT_SfntNameA(SfntName);
end;

function TTTFBackendFreeType.GetHinted:Boolean;
begin
  //Result:=FreeTypeTTFImpl.Hinted;
  //не реализовано
  Result:=False;
end;
procedure TTTFBackendFreeType.SetHinted(const AValue:Boolean);
begin
  //не реализовано
  //FreeTypeTTFImpl.Hinted:=AValue;
end;

constructor TTTFBackendFreeType.Create;
begin
  FreeTypeTTFImpl:=TFreeTypeFont.Create;
  FDPI:=96;
  FPointSize:=1;
  GlyphInSlotIndex:=EmptyIndex;
end;
destructor TTTFBackendFreeType.Destroy;
begin
  FreeAndNil(FreeTypeTTFImpl);
end;
procedure TTTFBackendFreeType.LoadFile(const AFile:String);
begin
  FreeTypeTTFImpl.AllocateResources(nil);
  FreeTypeTTFImpl.Name:=AFile;
end;

end.
