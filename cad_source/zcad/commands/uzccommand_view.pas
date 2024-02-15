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
{$mode delphi}
unit uzccommand_view;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  sysutils,
  uzegeometrytypes,uzegeometry,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings;

implementation

function view_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   s:string;
   ox,oy,oz:gdbvertex;
   m:DMatrix4D;
   recognized:boolean;
begin
  s:=uppercase(operands);
  ox:=createvertex(-1,0,0);
  oy:=createvertex(0,1,0);
  oz:=uzegeometry.CrossVertex(ox,oy);
  recognized:=true;
  if s='TOP' then begin
    //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(-1,0,0),createvertex(0,1,0),createvertex(0,0,-1))
    ox:=createvertex(-1,0,0);
    oy:=createvertex(0,1,0);
  end else if s='BOTTOM' then begin
    //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(1,0,0),createvertex(0,1,0),createvertex(0,0,1))
    ox:=createvertex(1,0,0);
    oy:=createvertex(0,1,0);
  end else if s='LEFT' then begin
    //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(0,0,-1),createvertex(0,1,0),createvertex(1,0,0))
    ox:=createvertex(0,0,-1);
    oy:=createvertex(0,1,0);
  end else if s='RIGHT' then begin
    //drawings.GetCurrentDWG.OGLwindow1.RotTo(createvertex(0,0,1),createvertex(0,1,0),createvertex(-1,0,0))
    ox:=createvertex(0,0,1);
    oy:=createvertex(0,1,0);
  end else if s='NEISO' then begin
    ox:=createvertex(1,0,0);
    oy:=createvertex(0,1,0);
    m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                  CreateRotationMatrixZ(sin(-pi/4),cos(-pi/4)));
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='SEISO' then begin
    ox:=createvertex(1,0,0);
    oy:=createvertex(0,1,0);

    m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                  CreateRotationMatrixZ(sin(pi+pi/4),cos(pi+pi/4)));
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='NWISO' then begin
    ox:=createvertex(1,0,0);
    oy:=createvertex(0,1,0);

    m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                  CreateRotationMatrixZ(sin({pi+}pi/4),cos({pi+}pi/4)));
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='SWISO' then begin
    ox:=createvertex(1,0,0);
    oy:=createvertex(0,1,0);

    m:=uzegeometry.MatrixMultiply(CreateRotationMatrixX(sin(pi/2+pi/6),cos(pi/2+pi/6)),
                                  CreateRotationMatrixZ(sin(pi-pi/4),cos(pi-pi/4)));
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='RL' then begin
    m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.look,-45*pi/180);
    ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
    oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='RR' then begin
    m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.look,45*pi/180);
    ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
    oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='RU' then begin
    m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.xdir,-45*pi/180);
    ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
    oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else if s='RD' then begin
    m:=CreateAffineRotationMatrix(drawings.GetCurrentDWG.GetPcamera^.prop.xdir,45*pi/180);
    ox:=drawings.GetCurrentDWG.GetPcamera^.prop.xdir;
    oy:=drawings.GetCurrentDWG.GetPcamera^.prop.ydir;
    ox:=VectorTransform3D(ox,m);
    oy:=VectorTransform3D(oy,m);
  end else
    recognized:=false;
  if recognized then begin
    oz:=uzegeometry.CrossVertex(ox,oy);
    drawings.GetCurrentDWG.wa.RotTo(ox,oy,oz);
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@view_com,'View',CADWG,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
