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

unit UGDBNamedObjectsArray;
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrVectorTypes,gzctnrVectorPObjects,sysutils,uzbtypes,uzegeometry,
     uzeNamedObject,gzctnrVectorClass;
type
{EXPORT+}
TForCResult=(IsFounded(*'IsFounded'*)=1,
             IsCreated(*'IsCreated'*)=2,
             IsError(*'IsError'*)=3);
{------REGISTEROBJECTTYPE GDBNamedObjectsArray}
GDBNamedObjectsArray{-}<PTObj,TObj>{//}
                     = object(GZVectorPObects{-}<PTObj,TObj>{//})
                    constructor init(m:Integer);
                    function getIndex(const name: String):Integer;
                    function getAddres(const name: String):Pointer;
                    function GetIndexByPointer(p:PGDBNamedObject):Integer;
                    function AddItem(const name:String; out PItem:Pointer):TForCResult;
                    function MergeItem(const name:String;LoadMode:TLoadOpt):Pointer;
                    function GetFreeName(const NameFormat:String;firstindex:integer):String;
                    procedure IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);virtual;
              end;
{EXPORT-}
PTGenericNamedObjectsArray=^TGenericNamedObjectsArray;
TGenericNamedObjectsArray=GDBNamedObjectsArray{-}<PGDBNamedObject,GDBNamedObject>{//};
TNamedObjectsArray{-}<TCls:Class>{//}
                     = class(GZVectorClass{-}<TCls>{//})
              end;
implementation
procedure GDBNamedObjectsArray<PTObj,TObj>.IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);
var p:PGDBNamedObject;
    ir:itrec;
begin
    inherited;
    p:=beginiterate(ir);
    if p<>nil then
    repeat
         p^.IterateCounter(PCounted,Counter,proc);
    p:=iterate(ir);
    until p=nil;
end;
function GDBNamedObjectsArray<PTObj,TObj>.GetFreeName(const NameFormat:String;firstindex:integer):String;
var
   counter,LoopCounter:integer;
   OldName:String;
begin
  counter:=firstindex-1;
  OldName:='';
  LoopCounter:=0;
  repeat
    inc(counter);
    inc(LoopCounter);
  try
       result:=sysutils.format(NameFormat,[counter]);;
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
function GDBNamedObjectsArray<PTObj,TObj>.MergeItem(const name:String;LoadMode:TLoadOpt):Pointer;
begin
     if AddItem(name,result)=IsFounded then
                       begin
                            if LoadMode=TLOMerge then
                            begin
                                 result:=nil;
                            end;
                       end;
end;
function GDBNamedObjectsArray<PTObj,TObj>.AddItem;
var
  p:PGDBNamedObject;
  ir:itrec;
  name_upper:string;
begin
  PItem:=nil;
  begin
       p:=beginiterate(ir);
       name_upper:=uppercase(name);
       if p<>nil then
       begin
       result:=IsFounded;
       repeat
            if uppercase(p^.name) = name_upper then
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
constructor GDBNamedObjectsArray<PTObj,TObj>.init;
begin
  inherited init(m);
end;
function GDBNamedObjectsArray<PTObj,TObj>.getIndex;
var
  p:PGDBNamedObject;
  ir:itrec;
  name_upper: String;
begin
  result := -1;

  p:=beginiterate(ir);
  name_upper:=uppercase(name);// Может вызывать отложенно? по флагу
  if p<>nil then
  repeat
    if uppercase(p^.name) = name_upper then
    begin
      result := ir.itc;
      exit;
    end;
    p:=iterate(ir);
  until p=nil;
end;
function GDBNamedObjectsArray<PTObj,TObj>.getAddres;
var
  p:PGDBNamedObject;
      ir:itrec;
  name_upper:string;
begin
  result:=nil;
  p:=beginiterate(ir);
  name_upper:=uppercase(name);
  if p<>nil then
  repeat
    if uppercase(p^.name) = name_upper then
    begin
      result := p;
      exit;
    end;
    p:=iterate(ir);
  until p=nil;
end;
function GDBNamedObjectsArray<PTObj,TObj>.GetIndexByPointer(p:PGDBNamedObject):Integer;
var
  _pobj:PGDBNamedObject;
  ir:itrec;
begin
  result:=-1;
  _pobj:=beginiterate(ir);
  if _pobj<>nil then
  repeat
    if _pobj = p then
    begin
      result := ir.itc;
      exit;
    end;
    _pobj:=iterate(ir);
  until _pobj=nil;
end;
begin
end.
