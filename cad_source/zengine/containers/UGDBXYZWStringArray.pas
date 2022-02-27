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
uses uzbtypes,gzctnrVector,sysutils;
type
{EXPORT+}
PGDBXYZWStringArray=^XYZWStringArray;
{REGISTEROBJECTTYPE XYZWStringArray}
XYZWStringArray= object(GZVector{-}<GDBStrWithPoint>{//})
                             constructor init(m:Integer);
                             procedure freeelement(PItem:PT);virtual;
                             //function add(p:Pointer):TArrayIndex;virtual;
                       end;
{EXPORT-}
implementation
//uses
//    log;
{function XYZWStringArray.add(p:Pointer):TArrayIndex;
begin
     AddByPointer(p);
     Pointer(PGDBStrWithPoint(p)^.str):=nil;
end;}
procedure XYZWStringArray.freeelement(PItem:PT);
begin
     PGDBStrWithPoint(PItem)^.str:='';
end;
constructor XYZWStringArray.init(m:Integer);
begin
     inherited init(m);
end;
begin
end.
