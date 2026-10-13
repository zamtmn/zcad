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
  Модуль: uzeffdxfnod
  Назначение: модель Named Object Dictionary (NOD) поверх объектов секции
  OBJECTS (этап 1 ТЗ cad_source/zengine/TZ_NOD_NamedObjectDictionary.md).

  * TZDXFDictionary — представление объекта DICTIONARY (и
    ACDBDICTIONARYWDFLT): флаги 280/281, упорядоченный список записей
    «ключ → хэндл + код 350/360»;
  * TZNODModel — все сырые объекты секции с индексом по хэндлу, все
    словари, корневой словарь NOD (DICTIONARY с 330=0), навигация по пути
    от NOD, множество «забранных» обработчиками хэндлов;
  * индекс символьных таблиц (этап 6): хэндл записи секции TABLES (LTYPE,
    STYLE, BLOCK_RECORD...) → тип таблицы и имя записи. Строится по
    требованию (LoadSymbolTablesFromText) — объекты веток ссылаются на
    записи таблиц по хэндлам, а чертёж хранит ссылки по именам;
  * построение модели из объектов, собранных вызывающим (этап 9, DWG):
    AddObject / AddSymbolRecord, затем EndBuild с хэндлом NOD из заголовка.

  Модель только читает данные и не имеет побочных эффектов: на этапе 1 она
  не подключена к загрузке чертежа.
}
unit uzeffdxfnod;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,
  Generics.Collections,
  uzeTypes,
  uzeffdxfobjects;

const
  { Тип объекта словаря }
  CDXFDictionaryObjType = 'DICTIONARY';
  { Словарь со значением по умолчанию (например, ACAD_PLOTSTYLENAME) }
  CDXFDictionaryWithDefaultObjType = 'ACDBDICTIONARYWDFLT';
  { Разделитель ключей в пути от NOD: 'ACAD_TABLESTYLE/Standard' }
  CNODPathDelimiter = '/';

