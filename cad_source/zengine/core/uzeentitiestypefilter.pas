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

unit uzeentitiestypefilter;
{$INCLUDE def.inc}


interface
uses LCLProc,uzeentityfactory,
     sysutils,uzbtypesbase,uzbtypes,
     usimplegenerics,Masks;
type
  TEntsTypeFilter=class
    Filter,
    Include,
    Exclude: TObjID2Counter;
    constructor Create;
    destructor Destroy;override;
    procedure AddType(EntType:TObjID);
    procedure AddTypeName(EntTypeName:GDBString);
    procedure AddTypeNameMask(EntTypeNameMask:GDBString);
    procedure SubType(EntType:TObjID);
    procedure SubTypeName(EntTypeName:GDBString);
    procedure SubTypeNameMask(EntTypeNameMask:GDBString);
    procedure SetFilter;
    procedure ResetFilter;
    function IsEntytyTypeAccepted(EntType:TObjID):boolean;
    function IsEmpty:boolean;
  end;
implementation
constructor TEntsTypeFilter.Create;
begin
  Filter:=TObjID2Counter.create;
  Include:=TObjID2Counter.create;
  Exclude:=TObjID2Counter.create;
end;

destructor TEntsTypeFilter.Destroy;
begin
  FreeAndNil(Filter);
  FreeAndNil(Include);
  FreeAndNil(Exclude);
end;

procedure TEntsTypeFilter.AddType(EntType:TObjID);
begin
  Include.CountKey(EntType,1);
end;

procedure TEntsTypeFilter.AddTypeName(EntTypeName:GDBString);
var EntInfoData:TEntInfoData;
begin
  if ENTName2EntInfoData.TryGetValue(UpperCase(EntTypeName),EntInfoData) then
    Include.CountKey(EntInfoData.EntityID,1);
end;

procedure TEntsTypeFilter.AddTypeNameMask(EntTypeNameMask:GDBString);
var
  iterator:ObjID2EntInfoData.TIterator;
  s:string;
begin
  iterator:=ObjID2EntInfoData.Min;
  if assigned(iterator) then
  repeat
    s:=iterator.Data.Value.DXFName;
    s:=iterator.Data.Value.UserName;
    if (MatchesMask(iterator.Data.Value.UserName,EntTypeNameMask,false))
    or (AnsiCompareText(iterator.Data.Value.UserName,EntTypeNameMask)=0) then
      Include.CountKey(iterator.Data.Value.EntityID,1);
  until not iterator.Next;
  if assigned(iterator) then
    iterator.destroy;
end;

procedure TEntsTypeFilter.SubType(EntType:TObjID);
begin
  Exclude.CountKey(EntType,1);
end;

procedure TEntsTypeFilter.SubTypeName(EntTypeName:GDBString);
var EntInfoData:TEntInfoData;
begin
  if ENTName2EntInfoData.TryGetValue(UpperCase(EntTypeName),EntInfoData) then
    Exclude.CountKey(EntInfoData.EntityID,1);
end;

procedure TEntsTypeFilter.SubTypeNameMask(EntTypeNameMask:GDBString);
var
  iterator:ObjID2EntInfoData.TIterator;
begin
  iterator:=ObjID2EntInfoData.Min;
  if assigned(iterator) then
  repeat
    if MatchesMask(iterator.Data.Value.UserName,EntTypeNameMask,false)
    or (AnsiCompareText(iterator.Data.Value.UserName,EntTypeNameMask)=0) then
      Exclude.CountKey(iterator.Data.Value.EntityID,1);
  until not iterator.Next;
  if assigned(iterator) then
    iterator.destroy;
end;

procedure TEntsTypeFilter.SetFilter;
var
  iterator:TObjID2Counter.TIterator;
  count:SizeUInt;
begin
  iterator:=Include.Min;
  if assigned(iterator) then
  repeat
    if not Exclude.TryGetValue(iterator.GetKey,count) then
      Filter.CountKey(iterator.GetKey,1);
  until not iterator.Next;
  if assigned(iterator) then
    iterator.destroy;
end;

procedure TEntsTypeFilter.ResetFilter;
begin
  FreeAndNil(Filter);
  FreeAndNil(Include);
  FreeAndNil(Exclude);

  Filter:=TObjID2Counter.create;
  Include:=TObjID2Counter.create;
  Exclude:=TObjID2Counter.create;
end;

function TEntsTypeFilter.IsEntytyTypeAccepted(EntType:TObjID):boolean;
var
  count:SizeUInt;
begin
  if Filter.TryGetValue(EntType,count) then
    result:=true
  else
    result:=false;
end;

function TEntsTypeFilter.IsEmpty:boolean;
begin
    result:=Filter.Size=0;
end;

begin
end.
