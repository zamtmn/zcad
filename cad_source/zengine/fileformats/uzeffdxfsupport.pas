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
{$ModeSwitch advancedrecords}
{$Include zengineconfig.inc}

interface
uses
  uzegeometrytypes,uzbtypes,sysutils,uzctnrVectorBytes,usimplegenerics,
  uzMVReader,UGDBPoint3DArray;

const
  cDXFError_WrogGroupCode='DXF group code "%d" expected but "%d" found';

  dxfVar_ACADVER='$ACADVER';
  dxfVar_DWGCODEPAGE='$DWGCODEPAGE';

  dxf_EOF='EOF';
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

  cAC1009='AC1009';{12}
  cAC1014='AC1014';{14}
  cAC1015='AC1015';{2000}
  cAC1018='AC1018';{2004}
  cAC1021='AC1021';{2007}
  cAC1024='AC1024';{2010}
  cAC1027='AC1027';{2013}
  cAC1032='AC1032';{2018}
  cACINVALID='ACINVALID';

  cDXF12  ='DXF12';
  cDXF14  ='DXF14';
  cDXF2000='DXF2000';
  cDXF2004='DXF2004';
  cDXF2007='DXF2007';
  cDXF2010='DXF2010';
  cDXF2013='DXF2013';
  cDXF2018='DXF2018';
  cDXFUNKNOWN='DXFUNKNOWN';

  DefaultLocalEntityFlags=0;

  VarValueWrong=0;

type
  TACDWGVerInt=Integer;
  TACDWGVer=(AC_INVALID,AC1009{12},AC1014{14},AC1015{2000},AC1018{2004},AC1021{2007},
             AC1024{2010},AC1027{2013},AC1032{2018});

  TACDWGCodePage=(CP_INVALID,ANSI_874,ANSI_932,ANSI_936,ANSI_949,ANSI_950,
                  ANSI_1250,ANSI_1251,ANSI_1252,ANSI_1253,ANSI_1254,ANSI_1255,
                  ANSI_1256,ANSI_1257,ANSI_1258);


  TDXFHeaderInfo=record
    Version:TACDWGVer;
    iVersion:TACDWGVerInt;
    DWGCodePage:TACDWGCodePage;
    iDWGCodePage:TSystemCodePage;
    procedure InitRec;
  end;

  TLocalEntityFlags=LongWord;
  EDXFReadException=class(Exception);
  PTIODXFSaveContext=^TIODXFSaveContext;
  TIODXFSaveContext=record
    handle: TDWGHandle;
    currentEntAddrOverrider:pointer;
    p2h:TMapPointerToHandle;
    VarsDict:TString2StringDictionary;
    Header:TDXFHeaderInfo;
    LocalEntityFlags:TLocalEntityFlags;

    procedure InitRec;
    procedure Done;
  end;

  TObjectTypes=(OT_Unknown,OT_TextStyle,OT_LineType,OT_Layer,OT_Entity);

  TDXFHandle2ZCObject=GMapHandle2Pointer<TDWGHandle,Pointer,TObjectTypes>;

  TIODXFLoadContext=record
    h2p:TDXFHandle2ZCObject;
    DWGVarsDict:TString2StringDictionary;

    Header:TDXFHeaderInfo;

    GDBVertexLoadCache:GDBPoint3dArray;

    procedure InitRec;
    procedure Done;
  end;

var
  sysvarSysDWG_CodePage:TZCCodePage=ZCCP1252;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:TzePoint3d);
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:TzePoint3d);
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:TzePoint2d);
procedure dxfDoubleout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Double);
procedure dxfIntegerout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:Integer);
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:String);overload;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:String; const FileHdrInfo:TDXFHeaderInfo);overload;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v1,v2:String);overload;

function dxfEnCodeString(const v:String; const FileHdrInfo:TDXFHeaderInfo):string;

function dxfLoadGroupCodeVertex(var rdr:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:TzePoint3d):Boolean;
function dxfLoadGroupCodeVertex1(var rdr:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:TzePoint3d):Boolean;
function dxfLoadGroupCodeDouble(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Double):Boolean;
function dxfLoadGroupCodeFloat(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Single):Boolean;
function dxfLoadGroupCodeInteger(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Integer):Boolean;
function dxfLoadGroupCodeString(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:String):Boolean;overload;
function dxfLoadGroupCodeString(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:TDXFEntsInternalStringType):Boolean;overload;
function dxfLoadGroupCodeString(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:String; const FileHdrInfo:TDXFHeaderInfo):Boolean;overload;

function dxfDeCodeString(const v:String; const FileHdrInfo:TDXFHeaderInfo):string;

