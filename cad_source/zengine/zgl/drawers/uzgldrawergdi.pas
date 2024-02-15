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
    Graphics,LazLogger,gzctnrVectorTypes,uzgvertex3sarray;
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
              procedure drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam);virtual;
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
procedure TLLGDISymbol.drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:TLLPrimitivesArray;var OptData:ZGLOptimizerData;const PSymbolsParam:PTSymbolSParam);
var
   r:TRect;

   point,spoint:GDBVertex3S;
   x,y:integer;
   s:AnsiString;
   {$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}_transminusM2,{$ENDIF}_transminusM,_obliqueM,_transplusM,_scaleM,_rotateM:DMatrix4D;
   {gdiDrawYOffset,}txtOblique,txtRotate,txtSx,txtSy:single;

   lfcp:TLogFont;

const
  deffonth={19}100;
  cnvStr:packed array[0..3]of byte=(0,0,0,0);
begin
     if not PSymbolsParam^.IsCanSystemDraw then
                                           begin
                                                inherited;
                                                inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.ZGLSymbols);
                                                exit;
                                           end;
  if TZGLGDIDrawer(drawer).CurrentPaintGDIData^.RD_TextRendering<>TRT_System then
                                                                                 begin
                                                                                 inherited;//там вывод букв треугольниками
                                                                                 inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.ZGLSymbols);
                                                                                 end;
  if TZGLGDIDrawer(drawer).CurrentPaintGDIData^.RD_TextRendering=TRT_ZGL then
                                                                             exit;

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
  {$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}_transminusM2:=CreateTranslationMatrix(CreateVertex(0,-TQtDeviceContext(TZGLGDIDrawer(drawer).OffScreedDC).Metrics.ascent,0));{$ENDIF}
  _transminusM:=CreateTranslationMatrix(CreateVertex(-x,-y,0));
  _scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
  _obliqueM:=OneMatrix;
  if txtOblique<>0 then
                       _obliqueM[1].v[0]:=-cotan(txtOblique);
  _transplusM:=CreateTranslationMatrix(CreateVertex(x,y,0));
  _rotateM:=CreateRotationMatrixZ(sin(-txtRotate),cos(-txtRotate));

  {$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}_transminusM:=MatrixMultiply(_transminusM,_transminusM2);{$ENDIF}
  _transminusM:=MatrixMultiply(_transminusM,_scaleM);
  _transminusM:=MatrixMultiply(_transminusM,_obliqueM);
  _transminusM:=MatrixMultiply(_transminusM,_rotateM);
  _transminusM:=MatrixMultiply(_transminusM,_transplusM);



  SetGraphicsMode_(TZGLGDIDrawer(drawer).OffScreedDC, GM_ADVANCED );
  SetWorldTransform_(TZGLGDIDrawer(drawer).OffScreedDC,_transminusM);

  //DrawText(TZGLGDIDrawer(drawer).OffScreedDC,'h',1,r,{Flags: Cardinal}0);
  //TextOut(TZGLGDIDrawer(drawer).OffScreedDC, x, y, 'h', 1);
  ExtTextOut(TZGLGDIDrawer(drawer).OffScreedDC,x,y{+round(gdiDrawYOffset)},{Options: Longint}0,@r,@s[1],-1,nil);
  inc(TZGLGDIDrawer(drawer).CurrentPaintGDIData^.DebugCounter.SystemSymbols);

  SetWorldTransform_(TZGLGDIDrawer(drawer).OffScreedDC,OneMatrix);
  SetGraphicsMode_(TZGLGDIDrawer(drawer).OffScreedDC, GM_COMPATIBLE );
end;

initialization
  GDIDrawer:=TZGLGDIDrawer.create;
  LLGDIPrimitivesCreator:=TLLGDIPrimitivesCreator.Create;
  {$IFDEF WINDOWS}(*GDIPlusDrawer:=TZGLGDIPlusDrawer.create;*){$ENDIF}
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  GDIDrawer.Destroy;
  LLGDIPrimitivesCreator.Destroy;
  {$IFDEF WINDOWS}(*GDIPlusDrawer.Destroy;*){$ENDIF}
end.