type
  { Запись словаря: 3/<Key>, затем 350 или 360/<TargetHandle> }
  TZDXFDictEntry = record
    Key: string;
    TargetHandle: TDWGHandle;
    { 350 — soft-owner, 360 — hard-owner; сохраняется при записи }
    OwnershipCode: Integer;
  end;
  TZDXFDictEntries = array of TZDXFDictEntry;

  { Словарь (DICTIONARY или ACDBDICTIONARYWDFLT) поверх сырого объекта. }
  TZDXFDictionary = class
  private
    FRawObject: TZDXFRawObject;
    FEntries: TZDXFDictEntries;
    FEntryCount: Integer;
    function GetEntry(AIndex: Integer): TZDXFDictEntry;
    function GetHandle: TDWGHandle;
    function GetOwnerHandle: TDWGHandle;
    procedure AddEntry(const AKey: string; ATarget: TDWGHandle; ACode: Integer);
  public
    { Группа 280: 1 — словарь жёстко владеет записями (0, если группы нет) }
    HardOwner: Integer;
    { Группа 281: режим клонирования дублирующихся записей (0, если группы нет) }
    CloningFlag: Integer;
    { Группа 340 у ACDBDICTIONARYWDFLT: запись по умолчанию (0 — нет) }
    DefaultHandle: TDWGHandle;

    { Строит словарь по сырому объекту (объект не копируется и не
      освобождается — им владеет TZNODModel) }
    constructor Create(ARawObject: TZDXFRawObject);
    { Индекс записи по ключу (без учёта регистра, как в AutoCAD), -1 — нет }
    function IndexOfKey(const AKey: string): Integer;
    function FindEntry(const AKey: string; out AEntry: TZDXFDictEntry): Boolean;

    property RawObject: TZDXFRawObject read FRawObject;
    property Handle: TDWGHandle read GetHandle;
    property OwnerHandle: TDWGHandle read GetOwnerHandle;
    property Count: Integer read FEntryCount;
    property Entries[AIndex: Integer]: TZDXFDictEntry read GetEntry; default;
  end;

  TZDXFDictionaryList = TObjectList<TZDXFDictionary>;

  { Запись символьной таблицы секции TABLES }
  TZDXFSymbolRecord = record
    { Тип записи (значение группы 0): LTYPE, STYLE, BLOCK_RECORD... }
    TableType: string;
    { Имя записи (группа 2) }
    Name: string;
  end;

  { Результат разбора секции OBJECTS. }
  TZNODModel = class
  private
    FObjects: TZDXFRawObjectList;
    FObjectByHandle: TDictionary<TDWGHandle, TZDXFRawObject>;
    FDictionaries: TZDXFDictionaryList;
    FDictionaryByHandle: TDictionary<TDWGHandle, TZDXFDictionary>;
    FClaimedHandles: TDictionary<TDWGHandle, Boolean>;
    FNOD: TZDXFDictionary;
    FRootDictionaryCount: Integer;
    FDuplicateHandleCount: Integer;
    FParseError: string;
    FSymbols: TDictionary<TDWGHandle, TZDXFSymbolRecord>;
    procedure BuildIndex;
    procedure FindNOD(APreferred: TZDXFDictionary = nil);
    procedure TraceNODKeys;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    { Разбирает текст секции OBJECTS (см. ParseDxfObjectsSection) и строит
      модель. False — структура секции нарушена (описание в ParseError);
      модель при этом строится по объектам, разобранным до ошибки. }
    function LoadFromText(const AObjectsSection: string): Boolean;

    { Этап 9 (DWG): модель строится из объектов, собранных вызывающим.
      Порядок: Clear; AddObject/AddSymbolRecord; EndBuild. }
    { Добавляет сырой объект (владение переходит модели). Индекс по
      хэндлу и словари строятся в EndBuild. }
    procedure AddObject(AObject: TZDXFRawObject);
    { Добавляет запись символьной таблицы в индекс (см. FindSymbolName).
      Повторный хэндл — остаётся первая запись. }
    procedure AddSymbolRecord(AHandle: TDWGHandle; const ATableType, AName: string);
    { Завершает построение: индекс по хэндлу, словари, NOD. ANODHandle <> 0 —
      хэндл корневого словаря из заголовка (DWG: NAMED OBJECTS DICTIONARY);
      если такого словаря нет — предупреждение и поиск NOD по 330=0, как
      в LoadFromText. }
    procedure EndBuild(ANODHandle: TDWGHandle = 0);

    { Объект по хэндлу, nil — нет }
    function FindObject(AHandle: TDWGHandle): TZDXFRawObject;
    { Словарь по хэндлу, nil — объекта нет или это не словарь }
    function FindDictionary(AHandle: TDWGHandle): TZDXFDictionary;
    { Объект по пути ключей от NOD ('ACAD_TABLESTYLE/Standard').
      Пустой путь — сам NOD. nil — NOD нет, ключ не найден, промежуточный
      объект не словарь или ссылка битая. }
    function ResolvePath(const APath: string): TZDXFRawObject;
    { Словарь по пути ключей от NOD, nil — см. ResolvePath }
    function ResolveDictionary(const APath: string): TZDXFDictionary;

    { Помечает хэндл как «забранный» обработчиком NOD }
    procedure ClaimHandle(AHandle: TDWGHandle);
    function IsHandleClaimed(AHandle: TDWGHandle): Boolean;
    function ClaimedHandleCount: Integer;

    { Строит индекс символьных таблиц по тексту секции TABLES (формат —
      как у LoadFromText; прежний индекс очищается, объекты OBJECTS не
      меняются). ACodePage <> 0 — кодовая страница имён (DXF до 2007,
      $DWGCODEPAGE), имена перекодируются в UTF-8; 0 — имена уже в UTF-8.
      Хэндл записи — группа 5 (у DIMSTYLE — 105). False — структура
      секции нарушена, индекс строится по разобранным записям. }
    function LoadSymbolTablesFromText(const ATablesSection: string;
      ACodePage: TSystemCodePage = 0): Boolean;
    { Имя записи символьной таблицы по хэндлу. ATableType <> '' — запись
      должна быть этого типа (без учёта регистра). False — нет (AName = ''). }
    function FindSymbolName(AHandle: TDWGHandle; const ATableType: string;
      out AName: string): Boolean;
    { Количество записей в индексе символьных таблиц }
    function SymbolRecordCount: Integer;

    property Objects: TZDXFRawObjectList read FObjects;
    property Dictionaries: TZDXFDictionaryList read FDictionaries;
    { Корневой словарь; nil — NOD нет (R12, пустая или битая секция) }
    property NOD: TZDXFDictionary read FNOD;
    { Количество DICTIONARY с 330=0 (больше 1 — файл подозрительный) }
    property RootDictionaryCount: Integer read FRootDictionaryCount;
    { Количество объектов с повторяющимся хэндлом (в индекс попадает первый) }
    property DuplicateHandleCount: Integer read FDuplicateHandleCount;
    property ParseError: string read FParseError;
  end;

