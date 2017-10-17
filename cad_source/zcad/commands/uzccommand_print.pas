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
unit uzccommand_print;
{$INCLUDE def.inc}

interface
uses
  uzglviewareageneral,
  uzgldrawercanvas,
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
  ,uzelongprocesssupport,LazLogger;
const
     modelspacename:GDBSTring='**Модель**';
type
  Print_com={$IFNDEF DELPHI}packed{$ENDIF} object(CommandRTEdObject)
    VS:GDBInteger;
    p1,p2:GDBVertex;
    procedure CommandContinue; virtual;
    procedure CommandStart(Operands:TCommandOperands); virtual;
    procedure ShowMenu;virtual;
    procedure Print(pdata:GDBPlatformint); virtual;
    procedure SetWindow(pdata:GDBPlatformint); virtual;
    procedure SelectPrinter(pdata:GDBPlatformint); virtual;
    procedure SelectPaper(pdata:GDBPlatformint); virtual;
  end;
  PTPrintParams=^TPrintParams;
  TPrintParams=packed record
    FitToPage:GDBBoolean;(*'Fit to page'*)
    Center:GDBBoolean;(*'Center'*)
    Scale:GDBDouble;(*'Scale'*)
  end;
var
  PrintParam:TPrintParams;
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
     tp1:=Pgdbvertex(v1.data.Instance)^;
     tp2:=Pgdbvertex(v2.data.Instance)^;

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
  Error(rsNotYetImplemented);
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
procedure Print_com.SelectPrinter(pdata:GDBPlatformint);
begin
  ZCMsgCallBackInterface.TextMessage(rsNotYetImplemented,TMWOHistoryOut);
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  if PSD.Execute then;
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;
procedure Print_com.SetWindow(pdata:GDBPlatformint);
begin
  commandmanager.executecommandsilent('GetRect',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

procedure Print_com.SelectPaper(pdata:GDBPlatformint);

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
procedure Print_com.Print(pdata:GDBPlatformint);
 var
  //prn:TPrinterRasterizer;
  dx,dy,{cx,cy,}sx,sy,scale:gdbdouble;
  tmatrix{,_clip}:DMatrix4D;
  cdwg:PTSimpleDrawing;
  oldForeGround:TRGB;
  DC:TDrawContext;

  PrinterDrawer:TZGLCanvasDrawer;
  pmatrix:DMatrix4D;
begin
  cdwg:=drawings.GetCurrentDWG;
  oldForeGround:=ForeGround;
  ForeGround.r:=0;
  ForeGround.g:=0;
  ForeGround.b:=0;
  //prn.init;
  //OGLSM:=@prn;
  dx:=p2.x-p1.x;
  if dx=0 then
              dx:=1;
  dy:=p2.y-p1.y;
  if dy=0 then
              dy:=1;
  ////cx:=(p2.x+p1.x)/2;
  ////cy:=(p2.y+p1.y)/2;
  //prn.model:=onematrix;//cdwg^.pcamera^.modelMatrix{LCS};
  //prn.project:=cdwg^.pcamera^.projMatrix{LCS};
  ////prn.w:=Printer.PaperSize.Width;
  ////prn.h:=Printer.PaperSize.Height;
  ////pr:=Printer.PaperSize.PaperRect;
  //prn.w:=Printer.PageWidth;
  //prn.h:=Printer.PageHeight;
  //prn.wmm:=dx;
  //prn.hmm:=dy;
  {prn.project}pmatrix:=ortho(p1.x,p2.x,p1.y,p2.y,-1,1,@onematrix);

  //prn.scalex:=1;
  //prn.scaley:=dy/dx;

  if PrintParam.FitToPage then
     begin
          sx:=((Printer.PageWidth/Printer.XDPI)*25.4);
          sx:=((Printer.PageWidth/Printer.XDPI)*25.4)/dx;
          sy:=((Printer.PageHeight/Printer.YDPI)*25.4)/dy;
          scale:=sy;
          if sx<sy then
                       scale:=sx;
          PrintParam.Scale:=scale;
     end
  else
      scale:=PrintParam.Scale;
  //prn.scalex:=prn.scalex*scale;
  //prn.scaley:=prn.scaley*scale;

  tmatrix:=drawings.GetCurrentDWG^.pcamera^.projMatrix;
  //drawings.GetCurrentDWG^.pcamera^.projMatrix:=prn.project;
  //drawings.GetCurrentDWG^.pcamera^.modelMatrix:=prn.model;
  try
  Printer.Title := 'zcadprint';
  Printer.BeginDoc;

  drawings.GetCurrentDWG^.pcamera^.NextPosition;
  inc(cdwg^.pcamera^.DRAWCOUNT);
  //_clip:=MatrixMultiply(prn.model,prn.project);
  drawings.GetCurrentDWG^.pcamera^.getfrustum(@cdwg^.pcamera^.modelMatrix,   @cdwg^.pcamera^.projMatrix,   cdwg^.pcamera^.clip,   cdwg^.pcamera^.frustum);
  //_frustum:=calcfrustum(@_clip);
  drawings.GetCurrentDWG^.wa.param.firstdraw := TRUE;
  //cdwg^.OGLwindow1.param.debugfrustum:=cdwg^.pcamera^.frustum;
  //cdwg^.OGLwindow1.param.ShowDebugFrustum:=true;
  dc:=cdwg^.CreateDrawingRC(true);
  dc.DrawMode:=true;
  PrinterDrawer:=TZGLCanvasDrawer.create;
  dc.drawer:=PrinterDrawer;
  PrinterDrawer.pushMatrixAndSetTransform(pmatrix);
  PrinterDrawer.canvas:=Printer.Canvas;
  drawings.GetCurrentROOT^.CalcVisibleByTree(cdwg^.pcamera^.frustum{calcfrustum(@_clip)},cdwg^.pcamera^.POSCOUNT,cdwg^.pcamera^.VISCOUNT,drawings.GetCurrentROOT^.ObjArray.ObjTree,cdwg^.pcamera^.totalobj,cdwg^.pcamera^.infrustum,@cdwg^.myGluProject2,cdwg^.pcamera^.prop.zoom,SysVarRDImageDegradationCurrentDegradationFactor);
  //drawings.GetCurrentDWG^.OGLwindow1.draw;
  //prn.startrender;
  drawings.GetCurrentDWG^.wa.treerender(drawings.GetCurrentROOT^.ObjArray.ObjTree,0,{0}dc);
  //prn.endrender;
  inc(cdwg^.pcamera^.DRAWCOUNT);

  Printer.EndDoc;
  drawings.GetCurrentDWG^.pcamera^.projMatrix:=tmatrix;

  except
    on E:Exception do
    begin
      Printer.Abort;
      ZCMsgCallBackInterface.TextMessage(e.message,TMWOShowError);
    end;
  end;
  ForeGround:=oldForeGround;
  zcRedrawCurrentDrawing;
end;

procedure startup;
begin
  SysUnit^.RegisterType(TypeInfo(PTPrintParams));
  SysUnit^.SetTypeDesk(TypeInfo(TPrintParams),['FitToPage','Center','Scale']);

  Print.init('Print',CADWG,0);
  PrintParam.Scale:=1;
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
