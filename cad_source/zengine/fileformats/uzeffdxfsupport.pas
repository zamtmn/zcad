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

unit uzeffdxfsupport;
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}

interface
uses uzegeometrytypes,uzbtypes,sysutils,uzctnrVectorBytes,usimplegenerics;

const
  dxfName_AcDbEntity='AcDbEntity';
  dxfName_AcDbLine='AcDbLine';
  dxfName_Line='LINE';
  dxfName_AcDbSymbolTableRecord='AcDbSymbolTableRecord';
  dxfName_BLOCK_RECORD='BLOCK_RECORD';
  dxfName_ENDTAB='ENDTAB';
  dxfName_TABLE='TABLE';
  dxfName_TABLES='TABLES';
  dxfName_SECTION='SECTION';
  dxfName_HEADER='HEADER';
  dxfName_CLASSES='CLASSES';
  dxfName_APPID='APPID';
  dxfName_DIMSTYLE='DIMSTYLE';
  dxfName_BLOCKRECORD='BLOCK_RECORD';
  dxfName_ENDSEC='ENDSEC';
  dxfName_Layer='LAYER';
  dxfName_Style='STYLE';
  dxfName_LType='LTYPE';

type
  PTIODXFContext=^TIODXFContext;
  TIODXFContext=record
    handle: TDWGHandle;
    currentEntAddrOverrider:pointer;
    p2h:TMapPointerToHandle;
    VarsDict:TString2StringDictionary;
  end;

  TIODXFLoadContext=record
    h2p:TMapHandleToPointer
  end;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex2d);
procedure dxfDoubleout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Double);
procedure dxfIntegerout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Integer);
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:String);overload;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v1,v2:String);overload;
function mystrtoint(const s:String):Integer; inline;
function readmystrtoint(var f:TZctnrVectorBytes):Integer; inline;
function readmystrtodouble(var f:TZctnrVectorBytes):Double;inline;
function readmystr(var f:TZctnrVectorBytes):String; inline;
function dxfvertexload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):Boolean; inline;
function dxfvertexload1(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):Boolean; inline;
function dxfDoubleload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Double):Boolean; inline;
function dxfFloatload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Single):Boolean; inline;
function dxfIntegerload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Integer):Boolean; inline;
function dxfStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:String):Boolean;overload; inline;
function dxfStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:TDXFEntsInternalStringType):Boolean;overload; inline;
function dxfGroupCode(const dxfcod:Integer):String; inline;
function DXFHandle(const sh:string):TDWGHandle; inline;

implementation
//uses
//    log;
function DXFHandle(const sh:string):TDWGHandle;
begin
     result:=StrToQWord('$'+sh);
end;
function dxfGroupCode(const dxfcod:Integer):String;
begin
     result:=inttostr(dxfcod);
end;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
var s:String;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.z:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
var s:String;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     inc(dxfcode);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.z:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex2d);
var s:String;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfDoubleout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Double);
var s:String;
begin
     s:=inttostr(dxfcode);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v:10:10,s);
     f.TXTAddStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfIntegerout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Integer);
//var s:String;
begin
     f.TXTAddStringEOL(inttostr(dxfcode));
     //WriteString_EOL(outfile,inttostr(dxfcode));
     f.TXTAddStringEOL(inttostr(v));
     //WriteString_EOL(outfile,inttostr(v));
end;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:String);
//var s:String;
begin
     f.TXTAddStringEOL(inttostr(dxfcode));
     //WriteString_EOL(outfile,inttostr(dxfcode));
     f.TXTAddStringEOL(v);
     //WriteString_EOL(outfile,v);
end;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v1,v2:String);
begin
     f.TXTAddStringEOL(inttostr(dxfcode));
     f.TXTAddString(v1);
     f.TXTAddStringEOL(v2);
end;
function mystrtoint(const s:String):Integer;
var code:Integer;
begin
     val(s,result,code);
     if code<>0 then result:=0;
end;
function readmystrtoint(var f:TZctnrVectorBytes):Integer;
begin
     if f.ParseInteger(Result)<>0 then Result:=0;
end;
function readmystrtodouble(var f:TZctnrVectorBytes):Double;
begin
     if f.ParseDouble(Result)<>0 then result:=0.0;
end;
function readmystr(var f:TZctnrVectorBytes):String;
begin
     result := f.readString;
end;

function dxfvertexload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):Boolean;
begin
     dxfcod:=((currentdxfcod-dxfcod));
     if dxfcod=0 then begin v.x:=readmystrtodouble(f); result:=true end
else if dxfcod=10 then begin v.y:=readmystrtodouble(f); result:=true end
else if dxfcod=20 then begin v.z:=readmystrtodouble(f); result:=true end else result:=false;
end;
function dxfvertexload1(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):Boolean;
begin
     dxfcod:=((currentdxfcod-dxfcod));
     if dxfcod=0 then begin v.x:=readmystrtodouble(f); result:=true end
else if dxfcod=1 then begin v.y:=readmystrtodouble(f); result:=true end
else if dxfcod=2 then begin v.z:=readmystrtodouble(f); result:=true end else result:=false;
end;
function dxfDoubleload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Double):Boolean;
begin
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end else result:=false;
end;
function dxfFloatload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Single):Boolean;
begin
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end else result:=false;
end;
function dxfIntegerload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Integer):Boolean;
begin
     if currentdxfcod=dxfcod then begin v:=readmystrtoint(f); result:=true end else result:=false;
end;
function dxfStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer;var v:String):Boolean;
var
  s:ansistring;
begin
     if currentdxfcod=dxfcod then
     begin
       s:=f.readStringTemp;
       if v='' then v:=v+Copy(s,1,Length(s)) else v:=v+s;
       result:=true;
     end else result:=false;
end;
function dxfStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:TDXFEntsInternalStringType):Boolean;
var
  s:ansistring;
begin
   { #todo : Нужно убрать уникодный вариант. читать утф8 потом за 1 раз присваивать }
   if currentdxfcod=dxfcod then
   begin
     s:=f.readStringTemp;
     if v='' then v:=v+TDXFEntsInternalStringType(Copy(s,1,Length(s))) else v:=v+TDXFEntsInternalStringType(s);
     result:=true;
   end else result:=false;
end;
begin
end.
