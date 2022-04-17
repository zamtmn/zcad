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
{$INCLUDE zengineconfig.inc}


interface
uses LCLProc,uzeentityfactory,
     sysutils,uzbtypes,
     usimplegenerics,Masks;
type
  TEntsTypeFilter=class
    Filter,
    Include,
    Exclude: TObjID2Counter;
    constructor Create;
    destructor Destroy;override;
    procedure AddType(EntType:TObjID);
    procedure AddTypeName(EntTypeName:String);
    procedure AddTypeNameMask(EntTypeNameMask:String);
    procedure SubType(EntType:TObjID);
    procedure SubTypeName(EntTypeName:String);
    procedure SubTypeNameMask(EntTypeNameMask:String);
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

procedure TEntsTypeFilter.AddTypeName(EntTypeName:String);
var EntInfoData:TEntInfoData;
begin
  if ENTName2EntInfoData.TryGetValue(UpperCase(EntTypeName),EntInfoData) then
    Include.CountKey(EntInfoData.EntityID,1);
end;

procedure TEntsTypeFilter.AddTypeNameMask(EntTypeNameMask:String);
var
  //iterator:ObjID2EntInfoData.TIterator;
  pair:ObjID2EntInfoData.TDictionaryPair;
  s:string;
begin
  for pair in ObjID2EntInfoData do begin
  //iterator:=ObjID2EntInfoData.Min;
  //if assigned(iterator) then
  //repeat
    s:=pair.Value.DXFName;
    s:=pair.Value.UserName;
    if (MatchesMask(pair.Value.UserName,EntTypeNameMask,false))
    or (AnsiCompareText(pair.Value.UserName,EntTypeNameMask)=0) then
      Include.CountKey(pair.Value.EntityID,1);
  end;
  //until not iterator.Next;
  //if assigned(iterator) then
  //  iterator.destroy;
end;

procedure TEntsTypeFilter.SubType(EntType:TObjID);
begin
  Exclude.CountKey(EntType,1);
end;

procedure TEntsTypeFilter.SubTypeName(EntTypeName:String);
var EntInfoData:TEntInfoData;
begin
  if ENTName2EntInfoData.TryGetValue(UpperCase(EntTypeName),EntInfoData) then
    Exclude.CountKey(EntInfoData.EntityID,1);
end;

procedure TEntsTypeFilter.SubTypeNameMask(EntTypeNameMask:String);
var
  //iterator:ObjID2EntInfoData.TIterator;
  pair:ObjID2EntInfoData.TDictionaryPair;
begin
  for pair in ObjID2EntInfoData do begin
  //iterator:=ObjID2EntInfoData.Min;
  //if assigned(iterator) then
  //repeat
    if MatchesMask(pair.Value.UserName,EntTypeNameMask,false)
    or (AnsiCompareText(pair.Value.UserName,EntTypeNameMask)=0) then
      Exclude.CountKey(pair.Value.EntityID,1);
  end;
  //until not iterator.Next;
  //if assigned(iterator) then
  //  iterator.destroy;
end;

procedure TEntsTypeFilter.SetFilter;
var
  //iterator:TObjID2Counter.TIterator;
  pair:TObjID2Counter.TDictionaryPair;
  count:SizeUInt;
begin
  for pair in Include do
  //iterator:=Include.Min;
  //if assigned(iterator) then
  //repeat
    if not Exclude.TryGetValue(pair.Key,count) then
      Filter.CountKey(pair.Key,1);
  //until not iterator.Next;
  //if assigned(iterator) then
  //  iterator.destroy;
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
    result:=Filter.{Size}Count=0;
end;

begin
end.
