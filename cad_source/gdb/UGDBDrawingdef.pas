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

unit UGDBDrawingdef;
interface
uses ugdbdimstylearray,gdbase,gdbasetypes,UGDBLayerArray,UGDBTextStyleArray,ugdbltypearray,UUnitManager,UGDBTableStyleArray;
type
{EXPORT+}
PTDrawingDef=^TDrawingDef;
TDrawingDef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseobject)
                       function GetLayerTable:PGDBLayerArray;virtual;abstract;
                       function GetLTypeTable:PGDBLtypeArray;virtual;abstract;
                       function GetTextStyleTable:PGDBTextStyleArray;virtual;abstract;
                       function GetTableStyleTable:PGDBTableStyleArray;virtual;abstract;
                       function GetDimStyleTable:PGDBDimStyleArray;virtual;abstract;
                       function GetDWGUnits:PTUnitManager;virtual;abstract;
                       procedure AddBlockFromDBIfNeed(name:GDBString);virtual;abstract;
                       function GetCurrentRootSimple:GDBPointer;virtual;abstract;
                       function GetBlockDefArraySimple:GDBPointer;virtual;abstract;
                       procedure ChangeStampt(st:GDBBoolean);virtual;abstract;
                 end;
{EXPORT-}
implementation
end.
