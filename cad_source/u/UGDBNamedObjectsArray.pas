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

unit UGDBNamedObjectsArray;
{$INCLUDE def.inc}
interface
uses ugdbopenarrayofpidentobects,sysutils,gdbase, geometry,
     {varmandef,gdbobjectsconstdef}gdbasetypes;
type
{EXPORT+}
TForCResult=(IsFounded(*'IsFounded'*)=1,
             IsCreated(*'IsCreated'*)=2,
             IsError(*'IsError'*)=3);
PGDBNamedObjectsArray=^GDBNamedObjectsArray;
GDBNamedObjectsArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjOpenArrayOfPIdentObects)(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,s:GDBInteger);
                    function getIndex(name: GDBString):GDBInteger;
                    function getAddres(name: GDBString):GDBPointer;
                    function GetIndexByPointer(p:PGDBNamedObject):GDBInteger;
                    function AddItem(name:GDBSTRING; out PItem:Pointer):TForCResult;
                    function MergeItem(name:GDBSTRING;LoadMode:TLoadOpt):GDBPointer;
                    function GetFreeName(NameFormat:GDBString;firstindex:integer):GDBString;
              end;
{EXPORT-}
implementation
uses
    log;
function GDBNamedObjectsArray.GetFreeName(NameFormat:GDBString;firstindex:integer):GDBString;
var
   counter,LoopCounter:integer;
   OldName:GDBString;
begin
  counter:=firstindex-1;
  OldName:='';
  LoopCounter:=0;
  repeat
    inc(counter);
    inc(LoopCounter);
  try
       result:=sysutils.format({'Unnamed%-3.3d'}NameFormat,[counter]);;
  except
       result:='';
  end;
  if OldName=result then
                        begin
                          result:='';
                          exit;
                        end;
  if LoopCounter>99 then
                        begin
                             result:='';
                             exit;
                        end;
  OldName:=result;
  until getIndex(result)=-1;
end;

function GDBNamedObjectsArray.MergeItem(name:GDBSTRING;LoadMode:TLoadOpt):GDBPointer;
begin
     if AddItem(name,result)=IsFounded then
                       begin
                            if LoadMode=TLOMerge then
                            begin
                                 result:=nil;
                            end;
                       end;
end;

function GDBNamedObjectsArray.AddItem;
var
  p:PGDBNamedObject;
  ir:itrec;
begin
  PItem:=nil;
  //result:=IsError;
  {if count = 0 then
  begin
       PItem:=createobject;
       result:=IsCreated;
  end
  else}
  begin
       p:=beginiterate(ir);
       if p<>nil then
       begin
       result:=IsFounded;
       repeat
            if uppercase(p^.name) = uppercase(name) then
                                                        begin
                                                             PItem:=p;
                                                             system.exit;
                                                        end;
            p:=iterate(ir);
       until p=nil;
       end;
    begin
      result:=IsCreated;
      PItem:=createobject;
    end;
  end;
end;
constructor GDBNamedObjectsArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,s);
end;
function GDBNamedObjectsArray.getIndex;
var
  p:PGDBNamedObject;
    ir:itrec;
begin
  result := -1;

  p:=beginiterate(ir);
  if p<>nil then
  repeat
    if uppercase(p^.name) = uppercase(name) then
    begin
      result := ir.itc;
      exit;
    end;
    p:=iterate(ir);
  until p=nil;
end;
function GDBNamedObjectsArray.getAddres;
var
  p:PGDBNamedObject;
      ir:itrec;
begin
  result:=nil;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
    if uppercase(p^.name) = uppercase(name) then
    begin
      result := p;
      exit;
    end;
    p:=iterate(ir);
  until p=nil;
end;
function GDBNamedObjectsArray.GetIndexByPointer(p:PGDBNamedObject):GDBInteger;
{старая версия, когда именованые объекты располагались не по ссылке
begin
     result:=(GDBPlatformint(p)-GDBPlatformint(parray))div size
end;}
var
  pobj:PGDBNamedObject;
  ir:itrec;
begin
  result:=-1;
  pobj:=beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj = p then
    begin
      result := ir.itc;
      exit;
    end;
    pobj:=iterate(ir);
  until pobj=nil;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBNamedObjectArray.initialization');{$ENDIF}
end.
