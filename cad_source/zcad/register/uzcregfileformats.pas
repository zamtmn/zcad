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
  uzbtypes,uzeTypes,uzeffdxfsupport,uzeffmanager,uzeLogIntf,
  uzeffdxf,
  uzeffLibreDWG,uzeffLibreDWG2Ents;
implementation
function DWGCodePage2DXFCodePage(ADWGCP:TACDWGCodePage):TZCCodePage;
begin
  case ADWGCP of
    ANSI_874:result:=ZCCP874;
    ANSI_932:result:=ZCCP932;
    ANSI_936:result:=ZCCP936;
    ANSI_949:result:=ZCCP949;
    ANSI_950:result:=ZCCP950;
    ANSI_1250:result:=ZCCP1250;
    ANSI_1251:result:=ZCCP1251;
    ANSI_1252:result:=ZCCP1252;
    ANSI_1253:result:=ZCCP1253;
    ANSI_1254:result:=ZCCP1254;
    ANSI_1255:result:=ZCCP1255;
    ANSI_1256:result:=ZCCP1256;
    ANSI_1257:result:=ZCCP1257;
    ANSI_1258:result:=ZCCP1258;
    CP_INVALID:result:=ZCCPINVALID;
  end;
end;

procedure LoadDXFviaZEnfine(const AFileName: String;var dwgCtx:TZDrawingContext;const LogIntf:TZELogProc=nil);
var
  hdr:TDXFHeaderInfo;
begin
  hdr:=uzeffdxf.addfromdxf(AFileName,dwgCtx,LogIntf);
  if hdr.DWGCodePage<>CP_INVALID then
    dwgCtx.PDrawing^.DXFCodePage:=DWGCodePage2DXFCodePage(hdr.DWGCodePage)
  else
    dwgCtx.PDrawing^.DXFCodePage:=sysvarSysDWG_CodePage;
end;
begin
  Ext2LoadProcMap.RegisterExt('dxf','AutoCAD DXF files via zengine (*.dxf)',@LoadDXFviaZEnfine,true);
  Ext2LoadProcMap.DefaultExt:='dxf';

  Ext2LoadProcMap.RegisterExt('dwg','AutoCAD DWG files via LibreDWG (*.dwg)',@uzeffLibreDWG.addfromdwg);
  Ext2LoadProcMap.RegisterExt('dxf','AutoCAD DXF files via LibreDWG (*.dxf)',@uzeffLibreDWG.addfromdxf);
end.
