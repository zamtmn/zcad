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

unit uzegluinterface;
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}

interface
uses uzbLogIntf,
     {$IFNDEF DELPHI}glu,gl,{$ELSE}dglOpenGL,windows,{$ENDIF}
     {$IFDEF SLINUX}glx,{$ENDIF}
     uzegeometrytypes,sysutils,uzegeometry;
const
      GLU_VERSION={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_VERSION;
      GLU_TESS_VERTEX={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_VERTEX;
      GLU_TESS_VERTEX_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_VERTEX_DATA;
      GLU_TESS_BEGIN_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_BEGIN_DATA;
      GLU_TESS_ERROR_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_ERROR_DATA;
      GLU_TESS_COMBINE={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_COMBINE;
      GLU_TESS_COMBINE_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_COMBINE_DATA;
      GLU_EXTENSIONS={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_EXTENSIONS;
      GLU_NURBS_VERTEX_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_VERTEX_EXT;
      GLU_NURBS_MODE_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_MODE_EXT;
      GLU_NURBS_TESSELLATOR_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_TESSELLATOR_EXT;
      GLU_SAMPLING_TOLERANCE={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_SAMPLING_TOLERANCE;
      GLU_DISPLAY_MODE={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_DISPLAY_MODE;
      GLU_POINT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_POINT;
      GLU_NURBS_BEGIN_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_BEGIN_EXT;
      GLU_NURBS_END_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_END_EXT;
      GLU_NURBS_ERROR={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_ERROR;
      GLU_AUTO_LOAD_MATRIX={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_AUTO_LOAD_MATRIX;

      GLU_NURBS_BEGIN_DATA_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_BEGIN_DATA_EXT;
      GLU_NURBS_END_DATA_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_END_DATA_EXT;
      GLU_NURBS_VERTEX_DATA_EXT={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_NURBS_VERTEX_DATA_EXT;

      GLUIntf_GL_FALSE=gl.GL_FALSE;
      GLUIntf_GL_TRUE=gl.GL_TRUE;
      GLUIntf_GL_MAP1_VERTEX_4=gl.GL_MAP1_VERTEX_4;
type
    PTViewPortArray=^TViewPortArray;
    TGLUIntf_GLenum=GLenum;

    TBeginCB=procedure(const v: TGLUIntf_GLenum;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
    TVertexCB=procedure(const v: PzePoint3s;const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
    TEndCB=procedure (const Data: Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
    TErrorCB=procedure(const v: GLenum);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};

    TessObj=Pointer;
    GLUnurbsObj=Pointer;
    PTGLUInterface=^TGLUInterface;
    TGLUInterface=object
                           constructor init;

                           function NewTess:TessObj;
                           procedure DeleteTess(ptessobj:TessObj);
                           procedure TessBeginPolygon(tess:TessObj;data:pointer);
                           procedure TessEndPolygon(tess:TessObj);
                           procedure TessBeginContour(tess:TessObj);
                           procedure TessEndContour(tess:TessObj);
                           procedure TessVertex(tess:TessObj; location:PzePoint3d; data:PtrInt);
                           procedure TessCallback(tess:TessObj; which:TGLUIntf_GLenum; CallBackFunc:_GLUfuncptr);

                           function NewNurbsRenderer:GLUnurbsObj;
                           procedure SetupNurbsRenderer(const renderer:GLUnurbsObj;
                                                        const tolerance:GLfloat;
                                                        constref model,perspective:DMatrix4d;
                                                        constref view:Matrix4i;
                                                        const BeginCB:TBeginCB;const EndCB:TVertexCB;const VertexCB:TVertexCB;const ErrorCB:TErrorCB;
                                                        const Data: Pointer);overload;
                           procedure SetupNurbsRenderer(const renderer:GLUnurbsObj;
                                                        const tolerance:GLfloat;
                                                        const BeginCB:TBeginCB;const EndCB:TVertexCB;const VertexCB:TVertexCB;const ErrorCB:TErrorCB;
                                                        const Data: Pointer);overload;
                           procedure DeleteNurbsRenderer(renderer:GLUnurbsObj);
                           procedure NurbsCallback(nurb:GLUnurbsObj; which:TGLUIntf_GLenum; CallBackFunc:_GLUfuncptr);
                           procedure BeginCurve(renderer:GLUnurbsObj);
	                   procedure EndCurve(renderer:GLUnurbsObj);
                           procedure NurbsCurve(nurb:PGLUnurbs; knotCount:GLint; knots:PGLfloat; stride:GLint; control:PGLfloat;
                                                order:GLint; _type:TGLUIntf_GLenum);
                           procedure NurbsProperty(nurb:PGLUnurbs; _property:TGLUIntf_GLenum; value:GLfloat);
                           procedure NurbsCallbackData(nurb:PGLUnurbs; userData:Pointer);
                           function ErrorString(error:TGLUIntf_GLenum):glu.PGLubyte;
                           function mygluGetString(name: TGLUIntf_GLenum): PAnsiChar;
                           procedure mygluPickMatrix(x:GLdouble; y:GLdouble; delX:GLdouble; delY:GLdouble; viewport:PGLint);
                           procedure mygluLoadSamplingMatrices(renderer:GLUnurbsObj;const model,perspective:PGLfloat;view:PGLint);
    end;

var
   GLUIntrf:TGLUInterface;
   GLUVersion,GLUExtensions:String;
implementation
function TGLUInterface.mygluGetString(name: TGLUIntf_GLenum): PAnsiChar;
begin
     result:=gluGetString(name);
end;
procedure TGLUInterface.mygluPickMatrix(x:GLdouble; y:GLdouble; delX:GLdouble; delY:GLdouble; viewport:PGLint);
begin
     gluPickMatrix(x,y,delX,delY,{$IFNDEF DELPHI}PTViewPortArray(viewport)^{$ELSE}(viewport){$ENDIF});
end;
procedure TGLUInterface.mygluLoadSamplingMatrices(renderer:GLUnurbsObj;const model,perspective:PGLfloat;view:PGLint);
begin
     gluLoadSamplingMatrices(renderer,model,perspective,view);
end;
function TGLUInterface.NewNurbsRenderer:GLUnurbsObj;
begin
     result:=gluNewNurbsRenderer;
end;
procedure TGLUInterface.SetupNurbsRenderer(const renderer:GLUnurbsObj;
                                           const tolerance:GLfloat;
                                           constref model,perspective:DMatrix4d;
                                           constref view:Matrix4i;
                                           const BeginCB:TBeginCB;const EndCB:TVertexCB;const VertexCB:TVertexCB;const ErrorCB:TErrorCB;
                                           const Data: Pointer);
var
  fm,fp:DMatrix4f;
begin
  fm:=ToDMatrix4f(model);
  fp:=ToDMatrix4f(perspective);

  NurbsProperty(renderer,GLU_NURBS_MODE_EXT,GLU_NURBS_TESSELLATOR_EXT);
  NurbsProperty(renderer,GLU_SAMPLING_TOLERANCE,tolerance);
  NurbsProperty(renderer,GLU_DISPLAY_MODE,{GLU_FILL}GLU_POINT);
  NurbsProperty(renderer,GLU_AUTO_LOAD_MATRIX,{GL_TRUE}GL_FALSE);
  mygluLoadSamplingMatrices(renderer,@fm,@fp,@view);
  NurbsCallback(renderer,GLU_NURBS_BEGIN_DATA_EXT,_GLUfuncptr(BeginCB));
  NurbsCallback(renderer,GLU_NURBS_END_DATA_EXT,_GLUfuncptr(EndCB));
  NurbsCallback(renderer,GLU_NURBS_VERTEX_DATA_EXT,_GLUfuncptr(VertexCB));
  NurbsCallback(renderer,GLU_NURBS_ERROR,_GLUfuncptr(ErrorCB));
  NurbsCallbackData(renderer,Data);
end;

procedure TGLUInterface.SetupNurbsRenderer(const renderer:GLUnurbsObj;
                                           const tolerance:GLfloat;
                                           const BeginCB:TBeginCB;const EndCB:TVertexCB;const VertexCB:TVertexCB;const ErrorCB:TErrorCB;
                                           const Data: Pointer);
begin
  NurbsProperty(renderer,GLU_NURBS_MODE_EXT,GLU_NURBS_TESSELLATOR_EXT);
  NurbsProperty(renderer,GLU_SAMPLING_TOLERANCE,tolerance);
  NurbsProperty(renderer,GLU_DISPLAY_MODE,{GLU_FILL}GLU_POINT);
  NurbsProperty(renderer,GLU_AUTO_LOAD_MATRIX,{GL_TRUE}GL_FALSE);
  NurbsCallback(renderer,GLU_NURBS_BEGIN_DATA_EXT,_GLUfuncptr(BeginCB));
  NurbsCallback(renderer,GLU_NURBS_END_DATA_EXT,_GLUfuncptr(EndCB));
  NurbsCallback(renderer,GLU_NURBS_VERTEX_DATA_EXT,_GLUfuncptr(VertexCB));
  NurbsCallback(renderer,GLU_NURBS_ERROR,_GLUfuncptr(ErrorCB));
  NurbsCallbackData(renderer,Data);
end;


procedure TGLUInterface.DeleteNurbsRenderer(renderer:GLUnurbsObj);
begin
     gluDeleteNurbsRenderer(renderer)
end;
procedure TGLUInterface.NurbsCallback(nurb:GLUnurbsObj; which:TGLUIntf_GLenum; CallBackFunc:_GLUfuncptr);
begin
     gluNurbsCallback(nurb,which,CallBackFunc);
end;
procedure TGLUInterface.BeginCurve(renderer:GLUnurbsObj);
begin
     gluBeginCurve(renderer);
end;
procedure TGLUInterface.EndCurve(renderer:GLUnurbsObj);
begin
     gluEndCurve(renderer);
end;
procedure TGLUInterface.NurbsCurve(nurb:PGLUnurbs; knotCount:GLint; knots:PGLfloat; stride:GLint; control:PGLfloat;order:GLint; _type:TGLUIntf_GLenum);
begin
     gluNurbsCurve(nurb,knotCount,knots,stride,control,order,_type);
end;
procedure TGLUInterface.NurbsProperty(nurb:PGLUnurbs; _property:TGLUIntf_GLenum; value:GLfloat);
begin
     gluNurbsProperty(nurb,_property,value);
end;
procedure TGLUInterface.NurbsCallbackData(nurb:PGLUnurbs; userData:Pointer);
begin
  gluNurbsCallbackData(nurb,userData);
end;
function TGLUInterface.ErrorString(error:TGLUIntf_GLenum):glu.PGLubyte;
begin
     result:=gluErrorString(error);
end;
function TGLUInterface.NewTess:Pointer;
begin
     result:=gluNewTess;
end;
procedure TGLUInterface.DeleteTess(ptessobj:Pointer);
begin
     gluDeleteTess(ptessobj);
end;
procedure TGLUInterface.TessBeginPolygon(tess:TessObj;data:pointer);
begin
     gluTessBeginPolygon(tess,data);
end;
procedure TGLUInterface.TessEndPolygon(tess:TessObj);
begin
     gluTessEndPolygon(tess);
end;
procedure TGLUInterface.TessBeginContour(tess:TessObj);
begin
     gluTessBeginContour(tess);
end;
procedure TGLUInterface.TessEndContour(tess:TessObj);
begin
     gluTessEndContour(tess);
end;
procedure TGLUInterface.TessCallback(tess:TessObj; which:TGLUIntf_GLenum; CallBackFunc:_GLUfuncptr);
begin
     gluTessCallback(tess,which,CallBackFunc);
end;

procedure TGLUInterface.TessVertex(tess:TessObj; location:PzePoint3d; data:PtrInt);
{type
    PT3darray=^T3darray;}
//var
//   tv:GDBvertex;
begin
     //tv.x:=location.x;
     //tv.y:=location.y;
     //tv.z:=0;
     gluTessVertex(tess,{PT3darray(@tv)^}pointer(location),pointer(data));
end;

constructor TGLUInterface.init;
begin

end;

var
   p:pchar;
initialization
begin
     GLUIntrf.init;
     p:=GLUIntrf.mygluGetString(GLU_VERSION);
     GLUVersion:=p;
     zDebugLn('{I}GLU Version:="%s"',[GLUVersion]);
     //programlog.LogOutFormatStr('GLU Version:="%s"',[GLUVersion],0,LM_Info);
     p:=GLUIntrf.mygluGetString(GLU_EXTENSIONS);
     GLUExtensions:=p;
     zDebugLn('{I}GLU Extensions:="%s"',[p]);
     //programlog.LogOutFormatStr('GLU Extensions:="%s"',[p],0,LM_Info);
end
finalization
  zDebugLn('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
end.
