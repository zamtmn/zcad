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

unit UOpenArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,sysutils,gdbase;
type
GDBITERATEPROC = procedure(pdata:GDBPointer);stdcall;
{Export+}
POpenArray=^OpenArray;
OpenArray=object(GDBaseObject)
                Deleted:GDBLongword;(*hidden_in_objinsp*)
                Count:GDBLongword;(*saved_to_shd*)(*hidden_in_objinsp*)
                Max:GDBLongword;(*hidden_in_objinsp*)
                Size:GDBLongword;(*hidden_in_objinsp*)
                constructor init(m,s:GDBInteger);
                function GetElemCount:GDBInteger;
          end;
{Export-}
implementation
uses
    log;
function OpenArray.GetElemCount;
begin
  result:=count-deleted;
end;
constructor OpenArray.init(m, s: GDBInteger);
begin
  Count := 0;
  Deleted:=0;
  Max := m;
  Size := s;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UOpenArray.initialization');{$ENDIF}
end.
