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
uses gzctnrvector,gzctnrvectorpobjects,uzbtypesbase,sysutils,
     uzctnrvectorstrings;
type
{EXPORT+}
PGDBTableArray=^GDBTableArray;
{REGISTEROBJECTTYPE GDBTableArray}
GDBTableArray= object(GZVectorPObects{-}<PTZctnrVectorGDBString,TZctnrVectorString>{//})(*OpenArrayOfData=TZctnrVectorGDBString*)
                    columns,rows:GDBInteger;
                    constructor init(c,r:GDBInteger);
                    //function copyto(var source:GDBOpenArrayOfData{-}<TZctnrVectorGDBString>{//}):GDBInteger;virtual;
              end;
{EXPORT-}
implementation
constructor GDBTableArray.init;
begin
   inherited init(r);
end;
begin
end.
