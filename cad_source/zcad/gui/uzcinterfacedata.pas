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

unit uzcinterfacedata;
{$INCLUDE def.inc}

interface
uses
       uzbtypesbase,uzestyleslayers,uzestyleslinetypes,uzestylestexts,uzestylesdim,
       classes;
type
  TInterfaceVars=record
                       CColor,CLWeight:GDBInteger;
                       CLayer:PGDBLayerProp;
                       CLType:PGDBLTypeProp;
                       CTStyle:PGDBTextStyle;
                       CDimStyle:PGDBDimStyle;
                 end;
var
  IVars:TInterfaceVars;
  updatesbytton,updatescontrols,enabledcontrols:tlist;
const
     LTEditor:pointer=@IVars;//пофиг что, используем только цифру
implementation
end.

