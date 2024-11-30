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

unit uzecamera;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzbLogIntf,uzegeometrytypes,uzbtypes,uzegeometry;

type
  GDBProjectProc=procedure (objcoord:GDBVertex; out wincoord:GDBVertex) of object;
{EXPORT+}
  PGDBObjCamera=^GDBObjCamera;
{REGISTEROBJECTTYPE GDBObjCamera}
  GDBObjCamera= object(GDBBaseCamera)
    modelMatrixLCS:DMatrix4D;
    zminLCS,zmaxLCS:Double;
    frustumLCS:ClipArray;
    clipLCS:DMatrix4D;
    projMatrixLCS:DMatrix4D;
    notuseLCS:Boolean;
    procedure getfrustum(mm,pm:PDMatrix4D;var _clip:DMatrix4D;var _frustum:ClipArray);
    procedure RotateInLocalCSXY(ux,uy:Double);
    procedure MoveInLocalCSXY(oldx,oldy:Double;ax:gdbvertex);
    function GetObjTypeName:String;virtual;
    constructor initnul;

    procedure NextPosition;virtual;
  end;
{EXPORT-}

implementation

procedure GDBObjCamera.NextPosition;
begin
  POSCOUNT:=zeHandles.CreateHandle;
  //VISCOUNT:=zeHandles.CreateHandle;
end;
constructor GDBObjCamera.initnul;
begin
  POSCOUNT:=zeHandles.CreateHandle;
  VISCOUNT:=zeHandles.CreateHandle;
end;
function GDBObjCamera.GetObjTypeName;
begin
  result:='GDBObjCamera';
end;
procedure GDBObjCamera.getfrustum;
begin
  _clip:=MatrixMultiply(mm^,pm^);
  _frustum:=calcfrustum(@_clip);
end;
procedure GDBObjCamera.RotateInLocalCSXY(ux,uy:Double);
var
  tempmatr,rotmatr:DMatrix4D;
begin
  tempmatr:=CreateMatrixFromBasis(prop.xdir,prop.ydir,prop.look);
  rotmatr:=MatrixMultiply(CreateRotationMatrixY(uy),CreateRotationMatrixX(ux));
  tempmatr:=MatrixMultiply(rotmatr,tempmatr);

  prop.xdir:=pgdbvertex(@tempmatr.mtr[0])^;
  prop.ydir:=pgdbvertex(@tempmatr.mtr[1])^;
  prop.look:=pgdbvertex(@tempmatr.mtr[2])^;

  prop.look:=NormalizeVertex(prop.look);
  prop.xdir := CrossVertex(prop.ydir,prop.look);
  prop.xdir:=NormalizeVertex(prop.xdir);
  prop.ydir := CrossVertex(prop.look,prop.xdir);
end;
procedure GDBObjCamera.MoveInLocalCSXY(oldx,oldy:Double;ax:gdbvertex);
var
  tempmatr,rotmatr:DMatrix4D;
  tv,tv2:gdbvertex4d;
  len,d:Double;
begin
  rotmatr:=CreateMatrixFromBasis(prop.xdir,prop.ydir,prop.look);

  tv2.x:=-oldx;
  tv2.y:=-oldy;
  tv2.z:=0;
  tv2.w:=1;

  len:=onevertexlength(ax);
  d:=sqrt(tv2.x*tv2.x+tv2.y*tv2.y+tv2.z*tv2.z);
  if d>eps then begin
  len:=len/d;
  if (abs(ax.x)>eps)or(abs(ax.y)>eps) then begin
    tv2.x:=tv2.x*len;
    tv2.y:=tv2.y*len;
    tv:=tv2;
    tempmatr:=rotmatr;
    tv:=vectortransform(tv,tempmatr);
    tv.x:=tv.x;
    Pgdbvertex(@rotmatr.mtr[3])^:=prop.point;
    tempmatr:=CreateTranslationMatrix(Pgdbvertex(@tv)^);
    tempmatr:=MatrixMultiply(rotmatr,tempmatr);
    prop.point:=Pgdbvertex(@tempmatr.mtr[3])^;
  end;
  end else
    zDebugln('GDBObjCamera.MoveInLocalCSXY:'+rsDivByZero);
end;
begin
end.
