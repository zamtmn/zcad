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
{$MODE OBJFPC}{$H+}
unit uzccommand_print;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzgldrawercanvas,uzgldrawergdi,uzgldrawergeneral2d,
  uzcoimultiobjects,uzepalette,
  uzeentpoint,uzeentityfactory,
  uzedrawingsimple,uzcsysvars,uzcstrconsts,
  PrintersDlgs,printers,graphics,uzeentdevice,
  LazUTF8,Clipbrd,LCLType,classes,uzeenttext,
  uzccommandsabstract,uzbstrproc,
  uzccommandsmanager,
  uzccommandsimpl,
  uzcdrawings,
  uzeutils,uzcutils,
  sysutils,
  varmandef,
  uzglviewareadata,
  uzeffdxf,
  uzcinterface,
  uzegeometry,

  uzegeometrytypes,uzeentity,uzeentcircle,uzeentline,uzeentmtext,
  uzeentblockinsert,uzeentpolyline,uzclog,
  math,
  uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,
  TypeDescriptors,uzelongprocesssupport,LazLogger,uzeiopalette,uzerasterizer;
const
     modelspacename:String='**Модель**';
type
  {REGISTEROBJECTTYPE Print_com}
  Print_com= object(CommandRTEdObject)
    VS:Integer;
    p1,p2:GDBVertex;
    procedure CommandContinue; virtual;
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure ShowMenu;virtual;
    procedure Print(pdata:PtrInt); virtual;
    procedure SetWindow(pdata:PtrInt); virtual;
    procedure SelectPrinter(pdata:PtrInt); virtual;
    procedure SelectPaper(pdata:PtrInt); virtual;
  end;
var
  PrintParam:TRasterizeParams;
  PSD: TPrinterSetupDialog;
  PAGED: TPageSetupDialog;
  Print:Print_com;

implementation

procedure Print_com.CommandContinue;
var v1,v2:vardesk;
   tp1,tp2:gdbvertex;
begin
     if (commandmanager.GetValueHeap-vs)=2 then
     begin
     v2:=commandmanager.PopValue;
     v1:=commandmanager.PopValue;
     vs:=commandmanager.GetValueHeap;
     tp1:=Pgdbvertex(v1.data.Addr.Instance)^;
     tp2:=Pgdbvertex(v2.data.Addr.Instance)^;

     p1.x:=min(tp1.x,tp2.x);
     p1.y:=min(tp1.y,tp2.y);
     p1.z:=min(tp1.z,tp2.z);

     p2.x:=max(tp1.x,tp2.x);
     p2.y:=max(tp1.y,tp2.y);
     p2.z:=max(tp1.z,tp2.z);
     end;

end;
procedure Print_com.CommandStart(Operands:TCommandOperands);
begin
  {Error}Prompt(rsNotYetImplemented);
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  begin
       ShowMenu;
       commandmanager.DMShow;
       vs:=commandmanager.GetValueHeap;
       inherited CommandStart('');
  end
end;
procedure Print_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Printer setup..','Printer setup..',@SelectPrinter);
  commandmanager.DMAddMethod('Page setup..','Printer setup..',@SelectPaper);
  commandmanager.DMAddMethod('Set window','Set window',@SetWindow);
  commandmanager.DMAddMethod('Print','Print',@print);
  commandmanager.DMShow;
end;
procedure Print_com.SelectPrinter(pdata:PtrInt);
begin
  ZCMsgCallBackInterface.TextMessage(rsNotYetImplemented,TMWOHistoryOut);
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  if PSD.Execute then;
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;
procedure Print_com.SetWindow(pdata:PtrInt);
begin
  commandmanager.executecommandsilent('GetRect',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

procedure Print_com.SelectPaper(pdata:PtrInt);

begin
  ZCMsgCallBackInterface.TextMessage(rsNotYetImplemented,TMWOHistoryOut);
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  if Paged.Execute then;
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;
function Inch(AValue: Double; VertRes:boolean=true): Integer;
begin
  if VertRes then
    result := Round(AValue*Printer.YDPI)
  else
    result := Round(AValue*Printer.XDPI);
end;
procedure Print_com.Print(pdata:PtrInt);
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
end;

procedure startup;
begin
  SysUnit^.RegisterType(TypeInfo(PTRasterizeParams));
  SysUnit^.SetTypeDesk(TypeInfo(TRasterizeParams),['FitToPage','Center','Scale']);

  Print.init('Print',CADWG,0);
  PrintParam.Scale:=1;
  PrintParam.FitToPage:=true;
  PrintParam.Palette:=PC_Monochrome;
  Print.SetCommandParam(@PrintParam,'PTPrintParams');

  PSD:=TPrinterSetupDialog.Create(nil);
  PAGED:=TPageSetupDialog.Create(nil);
end;

procedure Finalize;
begin
  freeandnil(psd);
  freeandnil(paged);
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
