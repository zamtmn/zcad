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

unit uzeentplain;
{$INCLUDE zengineconfig.inc}

interface
uses
 uzegeometrytypes,uzgldrawcontext,uzegeometry,uzeentwithlocalcs;
type
{EXPORT+}
{REGISTEROBJECTTYPE GDBObjPlain}
GDBObjPlain= object(GDBObjWithLocalCS)
                  Outbound:OutBound4V;(*oi_readonly*)(*hidden_in_objinsp*)

                  procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
            end;
{EXPORT-}
implementation
//uses
//    log;
procedure GDBObjPlain.DrawGeometry;
var
  p: GDBVertex;
begin
  if DC.SystmGeometryDraw{and(POGLWnd.subrender=0)} then
  begin
       {oglsm.myglbegin(GL_LINES);
       oglsm.myglvertex3dv(@outbound[0]);
       oglsm.myglvertex3dv(@outbound[1]);
       oglsm.myglvertex3dv(@outbound[1]);
       oglsm.myglvertex3dv(@outbound[2]);
       oglsm.myglvertex3dv(@outbound[2]);
       oglsm.myglvertex3dv(@outbound[3]);
       oglsm.myglvertex3dv(@outbound[3]);
       oglsm.myglvertex3dv(@outbound[0]);
       oglsm.myglend;}

       //oglsm.myglbegin(GL_LINES);
       //oglsm.glcolor3ub(255,0,0);
       dc.drawer.SetColor(255,0,0,0);

       p:=VertexAdd(Local.P_insert,Local.Basis.ox);
       //oglsm.myglvertex3dv(@Local.P_insert);
       //oglsm.myglvertex3dv(@p);
       dc.drawer.DrawLine3DInModelSpace(Local.P_insert,p,dc.DrawingContext.matrixs);

       //oglsm.glcolor3ub(0,255,0);
       dc.drawer.SetColor(0,255,0,0);
       p:=VertexAdd(Local.P_insert,Local.Basis.oy);
       //oglsm.myglvertex3dv(@Local.P_insert);
       //oglsm.myglvertex3dv(@p);
       dc.drawer.DrawLine3DInModelSpace(Local.P_insert,p,dc.DrawingContext.matrixs);

       //oglsm.glcolor3ub(0,0,255);
       dc.drawer.SetColor(0,0,255,0);
       p:=VertexAdd(Local.P_insert,Local.Basis.oz);
       //oglsm.myglvertex3dv(@Local.P_insert);
       //oglsm.myglvertex3dv(@p);
       dc.drawer.DrawLine3DInModelSpace(Local.P_insert,p,dc.DrawingContext.matrixs);

       //oglsm.myglend;
  end;
  inherited;

end;
begin
end.
