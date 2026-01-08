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

unit uzgldrawerogl;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzgindexsarray,uzbLogIntf,uzepalette,
  {$IFDEF LCLGTK2}
    Gtk2Def,
  {$ENDIF}
  {$IFNDEF DELPHI}LCLIntf,LCLType,{$ENDIF}
  Classes,Controls,
  uzgvertex3sarray,uzegeometry,uzgldrawergeneral,uzgldrawerabstract,
  uzgloglstatemanager,Graphics,uzbtypes,uzeTypes,
  uzegeometrytypes,uzecamera;

const
  texturesize=128;
type
TGLVersion=(GLV_1_0,GLV_1_2,GLV_1_3,GLV_1_4,
            GLV_1_5,GLV_2_0,GLV_2_1,GLV_3_0,
            GLV_3_1,GLV_3_2,GLV_3_3,GLV_4_0,
            GLV_4_3);

TOpenglData=record
          RD_DraverVersion:TGLVersion;(*'Draver version'*)(*oi_readonly*)
          RD_Renderer:String;(*'Device'*)(*oi_readonly*)
          RD_DriverVersion:String;(*'Driver version'*)(*oi_readonly*)
          RD_Extensions:String;(*'Extensions'*)(*oi_readonly*)
          RD_Vendor:String;(*'Vendor'*)(*oi_readonly*)
          RD_UseStencil:PBoolean;(*'Use STENCIL buffer'*)
          RD_Light:PBoolean;(*'Light'*)
          RD_LineSmooth:PBoolean;(*'Line smoothing'*)
          RD_VSync:TGDB3StateBool;(*'VSync'*)
          RD_MaxWidth:Integer;(*'Max width'*)(*oi_readonly*)
          RD_MaxLineWidth:Double;(*'Max line width'*)(*oi_readonly*)
          RD_MaxPointSize:Double;(*'Max point size'*)(*oi_readonly*)
    end;
PTOpenglData=^TOpenglData;


TZGLOpenGLDrawer=class(TZGLGeneralDrawer)
                        myscrbuf:tmyscrbuf;
                        mm:TzeTypedMatrix4d;
                        public
                        procedure SetPenStyle(const style:TZGLPenStyle);override;
                        procedure SetDrawMode(const mode:TZGLDrawMode);override;
                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;
                        procedure endrender;override;
                        procedure DrawLine(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2:TLLVertexIndex);override;
                        procedure DrawTriangle(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3:TLLVertexIndex);override;
                        procedure DrawTrianglesFan(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);override;
                        procedure DrawTrianglesStrip(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);override;
                        procedure DrawQuad(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3,i4:TLLVertexIndex);override;
                        function CheckOutboundInDisplay(const PVertexBuffer:PZGLVertex3Sarray;const i1:TLLVertexIndex):boolean;override;
                        procedure DrawPoint(const PVertexBuffer:PZGLVertex3Sarray;const i:TLLVertexIndex);override;
                        procedure SetLineWidth(const w:single);override;
                        procedure SetPointSize(const s:single);override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure ClearScreen(stencil:boolean);override;
                        procedure TranslateCoord2D(const tx,ty:single);override;
                        procedure ScaleCoord2D(const sx,sy:single);override;
                        procedure SetLineSmooth(const smoth:boolean);override;
                        procedure SetPointSmooth(const smoth:boolean);override;
                        procedure ClearStatesMachine;override;
                        procedure SetFillStencilMode;override;
                        procedure SetSelectedStencilMode;override;
                        procedure SetDrawWithStencilMode;override;
                        procedure DisableStencil;override;
                        procedure SetZTest(Z:boolean);override;
                        {в координатах окна}
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:TStoredType);override;
                        procedure DrawQuad2DInDCS(const x1,y1,x2,y2:TStoredType);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of TStoredType);override;
                        {в координатах модели}
                        procedure DrawLine3DInModelSpace(const p1,p2:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawPoint3DInModelSpace(const p:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawTriangle3DInModelSpace(const normal,p1,p2,p3:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);override;

                        procedure SaveBuffers;override;
                        procedure RestoreBuffers;override;
                        function CreateScrbuf:boolean; override;
                        procedure delmyscrbuf; override;
                        procedure SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);override;

                        {}
                        procedure pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4d;FromOneMatrix:Boolean=False);overload;override;
                        procedure pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4s;FromOneMatrix:Boolean=False);overload;override;
                        procedure DisableLCS(var matrixs:tmatrixs);overload;override;
                        procedure EnableLCS(var matrixs:tmatrixs);overload;override;
                        procedure popMatrix;override;
                   end;
