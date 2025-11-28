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
  EasyLazFreeType,TTObjs,
  uzegeometrytypes;
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
      function InternalGetCapHeight: single;override;
      function GetGlyph(Index: integer): TGlyphData;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;

      procedure DoneGlyph(var GD:TGlyphData);override;

      function GetGlyphBounds(GD:TGlyphData):TRect;override;
      function GetGlyphAdvance(GD:TGlyphData):Single;override;
      function GetGlyphContoursCount(GD:TGlyphData):Integer;override;
      function GetGlyphPointsCount(GD:TGlyphData):Integer;override;
      function GetGlyphPoint(GD:TGlyphData;np:integer):TzePoint2d;override;
      function GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;override;
      function GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;override;
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
function TTTFBackendLazFreeType.GetGlyphContoursCount(GD:TGlyphData):Integer;
begin
  result:=PGlyph(TFreeTypeGlyph(GD.PG).Data.z)^.outline.n_contours;
end;
function TTTFBackendLazFreeType.GetGlyphPointsCount(GD:TGlyphData):Integer;
begin
  result:=PGlyph(TFreeTypeGlyph(GD.PG).Data.z)^.outline.n_points-2;
end;
function TTTFBackendLazFreeType.GetGlyphPoint(GD:TGlyphData;np:integer):TzePoint2d;
begin
  with PGlyph(TFreeTypeGlyph(GD.PG).Data.z)^.outline.points^[np] do begin
    result.x:=x;
    result.y:=y;
  end;
end;
function TTTFBackendLazFreeType.GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;
begin
  result:=[];
  if PGlyph(TFreeTypeGlyph(GD.PG).Data.z)^.outline.flags^[np]<>0 then
    Include(result,TTFPFOnCurve);
end;
function TTTFBackendLazFreeType.GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;
begin
  result:=PGlyph(TFreeTypeGlyph(GD.PG).Data.z)^.outline.conEnds^[np];
end;
function TTTFBackendLazFreeType.GetGlyph(Index: integer):TGlyphData;
begin
  Result.PG:=PtrInt(LazFreeTypeTTFImpl.Glyph[Index]);
end;
procedure TTTFBackendLazFreeType.DoneGlyph(var GD:TGlyphData);
begin
  GD.PG:={nil}0;
end;
function TTTFBackendLazFreeType.InternalGetCapHeight: single;
begin
  Result:=LazFreeTypeTTFImpl.CapHeight;
  if Result=0 then begin
    Result:=-CalcCapHeight;
  end;
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
