unit uscanresult;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, gvector, ghashmap, PasTree, PParser;

type
  TUnitName=String;    //алиас для имени юнита
  TUnitIndex=integer;  //алиас для индекса юнита в массиве

  UnitNameHash=class
    class function hash(s:TUnitName; n:longint):SizeUInt;//процедура ращета хэша для стринга, нужна для устройства хэшмапы
  end;
  {$IF FPC_FULLVERSION>=030001}
  TUnitName2IndexMap=specialize THashMap<TUnitName, TUnitIndex, UnitNameHash>;//хэшмапа для перевода имени блока в индекс
  {$ELSE}
  TUnitName2IndexMap=class (specialize THashMap<TUnitName, TUnitIndex, UnitNameHash>)
                       function GetValue(key:TUnitName;out value:TUnitIndex):boolean;inline;
                     end;
  {$ENDIF}
  TUnitFlag=(UFLoop);
  TUnitFlags=set of TUnitFlag;
  TNodeState=(NSNotCheced,NSCheced,NSFiltredOut);
  TUnitType=(UTProgram,UTUnit);
  TUsesArray=specialize TVector<TUnitIndex>;//вектор индексов
  TUnitInfo=object //информация о юните, пока тут почти пусто
    NodeState:TNodeState;                       //Метка "уже обработан" при записи в граф. для записи одноразовой информации
    UnitName:TUnitName;                         //имя юнита
    UnitPath:string;                            //путь к юниту;
    UnitType:TUnitType;                         //тип юнита
    UnitFlags:TUnitFlags;
    InterfaceUses,ImplementationUses:TUsesArray;//массив индексов юнитов которые есть в усес этого юнита

    PasModule:TPasModule;
    PasTreeContainer:TPasTreeContainer;

    constructor init(const un:TUnitName);
    destructor done;
  end;
  TUnitInfoArray=class (specialize TVector<TUnitInfo>)//вектор элементов типа TUnitInfo
    destructor destroy;override;
  end;

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
destructor TUnitInfoArray.destroy;
var
  i:integer;
begin
  for i:=0 to size-1 do
   Mutable[i]^.done;
end;
constructor TUnitInfo.init(const un:TUnitName);
begin
  UnitName:=un;
  InterfaceUses:=TUsesArray.Create;
  ImplementationUses:=TUsesArray.Create;
  UnitFlags:=[];
  PasModule:=nil;
  PasTreeContainer:=nil;
end;
destructor TUnitInfo.done;
begin
  if assigned(PasModule) then PasModule.Free;
  if assigned(PasTreeContainer) then PasTreeContainer.Free;
end;

{$IF FPC_FULLVERSION<030001}
function TUnitName2IndexMap.GetValue(key:TUnitName;out value:TUnitIndex): boolean;
var i,bs:SizeUInt;
    curbucket:TContainer;
begin
  curbucket:=FData[THash.hash(key,FData.size)];
  bs:=curbucket.size;
  i:=0;
  while i < bs do begin
{$ifdef STL_INTERFACE_EXT}
    if THash.equal(curbucket[i].Key, key) then begin
{$else}
    if (curbucket[i].Key = key) then begin
{$endif}
      value:=curbucket[i].Value;
      exit(true);
    end;
    inc(i);
  end;
  exit(false);
end;
{$ENDIF}
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
  result.init(un);
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