procedure dxfLoadString(var rdr:TZMemReader;out v:String;const FileHdrInfo:TDXFHeaderInfo);
procedure dxfLoadAddString(var rdr:TZMemReader;var v:String;const FileHdrInfo:TDXFHeaderInfo);

function dxfGroupCode(const DXFCode:Integer):String;
function DXFHandle(const sh:string):TDWGHandle;

function dxfRequiredVertex2D(var rdr:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):TzePoint2d;
function dxfRequiredDouble(var rdr:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):Double;
function dxfRequiredInteger(var rdr:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):Integer;

function ACVer2ACVerStr(ACVer:integer):string;
function ACVer2DXFVerStr(ACVer:integer):string;

function ACVer2DXF_ACVer(ACVer:integer):TACDWGVer;

function SysCP2ACCP(SCP:TSystemCodePage):TACDWGCodePage;
function ZCCP2Str(ZCCP:TZCCodePage):string;
function ZCCodePage2ACDWGCodePage(ZCCP:TZCCodePage):TACDWGCodePage;
function ZCCodePage2SysCP(ZCCP:TZCCodePage):TSystemCodePage;

implementation


function ACVer2ACVerStr(ACVer:integer):string;
begin
  case ACVer of
    1009:result:=cAC1009;{12}
    1014:result:=cAC1014;{2000}
    1015:result:=cAC1015;{2000}
    1018:result:=cAC1018;{2004}
    1021:result:=cAC1021;{2007}
    1024:result:=cAC1024;{2010}
    1027:result:=cAC1027;{2013}
    1032:result:=cAC1032;{2018}
    else result:=cACINVALID;
  end;
end;

function ACVer2DXFVerStr(ACVer:integer):string;
begin
  case ACVer of
    1009:result:=cDXF12;
    1014:result:=cDXF14;
    1015:result:=cDXF2000;
    1018:result:=cDXF2004;
    1021:result:=cDXF2007;
    1024:result:=cDXF2010;
    1027:result:=cDXF2013;
    1032:result:=cDXF2018;
    else result:=cDXFUNKNOWN;
  end;
end;

function ACVer2DXF_ACVer(ACVer:integer):TACDWGVer;
begin
  case ACVer of
    1009:result:=AC1009;{12}
    1014:result:=AC1014;{2000}
    1015:result:=AC1015;{2000}
    1018:result:=AC1018;{2004}
    1021:result:=AC1021;{2007}
    1024:result:=AC1024;{2010}
    1027:result:=AC1027;{2013}
    1032:result:=AC1032;{2018}
    else result:=AC_INVALID;
  end;
end;

function SysCP2ACCP(SCP:TSystemCodePage):TACDWGCodePage;
begin
  case SCP of
    874:result:=ANSI_874;
    932:result:=ANSI_932;
    936:result:=ANSI_936;
    949:result:=ANSI_949;
    950:result:=ANSI_950;
    1250:result:=ANSI_1250;
    1251:result:=ANSI_1251;
    1252:result:=ANSI_1252;
    1253:result:=ANSI_1253;
    1254:result:=ANSI_1254;
    1255:result:=ANSI_1255;
    1256:result:=ANSI_1256;
    1257:result:=ANSI_1257;
    1258:result:=ANSI_1258;
    else result:=CP_INVALID;
  end;
end;

function ZCCP2Str(ZCCP:TZCCodePage):string;
begin
  case ZCCP of
    ZCCP874:result:='ANSI_874';
    ZCCP932:result:='ANSI_932';
    ZCCP936:result:='ANSI_936';
    ZCCP949:result:='ANSI_949';
    ZCCP950:result:='ANSI_950';
    ZCCP1250:result:='ANSI_1250';
    ZCCP1251:result:='ANSI_1251';
    ZCCP1252:result:='ANSI_1252';
    ZCCP1253:result:='ANSI_1253';
    ZCCP1254:result:='ANSI_1254';
    ZCCP1255:result:='ANSI_1255';
    ZCCP1256:result:='ANSI_1256';
    ZCCP1257:result:='ANSI_1257';
    ZCCP1258:result:='ANSI_1258';
    ZCCPINVALID:result:='ANSI_1251';
  end;
end;

