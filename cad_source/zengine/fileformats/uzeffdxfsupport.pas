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
uses uzegeometrytypes,uzbtypes,sysutils,uzctnrVectorBytes,usimplegenerics,
  uzMVReader;

const
  cDXFError_WrogGroupCode='DXF group code "%d" expected but "%d" found';

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
  EDXFReadException=class(Exception);
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

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBvertex);
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBvertex);
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:gdbvertex2d);
procedure dxfDoubleout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Double);
procedure dxfIntegerout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Integer);
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:String);overload;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v1,v2:String);overload;
function dxfVertexLoad(var f:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:GDBvertex):Boolean;
function dxfVertexLoad1(var f:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:GDBvertex):Boolean;
function dxfDoubleload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Double):Boolean;
function dxfFloatload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Single):Boolean;
function dxfIntegerload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Integer):Boolean;
function dxfStringload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:String):Boolean;overload;
function dxfStringload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:TDXFEntsInternalStringType):Boolean;overload;
function dxfGroupCode(const DXFCode:Integer):String;
function DXFHandle(const sh:string):TDWGHandle;

function dxfRequiredVertex2D(var f:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):GDBvertex2D;
function dxfRequiredDouble(var f:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):Double;

implementation

function DXFHandle(const sh:string):TDWGHandle;
begin
     result:=StrToQWord('$'+sh);
end;
function dxfGroupCode(const DXFCode:Integer):String;
begin
     result:=inttostr(DXFCode);
end;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBvertex);
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
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:GDBvertex);
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

function dxfVertexLoad(var f:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:GDBvertex):Boolean;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v.x:=f.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+10 then begin v.y:=f.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+20 then begin v.z:=f.ParseDouble; result:=true end;
end;
function dxfRequiredVertex2d(var f:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):GDBvertex2d;
begin
  if CurrentDXFGroupCode=RequiredDXFGroupCode then begin
    result.x:=f.ParseDouble;
    CurrentDXFGroupCode:=f.ParseInteger;
    if CurrentDXFGroupCode=RequiredDXFGroupCode+10 then begin
      result.y:=f.ParseDouble;
      CurrentDXFGroupCode:=f.ParseInteger;
    end else
      raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode+10,CurrentDXFGroupCode]);
  end else
    raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode,CurrentDXFGroupCode]);
end;
function dxfRequiredDouble(var f:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):Double;
begin
  if CurrentDXFGroupCode=RequiredDXFGroupCode then begin
    result:=f.ParseDouble;
    CurrentDXFGroupCode:=f.ParseInteger;
  end else
    raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode,CurrentDXFGroupCode]);
end;
function dxfVertexLoad1(var f:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:GDBvertex):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v.x:=f.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+1 then begin v.y:=f.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+2 then begin v.z:=f.ParseDouble; result:=true end;
end;
function dxfDoubleload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Double):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v:=f.ParseDouble; result:=true end
end;
function dxfFloatload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Single):Boolean;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v:=f.ParseDouble; result:=true end
end;
function dxfIntegerload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Integer):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v:=f.ParseInteger; result:=true end
end;
function dxfStringload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer;var v:String):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin
       v:=v+f.ParseString;
       result:=true;
     end;
end;
function dxfStringload(var f:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:TDXFEntsInternalStringType):Boolean;
begin
     { #todo : Нужно убрать уникодный вариант. читать утф8 потом за 1 раз присваивать }
     result:=false;
     if CurrentDXFCode=DXFCode then begin
       v:=v+TDXFEntsInternalStringType(f.ParseString);
       result:=true;
     end;
end;
begin
end.
