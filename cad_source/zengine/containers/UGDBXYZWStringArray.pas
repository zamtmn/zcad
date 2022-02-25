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

unit UGDBXYZWStringArray;
{$INCLUDE zcadconfig.inc}
interface
uses uzbtypesbase,uzbtypes,gzctnrVector,sysutils;
type
{EXPORT+}
PGDBXYZWStringArray=^XYZWGDBStringArray;
{REGISTEROBJECTTYPE XYZWGDBStringArray}
XYZWGDBStringArray= object(GZVector{-}<GDBStrWithPoint>{//})
                             constructor init(m:Integer);
                             procedure freeelement(PItem:PT);virtual;
                             //function add(p:Pointer):TArrayIndex;virtual;
                       end;
{EXPORT-}
implementation
//uses
//    log;
{function XYZWGDBStringArray.add(p:Pointer):TArrayIndex;
begin
     AddByPointer(p);
     Pointer(PGDBStrWithPoint(p)^.str):=nil;
end;}
procedure XYZWGDBStringArray.freeelement(PItem:PT);
begin
     PGDBStrWithPoint(PItem)^.str:='';
end;
constructor XYZWGDBStringArray.init(m:Integer);
begin
     inherited init(m);
end;
begin
end.
