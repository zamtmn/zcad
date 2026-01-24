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

unit uzeentitiestypefilter;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}


interface

uses
  SysUtils,LCLProc,Masks,
  uzeentityfactory,uzeentity,
  uzeBaseExtender,uzeExtdrAbstractEntityExtender,
  uzeTypes,usimplegenerics;

const
  CachedValuesCount=2;

type
  TEntsTypeFilter=class
    protected
      EntFilter,
      EntInclude,
      EntExclude:TObjID2Counter;
      ExtdrFilter,
      ExtdrInclude,
      ExtdrExclude:TMetaExtender2Counter;

      FCachedEntsCount:Integer;
      FCachedExtdrsCount:Integer;

      FCachedEntsArray:array[0..CachedValuesCount-1] of TObjID;
      FCachedExtdrsArray:array[0..CachedValuesCount-1] of TMetaExtender;

      function IsEntytyTypeAccepted(EntType:TObjID):boolean;
      function IsExtdrTypeAccepted(ExtdrType:TMetaExtender):boolean;

    public
      constructor Create;
      destructor Destroy;override;

      procedure AddType(EntType:TObjID);
      procedure AddTypeName(EntTypeName:String);
      procedure AddTypeNames(EntTypeNames:array of String);
      procedure AddTypeNameMask(EntTypeNameMask:String);

      procedure SubType(EntType:TObjID);
      procedure SubTypeName(EntTypeName:String);
      procedure SubTypeNames(EntTypeNames:array of String);
      procedure SubTypeNameMask(EntTypeNameMask:String);

      procedure AddExtdr(ExtdrType:TMetaExtender);
      procedure AddExtdrName(ExtdrTypeName:String);
      procedure AddExtdrNames(ExtdrTypeNames:array of String);
      procedure AddExtdrNameMask(ExtdrTypeNameMask:String);

      procedure SubExtdr(ExtdrType:TMetaExtender);
      procedure SubExtdrName(ExtdrTypeName:String);
      procedure SubExtdrNames(ExtdrTypeNames:array of String);
      procedure SubExtdrNameMask(ExtdrTypeNameMask:String);

      procedure SetFilter;
      procedure ResetFilter;

      function IsEntytyAccepted(pv:pGDBObjEntity):boolean;

      function IsEmpty:boolean;
  end;
implementation
constructor TEntsTypeFilter.Create;
begin
  EntFilter:=TObjID2Counter.create;
  EntInclude:=TObjID2Counter.create;
  EntExclude:=TObjID2Counter.create;

  ExtdrFilter:=TMetaExtender2Counter.create;
  ExtdrInclude:=TMetaExtender2Counter.create;
  ExtdrExclude:=TMetaExtender2Counter.create;

  FCachedEntsCount:=-1;
  FCachedExtdrsCount:=-1;
end;

destructor TEntsTypeFilter.Destroy;
begin
  EntFilter.Destroy;
  EntInclude.Destroy;
  EntExclude.Destroy;

  ExtdrFilter.Destroy;
  ExtdrInclude.Destroy;
  ExtdrExclude.Destroy;
end;

procedure TEntsTypeFilter.AddType(EntType:TObjID);
begin
  EntInclude.CountKey(EntType,1);
end;

procedure TEntsTypeFilter.AddTypeName(EntTypeName:String);
var EntInfoData:TEntInfoData;
begin
  if ENTName2EntInfoData.TryGetValue(UpperCase(EntTypeName),EntInfoData) then
    EntInclude.CountKey(EntInfoData.EntityID,1);
end;
procedure TEntsTypeFilter.AddTypeNames(EntTypeNames:array of String);
var
  EntTypeName:string;
begin
  for EntTypeName in EntTypeNames do
    AddTypeName(EntTypeName);
end;

procedure TEntsTypeFilter.AddTypeNameMask(EntTypeNameMask:String);
var
  pair:ObjID2EntInfoData.TDictionaryPair;
begin
  for pair in ObjID2EntInfoData do begin
    if (MatchesMask(pair.Value.UserName,EntTypeNameMask,false))
    or (AnsiCompareText(pair.Value.UserName,EntTypeNameMask)=0) then
      EntInclude.CountKey(pair.Value.EntityID,1);
  end;
end;

procedure TEntsTypeFilter.SubType(EntType:TObjID);
begin
  EntExclude.CountKey(EntType,1);
end;

procedure TEntsTypeFilter.SubTypeNames(EntTypeNames:array of String);
var
  EntTypeName:string;
begin
  for EntTypeName in EntTypeNames do
    SubTypeName(EntTypeName);
end;

procedure TEntsTypeFilter.SubTypeName(EntTypeName:String);
var EntInfoData:TEntInfoData;
begin
  if ENTName2EntInfoData.TryGetValue(UpperCase(EntTypeName),EntInfoData) then
    EntExclude.CountKey(EntInfoData.EntityID,1);
end;

procedure TEntsTypeFilter.SubTypeNameMask(EntTypeNameMask:String);
var
  pair:ObjID2EntInfoData.TDictionaryPair;
begin
  for pair in ObjID2EntInfoData do begin
    if MatchesMask(pair.Value.UserName,EntTypeNameMask,false)
    or (AnsiCompareText(pair.Value.UserName,EntTypeNameMask)=0) then
      EntExclude.CountKey(pair.Value.EntityID,1);
  end;
end;

procedure TEntsTypeFilter.AddExtdr(ExtdrType:TMetaExtender);
begin
  ExtdrInclude.CountKey(ExtdrType,1);
end;

