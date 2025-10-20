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

unit uzgldrawergdi;
{$INCLUDE zengineconfig.inc}
interface
uses
    uzgprimitivessarray,sysutils,uzgldrawergeneral2d,uzelclintfex,
    fileutil,math,uzefontmanager,uzefont,uzglviewareaabstract,
    {$IFNDEF DELPHI}LazUTF8,{$ENDIF}uzglgeomdata,uzgldrawcontext,uzgprimitives,
    uzgprimitivescreatorabstract,uzgprimitivescreator,uzepalette,
    {$IFDEF WINDOWS}windows,{$ENDIF}{$IFDEF DELPHI}windows,{$ENDIF}
    {$IFDEF LCLGTK2}
    Gtk2Def,
    {$ENDIF}
    {$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}
    qtobjects,
    {$ENDIF}
    {$if DEFINED(LCLQt5)}
    qt5,
    {$ENDIF}
    {$IFNDEF DELPHI}LCLIntf,LCLType,{$ENDIF}
    Classes,Controls,
    uzegeometrytypes,uzegeometry,uzgldrawergeneral,uzgldrawerabstract,
    Graphics,uzbLogIntf,gzctnrVectorTypes,uzgvertex3sarray,uzglvectorobject,
    uzeconsts,uzefontshx;
const
  NeedScreenInvalidrect=true;
type
{EXPORT+}
{REGISTERRECORDTYPE TGDIPrimitivesCounter}
TGDIPrimitivesCounter=record
          Lines:Integer;
          Triangles:Integer;
          Quads:Integer;
          Points:Integer;
          ZGLSymbols:Integer;
          SystemSymbols:Integer;
    end;
TTextRenderingType=(TRT_System,TRT_ZGL,TRT_Both);
PTGDIData=^TGDIData;
{REGISTERRECORDTYPE TGDIData}
TGDIData=record
          RD_TextRendering:TTextRenderingType;
          RD_DrawDebugGeometry:Boolean;
          DebugCounter:TGDIPrimitivesCounter;
          RD_Renderer:String;(*'Device'*)(*oi_readonly*)
          RD_Version:String;(*'Version'*)(*oi_readonly*)
    end;
{EXPORT-}
TGDIFontCacheKey=record
                       RealSizeInPixels:Integer;
                       PFontRecord:PGDBFontRecord;
                 end;
{TGDIFontCacheData=record
                       Handle:HFONT;
                  end;}
PTLLGDISymbol=^TLLGDISymbol;
{---REGISTEROBJECTTYPE TLLGDISymbol}
TLLGDISymbol= object(TLLSymbol)
              procedure drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam;const inFrustumState:TInBoundingVolume);virtual;
        end;
TLLGDIPrimitivesCreator=class(TLLPrimitivesCreator)
                             function CreateLLSymbol(var pa:TLLPrimitivesArray):TArrayIndex;override;
                        end;