{ Является ли объект словарём (DICTIONARY или ACDBDICTIONARYWDFLT) }
function IsDXFDictionaryObjType(const AObjType: string): Boolean;

implementation

uses
  Classes,
  uzeffdxfnodlog;

function IsDXFDictionaryObjType(const AObjType: string): Boolean;
begin
  Result := SameText(AObjType, CDXFDictionaryObjType) or
            SameText(AObjType, CDXFDictionaryWithDefaultObjType);
end;

{ TZDXFDictionary }

constructor TZDXFDictionary.Create(ARawObject: TZDXFRawObject);
var
  I, Code, IntVal: Integer;
  Value, PendingKey: string;
  HasPendingKey, InBlock: Boolean;
  H: TDWGHandle;
begin
  inherited Create;
  FRawObject := ARawObject;
  HardOwner := 0;
  CloningFlag := 0;
  DefaultHandle := 0;
  PendingKey := '';
  HasPendingKey := False;
  InBlock := False;
  for I := 0 to ARawObject.PairCount - 1 do begin
    Code := ARawObject.Pairs[I].Code;
    Value := ARawObject.Pairs[I].Value;
    { Блоки 102 (реакторы, xdictionary с его 360) — не записи словаря }
    if Code = 102 then begin
      Value := Trim(Value);
      if (Value <> '') and (Value[1] = '{') then
        InBlock := True
      else if Value = '}' then
        InBlock := False;
      Continue;
    end;
    if InBlock then
      Continue;
    case Code of
      3: begin
        if HasPendingKey then
          NODLogTraceFormatStr(
            'uzeffdxfnod: dictionary %s: key "%s" has no 350/360 handle, skipped',
            [ARawObject.HandleStr, PendingKey]);
        PendingKey := Value;
        HasPendingKey := True;
      end;
      350, 360:
        if HasPendingKey then begin
          if not TryDXFStrToHandle(Value, H) then
            NODLogTraceFormatStr(
              'uzeffdxfnod: dictionary %s: key "%s" has invalid handle "%s"',
              [ARawObject.HandleStr, PendingKey, Trim(Value)]);
          AddEntry(PendingKey, H, Code);
          HasPendingKey := False;
        end;
      280:
        if TryStrToInt(Trim(Value), IntVal) then
          HardOwner := IntVal;
      281:
        if TryStrToInt(Trim(Value), IntVal) then
          CloningFlag := IntVal;
      340:
        if SameText(ARawObject.ObjType, CDXFDictionaryWithDefaultObjType) then
          TryDXFStrToHandle(Value, DefaultHandle);
    end;
  end;
  if HasPendingKey then
    NODLogTraceFormatStr(
      'uzeffdxfnod: dictionary %s: key "%s" has no 350/360 handle, skipped',
      [ARawObject.HandleStr, PendingKey]);
end;

procedure TZDXFDictionary.AddEntry(const AKey: string; ATarget: TDWGHandle;
  ACode: Integer);
begin
  if FEntryCount >= Length(FEntries) then
    if Length(FEntries) < 4 then
      SetLength(FEntries, 4)
    else
      SetLength(FEntries, Length(FEntries) * 2);
  FEntries[FEntryCount].Key := AKey;
  FEntries[FEntryCount].TargetHandle := ATarget;
  FEntries[FEntryCount].OwnershipCode := ACode;
  Inc(FEntryCount);
end;

function TZDXFDictionary.GetEntry(AIndex: Integer): TZDXFDictEntry;
begin
  if (AIndex < 0) or (AIndex >= FEntryCount) then
    raise EListError.CreateFmt('TZDXFDictionary: entry index %d out of bounds (%d)',
      [AIndex, FEntryCount]);
  Result := FEntries[AIndex];
end;

