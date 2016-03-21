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

unit ugdbopenarrayofpidentobects;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfPObjects,
     gdbase,GDBasetypes,memman{,log};
type
{Export+}
PGDBObjOpenArrayOfPIdentObects=^GDBObjOpenArrayOfPIdentObects;
GDBObjOpenArrayOfPIdentObects={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                             objsizeof:GDBInteger;
                             constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,_objsizeof:GDBInteger);
                             function getelement(index:TArrayIndex):GDBPointer;
                             function CreateObject:PGDBaseObject;
                end;
{Export-}
implementation
function GDBObjOpenArrayOfPIdentObects.getelement(index:TArrayIndex):GDBPointer;
var pp:ppointer;
begin
     pp:=inherited getelement(index);
     if pp=nil then
                   result:=nil
               else
                   result:=pp^;
end;

constructor GDBObjOpenArrayOfPIdentObects.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m);
  objsizeof:=_objsizeof;
end;
function GDBObjOpenArrayOfPIdentObects.CreateObject;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{6F264155-0BCB-408F-BDA7-F3E8A4540F18}',{$ENDIF}pointer(result),objsizeof);
  add(@result);
end;

begin
end.
