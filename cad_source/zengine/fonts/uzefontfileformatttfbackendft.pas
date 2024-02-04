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
  sysutils,
  uzeFontFileFormatTTFBackend,
  freetypehdyn,ftfont;
type
  TTTFBackendFreeType=Class(TTTFBackend)
    protected
      FreeTypeTTFImpl:TFreeTypeFont;

      function GetHinted:Boolean;override;
      procedure SetHinted(const AValue:Boolean);override;
      function GetFullName:String;override;
      function GetFamily:String;override;
      {procedure SetSizeInPoints(const AValue:single);override;
      function GetSizeInPoints:single;override;
      function GetCharIndex(AUnicodeChar:integer):integer;override;

      function GetAscent: single;override;
      function GetDescent: single;override;
      function GetCapHeight: single;override;}
      //function GetGlyph(Index: integer): TFreeTypeGlyph;override;

    public
      constructor Create;override;
      destructor Destroy;override;
      procedure LoadFile(const AFile:String);override;
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
