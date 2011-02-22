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

unit OGLSpecFunc;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbase,LCLType,
     gl,glu,
     {$IFDEF LINUX}glx,{$ENDIF}
     {$IFDEF WINDOWS}windows,{$ENDIF}
     log,sysutils,varmandef;
type
    PTViewPortArray=^TViewPortArray;

    TOGLContextDesk=record
                          hrc: {HGLRC}thandle;
                          dc:HDC;
                    end;
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

                           procedure myglbegin(mode:GLenum);inline;
                           procedure myglend;inline;
                           procedure mytotalglend;inline;
                           procedure myglEnable(const cap: GLenum);inline;
                           procedure myglDisable(const cap: GLenum);inline;
                           procedure myglPointSize(const size: GLfloat);inline;
                           procedure myglLineWidth(const width: GLfloat);inline;
                           procedure myglStencilFunc(const func: GLenum;const  ref: GLint;const  mask: GLuint);inline;
                           procedure myglStencilOp(const fail, zfail, zpass: GLenum);inline;
                           procedure myglLogicOp(const opcode: GLenum);inline;
                           procedure myglPushMatrix;inline;
                           procedure myglPopMatrix;inline;
                           procedure myglMatrixMode(const mode: GLenum);inline;
                           procedure myglLineStipple(const factor: GLint; const pattern: GLushort);inline;
                           constructor init;

                           procedure myglVertex3dV(const V:PGDBVertex);inline;
                           procedure myglNormal3dV(const V:PGDBVertex);inline;
                           procedure myglColor3ub(const red, green, blue: GLubyte);inline;
                           procedure myglVertex3d(const V:GDBVertex);inline;
                           procedure myglVertex(const x,y,z:GDBDouble);inline;
    end;

var
   CurrentCamCSOffset:GDBvertex;
   notuseLCS:GDBBOOLEAN;
   OGLSM:TOGLStateManager;
const
     MY_EmptyMode=1000000;

procedure SetDCPixelFormat(oglc:TOGLContextDesk);
function isOpenGLError:GLenum;
function CalcDisplaySubFrustum(const x,y,w,h:gdbdouble;const mm,pm:DMatrix4D):ClipArray;
//(const v: PGLdouble); stdcall;
//procedure myglVertex3dV(V:PGDBVertex);
procedure MyglMakeCurrent(oglc:TOGLContextDesk);
procedure MySwapBuffers(oglc:TOGLContextDesk);
procedure MywglDeleteContext(oglc:TOGLContextDesk);
procedure MywglCreateContext(var oglc:TOGLContextDesk);

Procedure DrawAABB(const BoundingBox:GDBBoundingBbox);
var
   bcount:integer;
   primcount,pointcount,bathcount:GDBInteger;
   middlepoint:GDBVertex;
implementation
uses
    ugdbdescriptor,geometry;
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
procedure processpoint(const point:gdbvertex);
begin
     //inc(pointcount);
     //middlepoint:=geometry.VertexAdd(middlepoint,point);
end;

procedure TOGLStateManager.myglVertex3dV;
var t:gdbvertex;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     processpoint(v^);
     inc(pointcount);
     {$ENDIF}
     if notuseLCS then
                      glVertex3dV(pointer(v))
                  else
                      begin
                           t:=vertexadd(v^,CurrentCamCSOffset);
                           glVertex3dV(@t);
                      end;
end;
procedure TOGLStateManager.myglNormal3dV(const V:PGDBVertex);inline;
begin
     glNormal3dV(pointer(v))
end;

procedure TOGLStateManager.myglColor3ub(const red, green, blue: GLubyte);inline;
begin
     glColor3ub(red, green, blue);
end;

procedure TOGLStateManager.myglVertex3d;
var t:gdbvertex;
begin
     {$IFDEF DEBUGCOUNTGEOMETRY}
     processpoint(v);
     inc(pointcount);
     {$ENDIF}
     if notuseLCS then
                      glVertex3dV(@v)
                  else
                      begin
                           t:=vertexadd(v,CurrentCamCSOffset);
                           glVertex3dv(@t);
                      end;
end;
procedure TOGLStateManager.myglVertex;
var t,t1:gdbvertex;
begin
     t1:=createvertex(x,y,z);
     {$IFDEF DEBUGCOUNTGEOMETRY}
     processpoint(t1);
     inc(pointcount);
     {$ENDIF}
     if notuseLCS then
                      glVertex3dV(@t1)
                  else
                      begin
                           t:=vertexadd(t1,CurrentCamCSOffset);
                           glVertex3dv(@t);
                      end;
end;
function CalcDisplaySubFrustum(const x,y,w,h:gdbdouble;const mm,pm:DMatrix4D):ClipArray;
var
tm: DMatrix4D;
begin
  oglsm.myglMatrixMode(GL_Projection);
  oglsm.myglpushmatrix;
  glLoadIdentity;
  gluPickMatrix(x,y,w,h, PTViewPortArray(@gdb.GetCurrentDWG.pcamera^.viewport)^);
  glGetDoublev(GL_PROJECTION_MATRIX, @tm);
  tm := MatrixMultiply(pm, tm);
  tm := MatrixMultiply(mm, tm);
  result := calcfrustum(@tm);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
end;
function isOpenGLError:GLenum;
var
   s:string;
begin
     result:=glgeterror;
     if result<>GL_NO_ERROR then
                      begin
                           s:='OPENGL ERROR! '+inttostr(result);
                           //MessageBox(0,@s[1],0,MB_OK);
                           {asm
                              int(3);
                           end;}
                      end;
end;
procedure TOGLStateManager.myglbegin(mode:GLenum);
begin
//(*
    //if (mode<>GL_LINES)and(mode<>GL_QUADS) then
    //                          mode:=mode;
     if mode<>currentmode then
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
     if bcount>1 then
                     asm
                              {int(3);}
                     end;
//*)
//    glbegin(mode)
end;
procedure TOGLStateManager.myglend;
begin
(*
     if bcount<1 then
                     asm
                              {int(3);}
                     end;
     dec(bcount);
*)
//     glend;

end;
procedure TOGLStateManager.mytotalglend;
begin
     (*if bcount<1 then
                     asm
                              {int(3);}
                     end;*)
     //dec(bcount);

     if currentmode<>MY_EmptyMode then
                                     begin
                                          glend;
                                          {$IFDEF DEBUGCOUNTGEOMETRY}inc(bathcount);{$ENDIF}
                                          currentmode:=MY_EmptyMode;
                                     end;
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
     _myglStencilmask:=-1;

     _myglStencilfail:=maxint;
     _myglStencilzfail:=maxint;
     _myglStencilzpass:=maxint;

     _myglLogicOpCode:=maxint;
     _glMatrixMode:=maxint;

     _LineStipplefactor:=maxint;
     _LineStipplepattern:=maxword;

end;

procedure SetDCPixelFormat(oglc:TOGLContextDesk);
{var
  nPixelFormat: GDBInteger;
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
Procedure DrawAABB(const BoundingBox:GDBBoundingBbox);
begin
oglsm.myglbegin(GL_LINE_LOOP);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z);
oglsm.myglend();
oglsm.myglbegin(GL_LINE_LOOP);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
   oglsm.myglVertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z);
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
     {$IFDEF DEBUGINITSECTION}log.LogOut('oglspecfunc.initialization');{$ENDIF}
     bcount:=0;
     oglsm.init;
end.