TZGLGDIDrawer=class(TZGLGeneral2DDrawer)
                        public
                        OffScreedDC:HDC;
                        CanvasDC:HDC;
                        OffscreenBitmap:HBITMAP;
                        SavedBitmap:HBITMAP;
                        SavedDC:HDC;
                        hLinePen:HPEN;
                        hBrush:HBRUSH;
                        CurrentPaintGDIData:PTGDIData;

                        constructor create;

                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;
                        procedure createoffscreendc;
                        procedure deleteoffscreendc;
                        procedure endpaint(InPaintMessage:boolean);override;

                        procedure InternalDrawLine(const x1,y1,x2,y2:TStoredType);override;
                        procedure InternalDrawTriangle(const x1,y1,x2,y2,x3,y3:TStoredType);override;
                        procedure InternalDrawQuad(const x1,y1,x2,y2,x3,y3,x4,y4:TStoredType);override;
                        procedure InternalDrawPoint(const x,y:TStoredType);override;

                        function CreateScrbuf:boolean; override;
                        procedure delmyscrbuf; override;
                        procedure SaveBuffers;override;
                        procedure RestoreBuffers;override;
                        procedure SwapBuffers;override;
                        procedure SetDrawMode(const mode:TZGLDrawMode);override;
                        procedure ClearScreen(stencil:boolean);override;
                        procedure _createPen;override;

                        function GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;override;
                        procedure PostRenderDraw;override;
                   end;
{$IFDEF WINDOWS}
(*TZGLGDIPlusDrawer=class(TZGLGDIDrawer)
                        graphicsGDIPlus:TGPGraphics;
                        pen: TGPPen;
                        HDC: HDC;
                        lpPaint: TPaintStruct;
                        public
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;
                        procedure endrender;override;
                        procedure DrawLine(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2:TLLVertexIndex);override;
                        procedure DrawPoint(const PVertexBuffer:PGDBOpenArrayOfData;const i:TLLVertexIndex);override;
                   end;*)
{$ENDIF}
var
   OGLDrawer:TZGLAbstractDrawer;
   GDIDrawer:TZGLGDIDrawer;
   code:integer;
   LLGDIPrimitivesCreator:TLLGDIPrimitivesCreator;
   {$IFDEF WINDOWS}(*GDIPlusDrawer:TZGLGDIPlusDrawer;*){$ENDIF}
implementation
//uses log;
procedure isWindowsErrors;
begin

     {$IFDEF WINDOWS}
//     code:=code;
     code:=0;
     code:=GetLastError;
//     if code<>0 then
//                    code:=code;
     SetLastError(0);
     code:=0;
     {$ENDIF}

