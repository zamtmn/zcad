unit uscanresult;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, gvector, ghashmap;

type
  TUnitName=String;
  TUnitIndex=integer;

  UnitNameHash=class
    class function hash(s:TUnitName; n:longint):SizeUInt;
  end;

  TUnitName2IndexMap=specialize THashMap<TUnitName, TUnitIndex, UnitNameHash>;
  TUsesArray=specialize TVector<TUnitIndex>;
  TUnitInfo=record
    UnitName:TUnitName;
    InterfaceUses,ImplementationUses:TUsesArray;
  end;
  TUnitInfoArray=specialize TVector<TUnitInfo>;

  TScanResult=class
    private
      function CreateEmptyUnitInfo(const un:TUnitName):TUnitInfo;
    public
      UnitInfoArray:TUnitInfoArray;
      UnitName2IndexMap:TUnitName2IndexMap;
      constructor create;
      destructor destroy;override;

      function TryCreateNewUnitInfo(const un:TUnitName;var UnitIindex:TUnitIndex):boolean;
      function isUnitInfoPresent(const un:TUnitName;var UnitIindex:TUnitIndex):boolean;
  end;

implementation
function MakeHash(const s: String):SizeUInt;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(s) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(s[I]);
end;
class function UnitNameHash.hash(s:TUnitName; n:longint):SizeUInt;
begin
     result:=makehash(s) mod SizeUInt(n);
end;
constructor TScanResult.create;
begin
  UnitName2IndexMap:=TUnitName2IndexMap.create;
  UnitInfoArray:=TUnitInfoArray.Create;
end;
destructor TScanResult.destroy;
var
  i:integer;
begin
  UnitName2IndexMap.destroy;
  for i:=0 to UnitInfoArray.Size-1 do
  begin
    UnitInfoArray.Mutable[i]^.ImplementationUses.Destroy;
    UnitInfoArray.Mutable[i]^.InterfaceUses.Destroy;
  end;
  UnitInfoArray.destroy;
end;
function TScanResult.CreateEmptyUnitInfo(const un:TUnitName):TUnitInfo;
begin
  result.UnitName:=un;
  result.InterfaceUses:=TUsesArray.Create;
  result.ImplementationUses:=TUsesArray.Create;
end;

function TScanResult.TryCreateNewUnitInfo(const un:TUnitName;var UnitIindex:TUnitIndex):boolean;
var
  lcun:TUnitName;
begin
  lcun:=lowercase(un);
  if UnitName2IndexMap.GetValue(lcun,UnitIindex)then
                                            begin
                                              exit(false);
                                            end;
  UnitIindex:=UnitInfoArray.Size;
  UnitInfoArray.PushBack(CreateEmptyUnitInfo(un));
  UnitName2IndexMap.insert(lcun,UnitIindex);
  result:=true;
end;
function TScanResult.isUnitInfoPresent(const un:TUnitName;var UnitIindex:TUnitIndex):boolean;
var
  lcun:TUnitName;
begin
  lcun:=lowercase(un);
  if UnitName2IndexMap.GetValue(lcun,UnitIindex)then
                                            result:=true
                                        else
                                            result:=false;
end;
end.

