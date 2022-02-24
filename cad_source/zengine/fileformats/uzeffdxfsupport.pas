{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE zcadconfig.inc}

interface
uses uzegeometrytypes,uzbtypesbase,uzbtypes,sysutils,uzctnrVectorBytes,usimplegenerics;

const
  dxfName_AcDbEntity='AcDbEntity';
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
  TIODXFContext=record
    handle: TDWGHandle;
    currentEntAddrOverrider:pointer;
    p2h:TMapPointerToHandle;
    VarsDict:TGDBString2GDBStringDictionary;
  end;

  TIODXFLoadContext=record
    h2p:TMapHandleToPointer
  end;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex2d);
procedure dxfGDBDoubleout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBDouble);
procedure dxfGDBIntegerout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Integer);
procedure dxfGDBStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBString);
function mystrtoint(s:GDBString):Integer;
function readmystrtoint(var f:TZctnrVectorBytes):Integer;
function readmystrtodouble(var f:TZctnrVectorBytes):GDBDouble;
function readmystr(var f:TZctnrVectorBytes):GDBString;
function dxfvertexload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):GDBBoolean;
function dxfvertexload1(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):GDBBoolean;
function dxfGDBDoubleload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:GDBDouble):GDBBoolean;
function dxfFloatload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Single):GDBBoolean;
function dxfGDBIntegerload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Integer):GDBBoolean;
function dxfGDBStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:GDBString):GDBBoolean;overload;
function dxfGDBStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:TDXFEntsInternalStringType):GDBBoolean;overload;
function dxfGroupCode(const dxfcod:Integer):GDBString;
function DXFHandle(sh:string):TDWGHandle;

implementation
//uses
//    log;
function DXFHandle(sh:string):TDWGHandle;
begin
     result:=StrToQWord('$'+sh);
end;
function dxfGroupCode(const dxfcod:Integer):GDBString;
begin
     result:=inttostr(dxfcod);
end;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.z:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     inc(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.z:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex2d);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfGDBDoubleout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBDouble);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfGDBIntegerout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Integer);
//var s:GDBString;
begin
     f.TXTAddGDBStringEOL(inttostr(dxfcode));
     //WriteString_EOL(outfile,inttostr(dxfcode));
     f.TXTAddGDBStringEOL(inttostr(v));
     //WriteString_EOL(outfile,inttostr(v));
end;
procedure dxfGDBStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBString);
//var s:GDBString;
begin
     f.TXTAddGDBStringEOL(inttostr(dxfcode));
     //WriteString_EOL(outfile,inttostr(dxfcode));
     f.TXTAddGDBStringEOL(v);
     //WriteString_EOL(outfile,v);
end;
function mystrtoint(s:GDBString):Integer;
var code:Integer;
begin
     val(s,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystrtoint(var f:TZctnrVectorBytes):Integer;
var code:Integer;
    //s:GDBString;
begin
     //s := f.readGDBSTRING;
     val({s}f.readGDBSTRING,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystrtodouble(var f:TZctnrVectorBytes):GDBDouble;
var code:Integer;
    //s:GDBString;
begin
     //s := f.readGDBSTRING;
     val({s}f.readGDBSTRING,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystr(var f:TZctnrVectorBytes):GDBString;
//var s:GDBString;
begin
     result := f.readGDBSTRING;
end;

function dxfvertexload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v.x:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+10 then begin v.y:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+20 then begin v.z:=readmystrtodouble(f); result:=true end;
end;
function dxfvertexload1(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:gdbvertex):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v.x:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+1 then begin v.y:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+2 then begin v.z:=readmystrtodouble(f); result:=true end;
end;
function dxfGDBDoubleload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:GDBDouble):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end
end;
function dxfFloatload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Single):GDBBoolean;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end
end;
function dxfGDBIntegerload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:Integer):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtoint(f); result:=true end
end;
function dxfGDBStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer;var v:GDBString):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin
                                       v:=v+readmystr(f); result:=true end
end;
function dxfGDBStringload(var f:TZctnrVectorBytes;dxfcod,currentdxfcod:Integer; var v:TDXFEntsInternalStringType):GDBBoolean;
begin
     { #todo : Нужно убрать уникодный вариант. читать утф8 потом за 1 раз присваивать }
     result:=false;
     if currentdxfcod=dxfcod then begin
                                       v:=v+TDXFEntsInternalStringType(readmystr(f)); result:=true end
end;
begin
end.
