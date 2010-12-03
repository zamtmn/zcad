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
{$INCLUDE def.inc}
interface
uses gdbasetypes,gdbase,UGDBOpenArrayOfData{,UGDBOpenArrayOfByte},sysutils;
type
{EXPORT+}
PGDBXYZWGDBStringArray=^XYZWGDBGDBStringArray;
XYZWGDBGDBStringArray=object(GDBOpenArrayOfData)
                             constructor init(m:GDBInteger);
                             procedure freeelement(p:GDBPointer);virtual;
                             function add(p:GDBPointer):TArrayIndex;virtual;
                       end;
{EXPORT-}
implementation
uses
    log;
function XYZWGDBGDBStringArray.add(p:GDBPointer):TArrayIndex;
begin
     GDBOpenArrayOfData.add(p);
     GDBPointer(PGDBStrWithPoint(p)^.str):=nil;
end;
procedure XYZWGDBGDBStringArray.freeelement(p:GDBPointer);
begin
     PGDBStrWithPoint(p)^.str:='';
end;
constructor XYZWGDBGDBStringArray.init(m:GDBInteger);
begin
     inherited init({$IFDEF DEBUGBUILD}'{5F615BF3-34BD-4C3E-9019-CE7CB9D2C2E7}',{$ENDIF}m,sizeof(GDBStrWithPoint));
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBXYZWStringArray.initialization');{$ENDIF}
end.
