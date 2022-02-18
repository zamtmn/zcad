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

unit uzcregenginefeatures;
{$INCLUDE zcadconfig.inc}
interface
uses uzeutils,uzeentity,uzedrawingsimple,uzbtypes,uzeconsts,uzeenttext,uzeentdimension,LazLogger;
implementation
procedure zeSetTextStylePropFromDrawingProp(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);
var
  enttype:TObjID;
begin
     enttype:=PEnt^.GetObjType;
     if (enttype=GDBMTextID)or(enttype=GDBTextID)then
     begin
       PGDBObjText(PEnt)^.TXTStyleIndex:=Drawing.CurrentTextStyle;
     end;
end;
procedure zeSetDimStylePropFromDrawingProp(const PEnt: PGDBObjEntity; var Drawing:TSimpleDrawing);
var
  enttype:TObjID;
begin
     enttype:=PEnt^.GetObjType;
     if (enttype=GDBAlignedDimensionID)or(enttype=GDBRotatedDimensionID)or
        (enttype=GDBDiametricDimensionID)or(enttype=GDBRadialDimensionID)then
     begin
       PGDBObjDimension(PEnt)^.PDimStyle:=Drawing.CurrentDimStyle;
     end;
end;
initialization;
  zeRegisterEntPropSetter(zeSetTextStylePropFromDrawingProp);
  zeRegisterEntPropSetter(zeSetDimStylePropFromDrawingProp);
finalization;
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
