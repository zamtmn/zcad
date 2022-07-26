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

unit uzcinterfacedata;
{$INCLUDE zengineconfig.inc}

interface
uses
       uzestyleslayers,uzestyleslinetypes,uzestylestexts,uzestylesdim,
       classes;
type
  TInterfaceVars=record
                       CColor,CLWeight:Integer;
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