end;
{$IFDEF WINDOWS}
(*
procedure TZGLGDIPlusDrawer.startrender;
begin
     canvas:=canvas;
     {if not assigned(graphicsGDIPlus)then
     begin}
     graphicsGDIPlus := TGPGraphics.Create(Canvas.Handle);
     pen:= TGPPen.Create(MakeColor(255, 0, 0, 0), 1);
     //end;
end;

procedure TZGLGDIPlusDrawer.endrender;
begin
     canvas:=canvas;
     pen.Free;
     graphicsGDIPlus.Free;
end;

procedure TZGLGDIPlusDrawer.DrawLine(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(i2));
    //graphicsGDIPlus.DrawLine(Pen,pv1.x,midline-pv1.y,pv2.x,midline-pv2.y);
end;

procedure TZGLGDIPlusDrawer.DrawPoint(const PVertexBuffer:PGDBOpenArrayOfData;const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
begin
     pv:=PGDBVertex3S(PVertexBuffer.getDataMutable(i));
     //graphicsGDIPlus.Drawpoint(Pen,pv.x,midline-pv.y);
end;
*)
{$ENDIF}
procedure TZGLGDIDrawer.PostRenderDraw;
var
   s:String;
   //r:trect;
   TM: TTextMetric;
   x,y:integer;
begin
     if CurrentPaintGDIData<>nil then
     if CurrentPaintGDIData^.RD_DrawDebugGeometry then
     begin
       SetBkMode(OffScreedDC,{TRANSPARENT}OPAQUE );
       SetTextColor(OffScreedDC,PenColor);
       SelectObject(OffScreedDC,GetStockObject(SYSTEM_FONT));
       GetTextMetrics(OffScreedDC,tm);
       {$IFDEF WINDOWS}SetTextAlign(OffScreedDC,TA_TOP or TA_LEFT);{$ENDIF}
       x:=10;y:=10;
       s:=format('Lines: %d         ',[CurrentPaintGDIData^.DebugCounter.Lines]);
       TextOut(OffScreedDC,x,y,@s[1],length(s));

       inc(y,tm.tmHeight);
       s:=format('Triangles: %d         ',[CurrentPaintGDIData^.DebugCounter.Triangles]);
       TextOut(OffScreedDC,x,y,@s[1],length(s));

       inc(y,tm.tmHeight);
       s:=format('Quads: %d         ',[CurrentPaintGDIData^.DebugCounter.Quads]);
       TextOut(OffScreedDC,x,y,@s[1],length(s));

       inc(y,tm.tmHeight);
       s:=format('Points: %d         ',[CurrentPaintGDIData^.DebugCounter.Points]);
       TextOut(OffScreedDC,x,y,@s[1],length(s));

       inc(y,tm.tmHeight);
       s:=format('ZGLSymbols: %d         ',[CurrentPaintGDIData^.DebugCounter.ZGLSymbols]);
       TextOut(OffScreedDC,x,y,@s[1],length(s));

       inc(y,tm.tmHeight);
       s:=format('SystemSymbols: %d         ',[CurrentPaintGDIData^.DebugCounter.SystemSymbols]);
       TextOut(OffScreedDC,x,y,@s[1],length(s));

       CorrectScreenInvalidrect(wh.cx,wh.cy);
       DrawLine2DInDCS(ScreenInvalidRect.Left,ScreenInvalidRect.top,ScreenInvalidRect.right,ScreenInvalidRect.bottom);
       DrawLine2DInDCS(ScreenInvalidRect.right,ScreenInvalidRect.top,ScreenInvalidRect.left,ScreenInvalidRect.bottom);
     end;
end;

constructor TZGLGDIDrawer.create;
begin
     inherited;
     SavedBitmap:=0;
     OffScreedDC:=0;
end;
procedure TZGLGDIDrawer.SetDrawMode(const mode:TZGLDrawMode);
begin
     case mode of
        TDM_Normal:
                   begin
                        SetROP2(OffScreedDC,R2_COPYPEN);
                   end;
            TDM_OR:
                   begin
                        SetROP2(OffScreedDC,R2_MERGEPEN);
                   end;
           TDM_XOR:
                     begin
                          SetROP2(OffScreedDC,R2_XORPEN);
                     end;
     end;
end;
procedure TZGLGDIDrawer.createoffscreendc;
begin
     if OffScreedDC=0 then
     begin
        OffScreedDC:=CreateCompatibleDC(CanvasDC);
        OffscreenBitmap:=CreateCompatibleBitmap(CanvasDC,wh.cx,wh.cy);
        SelectObject(OffScreedDC,OffscreenBitmap);
        hLinePen:=CreatePen(PS_SOLID, 1, PenColor);
        SelectObject(OffScreedDC, hLinePen);
     end;
end;
procedure TZGLGDIDrawer.deleteoffscreendc;
begin
     if OffScreedDC<>0 then
     begin
         DeleteObject(OffscreenBitmap);
         OffscreenBitmap:=0;
         DeleteObject(hLinePen);
         hLinePen:=0;
         DeleteDC(OffScreedDC);
         OffScreedDC:=0;
     end;
end;

function TZGLGDIDrawer.startpaint;
begin
     CurrentPaintGDIData:=wa.getParam;
     if CurrentPaintGDIData<>nil then
                                     FillChar(CurrentPaintGDIData^.DebugCounter,sizeof(CurrentPaintGDIData^.DebugCounter),0);
     CanvasDC:=0;
     isWindowsErrors;
     if InPaintMessage and (canvas<>nil) then
       CanvasDC:=(canvas.Handle)
     else
       CanvasDC:=GetDC(panel.Handle);
     createoffscreendc;
     isWindowsErrors;
     result:=CreateScrbuf;
     PState:=TPaintState.TPSBufferNotSaved;
end;
procedure TZGLGDIDrawer.endpaint;
begin
     if not InPaintMessage then
     ReleaseDC(panel.Handle,CanvasDC);
     CurrentPaintGDIData:=nil;
end;
function TZGLGDIDrawer.CreateScrbuf:boolean;
begin
     result:=false;
     {$IFNDEF LCLGTK2}if (wh.cx>0)and(wh.cy>0) then{$ENDIF}
     if SavedBitmap=0 then
     if CanvasDC<>0 then
     begin
          SavedDC:=CreateCompatibleDC({CanvasDC}0);
          isWindowsErrors;
          SavedBitmap:=CreateCompatibleBitmap({SavedDC}CanvasDC,wh.cx,wh.cy);
          isWindowsErrors;
          SelectObject(SavedDC,SavedBitmap);
          isWindowsErrors;
          result:=true;
          createoffscreendc;
     end;
end;
procedure TZGLGDIDrawer.delmyscrbuf;
begin
     if SavedBitmap<>0 then
     begin
     DeleteObject(SavedBitmap);
     isWindowsErrors;
     DeleteDC(SavedDC);
     isWindowsErrors;
     SavedBitmap:=0;
     SavedDC:=0;
     end;
     deleteoffscreendc;
end;
procedure TZGLGDIDrawer.SaveBuffers;
begin
    {$IFDEF LCLGTK2}
     if TGtkDeviceContext(SavedDC).drawable=nil
     then
         delmyscrbuf
     else
    {$ENDIF}
         {$IFDEF WINDOWS}windows.{$ENDIF}BitBlt(SavedDC,0,0,wh.cx,wh.cy,OffScreedDC,0,0,SRCCOPY);
     isWindowsErrors;
     PState:=TPaintState.TPSBufferSaved;
     InitScreenInvalidrect(wh.cx,wh.cy);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.RestoreBuffers;
//var i:integer;
begin
     //windows.BitBlt(OffScreedDC,0,0,100,100,SavedDC,0,0,SRCCOPY);
    CorrectScreenInvalidrect(wh.cx,wh.cy);
    //{$IFDEF WINDOWS}windows.{$ENDIF}BitBlt(OffScreedDC,0,0,w,h,SavedDC,0,0,SRCCOPY);
    {$IFDEF WINDOWS}windows.{$ENDIF}BitBlt(OffScreedDC,ScreenInvalidRect.Left,ScreenInvalidRect.Top,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1,SavedDC,ScreenInvalidRect.Left,ScreenInvalidRect.Top,SRCCOPY{WHITENESS});

    {StretchBlt experiments}
    //SetStretchBltMode(OffScreedDC,HALFTONE);
    //SetBrushOrgEx(OffScreedDC, 1, 1, nil);
    //for i:=0 to 1000 do
    //{$IFDEF WINDOWS}windows.{$ENDIF}StretchBlt(OffScreedDC,ScreenInvalidRect.Left-100,ScreenInvalidRect.Top-100,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1+200,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1+200,SavedDC,ScreenInvalidRect.Left,ScreenInvalidRect.Top,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1,SRCCOPY);
    //{$IFDEF WINDOWS}windows.{$ENDIF}StretchBlt(OffScreedDC,ScreenInvalidRect.Left-100,ScreenInvalidRect.Top-100,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1+200,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1+200,SavedDC,ScreenInvalidRect.Left-350,ScreenInvalidRect.Top-350,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1+700,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1+700,SRCCOPY);

    PState:=TPaintState.TPSBufferSaved;
    InitScreenInvalidrect(wh.cx,wh.cy);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.SwapBuffers;
begin
     //isWindowsErrors;
     //windows.BitBlt({canvas.Handle}CanvasDC,0,0,100,100,OffScreedDC,0,0,SRCCOPY);
     {$IFDEF WINDOWS}windows.{$ENDIF}BitBlt({canvas.Handle}CanvasDC,0,0,wh.cx,wh.cy,OffScreedDC,0,0,SRCCOPY);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.InternalDrawLine(const x1,y1,x2,y2:TStoredType);
var
   _x1,_y1,_x2,_y2:integer;
begin
     _x1:=round(x1);
     _y1:=round(y1);
     _x2:=round(x2);
     _y2:=round(y2);
     MoveToEx(OffScreedDC,_x1,_y1, nil);
     LineTo(OffScreedDC,_x2,_y2);
     if NeedScreenInvalidrect then
                                  begin
                                       ProcessScreenInvalidrect(_x1,_y1);
                                       ProcessScreenInvalidrect(_x2,_y2);
                                  end;
     if CurrentPaintGDIData<>nil then
                                     inc(CurrentPaintGDIData^.DebugCounter.Lines);
end;
procedure TZGLGDIDrawer.InternalDrawPoint(const x,y:TStoredType);
var
   _x,_y:integer;
begin
     _x:=round(x);
     _y:=round(y);
     //Canvas.Pixels[round(pv.x),round(pv.y)]:=canvas.Pen.Color;
     if NeedScreenInvalidrect then
                                  begin
                                       ProcessScreenInvalidrect(_x,_y);
                                  end;
     if CurrentPaintGDIData<>nil then
                                     inc(CurrentPaintGDIData^.DebugCounter.Points);
end;
procedure TZGLGDIDrawer.InternalDrawTriangle(const x1,y1,x2,y2,x3,y3:TStoredType);
var
    sp:array [1..3]of TPoint;
begin
    sp[1].x:=round(x1);
    sp[1].y:=round(y1);
    sp[2].x:=round(x2);
    sp[2].y:=round(y2);
    sp[3].x:=round(x3);
    sp[3].y:=round(y3);
    PolyGon(OffScreedDC,{$IFNDEF DELPHI}@{$ENDIF}sp[1],3{$IFNDEF DELPHI},false{$ENDIF});
    if NeedScreenInvalidrect then
                                 begin
                                      ProcessScreenInvalidrect(sp[1].x,sp[1].y);
                                      ProcessScreenInvalidrect(sp[2].x,sp[2].y);
                                      ProcessScreenInvalidrect(sp[3].x,sp[3].y);
                                 end;
    if CurrentPaintGDIData<>nil then
                                    inc(CurrentPaintGDIData^.DebugCounter.Triangles);
end;
procedure TZGLGDIDrawer.InternalDrawQuad(const x1,y1,x2,y2,x3,y3,x4,y4:TStoredType);
var
    sp:array [1..4]of TPoint;
begin
    sp[1].x:=round(x1);
    sp[1].y:=round(y1);
    sp[2].x:=round(x2);
    sp[2].y:=round(y2);
    sp[3].x:=round(x3);
    sp[3].y:=round(y3);
    sp[4].x:=round(x4);
    sp[4].y:=round(y4);
    PolyGon(OffScreedDC,{$IFNDEF DELPHI}@{$ENDIF}sp[1],4{$IFNDEF DELPHI},false{$ENDIF});
    //PolyGon(OffScreedDC,@sp[1],4,false);
    if NeedScreenInvalidrect then
                                 begin
                                      ProcessScreenInvalidrect(sp[1].x,sp[1].y);
                                      ProcessScreenInvalidrect(sp[2].x,sp[2].y);
                                      ProcessScreenInvalidrect(sp[3].x,sp[3].y);
                                      ProcessScreenInvalidrect(sp[4].x,sp[4].y);
                                 end;
    if CurrentPaintGDIData<>nil then
                                    inc(CurrentPaintGDIData^.DebugCounter.Quads);
end;
procedure TZGLGDIDrawer._createPen;
var
   ps:integer;
begin
  deleteobject(hLinePen);
  deleteobject(hBrush);

  case penstyle of
              TPS_Solid:
                        ps:=PS_SOLID;
              TPS_Dot:
                      ps:=PS_DOT;
              TPS_Dash:
                       ps:=PS_DASH;
          TPS_Selected:
                       ps:=PS_DOT;
  end;
  SetBkColor(OffScreedDC,ClearColor);
  {$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}
  if linewidth=1 then
    linewidth:=0;
  {$ENDIF}
  hLinePen:=CreatePen(ps,linewidth,PenColor);
  {$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}
  TQtPen(hLinePen).setCosmetic(True);
  {$ENDIF}

  SelectObject(OffScreedDC, hLinePen);


  hBrush:=CreateSolidBrush(PenColor);
  SelectObject(OffScreedDC, hBrush);
end;

procedure TZGLGDIDrawer.ClearScreen(stencil:boolean);
var
  mRect: TRect;
  _ClearBrush: {$IFDEF DELPHI}windows.{$ENDIF}HBRUSH;
  _LogBrush: TLogBrush;
begin
     mrect:=Rect(0,0,wh.cx,wh.cy);
     with _LogBrush do
     begin
       lbStyle := {BS_HATCHED}BS_SOLID;
       lbColor := ClearColor;
       lbHatch := HS_CROSS
     end;
     _ClearBrush:=CreateBrushIndirect(_LogBrush);
     isWindowsErrors;
     FillRect(OffScreedDC,mRect,_ClearBrush);
     isWindowsErrors;
     deleteobject(_ClearBrush);
     isWindowsErrors;
end;

function TZGLGDIDrawer.GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;
begin
     result:=LLGDIPrimitivesCreator;
end;
function TLLGDIPrimitivesCreator.CreateLLSymbol(var pa:TLLPrimitivesArray):TArrayIndex;
var
   pgdisymbol:PTLLGDISymbol;
begin
  pa.AlignDataSize;
     result:=pa.count;
     pointer(pgdisymbol):=pa.getDataMutable(pa.AllocData(sizeof(TLLGDISymbol)));
     pgdisymbol.init;
end;

// Отрисовка SHX примитивов через GDI
// Rendering SHX primitives using GDI
procedure RenderSHXPrimitivesWithGDI(DC:HDC;const FontData:PZGLVectorObject;const LLPOffset,LLPCount:TArrayIndex;const Transform:DMatrix4D;const ScreenTransform:TZGLGDIDrawer);
var
  i,primIndex:TArrayIndex;
  PPrimitive:PTLLPrimitive;
  PLine:PTLLLine;
  PPolyLine:PTLLPolyLine;
  PTriangle:PTLLTriangle;
  pv1,pv2:PGDBvertex;
  v1,v2:GDBvertex;
  pts:array of TPoint;
  j:integer;
begin
  // Проходим по низкоуровневым примитивам и рисуем их через GDI
  // Iterate through low-level primitives and render using GDI
  primIndex:=LLPOffset;
  i:=0;
  while i<LLPCount do begin
    PPrimitive:=pointer(FontData^.LLprimitives.getDataMutable(primIndex));

    // Пытаемся интерпретировать как линию и проверяем валидность данных
    // Try to cast as TLLLine and check if it has valid data
    PLine:=PTLLLine(PPrimitive);
    if (PLine^.P1Index>=0) and (PLine^.P1Index+1<FontData^.GeomData.Vertex3S.Count) then begin
      // Получаем вершины линии
      // Get line vertices
      pv1:=FontData^.GeomData.Vertex3S.getDataMutable(PLine^.P1Index);
      pv2:=FontData^.GeomData.Vertex3S.getDataMutable(PLine^.P1Index+1);

      // Применяем трансформацию символа к вершинам
      // Transform vertices with symbol transformation
      v1:=VectorTransform3d(pv1^,Transform);
      v2:=VectorTransform3d(pv2^,Transform);

      // Преобразуем в экранные координаты
      // Transform to screen coordinates
      v1:=ScreenTransform.TranslatePoint(v1);
      v2:=ScreenTransform.TranslatePoint(v2);

      // Рисуем линию
      // Draw line
      MoveToEx(DC,round(v1.x),round(v1.y),nil);
      LineTo(DC,round(v2.x),round(v2.y));
    end;

    primIndex:=primIndex+PPrimitive^.getPrimitiveSize;
    inc(i);
  end;
end;

procedure TLLGDISymbol.drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam;const inFrustumState:TInBoundingVolume);
var
   r:TRect;

   point,spoint:GDBVertex3S;
   x,y:integer;
   s:AnsiString;
   {$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}_transminusM2,{$ENDIF}_transminusM,_obliqueM,_transplusM,_scaleM,_rotateM:DMatrix4D;
   {gdiDrawYOffset,}txtOblique,txtRotate,txtSx,txtSy:single;

   lfcp:TLogFont;
   isSHXFont:Boolean;

