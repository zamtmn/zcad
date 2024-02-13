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
  freetypehdyn,ftfont;
type
  TTTFBackendFreeType=Class(TTTFBackend)
    protected
      FreeTypeTTFImpl:TFreeTypeFont;

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

      {function GetAscent: single;override;
      function GetDescent: single;override;}
      function GetCapHeight: single;override;
      function GetGlyph(Index: integer):TGlyphData;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;
      //property DPI: integer read GetDPI write SetDPI;
      procedure DoneGlyph(var GD:TGlyphData);override;

      function GetGlyphBounds(GD:TGlyphData):TRect;override;
  end;

implementation
function readFT_SfntName(var SfntName:TFT_SfntName):UnicodeString;
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
      result:=ts;
    end;
  end;
end;

function TTTFBackendFreeType.GetGlyph(Index: integer):TGlyphData;
begin
  Result.PG:=nil;
  FT_Load_Glyph(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),Index,FT_LOAD_DEFAULT);
  FT_Get_Glyph(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex).glyph,Result.PG);
end;
procedure TTTFBackendFreeType.DoneGlyph(var GD:TGlyphData);
begin
  FT_Done_Glyph(GD.PG);
end;

function TTTFBackendFreeType.GetGlyphBounds(GD:TGlyphData):TRect;
var
  BB:FT_BBox;
begin
  FT_Glyph_Get_CBox(GD.PG,FT_GLYPH_BBOX_UNSCALED,BB);
  bb:=bb;
end;

function TTTFBackendFreeType.GetCapHeight:single;
var
  p:pointer;
begin
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),FT_SFNT_OS2);
  if p<>nil then
    result:=PTT_OS(p)^.sCapHeight
  else
    exit(0);
  p:=FT_Get_Sfnt_Table(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),FT_SFNT_HEAD);
  if p<>nil then
    result:=result/PTT_Header(p)^.Units_Per_EM
  else
    exit(0);

  result:=result * FPointSize * FDPI / 72;
end;

function TTTFBackendFreeType.GetCharIndex(AUnicodeChar:integer):integer;
begin
  result:=FT_Get_Char_Index(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),AUnicodeChar);
end;
function TTTFBackendFreeType.GetSizeInPoints:single;
begin
  result:=FPointSize;
end;

procedure TTTFBackendFreeType.SetSizeInPoints(const AValue:single);
begin
  FPointSize:=AValue;
  FT_Set_Char_Size(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),round(64*AValue),round(3*64*AValue),round(AValue),round(3*AValue));
end;

function TTTFBackendFreeType.GetFullName:String;
var
  SfntName:TFT_SfntName;
begin
  SfntName:=Default(TFT_SfntName);
  FT_Get_Sfnt_Name(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),TT_NAME_ID_FULL_NAME,SfntName);
  result:=readFT_SfntName(SfntName);
end;
function TTTFBackendFreeType.GetFamily:String;
var
  SfntName:TFT_SfntName;
begin
  SfntName:=Default(TFT_SfntName);
  FT_Get_Sfnt_Name(FontMgr.GetFreeTypeFont(FreeTypeTTFImpl.FontIndex),TT_NAME_ID_FONT_FAMILY,SfntName);
  result:=readFT_SfntName(SfntName);
end;

function TTTFBackendFreeType.GetHinted:Boolean;
begin
  //Result:=FreeTypeTTFImpl.Hinted;
end;
procedure TTTFBackendFreeType.SetHinted(const AValue:Boolean);
begin
  //FreeTypeTTFImpl.Hinted:=AValue;
end;

constructor TTTFBackendFreeType.Create;
begin
  FreeTypeTTFImpl:=TFreeTypeFont.Create;
  FDPI:=96;
  FPointSize:=1;
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
