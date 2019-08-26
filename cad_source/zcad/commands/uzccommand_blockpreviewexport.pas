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
{$MODE OBJFPC}
unit uzccommand_blockpreviewexport;
{$INCLUDE def.inc}

interface
uses
  uzgldrawerabstract,
  uzgldrawercanvas,uzgldrawergdi,uzgldrawergeneral2d,
  uzcoimultiobjects,uzepalette,
  uzgldrawcontext,
  uzeentpoint,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,uzccomdrawdase,
  PrintersDlgs,printers,graphics,uzeentdevice,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,
  uzccommandsabstract,uzbstrproc,
  uzbtypesbase,uzccommandsmanager,uzccombase,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  uzeutils,uzcutils,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzeffdxf,
  uzcinterface,
  uzegeometry,
  uzbmemman,
  uzbgeomtypes,uzeentity,uzeentcircle,uzeentline,uzeentgenericsubentry,uzeentmtext,
  uzcshared,uzeentblockinsert,uzeentpolyline,uzclog,
  math,
  uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,TypeDescriptors,UGDBVisibleTreeArray
  ,uzelongprocesssupport,LazLogger,uzeiopalette,uzeconsts,uzerasterizer;
implementation
function BlockPreViewExport_com(operands:TCommandOperands):TCommandResult;
var
   i:integer;
begin
     zcRedrawCurrentDrawing;
     result:=cmd_ok;
end;

{procedure Print_com.Print(pdata:GDBPlatformint);
 var
  cdwg:PTSimpleDrawing;
  PrinterDrawer:TZGLGeneral2DDrawer;
begin
  cdwg:=drawings.GetCurrentDWG;
  try

    Printer.Title := 'zcadprint';
    Printer.BeginDoc;

    PrinterDrawer:=TZGLCanvasDrawer.create;
    rasterize(cdwg,Printer.PageWidth,Printer.PageHeight,p1,p2,PrintParam,Printer.Canvas,PrinterDrawer);
    PrinterDrawer.Free;

    Printer.EndDoc;

  except
    on E:Exception do
    begin
      Printer.Abort;
      ZCMsgCallBackInterface.TextMessage(e.message,TMWOShowError);
    end;
  end;
  zcRedrawCurrentDrawing;
end;}

procedure startup;
begin
  CreateCommandFastObjectPlugin(@BlockPreViewExport_com,'BlockPreViewExport',0,0);
end;

procedure Finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