const
  deffonth={19}100;
  cnvStr:packed array[0..3]of byte=(0,0,0,0);
begin
     // Если шрифт не поддерживает системную отрисовку, используем ZGL рендеринг
     // If font doesn't support system drawing, use ZGL rendering
     if not PSymbolsParam^.IsCanSystemDraw then
                                           begin
                                                inherited;
                                                inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.ZGLSymbols);
                                                exit;
                                           end;
  // Проверяем режим рендеринга текста
  // Check text rendering mode
  if TZGLGDIDrawer(drawer).CurrentPaintGDIData^.RD_TextRendering<>TRT_System then
                                                                                 begin
                                                                                 inherited;//там вывод букв треугольниками / text output using triangles
                                                                                 inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.ZGLSymbols);
                                                                                 end;
  if TZGLGDIDrawer(drawer).CurrentPaintGDIData^.RD_TextRendering=TRT_ZGL then
                                                                             exit;

  // Проверяем, является ли это SHX шрифтом по типу реализации шрифта
  // Check if this is an SHX font by checking the font implementation type
  isSHXFont:=PGDBfont(PSymbolsParam.pfont)^.font is TZESHXFontImpl;

  if PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle=0
  then
      begin
            lfcp.lfHeight:=deffonth;
            lfcp.lfWidth:=0;
            lfcp.lfEscapement:=0;
            lfcp.lfOrientation:=0;
            lfcp.lfWeight:=FW_NORMAL;
            lfcp.lfItalic:=0;
            lfcp.lfUnderline:=0;
            lfcp.lfStrikeOut:=0;
            lfcp.lfCharSet:=DEFAULT_CHARSET;
            lfcp.lfOutPrecision:=0;
            lfcp.lfClipPrecision:=0;
            lfcp.lfQuality:=0;
            lfcp.lfPitchAndFamily:=0;
            {$IFNDEF DELPHI}
            lfcp.lfFaceName:=PGDBfont(PSymbolsParam.pfont)^.family;
            {$ENDIF}
           PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle:=CreateFontIndirect(lfcp);
           SelectObject(TZGLGDIDrawer(drawer).OffScreedDC,PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle);
      end
  else
      begin
           SelectObject(TZGLGDIDrawer(drawer).OffScreedDC,PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle);
      end;

  point.x:=0;
  point.y:=0;
  point.z:=0;
  point:=VectorTransform3d(point,self.SymMatr);
  spoint:=TZGLGDIDrawer(drawer).TranslatePoint(point);
  x:=round(spoint.x);
  y:=round(spoint.y);
  {$IFNDEF DELPHI}
  cnvStr[0]:=lo(word(SymCode));
  cnvStr[1]:=hi(word(SymCode));
  s:=UTF16ToUTF8(@cnvStr,1);
  {$ENDIF}

  txtOblique:=pi/2-PSymbolsParam^.Oblique;
  txtRotate:=PSymbolsParam^.Rotate;
  {txtSy:=TQtFont(PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle).Metrics.ascent;
  txtSy:=TQtFont(PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle).Metrics.descent;
  txtSy:=TQtFont(PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle).Metrics.height;}
  txtSy:=PSymbolsParam^.NeededFontHeight/(rc.DrawingContext.zoom)/(deffonth);
  {$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}txtSy:=txtSy*(deffonth)/(TQtFont(PGDBfont(PSymbolsParam.pfont)^.DummyDrawerHandle).Metrics.height-1);{$ENDIF}
  txtSx:=txtSy*PSymbolsParam^.sx;

  SetBkMode(TZGLGDIDrawer(drawer).OffScreedDC,TRANSPARENT);
  if TZGLGDIDrawer(drawer).CurrentPaintGDIData^.RD_TextRendering<>TRT_Both then
                                                                               SetTextColor(TZGLGDIDrawer(drawer).OffScreedDC,TZGLGDIDrawer(drawer).PenColor)
                                                                           else
                                                                               SetTextColor(TZGLGDIDrawer(drawer).OffScreedDC,TZGLGDIDrawer(drawer).ClearColor);

  SetTextAlignToBaseLine(TZGLGDIDrawer(drawer).OffScreedDC);

  // Обработка текста SHX и TTF рендрингом GDI происходит по-разному
  // SHX и TTF fonts require different rendering approaches with GDI
  if isSHXFont and (PExternalVectorObject<>nil) and (ExternalLLPCount>0) then
  begin
    // Для SHX шрифтов: рисуем векторные примитивы без трансформации контекста
    // For SHX fonts: render vector primitives without context transformation
    // Трансформация уже применена к примитивам внутри RenderSHXPrimitivesWithGDI
    // Transformation is already applied to primitives inside RenderSHXPrimitivesWithGDI
    RenderSHXPrimitivesWithGDI(TZGLGDIDrawer(drawer).OffScreedDC,
                               PZGLVectorObject(PExternalVectorObject),
                               ExternalLLPOffset,
                               ExternalLLPCount,
                               SymMatr,
                               TZGLGDIDrawer(drawer));
    inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.SystemSymbols);
  end
  else
  begin
    // Для TTF шрифтов: применяем трансформацию (Scale, Rotate, Oblique) через WorldTransform
    // For TTF fonts: apply transformation (Scale, Rotate, Oblique) via WorldTransform
    // Строим матрицу: T(x,y) × Rotate × Oblique × Scale
    // Build matrix: T(x,y) × Rotate × Oblique × Scale
    // Эта матрица будет применена к точке (0,0) при рисовании
    // This matrix will be applied to point (0,0) during rendering

    _scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
    if txtOblique<>0 then begin
      _obliqueM.CreateRec(OneMtr,CMTShear);
      _obliqueM.mtr[1].v[0]:=-cotan(txtOblique);
    end
    else
      _obliqueM:=OneMatrix;
    _rotateM:=CreateRotationMatrixZ(-txtRotate);
    _transplusM:=CreateTranslationMatrix(CreateVertex(x,y,0));

    // Применяем трансформации для TTF шрифта: T(x,y) × Rotate × Oblique × Scale
    // Apply transformations for TTF font: T(x,y) × Rotate × Oblique × Scale
    // Порядок справа налево: сначала Scale, потом Oblique, потом Rotate, потом T(x,y)
    // Order right to left: first Scale, then Oblique, then Rotate, then T(x,y)
    _transminusM:=_scaleM;
    _transminusM:=MatrixMultiply(_transminusM,_obliqueM);
    _transminusM:=MatrixMultiply(_transminusM,_rotateM);
    _transminusM:=MatrixMultiply(_transminusM,_transplusM);

    // Устанавливаем трансформацию для TTF текста
    // Set transformation for TTF text
    SetGraphicsMode_(TZGLGDIDrawer(drawer).OffScreedDC, GM_ADVANCED);
    SetWorldTransform_(TZGLGDIDrawer(drawer).OffScreedDC,_transminusM);

    // Рисуем TTF текст в точке (0,0), трансформация применится автоматически
    // Render TTF text at point (0,0), transformation will be applied automatically
    ExtTextOut(TZGLGDIDrawer(drawer).OffScreedDC,0,0{+round(gdiDrawYOffset)},{Options: Longint}0,@r,@s[1],-1,nil);
    inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.SystemSymbols);

    // Возвращаем обычный режим
    // Restore normal mode
    SetWorldTransform_(TZGLGDIDrawer(drawer).OffScreedDC,OneMatrix);
    SetGraphicsMode_(TZGLGDIDrawer(drawer).OffScreedDC, GM_COMPATIBLE);
  end;
end;

initialization
  GDIDrawer:=TZGLGDIDrawer.create;
  LLGDIPrimitivesCreator:=TLLGDIPrimitivesCreator.Create;
  {$IFDEF WINDOWS}(*GDIPlusDrawer:=TZGLGDIPlusDrawer.create;*){$ENDIF}
finalization
  zDebugln('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  GDIDrawer.Destroy;
  LLGDIPrimitivesCreator.Destroy;
  {$IFDEF WINDOWS}(*GDIPlusDrawer.Destroy;*){$ENDIF}
end.

