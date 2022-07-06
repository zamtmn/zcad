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

unit uzegeometrytypes;
{$Mode delphi}{$ModeSwitch advancedrecords}{$H+}
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
        0:(v:TCoordArray);
        1:(x,y:TT);
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
        0:(v:TCoordArray);
        1:(x,y:TT);
  end;
{EXPORT+}

  FontFloat=Single;
  PFontFloat=^FontFloat;
  PGDBXCoordinate=^GDBXCoordinate;
  GDBXCoordinate=Double;
  PGDBYCoordinate=^GDBYCoordinate;
  GDBYCoordinate=Double;
  PGDBZCoordinate=^GDBZCoordinate;
  GDBZCoordinate=Double;


  PGDBvertex=^GDBvertex;
  {REGISTERRECORDTYPE GDBvertex}
  {-}GDBvertex=GVector3<Double,Double>;{//}
  {-}{/GDBvertex=record/}
    {-}{/x:GDBXCoordinate;/}
    {-}{/y:GDBYCoordinate;/}
    {-}{/z:GDBZCoordinate;/}
  {-}{/end;/}

  PGDBvertex3S=^GDBvertex3S;
  {REGISTERRECORDTYPE GDBvertex3S}
  {-}GDBvertex3S=GVector3<Single,Single>;{//}
  {-}{/GDBvertex3S=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
    {-}{/z:Single;/}
  {-}{/end;/}

  PGDBvertex2D=^GDBvertex2D;
  {REGISTERRECORDTYPE GDBvertex2D}
  {-}GDBvertex2D=GVector2<Double,Double>;{//}
  {-}{/GDBvertex2D=record/}
    {-}{/x:Double;/}
    {-}{/y:Double;/}
  {-}{/end;/}

  //DVector4F=packed array[0..3]of Single;
  PDVector4F=^DVector4F;
  {REGISTERRECORDTYPE DVector4F}
  {-}DVector4F=GVector4<Single,Single>;{//}
  {-}{/DVector4F=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
    {-}{/z:Single;/}
    {-}{/w:Single;/}
  {-}{/end;/}

  PIMatrix4=^IMatrix4;
  //IMatrix4=packed array[0..3]of Integer;
  {REGISTERRECORDTYPE IMatrix4}
  {-}IMatrix4=GVector4i<Integer,Integer>;{//}
  {-}{/IMatrix4=record/}
    {-}{/x:Integer;/}
    {-}{/y:Integer;/}
    {-}{/z:Integer;/}
    {-}{/w:Integer;/}
  {-}{/end;/}

  //DVector4D=packed array[0..3]of Double;
  {REGISTERRECORDTYPE DVector4D}
  {-}DVector4D=GVector4<Double,Double>;{//}
  {-}{/DVector4D=record/}
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

  PDMatrix4D=^DMatrix4D;
  DMatrix4D=packed array[0..3]of DVector4D;
  DMatrix3D=packed array[0..2]of DVector3D;
  ClipArray=packed array[0..5]of DVector4D;
  PDMatrix4F=^DMatrix4F;
  DMatrix4F=packed array[0..3]of DVector4F;

  PGDBCoordinates3D=^GDBCoordinates3D;
  GDBCoordinates3D=GDBvertex;
  PGDBLength=^GDBLength;
  GDBLength=Double;
  PGDBQuaternion=^GDBQuaternion;
  {REGISTERRECORDTYPE GDBQuaternion}
  GDBQuaternion=record
     ImagPart: GDBvertex;
     RealPart: Double;
                end;
  {REGISTERRECORDTYPE GDBBasis}
  GDBBasis=record
                  ox:GDBvertex;(*'OX Axis'*)(*saved_to_shd*)
                  oy:GDBvertex;(*'OY Axis'*)(*saved_to_shd*)
                  oz:GDBvertex;(*'OZ Axis'*)(*saved_to_shd*)
            end;
  PGDBvertex4S=^GDBvertex4S;
  {REGISTERRECORDTYPE GDBvertex4S}
  GDBvertex4S=record
                  x:Single;(*saved_to_shd*)
                  y:Single;(*saved_to_shd*)
                  z:Single;(*saved_to_shd*)
                  w:Single;(*saved_to_shd*)
            end;
  PGDBLineProp=^GDBLineProp;
  {REGISTERRECORDTYPE GDBLineProp}
  GDBLineProp=record
                    lBegin:GDBCoordinates3D;(*'Begin'*)(*saved_to_shd*)
                    lEnd:GDBCoordinates3D;(*'End'*)(*saved_to_shd*)
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
                  Base:GDBvertex2D;(*'Base'*)(*saved_to_shd*)
                  Spacing:GDBvertex2D;(*'Spacing'*)(*saved_to_shd*)
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
                        coord:GDBvertex2D;
                        count:Integer;
                  end;
  PGDBPolyVertex3D=^GDBPolyVertex3D;
  {REGISTERRECORDTYPE GDBPolyVertex3D}
  GDBPolyVertex3D=record
                        coord:GDBvertex;
                        count:Integer;
                        LineNumber:Integer;
                  end;
  PGDBvertex2S=^GDBvertex2S;
  {REGISTERRECORDTYPE GDBvertex2S}
  {-}GDBvertex2S=GVector2<Single,Single>;{//}
  {-}{/GDBvertex2S=record/}
    {-}{/x:Single;/}
    {-}{/y:Single;/}
  {-}{/end;/}
  {REGISTERRECORDTYPE GDBvertex2DI}
  {-}GDBvertex2DI=GVector2i<Integer,Integer>;{//}
  {-}{/GDBvertex2DI=record/}
    {-}{/x:Integer;/}
    {-}{/y:Integer;/}
  {-}{/end;/}
  {REGISTERRECORDTYPE GDBCameraBaseProp}
  GDBCameraBaseProp=record
                          point:GDBvertex;
                          look:GDBvertex;
                          ydir:GDBvertex;
                          xdir:GDBvertex;
                          zoom: Double;
                    end;
  {REGISTERRECORDTYPE tmatrixs}
  tmatrixs=record
                     pmodelMatrix:PDMatrix4D;
                     pprojMatrix:PDMatrix4D;
                     pviewport:PIMatrix4;
  end;

  {Bounding volume}
  {REGISTERRECORDTYPE TBoundingBox}
  TBoundingBox=record
                        LBN:GDBvertex;(*'Near'*)
                        RTF:GDBvertex;(*'Far'*)
                  end;
  {REGISTERRECORDTYPE TBoundingRect}
  TBoundingRect=record
                        LB:GDBvertex2D;(*'Near'*)
                        RT:GDBvertex2D;(*'Far'*)
                  end;
  TInBoundingVolume=(IRFully,IRPartially,IREmpty,IRNotAplicable);

  PGDBvertex2DI=^GDBvertex2DI;
  GDBvertex2DIArray=packed array [0..0] of GDBvertex2DI;
  OutBound4V=packed array [0..3]of GDBvertex;
  PGDBQuad3d=^GDBQuad3d;
  GDBQuad2d=packed array[0..3] of GDBvertex2D;
  GDBQuad3d=OutBound4V;
  PGDBLineProj=^GDBLineProj;
  GDBLineProj=packed array[0..6] of GDBvertex2D;
  {REGISTERRECORDTYPE GDBplane}
  GDBplane=record
                 normal:GDBvertex;
                 d:Double;
           end;
  {REGISTERRECORDTYPE GDBray}
  GDBray=record
               start,dir:GDBvertex;
         end;
  {REGISTERRECORDTYPE GDBPiece}
  GDBPiece=record
               lbegin,dir,lend:GDBvertex;
         end;
  ptarcrtmodify=^tarcrtmodify;
  {REGISTERRECORDTYPE tarcrtmodify}
  tarcrtmodify=record
                        p1,p2,p3:GDBVertex2d;
                  end;
  {REGISTERRECORDTYPE TArcData}
  TArcData=record
                 r,startangle,endangle:Double;
                 p:GDBvertex2D;
  end;
{EXPORT-}
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
end.