var
   code:integer;
implementation
//uses log;
procedure TZGLOpenGLDrawer.pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4d;FromOneMatrix:Boolean=False);
begin
  oglsm.myglPushMatrix;
  if FromOneMatrix {and (not LCS.notuseLCS)} then begin
    oglsm.myglLoadMatrixd(@mm);
    {LCS.notuseLCS:=true;
    LCS.CurrentCamCSOffset:=NulVertex;
    LCS.CurrentCamCSOffsetS:=NulVertex3S;}
  end;
  oglsm.myglMultMatrixD(Transform)
end;
procedure TZGLOpenGLDrawer.pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4s;FromOneMatrix:Boolean=False);
begin
  oglsm.myglPushMatrix;
  if FromOneMatrix and (not LCS.notuseLCS) then begin
    oglsm.myglLoadMatrixd(@mm);
    {LCS.notuseLCS:=true;
    LCS.CurrentCamCSOffset:=NulVertex;
    LCS.CurrentCamCSOffsetS:=NulVertex3S;}
  end;
  oglsm.myglMultMatrixF(Transform);
end;
procedure TZGLOpenGLDrawer.popMatrix;
begin
  //LCS:=LCSSave;
  oglsm.myglPopMatrix;
end;
procedure TZGLOpenGLDrawer.DisableLCS(var matrixs:tmatrixs);
begin
  LCS.notuseLCS:=true;
  LCS.CurrentCamCSOffset:=NulVertex;
  LCS.CurrentCamCSOffsetS:=NulVertex3S;
end;
procedure TZGLOpenGLDrawer.EnableLCS(var matrixs:tmatrixs);
begin
  LCS:=LCSSave;
end;
procedure TZGLOpenGLDrawer.DrawLine(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2:TLLVertexIndex);
begin
    oglsm.myglbegin(GL_LINES);
    oglsm.myglVertex3DV(PVertexBuffer.getDataMutable(i1));
    oglsm.myglVertex3DV(PVertexBuffer.getDataMutable(i2));
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawTriangle(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3:TLLVertexIndex);
begin
    oglsm.myglbegin(GL_TRIANGLES);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i1)^);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i2)^);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i3)^);
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawTrianglesFan(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);
var
   i{,index}:integer;
   pindex:PTLLVertexIndex;
begin
    oglsm.myglbegin(GL_TRIANGLE_FAN);
    for i:=i1 to i1+IndexCount-1 do
    begin
    pindex:=pointer(PIndexBuffer.getDataMutable(i));
    oglsm.myglVertex(PVertexBuffer.getDataMutable(pindex^)^);
    end;
    oglsm.myglend{mytotalglend};
end;
procedure TZGLOpenGLDrawer.DrawTrianglesStrip(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);
var
   i{,index}:integer;
   pindex:PTLLVertexIndex;
begin
    oglsm.myglbegin(GL_TRIANGLE_STRIP);
    for i:=i1 to i1+IndexCount-1 do
    begin
    pindex:=pointer(PIndexBuffer.getDataMutable(i));
    oglsm.myglVertex(PVertexBuffer.getDataMutable(pindex^)^);
    end;
    oglsm.myglend{mytotalglend};
end;
procedure TZGLOpenGLDrawer.DrawQuad(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3,i4:TLLVertexIndex);
begin
    oglsm.myglbegin(GL_QUADS);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i1)^);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i2)^);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i3)^);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i4)^);
    oglsm.myglend;
end;
function TZGLOpenGLDrawer.CheckOutboundInDisplay(const PVertexBuffer:PZGLVertex3Sarray;const i1:TLLVertexIndex):boolean;
begin
    result:=true;
end;

procedure TZGLOpenGLDrawer.DrawPoint(const PVertexBuffer:PZGLVertex3Sarray;const i:TLLVertexIndex);
begin
    oglsm.myglbegin(GL_points);
    oglsm.myglVertex(PVertexBuffer.getDataMutable(i)^);
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.TranslateCoord2D(const tx,ty:single);
begin
     oglsm.mygltranslated(tx, ty,0);
end;
procedure TZGLOpenGLDrawer.ScaleCoord2D(const sx,sy:single);
begin
     oglsm.myglscalef(sx,sy,1);
