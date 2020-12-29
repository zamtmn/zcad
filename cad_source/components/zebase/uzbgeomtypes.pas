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
unit uzbgeomtypes;
{$INCLUDE def.inc}
interface
uses uzbtypesbase;
type
{EXPORT+}
PIMatrix4=^IMatrix4;
IMatrix4=packed array[0..3]of GDBInteger;
DVector4D=packed array[0..3]of GDBDouble;
DVector3D=packed array[0..2]of GDBDouble;
DVector4F=packed array[0..3]of GDBFloat;
PDMatrix4D=^DMatrix4D;
DMatrix4D=packed array[0..3]of DVector4D;
DMatrix3D=packed array[0..2]of DVector3D;
ClipArray=packed array[0..5]of DVector4D;
PDMatrix4F=^DMatrix4F;
DMatrix4F=packed array[0..3]of DVector4F;

FontFloat=GDBFloat;
PFontFloat=^FontFloat;
PGDBXCoordinate=^GDBXCoordinate;
GDBXCoordinate=GDBDouble;
PGDBYCoordinate=^GDBYCoordinate;
GDBYCoordinate=GDBDouble;
PGDBZCoordinate=^GDBZCoordinate;
GDBZCoordinate=GDBDouble;
PGDBvertex=^GDBvertex;
{REGISTERRECORDTYPE GDBvertex}
GDBvertex=record
                x:GDBXCoordinate;(*saved_to_shd*)
                y:GDBYCoordinate;(*saved_to_shd*)
                z:GDBZCoordinate;(*saved_to_shd*)
          end;
PGDBCoordinates3D=^GDBCoordinates3D;
GDBCoordinates3D=GDBvertex;
PGDBLength=^GDBLength;
GDBLength=GDBDouble;
PGDBQuaternion=^GDBQuaternion;
{REGISTERRECORDTYPE GDBQuaternion}
GDBQuaternion=record
   ImagPart: GDBvertex;
   RealPart: GDBDouble;
              end;
{REGISTERRECORDTYPE GDBBasis}
GDBBasis=record
                ox:GDBvertex;(*'OX Axis'*)(*saved_to_shd*)
                oy:GDBvertex;(*'OY Axis'*)(*saved_to_shd*)
                oz:GDBvertex;(*'OZ Axis'*)(*saved_to_shd*)
          end;
PGDBvertex3S=^GDBvertex3S;
{REGISTERRECORDTYPE GDBvertex3S}
GDBvertex3S=record
                x:GDBFloat;(*saved_to_shd*)
                y:GDBFloat;(*saved_to_shd*)
                z:GDBFloat;(*saved_to_shd*)
          end;
PGDBvertex4S=^GDBvertex4S;
{REGISTERRECORDTYPE GDBvertex4S}
GDBvertex4S=record
                x:GDBFloat;(*saved_to_shd*)
                y:GDBFloat;(*saved_to_shd*)
                z:GDBFloat;(*saved_to_shd*)
                w:GDBFloat;(*saved_to_shd*)
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
                x,y,z,w:GDBDouble;
            end;
{REGISTERRECORDTYPE GDBvertex4F}
GDBvertex4F=record
                x,y,z,w:GDBFloat;
            end;
PGDBvertex2D=^GDBvertex2D;
{REGISTERRECORDTYPE GDBvertex2D}
GDBvertex2D=record
                x:GDBDouble;(*saved_to_shd*)
                y:GDBDouble;(*saved_to_shd*)
            end;
PGDBSnap2D=^GDBSnap2D;
{REGISTERRECORDTYPE GDBSnap2D}
GDBSnap2D=record
                Base:GDBvertex2D;(*'Base'*)(*saved_to_shd*)
                Spacing:GDBvertex2D;(*'Spacing'*)(*saved_to_shd*)
            end;
PGDBFontVertex2D=^GDBFontVertex2D;
{REGISTERRECORDTYPE GDBFontVertex2D}
GDBFontVertex2D=record
                x:FontFloat;(*saved_to_shd*)
                y:FontFloat;(*saved_to_shd*)
            end;
PGDBPolyVertex2D=^GDBPolyVertex2D;
{REGISTERRECORDTYPE GDBPolyVertex2D}
GDBPolyVertex2D=record
                      coord:GDBvertex2D;
                      count:GDBInteger;
                end;
PGDBPolyVertex3D=^GDBPolyVertex3D;
{REGISTERRECORDTYPE GDBPolyVertex3D}
GDBPolyVertex3D=record
                      coord:GDBvertex;
                      count:GDBInteger;
                      LineNumber:GDBInteger;
                end;
PGDBvertex2S=^GDBvertex2S;
{REGISTERRECORDTYPE GDBvertex2S}
GDBvertex2S=record
                   x,y:GDBFloat;
             end;
{REGISTERRECORDTYPE GDBvertex2DI}
GDBvertex2DI=record
                   x,y:GDBInteger;
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
TInBoundingVolume=(IRFully,IRPartially,IREmpty);

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
               d:GDBDouble;
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
{EXPORT-}
implementation
begin
end.

