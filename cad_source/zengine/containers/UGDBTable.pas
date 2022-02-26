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

unit UGDBTable;
{$INCLUDE zcadconfig.inc}
interface
uses gzctnrVector,gzctnrVectorPObjects,sysutils,
     uzctnrvectorstrings;
type
{EXPORT+}
PGDBTableArray=^GDBTableArray;
{REGISTEROBJECTTYPE GDBTableArray}
GDBTableArray= object(GZVectorPObects{-}<PTZctnrVectorStrings,TZctnrVectorStrings>{//})(*OpenArrayOfData=TZctnrVectorStrings*)
                    columns,rows:Integer;
                    constructor init(c,r:Integer);
                    //function copyto(var source:GDBOpenArrayOfData{-}<TZctnrVectorStrings>{//}):Integer;virtual;
              end;
{EXPORT-}
implementation
constructor GDBTableArray.init;
begin
   inherited init(r);
end;
begin
end.
