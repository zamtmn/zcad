unit uscanresult;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, gvector, ghashmap;

type
  TUnitName=String;    //алиас для имени юнита
  TUnitIndex=integer;  //алиас для индекса юнита в массиве

  UnitNameHash=class
    class function hash(s:TUnitName; n:longint):SizeUInt;//процедура ращета хэша для стринга, нужна для устройства хэшмапы
  end;

  TUnitName2IndexMap=specialize THashMap<TUnitName, TUnitIndex, UnitNameHash>;//хэшмапа для перевода имени блока в индекс
  TUsesArray=specialize TVector<TUnitIndex>;//вектор индексов
  TUnitInfo=record //информация о юните, пока тут почти пусто
    UnitName:TUnitName;                         //имя юнита
    InterfaceUses,ImplementationUses:TUsesArray;//массив индексов юнитов которые есть в усес этого юнита
  end;
  TUnitInfoArray=specialize TVector<TUnitInfo>;//вектор элементов типа TUnitInfo

  TScanResult=class
    private
      function CreateEmptyUnitInfo(const un:TUnitName):TUnitInfo;
    public
      UnitInfoArray:TUnitInfoArray;        //массив юнитов
      UnitName2IndexMap:TUnitName2IndexMap;//хэшмап для быстрого перевода имени юнита в индекс в UnitInfoArray
      constructor create;
      destructor destroy;override;

      {попытка создания в массиве записи для юнита un}
      {возвращает false если запись с таким именем уже есть, создавать ненадо}
      {возвращает true если записи с таким именем еще небыло, она создана}
      {возвращает UnitIindex индекс записи в любом случае}
      function TryCreateNewUnitInfo(const un:TUnitName;var UnitIindex:TUnitIndex):boolean;

      {проверка наличия в массиве записи для юнита un}
      {возвращает true если запись с таким именем есть}
      {возвращает false если записи с таким именем нет}
      {возвращает UnitIindex индекс записи если true}
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

