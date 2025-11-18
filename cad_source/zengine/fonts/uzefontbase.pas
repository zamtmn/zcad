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

unit uzefontbase;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzgprimitives,uzglvectorobject,uzbstrproc,uzctnrVectorBytes,gzctnrVectorTypes,
  gzctnrVector,sysutils,uzbtypes,uzegeometrytypes,uzegeometry;

const
  SymCasheSize=128;
type
  TSymbolInfoArray=packed array [0..SymCasheSize-1] of GDBsymdolinfo;
  TGDBUNISymbolInfoVector=GZVector<GDBUNISymbolInfo>;

  TZEBaseFontImpl=class
    protected
      symbolinfo:TSymbolInfoArray;
      unisymbolinfo:TGDBUNISymbolInfoVector;
      function findunisymbolinfo(symbol:Integer):PGDBsymdolinfo;

    public
      FontData:ZGLVectorObject;
      procedure SetupSymbolLineParams(const matr:DMatrix4d; var SymsParam:TSymbolSParam);virtual;
      function GetOrReplaceSymbolInfo(symbol:Integer):PGDBsymdolinfo;virtual;abstract;
      function GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;virtual;
      function findunisymbolinfos(symbolname:String):PGDBsymdolinfo;

      constructor Create;
      destructor Destroy;override;

      function IsUnicode:Boolean;virtual;abstract;
      function IsCanSystemDraw:Boolean;virtual;abstract;
  end;
implementation
procedure TZEBaseFontImpl.SetupSymbolLineParams(const matr:DMatrix4d; var SymsParam:TSymbolSParam);
begin
end;
constructor TZEBaseFontImpl.Create;
var
  i:integer;
begin
  inherited;
  for i:=low(symbolinfo) to high(symbolinfo) do begin
    symbolinfo[i].LLPrimitiveStartIndex:=-1;
    symbolinfo[i].LLPrimitiveCount:=0;
    symbolinfo[i].LatestCreate:=false;
  end;

  unisymbolinfo.init(1000);
  FontData.init();
end;
destructor TZEBaseFontImpl.Destroy;
var
  i:integer;
  pobj:PGDBUNISymbolInfo;
  ir:itrec;
begin
  inherited;
  for i:=low(symbolinfo) to high(symbolinfo) do
    symbolinfo[i].Name:='';

  pobj:=unisymbolinfo.beginiterate(ir);
  if pobj<>nil then repeat
    pobj^.symbolinfo.Name:='';
    pobj:=unisymbolinfo.iterate(ir);
  until pobj=nil;
  unisymbolinfo.Done;
  FontData.done;
end;
function TZEBaseFontImpl.GetOrCreateSymbolInfo(symbol:Integer):PGDBsymdolinfo;
var
  usi:GDBUNISymbolInfo;
begin
  if symbol<SymCasheSize then
    result:=@symbolinfo[symbol]
  else begin
    result:=findunisymbolinfo(symbol);
    if result=nil then
    begin
      usi.symbol:=symbol;
      usi.symbolinfo.LLPrimitiveStartIndex:=-1;
      usi.symbolinfo.NextSymX:=0;
      usi.symbolinfo.SymMaxY:=0;
      usi.symbolinfo.h:=0;
      usi.symbolinfo.LLPrimitiveCount:=0;
      usi.symbolinfo.w:=0;
      usi.symbolinfo.SymMinY:=0;
      usi.symbolinfo.LatestCreate:=false;
      killstring(usi.symbolinfo.Name);
      unisymbolinfo.PushBackData(usi);
      result:=@(PGDBUNISymbolInfo(unisymbolinfo.getDataMutable(unisymbolinfo.Count-1))^.symbolinfo);
    end;
  end;
end;
function TZEBaseFontImpl.findunisymbolinfo(symbol:Integer):PGDBsymdolinfo;
var
  pobj:PGDBUNISymbolInfo;
  ir:itrec;
begin
  pobj:=unisymbolinfo.beginiterate(ir);
  if pobj<>nil then
    repeat
      if pobj^.symbol=symbol then begin
        result:=@pobj^.symbolinfo;
        exit;
      end;
    pobj:=unisymbolinfo.iterate(ir);
    until pobj=nil;
  result:=nil;
end;
function TZEBaseFontImpl.findunisymbolinfos(symbolname:String):PGDBsymdolinfo;
var
  pobj:PGDBUNISymbolInfo;
  ir:itrec;
  i:integer;
begin
  symbolname:=uppercase(symbolname);
  for i:=low(symbolinfo) to high(symbolinfo) do begin
    if uppercase(symbolinfo[i].Name)=symbolname then begin
      result:=@symbolinfo[i];
      exit;
    end;
  end;
  pobj:=unisymbolinfo.beginiterate(ir);
  if pobj<>nil then
    repeat
      if uppercase(pobj^.symbolinfo.Name)=symbolname then begin
        result:=@pobj^.symbolinfo;
        exit;
      end;
    pobj:=unisymbolinfo.iterate(ir);
    until pobj=nil;
    result:=nil;
end;
end.
