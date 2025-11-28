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
unit uzeentplain;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzegeometrytypes,uzgldrawcontext,uzegeometry,uzeentwithlocalcs;

type

  GDBObjPlain=object(GDBObjWithLocalCS)
    Outbound:OutBound4V;
    procedure DrawGeometry(lw:integer;
      var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
  end;

implementation

procedure GDBObjPlain.DrawGeometry;
var
  p:TzePoint3d;
begin
  if DC.SystmGeometryDraw then begin
    dc.drawer.SetColor(255,0,0,0);

    p:=VertexAdd(Local.P_insert,Local.Basis.ox);
    dc.drawer.DrawLine3DInModelSpace(Local.P_insert,p,dc.DrawingContext.matrixs);

    dc.drawer.SetColor(0,255,0,0);
    p:=VertexAdd(Local.P_insert,Local.Basis.oy);
    dc.drawer.DrawLine3DInModelSpace(Local.P_insert,p,dc.DrawingContext.matrixs);

    dc.drawer.SetColor(0,0,255,0);
    p:=VertexAdd(Local.P_insert,Local.Basis.oz);
    dc.drawer.DrawLine3DInModelSpace(Local.P_insert,p,dc.DrawingContext.matrixs);
  end;
  inherited;

end;

begin
end.
