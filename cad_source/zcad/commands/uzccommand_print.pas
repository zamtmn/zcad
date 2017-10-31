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
  uzglviewareageneral,uzgldrawerabstract,
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
  ddx,ddy,dx,dy,{cx,cy,}sx,sy,scale:gdbdouble;
  tmatrix,_clip:DMatrix4D;
  _frustum:ClipArray;
  cdwg:PTSimpleDrawing;
  oldForeGround:TRGB;
  DC:TDrawContext;

  PrinterDrawer:TZGLGeneral2DDrawer;

  pw,ph:integer;
  point1,point2:GDBVertex;

  modelMatrix,smatrix:DMatrix4D;
  projMatrix:DMatrix4D;
  viewport:IMatrix4;
  pd1,pd2:GDBvertex2D;
begin
  cdwg:=drawings.GetCurrentDWG;
  oldForeGround:=ForeGround;
  ForeGround.r:=0;
  ForeGround.g:=0;
  ForeGround.b:=0;
  pw:=Printer.PageWidth;
  ph:=Printer.PageHeight;
  point2:=p2;
  point1:=p1;

  dx:=point2.x-point1.x;
  if dx=0 then
              dx:=1;
  dy:=point2.y-point1.y;
  if dy=0 then
              dy:=1;

  if PrintParam.FitToPage then
     begin
          sx:=((Printer.PageWidth))/dx;
          sy:=((Printer.PageHeight))/dy;
          scale:=sy;
          if sx<sy then
                       scale:=sx;
          PrintParam.Scale:=scale;
     end
  else
      scale:=PrintParam.Scale;

  if sx>sy then begin
    sx:=sx/sy;
    sy:=1;
  end else begin
    sy:=sy/sx;
    sx:=1;
  end;

  smatrix:=CreateScaleMatrix(CreateVertex(scale,scale,scale));

  //projMatrix:=ortho(point1.x,point2.x,point1.y,point2.y,-1,1,@onematrix);

  projMatrix:=onematrix;
  projMatrix:=ortho(-dx/2,dx/2,-dy/2,dy/2,-1,1,@projMatrix);
  projMatrix:=MatrixMultiply(projMatrix,CreateTranslationMatrix(CreateVertex(-(point1.x+point2.x)/dx,-(point1.y+point2.y)/dy,0)));
  projMatrix:=MatrixMultiply(projMatrix,CreateScaleMatrix(CreateVertex(1/sx,1/sy,1)));




  modelMatrix:=OneMatrix;
  //modelMatrix:=CreateTranslationMatrix(CreateVertex(-dx/{2}5,{dy/2}0,0));
  //projMatrix:=onematrix;
  //projMatrix:=MatrixMultiply(projMatrix,smatrix);

  {point1:=VectorTransform3D(point1,projMatrix);
  point1.x:=-point1.x;
  point1.y:=(Printer.PageHeight-point1.y);}

  //smatrix:=CreateTranslationMatrix(point1);
  //projMatrix:=MatrixMultiply(projMatrix,smatrix);

  //projMatrix:=MatrixMultiply(projMatrix,CreateScaleMatrix(CreateVertex(1,-1,1)));

  point1:=VectorTransform3D(CreateVertex(0,0,0),projMatrix);
  point1:=VectorTransform3D(CreateVertex(1,1,0),projMatrix);


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
  dc.MaxDetail:=true;
  PrinterDrawer:=TZGLCanvasDrawer.create;
  dc.drawer:=PrinterDrawer;

  //modelMatrix:=onematrix;
  //projMatrix:DMatrix4D;
  viewport[0]:=0;
  viewport[1]:=0;
  viewport[2]:=pw;
  viewport[3]:=ph;
  dc.DrawingContext.matrixs.pmodelMatrix:=@modelMatrix;
  dc.DrawingContext.matrixs.pprojMatrix:=@projMatrix;
  dc.DrawingContext.matrixs.pviewport:=@viewport;

  dc.drawer.startrender(TRM_ModelSpace,dc.DrawingContext.matrixs);
  //PrinterDrawer.pushMatrixAndSetTransform(projMatrix);
  PrinterDrawer.canvas:=Printer.Canvas;

  PrinterDrawer.WorkAreaResize(Rect(0,0,pw,ph));

  //Printer.Canvas.Line(0,0,pw,ph);

  _clip:=MatrixMultiply(modelMatrix,projMatrix);
  _frustum:=calcfrustum(@_clip);

  drawings.GetCurrentROOT^.CalcVisibleByTree(_frustum,cdwg^.pcamera^.POSCOUNT,cdwg^.pcamera^.VISCOUNT,drawings.GetCurrentROOT^.ObjArray.ObjTree,cdwg^.pcamera^.totalobj,cdwg^.pcamera^.infrustum,@cdwg^.myGluProject2,cdwg^.pcamera^.prop.zoom,0);
  drawings.GetCurrentROOT^.FormatEntity(drawings.GetCurrentDWG^,dc);
  //drawings.GetCurrentDWG^.OGLwindow1.draw;
  //prn.startrender;

  pd1:=PrinterDrawer.ProjectPoint3DInModelSpace(p1,dc.DrawingContext.matrixs);
  pd2:=PrinterDrawer.ProjectPoint3DInModelSpace(p2,dc.DrawingContext.matrixs);
  PrinterDrawer.canvas.ClipRect:=rect(round(pd1.x),round(pd1.y),round(pd2.x),round(pd2.y));
  PrinterDrawer.canvas.Clipping:=true;
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
  PrintParam.FitToPage:=true;
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
