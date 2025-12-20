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

unit uzedrawingdef;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzgldrawcontext,uzestylesdim,uzbtypes,uzestyleslayers,uzestylestexts,
  uzbUnits,
  uzestyleslinetypes,uzestylestables;
type
{EXPORT+}
PTDrawingDef=^TDrawingDef;
{REGISTEROBJECTTYPE TDrawingDef}
TDrawingDef= object(GDBaseobject)
                       procedure CreateBlockDef(name:String);virtual;abstract;
                       function GetLayerTable:PGDBLayerArray;virtual;abstract;
                       function GetLTypeTable:PGDBLtypeArray;virtual;abstract;
                       function GetTextStyleTable:PGDBTextStyleArray;virtual;abstract;
                       function GetTableStyleTable:PGDBTableStyleArray;virtual;abstract;
                       function GetDimStyleTable:PGDBDimStyleArray;virtual;abstract;
                       function GetDWGUnits:{PTUnitManager}pointer;virtual;abstract;
                       procedure AddBlockFromDBIfNeed(name:String);virtual;abstract;
                       function GetCurrentRootSimple:Pointer;virtual;abstract;
                       function GetCurrentRootObjArraySimple:Pointer;virtual;abstract;
                       function GetBlockDefArraySimple:Pointer;virtual;abstract;
                       function GetConstructEntsCount:Integer;virtual;abstract;
                       procedure ChangeStampt(st:Boolean);virtual;abstract;
                       function GetChangeStampt:Boolean;virtual;abstract;
                       function CanUndo:boolean;virtual;abstract;
                       function CanRedo:boolean;virtual;abstract;
                       function CreateDrawingRC(_maxdetail:Boolean=false;ExcludeOpts:TDContextOptions=[]):TDrawContext;virtual;abstract;
                       function GetUnitsFormat:TzeUnitsFormat;virtual;abstract;
                 end;
{EXPORT-}
implementation
end.
