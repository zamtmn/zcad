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

unit uzeFontFileFormatTTFBackendLFT;
{$INCLUDE zengineconfig.inc}
interface
uses
  sysutils,Types,
  uzeFontFileFormatTTFBackend,
  EasyLazFreeType;
type
  TTTFBackendLazFreeType=Class(TTTFBackend)
    protected
      LazFreeTypeTTFImpl:TFreeTypeFont;

      function GetHinted:Boolean;override;
      procedure SetHinted(const AValue:Boolean);override;
      function GetFullName:String;override;
      function GetFamily:String;override;
      procedure SetSizeInPoints(const AValue:single);override;
      function GetSizeInPoints:single;override;
      function GetCharIndex(AUnicodeChar:integer):integer;override;

      function GetAscent: single;override;
      function GetDescent: single;override;
      function GetCapHeight: single;override;
      function GetGlyph(Index: integer): TGlyphData;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;

      function GetGlyphBounds(GD:TGlyphData):TRect;override;
      function GetGlyphAdvance(GD:TGlyphData):Single;override;
  end;
implementation
function TTTFBackendLazFreeType.GetGlyphBounds(GD:TGlyphData):TRect;
begin
  result:=TFreeTypeGlyph(GD.PG).Bounds;
end;
function TTTFBackendLazFreeType.GetGlyphAdvance(GD:TGlyphData):Single;
begin
  result:=TFreeTypeGlyph(GD.PG).Advance;
end;

function TTTFBackendLazFreeType.GetGlyph(Index: integer):TGlyphData;
begin
  Result.PG:=LazFreeTypeTTFImpl.Glyph[Index];
end;
function TTTFBackendLazFreeType.GetCapHeight: single;
begin
  Result:=LazFreeTypeTTFImpl.CapHeight;
end;
function TTTFBackendLazFreeType.GetAscent:single;
begin
  Result:=LazFreeTypeTTFImpl.Ascent;
end;
function TTTFBackendLazFreeType.GetDescent:single;
begin
  Result:=LazFreeTypeTTFImpl.Descent;
end;
function TTTFBackendLazFreeType.GetCharIndex(AUnicodeChar:integer):integer;
begin
  Result:=LazFreeTypeTTFImpl.CharIndex[AUnicodeChar];
end;
procedure TTTFBackendLazFreeType.SetSizeInPoints(const AValue:single);
begin
  LazFreeTypeTTFImpl.SizeInPoints:=AValue;
end;
function TTTFBackendLazFreeType.GetSizeInPoints:single;
begin
  Result:=LazFreeTypeTTFImpl.SizeInPoints;
end;
function TTTFBackendLazFreeType.GetFullName:String;
begin
  Result:=LazFreeTypeTTFImpl.Information[ftiFullName];
end;
function TTTFBackendLazFreeType.GetFamily:String;
begin
  Result:=LazFreeTypeTTFImpl.Information[ftiFamily];
end;
procedure TTTFBackendLazFreeType.LoadFile(const AFile:String);
begin
   LazFreeTypeTTFImpl.Name:=AFile;
end;
function TTTFBackendLazFreeType.GetHinted:Boolean;
begin
  Result:=LazFreeTypeTTFImpl.Hinted;
end;
procedure TTTFBackendLazFreeType.SetHinted(const AValue:Boolean);
begin
  LazFreeTypeTTFImpl.Hinted:=AValue;
end;
constructor TTTFBackendLazFreeType.Create;
begin
  LazFreeTypeTTFImpl:=TFreeTypeFont.Create;
end;
destructor TTTFBackendLazFreeType.Destroy;
begin
  FreeAndNil(LazFreeTypeTTFImpl);
end;
initialization
end.
