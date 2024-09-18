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
PGDBObjVisualProp=^GDBObjVisualProp;
GDBObjVisualProp=record
                      Layer:PGDBLayerProp;
                      LineWeight:TGDBLineWeight;
                      LineType:PGDBLtypeProp;
                      LineTypeScale:GDBNonDimensionDouble;
                      BoundingBox:TBoundingBox;
                      LastCameraPos:TActulity;
                      Color:TGDBPaletteColor;
                 end;
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
