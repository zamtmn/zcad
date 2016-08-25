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
{$INCLUDE def.inc}
interface
uses uzeutils,uzeentity,uzedrawingsimple,uzbtypes,uzeconsts,uzeenttext;
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
initialization;
    zeRegisterEntPropSetter(zeSetTextStylePropFromDrawingProp);
finalization;
end.
