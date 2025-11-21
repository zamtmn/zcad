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
unit uzeRasterizer;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzegeometrytypes,
  uzedrawingsimple,uzgldrawcontext,uzgldrawergeneral2d,uzgldrawerabstract,
  uzeroot,
  uzegeometry,uzeconsts,
  uzeiopalette,uzepalette,uzcutils,
  uzbLogIntf,Graphics,Classes,
  uzgldrawercanvas,uzbtypes;
type
  TRasterizeColor=(PC_Color,PC_Grayscale,PC_Monochrome);
  PTRasterizeParams=^TRasterizeParams;
  TRasterizeParams=record
    FitToPage:Boolean;
    Center:Boolean;
    Scale:Double;
    Palette:TRasterizeColor;
  end;
procedure rasterize(cdwg:PTSimpleDrawing;pw,ph:integer;point1,point2:TzePoint3d;PrintParam:TRasterizeParams;Canvas: TCanvas;PrinterDrawer:TZGLGeneral2DDrawer);
implementation
procedure rasterize(cdwg:PTSimpleDrawing;pw,ph:integer;point1,point2:TzePoint3d;PrintParam:TRasterizeParams;Canvas: TCanvas;PrinterDrawer:TZGLGeneral2DDrawer);
 var
  dx,dy,sx,sy,scale:Double;
  tmatrix,_clip:DMatrix4d;
  _frustum:ClipArray;
  DC:TDrawContext;

  modelMatrix:DMatrix4d;
  projMatrix:DMatrix4d;
  viewport:TzeVector4i;
  pd1,pd2:TzePoint2d;

  oldforegroundindex:integer;
  Actlt:TVisActuality;
begin

  dx:=point2.x-point1.x;
  if dx=0 then
              dx:=1;
  dy:=point2.y-point1.y;
  if dy=0 then
              dy:=1;

  if PrintParam.FitToPage then
     begin
          sx:=(({Printer.PageWidth}pw))/dx;
          sy:=(({Printer.PageHeight}ph))/dy;
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

  //smatrix:=CreateScaleMatrix(CreateVertex(scale,scale,scale));

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

  //point1:=VectorTransform3D(CreateVertex(0,0,0),projMatrix);
  //point1:=VectorTransform3D(CreateVertex(1,1,0),projMatrix);


  //prn.scalex:=prn.scalex*scale;
  //prn.scaley:=prn.scaley*scale;

  tmatrix:=cdwg^.pcamera^.projMatrix;
  //drawings.GetCurrentDWG^.pcamera^.projMatrix:=prn.project;
  //drawings.GetCurrentDWG^.pcamera^.modelMatrix:=prn.model;
  //try

  if PrintParam.Palette<>PC_Color then
  case PrintParam.Palette of
    PC_Monochrome:PushAndSetNewPalette(MonochromePalette);
    PC_Grayscale: begin
                    zDebugLn('{WH}Print: Grayscale palette not yet implemented, use monochrome palette');
                    PushAndSetNewPalette(grayscalepalette);
                  end;
    PC_Color:     ;//заглушка
  end;

  //----Printer.Title := 'zcadprint';
  //----Printer.BeginDoc;

  cdwg^.pcamera^.NextPosition;
  inc(cdwg^.pcamera^.DRAWCOUNT);
  //_clip:=MatrixMultiply(prn.model,prn.project);
  cdwg^.pcamera^.getfrustum(@cdwg^.pcamera^.modelMatrix,   @cdwg^.pcamera^.projMatrix,   cdwg^.pcamera^.clip,   cdwg^.pcamera^.frustum);
  //_frustum:=calcfrustum(@_clip);
  cdwg^.wa.param.firstdraw := TRUE;
  //cdwg^.OGLwindow1.param.debugfrustum:=cdwg^.pcamera^.frustum;
  //cdwg^.OGLwindow1.param.ShowDebugFrustum:=true;
  dc:=cdwg^.CreateDrawingRC(true);
  dc.DrawMode:=true;
  dc.MaxDetail:=true;
  //PrinterDrawer:=TZGLCanvasDrawer.create;
  dc.drawer:=PrinterDrawer;
  oldforegroundindex:=dc.DrawingContext.ForeGroundColorIndex;
  dc.DrawingContext.ForeGroundColorIndex:=uzeconsts.ClBlack;


  //modelMatrix:=onematrix;
  //projMatrix:DMatrix4d;
  viewport.v[0]:=0;
  viewport.v[1]:=0;
  viewport.v[2]:=pw;
  viewport.v[3]:=ph;
  dc.DrawingContext.matrixs.pmodelMatrix:=@modelMatrix;
  dc.DrawingContext.matrixs.pprojMatrix:=@projMatrix;
  dc.DrawingContext.matrixs.pviewport:=@viewport;

  dc.drawer.startrender(TRM_ModelSpace,dc.DrawingContext.matrixs);
  //PrinterDrawer.pushMatrixAndSetTransform(projMatrix);
  PrinterDrawer.canvas:=Canvas;

  PrinterDrawer.WorkAreaResize(Rect(0,0,pw,ph));

  //Printer.Canvas.Line(0,0,pw,ph);

  _clip:=MatrixMultiply(modelMatrix,projMatrix);
  _frustum:=calcfrustum(@_clip);

  Actlt.InfrustumActualy:=cdwg^.pcamera^.POSCOUNT;
  Actlt.VisibleActualy:=cdwg^.pcamera^.VISCOUNT;
  cdwg^.GetCurrentROOT^.CalcVisibleByTree(_frustum,Actlt,cdwg^.GetCurrentROOT^.ObjArray.ObjTree,cdwg^.pcamera^.Counters,@cdwg^.myGluProject2,cdwg^.pcamera^.prop.zoom,0);
  //cdwg^.GetCurrentROOT^.FormatEntity(cdwg^,dc);
  DoFormat(cdwg^.GetCurrentROOT^,cdwg^.GetCurrentROOT^.ObjArray,
    cdwg^.GetCurrentROOT^.ObjToConnectedArray,cdwg^,DC,0,[]);
  //drawings.GetCurrentDWG^.OGLwindow1.draw;
  //prn.startrender;

  pd1:=PrinterDrawer.ProjectPoint3DInModelSpace(point1,dc.DrawingContext.matrixs);
  pd2:=PrinterDrawer.ProjectPoint3DInModelSpace(point2,dc.DrawingContext.matrixs);
  PrinterDrawer.canvas.ClipRect:=rect(round(pd1.x),round(pd1.y),round(pd2.x),round(pd2.y));
  PrinterDrawer.canvas.Clipping:=true;
  cdwg^.wa.treerender(cdwg^.GetCurrentROOT^.ObjArray.ObjTree,0,{0}dc);
  //prn.endrender;
  inc(cdwg^.pcamera^.DRAWCOUNT);

  //----Printer.EndDoc;
  cdwg^.pcamera^.projMatrix:=tmatrix;

  if PrintParam.Palette<>PC_Color then
    PopPalette;
  dc.DrawingContext.ForeGroundColorIndex:=oldforegroundindex;

  {except
    on E:Exception do
    begin
      Printer.Abort;
      zcUI.TextMessage(e.message,TMWOShowError);
    end;
  end;}
  zcRedrawCurrentDrawing;
end;

begin
end.
