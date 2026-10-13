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
  Модуль: uzeffdxfnodpreserved
  Назначение: хранилище «чужих» веток NOD (этап 7 ТЗ
  cad_source/zengine/TZ_NOD_NamedObjectDictionary.md).

  Ветка — объект по ключу NOD, у которого нет обработчика в реестре
  uzeffdxfnodregistry и который не пишется из шаблона (ACAD_GROUP,
  ACAD_LAYOUT...), вместе со всеми объектами, которыми он владеет
  (записи словарей, расширенные словари, объекты с владельцем 330 из
  ветки). Объекты хранятся копиями TZDXFRawObject в порядке файла, строки
  значений — в UTF-8 (DXF до 2007 перекодируется при загрузке).

  Заполняется при загрузке DXF 2000+ (RunNODPreserveUnknownBranches),
  пишется при сохранении TZNODSaveSession после веток обработчиков с
  перемаппингом всех хэндлов. Модуль не зависит от реестра и чертежа —
  его использует TSimpleDrawing (поле PreservedNODBranches).
}
unit uzeffdxfnodpreserved;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,
  Generics.Collections,
  uzeTypes,
  uzeffdxfobjects;

type
  { Одна сохранённая ветка NOD }
  TZNODPreservedBranch = record
    { Ключ записи NOD ('MY_PLUGIN') }
    Key: string;
    { Исходный хэндл корневого объекта ветки (цель записи NOD) }
    RootHandle: TDWGHandle;
    { Код ссылки записи NOD: 350 (soft owner) или 360 (hard owner) }
    OwnershipCode: Integer;
    { Исходный хэндл NOD файла, из которого загружена ветка }
    SourceNODHandle: TDWGHandle;
  end;

  { Ссылка объекта ветки на объект ветки NOD-обработчика (стиль таблиц и
    т. п.): при записи разрешается по имени через FindObjectHandleProc. }
  TZNODPreservedRef = record
    { Исходный хэндл объекта, на который ссылаются }
    Handle: TDWGHandle;
    { Ключ NOD обработчика ('ACAD_TABLESTYLE') }
    HandlerKey: string;
    { Ключ объекта в словаре ветки обработчика; '' — ссылка на сам словарь }
    Name: string;
  end;

  TZNODPreservedBranches = class
  private
    FBranches: array of TZNODPreservedBranch;
    { Объекты всех веток в порядке файла (владеет) }
    FObjects: TZDXFRawObjectList;
    { Индекс ветки каждого объекта (параллельно FObjects) }
    FObjectBranch: array of Integer;
    { Исходный хэндл объекта → индекс в FObjects }
    FHandleIndex: TDictionary<TDWGHandle, Integer>;
    { Определения классов (записи CLASS секции CLASSES) типов объектов
      веток (владеет) }
    FClasses: TZDXFRawObjectList;
    FRefs: array of TZNODPreservedRef;
    function GetBranch(AIndex: Integer): TZNODPreservedBranch;
    function GetBranchCount: Integer;
    function GetObject(AIndex: Integer): TZDXFRawObject;
    function GetObjectCount: Integer;
    function GetObjectBranch(AIndex: Integer): Integer;
    function GetClass(AIndex: Integer): TZDXFRawObject;
    function GetClassCount: Integer;
    function GetRef(AIndex: Integer): TZNODPreservedRef;
    function GetRefCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    { Индекс ветки с ключом AKey (без учёта регистра), -1 — нет }
    function IndexOfKey(const AKey: string): Integer;
    { Добавляет ветку, возвращает её индекс }
    function AddBranch(const AKey: string; ARootHandle: TDWGHandle;
      AOwnershipCode: Integer; ASourceNODHandle: TDWGHandle): Integer;
    { Добавляет копию объекта в ветку ABranch. Значения пар копируются как
      есть: перекодировку делает вызывающий. }
    function AddObjectCopy(ABranch: Integer; ASource: TZDXFRawObject): TZDXFRawObject;
    { Есть ли объект с исходным хэндлом AHandle }
    function ContainsHandle(AHandle: TDWGHandle): Boolean;
    { Индекс объекта с исходным хэндлом AHandle, -1 — нет }
    function IndexOfHandle(AHandle: TDWGHandle): Integer;
    { Добавляет копию записи CLASS (если класса с таким именем ещё нет) }
    procedure AddClassCopy(ASource: TZDXFRawObject);
    { Запись CLASS по имени класса (группа 1, без учёта регистра); nil — нет }
    function FindClass(const AName: string): TZDXFRawObject;
    { Запоминает ссылку на объект ветки обработчика (повтор хэндла
      игнорируется) }
    procedure AddRef(AHandle: TDWGHandle; const AHandlerKey, AName: string);
    function FindRef(AHandle: TDWGHandle; out ARef: TZNODPreservedRef): Boolean;

    property BranchCount: Integer read GetBranchCount;
    property Branches[AIndex: Integer]: TZNODPreservedBranch read GetBranch;
    property ObjectCount: Integer read GetObjectCount;
    property Objects[AIndex: Integer]: TZDXFRawObject read GetObject;
    { Индекс ветки объекта AIndex }
    property ObjectBranch[AIndex: Integer]: Integer read GetObjectBranch;
    property ClassCount: Integer read GetClassCount;
    property Classes[AIndex: Integer]: TZDXFRawObject read GetClass;
    property RefCount: Integer read GetRefCount;
    property Refs[AIndex: Integer]: TZNODPreservedRef read GetRef;
  end;

implementation

{ TZNODPreservedBranches }

