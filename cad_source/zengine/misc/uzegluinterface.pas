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

unit uzegluinterface;
{$INCLUDE zengineconfig.inc}

interface
uses LCLProc,uzepalette,{$IFNDEF DELPHI}LCLType,{$ENDIF}
     {$IFNDEF DELPHI}glu,gl,{$ELSE}dglOpenGL,windows,{$ENDIF}
     {$IFDEF SLINUX}glx,{$ENDIF}
     uzegeometrytypes,sysutils,uzegeometry;
const
      GLU_VERSION={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_VERSION;
      GLU_TESS_VERTEX={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_VERTEX;
      GLU_TESS_VERTEX_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_VERTEX_DATA;
      GLU_TESS_BEGIN_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_BEGIN_DATA;
      GLU_TESS_ERROR_DATA={$IFNDEF DELPHI}glu.{$ELSE}dglOpenGL.{$ENDIF}GLU_TESS_ERROR_DATA;
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
type
    PTViewPortArray=^TViewPortArray;

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
                           procedure TessVertex(tess:TessObj; location:PGDBVertex; data:pointer);
                           procedure TessCallback(tess:TessObj; which:GLenum; CallBackFunc:_GLUfuncptr);

                           function NewNurbsRenderer:GLUnurbsObj;
                           procedure DeleteNurbsRenderer(renderer:GLUnurbsObj);
                           procedure NurbsCallback(nurb:GLUnurbsObj; which:GLenum; CallBackFunc:_GLUfuncptr);
                           procedure BeginCurve(renderer:GLUnurbsObj);
	                   procedure EndCurve(renderer:GLUnurbsObj);
                           procedure NurbsCurve(nurb:PGLUnurbs; knotCount:GLint; knots:PGLfloat; stride:GLint; control:PGLfloat;
                                                order:GLint; _type:GLenum);
                           procedure NurbsProperty(nurb:PGLUnurbs; _property:GLenum; value:GLfloat);
                           function ErrorString(error:GLenum):glu.PGLubyte;
                           function mygluGetString(name: GLenum): PAnsiChar;
                           procedure mygluPickMatrix(x:GLdouble; y:GLdouble; delX:GLdouble; delY:GLdouble; viewport:PGLint);
                           procedure mygluLoadSamplingMatrices(renderer:GLUnurbsObj;const model,perspective:PGLfloat;view:PGLint);
    end;

var
   GLUIntrf:TGLUInterface;
   GLUVersion,GLUExtensions:String;
implementation
function TGLUInterface.mygluGetString(name: GLenum): PAnsiChar;
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
procedure TGLUInterface.DeleteNurbsRenderer(renderer:GLUnurbsObj);
begin
     gluDeleteNurbsRenderer(renderer)
end;
procedure TGLUInterface.NurbsCallback(nurb:GLUnurbsObj; which:GLenum; CallBackFunc:_GLUfuncptr);
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
procedure TGLUInterface.NurbsCurve(nurb:PGLUnurbs; knotCount:GLint; knots:PGLfloat; stride:GLint; control:PGLfloat;order:GLint; _type:GLenum);
begin
     gluNurbsCurve(nurb,knotCount,knots,stride,control,order,_type);
end;
procedure TGLUInterface.NurbsProperty(nurb:PGLUnurbs; _property:GLenum; value:GLfloat);
begin
     gluNurbsProperty(nurb,_property,value);
end;
function TGLUInterface.ErrorString(error:GLenum):glu.PGLubyte;
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
procedure TGLUInterface.TessCallback(tess:TessObj; which:GLenum; CallBackFunc:_GLUfuncptr);
begin
     gluTessCallback(tess,which,CallBackFunc);
end;

procedure TGLUInterface.TessVertex(tess:TessObj; location:PGDBVertex; data:pointer);
{type
    PT3darray=^T3darray;}
//var
//   tv:gdbvertex;
begin
     //tv.x:=location.x;
     //tv.y:=location.y;
     //tv.z:=0;
     gluTessVertex(tess,{PT3darray(@tv)^}pointer(location),data);
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
     debugln('{I}GLU Version:="%s"',[GLUVersion]);
     //programlog.LogOutFormatStr('GLU Version:="%s"',[GLUVersion],0,LM_Info);
     p:=GLUIntrf.mygluGetString(GLU_EXTENSIONS);
     GLUExtensions:=p;
     debugln('{I}GLU Extensions:="%s"',[p]);
     //programlog.LogOutFormatStr('GLU Extensions:="%s"',[p],0,LM_Info);
end
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
