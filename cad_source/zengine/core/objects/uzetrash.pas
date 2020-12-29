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

unit uzetrash;
{$INCLUDE def.inc}
interface
uses
    uzbgeomtypes,uzbtypesbase,uzbtypes,uzeentity,uzeconsts,uzegeometry;
type
{EXPORT+}
{REGISTEROBJECTTYPE GDBObjTrash}
GDBObjTrash= object(GDBObjEntity)
                 function GetHandle:GDBPlatformint;virtual;
                 function GetMatrix:PDMatrix4D;virtual;
                 constructor initnul;
                 destructor done;virtual;
            end;
{EXPORT-}
var
    GDBTrash:GDBObjTrash;
implementation
 //uses log;
function GDBObjTrash.GetHandle;
begin
     result:=H_Trash;
end;
function GDBObjTrash.GetMatrix;
begin
     result:=@onematrix;
end;
constructor GDBObjTrash.initnul;
begin
end;
destructor GDBObjTrash.done;
begin
end;
begin
end.
