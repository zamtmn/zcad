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

unit printerspecfunc;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbase,LCLType,Printers,
     gl,glu,OGLSpecFunc,
     {$IFDEF SLINUX}glx,{$ENDIF}
     {$IFDEF WINDOWS}windows,{$ENDIF}
     log,sysutils,varmandef,Graphics;
type
    PTPrinterRasterizer=^TPrinterRasterizer;
    TPrinterRasterizer=object(TOGLStateManager)
                           model,project,RM:DMatrix4D;
                           prevpoint:gdbvertex;
                           w,h:Integer;
                           wmm,hmm:GDBDouble;
                           procedure myglVertex3d(const V:GDBVertex);virtual;//inline;
                           procedure myglVertex(const x,y,z:GDBDouble);virtual;//inline;
                           procedure myglVertex3dV(const V:PGDBVertex);virtual;//inline;
                           procedure startrender;virtual;//inline;
                           procedure myglPushMatrix;virtual;//inline;
                           procedure myglPopMatrix;virtual;//inline;

                           procedure glcolor3ub(const red, green, blue: GLubyte);virtual;//inline;
                           procedure glColor3ubv(const v: rgb);virtual;//inline;
    end;
implementation
uses
    UGDBDescriptor,geometry;
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

procedure TPrinterRasterizer.glColor3ubv(const v: rgb);
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

procedure TPrinterRasterizer.myglVertex3dV;
var t:gdbvertex;
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
    t:=geometry.VectorTransform3D(v^,RM);
    if currentmode=GL_lines then
    begin
    if pointcount=2 then
                  begin
                  Printer.Canvas.Line(round(((prevpoint.x+1)/2)*wmm),round(h{mm}-((prevpoint.y+1)/2)*hmm),round(((t.x+1)/2)*wmm),round(h{mm}-((t.y+1)/2)*hmm));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
procedure TPrinterRasterizer.startrender;
begin
     inherited;
     RM:=geometry.MatrixMultiply(model,project);
end;
procedure TPrinterRasterizer.myglVertex3d;
var t:gdbvertex;
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
    t:=geometry.VectorTransform3D(v,RM);
    if currentmode=GL_lines then
    begin
    if pointcount=2 then
                  begin
                  Printer.Canvas.Line(round(((prevpoint.x+1)/2)*wmm),round(h{mm}-((prevpoint.y+1)/2)*hmm),round(((t.x+1)/2)*wmm),round(h{mm}-((t.y+1)/2)*hmm));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
procedure TPrinterRasterizer.myglVertex;
var t,t1:gdbvertex;
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
    t:=geometry.VectorTransform3D(createvertex(x,y,z),RM);
    if currentmode=GL_lines then
    begin
    if pointcount=2 then
                  begin
                  Printer.Canvas.Line(round(((prevpoint.x+1)/2)*wmm),round(h{mm}-((prevpoint.y+1)/2)*hmm),round(((t.x+1)/2)*wmm),round(h{mm}-((t.y+1)/2)*hmm));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('printerspecfunc.initialization');{$ENDIF}
end.
