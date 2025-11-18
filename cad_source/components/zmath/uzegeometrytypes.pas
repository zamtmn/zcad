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

  FontFloat=Double;
  PFontFloat=^FontFloat;
  PGDBXCoordinate=^GDBXCoordinate;
  GDBXCoordinate=Double;
  PGDBYCoordinate=^GDBYCoordinate;
  GDBYCoordinate=Double;
  PGDBZCoordinate=^GDBZCoordinate;
  GDBZCoordinate=Double;

  PzeVector3d=^TzeVector3d;
  {REGISTERRECORDTYPE TzeVector3d}
  {-}TzeVector3d=GVector3<Double,Double>;{//}
  {-}{/TzeVector3d=record/}
    {-}{/x:GDBXCoordinate;/}
    {-}{/y:GDBYCoordinate;/}
    {-}{/z:GDBZCoordinate;/}
  {-}{/end;/}

  PzePoint3d=^TzePoint3d;
  {REGISTERRECORDTYPE TzePoint3d}
  {-}TzePoint3d=GVector3<Double,Double>;{//}
  {-}{/TzePoint3d=record/}
    {-}{/x:GDBXCoordinate;/}
    {-}{/y:GDBYCoordinate;/}
    {-}{/z:GDBZCoordinate;/}
  {-}{/end;/}

  PzePoint3s=^TzePoint3s;
  {REGISTERRECORDTYPE TzePoint3s}
  {-}TzePoint3s=GVector3<Single,Single>;{//}
  {-}{/TzePoint3s=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
    {-}{/z:Single;/}
  {-}{/end;/}

  PzePoint2d=^TzePoint2d;
  {REGISTERRECORDTYPE TzePoint2d}
  {-}TzePoint2d=GVector2<Double,Double>;{//}
  {-}{/TzePoint2d=record/}
    {-}{/x:Double;/}
    {-}{/y:Double;/}
  {-}{/end;/}

  //DVector4s=packed array[0..3]of Single;
  PDVector4s=^DVector4s;
  {REGISTERRECORDTYPE DVector4s}
  {-}DVector4s=GVector4<Single,Single>;{//}
  {-}{/DVector4s=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
    {-}{/z:Single;/}
    {-}{/w:Single;/}
  {-}{/end;/}

  PMatrix4i=^Matrix4i;
  //Matrix4i=packed array[0..3]of Integer;
  {REGISTERRECORDTYPE Matrix4i}
  {-}Matrix4i=GVector4i<Integer,Integer>;{//}
  {-}{/Matrix4i=record/}
    {-}{/x:Integer;/}
    {-}{/y:Integer;/}
    {-}{/z:Integer;/}
    {-}{/w:Integer;/}
  {-}{/end;/}

  //DVector4d=packed array[0..3]of Double;
  {REGISTERRECORDTYPE DVector4d}
  {-}DVector4d=GVector4<Double,Double>;{//}
  {-}{/DVector4d=record/}
    {-}{/x:Double;/}
    {-}{/y:Double;/}
    {-}{/z:Double;/}
    {-}{/w:Double;/}
  {-}{/end;/}

  //DVector3D=packed array[0..2]of Double;
  {REGISTERRECORDTYPE DVector3D}
  {-}DVector3D=GVector3<Double,Double>;{//}
  {-}{/DVector3D=record/}
    {-}{/x:Double;/}
    {-}{/y:Double;/}
    {-}{/z:Double;/}
  {-}{/end;/}
  PMatrix4d=^TMatrix4d;
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

  DMatrix3D=packed array[0..2]of DVector3D;
  ClipArray=packed array[0..5]of DVector4d;

  PGDBCoordinates3D=^GDBCoordinates3D;
  GDBCoordinates3D=TzePoint3d;
  PGDBLength=^GDBLength;
  GDBLength=Double;
  PGDBQuaternion=^GDBQuaternion;

  {REGISTERRECORDTYPE GDBQuaternion}
  GDBQuaternion=record
     ImagPart: TzePoint3d;
     RealPart: Double;
                end;
  {REGISTERRECORDTYPE GDBBasis}
  GDBBasis=record
                  ox:TzePoint3d;(*'OX Axis'*)
                  oy:TzePoint3d;(*'OY Axis'*)
                  oz:TzePoint3d;(*'OZ Axis'*)
            end;

  PGDBObj2dprop=^GDBObj2dprop;
  {REGISTERRECORDTYPE GDBObj2dprop}
  GDBObj2dprop=record
    Basis:GDBBasis;(*'Basis'*)
    P_insert:GDBCoordinates3D;(*'Insertion point OCS'*)
  end;

  PGDBvertex4S=^GDBvertex4S;
  {REGISTERRECORDTYPE GDBvertex4S}
  GDBvertex4S=record
                  x:Single;
                  y:Single;
                  z:Single;
                  w:Single;
            end;
  PGDBLineProp=^GDBLineProp;
  {REGISTERRECORDTYPE GDBLineProp}
  GDBLineProp=record
                    lBegin:GDBCoordinates3D;(*'Begin'*)
                    lEnd:GDBCoordinates3D;(*'End'*)
                end;
  PGDBvertex4D=^GDBvertex4D;
  {REGISTERRECORDTYPE GDBvertex4D}
  GDBvertex4D=record
                  x,y,z,w:Double;
              end;
  {REGISTERRECORDTYPE GDBvertex4F}
  GDBvertex4F=record
                  x,y,z,w:Single;
              end;
  PGDBSnap2D=^GDBSnap2D;
  {REGISTERRECORDTYPE GDBSnap2D}
  GDBSnap2D=record
                  Base:TzePoint2d;(*'Base'*)
                  Spacing:TzePoint2d;(*'Spacing'*)
              end;
  PGDBFontVertex2D=^GDBFontVertex2D;
  {REGISTERRECORDTYPE GDBFontVertex2D}
  {-}GDBFontVertex2D=GVector2<FontFloat,FontFloat>;{//}
  {-}{/GDBFontVertex2D=record/}
    {-}{/x:FontFloat;/}
    {-}{/y:FontFloat;/}
  {-}{/end;/}
  PGDBPolyVertex2D=^GDBPolyVertex2D;
  {REGISTERRECORDTYPE GDBPolyVertex2D}
  GDBPolyVertex2D=record
                        coord:TzePoint2d;
                        count:Integer;
                  end;
  PGDBPolyVertex3D=^GDBPolyVertex3D;
  {REGISTERRECORDTYPE GDBPolyVertex3D}
  GDBPolyVertex3D=record
                        coord:TzePoint3d;
                        count:Integer;
                        LineNumber:Integer;
                  end;
  PzePoint2s=^TzePoint2s;
  {REGISTERRECORDTYPE TzePoint2s}
  {-}TzePoint2s=GVector2<Single,Single>;{//}
  {-}{/TzePoint2s=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
  {-}{/end;/}
  {REGISTERRECORDTYPE TzePoint2i}
  {-}TzePoint2i=GVector2i<Integer,Integer>;{//}
  {-}{/TzePoint2i=record/}
    {-}{/x:Integer;/}
    {-}{/y:Integer;/}
  {-}{/end;/}
  {REGISTERRECORDTYPE GDBCameraBaseProp}
  GDBCameraBaseProp=record
                          point:TzePoint3d;
                          look:TzePoint3d;
                          ydir:TzePoint3d;
                          xdir:TzePoint3d;
                          zoom: Double;
                    end;
  {REGISTERRECORDTYPE tmatrixs}
  tmatrixs=record
                     pmodelMatrix:PDMatrix4d;
                     pprojMatrix:PDMatrix4d;
                     pviewport:PMatrix4i;
  end;

  {Bounding volume}
  {REGISTERRECORDTYPE TBoundingBox}
  TBoundingBox=record
                        LBN:TzePoint3d;(*'Near'*)
                        RTF:TzePoint3d;(*'Far'*)
                  end;
  {REGISTERRECORDTYPE TBoundingRect}
  TBoundingRect=record
                        LB:TzePoint2d;(*'Near'*)
                        RT:TzePoint2d;(*'Far'*)
                  end;
  TInBoundingVolume=(IRFully,IRPartially,IREmpty,IRNotAplicable);

  PTzePoint2i=^TzePoint2i;
  TzePoint2iArray=packed array [0..0] of TzePoint2i;
  OutBound4V=packed array [0..3]of TzePoint3d;
  PGDBQuad3d=^GDBQuad3d;
  GDBQuad2d=packed array[0..3] of TzePoint2d;
  GDBQuad3d=OutBound4V;
  PGDBLineProj=^GDBLineProj;
  GDBLineProj=packed array[0..6] of TzePoint2d;
  {REGISTERRECORDTYPE GDBplane}
  GDBplane=record
                 normal:TzePoint3d;
                 d:Double;
           end;
  {REGISTERRECORDTYPE GDBray}
  GDBray=record
               start,dir:TzePoint3d;
         end;
  {REGISTERRECORDTYPE GDBPiece}
  GDBPiece=record
               lbegin,dir,lend:TzePoint3d;
         end;
  ptarcrtmodify=^tarcrtmodify;
  {REGISTERRECORDTYPE tarcrtmodify}
  tarcrtmodify=record
                        p1,p2,p3:TzePoint2d;
                  end;
  {REGISTERRECORDTYPE TArcData}
  TArcData=record
                 r,startangle,endangle:Double;
                 p:TzePoint2d;
  end;
{EXPORT-}
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
  result:=PzePoint3d(@self)^;
end;

function TzePointHlpr.asVector3d:TzeVector3d;
begin
  result:=PzeVector3d(@self)^;
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
