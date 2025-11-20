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

unit uzgloglstatemanager;
{$INCLUDE zengineconfig.inc}

interface
uses uzegeometrytypes,uzepalette,{$IFNDEF DELPHI}LCLType,{$ENDIF}
     {$IFNDEF DELPHI}gl,{glu,}glext,{$ELSE}dglOpenGL,windows,{$ENDIF}
     {$IFDEF SLINUX}glx,{$ENDIF}
     {$IFDEF WINDOWS}windows,{$ENDIF}
     uzgldrawergeneral,uzegeometry,sysutils;
type
    GLenum={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GLenum;
    TViewPortArray = array [0..3] of GLint;//ВРЕМЕННО
const ls = $AAAA;
      ps:array [0..31] of LongWord=(
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC,
                                   $33333333,$33333333,
                                   $CCCCCCCC,$CCCCCCCC
                                  );
      GL_lines={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_lines;
      GL_LINE_STRIP={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LINE_STRIP;
      GL_line_loop={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_line_loop;
      GL_POINT_SMOOTH={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_POINT_SMOOTH;
      GL_LINE_SMOOTH={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LINE_SMOOTH;
      GL_points={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_points;
      GL_QUADS={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_QUADS;
      GL_ALWAYS={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_ALWAYS;
      GL_LINE_STIPPLE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LINE_STIPPLE;
      GL_POLYGON_STIPPLE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_POLYGON_STIPPLE;
      GL_TRIANGLES={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TRIANGLES;
      GL_TRIANGLE_FAN={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TRIANGLE_FAN;
      GL_TRIANGLE_STRIP={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TRIANGLE_STRIP;

      GL_PROJECTION={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_PROJECTION;
      GL_MODELVIEW={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_MODELVIEW;
      GL_VIEWPORT={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_VIEWPORT;
      GL_LIGHTING={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LIGHTING;
      GL_LIGHT0={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LIGHT0;
      GL_COLOR_MATERIAL={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_COLOR_MATERIAL;
      GL_POSITION={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_POSITION;
      GL_FRONT_AND_BACK={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_FRONT_AND_BACK;
      GL_SHININESS={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_SHININESS;
      GL_SPECULAR={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_SPECULAR;
      GL_LIGHT_MODEL_TWO_SIDE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LIGHT_MODEL_TWO_SIDE;
      GL_AMBIENT_AND_DIFFUSE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_AMBIENT_AND_DIFFUSE;

      GL_COLOR_LOGIC_OP={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_COLOR_LOGIC_OP;
      GL_OR={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_OR;
      GL_XOR={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_XOR;

      GL_TEXTURE_2D={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TEXTURE_2D;
      GL_DEPTH_TEST={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_DEPTH_TEST;
      GL_LEQUAL={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LEQUAL;
      GL_STENCIL_TEST={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_STENCIL_TEST;
      GL_BLEND={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_BLEND;
      GL_SRC_ALPHA={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_SRC_ALPHA;
      GL_ONE_MINUS_SRC_ALPHA={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_ONE_MINUS_SRC_ALPHA;
      GL_LINE_SMOOTH_HINT={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LINE_SMOOTH_HINT;
      GL_NICEST={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_NICEST;
      GL_KEEP={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_KEEP;
      GL_COLOR_BUFFER_BIT={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_COLOR_BUFFER_BIT;
      GL_DEPTH_BUFFER_BIT={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_DEPTH_BUFFER_BIT;
      GL_STENCIL_BUFFER_BIT={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_STENCIL_BUFFER_BIT;
      GL_LOAD={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LOAD;
      GL_return={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_return;
      GL_AUX0={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_AUX0;
      GL_BACK={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_BACK;
      GL_COLOR={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_COLOR;
      GL_BGRA_EXT={$IFNDEF DELPHI}glext.{$ELSE}dglOpenGL.{$ENDIF}GL_BGRA_EXT;
      GL_NEVER={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_NEVER;
      GL_REPLACE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_REPLACE;
      GL_UNSIGNED_BYTE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_UNSIGNED_BYTE;
      GL_EQUAL={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_EQUAL;
      GL_TEXTURE_MIN_FILTER={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TEXTURE_MIN_FILTER;
      GL_RGB={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_RGB;
      GL_NEAREST={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_NEAREST;
      GL_TEXTURE_MAG_FILTER={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TEXTURE_MAG_FILTER;
      GL_VENDOR={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_VENDOR;
      GL_RENDERER={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_RENDERER;
      GL_VERSION={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_VERSION;
      GL_LINE_WIDTH_RANGE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_LINE_WIDTH_RANGE;
      GL_point_size_RANGE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_point_size_RANGE;
      GL_PROJECTION_MATRIX={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_PROJECTION_MATRIX;
      GL_EXTENSIONS={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_EXTENSIONS;
      GL_MAP1_VERTEX_4={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_MAP1_VERTEX_4;
      GL_MAP1_VERTEX_3={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_MAP1_VERTEX_3;
      GL_TRUE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_TRUE;
      GL_FALSE={$IFNDEF DELPHI}gl.{$ELSE}dglOpenGL.{$ENDIF}GL_FALSE;

      maxmybufer=1024;
type
    tmyscrbuf = array [0..maxmybufer] of GLuint;
    {$IFNDEF DELPHI}
    {if FPC_FULlVERSION>20600}
    {glu}//TViewPortArray = array [0..3] of GLint;
    {ENDIF}
    {$ENDIF}
    {$IFDEF DELPHI}
    //TViewPortArray = {array [0..3] of GLint}TVector4i;
    {$ENDIF}

    TessObj=Pointer;
    GLUnurbsObj=Pointer;

    TOGLContextDesk=record
                          hrc: {HGLRC}thandle;
                          dc:HDC;
                    end;
    PTOGLStateManager=^TOGLStateManager;
    TOGLStateManager=object
                           currentpointsize,currentlinewidth:GLfloat;
                           currentmode,lastmode:GLenum;

                           _myglStencilfunc: GLenum;
                           _myglStencilref: GLint;
                           _myglStencilmask: GLuint;

                           _myglStencilfail,
                           _myglStencilzfail,
                           _myglStencilzpass: GLenum;

                           _myglLogicOpCode:GLenum;

                           _glMatrixMode:GLenum;

                           _LineStipplefactor: GLint;
                           _LineStipplepattern: GLushort;
                           _ppolygonpattern:pointer;

                           _colour:uzepalette.TRGB;

                           procedure myglbegin(mode:GLenum);inline;
                           procedure myglend;inline;
                           procedure mytotalglend;inline;
                           procedure myglDepthFunc(const cap: GLenum);inline;
                           procedure myglEnable(const cap: GLenum);inline;
                           procedure myglDisable(const cap: GLenum);inline;
                           procedure myglPointSize(const size: GLfloat);virtual;//inline;
                           procedure myglLineWidth(const width: GLfloat);virtual;//inline;
                           procedure myglStencilFunc(const func: GLenum;const  ref: GLint;const  mask: GLuint);inline;
                           procedure myglStencilOp(const fail, zfail, zpass: GLenum);inline;
                           procedure myglLogicOp(const opcode: GLenum);inline;
                           procedure myglPushMatrix;virtual;//inline;
                           procedure myglPopMatrix;virtual;//inline;
                           procedure myglMultMatrixD(const matrix:DMatrix4d);virtual;//inline;
                           procedure myglMultMatrixF(const matrix:DMatrix4f);virtual;//inline;
                           procedure myglMatrixMode(const mode: GLenum);inline;
                           procedure myglLineStipple(const factor: GLint; const pattern: GLushort);inline;
                           procedure myglPolygonStipple(const ppattern:pointer);inline;
                           constructor init;

                           procedure glcolor3ub(const red, green, blue: GLubyte);virtual;//inline;
                           procedure glcolor4ub(const red, green, blue,alpha: GLubyte);virtual;//inline;
                           procedure glColor3ubv(const v: TRGB);virtual;//inline;

                           procedure myglNormal3dV(const V:PzePoint3d);inline;
                           //procedure myglColor3ub(const red, green, blue: GLubyte);inline;
                           procedure myglVertex3d(const V:TzePoint3d);virtual;//inline;
                           procedure myglVertex2d(const x,y:Double);virtual;//inline;
                           procedure myglVertex2f(const x,y:GLFloat);virtual;//inline;
                           procedure myglvertex2dv(const V:Pointer);virtual;//inline;
                           procedure myglvertex2iv(const V:Pointer);virtual;//inline;
                           procedure myglVertex2i(x, y: GLint);virtual;//inline;
                           procedure myglVertex(const x,y,z:Double);virtual;overload;//inline;
                           procedure myglVertex3dV(const V:PzePoint3d);virtual;//inline;
                           procedure myglVertex3fV(const V:PzePoint3s);virtual;//inline;
                           procedure myglVertex(constref V:TzePoint3d);virtual;overload;//inline;
                           procedure myglVertex(constref V:TzePoint3s);virtual;overload;//inline;
                           procedure startrender;virtual;//inline;
                           procedure endrender;virtual;//inline;
                           {$IFDEF SINGLEPRECISIONGEOMETRY}
                           procedure glVertex3dv(const v: PzePoint3d);inline;
                           {$ENDIF}
                           procedure myglViewport(const x,y,width,height:Integer);inline;
                           procedure myglGetIntegerv(pname: GLenum; params: PGLint);inline;
                           procedure myglLoadMatrixd(const m: PGLdouble);inline;
                           procedure myglLightfv(light, pname: GLenum; const params: PGLfloat);inline;
                           procedure myglMaterialf(face, pname: GLenum; param: GLfloat);inline;
                           procedure myglMaterialfv(face, pname: GLenum; const params: PGLfloat);inline;
                           procedure myglColorMaterial(face, mode: GLenum);inline;
                           procedure myglLightModeli(pname: GLenum; param: GLint);inline;
                           procedure myglLoadIdentity;inline;
                           procedure myglOrtho(left, right, bottom, top, zNear, zFar: GLdouble);inline;
                           procedure myglScalef(x, y, z: GLfloat);inline;
                           procedure myglTranslated(x, y, z: GLdouble);inline;
                           procedure myglBindTexture(target: GLenum; texture: GLuint);inline;
                           procedure myglCopyTexSubImage2D(target: GLenum; level, xoffset, yoffset, x, y: GLint; width, height: GLsizei);inline;
                           procedure myglTexCoord2d(s, t: GLdouble);inline;
                           procedure myglClearColor(red, green, blue, alpha: GLclampf);inline;
                           procedure myglBlendFunc(sfactor, dfactor: GLenum);inline;
                           procedure myglHint(target, mode: GLenum);inline;
                           procedure myglClear(mask: GLbitfield);inline;
                           procedure myglAccum(op: GLenum; value: GLfloat);inline;
                           procedure myglDrawBuffer(mode: GLenum);inline;
                           procedure myglReadBuffer(mode: GLenum);inline;
                           procedure myglCopyPixels(x, y: GLint; width, height: GLsizei; atype: GLenum);inline;
                           procedure myglReadPixels(x, y: GLint; width, height: GLsizei; format, atype: GLenum; pixels: Pointer);inline;
                           procedure myglRasterPos2i(x, y: GLint);inline;
                           procedure myglDrawPixels(width, height: GLsizei; format, atype: GLenum; const pixels: Pointer);inline;
                           procedure myglDeleteTextures(n: GLsizei; const textures: PGLuint);inline;
                           procedure myglGenTextures(n: GLsizei; textures: PGLuint);inline;
                           procedure myglTexImage2D(target: GLenum; level: GLInt; internalformat: GLEnum; width, height: GLsizei; border: GLint; format, atype: GLenum; const pixels: Pointer);inline;
                           procedure myglTexParameteri(target: GLenum; pname: GLenum; param: GLint);inline;
                           procedure myglGetDoublev(pname: GLenum; params: PGLdouble);//inline;
                           function myglGetString(name: GLenum): PAnsiChar;inline;
    end;

var
   GLRasterizer:TOGLStateManager;
   OGLSM:PTOGLStateManager;
   wglSwapIntervalEXT: function(interval: GLint): BOOL;{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
const
     MY_EmptyMode=1000000;
procedure SetDCPixelFormat(oglc:TOGLContextDesk);
function isOpenGLError:GLenum;
//(const v: PGLdouble); stdcall;
//procedure myglVertex3dV(V:PzePoint3d);
procedure MyglMakeCurrent(oglc:TOGLContextDesk);
procedure MySwapBuffers(oglc:TOGLContextDesk);
procedure MywglDeleteContext(oglc:TOGLContextDesk);
procedure MywglCreateContext(var oglc:TOGLContextDesk);

{$IFDEF WINDOWS}
function wglGetProcAddress(ProcName:LPCSTR):PROC;stdcall; external 'opengl32' name 'wglGetProcAddress';
{$ENDIF}

Procedure DrawAABB(const BoundingBox:TBoundingBox);
var
   bcount:integer;
   primcount,pointcount,bathcount:Integer;
   middlepoint:TzePoint3d;
implementation
procedure MywglCreateContext(var oglc:TOGLContextDesk);
begin
     //oglc.hrc := wglCreateContext(oglc.DC);
end;

procedure MywglDeleteContext(oglc:TOGLContextDesk);
begin
     //wglDeleteContext(oglc.hrc);
end;

procedure MySwapBuffers(oglc:TOGLContextDesk);
begin
     //SwapBuffers(oglc.DC)
end;

procedure MyglMakeCurrent(oglc:TOGLContextDesk);
begin
    //wglMakeCurrent(oglc.DC, oglc.hrc);
end;
procedure processpoint(const point:TzePoint3s);
begin
     //inc(pointcount);
     //middlepoint:=uzegeometry.VertexAdd(middlepoint,point);
end;
procedure TOGLStateManager.glcolor3ub(const red, green, blue: GLubyte);
begin
     if (red<>_colour.r)
     or (green<>_colour.g)
     or (blue<>_colour.b)then
                              begin
                                   _colour.r:=red;
                                   _colour.g:=green;
                                   _colour.b:=blue;
                                   {$IFNDEF DELPHI}gl{$ELSE}dglOpenGL{$ENDIF}.glColor3ubv(@_colour);
                              end;
end;

procedure TOGLStateManager.glcolor4ub(const red, green, blue, alpha: GLubyte);
begin
     if (red<>_colour.r)
     or (green<>_colour.g)
     or (blue<>_colour.b)
     or (alpha<>_colour.a)then
                              begin
                                   _colour.r:=red;
                                   _colour.g:=green;
                                   _colour.b:=blue;
                                   _colour.a:=alpha;
                                   {$IFNDEF DELPHI}gl{$ELSE}dglOpenGL{$ENDIF}.glColor4ub(red, green, blue, alpha);
                              end;
end;


procedure TOGLStateManager.glColor3ubv(const v: TRGB);
begin
     if (v.r<>_colour.r)
     or (v.g<>_colour.g)
     or (v.b<>_colour.b)then
                              begin
                                   {$IFNDEF DELPHI}gl{$ELSE}dglOpenGL{$ENDIF}.glColor3ubv(@v);
                                   _colour:=v;
                              end;
end;

procedure TOGLStateManager.startrender;
begin
     middlepoint:=nulvertex;
     pointcount:=0;
     primcount:=0;
     bathcount:=0;
end;
procedure TOGLStateManager.endrender;
begin
    //sysvar.debug.renderdeb.middlepoint:=middlepoint;
    {sysvar.debug.renderdeb.pointcount:=pointcount;
    sysvar.debug.renderdeb.primcount:=primcount;
    sysvar.debug.renderdeb.bathcount:=bathcount;
    if pointcount<>0 then
                          sysvar.debug.renderdeb.middlepoint:=uzegeometry.VertexMulOnSc(middlepoint,1/pointcount);
    }
end;
{$IFDEF SINGLEPRECISIONGEOMETRY}
procedure TOGLStateManager.glVertex3dv(const v: PzePoint3d);
var
   t:TzePoint3s;
begin
     t.x:=v.x;
     t.y:=v.y;
     t.z:=v.z;
     glVertex3fv(@t);
end;
{$ENDIF}
procedure TOGLStateManager.myglvertex2iv(const V:Pointer);
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     //processpoint(v^);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex2iV(pointer(v))
                  else
                      begin
                           t:=vertexadd(createvertex(PzePoint2i(v)^.x,PzePoint2i(v)^.y,0),LCS.CurrentCamCSOffset);
                           glVertex3dV(@t);
                      end;
end;
procedure TOGLStateManager.myglVertex2i(x, y: GLint);
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     //processpoint(v^);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex2i(x,y)
                  else
                      begin
                           t:=vertexadd(createvertex(x,y,0),LCS.CurrentCamCSOffset);
                           glVertex3dV(@t);
                      end;
end;
procedure TOGLStateManager.myglvertex2dv(const V:Pointer);
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     //processpoint(v^);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex2dV(pointer(v))
                  else
                      begin
                           t:=vertexadd(createvertex(PzePoint2d(v)^.x,PzePoint2d(v)^.y,0),LCS.CurrentCamCSOffset);
                           glVertex3dV(@t);
                      end;
end;

procedure TOGLStateManager.myglVertex3dV;
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     //processpoint(v^);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex3dV(pointer(v))
                  else
                      begin
                           t:=vertexadd(v^,LCS.CurrentCamCSOffset);
                           glVertex3dV(@t);
                      end;
end;
procedure TOGLStateManager.myglVertex3fV;
var t:TzePoint3s;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     processpoint(v^);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex3fV(pointer(v))
                  else
                      begin
                           t:=vertexadd(v^,LCS.CurrentCamCSOffsetS);
                           glVertex3fV(@t);
                      end;
end;
procedure TOGLStateManager.myglVertex(constref V:TzePoint3d);
begin
  myglVertex3dV(@v);
end;
procedure TOGLStateManager.myglVertex(constref V:TzePoint3s);
begin
  myglVertex3fV(@v);
end;
procedure TOGLStateManager.myglNormal3dV(const V:PzePoint3d);{$IFNDEF DELPHI}inline;{$ENDIF}
begin
     glNormal3dV(pointer(v))
end;
procedure TOGLStateManager.myglVertex2f(const x,y:GLFloat);
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex2f(x,y)
                  else
                      begin
                           t:=vertexadd(createvertex(x,y,0),LCS.CurrentCamCSOffset);
                           glVertex3dv(@t);
                      end;
end;

procedure TOGLStateManager.myglVertex2d(const x,y:Double);
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex2d(x,y)
                  else
                      begin
                           t:=vertexadd(createvertex(x,y,0),LCS.CurrentCamCSOffset);
                           glVertex3dv(@t);
                      end;
end;

procedure TOGLStateManager.myglVertex3d;
var t:TzePoint3d;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     //processpoint(v);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex3dV(@v)
                  else
                      begin
                           t:=vertexadd(v,LCS.CurrentCamCSOffset);
                           glVertex3dv(@t);
                      end;
end;
procedure TOGLStateManager.myglVertex(const x,y,z:Double);
var t,t1:TzePoint3d;
begin
     t1:=createvertex(x,y,z);
     {$IFDEF DEBUGCOUNTGEOMETRY}
     //processpoint(t1);
     inc(pointcount);
     {$ENDIF}
     if LCS.notuseLCS then
                      glVertex3dV(@t1)
                  else
                      begin
                           t:=vertexadd(t1,LCS.CurrentCamCSOffset);
                           glVertex3dv(@t);
                      end;
end;
function isOpenGLError:GLenum;
//var
   //s:string;
begin
     result:=glgeterror;
     if result<>GL_NO_ERROR then
                      begin
                           //s:='OPENGL ERROR! '+inttostr(result);
                           //MessageBox(0,@s[1],0,MB_OK);
                        {$IFDEF LOUDERRORS}
                           //Raise Exception.Create('Something wrong');
                        {$ENDIF}
                      end;
end;
procedure TOGLStateManager.myglbegin(mode:GLenum);
begin
//(*
    //if (mode<>GL_LINES)and(mode<>GL_QUADS) then
    //                          mode:=mode;
     if ((mode<>currentmode)or(currentmode=GL_LINE_STRIP)or(currentmode=GL_TRIANGLE_STRIP)or(currentmode=GL_TRIANGLE_FAN)) then
     begin
     if currentmode<>MY_EmptyMode then
                                     begin
                                          glend;
                                          //isOpenGLError;
                                          {$IFDEF DEBUGCOUNTGEOMETRY}inc(bathcount);{$ENDIF}
                                     end;
     glbegin(mode);
     //{$IFDEF DEBUGCOUNTGEOMETRY}inc(bathcount);{$ENDIF}
     end;


     {IFDEF DEBUGCOUNTGEOMETRY}inc(primcount);{ENDIF}

     inc(bcount);
     currentmode:=mode;
     (*if bcount>1 then
        {$IFDEF LOUDERRORS}
        //Raise Exception.Create('Something wrong');
        {$ENDIF}*)
     pointcount:=0;
//*)
//    glbegin(mode)
end;
procedure TOGLStateManager.myglend;
begin
(*
     if bcount<1 then
       {$IFDEF LOUDERRORS}
        //Raise Exception.Create('Something wrong');
       {$ENDIF}
     dec(bcount);
*)
//     glend;
     pointcount:=0;

end;
procedure TOGLStateManager.mytotalglend;
begin
     (*if bcount<1 then
         {$IFDEF LOUDERRORS}
         //Raise Exception.Create('Something wrong');
         {$ENDIF}*)
     //dec(bcount);

     if currentmode<>MY_EmptyMode then
                                     begin
                                          glend;
                                          {$IFDEF DEBUGCOUNTGEOMETRY}inc(bathcount);{$ENDIF}
                                          currentmode:=MY_EmptyMode;
                                     end;
end;
procedure TOGLStateManager.myglDepthFunc(const cap: GLenum);
begin
     mytotalglend;
     glDepthFunc(cap);
end;
procedure TOGLStateManager.myglEnable(const cap: GLenum);
begin
     mytotalglend;
     glEnable(cap);
end;
procedure TOGLStateManager.myglDisable(const cap: GLenum);
begin
  mytotalglend;
  glDisable(cap);
  //case cap of
  if cap=GL_LINE_STIPPLE then begin
    _LineStipplefactor:=-1;
    _LineStipplepattern:=0;
  end;
  //end;
end;
procedure TOGLStateManager.myglPointSize(const size: GLfloat);
begin
     if currentpointsize<>size then
                     begin
                          mytotalglend;
                          glPointSize(size);
                          currentpointsize:=size;
                     end;
end;
procedure TOGLStateManager.myglLineWidth(const width: GLfloat);
begin
     if currentlinewidth<>width then
                     begin
                          mytotalglend;
                          gllinewidth(width);
                          currentlinewidth:=width;
                     end;
end;
procedure TOGLStateManager.myglStencilFunc(const func: GLenum;const  ref: GLint;const  mask: GLuint);
begin
     if
     (_myglStencilfunc<>func)or
     (_myglStencilref<>ref)or
     (_myglStencilmask<>mask)
     then
         begin
              mytotalglend;
              glStencilFunc(func,ref,mask);
              _myglStencilfunc:=func;
              _myglStencilref:=ref;
              _myglStencilmask:=mask;
         end;

end;
procedure TOGLStateManager.myglStencilOp(const fail, zfail, zpass: GLenum);
begin
     if
     (_myglStencilfail<>fail)or
     (_myglStencilzfail<>zfail)or
     (_myglStencilzpass<>zpass)
     then
         begin
              mytotalglend;
              glStencilOp(fail, zfail, zpass);
              _myglStencilfail:=fail;
              _myglStencilzfail:=zfail;
              _myglStencilzpass:=zpass;
         end;
end;
procedure TOGLStateManager.myglLogicOp(const opcode: GLenum);
begin
     if _myglLogicOpCode<>opcode then
     begin
     mytotalglend;
     glLogicOp(opcode);
     _myglLogicOpCode:=opcode;
     end;
end;
procedure TOGLStateManager.myglLineStipple(const factor: GLint; const pattern: GLushort);
begin
     if
     (_LineStipplefactor<>factor)or
     (_LineStipplepattern<>pattern)
     then
         begin
              mytotalglend;
              glLineStipple(factor,pattern);
              _LineStipplefactor:=factor;
              _LineStipplepattern:=pattern;
         end;
end;
procedure TOGLStateManager.myglPolygonStipple(const ppattern:pointer);
begin
     if
     (_ppolygonpattern<>ppattern)
     then
         begin
              mytotalglend;
              glPolygonStipple(ppattern);
              _ppolygonpattern:=ppattern;
         end;
end;
procedure TOGLStateManager.myglPushMatrix;
begin
     mytotalglend;
     glPushMatrix
end;

procedure TOGLStateManager.myglPopMatrix;
begin
     mytotalglend;
     glPopMatrix;
end;
procedure TOGLStateManager.myglMultMatrixD(const matrix:DMatrix4d);
begin
     glmultmatrixd(@matrix);
end;
procedure TOGLStateManager.myglMultMatrixF(const matrix:DMatrix4f);
begin
     glmultmatrixf(@matrix);
end;
procedure TOGLStateManager.myglViewport(const x,y,width,height:Integer);
begin
     glViewport(x,y,width,height);
end;
procedure TOGLStateManager.myglGetIntegerv(pname: GLenum; params: PGLint);
begin
     glGetIntegerv(pname,params);
end;
procedure TOGLStateManager.myglLoadMatrixd(const m: PGLdouble);
begin
     glLoadMatrixd(m);
end;
procedure TOGLStateManager.myglLightfv(light, pname: GLenum; const params: PGLfloat);
begin
     glLightfv(light,pname,params);
end;
procedure TOGLStateManager.myglMaterialf(face, pname: GLenum; param: GLfloat);
begin
     glMaterialf(face,pname,param);
end;
procedure TOGLStateManager.myglMaterialfv(face, pname: GLenum; const params: PGLfloat);
begin
     glMaterialfv(face,pname,params);
end;
procedure TOGLStateManager.myglColorMaterial(face, mode: GLenum);
begin
     glColorMaterial(face,mode);
end;
procedure TOGLStateManager.myglLightModeli(pname: GLenum; param: GLint);
begin
     glLightModeli(pname,param);
end;
procedure TOGLStateManager.myglLoadIdentity;
begin
     glLoadIdentity;
end;
procedure TOGLStateManager.myglOrtho(left, right, bottom, top, zNear, zFar: GLdouble);
begin
     glOrtho(left,right,bottom,top,zNear,zFar);
end;
procedure TOGLStateManager.myglScalef(x, y, z: GLfloat);
begin
     glScalef(x,y,z);
end;
procedure TOGLStateManager.myglTranslated(x, y, z: GLdouble);
begin
     glTranslated(x,y,z);
end;
procedure TOGLStateManager.myglBindTexture(target: GLenum; texture: GLuint);
begin
     glBindTexture(target,texture);
end;
procedure TOGLStateManager.myglCopyTexSubImage2D(target: GLenum; level, xoffset, yoffset, x, y: GLint; width, height: GLsizei);
begin
     glCopyTexSubImage2D(target,level, xoffset, yoffset, x, y,width, height);
end;
procedure TOGLStateManager.myglTexCoord2d(s, t: GLdouble);
begin
     glTexCoord2d(s, t);
end;
procedure TOGLStateManager.myglClearColor(red, green, blue, alpha: GLclampf);
begin
     glClearColor(red, green, blue, alpha);
end;
procedure TOGLStateManager.myglBlendFunc(sfactor, dfactor: GLenum);
begin
     glBlendFunc(sfactor, dfactor);
end;
procedure TOGLStateManager.myglHint(target, mode: GLenum);
begin
     glHint(target, mode);
end;
procedure TOGLStateManager.myglClear(mask: GLbitfield);
begin
     glClear(mask);
end;
procedure TOGLStateManager.myglAccum(op: GLenum; value: GLfloat);
begin
     glAccum(op,value);
end;
procedure TOGLStateManager.myglDrawBuffer(mode: GLenum);
begin
     glDrawBuffer(mode);
end;
procedure TOGLStateManager.myglReadBuffer(mode: GLenum);
begin
     glReadBuffer(mode);
end;
procedure TOGLStateManager.myglCopyPixels(x, y: GLint; width, height: GLsizei; atype: GLenum);
begin
     glCopyPixels(x, y,width, height,atype);
end;
procedure TOGLStateManager.myglReadPixels(x, y: GLint; width, height: GLsizei; format, atype: GLenum; pixels: Pointer);
begin
     glReadPixels(x, y, width, height, format, atype, pixels);
end;
procedure TOGLStateManager.myglRasterPos2i(x, y: GLint);
begin
     glRasterPos2i(x, y);
end;
procedure TOGLStateManager.myglDrawPixels(width, height: GLsizei; format, atype: GLenum; const pixels: Pointer);
begin
     glDrawPixels(width, height, format, atype, pixels);
end;
procedure TOGLStateManager.myglDeleteTextures(n: GLsizei; const textures: PGLuint);
begin
     glDeleteTextures(n, textures);
end;
procedure TOGLStateManager.myglGenTextures(n: GLsizei; textures: PGLuint);
begin
     glGenTextures(n, textures);
end;
procedure TOGLStateManager.myglTexImage2D(target: GLenum; level: GLInt; internalformat: GLEnum; width, height: GLsizei; border: GLint; format, atype: GLenum; const pixels: Pointer);
begin
     glTexImage2D(target, level, internalformat, width, height, border, format, atype, pixels);
end;
procedure TOGLStateManager.myglTexParameteri(target: GLenum; pname: GLenum; param: GLint);
begin
     glTexParameteri(target, pname, param);
end;
procedure TOGLStateManager.myglGetDoublev(pname: GLenum; params: PGLdouble);
begin
     glGetDoublev(pname, params);
end;
function TOGLStateManager.myglGetString(name: GLenum): PAnsiChar;
begin
     result:=glGetString(name);
end;
procedure TOGLStateManager.myglMatrixMode(const mode: GLenum);
begin
     if _glMatrixMode<>mode then
     begin
     mytotalglend;
     glMatrixMode(mode);
     _glMatrixMode:=mode;
     end;
end;

constructor TOGLStateManager.init;
begin
     currentmode:=MY_EmptyMode;
     currentpointsize:=-1;
     currentlinewidth:=-1;

     _myglStencilfunc:=maxint;
     _myglStencilref:=-1;
     _myglStencilmask:={-1}0;

     _myglStencilfail:=maxint;
     _myglStencilzfail:=maxint;
     _myglStencilzpass:=maxint;

     _myglLogicOpCode:=maxint;
     _glMatrixMode:=maxint;

     _LineStipplefactor:=maxint;
     _LineStipplepattern:=maxword;
     _colour.r:=255;
     _colour.g:=255;
     _colour.b:=255;
     _ppolygonpattern:=nil;

end;

procedure SetDCPixelFormat(oglc:TOGLContextDesk);
{var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
  rez: BOOL;}
begin
{  programlog.logoutstr('OGLSpecFunc.SetDCPixelformat',lp_IncPos);
  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
  begin
    nSize := sizeof(pfd);
    nVersion := 1;
    dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType := PFD_TYPE_RGBA;
    cColorBits := 32;
    cDepthBits := 32;
    cAccumBits := 32;
    cAuxBuffers:= 8;
    cStencilBits:= 4;
    iLayerType := PFD_MAIN_PLANE;
  end;
  nPixelFormat := ChoosePixelFormat(oglc.DC, @pfd);
  DescribePixelFormat(oglc.dc,nPixelFormat,sizeof(PIXELFORMATDESCRIPTOR),pfd);
  programlog.logoutstr('PixelFormat='+inttostr(nPixelFormat),0);
  programlog.logoutstr('cColorBits='+inttostr(pfd.cColorBits),0);
  programlog.logoutstr('cAccumBits='+inttostr(pfd.cAccumBits),0);
  programlog.logoutstr('cDepthBits='+inttostr(pfd.cDepthBits),0);
  programlog.logoutstr('cStencilBits='+inttostr(pfd.cStencilBits),0);
  programlog.logoutstr('cAuxBuffers='+inttostr(pfd.cAuxBuffers),0);
  programlog.logoutstr('cStencilBits='+inttostr(pfd.cStencilBits),0);
  rez:=SetPixelFormat(oglc.dc, nPixelFormat, @pfd);
  if rez then programlog.logoutstr('end;',lp_DecPos)
         else
             begin
                  programlog.logoutstr(pansichar('SetPixelFormat error - '+inttostr(getlasterror)),lp_DecPos);
             end;}
end;
Procedure DrawAABB(const BoundingBox:TBoundingBox);
begin
oglsm.myglbegin(GL_LINES);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
oglsm.myglend();
oglsm.myglbegin(GL_LINES);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
oglsm.myglend();
oglsm.myglbegin(GL_LINES);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
oglsm.myglend();
end;
begin
     bcount:=0;
     GLRasterizer.init;
     //oglsm.init;
     oglsm:=@GLRasterizer;
end.
