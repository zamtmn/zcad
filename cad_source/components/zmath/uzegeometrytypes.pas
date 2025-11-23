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

unit uzegeometrytypes;
{$Mode delphi}{$ModeSwitch advancedrecords}{$ModeSwitch typehelpers}{$H+}
{$Macro on}

interface
const
  EPSILON  : Single = 1e-40;
  EPSILON2 : Single = 1e-30;
  eps=1e-14;
  floateps=1e-6;
  sqreps=1e-7;
  bigeps=1e-10;
type
  TzeMatrixType=(MTIdentity,MTScale,MTTranslate,MTRotate,MTShear);
  TzeMatrixTypes=set of TzeMatrixType;
  GRawMatrix4<GRow>=record
    case Integer of
      0:(l0,l1,l2,l3:GRow);
      1:(v:array [0..3] of GRow);
  end;
  GRawMatrix6<GRow>=record
    case Integer of
      0:(right,left,down,up,near,far:GRow);
      1:(v:array [0..5] of GRow);
  end;

  GMatrix4<TMtr>=record
    mtr:TMtr;
    t:TzeMatrixTypes;
    constructor CreateRec(AMtr:TMtr;At:TzeMatrixTypes);
    function IsIdentity:Boolean;inline;
  end;
  GVector4<T;TT:record>=record
    const
      ArrS=4;
    {$Define VectorTypeName := GVector4}
    {$Include gvectorintf.inc}
    {$UnDef VectorTypeName}
    var
      case Integer of
        0:(x,y,z,w:TT);
        1:(v:TCoordArray);
  end;
  GVector3<T;TT:record>=record
    const
      ArrS=3;
    {$Define VectorTypeName := GVector3}
    {$Include gvectorintf.inc}
    {$UnDef VectorTypeName}
    var
      case Integer of
        0:(x,y,z:TT);
        1:(v:TCoordArray);
  end;
  GVector2<T;TT:record>=record
    const
      ArrS=2;
    {$Define VectorTypeName := GVector2}
    {$Include gvectorintf.inc}
    {$UnDef VectorTypeName}
    var
      case Integer of
        0:(x,y:TT);
        1:(v:TCoordArray);
  end;
  GVector4i<T;TT:record>=record
    const
      ArrS=4;
    {$Define VectorTypeName := GVector4i}
    {$Define IntParam}
    {$Include gvectorintf.inc}
    {$UnDef IntParam}
    {$UnDef VectorTypeName}
    var
      case Integer of
        0:(x,y,z,w:TT);
        1:(v:TCoordArray);
  end;
  GVector3i<T;TT:record>=record
    const
      ArrS=3;
    {$Define VectorTypeName := GVector3i}
    {$Define IntParam}
    {$Include gvectorintf.inc}
    {$UnDef IntParam}
    {$UnDef VectorTypeName}
    var
      case Integer of
        0:(x,y,z:TT);
        1:(v:TCoordArray);
  end;
  GVector2i<T;TT:record>=record
    const
      ArrS=2;
    {$Define VectorTypeName := GVector2i}
    {$Define IntParam}
    {$Include gvectorintf.inc}
    {$UnDef IntParam}
    {$UnDef VectorTypeName}
    var
      case Integer of
        0:(x,y:TT);
        1:(v:TCoordArray);
  end;
  TzeXUnits=Double;
  TzeYUnits=Double;
  TzeZUnits=Double;


  TzePoint2d=GVector2<double,double>;
  PzePoint2d=^TzePoint2d;
  TzePoint2i=GVector2i<integer,integer>;
  PzePoint2i=^TzePoint2i;
  TzeVector3d=GVector3<Double,Double>;
  PzeVector3d=^TzeVector3d;
  TzePoint3d=GVector3<Double,Double>;
  PzePoint3d=^TzePoint3d;

  TzeVector4d=GVector4<Double,Double>;
  PzeVector4d=^TzeVector4d;

  TzeVector4s=GVector4<Single,Single>;
  PzeVector4s=^TzeVector4s;

  TzeVector4i=GVector4i<Integer,Integer>;
  PzeVector4i=^TzeVector4i;

  TzeFrustum=GRawMatrix6<TzeVector4d>;

  TzeMatrix4s=GRawMatrix4<TzeVector4s>;
  TzeMatrix4d=GRawMatrix4<TzeVector4d>;

  TzeTypedMatrix4d=GMatrix4<TzeMatrix4d>;
  PzeTypedMatrix4d=^TzeTypedMatrix4d;

  TzeTypedMatrix4s=GMatrix4<TzeMatrix4s>;
  PzeTypedMatrix4s=^TzeTypedMatrix4s;

  TzePoint3s=GVector3<Single,Single>;
  PzePoint3s=^TzePoint3s;

  TzeQuaternion=record
    ImagPart:TzeVector3d;
    RealPart:double;
  end;
  PzeQuaternion=^TzeQuaternion;


  GDBBasis=record
    ox:TzeVector3d;
    oy:TzeVector3d;
    oz:TzeVector3d;
  end;

  GDBObj2dprop=record
    Basis:GDBBasis;
    P_insert:TzePoint3d;
  end;
  PGDBObj2dprop=^GDBObj2dprop;

  PGDBLineProp=^GDBLineProp;
  GDBLineProp=record
    lBegin:TzePoint3d;
    lEnd:TzePoint3d;
  end;

  FontFloat=Double;
  PFontFloat=^FontFloat;
  GDBFontVertex2D=GVector2<FontFloat,FontFloat>;
  PGDBFontVertex2D=^GDBFontVertex2D;

  GDBPolyVertex2D=record
    coord:TzePoint2d;
    count:Integer;
  end;
  PGDBPolyVertex2D=^GDBPolyVertex2D;

  TzePoint2s=GVector2<Single,Single>;
  PzePoint2s=^TzePoint2s;
  tmatrixs=record
    pmodelMatrix:PzeTypedMatrix4d;
    pprojMatrix:PzeTypedMatrix4d;
    pviewport:PzeVector4i;
  end;
{Bounding volume}
  TBoundingBox=record
    LBN:TzePoint3d;(*'Near'*)
    RTF:TzePoint3d;(*'Far'*)
  end;
  TBoundingRect=record
    LB:TzePoint2d;(*'Near'*)
    RT:TzePoint2d;(*'Far'*)
  end;
  TInBoundingVolume=(IRFully,IRPartially,IREmpty,IRNotAplicable);
  OutBound4V=packed array [0..3]of TzePoint3d;
  PGDBQuad3d=^GDBQuad3d;
  GDBQuad2d=packed array[0..3] of TzePoint2d;
  GDBQuad3d=OutBound4V;
  tarcrtmodify=record
    p1,p2,p3:TzePoint2d;
  end;
  ptarcrtmodify=^tarcrtmodify;

  TArcData=record
    r,startangle,endangle:Double;
    p:TzePoint2d;
  end;
  TzeVector3dHlpr=type helper for TzeVector3d
    function asPoint:TzePoint3d;inline;
  end;
  TzePointHlpr=type helper for TzePoint3d
    function asVector3d:TzeVector3d;inline;
  end;