end;
procedure TZGLOpenGLDrawer.SetLineSmooth(const smoth:boolean);
begin
     if smoth then
                 begin
                      oglsm.myglEnable(GL_BLEND);
                      oglsm.myglBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
                      oglsm.myglEnable(GL_LINE_SMOOTH);
                      oglsm.myglHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
                 end
             else
                 begin
                      oglsm.myglDisable(GL_BLEND);
                      oglsm.myglDisable(GL_LINE_SMOOTH);
                 end;
end;
procedure TZGLOpenGLDrawer.SetPointSmooth(const smoth:boolean);
begin
     if smoth then
                 begin
                      oglsm.myglEnable(gl_point_smooth);
                 end
             else
                 begin
                      oglsm.myglDisable(gl_point_smooth);
                 end;
end;
procedure TZGLOpenGLDrawer.ClearStatesMachine;
begin
     oglsm.mytotalglend;
end;
procedure TZGLOpenGLDrawer.SetSelectedStencilMode;
begin
     oglsm.myglStencilFunc(GL_ALWAYS,0,1);
end;
procedure TZGLOpenGLDrawer.SetFillStencilMode;
begin
     oglsm.myglEnable(GL_STENCIL_TEST);
     oglsm.myglStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
     oglsm.myglStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
end;
procedure TZGLOpenGLDrawer.SetDrawWithStencilMode;
begin
    oglsm.myglEnable(GL_STENCIL_TEST);
    oglsm.myglStencilFunc(GL_EQUAL,0,1);
    oglsm.myglStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
end;
procedure TZGLOpenGLDrawer.DisableStencil;
begin
     oglsm.myglDisable(GL_STENCIL_TEST);
end;
procedure TZGLOpenGLDrawer.SetZTest(Z:boolean);
begin
     if Z then
             begin
                  oglsm.myglDepthFunc(GL_LEQUAL);
                  oglsm.myglEnable(GL_DEPTH_TEST);
             end
         else
             begin
                  oglsm.myglDisable(GL_DEPTH_TEST);
             end;
end;
procedure TZGLOpenGLDrawer.startrender;
begin
     OGLSM.startrender;
     case mode of
                 TRM_ModelSpace:
                 begin
                 end;
                 TRM_DisplaySpace,TRM_WindowSpace:
                 begin
                  oglsm.myglMatrixMode(GL_PROJECTION);
                  oglsm.myglLoadIdentity;
                  oglsm.myglOrtho(0.0,matrixs.pviewport.v[2],matrixs.pviewport.v[3], 0.0, -1.0, 1.0);
                  oglsm.myglMatrixMode(GL_MODELVIEW);
                  oglsm.myglLoadIdentity;
                  if mode=TRM_DisplaySpace then
                  begin
                  oglsm.myglscalef(1, -1, 1);
                  oglsm.mygltranslated(0, -matrixs.pviewport.v[3], 0);
                  end;
                 end;
     end;
end;
function TZGLOpenGLDrawer.startpaint(InPaintMessage:boolean;w,h:integer):boolean;
begin
     if myscrbuf[0]=0 then
                          begin
                               result:=true;
                               CreateScrbuf;
                          end
                       else
                           result:=false;
end;

procedure TZGLOpenGLDrawer.endrender;
begin
     OGLSM.endrender;
end;
procedure TZGLOpenGLDrawer.SetColor(const red, green, blue, alpha: byte);
begin
     oglsm.glcolor3ub(red, green, blue);
end;
procedure TZGLOpenGLDrawer.ClearScreen(stencil:boolean);
begin
     if stencil then
                    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
                else
                    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;
procedure TZGLOpenGLDrawer.SetColor(const color: TRGB);
begin
     oglsm.glcolor3ubv(color);
end;
procedure TZGLOpenGLDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     oglsm.myglClearColor(red/255,green/255,blue/255,alpha/255);
end;
procedure TZGLOpenGLDrawer.SetLineWidth(const w:single);
begin
     if w>1 then begin
                      oglsm.mygllinewidth(w);
                      oglsm.myglEnable(GL_LINE_SMOOTH);
                      oglsm.myglpointsize(w);
                      oglsm.myglEnable(gl_point_smooth);
                 end
            else
                begin
                      oglsm.mygllinewidth(1);
                      oglsm.myglDisable(GL_LINE_SMOOTH);
                      oglsm.myglpointsize(1);
                      oglsm.myglDisable(gl_point_smooth);
                end;
