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

uses
  uzepalette,uzestyleslinetypes,uzegeometrytypes,
  uzeTypes,SysUtils,
 uzctnrVectorBytesStream,uzestyleslayers;

type
  PGDBObjVisualProp=^GDBObjVisualProp;

  GDBObjVisualProp=record
    Layer:PGDBLayerProp;
    LineWeight:TGDBLineWeight;
    LineType:PGDBLtypeProp;
    LineTypeScale:TZeDimLess;
    BoundingBox:TBoundingBox;
    LastCameraPos:TActuality;
    Color:TGDBPaletteColor;
  end;

function getLTfromVP(const vp:GDBObjVisualProp):PGDBLtypeProp;

implementation

function getLTfromVP(const vp:GDBObjVisualProp):PGDBLtypeProp;
begin
  Result:=vp.LineType;
  if assigned(Result) then
    if Result.Mode=TLTByLayer then
      Result:=vp.Layer.LT;
end;

begin
end.
