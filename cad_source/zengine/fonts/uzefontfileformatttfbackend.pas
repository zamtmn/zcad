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
  sysutils,
  EasyLazFreeType;
type
  TTTFBackends=class of TTTFBackend;
  TTTFBackend=class
    protected
      function GetHinted:Boolean;virtual;abstract;
      procedure SetHinted(const AValue:Boolean);virtual;abstract;
      function GetFullName:String;virtual;abstract;
      function GetFamily:String;virtual;abstract;
      procedure SetSizeInPoints(const AValue:single);virtual;abstract;
      function GetSizeInPoints:single;virtual;abstract;
      function GetCharIndex(AUnicodeChar:integer):integer;virtual;abstract;

      function GetAscent: single; virtual; abstract;
      function GetDescent: single; virtual; abstract;
      function GetCapHeight: single; virtual; abstract;
      function GetGlyph(Index: integer): TFreeTypeGlyph; virtual; abstract;

    public
      constructor Create;virtual;abstract;
      procedure LoadFile(const AFile:String);virtual;abstract;
      property Hinted:Boolean read GetHinted write SetHinted;
      property FullName:String read GetFullName;
      property Family:String read GetFamily;
      property SizeInPoints:single read GetSizeInPoints write SetSizeInPoints;
      property CharIndex[AUnicodeChar:integer]:integer read GetCharIndex;

      property Ascent: single read GetAscent;
      property Descent: single read GetDescent;
      property CapHeight: single read GetCapHeight;
      property Glyph[Index: integer]: TFreeTypeGlyph read GetGlyph;
  end;
implementation
end.
