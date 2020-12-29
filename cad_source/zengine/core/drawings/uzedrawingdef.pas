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

unit uzedrawingdef;
{$INCLUDE def.inc}
interface
uses uzgldrawcontext,uzestylesdim,uzbtypesbase,uzbtypes,uzestyleslayers,uzestylestexts,
     uzedimensionaltypes,uzestyleslinetypes,uzestylestables;
type
{EXPORT+}
PTDrawingDef=^TDrawingDef;
{REGISTEROBJECTTYPE TDrawingDef}
TDrawingDef= object(GDBaseobject)
                       function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
                       function GetLayerTable:PGDBLayerArray;virtual;abstract;
                       function GetLTypeTable:PGDBLtypeArray;virtual;abstract;
                       function GetTextStyleTable:PGDBTextStyleArray;virtual;abstract;
                       function GetTableStyleTable:PGDBTableStyleArray;virtual;abstract;
                       function GetDimStyleTable:PGDBDimStyleArray;virtual;abstract;
                       function GetDWGUnits:{PTUnitManager}pointer;virtual;abstract;
                       procedure AddBlockFromDBIfNeed(name:GDBString);virtual;abstract;
                       function GetCurrentRootSimple:GDBPointer;virtual;abstract;
                       function GetCurrentRootObjArraySimple:GDBPointer;virtual;abstract;
                       function GetBlockDefArraySimple:GDBPointer;virtual;abstract;
                       procedure ChangeStampt(st:GDBBoolean);virtual;abstract;
                       function GetChangeStampt:GDBBoolean;virtual;abstract;
                       function CanUndo:boolean;virtual;abstract;
                       function CanRedo:boolean;virtual;abstract;
                       function CreateDrawingRC(_maxdetail:GDBBoolean=false):TDrawContext;virtual;abstract;
                       function GetUnitsFormat:TzeUnitsFormat;virtual;abstract;
                 end;
{EXPORT-}
implementation
end.
