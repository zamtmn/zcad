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

{EXPORT+}
  TMatrixComponents=(MTIdentity,MTScale,MTTranslate,MTRotate,MTShear);
  TMatrixType={-}set of TMatrixComponents{/Byte/};
{EXPORT-}
  GMatrix4<TMtr>=record
    mtr:TMtr;
    t:TMatrixType;
    constructor CreateRec(AMtr:TMtr;At:TMatrixType);
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
{EXPORT+}

  GDBXCoordinate=Double;
  PGDBXCoordinate=^GDBXCoordinate;
  GDBYCoordinate=Double;
  PGDBYCoordinate=^GDBYCoordinate;
  GDBZCoordinate=Double;
  PGDBZCoordinate=^GDBZCoordinate;


  {REGISTERRECORDTYPE TzeVector3d}
  {-}TzeVector3d=GVector3<Double,Double>;{//}
  {-}{/TzeVector3d=record/}
    {-}{/x:GDBXCoordinate;/}
    {-}{/y:GDBYCoordinate;/}
    {-}{/z:GDBZCoordinate;/}
  {-}{/end;/}
  PzeVector3d=^TzeVector3d;

  {REGISTERRECORDTYPE TzePoint3d}
  {-}TzePoint3d=GVector3<Double,Double>;{//}
  {-}{/TzePoint3d=record/}
    {-}{/x:GDBXCoordinate;/}
    {-}{/y:GDBYCoordinate;/}
    {-}{/z:GDBZCoordinate;/}
  {-}{/end;/}
  PzePoint3d=^TzePoint3d;

  {REGISTERRECORDTYPE TzePoint3s}
  {-}TzePoint3s=GVector3<Single,Single>;{//}
  {-}{/TzePoint3s=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
    {-}{/z:Single;/}
  {-}{/end;/}
  PzePoint3s=^TzePoint3s;

  {REGISTERRECORDTYPE TzePoint2d}
  {-}TzePoint2d=GVector2<Double,Double>;{//}
  {-}{/TzePoint2d=record/}
    {-}{/x:Double;/}
    {-}{/y:Double;/}
  {-}{/end;/}
  PzePoint2d=^TzePoint2d;

  //Matrix4i=packed array[0..3]of Integer;
  {REGISTERRECORDTYPE Matrix4i}
  {-}Matrix4i=GVector4i<Integer,Integer>;{//}
  {-}{/Matrix4i=record/}
    {-}{/x:Integer;/}
    {-}{/y:Integer;/}
    {-}{/z:Integer;/}
    {-}{/w:Integer;/}
  {-}{/end;/}
  PMatrix4i=^Matrix4i;

  {REGISTERRECORDTYPE GDBSnap2D}
  GDBSnap2D=record
    Base:TzePoint2d;(*'Base'*)
    Spacing:TzePoint2d;(*'Spacing'*)
  end;
  PGDBSnap2D=^GDBSnap2D;

  {REGISTERRECORDTYPE TzePoint2i}
  {-}TzePoint2i=GVector2i<Integer,Integer>;{//}
  {-}{/TzePoint2i=record/}
    {-}{/x:Integer;/}
    {-}{/y:Integer;/}
  {-}{/end;/}
  PzePoint2i=^TzePoint2i;

  {REGISTERRECORDTYPE GDBCameraBaseProp}
  GDBCameraBaseProp=record
    point:TzePoint3d;
    look:TzeVector3d;
    ydir:TzeVector3d;
    xdir:TzeVector3d;
    zoom:double;
  end;

  {REGISTERRECORDTYPE GDBplane}
  GDBplane=record
    normal:TzeVector3d;
    d:double;
  end;

  {REGISTERRECORDTYPE GDBPiece}
  GDBPiece=record
    lbegin:TzePoint3d;
    dir:TzeVector3d;
    lend:TzePoint3d;
  end;

  {REGISTERRECORDTYPE DVector4s}
  {-}DVector4s=GVector4<Single,Single>;{//}
  {-}{/DVector4s=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
    {-}{/z:Single;/}
    {-}{/w:Single;/}
  {-}{/end;/}

  {REGISTERRECORDTYPE DVector4d}
  {-}DVector4d=GVector4<Double,Double>;{//}
  {-}{/DVector4d=record/}
    {-}{/x:Double;/}
    {-}{/y:Double;/}
    {-}{/z:Double;/}
    {-}{/w:Double;/}
  {-}{/end;/}

  TMatrix4d=packed array[0..3]of DVector4d;
  PDMatrix4d=^DMatrix4d;
  {-}DMatrix4d=GMatrix4<TMatrix4d>;{//}
  {-}{/DMatrix4d=record/}
  {-}{/  mtr:TMatrix4d;/}
  {-}{/  t:TMatrixType;/}
  {-}{/end;            /}

  TMatrix4f=packed array[0..3]of DVector4s;
  PDMatrix4f=^DMatrix4f;
  {-}DMatrix4f=GMatrix4<TMatrix4f>;{//}
  {-}{/DMatrix4f=record/}
  {-}{/  mtr:TMatrix4f;/}
  {-}{/  t:TMatrixType;/}
  {-}{/end;            /}

  ClipArray=packed array[0..5]of DVector4d;

{EXPORT-}

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

  TzeVector4s=GVector4<single,single>;
  PTzeVector4s=^TzeVector4s;

  TzeVector4d=GVector4<double,double>;
  PTzeVector4d=^TzeVector4d;

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
    pmodelMatrix:PDMatrix4d;
    pprojMatrix:PDMatrix4d;
    pviewport:PMatrix4i;
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

constructor GMatrix4<TMtr>.CreateRec(AMtr:TMtr;At:TMatrixType);
begin
  mtr:=AMtr;
  t:=At;
end;
function GMatrix4<TMtr>.IsIdentity:Boolean;
begin
  result:=(t=CMTIdentity);
end;

end.
