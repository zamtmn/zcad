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
{$INCLUDE def.inc}

interface
uses uzbgeomtypes,uzbtypesbase,uzbtypes,sysutils,UGDBOpenArrayOfByte,usimplegenerics;

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

procedure dxfvertexout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:gdbvertex);
procedure dxfvertexout1(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:gdbvertex);
procedure dxfvertex2dout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:gdbvertex2d);
procedure dxfGDBDoubleout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:GDBDouble);
procedure dxfGDBIntegerout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:GDBInteger);
procedure dxfGDBStringout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:GDBString);
function mystrtoint(s:GDBString):GDBInteger;
function readmystrtoint(var f:GDBOpenArrayOfByte):GDBInteger;
function readmystrtodouble(var f:GDBOpenArrayOfByte):GDBDouble;
function readmystr(var f:GDBOpenArrayOfByte):GDBString;
function dxfvertexload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:gdbvertex):GDBBoolean;
function dxfvertexload1(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:gdbvertex):GDBBoolean;
function dxfGDBDoubleload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:GDBDouble):GDBBoolean;
function dxfGDBFloatload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:GDBFloat):GDBBoolean;
function dxfGDBIntegerload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:GDBInteger):GDBBoolean;
function dxfGDBStringload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBString):GDBBoolean;overload;
function dxfGDBStringload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:UnicodeString):GDBBoolean;overload;
function dxfGroupCode(const dxfcod:GDBInteger):GDBString;
function DXFHandle(sh:string):TDWGHandle;

implementation
//uses
//    log;
function DXFHandle(sh:string):TDWGHandle;
begin
     result:=StrToQWord('$'+sh);
end;
function dxfGroupCode(const dxfcod:GDBInteger):GDBString;
begin
     result:=inttostr(dxfcod);
end;

procedure dxfvertexout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:gdbvertex);
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
procedure dxfvertexout1(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:gdbvertex);
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
procedure dxfvertex2dout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:gdbvertex2d);
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
procedure dxfGDBDoubleout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:GDBDouble);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
     str(v:10:10,s);
     f.TXTAddGDBStringEOL(s);
     //WriteString_EOL(outfile,s);
end;
procedure dxfGDBIntegerout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:GDBInteger);
//var s:GDBString;
begin
     f.TXTAddGDBStringEOL(inttostr(dxfcode));
     //WriteString_EOL(outfile,inttostr(dxfcode));
     f.TXTAddGDBStringEOL(inttostr(v));
     //WriteString_EOL(outfile,inttostr(v));
end;
procedure dxfGDBStringout(var f:GDBOpenArrayOfByte;dxfcode:GDBInteger;const v:GDBString);
//var s:GDBString;
begin
     f.TXTAddGDBStringEOL(inttostr(dxfcode));
     //WriteString_EOL(outfile,inttostr(dxfcode));
     f.TXTAddGDBStringEOL(v);
     //WriteString_EOL(outfile,v);
end;
function mystrtoint(s:GDBString):GDBInteger;
var code:GDBInteger;
begin
     val(s,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystrtoint(var f:GDBOpenArrayOfByte):GDBInteger;
var code:GDBInteger;
    //s:GDBString;
begin
     //s := f.readGDBSTRING;
     val({s}f.readGDBSTRING,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystrtodouble(var f:GDBOpenArrayOfByte):GDBDouble;
var code:GDBInteger;
    //s:GDBString;
begin
     //s := f.readGDBSTRING;
     val({s}f.readGDBSTRING,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystr(var f:GDBOpenArrayOfByte):GDBString;
//var s:GDBString;
begin
     result := f.readGDBSTRING;
end;

function dxfvertexload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:gdbvertex):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v.x:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+10 then begin v.y:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+20 then begin v.z:=readmystrtodouble(f); result:=true end;
end;
function dxfvertexload1(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:gdbvertex):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v.x:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+1 then begin v.y:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+2 then begin v.z:=readmystrtodouble(f); result:=true end;
end;
function dxfGDBDoubleload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:GDBDouble):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end
end;
function dxfGDBFloatload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:GDBFloat):GDBBoolean;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end
end;
function dxfGDBIntegerload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; out v:GDBInteger):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtoint(f); result:=true end
end;
function dxfGDBStringload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger;var v:GDBString):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin
                                       v:=v+readmystr(f); result:=true end
end;
function dxfGDBStringload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:UnicodeString):GDBBoolean;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin
                                       v:=v+readmystr(f); result:=true end
end;
begin
end.
