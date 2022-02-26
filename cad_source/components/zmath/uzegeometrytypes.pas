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
interface
type
{EXPORT+}
  PIMatrix4=^IMatrix4;
  IMatrix4=packed array[0..3]of Integer;
  DVector4D=packed array[0..3]of Double;
  DVector3D=packed array[0..2]of Double;
  DVector4F=packed array[0..3]of Single;
  PDMatrix4D=^DMatrix4D;
  DMatrix4D=packed array[0..3]of DVector4D;
  DMatrix3D=packed array[0..2]of DVector3D;
  ClipArray=packed array[0..5]of DVector4D;
  PDMatrix4F=^DMatrix4F;
  DMatrix4F=packed array[0..3]of DVector4F;

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
  GDBvertex=record
                  x:GDBXCoordinate;(*saved_to_shd*)
                  y:GDBYCoordinate;(*saved_to_shd*)
                  z:GDBZCoordinate;(*saved_to_shd*)
            end;
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
  PGDBvertex3S=^GDBvertex3S;
  {REGISTERRECORDTYPE GDBvertex3S}
  GDBvertex3S=record
                  x:Single;(*saved_to_shd*)
                  y:Single;(*saved_to_shd*)
                  z:Single;(*saved_to_shd*)
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
  PGDBvertex2D=^GDBvertex2D;
  {REGISTERRECORDTYPE GDBvertex2D}
  GDBvertex2D=record
                  x:Double;(*saved_to_shd*)
                  y:Double;(*saved_to_shd*)
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
  GDBvertex2S=record
                     x,y:Single;
               end;
  {REGISTERRECORDTYPE GDBvertex2DI}
  GDBvertex2DI=record
                     x,y:Integer;
               end;

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
end.
