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

procedure SetDCPixelFormat(oglc:TOGLContextDesk);
function isOpenGLError:GLenum;
procedure myglbegin(mode:GLenum);
procedure myglend;
function CalcDisplaySubFrustum(x,y,w,h:gdbdouble;const mm,pm:DMatrix4D):ClipArray;
//(const v: PGLdouble); stdcall;
//procedure myglVertex3dV(V:PGDBVertex);
procedure myglVertex3dV(const V:PGDBVertex);stdcall;
procedure myglVertex3d(const V:GDBVertex);stdcall;
procedure myglVertex(const x,y,z:GDBDouble);stdcall;
procedure MyglMakeCurrent(oglc:TOGLContextDesk);
procedure MySwapBuffers(oglc:TOGLContextDesk);
procedure MywglDeleteContext(oglc:TOGLContextDesk);
procedure MywglCreateContext(var oglc:TOGLContextDesk);
var
   bcount:integer;
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

procedure myglVertex3dV;
var t:gdbvertex;
begin
     t:=vertexadd(v^,gdb.GetCurrentDWG.pcamera^.CamCSOffset);
     glVertex3dV(@t);
end;
procedure myglVertex3d;
var t:gdbvertex;
begin
     t:=vertexadd(v,gdb.GetCurrentDWG.pcamera^.CamCSOffset);
     glVertex3dv(@t);
end;
procedure myglVertex;
var t:gdbvertex;
begin
     t:=vertexadd(createvertex(x,y,z),gdb.GetCurrentDWG.pcamera^.CamCSOffset);
     glVertex3dv(@t);
end;
function CalcDisplaySubFrustum(x,y,w,h:gdbdouble;const mm,pm:DMatrix4D):ClipArray;
var
tm: DMatrix4D;
begin
  glMatrixMode(GL_Projection);
  glpushmatrix;
  glLoadIdentity;
  gluPickMatrix(x,y,w,h, PTViewPortArray(@gdb.GetCurrentDWG.pcamera^.viewport)^);
  glGetDoublev(GL_PROJECTION_MATRIX, @tm);
  tm := MatrixMultiply(pm, tm);
  tm := MatrixMultiply(mm, tm);
  result := calcfrustum(@tm);
  glpopmatrix;
  glMatrixMode(GL_MODELVIEW);
end;
function isOpenGLError:GLenum;
begin
     result:=glgeterror;
     if result<>GL_NO_ERROR then
                      begin
                           //MessageBox(0,'OPENGL ERROR!',0,MB_OK);
                           {asm
                              int(3);
                           end;}
                      end;
end;
procedure myglbegin(mode:GLenum);
begin
     inc(bcount);
     if bcount>1 then
                     asm
                              {int(3);}
                     end;
     glbegin(mode);
end;
procedure myglend;
begin
     if bcount<1 then
                     asm
                              {int(3);}
                     end;
     dec(bcount);
     glend;
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
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('oglspecfunc.initialization');{$ENDIF}
     bcount:=0;
end.
