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
unit uzcCommand_Print;
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
  uzcinterface,
  uzegeometry,

  uzegeometrytypes,uzeentity,uzeentcircle,uzeentline,uzeentmtext,
  uzeentblockinsert,uzeentpolyline,
  math,
  uzeentlwpolyline,UBaseTypeDescriptor,uzeblockdef,Varman,URecordDescriptor,
  TypeDescriptors,uzelongprocesssupport,uzcLog,uzeiopalette,uzerasterizer,
  uzcfPrintPreview;
type
  Print_com= object(CommandRTEdObject)
    VS:Integer;
    p1,p2:GDBVertex;
    procedure CommandContinue(const Context:TZCADCommandContext); virtual;
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure ShowMenu;virtual;
    procedure Print(pdata:PtrInt);
    procedure Preview(pdata:PtrInt);
    procedure OnShowPreview(Sender: TObject);
    procedure SetWindow(pdata:PtrInt);
    procedure SelectPrinter(pdata:PtrInt);
    procedure SelectPaper(pdata:PtrInt);
  end;
var
  PrintParam:TRasterizeParams;
  PSD: TPrinterSetupDialog;
  PAGED: TPageSetupDialog;
  Print:Print_com;

implementation

procedure dbg;
begin
  ZCMsgCallBackInterface.TextMessage(Format('Printer "%s", paper "%s"(%dx%d)',[Printer.PrinterName,Printer.PaperSize.PaperName,Printer.PageWidth,Printer.PageHeight]),TMWOHistoryOut);
end;

procedure Print_com.CommandContinue(const Context:TZCADCommandContext);
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
procedure Print_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  {Error}Prompt(rsNotYetImplemented);
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  begin
       ShowMenu;
       commandmanager.DMShow;
       vs:=commandmanager.GetValueHeap;
       inherited CommandStart(context,'');
  end;
  dbg;
end;
procedure Print_com.ShowMenu;
begin
  commandmanager.DMAddMethod('Printer setup..','Printer setup..',@SelectPrinter);
  commandmanager.DMAddMethod('Page setup..','Printer setup..',@SelectPaper);
  commandmanager.DMAddMethod('Set window','Set window',@SetWindow);
  commandmanager.DMAddMethod('Print','Print',@Print);
  commandmanager.DMAddMethod('Preview','Preview',@Preview);
  commandmanager.DMShow;
end;
procedure Print_com.SelectPrinter(pdata:PtrInt);
begin
  ZCMsgCallBackInterface.TextMessage(rsNotYetImplemented,TMWOHistoryOut);
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  if PSD.Execute then;
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
  dbg;
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
  dbg;
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
  dbg;
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

procedure Print_com.OnShowPreview(Sender: TObject);

var
 cdwg:PTSimpleDrawing;
 PrinterDrawer:TZGLGeneral2DDrawer;
 pw,ph,cw,ch:integer;
 xk,yk:double;
begin
  cdwg:=drawings.GetCurrentDWG;
  cw:=PreviewForm.ClientWidth;
  ch:=PreviewForm.ClientHeight;

  pw:=Printer.PageWidth;
  ph:=Printer.PageHeight;
  xk:=pw/cw;
  yk:=ph/ch;

 if xk<yk then begin
   PreviewForm.Image1.Height:=PreviewForm.ClientHeight;
   PreviewForm.Image1.Width:=trunc(PreviewForm.ClientWidth*xk/yk);
 end else begin
   PreviewForm.Image1.Height:=trunc(PreviewForm.ClientHeight*yk/xk);
   PreviewForm.Image1.Width:=PreviewForm.ClientWidth;
 end;

 PreviewForm.Image1.Canvas.Brush.Color:=clWhite;
 PreviewForm.Image1.Canvas.FillRect(0,0,PreviewForm.Image1.ClientWidth-1,PreviewForm.Image1.ClientHeight-1);
 PrinterDrawer:=TZGLCanvasDrawer.create;
 rasterize(cdwg,PreviewForm.Image1.ClientWidth,PreviewForm.Image1.ClientHeight,p1,p2,PrintParam,PreviewForm.Image1.Canvas,PrinterDrawer);
 PrinterDrawer.Free;
end;

procedure Print_com.Preview(pdata:PtrInt);
begin
  dbg;
  PreviewForm:=TPreviewForm.Create(nil);
  PreviewForm.OnShow:=@OnShowPreview;
  PreviewForm.Show;
  //PreviewForm.Free;
end;

initialization
  ProgramLog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  SysUnit^.RegisterType(TypeInfo(PTRasterizeParams));
  SysUnit^.SetTypeDesk(TypeInfo(TRasterizeParams),['FitToPage','Center','Scale','Palette']);

  Print.init('Print',CADWG,0);
  PrintParam.Scale:=1;
  PrintParam.FitToPage:=true;
  PrintParam.Palette:=PC_Monochrome;
  Print.SetCommandParam(@PrintParam,'PTRasterizeParams');

  PSD:=TPrinterSetupDialog.Create(nil);
  PAGED:=TPageSetupDialog.Create(nil);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  freeandnil(psd);
  freeandnil(paged);
end.
