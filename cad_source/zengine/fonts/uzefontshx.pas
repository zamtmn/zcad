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

unit uzefontshx;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzefontbase,uzctnrVectorBytes,sysutils,uzegeometry,uzbtypes;
type
  TZESHXFontImpl= class(TZEBaseFontImpl)
    h,u:Byte;
    FUnicode:Boolean;
    constructor Create;
    destructor Destroy;override;
    public
      function IsUnicode:Boolean;override;
      function IsCanSystemDraw:Boolean;override;
      property Unicode:Boolean read FUnicode write FUnicode;
      function GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;override;
  end;
implementation
function TZESHXFontImpl.IsCanSystemDraw:Boolean;
begin
  result:=true;
end;
function TZESHXFontImpl.GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;
begin
     if symbol=49 then
                        symbol:=symbol;
     if symbol<SymCasheSize then
                       begin
                       result:=@symbolinfo[symbol];
                       if result^.LLPrimitiveStartIndex=-1 then
                                        result:=@symbolinfo[ord('?')];
                       end
                   else
                       begin
                            result:=findunisymbolinfo(symbol);
                            if result=nil then
                            begin
                                 result:=@symbolinfo[ord('?')];
                                 exit;
                            end;
                            if result^.LLPrimitiveStartIndex=-1 then
                                             result:=@symbolinfo[ord('?')];

                       end;
end;

function TZESHXFontImpl.IsUnicode:Boolean;
begin
  result:=unicode;
end;
constructor TZESHXFontImpl.Create;
begin
  inherited;
  FUnicode:=false;
  u:=1;
  h:=1;
end;
destructor TZESHXFontImpl.Destroy;
begin
  inherited;
end;
end.