const
 CMTScale=[MTIdentity,MTScale];
 CMTTranslate=[MTIdentity,MTTranslate];
 CMTRotate=[MTIdentity,MTRotate];
 CMTTransform=[MTIdentity,MTScale,MTTranslate,MTRotate];
 CMTIdentity=[MTIdentity];
 CMTShear=[MTShear];
implementation
{$Define VectorTypeName := GVector4}
{$Include gvectorimpl.inc}
{$UnDef VectorTypeName}

{$Define VectorTypeName := GVector3}
{$Include gvectorimpl.inc}
{$UnDef VectorTypeName}

{$DEFINE VectorTypeName := GVector2}
{$Include gvectorimpl.inc}
{$UnDef VectorTypeName}

{$Define VectorTypeName := GVector4i}
{$Define IntParam}
{$Include gvectorimpl.inc}
{$UnDef IntParam}
{$UnDef VectorTypeName}

{$Define VectorTypeName := GVector3i}
{$Define IntParam}
{$Include gvectorimpl.inc}
{$UnDef IntParam}
{$UnDef VectorTypeName}

{$DEFINE VectorTypeName := GVector2i}
{$Define IntParam}
{$Include gvectorimpl.inc}
{$UnDef IntParam}
{$UnDef VectorTypeName}

function TzeVector3dHlpr.asPoint:TzePoint3d;
begin
  result:=TzePoint3d(self);
end;

function TzePointHlpr.asVector3d:TzeVector3d;
begin
  result:=TzeVector3d(self);
end;

constructor GMatrix4<TMtr>.CreateRec(AMtr:TMtr;At:TzeMatrixTypes);
begin
  mtr:=AMtr;
  t:=At;
end;
function GMatrix4<TMtr>.IsIdentity:Boolean;
begin
  result:=(t=CMTIdentity);
end;

end.
