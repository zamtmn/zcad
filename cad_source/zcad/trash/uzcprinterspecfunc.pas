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

unit uzcprinterspecfunc;
{$INCLUDE zengineconfig.inc}

interface
uses uzegeometrytypes,uzepalette,LCLType,Printers,
     gl,glu,uzgloglstatemanager,
     {$IFDEF SLINUX}glx,{$ENDIF}
     sysutils,uzsbVarmanDef,Graphics,uzcdrawings,uzegeometry;
type
    PTPrinterRasterizer=^TPrinterRasterizer;
    TPrinterRasterizer=object(TOGLStateManager)
                           model,project,RM:DMatrix4d;
                           prevpoint:gdbvertex;
                           w,h:Integer;
                           wmm,hmm,scalex,scaley:Double;
                           procedure myglVertex3d(const V:GDBVertex);virtual;//inline;
                           procedure myglVertex(const x,y,z:Double);virtual;//inline;
                           procedure myglVertex3dV(const V:PzePoint3d);virtual;//inline;
                           procedure startrender;virtual;//inline;
                           procedure myglPushMatrix;virtual;//inline;
                           procedure myglPopMatrix;virtual;//inline;

                           procedure glcolor3ub(const red, green, blue: GLubyte);virtual;//inline;
                           procedure glColor3ubv(const v: TRGB);virtual;//inline;
                           Function translate(const V:GDBVertex):TzePoint2i;
                           procedure myglPointSize(const size: GLfloat);virtual;//inline;
                           procedure myglLineWidth(const width: GLfloat);virtual;//inline;
    end;
implementation
procedure TPrinterRasterizer.myglPointSize(const size: GLfloat);
begin
     myglLineWidth(size);
end;
procedure TPrinterRasterizer.myglLineWidth(const width: GLfloat);
begin
     if currentlinewidth<>width then
                     begin
                          mytotalglend;
                          Printer.Canvas.Pen.Width:=round(width/25.4*60);
                          currentlinewidth:=width;
                     end;
end;

procedure TPrinterRasterizer.glcolor3ub(const red, green, blue: GLubyte);
begin
     if (red<>_colour.r)
     or (green<>_colour.g)
     or (blue<>_colour.b)then
                              begin
                                   _colour.r:=red;
                                   _colour.g:=green;
                                   _colour.b:=blue;
                                   Printer.Canvas.Pen.Color:=RGBToColor(_colour.r,_colour.g,_colour.b);
                                   //gl.glColor3ubv(@_colour);
                              end;
end;

procedure TPrinterRasterizer.glColor3ubv(const v: TRGB);
begin
     if (v.r<>_colour.r)
     or (v.g<>_colour.g)
     or (v.b<>_colour.b)then
                              begin
                                   Printer.Canvas.Pen.Color:=RGBToColor(v.r,v.g,v.b);
                                   //gl.glColor3ubv(@v);
                                   _colour:=v;
                              end;
end;
procedure TPrinterRasterizer.myglPushMatrix;
begin
     inherited;
end;

procedure TPrinterRasterizer.myglPopMatrix;
begin
     inherited;
end;
Function TPrinterRasterizer.translate(const V:GDBVertex):TzePoint2i;
begin
     //result.x:=round(((v.x+1)/2)*w{mm});
     //result.y:=round(h{mm}-((v.y+1)/2)*h{mm});
     result.x:=round(v.x);
     result.y:=round(v.y);
end;
procedure TPrinterRasterizer.startrender;
begin
    //scalex:={w}scalex*1000;
    //scaley:={h}scaley*1000;
     inherited;
     RM:=uzegeometry.MatrixMultiply(model,project);
     RM:=uzegeometry.MatrixMultiply(RM,uzegeometry.CreateTranslationMatrix(createvertex(1,1,0)));
     RM:=uzegeometry.MatrixMultiply(RM,uzegeometry.CreateScaleMatrix(createvertex(0.5,-0.5,1)));
     RM:=uzegeometry.MatrixMultiply(RM,uzegeometry.CreateScaleMatrix(createvertex(wmm*scalex*600/25.4,hmm*scalex*600/25.4,1)));
     RM:=uzegeometry.MatrixMultiply(RM,uzegeometry.CreateTranslationMatrix(createvertex(0,h,0)));
end;
procedure TPrinterRasterizer.myglVertex3dV;
var t:gdbvertex;
    p1,p2:TzePoint2i;
begin
     (*{$IFDEF DEBUGCOUNTGEOMETRY}
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
    *)
    inc(pointcount);
    t:=uzegeometry.VectorTransform3D(v^,RM);
    if currentmode=GL_lines then
    begin
    if pointcount=2 then
                  begin
                  p1:=translate(prevpoint);
                  p2:=translate(t);
                  Printer.Canvas.Line(p1.x,p1.y,p2.x,p2.y);
                  //Printer.Canvas.Line(round(((prevpoint.x+1)/2)*wmm),round(h{mm}-((prevpoint.y+1)/2)*hmm),round(((t.x+1)/2)*wmm),round(h{mm}-((t.y+1)/2)*hmm));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
procedure TPrinterRasterizer.myglVertex3d;
var t:gdbvertex;
    p1,p2:TzePoint2i;
begin
     (*{$IFDEF DEBUGCOUNTGEOMETRY}
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
     *)
    inc(pointcount);
    t:=uzegeometry.VectorTransform3D(v,RM);
    if currentmode=GL_lines then
    begin
    if pointcount=2 then
                  begin
                  p1:=translate(prevpoint);
                  p2:=translate(t);
                  Printer.Canvas.Line(p1.x,p1.y,p2.x,p2.y);
                  //Printer.Canvas.Line(round(((prevpoint.x+1)/2)*wmm),round(h{mm}-((prevpoint.y+1)/2)*hmm),round(((t.x+1)/2)*wmm),round(h{mm}-((t.y+1)/2)*hmm));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
procedure TPrinterRasterizer.myglVertex;
var t{,t1}:gdbvertex;
    p1,p2:TzePoint2i;
begin
     (*
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
     *)
    inc(pointcount);
    t:=uzegeometry.VectorTransform3D(createvertex(x,y,z),RM);
    if currentmode=GL_lines then
    begin
    if pointcount=2 then
                  begin
                  p1:=translate(prevpoint);
                  p2:=translate(t);
                  Printer.Canvas.Line(p1.x,p1.y,p2.x,p2.y);
                  //Printer.Canvas.Line(round(((prevpoint.x+1)/2)*wmm),round(h{mm}-((prevpoint.y+1)/2)*hmm),round(((t.x+1)/2)*wmm),round(h{mm}-((t.y+1)/2)*hmm));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
begin
end.
