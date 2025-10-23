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

unit uzeFontFileFormatTTFBackend;
{$INCLUDE zengineconfig.inc}
interface
uses
  sysutils,Types,
  EasyLazFreeType,
  uzegeometrytypes;
type
  TGlyphData=record
    PG:PtrInt;
  end;

  TTTFPointFlag=(TTFPFOnCurve);
  TTTFPointFlags=set of TTTFPointFlag;

  TTTFBackends=class of TTTFBackend;
  TTTFBackend=class
    protected
      FCapHeight:single;

      function GetHinted:Boolean;virtual;abstract;
      procedure SetHinted(const AValue:Boolean);virtual;abstract;
      function GetFullName:String;virtual;abstract;
      function GetFamily:String;virtual;abstract;
      procedure SetSizeInPoints(const AValue:single);virtual;abstract;
      function GetSizeInPoints:single;virtual;abstract;
      function GetCharIndex(AUnicodeChar:integer):integer;virtual;abstract;

      function GetAscent: single; virtual; abstract;
      function GetDescent: single; virtual; abstract;
      function CalcCapHeight: single;
      function GetCapHeight: single; virtual;
      function InternalGetCapHeight: single; virtual; abstract;
      function GetGlyph(Index: integer): TGlyphData; virtual; abstract;
      function GetkForGDISystemRender: single; virtual; abstract;

    public
      constructor Create;virtual;abstract;
      procedure LoadFile(const AFile:String);virtual;abstract;
      property Hinted:Boolean read GetHinted write SetHinted;
      property FullName:String read GetFullName;
      property Family:String read GetFamily;
      property SizeInPoints:single read GetSizeInPoints write SetSizeInPoints;
      property CharIndex[AUnicodeChar:integer]:integer read GetCharIndex;

      function GetGlyphBounds(GD:TGlyphData):TRect;virtual;abstract;
      function GetGlyphAdvance(GD:TGlyphData):Single;virtual;abstract;
      function GetGlyphContoursCount(GD:TGlyphData):Integer;virtual;abstract;
      function GetGlyphPointsCount(GD:TGlyphData):Integer;virtual;abstract;
      function GetGlyphPoint(GD:TGlyphData;np:integer):GDBvertex2D;virtual;abstract;
      function GetGlyphPointFlag(GD:TGlyphData;np:integer):TTTFPointFlags;virtual;abstract;
      function GetGlyphConEnd(GD:TGlyphData;np:integer):Integer;virtual;abstract;
      procedure DoneGlyph(var GD:TGlyphData); virtual; abstract;

      function TTFImplDummyGlobalScale:Double;virtual;

      property Ascent: single read GetAscent;
      property Descent: single read GetDescent;
      property CapHeight: single read GetCapHeight;
      property Glyph[Index: integer]: TGlyphData read GetGlyph;
      property kForGDISystemRender: single read GetkForGDIsystemRender;
  end;
const
  CTTFDefaultSizeInPoints=10000;
var
  TTFBackend:TTTFBackends;
  {$IF DEFINED(USELAZFREETYPETTFIMPLEMENTATION) and DEFINED(USEFREETYPETTFIMPLEMENTATION)}
  sysvarTTFUseLazFreeTypeImplementation:boolean=false;
  {$ENDIF}
implementation
function TTTFBackend.TTFImplDummyGlobalScale:Double;
begin
  result:=1;
end;

function TTTFBackend.CalcCapHeight: single;
var
  ndx:integer;
  ch:char;
  GenGlyph:TGlyphData;
  glyphBounds:TRect;
begin
  for ch in 'XYZABCDEFGHIJKLMNOPQRSTUWV' do begin
    ndx:=CharIndex[ord(ch)];
    if ndx<>0 then begin
      GenGlyph:=Glyph[ndx];
      glyphBounds:=GetGlyphBounds(GenGlyph);
      DoneGlyph(GenGlyph);
      exit(glyphBounds.Top);
    end;
  end;
  result:=-1;
end;

function TTTFBackend.GetCapHeight:single;
//var
//  pos2,phead,phori:pointer;
begin
  if FCapHeight<>0 then
    result:=FCapHeight
  else begin
    FCapHeight:=InternalGetCapHeight;
    result:=FCapHeight;
  end;
end;

end.