function ZCCodePage2ACDWGCodePage(ZCCP:TZCCodePage):TACDWGCodePage;
begin
  case ZCCP of
    ZCCP874:result:=ANSI_874;
    ZCCP932:result:=ANSI_932;
    ZCCP936:result:=ANSI_936;
    ZCCP949:result:=ANSI_949;
    ZCCP950:result:=ANSI_950;
    ZCCP1250:result:=ANSI_1250;
    ZCCP1251:result:=ANSI_1251;
    ZCCP1252:result:=ANSI_1252;
    ZCCP1253:result:=ANSI_1253;
    ZCCP1254:result:=ANSI_1254;
    ZCCP1255:result:=ANSI_1255;
    ZCCP1256:result:=ANSI_1256;
    ZCCP1257:result:=ANSI_1257;
    ZCCP1258:result:=ANSI_1258;
    ZCCPINVALID:result:=ANSI_1252;
  end;
end;

function ZCCodePage2SysCP(ZCCP:TZCCodePage):TSystemCodePage;
begin
  case ZCCP of
    ZCCP874:result:=874;
    ZCCP932:result:=932;
    ZCCP936:result:=936;
    ZCCP949:result:=949;
    ZCCP950:result:=950;
    ZCCP1250:result:=1250;
    ZCCP1251:result:=1251;
    ZCCP1252:result:=1252;
    ZCCP1253:result:=1253;
    ZCCP1254:result:=1254;
    ZCCP1255:result:=1255;
    ZCCP1256:result:=1256;
    ZCCP1257:result:=1257;
    ZCCP1258:result:=1258;
    ZCCPINVALID:result:=1252;
  end;
end;


procedure TIODXFSaveContext.InitRec;
begin
  p2h:=TMapPointerToHandle.Create;
  currentEntAddrOverrider:=nil;
  VarsDict:=TString2StringDictionary.create;
  handle := $2;

  Header.InitRec;
end;
procedure TIODXFSaveContext.Done;
begin
  p2h.Free;
  VarsDict.Free;
end;

procedure TIODXFLoadContext.InitRec;
begin
  h2p:=TDXFHandle2ZCObject.Create;
  DWGVarsDict:=TString2StringDictionary.Create;

  Header.InitRec;

  GDBVertexLoadCache.init(1000);
end;

procedure TDXFHeaderInfo.InitRec;
begin
  Version:=AC_INVALID;
  iVersion:=VarValueWrong;
  DWGCodePage:=CP_INVALID;
  iDWGCodePage:=VarValueWrong;
end;

procedure TIODXFLoadContext.Done;
begin
  h2p.Free;
  DWGVarsDict.Free;
  GDBVertexLoadCache.Done;
end;

function DXFHandle(const sh:string):TDWGHandle;
begin
     result:=StrToQWord('$'+sh);
end;
function dxfGroupCode(const DXFCode:Integer):String;
begin
     result:=inttostr(DXFCode);
end;

procedure dxfvertexout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:TzePoint3d);
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
procedure dxfvertexout1(var f:TZctnrVectorBytes;dxfcode:Integer;const v:TzePoint3d);
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
procedure dxfvertex2dout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:TzePoint2d);
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
begin
  f.TXTAddStringEOL(inttostr(dxfcode));
  f.TXTAddStringEOL(v);
end;
function dxfEncodeString(const v:String; const FileHdrInfo:TDXFHeaderInfo):string;
var
  ts:RawByteString;
begin
  if FileHdrInfo.iVersion<1021 then begin
    //младше версии DXF R2007 (AC1021)
    //нужно перекодировать в соответствии с DWGCodepage
    //начиная с DXF R2007 в dxf тексты уже хранятся в utf8
    ts:=v;
    SetCodePage(ts,CP_UTF8,false);
    SetCodePage(ts,FileHdrInfo.iDWGCodePage,true);
    result:=ts;
  end else
    result:=v;
end;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v:String; const FileHdrInfo:TDXFHeaderInfo);
var
  ts:RawByteString;
begin
  f.TXTAddStringEOL(inttostr(dxfcode));
  if FileHdrInfo.iVersion<1021 then begin
    //младше версии DXF R2007 (AC1021)
    //нужно перекодировать в соответствии с DWGCodepage
    //начиная с DXF R2007 в dxf тексты уже хранятся в utf8
    f.TXTAddStringEOL(dxfEncodeString(v,FileHdrInfo));
  end else
    f.TXTAddStringEOL(v);
end;
procedure dxfStringout(var f:TZctnrVectorBytes;dxfcode:Integer;const v1,v2:String);
begin
     f.TXTAddStringEOL(inttostr(dxfcode));
     f.TXTAddString(v1);
     f.TXTAddStringEOL(v2);
end;

