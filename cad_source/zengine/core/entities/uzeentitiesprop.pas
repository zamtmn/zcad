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

unit uzeentitiesprop;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzedimensionaltypes,uzepalette,uzestyleslinetypes,uzegeometrytypes,uzbtypes,uzegeometry,sysutils,
     uzctnrVectorBytes,uzestyleslayers;
type
//ID:TObjID;(*'Object type'*)(*oi_readonly*)(*hidden_in_objinsp*)
{Export+}
PGDBObjVisualProp=^GDBObjVisualProp;
{REGISTERRECORDTYPE GDBObjVisualProp}
GDBObjVisualProp=record
                      Layer:{-}PGDBLayerProp{/PGDBLayerPropObjInsp/};(*'Layer'*)
                      LineWeight:TGDBLineWeight;(*'Line weight'*)
                      LineType:{-}PGDBLtypeProp{/PGDBLtypePropObjInsp/};(*'Line type'*)
                      LineTypeScale:GDBNonDimensionDouble;(*'Line type scale'*)
                      BoundingBox:TBoundingBox;(*'Bounding box'*)(*oi_readonly*)(*hidden_in_objinsp*)
                      LastCameraPos:TActulity;(*oi_readonly*)(*hidden_in_objinsp*)
                      Color:TGDBPaletteColor;
                 end;
{Export-}
function getLTfromVP(const vp:GDBObjVisualProp):PGDBLtypeProp;
implementation
function getLTfromVP(const vp:GDBObjVisualProp):PGDBLtypeProp;
begin
      result:=vp.LineType;
      if assigned(result) then
      if result.Mode=TLTByLayer then
                                result:=vp.Layer.LT;
end;
begin
end.