procedure TEntsTypeFilter.AddExtdrName(ExtdrTypeName:String);
var Extdr:TMetaEntityExtender;
begin
  if EntityExtenders.TryGetValue(UpperCase(ExtdrTypeName),Extdr) then
    ExtdrInclude.CountKey(Extdr,1);
end;

procedure TEntsTypeFilter.AddExtdrNames(ExtdrTypeNames:array of String);
var
  ExtdrTypeName:String;
begin
  for ExtdrTypeName in ExtdrTypeNames do
    AddExtdrName(ExtdrTypeName);
end;

procedure TEntsTypeFilter.AddExtdrNameMask(ExtdrTypeNameMask:String);
var
  pair:EntityExtenders.TDictionaryPair;
  s:string;
begin
  for pair in EntityExtenders do begin
    s:=pair.Key;
    if (MatchesMask(s,ExtdrTypeNameMask,false))
    or (AnsiCompareText(s,ExtdrTypeNameMask)=0) then
      ExtdrInclude.CountKey(pair.Value,1);
  end;
end;

procedure TEntsTypeFilter.SubExtdr(ExtdrType:TMetaExtender);
begin
  ExtdrExclude.CountKey(ExtdrType,1);
end;

procedure TEntsTypeFilter.SubExtdrName(ExtdrTypeName:String);
var Extdr:TMetaEntityExtender;
begin
  if EntityExtenders.TryGetValue(UpperCase(ExtdrTypeName),Extdr) then
    ExtdrExclude.CountKey(Extdr,1);
end;

procedure TEntsTypeFilter.SubExtdrNames(ExtdrTypeNames:array of String);
var
  ExtdrTypeName:String;
begin
  for ExtdrTypeName in ExtdrTypeNames do
    SubExtdrName(ExtdrTypeName);
end;


procedure TEntsTypeFilter.SubExtdrNameMask(ExtdrTypeNameMask:String);
var
  pair:EntityExtenders.TDictionaryPair;
  s:string;
begin
  for pair in EntityExtenders do begin
    s:=pair.Key;
    if (MatchesMask(s,ExtdrTypeNameMask,false))
    or (AnsiCompareText(s,ExtdrTypeNameMask)=0) then
      ExtdrExclude.CountKey(pair.Value,1);
  end;
end;

procedure TEntsTypeFilter.SetFilter;
var
  EntPair:TObjID2Counter.TDictionaryPair;
  ExtdrPair:TMetaExtender2Counter.TDictionaryPair;
  Count,DummyCount:SizeUInt;
begin
  count:=0;
  for EntPair in EntInclude do
    if not EntExclude.TryGetValue(EntPair.Key,DummyCount) then begin
      EntFilter.CountKey(EntPair.Key,1);
      if count<High(FCachedEntsArray) then
        FCachedEntsArray[count]:=EntPair.Key;
      inc(count);
    end;
  count:=0;
  for ExtdrPair in ExtdrInclude do
    if not  ExtdrExclude.TryGetValue(ExtdrPair.Key,DummyCount) then begin
      ExtdrFilter.CountKey(ExtdrPair.Key,1);
      if count<High(FCachedExtdrsArray) then
        FCachedExtdrsArray[count]:=ExtdrPair.Key;
      inc(count);
    end;
  if EntFilter.Count<=CachedValuesCount then
    FCachedEntsCount:=EntFilter.Count-1
  else
    FCachedEntsCount:=-1;
  if ExtdrFilter.Count<=CachedValuesCount then
    FCachedExtdrsCount:=ExtdrFilter.Count-1
  else
    FCachedExtdrsCount:=-1;
end;

procedure TEntsTypeFilter.ResetFilter;
begin
  EntFilter.Destroy;
  EntInclude.Destroy;
  EntExclude.Destroy;

  ExtdrFilter.Destroy;
  ExtdrInclude.Destroy;
  ExtdrExclude.Destroy;

  EntFilter:=TObjID2Counter.create;
  EntInclude:=TObjID2Counter.create;
  EntExclude:=TObjID2Counter.create;

  ExtdrFilter:=TMetaExtender2Counter.create;
  ExtdrInclude:=TMetaExtender2Counter.create;
  ExtdrExclude:=TMetaExtender2Counter.create;
end;

function TEntsTypeFilter.IsEntytyTypeAccepted(EntType:TObjID):boolean;
var
  DummyCount:SizeUInt;
begin
  if FCachedEntsCount>=0 then
    for DummyCount:=0 to FCachedEntsCount do
      if FCachedEntsArray[DummyCount]=EntType then
        exit(true);
  result:=EntFilter.TryGetValue(EntType,DummyCount)
end;
function TEntsTypeFilter.IsExtdrTypeAccepted(ExtdrType:TMetaExtender):boolean;
var
  DummyCount:SizeUInt;
begin
  if FCachedExtdrsCount>=0 then
    for DummyCount:=0 to FCachedExtdrsCount do
      if FCachedExtdrsArray[DummyCount]=ExtdrType then
        exit(true);
  result:=ExtdrFilter.TryGetValue(ExtdrType,DummyCount);
end;
function TEntsTypeFilter.IsEntytyAccepted(pv:pGDBObjEntity):boolean;
var
  i:integer;
begin
  result:=IsEntytyTypeAccepted(pv.GetObjType);
  if result and (ExtdrFilter.Count>0) then begin
    for i:=0 to pv^.GetExtensionsCount-1 do
      if IsExtdrTypeAccepted(typeof(pv^.GetExtension(i)))then
        exit(true);
    exit(false);
  end;
end;

function TEntsTypeFilter.IsEmpty:boolean;
begin
  result:=(EntFilter.Count=0)and(ExtdrFilter.Count=0);
end;

begin
end.
