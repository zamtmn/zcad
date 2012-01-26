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
     log,sysutils,varmandef;
type
    PTPrinterRasterizer=^TPrinterRasterizer;
    TPrinterRasterizer=object(TOGLStateManager)
                           model,project,RM:DMatrix4D;
                           prevpoint:gdbvertex;
                           w,h:Integer;
                           procedure myglVertex3d(const V:GDBVertex);virtual;//inline;
                           procedure myglVertex(const x,y,z:GDBDouble);virtual;//inline;
                           procedure myglVertex3dV(const V:PGDBVertex);virtual;//inline;
                           procedure startrender;virtual;//inline;
    end;
implementation
uses
    UGDBDescriptor,geometry;
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
                  Printer.Canvas.Line(round(prevpoint.x*Printer.PageWidth),round(Printer.PageHeight-prevpoint.y*Printer.PageHeight),round(t.x*Printer.PageWidth),round(Printer.PageHeight-t.y*Printer.PageHeight));
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
                  Printer.Canvas.Line(round(prevpoint.x*w),round(h-prevpoint.y*h),round(t.x*w),round(h-t.y*h));
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
                  Printer.Canvas.Line(round(prevpoint.x*Printer.PageWidth),round(Printer.PageHeight-prevpoint.y*Printer.PageHeight),round(t.x*Printer.PageWidth),round(Printer.PageHeight-t.y*Printer.PageHeight));
                  pointcount:=0
                  end
    else
        prevpoint:=t;

    end;
end;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('printerspecfunc.initialization');{$ENDIF}
end.