function dxfLoadGroupCodeVertex(var rdr:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:TzePoint3d):Boolean;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v.x:=rdr.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+10 then begin v.y:=rdr.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+20 then begin v.z:=rdr.ParseDouble; result:=true end;
end;
function dxfRequiredVertex2d(var rdr:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):TzePoint2d;
begin
  if CurrentDXFGroupCode=RequiredDXFGroupCode then begin
    result.x:=rdr.ParseDouble;
    CurrentDXFGroupCode:=rdr.ParseInteger;
    if CurrentDXFGroupCode=RequiredDXFGroupCode+10 then begin
      result.y:=rdr.ParseDouble;
      CurrentDXFGroupCode:=rdr.ParseInteger;
    end else
      raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode+10,CurrentDXFGroupCode]);
  end else
    raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode,CurrentDXFGroupCode]);
end;
function dxfRequiredDouble(var rdr:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):Double;
begin
  if CurrentDXFGroupCode=RequiredDXFGroupCode then begin
    result:=rdr.ParseDouble;
    CurrentDXFGroupCode:=rdr.ParseInteger;
  end else
    raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode,CurrentDXFGroupCode]);
end;
function dxfRequiredInteger(var rdr:TZMemReader;const RequiredDXFGroupCode:Integer;var CurrentDXFGroupCode:Integer):Integer;
begin
  if CurrentDXFGroupCode=RequiredDXFGroupCode then begin
    result:=rdr.ParseInteger;
    CurrentDXFGroupCode:=rdr.ParseInteger;
  end else
    raise EDXFReadException.CreateFmt(cDXFError_WrogGroupCode,[RequiredDXFGroupCode,CurrentDXFGroupCode]);
end;
function dxfLoadGroupCodeVertex1(var rdr:TZMemReader;const DXFCode,CurrentDXFCode:Integer; var v:TzePoint3d):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v.x:=rdr.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+1 then begin v.y:=rdr.ParseDouble; result:=true end
else if CurrentDXFCode=DXFCode+2 then begin v.z:=rdr.ParseDouble; result:=true end;
end;
function dxfLoadGroupCodeDouble(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Double):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v:=rdr.ParseDouble; result:=true end
end;
function dxfLoadGroupCodeFloat(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Single):Boolean;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v:=rdr.ParseDouble; result:=true end
end;
function dxfLoadGroupCodeInteger(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:Integer):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin v:=rdr.ParseInteger; result:=true end
end;
function dxfLoadGroupCodeString(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer;var v:String):Boolean;
//var s:String;
begin
     result:=false;
     if CurrentDXFCode=DXFCode then begin
       v:=v+rdr.ParseString;
       result:=true;
     end;
end;
function dxfLoadGroupCodeString(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:TDXFEntsInternalStringType):Boolean;
begin
     { #todo : Нужно убрать уникодный вариант. читать утф8 потом за 1 раз присваивать }
     result:=false;
     if CurrentDXFCode=DXFCode then begin
       v:=v+TDXFEntsInternalStringType(rdr.ParseString);
       result:=true;
     end;
end;

function dxfDeCodeString(const v:String; const FileHdrInfo:TDXFHeaderInfo):string;
var
  s:RawByteString;
begin
  if FileHdrInfo.iVersion<1021 then begin
    s:=v;
    //младше версии DXF R2007 (AC1021)
    //нужно перекодировать в соответствии с DWGCodepage
    //начиная с DXF R2007 в dxf тексты уже хранятся в utf8
    SetCodePage(s,FileHdrInfo.iDWGCodePage,false);
    SetCodePage(s,CP_UTF8,true);
    Result:=s;
  end else
    Result:=v;
end;

procedure dxfLoadString(var rdr:TZMemReader;out v:String;const FileHdrInfo:TDXFHeaderInfo);
var
  s:RawByteString;
begin
  s:=rdr.ParseString;
  if FileHdrInfo.iVersion<1021 then begin
    //младше версии DXF R2007 (AC1021)
    //нужно перекодировать в соответствии с DWGCodepage
    //начиная с DXF R2007 в dxf тексты уже хранятся в utf8
    SetCodePage(s,FileHdrInfo.iDWGCodePage,false);
    SetCodePage(s,CP_UTF8,true);
  end;
  v:=s;
end;

procedure dxfLoadAddString(var rdr:TZMemReader;var v:String;const FileHdrInfo:TDXFHeaderInfo);
var
  s:String;
begin
  dxfLoadString(rdr,s,FileHdrInfo);
  v:=v+s;
end;

function dxfLoadGroupCodeString(var rdr:TZMemReader;DXFCode,CurrentDXFCode:Integer; var v:String; const FileHdrInfo:TDXFHeaderInfo):Boolean;
begin
  result:=false;
  if CurrentDXFCode=DXFCode then begin
    dxfLoadAddString(rdr,v,FileHdrInfo);
    result:=true;
  end;
end;

begin
end.