end;
procedure TZGLOpenGLDrawer.SetPointSize(const s:single);
begin
     oglsm.myglpointsize(s);
end;
procedure TZGLOpenGLDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
begin
    oglsm.myglbegin(GL_lines);
              oglsm.myglVertex2i(x1,y1);
              oglsm.myglVertex2i(x2,y2);
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:TStoredType);
begin
    oglsm.myglbegin(GL_lines);
              oglsm.myglVertex2f(x1,y1);
              oglsm.myglVertex2f(x2,y2);
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawQuad2DInDCS(const x1,y1,x2,y2:TStoredType);
begin
  oglsm.myglbegin(GL_QUADS);
  oglsm.myglVertex2f(x1,y1);
  oglsm.myglVertex2f(x2,y1);
  oglsm.myglVertex2f(x2,y2);
  oglsm.myglVertex2f(x1,y2);
  oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawClosedPolyLine2DInDCS(const coords:array of TStoredType);
var
   i:integer;
begin
     i:=0;
     oglsm.myglbegin(GL_line_loop);
     while i<high(coords) do
     begin
          oglsm.myglVertex2f(coords[i],coords[i+1]);
          inc(i,2);
     end;
     oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.SaveBuffers;
  var
    scrx,scry,texture{,e}:integer;
begin
  oglsm.myglEnable(GL_TEXTURE_2D);
  //isOpenGLError;

   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
         repeat
               oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
               //isOpenGLError;
               oglsm.myglCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,scrx,scry,texturesize,texturesize);
               //isOpenGLError;
               scrx:=scrx+texturesize;
               inc(texture);
         until scrx>wh.cx;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>wh.cy;


  oglsm.myglDisable(GL_TEXTURE_2D);
end;
procedure TZGLOpenGLDrawer.RestoreBuffers;
  var
    scrx,scry,texture{,e}:integer;
    _NotUseLCS:boolean;
begin
  _NotUseLCS:=LCS.NotUseLCS;
  LCS.NotUseLCS:=true;
  oglsm.myglEnable(GL_TEXTURE_2D);
  oglsm.myglDisable(GL_DEPTH_TEST);
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
       oglsm.myglOrtho(0.0, wh.cx, 0.0, wh.cy, -10.0, 10.0);
       oglsm.myglMatrixMode(GL_MODELVIEW);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
  begin
   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
   repeat
         oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
         //isOpenGLError;
         SetColor(255,255,255,255);
         oglsm.myglbegin(GL_quads);
                 oglsm.myglTexCoord2d(0,0);
                 oglsm.myglVertex2d(scrx,scry);
                 oglsm.myglTexCoord2d(1,0);
                 oglsm.myglVertex2d(scrx+texturesize,scry);
                 oglsm.myglTexCoord2d(1,1);
                 oglsm.myglVertex2d(scrx+texturesize,scry+texturesize);
                 oglsm.myglTexCoord2d(0,1);
                 oglsm.myglVertex2d(scrx,scry+texturesize);
         oglsm.myglend;
         oglsm.mytotalglend;
         //isOpenGLError;
         scrx:=scrx+texturesize;
         inc(texture);
   until scrx>wh.cx;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>wh.cy;
  end;
  oglsm.myglDisable(GL_TEXTURE_2D);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_MODELVIEW);
   LCS.NotUseLCS:=_NotUseLCS;