function TZDXFDictionary.GetHandle: TDWGHandle;
begin
  Result := FRawObject.Handle;
end;

function TZDXFDictionary.GetOwnerHandle: TDWGHandle;
begin
  Result := FRawObject.OwnerHandle;
end;

function TZDXFDictionary.IndexOfKey(const AKey: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FEntryCount - 1 do
    if SameText(FEntries[I].Key, AKey) then
      Exit(I);
  Result := -1;
end;

function TZDXFDictionary.FindEntry(const AKey: string;
  out AEntry: TZDXFDictEntry): Boolean;
var
  I: Integer;
begin
  I := IndexOfKey(AKey);
  Result := I >= 0;
  if Result then
    AEntry := FEntries[I]
  else begin
    AEntry.Key := '';
    AEntry.TargetHandle := 0;
    AEntry.OwnershipCode := 0;
  end;
end;

{ TZNODModel }

constructor TZNODModel.Create;
begin
  inherited Create;
  FObjects := TZDXFRawObjectList.Create(True);
  FObjectByHandle := TDictionary<TDWGHandle, TZDXFRawObject>.Create;
  FDictionaries := TZDXFDictionaryList.Create(True);
  FDictionaryByHandle := TDictionary<TDWGHandle, TZDXFDictionary>.Create;
  FClaimedHandles := TDictionary<TDWGHandle, Boolean>.Create;
  FSymbols := TDictionary<TDWGHandle, TZDXFSymbolRecord>.Create;
end;

destructor TZNODModel.Destroy;
begin
  FSymbols.Free;
  FClaimedHandles.Free;
  FDictionaryByHandle.Free;
  FDictionaries.Free;
  FObjectByHandle.Free;
  FObjects.Free;
  inherited Destroy;
end;

procedure TZNODModel.Clear;
begin
  FNOD := nil;
  FRootDictionaryCount := 0;
  FDuplicateHandleCount := 0;
  FParseError := '';
  FSymbols.Clear;
  FClaimedHandles.Clear;
  FDictionaryByHandle.Clear;
  FDictionaries.Clear;
  FObjectByHandle.Clear;
  FObjects.Clear;
end;

procedure TZNODModel.BuildIndex;
var
  I: Integer;
  Obj: TZDXFRawObject;
  Dict: TZDXFDictionary;
begin
  for I := 0 to FObjects.Count - 1 do begin
    Obj := FObjects[I];
    if Obj.Handle = 0 then
      Continue;
    if FObjectByHandle.ContainsKey(Obj.Handle) then begin
      Inc(FDuplicateHandleCount);
      NODLogWarningFormatStr(
        'uzeffdxfnod: duplicate handle %s in OBJECTS (%s, line %d), first object is used',
        [Obj.HandleStr, Obj.ObjType, Obj.LineNumber]);
      Continue;
    end;
    FObjectByHandle.Add(Obj.Handle, Obj);
    if IsDXFDictionaryObjType(Obj.ObjType) then begin
      Dict := TZDXFDictionary.Create(Obj);
      FDictionaries.Add(Dict);
      FDictionaryByHandle.Add(Obj.Handle, Dict);
    end;
  end;
end;

{ NOD — DICTIONARY без владельца (330=0 или группы 330 нет). AutoCAD
  пишет его первым объектом OBJECTS, но порядок здесь не важен. Если таких
  словарей несколько — берётся первый, в лог выдаётся предупреждение.
  APreferred — NOD, известный заранее (DWG: хэндл из заголовка); тогда
  корневые словари только считаются. }
procedure TZNODModel.FindNOD(APreferred: TZDXFDictionary);
var
  I: Integer;
  Dict: TZDXFDictionary;
begin
  FNOD := APreferred;
  FRootDictionaryCount := 0;
  for I := 0 to FDictionaries.Count - 1 do begin
    Dict := FDictionaries[I];
    if not SameText(Dict.RawObject.ObjType, CDXFDictionaryObjType) then
      Continue;
    if Dict.OwnerHandle <> 0 then
      Continue;
    Inc(FRootDictionaryCount);
    if FNOD = nil then
      FNOD := Dict
    else if APreferred = nil then
      NODLogWarningFormatStr(
        'uzeffdxfnod: several root dictionaries (330=0) in OBJECTS: %s is ignored, NOD is %s',
        [Dict.RawObject.HandleStr, FNOD.RawObject.HandleStr]);
  end;
end;

procedure TZNODModel.TraceNODKeys;
var
  I: Integer;
  Keys: string;
begin
  if not NODLogTraceEnabled then
    Exit;
  if FNOD <> nil then begin
    { Список ключей собирается только для включённой трассы NOD }
    Keys := '';
    for I := 0 to FNOD.Count - 1 do begin
      if I > 0 then
        Keys := Keys + ', ';
      Keys := Keys + FNOD[I].Key + '=' + DXFHandleToStr(FNOD[I].TargetHandle);
    end;
    NODLogTraceFormatStr('uzeffdxfnod: NOD %s keys (%d): %s',
      [FNOD.RawObject.HandleStr, FNOD.Count, Keys]);
  end else
    NODLogTraceFormatStr('uzeffdxfnod: NOD not found', []);
end;

function TZNODModel.LoadFromText(const AObjectsSection: string): Boolean;
var
  StartTick: QWord;
  Error: string;
begin
  Clear;
  StartTick := GetTickCount64;
  Result := ParseDxfObjectsSection(AObjectsSection, FObjects, Error);
  if not Result then begin
    FParseError := Error;
    NODLogWarningFormatStr('uzeffdxfnod: OBJECTS section parse error: %s', [Error]);
  end;
  BuildIndex;
  FindNOD;

  NODLogTraceFormatStr(
    'uzeffdxfnod: OBJECTS parsed: %d objects, %d dictionaries, %d root dictionaries, %d ms',
    [FObjects.Count, FDictionaries.Count, FRootDictionaryCount,
     GetTickCount64 - StartTick]);
  TraceNODKeys;
end;

procedure TZNODModel.AddObject(AObject: TZDXFRawObject);
begin
  if AObject <> nil then
    FObjects.Add(AObject);
end;

procedure TZNODModel.AddSymbolRecord(AHandle: TDWGHandle;
  const ATableType, AName: string);
var
  Rec: TZDXFSymbolRecord;
begin
  if AHandle = 0 then
    Exit;
  Rec.TableType := UpperCase(ATableType);
  Rec.Name := AName;
  if FSymbols.ContainsKey(AHandle) then
    NODLogTraceFormatStr(
      'uzeffdxfnod: symbol records: duplicate handle %s (%s "%s"), first record is used',
      [DXFHandleToStr(AHandle), Rec.TableType, Rec.Name])
  else
    FSymbols.Add(AHandle, Rec);
end;

procedure TZNODModel.EndBuild(ANODHandle: TDWGHandle);
var
  Dict: TZDXFDictionary;
begin
  { Повторный вызов перестраивает индексы по текущему списку объектов }
  FNOD := nil;
  FDuplicateHandleCount := 0;
  FDictionaryByHandle.Clear;
  FDictionaries.Clear;
  FObjectByHandle.Clear;
  BuildIndex;
  Dict := nil;
  if ANODHandle <> 0 then
    Dict := FindDictionary(ANODHandle);
  FindNOD(Dict);
  if (ANODHandle <> 0) and (Dict = nil) then begin
    if FNOD <> nil then
      NODLogWarningFormatStr(
        'uzeffdxfnod: root dictionary %s from header not found, NOD is %s (no owner)',
        [DXFHandleToStr(ANODHandle), FNOD.RawObject.HandleStr])
    else
      NODLogWarningFormatStr(
        'uzeffdxfnod: root dictionary %s from header not found, no NOD',
        [DXFHandleToStr(ANODHandle)]);
  end;
  NODLogTraceFormatStr(
    'uzeffdxfnod: model built: %d objects, %d dictionaries, %d root dictionaries, %d symbol records',
    [FObjects.Count, FDictionaries.Count, FRootDictionaryCount, FSymbols.Count]);
  TraceNODKeys;
end;

function TZNODModel.FindObject(AHandle: TDWGHandle): TZDXFRawObject;
begin
  if not FObjectByHandle.TryGetValue(AHandle, Result) then
    Result := nil;
end;

function TZNODModel.FindDictionary(AHandle: TDWGHandle): TZDXFDictionary;
begin
  if not FDictionaryByHandle.TryGetValue(AHandle, Result) then
    Result := nil;
end;

function TZNODModel.ResolvePath(const APath: string): TZDXFRawObject;
var
  Dict: TZDXFDictionary;
  Rest, Key: string;
  P: Integer;
  Entry: TZDXFDictEntry;
begin
  Result := nil;
  if FNOD = nil then
    Exit;
  Result := FNOD.RawObject;
  Rest := APath;
  while Rest <> '' do begin
    P := Pos(CNODPathDelimiter, Rest);
    if P > 0 then begin
      Key := Copy(Rest, 1, P - 1);
      Rest := Copy(Rest, P + 1, Length(Rest) - P);
    end else begin
      Key := Rest;
      Rest := '';
    end;
    Dict := FindDictionary(Result.Handle);
    if (Dict = nil) or not Dict.FindEntry(Key, Entry) then
      Exit(nil);
    Result := FindObject(Entry.TargetHandle);
    if Result = nil then
      Exit;
  end;
end;

function TZNODModel.ResolveDictionary(const APath: string): TZDXFDictionary;
var
  Obj: TZDXFRawObject;
begin
  Obj := ResolvePath(APath);
  if Obj <> nil then
    Result := FindDictionary(Obj.Handle)
  else
    Result := nil;
end;

procedure TZNODModel.ClaimHandle(AHandle: TDWGHandle);
begin
  FClaimedHandles.AddOrSetValue(AHandle, True);
end;

function TZNODModel.IsHandleClaimed(AHandle: TDWGHandle): Boolean;
begin
  Result := FClaimedHandles.ContainsKey(AHandle);
end;

function TZNODModel.ClaimedHandleCount: Integer;
begin
  Result := FClaimedHandles.Count;
end;

function TZNODModel.LoadSymbolTablesFromText(const ATablesSection: string;
  ACodePage: TSystemCodePage): Boolean;
var
  StartTick: QWord;
  Records: TZDXFRawObjectList;
  Obj: TZDXFRawObject;
  Error: string;
  H: TDWGHandle;
  Rec: TZDXFSymbolRecord;
  S: RawByteString;
begin
  FSymbols.Clear;
  StartTick := GetTickCount64;
  Records := TZDXFRawObjectList.Create(True);
  try
    Result := ParseDxfObjectsSection(ATablesSection, Records, Error);
    if not Result then
      NODLogWarningFormatStr('uzeffdxfnod: TABLES section parse error: %s', [Error]);
    for Obj in Records do begin
      { Заголовки таблиц (0/TABLE, 2/<имя таблицы>) — не записи }
      if SameText(Obj.ObjType, 'TABLE') or SameText(Obj.ObjType, 'ENDTAB') then
        Continue;
      H := Obj.Handle;
      if H = 0 then
        TryDXFStrToHandle(Obj.ValueOf(105), H);
      if H = 0 then
        Continue;
      Rec.TableType := UpperCase(Obj.ObjType);
      Rec.Name := Obj.ValueOf(2);
      if ACodePage <> 0 then begin
        S := Rec.Name;
        SetCodePage(S, ACodePage, False);
        SetCodePage(S, CP_UTF8, True);
        Rec.Name := S;
      end;
      if FSymbols.ContainsKey(H) then
        NODLogTraceFormatStr(
          'uzeffdxfnod: TABLES: duplicate handle %s (%s "%s"), first record is used',
          [DXFHandleToStr(H), Rec.TableType, Rec.Name])
      else
        FSymbols.Add(H, Rec);
    end;
  finally
    Records.Free;
  end;
  NODLogTraceFormatStr('uzeffdxfnod: TABLES parsed: %d symbol records, %d ms',
    [FSymbols.Count, GetTickCount64 - StartTick]);
end;

function TZNODModel.FindSymbolName(AHandle: TDWGHandle;
  const ATableType: string; out AName: string): Boolean;
var
  Rec: TZDXFSymbolRecord;
begin
  AName := '';
  Result := FSymbols.TryGetValue(AHandle, Rec) and
    ((ATableType = '') or SameText(Rec.TableType, ATableType));
  if Result then
    AName := Rec.Name;
end;

function TZNODModel.SymbolRecordCount: Integer;
begin
  Result := FSymbols.Count;
end;

end.
