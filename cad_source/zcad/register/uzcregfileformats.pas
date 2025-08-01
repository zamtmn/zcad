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

unit uzcregfileformats;

interface

uses
  SysUtils,
  uzbtypes,uzeffdxfsupport,uzeffmanager,uzeffdxf,uzeLogIntf;
implementation
function DWGCodePage2DXFCodePage(ADWGCP:TDXF_DWGCodePage):TDXFCodePage;
begin
  case ADWGCP of
    ANSI_874:result:=DXFCP874;
    ANSI_932:result:=DXFCP932;
    ANSI_936:result:=DXFCP936;
    ANSI_949:result:=DXFCP949;
    ANSI_950:result:=DXFCP950;
    ANSI_1250:result:=DXFCP1250;
    ANSI_1251:result:=DXFCP1251;
    ANSI_1252:result:=DXFCP1252;
    ANSI_1253:result:=DXFCP1253;
    ANSI_1254:result:=DXFCP1254;
    ANSI_1255:result:=DXFCP1255;
    ANSI_1256:result:=DXFCP1256;
    ANSI_1257:result:=DXFCP1257;
    ANSI_1258:result:=DXFCP1258;
    CP_INVALID:result:=DXFCPINVALID;
  end;
end;

procedure LoadDXFviaZEnfine(const AFileName: String;var dwgCtx:TZDrawingContext;const LogIntf:TZELogProc=nil);
var
  hdr:TDXFHeaderInfo;
begin
  hdr:=uzeffdxf.addfromdxf(AFileName,dwgCtx,LogIntf);
  dwgCtx.PDrawing^.DXFCodePage:=DWGCodePage2DXFCodePage(hdr.DWGCodePage);
end;
begin
  Ext2LoadProcMap.RegisterExt('dxf','AutoCAD DXF files via zengine (*.dxf)',@LoadDXFviaZEnfine,true);
  Ext2LoadProcMap.DefaultExt:='dxf';
end.
TDXF_DWGCodePage=(CP_INVALID,ANSI_874,ANSI_932,ANSI_936,ANSI_949,ANSI_950,
                  ANSI_1250,ANSI_1251,ANSI_1252,ANSI_1253,ANSI_1254,ANSI_1255,
                  ANSI_1256,ANSI_1257,ANSI_1258);

TDXFCodePage=(DXFCPINVALID,DXFCP874,DXFCP932,DXFCP936,DXFCP949,DXFCP950,
  DXFCP1250,DXFCP1251,DXFCP1252,DXFCP1253,DXFCP1254,DXFCP1255,DXFCP1256,
  DXFCP1257,DXFCP1258);