constructor TZNODPreservedBranches.Create;
begin
  inherited Create;
  FObjects := TZDXFRawObjectList.Create(True);
  FClasses := TZDXFRawObjectList.Create(True);
  FHandleIndex := TDictionary<TDWGHandle, Integer>.Create;
end;

destructor TZNODPreservedBranches.Destroy;
begin
  FHandleIndex.Free;
  FClasses.Free;
  FObjects.Free;
  inherited Destroy;
end;

procedure TZNODPreservedBranches.Clear;
begin
  SetLength(FBranches, 0);
  SetLength(FObjectBranch, 0);
  SetLength(FRefs, 0);
  FObjects.Clear;
  FClasses.Clear;
  FHandleIndex.Clear;
end;

function TZNODPreservedBranches.GetBranch(AIndex: Integer): TZNODPreservedBranch;
begin
  Result := FBranches[AIndex];
end;

function TZNODPreservedBranches.GetBranchCount: Integer;
begin
  Result := Length(FBranches);
end;

function TZNODPreservedBranches.GetObject(AIndex: Integer): TZDXFRawObject;
begin
  Result := FObjects[AIndex];
end;

function TZNODPreservedBranches.GetObjectCount: Integer;
begin
  Result := FObjects.Count;
end;

function TZNODPreservedBranches.GetObjectBranch(AIndex: Integer): Integer;
begin
  Result := FObjectBranch[AIndex];
end;

function TZNODPreservedBranches.GetClass(AIndex: Integer): TZDXFRawObject;
begin
  Result := FClasses[AIndex];
end;

function TZNODPreservedBranches.GetClassCount: Integer;
begin
  Result := FClasses.Count;
end;

function TZNODPreservedBranches.GetRef(AIndex: Integer): TZNODPreservedRef;
begin
  Result := FRefs[AIndex];
end;

function TZNODPreservedBranches.GetRefCount: Integer;
begin
  Result := Length(FRefs);
end;

function TZNODPreservedBranches.IndexOfKey(const AKey: string): Integer;
var
  I: Integer;
begin
  for I := 0 to High(FBranches) do
    if SameText(FBranches[I].Key, AKey) then
      Exit(I);
  Result := -1;
end;

function TZNODPreservedBranches.AddBranch(const AKey: string;
  ARootHandle: TDWGHandle; AOwnershipCode: Integer;
  ASourceNODHandle: TDWGHandle): Integer;
begin
  Result := Length(FBranches);
  SetLength(FBranches, Result + 1);
  FBranches[Result].Key := AKey;
  FBranches[Result].RootHandle := ARootHandle;
  FBranches[Result].OwnershipCode := AOwnershipCode;
  FBranches[Result].SourceNODHandle := ASourceNODHandle;
end;

function CopyRawObject(ASource: TZDXFRawObject): TZDXFRawObject;
begin
  Result := TZDXFRawObject.Create;
  Result.ObjType := ASource.ObjType;
  Result.Handle := ASource.Handle;
  Result.OwnerHandle := ASource.OwnerHandle;
  Result.HasOwnerGroup := ASource.HasOwnerGroup;
  Result.Reactors := Copy(ASource.Reactors);
  Result.XDictHandle := ASource.XDictHandle;
  Result.Pairs := Copy(ASource.Pairs, 0, ASource.PairCount);
  Result.PairCount := ASource.PairCount;
  Result.LineNumber := ASource.LineNumber;
end;

function TZNODPreservedBranches.AddObjectCopy(ABranch: Integer;
  ASource: TZDXFRawObject): TZDXFRawObject;
var
  I: Integer;
begin
  Result := CopyRawObject(ASource);
  I := FObjects.Add(Result);
  SetLength(FObjectBranch, I + 1);
  FObjectBranch[I] := ABranch;
  FHandleIndex.AddOrSetValue(Result.Handle, I);
end;

function TZNODPreservedBranches.ContainsHandle(AHandle: TDWGHandle): Boolean;
begin
  Result := FHandleIndex.ContainsKey(AHandle);
end;

function TZNODPreservedBranches.IndexOfHandle(AHandle: TDWGHandle): Integer;
begin
  if not FHandleIndex.TryGetValue(AHandle, Result) then
    Result := -1;
end;

procedure TZNODPreservedBranches.AddClassCopy(ASource: TZDXFRawObject);
begin
  if FindClass(ASource.ValueOf(1)) = nil then
    FClasses.Add(CopyRawObject(ASource));
end;

function TZNODPreservedBranches.FindClass(const AName: string): TZDXFRawObject;
var
  C: TZDXFRawObject;
begin
  for C in FClasses do
    if SameText(C.ValueOf(1), AName) then
      Exit(C);
  Result := nil;
end;

procedure TZNODPreservedBranches.AddRef(AHandle: TDWGHandle;
  const AHandlerKey, AName: string);
var
  R: TZNODPreservedRef;
  I: Integer;
begin
  if FindRef(AHandle, R) then
    Exit;
  I := Length(FRefs);
  SetLength(FRefs, I + 1);
  FRefs[I].Handle := AHandle;
  FRefs[I].HandlerKey := AHandlerKey;
  FRefs[I].Name := AName;
end;

function TZNODPreservedBranches.FindRef(AHandle: TDWGHandle;
  out ARef: TZNODPreservedRef): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(FRefs) do
    if FRefs[I].Handle = AHandle then begin
      ARef := FRefs[I];
      Exit(True);
    end;
  ARef := Default(TZNODPreservedRef);
  Result := False;
end;

end.