end;
function TZGLOpenGLDrawer.CreateScrbuf{(w,h:integer)}:boolean;
var scrx,scry,texture{,e}:integer;
begin
     //oglsm.mytotalglend;
     result:=false;
     if (wh.cx>0)and(wh.cy>0) then
     begin
     oglsm.myglEnable(GL_TEXTURE_2D);
     scrx:=0;  { TODO : Сделать генер текстур пакетом }
     scry:=0;
     texture:=0;
     repeat
           repeat
                 //if texture>80 then texture:=0;

                 oglsm.myglGenTextures(1, @myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglTexImage2D(GL_TEXTURE_2D,0,GL_RGB,texturesize,texturesize,0,GL_RGB,GL_UNSIGNED_BYTE,@TZGLOpenGLDrawer.CreateScrbuf);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 scrx:=scrx+texturesize;
                 inc(texture);
                 if texture>high(myscrbuf)then
                                              begin
                                                zDebugln('{E}TZGLOpenGLDrawer.CreateScrbuf: texture buffer overflow!');
                                                //programlog.LogOutStr('TZGLOpenGLDrawer.CreateScrbuf: texture buffer overflow!',lp_OldPos,LM_Error);
                                                texture:=0;
                                              end;
           until scrx>wh.cx;
           scrx:=0;
           scry:=scry+texturesize;
     until scry>wh.cy;
     oglsm.myglDisable(GL_TEXTURE_2D);
     result:=true;
     end;
end;
procedure TZGLOpenGLDrawer.delmyscrbuf;
var i:integer;
begin
     for I := 0 to high(tmyscrbuf) do
       begin
             if myscrbuf[i]<>0 then
                                   oglsm.mygldeletetextures(1,@myscrbuf[i]);
             myscrbuf[i]:=0;
       end;

end;
procedure TZGLOpenGLDrawer.SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);
begin
  mm:=cam.modelMatrix;
  oglsm.myglViewport(0, 0, w, h);
  oglsm.myglGetIntegerv(GL_VIEWPORT, @cam.viewport);

  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglLoadMatrixD(@cam.modelMatrixLCS);

  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglLoadMatrixD(@cam.projMatrixLCS);

  oglsm.myglMatrixMode(GL_MODELVIEW);
end;
procedure TZGLOpenGLDrawer.SetPenStyle(const style:TZGLPenStyle);
begin
     case style of
         TPS_Solid:
                   begin
                        oglsm.myglDisable(GL_LINE_STIPPLE);
                        oglsm.myglDisable(GL_POLYGON_STIPPLE);
                   end;
           TPS_Dot:
                     begin
                         oglsm.myglLineStipple(1, $3333);
                         oglsm.myglEnable(GL_LINE_STIPPLE);
                     end;
          TPS_Dash:
                    begin
                         oglsm.myglLineStipple(1, $F0F0);
                         oglsm.myglEnable(GL_LINE_STIPPLE);
                    end;
       TPS_Selected:
                    begin
                         oglsm.myglLineStipple(3, $AAAA);
                         oglsm.myglEnable(GL_LINE_STIPPLE);
                         oglsm.myglPolygonStipple(@ps);
                         oglsm.myglEnable(GL_POLYGON_STIPPLE);
                    end;
     end;
end;
procedure TZGLOpenGLDrawer.SetDrawMode(const mode:TZGLDrawMode);
begin
     case mode of
        TDM_Normal:
                   begin
                        oglsm.myglDisable(GL_COLOR_LOGIC_OP);
                   end;
            TDM_OR:
                   begin
                        oglsm.myglLogicOp(GL_OR);
                        oglsm.myglEnable(GL_COLOR_LOGIC_OP);
                   end;
           TDM_XOR:
                     begin
                         oglsm.myglLogicOp(GL_XOR);
                         oglsm.myglEnable(GL_COLOR_LOGIC_OP);
                     end;
     end;
end;
procedure TZGLOpenGLDrawer.DrawLine3DInModelSpace(const p1,p2:TzePoint3d;var matrixs:tmatrixs);
begin
     oglsm.myglbegin(GL_LINES);
      oglsm.myglVertex3dv(@p1);
      oglsm.myglVertex3dv(@p2);
     oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawPoint3DInModelSpace(const p:TzePoint3d;var matrixs:tmatrixs);
begin
     oglsm.myglbegin(GL_Points);
      oglsm.myglVertex3dv(@p);
     oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawTriangle3DInModelSpace(const normal,p1,p2,p3:TzePoint3d;var matrixs:tmatrixs);
begin
  oglsm.myglbegin(GL_TRIANGLES);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@p1);
  oglsm.myglVertex3dV(@p2);
  oglsm.myglVertex3dV(@p3);
  oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);
begin
  oglsm.myglbegin({GL_TRIANGLE_STRIP}GL_QUADS);
  oglsm.myglNormal3dV(@normal);
  oglsm.myglVertex3dV(@p1);
  oglsm.myglVertex3dV(@p2);
  oglsm.myglVertex3dV(@p4);
  oglsm.myglVertex3dV(@p3);
  oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawQuad3DInModelSpace(const p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);
begin
  oglsm.myglbegin(GL_QUADS);
  oglsm.myglVertex3dV(@p1);
  oglsm.myglVertex3dV(@p2);
  oglsm.myglVertex3dV(@p3);
  oglsm.myglVertex3dV(@p4);
  oglsm.myglend;
end;
initialization
finalization
end.

