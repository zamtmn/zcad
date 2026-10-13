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
  Модуль: uzeffdxfnodregistry
  Назначение: реестр NOD-обработчиков (этап 3 ТЗ
  cad_source/zengine/TZ_NOD_NamedObjectDictionary.md, контракт — раздел 4.3).

  Обработчик регистрируется по ключу корневого словаря (NOD), например
  ACAD_TABLESTYLE, в initialization своего модуля (как
  RegisterObjectsSaveDxfProc в uzeacadtable_dxf_write) и получает:

  * чтение (AddFromDXF, до ENTITIES; этап 5): EnsureDefaultsProc —
    обязательные записи ('Standard'), если после загрузки их нет (для
    любой версии DXF, в т. ч. R12);
  * чтение (AddFromDXF, DXF 2000+, до ENTITIES) — LoadProc со словарём-веткой
    своего ключа, если ключ есть в NOD загружаемого файла и ссылается на
    словарь. Хэндл словаря-ветки реестр помечает «забранным», хэндлы
    объектов ветки помечает сам обработчик. Исключение в LoadProc загрузку
    не прерывает. Если ключ ссылается прямо на объект типа ObjectType
    (не словарь, например XRECORD ACDB_RECOMPOSE_DATA), объект помечается
    «забранным» без вызова LoadProc (issue #1465);
  * чтение (этап 7, после LoadProc): ветки незарегистрированных ключей,
    которые не пишутся из шаблона (CNODTemplateKeys), копируются в
    TSimpleDrawing.PreservedNODBranches (RunNODPreserveUnknownBranches) и
    при записи выводятся после веток обработчиков с перемаппингом хэндлов;
  * запись (savedxf20XX) — через TZNODSaveSession:
    ReserveHandlesProc — до ENTITIES, не более одного раза за сохранение;
    ClassesProc — перед ENDSEC секции CLASSES;
    SaveProc — перед ENDSEC секции OBJECTS (до RunObjectsSaveDxfProcs).
    Обработчики, у которых MinVersion выше версии сохраняемого файла, при
    записи не вызываются, в лог пишется предупреждение.
    Этап 6: XDataAppName — приложение расширенных данных объектов
    обработчика, пишется в таблицу APPID (с учётом MinVersion);
    NeedsSymbolTables — LoadProc нужен индекс символьных таблиц модели
    (хэндл записи TABLES → имя), см. NODLoadNeedsSymbolTables.
    Этап 4: если ReserveHandlesProc вернул хэндл словаря-ветки (не 0), то
    ветка шаблона для ключа обработчика (словарь и все его объекты)
    пропускается при копировании шаблона, запись 3/350 в NOD шаблона
    ссылается на новый словарь, а при отсутствии ключа в NOD шаблона
    запись добавляется (в алфавитном порядке ключей). 0 — обработчик ключ
    не берёт: ветка шаблона копируется как есть.

  Ключ ZCAD (CNODZCADDataKey) зарезервирован обработчиком
  uzeffdxfnodzcad: его ветка не сохраняется как «чужая» (этап 7).

  Обработчики вызываются в порядке регистрации — хэндлы в файле
  детерминированы. Реестр сам хэндлы не выделяет: все хэндлы обработчик
  берёт из IODXFContext.handle.

  Детальная трасса — модуль лога NOD (lem NOD), выключен по умолчанию.
}
unit uzeffdxfnodregistry;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  uzeTypes,
  uzctnrVectorBytesStream,
  uzedrawingsimple,
  usimplegenerics,
  uzeffdxfsupport,
  uzeffdxfnod,
  uzeffdxfnodpreserved;

const
  { Минимальная версия DXF обработчика по умолчанию: DXF 2000 }
  CNODHandlerDefaultMinVersion = AC1015;
  { Ключ NOD данных ZCAD: зарезервирован обработчиком uzeffdxfnodzcad, его
    наполнение вне рамок этапа 7 }
  CNODZCADDataKey = 'ZCAD_DATA';
  { Ключи NOD, которые пишутся из шаблона (ограничение 2 ТЗ NOD): их
    ветки из загружаемого файла не сохраняются }
  CNODTemplateKeys: array[0..8] of string = (
    'ACAD_GROUP', 'ACAD_LAYOUT', 'ACAD_MLINESTYLE', 'ACAD_PLOTSETTINGS',
    'ACAD_PLOTSTYLENAME', 'ACAD_MATERIAL', 'ACAD_VISUALSTYLE', 'ACAD_COLOR',
    'AcDbVariableDictionary');
  { Ключи NOD, ветки которых ссылаются на объекты сущностей (FIELD в
    расширенных словарях сущностей): ZCAD эти объекты не сохраняет, поэтому
    ветки не сохраняются }
  CNODNotPreservedKeys: array[0..0] of string = (
    'ACAD_FIELDLIST');

type
  { Чтение: перенос данных ветки ADict (словарь по ключу обработчика в NOD)
    в чертёж. Вызывается до разбора ENTITIES. }
  TNODLoadProc = procedure(const AModel: TZNODModel;
    const ADict: TZDXFDictionary; var ADrawing: TSimpleDrawing);
  { Запись, до ENTITIES: выделяет хэндлы словаря-ветки и её объектов через
    AIODXFContext.handle и заполняет карты имя → хэндл. Возвращает хэндл
    словаря-ветки (0 — ветка не пишется). Реестр вызывает её не более
    одного раза за сохранение. }
  TNODReserveHandlesProc = function(var ADrawing: TSimpleDrawing;
    var AIODXFContext: TIODXFSaveContext): TDWGHandle;
  { Запись, секция OBJECTS: словарь-ветка и её объекты.
    ADictHandle — результат ReserveHandlesProc, ANODHandle — новый хэндл
    корневого словаря (NOD) в сохраняемом файле (0 — не найден). }
  TNODSaveProc = procedure(var AOutStream: TZctnrVectorBytes;
    var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext;
    ADictHandle, ANODHandle: TDWGHandle);
  { Запись, секция CLASSES (необязательная): объявление классов.
    Имена классов шаблона — AIODXFContext.TemplateClassNames. }
  TNODClassesProc = procedure(var AOutStream: TZctnrVectorBytes;
    var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext);
  { Запись (необязательная, после ReserveHandlesProc): новый хэндл объекта
    ветки с именем AName (0 — нет). Нужна, чтобы перенаправить ссылки
    других объектов шаблона на пропущенные объекты его ветки. }
  TNODFindObjectHandleProc = function(const AName: string;
    var AIODXFContext: TIODXFSaveContext): TDWGHandle;
  { Чтение (необязательная): обязательные записи по умолчанию (стиль
    'Standard' и т. п.), если после загрузки их нет в чертеже. Вызывается
    для каждого загружаемого DXF (и R12, и 2000+) после LoadProc, до
    ENTITIES — независимо от того, есть ли ключ в NOD файла. }
  TNODEnsureDefaultsProc = procedure(var ADrawing: TSimpleDrawing);

  { Описание NOD-обработчика. Любая процедура может быть nil. }
  TZNODHandler = record
    { Ключ записи в NOD ('ACAD_TABLESTYLE'); сравнивается без учёта
      регистра, как ключи словарей }
    Key: string;
    { Тип объектов ветки ('TABLESTYLE') — для лога и проверок обработчика }
    ObjectType: string;
    { Минимальная версия DXF, в которой ветка пишется }
    MinVersion: TACDWGVer;
    { Имя обязательной записи ('Standard'), '' — нет }
    DefaultName: string;
    LoadProc: TNODLoadProc;
    ReserveHandlesProc: TNODReserveHandlesProc;
    SaveProc: TNODSaveProc;
    ClassesProc: TNODClassesProc;
    FindObjectHandleProc: TNODFindObjectHandleProc;
    EnsureDefaultsProc: TNODEnsureDefaultsProc;
    { Имя приложения расширенных данных (1001), которое пишут объекты ветки
      ('ACAD_MLEADERVER'); '' — нет. При записи регистрируется в таблице
      APPID (этап 6). }
    XDataAppName: string;
    { LoadProc нужен индекс символьных таблиц (хэндл → имя записи LTYPE,
      STYLE, BLOCK_RECORD...; TZNODModel.FindSymbolName): объекты ветки
      ссылаются на записи таблиц по хэндлам (этап 6). Секция TABLES
      разбирается, только если такой обработчик будет вызван. }
    NeedsSymbolTables: Boolean;
  end;
  TZNODHandlers = array of TZNODHandler;

  { Ссылка объекта шаблона (вне ветки) на объект ветки обработчика }
  TZNODTemplateRef = record
    { Хэндл объекта ветки в шаблоне }
    Handle: TDWGHandle;
    { Индекс обработчика в сессии }
    HandlerIndex: Integer;
    { Ключ объекта в словаре ветки ('' — объект не запись словаря) }
    Name: string;
  end;
  TZNODTemplateRefs = array of TZNODTemplateRef;

  { Состояние NOD-обработчиков на время одного сохранения DXF.
    Список обработчиков фиксируется при создании (только подходящие по
    версии), поэтому регистрация во время сохранения на него не влияет. }
  TZNODSaveSession = class
  private
    FVersion: TACDWGVer;
    FHandlers: TZNODHandlers;
    FDictHandles: array of TDWGHandle;
    FHandlesReserved: Boolean;
    FObjectsWritten: Boolean;
    FTemplateNODHandle: TDWGHandle;
    { Хэндл словаря-ветки ключа обработчика в NOD шаблона (0 — ключа нет) }
    FTemplateDictHandles: array of TDWGHandle;
    { Хэндл объекта ветки шаблона → индекс обработчика }
    FTemplateBranch: TDictionary<TDWGHandle, Integer>;
    { Ссылки на объекты веток из остальных объектов шаблона }
    FTemplateRefs: TZNODTemplateRefs;
    FTemplateHandlesMapped: Boolean;
    { Записи NOD, добавленные в вывод (по индексу обработчика) }
    FNODEntryInserted: array of Boolean;
    { Этап 7: сохранённые ветки чертежа (не владеет; nil — нет) }
    FPreserved: TZNODPreservedBranches;
    { Ключи NOD шаблона }
    FTemplateNODKeys: TStringList;
    { Пишется ли ветка (по индексу ветки FPreserved) }
    FPreservedWritten: array of Boolean;
    { Запись NOD ветки добавлена в вывод }
    FPreservedInserted: array of Boolean;
    { Исходный хэндл объекта ветки → новый }
    FPreservedHandles: TDictionary<TDWGHandle, TDWGHandle>;
    function GetCount: Integer;
    function GetHandler(AIndex: Integer): TZNODHandler;
    function GetDictHandle(AIndex: Integer): TDWGHandle;
    function GetTemplateDictHandle(AIndex: Integer): TDWGHandle;
    procedure BuildTemplateBranches(AModel: TZNODModel);
    procedure SelectPreservedBranches;
    function GetPreservedWritten(AIndex: Integer): Boolean;
    function HasPreservedBranches: Boolean;
    function ResolvePreservedRef(ABranch: Integer; AHandle: TDWGHandle;
      ANODHandle: TDWGHandle; var AIODXFContext: TIODXFSaveContext;
      out ANewHandle: TDWGHandle): Boolean;
    procedure WritePreservedObject(var AOutStream: TZctnrVectorBytes;
      AObjIndex: Integer; var AIODXFContext: TIODXFSaveContext;
      ANODHandle: TDWGHandle);
  public
    { APreserved — сохранённые ветки NOD чертежа (этап 7; nil — нет):
      пишутся после веток обработчиков, если их ключа нет в NOD шаблона. }
    constructor Create(AVersion: TACDWGVer;
      APreserved: TZNODPreservedBranches = nil);
    destructor Destroy; override;
    { Разбирает секцию OBJECTS шаблона моделью этапа 1 и запоминает
      исходный хэндл его NOD (TemplateNODHandle), словари-ветки ключей
      обработчиков, множество хэндлов их объектов и ссылки на них из
      остальных объектов шаблона. Если обработчиков и сохранённых веток
      нет, шаблон не читается. False — NOD в шаблоне не найден. }
    function LoadTemplate(const ATemplateFileName: string): Boolean;
    { Разбирает текст секции OBJECTS шаблона (для тестов; LoadTemplate —
      то же для файла). }
    function LoadTemplateText(const AObjectsSection: string): Boolean;
    { Вызывает ReserveHandlesProc всех обработчиков и выделяет новые хэндлы
      объектам записываемых сохранённых веток (этап 7). Идемпотентна:
      вызовы после первого ничего не делают. }
    procedure ReserveHandles(var ADrawing: TSimpleDrawing;
      var AIODXFContext: TIODXFSaveContext);
    { Вызывает ClassesProc всех обработчиков, затем пишет классы объектов
      записываемых сохранённых веток, которых нет среди классов шаблона
      (этап 7). }
    procedure WriteClasses(var AOutStream: TZctnrVectorBytes;
      var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext);
    { Вызывает SaveProc всех обработчиков (при необходимости сначала
      ReserveHandles), затем пишет объекты сохранённых веток (этап 7) с
      перемаппингом хэндлов. ANODHandle — новый хэндл NOD в сохраняемом
      файле. Идемпотентна. }
    procedure WriteObjects(var AOutStream: TZctnrVectorBytes;
      var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext;
      ANODHandle: TDWGHandle);
    { После ReserveHandles: регистрирует в AMap (старый хэндл шаблона →
      новый) словари-ветки шаблона, которые заменяет обработчик (→ хэндл
      из ReserveHandlesProc, так перемапится пара 350 в NOD шаблона), и
      объекты веток, на которые ссылаются другие объекты шаблона (→ объект
      чертежа с тем же именем через FindObjectHandleProc, иначе — объект
      с именем DefaultName). Идемпотентна. }
    procedure MapTemplateHandles(AMap: TMapHandleToHandle;
      var AIODXFContext: TIODXFSaveContext);
    { Пропускается ли объект шаблона с хэндлом AHandle: объект ветки ключа,
      для которого обработчик выделил свой словарь (DictHandle > 0). }
    function IsTemplateHandleSkipped(AHandle: TDWGHandle): Boolean;
    { Есть ли что пропускать в шаблоне (после ReserveHandles) }
    function HasTemplateSkips: Boolean;
    { Записи 3/350, которые нужно добавить в NOD шаблона перед его записью
      с ключом ANextKey (ключи обработчиков, которых нет в NOD шаблона, у
      которых DictHandle > 0, и записываемых сохранённых веток — с их
      исходным кодом 350/360; по алфавиту меньше ANextKey).
      ANextKey = '' — все оставшиеся (конец NOD). Каждая запись выдаётся
      один раз; результат упорядочен по ключу. }
    function TakeNODInsertions(const ANextKey: string): TZDXFDictEntries;
    { Имена приложений расширенных данных (1001) объектов записываемых
      сохранённых веток — для таблицы APPID (этап 7). Добавляются в AList
      без повторов. }
    procedure GetPreservedXDataAppNames(AList: TStrings);
    { Новый хэндл объекта сохранённой ветки (после ReserveHandles; 0 —
      объект не пишется) }
    function PreservedNewHandle(ASourceHandle: TDWGHandle): TDWGHandle;

    property Version: TACDWGVer read FVersion;
    { Количество обработчиков, участвующих в сохранении }
    property Count: Integer read GetCount;
    property Handlers[AIndex: Integer]: TZNODHandler read GetHandler;
    { Хэндл словаря-ветки, выделенный ReserveHandlesProc (0 — нет) }
    property DictHandles[AIndex: Integer]: TDWGHandle read GetDictHandle;
    property HandlesReserved: Boolean read FHandlesReserved;
    property ObjectsWritten: Boolean read FObjectsWritten;
    { Исходный хэндл NOD шаблона (0 — шаблон не читался или NOD нет) }
    property TemplateNODHandle: TDWGHandle read FTemplateNODHandle;
    { Хэндл словаря-ветки обработчика в шаблоне (0 — ключа в NOD шаблона нет) }
    property TemplateDictHandles[AIndex: Integer]: TDWGHandle
      read GetTemplateDictHandle;
    { Ссылки остальных объектов шаблона на объекты веток }
    property TemplateRefs: TZNODTemplateRefs read FTemplateRefs;
    { Сохранённые ветки чертежа (этап 7; nil — нет) }
    property Preserved: TZNODPreservedBranches read FPreserved;
    { Пишется ли сохранённая ветка AIndex: шаблон прочитан, в NOD шаблона
      её ключа нет, обработчика ключа нет }
    property PreservedWritten[AIndex: Integer]: Boolean read GetPreservedWritten;
    { Ключи NOD шаблона (после LoadTemplate) }
    property TemplateNODKeys: TStringList read FTemplateNODKeys;
  end;

{ Регистрирует обработчик. False (и предупреждение в лог) — пустой ключ или
  обработчик с таким ключом уже зарегистрирован. }
function RegisterNODHandler(const AHandler: TZNODHandler): Boolean; overload;
function RegisterNODHandler(const AKey, AObjectType: string;
  ALoadProc: TNODLoadProc; AReserveHandlesProc: TNODReserveHandlesProc;
  ASaveProc: TNODSaveProc; AClassesProc: TNODClassesProc = nil;
  AMinVersion: TACDWGVer = CNODHandlerDefaultMinVersion;
  const ADefaultName: string = ''): Boolean; overload;
{ Удаляет обработчик (для тестов и выгрузки модулей). False — не найден. }
function UnregisterNODHandler(const AKey: string): Boolean;
function NODHandlerCount: Integer;
{ Обработчик по индексу в порядке регистрации }
function GetNODHandler(AIndex: Integer): TZNODHandler;
function FindNODHandler(const AKey: string; out AHandler: TZNODHandler): Boolean;

{ Чтение: для каждого зарегистрированного ключа, найденного в NOD модели и
  ссылающегося на словарь, вызывает LoadProc (в порядке регистрации).
  Возвращает количество вызванных LoadProc. AModel = nil или модель без
  NOD — ничего не вызывается. }
function RunNODLoadHandlers(AModel: TZNODModel;
  var ADrawing: TSimpleDrawing): Integer;
{ Чтение: вызывает EnsureDefaultsProc всех обработчиков (в порядке
  регистрации) — после RunNODLoadHandlers, до ENTITIES; для DXF R12, где
  NOD нет, — вместо него. Возвращает количество вызванных процедур.
  Исключение в процедуре загрузку не прерывает. }
function RunNODEnsureDefaults(var ADrawing: TSimpleDrawing): Integer;
{ Чтение: нужен ли индекс символьных таблиц — есть обработчик с
  NeedsSymbolTables, ключ которого есть в NOD модели и ссылается на
  непустой словарь. Вызывается после разбора OBJECTS, до
  RunNODLoadHandlers. }
function NODLoadNeedsSymbolTables(AModel: TZNODModel): Boolean;
{ Чтение (этап 7): после RunNODLoadHandlers копирует в
  ADrawing.PreservedNODBranches (создаёт при необходимости) ветки ключей
  NOD, которые не обрабатываются реестром и не пишутся из шаблона
  (IsNODPreservableKey): корневой объект записи и все объекты, которыми
  владеет ветка (владелец 330, расширенные словари). Из AClassesSection
  (текст секции CLASSES) берутся определения классов типов этих объектов.
  ACodePage <> 0 — кодовая страница строк (DXF до 2007), значения
  перекодируются в UTF-8. Возвращает количество сохранённых веток. }
function RunNODPreserveUnknownBranches(AModel: TZNODModel;
  var ADrawing: TSimpleDrawing; const AClassesSection: string = '';
  ACodePage: TSystemCodePage = 0): Integer;
{ Ключ NOD пишется из шаблона (CNODTemplateKeys) }
function IsNODTemplateKey(const AKey: string): Boolean;
{ Ветку ключа можно сохранить при загрузке (этап 7): нет обработчика, ключ
  не пишется из шаблона и не в CNODNotPreservedKeys }
function IsNODPreservableKey(const AKey: string): Boolean;
{ Код группы — ссылка на хэндл объекта (этап 7): 320–369, 390–399,
  480–481, 1005. Собственный хэндл 5 сюда не входит. }
function IsNODPreservedRefGroupCode(ACode: Integer): Boolean;

{ Имя версии DXF для лога ('AC1015') }
function ACDWGVerName(AVersion: TACDWGVer): string;

implementation

uses
  TypInfo,
  uzeffdxfobjects,
  uzeffdxfnodlog;

var
  NODHandlers: TZNODHandlers;

function ACDWGVerName(AVersion: TACDWGVer): string;
begin
  Result := GetEnumName(TypeInfo(TACDWGVer), Ord(AVersion));
end;

function IndexOfNODHandler(const AKey: string): Integer;
var
  I: Integer;
begin
  for I := 0 to High(NODHandlers) do
    if SameText(NODHandlers[I].Key, AKey) then
      Exit(I);
  Result := -1;
end;

function RegisterNODHandler(const AHandler: TZNODHandler): Boolean;
var
  I: Integer;
begin
  if Trim(AHandler.Key) = '' then begin
    NODLogWarningFormatStr(
      'uzeffdxfnodregistry: NOD handler with empty key is not registered', []);
    Exit(False);
  end;
  if IndexOfNODHandler(AHandler.Key) >= 0 then begin
    NODLogWarningFormatStr(
      'uzeffdxfnodregistry: NOD handler for key "%s" is already registered',
      [AHandler.Key]);
    Exit(False);
  end;
  I := Length(NODHandlers);
  SetLength(NODHandlers, I + 1);
  NODHandlers[I] := AHandler;
  NODLogTraceFormatStr(
    'uzeffdxfnodregistry: registered NOD handler #%d "%s" (%s, min %s)',
    [I, AHandler.Key, AHandler.ObjectType, ACDWGVerName(AHandler.MinVersion)]);
  Result := True;
end;

function RegisterNODHandler(const AKey, AObjectType: string;
  ALoadProc: TNODLoadProc; AReserveHandlesProc: TNODReserveHandlesProc;
  ASaveProc: TNODSaveProc; AClassesProc: TNODClassesProc;
  AMinVersion: TACDWGVer; const ADefaultName: string): Boolean;
var
  H: TZNODHandler;
begin
  H := Default(TZNODHandler);
  H.Key := AKey;
  H.ObjectType := AObjectType;
  H.MinVersion := AMinVersion;
  H.DefaultName := ADefaultName;
  H.LoadProc := ALoadProc;
  H.ReserveHandlesProc := AReserveHandlesProc;
  H.SaveProc := ASaveProc;
  H.ClassesProc := AClassesProc;
  Result := RegisterNODHandler(H);
end;

function UnregisterNODHandler(const AKey: string): Boolean;
var
  I, J: Integer;
begin
  I := IndexOfNODHandler(AKey);
  if I < 0 then
    Exit(False);
  for J := I to High(NODHandlers) - 1 do
    NODHandlers[J] := NODHandlers[J + 1];
  SetLength(NODHandlers, Length(NODHandlers) - 1);
  Result := True;
end;

function NODHandlerCount: Integer;
begin
  Result := Length(NODHandlers);
end;

function GetNODHandler(AIndex: Integer): TZNODHandler;
begin
  Result := NODHandlers[AIndex];
end;

function FindNODHandler(const AKey: string; out AHandler: TZNODHandler): Boolean;
var
  I: Integer;
begin
  I := IndexOfNODHandler(AKey);
  Result := I >= 0;
  if Result then
    AHandler := NODHandlers[I]
  else
    AHandler := Default(TZNODHandler);
end;

{ Ключ NOD, ссылающийся не на словарь, а прямо на объект типа
  AHandler.ObjectType (ACDB_RECOMPOSE_DATA → XRECORD, issue #1465): хэндл
  помечается «забранным», LoadProc (ему нужен словарь) не вызывается —
  такие записи обработчик читает из модели NOD сам. }
function ClaimNODObjectEntry(AModel: TZNODModel; const AHandler: TZNODHandler;
  ATarget: TDWGHandle): Boolean;
var
  Obj: TZDXFRawObject;
begin
  Obj := AModel.FindObject(ATarget);
  Result := (Obj <> nil) and (AHandler.ObjectType <> '') and
    SameText(Obj.ObjType, AHandler.ObjectType);
  if not Result then
    Exit;
  AModel.ClaimHandle(ATarget);
  NODLogTraceFormatStr(
    'uzeffdxfnodregistry: load: key "%s" refers to %s %s, claimed',
    [AHandler.Key, Obj.ObjType, Obj.HandleStr]);
end;

function RunNODLoadHandlers(AModel: TZNODModel;
  var ADrawing: TSimpleDrawing): Integer;
var
  I: Integer;
  Handlers: TZNODHandlers;
  Entry: TZDXFDictEntry;
  Dict: TZDXFDictionary;
begin
  Result := 0;
  if (AModel = nil) or (AModel.NOD = nil) then begin
    NODLogTraceFormatStr('uzeffdxfnodregistry: load: no NOD, handlers skipped', []);
    Exit;
  end;
  { Копия списка: обработчик может (от)регистрировать обработчики }
  Handlers := Copy(NODHandlers);
  for I := 0 to AModel.NOD.Count - 1 do
    if IndexOfNODHandler(AModel.NOD[I].Key) < 0 then
      NODLogTraceFormatStr(
        'uzeffdxfnodregistry: load: NOD key "%s" has no handler',
        [AModel.NOD[I].Key]);
  for I := 0 to High(Handlers) do begin
    if not AModel.NOD.FindEntry(Handlers[I].Key, Entry) then begin
      NODLogTraceFormatStr(
        'uzeffdxfnodregistry: load: key "%s" not found in NOD',
        [Handlers[I].Key]);
      Continue;
    end;
    Dict := AModel.FindDictionary(Entry.TargetHandle);
    if (Dict = nil) and ClaimNODObjectEntry(AModel, Handlers[I],
         Entry.TargetHandle) then
      Continue;
    if Dict = nil then begin
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: load: NOD key "%s" refers to %s, which is not a dictionary; skipped',
        [Handlers[I].Key, DXFHandleToStr(Entry.TargetHandle)]);
      Continue;
    end;
    AModel.ClaimHandle(Dict.Handle);
    if not Assigned(Handlers[I].LoadProc) then
      Continue;
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: load: key "%s", dictionary %s, %d entries',
      [Handlers[I].Key, Dict.RawObject.HandleStr, Dict.Count]);
    try
      Handlers[I].LoadProc(AModel, Dict, ADrawing);
      Inc(Result);
    except
      on E: Exception do
        NODLogWarningFormatStr(
          'uzeffdxfnodregistry: load: handler "%s" failed: %s: %s',
          [Handlers[I].Key, E.ClassName, E.Message]);
    end;
  end;
end;

function RunNODEnsureDefaults(var ADrawing: TSimpleDrawing): Integer;
var
  I: Integer;
  Handlers: TZNODHandlers;
begin
  Result := 0;
  Handlers := Copy(NODHandlers);
  for I := 0 to High(Handlers) do begin
    if not Assigned(Handlers[I].EnsureDefaultsProc) then
      Continue;
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: load: defaults of key "%s"', [Handlers[I].Key]);
    try
      Handlers[I].EnsureDefaultsProc(ADrawing);
      Inc(Result);
    except
      on E: Exception do
        NODLogWarningFormatStr(
          'uzeffdxfnodregistry: load: defaults of "%s" failed: %s: %s',
          [Handlers[I].Key, E.ClassName, E.Message]);
    end;
  end;
end;

function NODLoadNeedsSymbolTables(AModel: TZNODModel): Boolean;
var
  I: Integer;
  Entry: TZDXFDictEntry;
  Dict: TZDXFDictionary;
begin
  Result := False;
  if (AModel = nil) or (AModel.NOD = nil) then
    Exit;
  for I := 0 to High(NODHandlers) do
    if NODHandlers[I].NeedsSymbolTables and
       AModel.NOD.FindEntry(NODHandlers[I].Key, Entry) then begin
      Dict := AModel.FindDictionary(Entry.TargetHandle);
      if (Dict <> nil) and (Dict.Count > 0) then begin
        NODLogTraceFormatStr(
          'uzeffdxfnodregistry: load: key "%s" needs symbol tables',
          [NODHandlers[I].Key]);
        Exit(True);
      end;
    end;
end;

function IsNODTemplateKey(const AKey: string): Boolean;
var
  S: string;
begin
  for S in CNODTemplateKeys do
    if SameText(S, AKey) then
      Exit(True);
  Result := False;
end;

function IsNODPreservableKey(const AKey: string): Boolean;
var
  S: string;
begin
  Result := False;
  if (Trim(AKey) = '') or (IndexOfNODHandler(AKey) >= 0) or
     IsNODTemplateKey(AKey) then
    Exit;
  for S in CNODNotPreservedKeys do
    if SameText(S, AKey) then
      Exit;
  Result := True;
end;

function IsNODPreservedRefGroupCode(ACode: Integer): Boolean;
begin
  case ACode of
    320..369, 390..399, 480..481, 1005:
      Result := True;
  else
    Result := False;
  end;
end;

{ Строка кодовой страницы ACodePage → UTF-8 (0 или ASCII — без изменений) }
function NODDecodeValue(const AValue: string; ACodePage: TSystemCodePage): string;
var
  I: Integer;
  Hdr: TDXFHeaderInfo;
begin
  Result := AValue;
  if ACodePage = 0 then
    Exit;
  for I := 1 to Length(AValue) do
    if Ord(AValue[I]) >= $80 then begin
      Hdr.InitRec;
      Hdr.iVersion := 1015;
      Hdr.iDWGCodePage := ACodePage;
      Exit(dxfDeCodeString(AValue, Hdr));
    end;
end;

function RunNODPreserveUnknownBranches(AModel: TZNODModel;
  var ADrawing: TSimpleDrawing; const AClassesSection: string;
  ACodePage: TSystemCodePage): Integer;
var
  NODHandle: TDWGHandle;
  Preserved: TZNODPreservedBranches;
  Branch: TDictionary<TDWGHandle, Boolean>;
  HandlerRefs: TDictionary<TDWGHandle, TZNODPreservedRef>;

  { Может ли объект AHandle войти в ветку: существует, не NOD, не забран
    обработчиком и не входит в уже сохранённые ветки }
  function CanTake(AHandle: TDWGHandle): Boolean;
  begin
    Result := (AHandle <> 0) and (AHandle <> NODHandle) and
      (AModel.FindObject(AHandle) <> nil) and
      not AModel.IsHandleClaimed(AHandle) and
      not ((Preserved <> nil) and Preserved.ContainsHandle(AHandle));
  end;

  function AddToBranch(AHandle: TDWGHandle): Boolean;
  begin
    Result := CanTake(AHandle) and not Branch.ContainsKey(AHandle);
    if Result then
      Branch.Add(AHandle, True);
  end;

  { Ссылки на словари-ветки обработчиков и их записи: при записи
    разрешаются по имени (стиль таблиц и т. п.) }
  procedure BuildHandlerRefs;
  var
    I, J: Integer;
    Entry: TZDXFDictEntry;
    Dict: TZDXFDictionary;
    R: TZNODPreservedRef;
  begin
    for I := 0 to High(NODHandlers) do
      if AModel.NOD.FindEntry(NODHandlers[I].Key, Entry) then begin
        Dict := AModel.FindDictionary(Entry.TargetHandle);
        if Dict = nil then
          Continue;
        R.Handle := Dict.Handle;
        R.HandlerKey := NODHandlers[I].Key;
        R.Name := '';
        HandlerRefs.AddOrSetValue(R.Handle, R);
        for J := 0 to Dict.Count - 1 do
          if not HandlerRefs.ContainsKey(Dict[J].TargetHandle) then begin
            R.Handle := Dict[J].TargetHandle;
            R.Name := Dict[J].Key;
            HandlerRefs.Add(R.Handle, R);
          end;
      end;
  end;

  { Копирует объекты ветки (в порядке файла) в ветку AIndex хранилища,
    запоминает внешние ссылки на объекты обработчиков }
  procedure CopyBranch(AIndex: Integer; const AKey: string);
  var
    Obj, Copied: TZDXFRawObject;
    J: Integer;
    Ref: TDWGHandle;
    R: TZNODPreservedRef;
  begin
    for Obj in AModel.Objects do begin
      if not Branch.ContainsKey(Obj.Handle) then
        Continue;
      { Повтор хэндла в файле: берётся объект индекса модели }
      if AModel.FindObject(Obj.Handle) <> Obj then
        Continue;
      Copied := Preserved.AddObjectCopy(AIndex, Obj);
      for J := 0 to Copied.PairCount - 1 do begin
        Copied.Pairs[J].Value := NODDecodeValue(Copied.Pairs[J].Value, ACodePage);
        if not IsNODPreservedRefGroupCode(Copied.Pairs[J].Code) or
           not TryDXFStrToHandle(Trim(Copied.Pairs[J].Value), Ref) or
           (Ref = 0) or (Ref = NODHandle) or Branch.ContainsKey(Ref) then
          Continue;
        if HandlerRefs.TryGetValue(Ref, R) then begin
          Preserved.AddRef(Ref, R.HandlerKey, R.Name);
          NODLogTraceFormatStr(
            'uzeffdxfnodregistry: load: key "%s": %s %s refers to %s ("%s") of key "%s"',
            [AKey, Obj.ObjType, Obj.HandleStr, DXFHandleToStr(Ref), R.Name,
             R.HandlerKey]);
        end else
          NODLogTraceFormatStr(
            'uzeffdxfnodregistry: load: key "%s": %s %s refers to %s (group %d) outside the branch',
            [AKey, Obj.ObjType, Obj.HandleStr, DXFHandleToStr(Ref),
             Copied.Pairs[J].Code]);
      end;
    end;
  end;

  { Определения классов типов сохранённых объектов из секции CLASSES }
  procedure CopyClasses;
  var
    ClassObjs: TZDXFRawObjectList;
    C: TZDXFRawObject;
    Err, Name: string;
    I: Integer;
    Used: Boolean;
  begin
    if AClassesSection = '' then
      Exit;
    ClassObjs := TZDXFRawObjectList.Create(True);
    try
      if not ParseDxfObjectsSection(AClassesSection, ClassObjs, Err) then
        NODLogWarningFormatStr(
          'uzeffdxfnodregistry: load: CLASSES parse error: %s', [Err]);
      for C in ClassObjs do begin
        if not SameText(C.ObjType, 'CLASS') then
          Continue;
        Name := Trim(C.ValueOf(1));
        Used := False;
        for I := 0 to Preserved.ObjectCount - 1 do
          if SameText(Preserved.Objects[I].ObjType, Name) then begin
            Used := True;
            Break;
          end;
        if Used and (Preserved.FindClass(Name) = nil) then begin
          Preserved.AddClassCopy(C);
          NODLogTraceFormatStr(
            'uzeffdxfnodregistry: load: class "%s" (%s) preserved',
            [Name, Trim(C.ValueOf(2))]);
        end;
      end;
    finally
      ClassObjs.Free;
    end;
  end;

var
  I, B, ObjCount: Integer;
  Entry: TZDXFDictEntry;
  Changed: Boolean;
  Obj: TZDXFRawObject;
begin
  Result := 0;
  if (AModel = nil) or (AModel.NOD = nil) then
    Exit;
  NODHandle := AModel.NOD.Handle;
  Preserved := ADrawing.PreservedNODBranches;
  Branch := TDictionary<TDWGHandle, Boolean>.Create;
  HandlerRefs := TDictionary<TDWGHandle, TZNODPreservedRef>.Create;
  try
    BuildHandlerRefs;
    for I := 0 to AModel.NOD.Count - 1 do begin
      Entry := AModel.NOD[I];
      if IndexOfNODHandler(Entry.Key) >= 0 then
        Continue;
      if not IsNODPreservableKey(Entry.Key) then begin
        NODLogTraceFormatStr(
          'uzeffdxfnodregistry: load: NOD key "%s" is not preserved (written from template)',
          [Entry.Key]);
        Continue;
      end;
      if (Preserved <> nil) and (Preserved.IndexOfKey(Entry.Key) >= 0) then begin
        NODLogWarningFormatStr(
          'uzeffdxfnodregistry: load: NOD key "%s" is already preserved, skipped',
          [Entry.Key]);
        Continue;
      end;
      if not CanTake(Entry.TargetHandle) then begin
        NODLogWarningFormatStr(
          'uzeffdxfnodregistry: load: NOD key "%s" refers to %s, which is missing or already used; not preserved',
          [Entry.Key, DXFHandleToStr(Entry.TargetHandle)]);
        Continue;
      end;
      { Замыкание: расширенные словари объектов ветки и объекты, владелец
        которых (330) — объект ветки. Записи словарей с чужим владельцем —
        ссылки, а не владение: в ветку не входят. }
      Branch.Clear;
      Branch.Add(Entry.TargetHandle, True);
      repeat
        Changed := False;
        for Obj in AModel.Objects do
          if Branch.ContainsKey(Obj.Handle) then begin
            if AddToBranch(Obj.XDictHandle) then
              Changed := True;
          end else if Obj.HasOwnerGroup and Branch.ContainsKey(Obj.OwnerHandle) then
            if AddToBranch(Obj.Handle) then
              Changed := True;
      until not Changed;
      if Preserved = nil then begin
        Preserved := TZNODPreservedBranches.Create;
        ADrawing.PreservedNODBranches := Preserved;
      end;
      ObjCount := Preserved.ObjectCount;
      B := Preserved.AddBranch(Entry.Key, Entry.TargetHandle,
        Entry.OwnershipCode, NODHandle);
      CopyBranch(B, Entry.Key);
      Inc(Result);
      NODLogTraceFormatStr(
        'uzeffdxfnodregistry: load: NOD key "%s" preserved: root %s (%d), %d objects',
        [Entry.Key, DXFHandleToStr(Entry.TargetHandle), Entry.OwnershipCode,
         Preserved.ObjectCount - ObjCount]);
    end;
    if Result > 0 then
      CopyClasses;
  finally
    HandlerRefs.Free;
    Branch.Free;
  end;
end;

{ Текст секции OBJECTS DXF-файла (от 0/SECTION до конца файла — разбор
  остановится на ENDSEC). '' — секции нет. }
function ReadDXFObjectsSectionText(const AFileName: string): string;
var
  Lines, Section: TStringList;
  I, Start: Integer;
begin
  Result := '';
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFileName);
    Start := -1;
    for I := 0 to Lines.Count - 4 do
      if (Trim(Lines[I]) = '0') and (Trim(Lines[I + 1]) = 'SECTION') and
         (Trim(Lines[I + 2]) = '2') and (Trim(Lines[I + 3]) = 'OBJECTS') then begin
        Start := I;
        Break;
      end;
    if Start < 0 then
      Exit;
    Section := TStringList.Create;
    try
      for I := Start to Lines.Count - 1 do
        Section.Add(Lines[I]);
      Result := Section.Text;
    finally
      Section.Free;
    end;
  finally
    Lines.Free;
  end;
end;

{ TZNODSaveSession }

constructor TZNODSaveSession.Create(AVersion: TACDWGVer;
  APreserved: TZNODPreservedBranches);
var
  I, N: Integer;
begin
  inherited Create;
  FVersion := AVersion;
  FPreserved := APreserved;
  FTemplateNODKeys := TStringList.Create;
  FTemplateNODKeys.CaseSensitive := False;
  FPreservedHandles := TDictionary<TDWGHandle, TDWGHandle>.Create;
  if FPreserved <> nil then begin
    SetLength(FPreservedWritten, FPreserved.BranchCount);
    SetLength(FPreservedInserted, FPreserved.BranchCount);
    for I := 0 to FPreserved.BranchCount - 1 do begin
      FPreservedWritten[I] := False;
      FPreservedInserted[I] := False;
    end;
  end;
  SetLength(FHandlers, Length(NODHandlers));
  N := 0;
  for I := 0 to High(NODHandlers) do
    if NODHandlers[I].MinVersion <= AVersion then begin
      FHandlers[N] := NODHandlers[I];
      Inc(N);
    end else
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: NOD key "%s" is not written to DXF %s (requires %s or newer)',
        [NODHandlers[I].Key, ACDWGVerName(AVersion),
         ACDWGVerName(NODHandlers[I].MinVersion)]);
  SetLength(FHandlers, N);
  SetLength(FDictHandles, N);
  SetLength(FTemplateDictHandles, N);
  SetLength(FNODEntryInserted, N);
  for I := 0 to N - 1 do begin
    FDictHandles[I] := 0;
    FTemplateDictHandles[I] := 0;
    FNODEntryInserted[I] := False;
  end;
  FTemplateBranch := TDictionary<TDWGHandle, Integer>.Create;
end;

destructor TZNODSaveSession.Destroy;
begin
  FPreservedHandles.Free;
  FTemplateNODKeys.Free;
  FTemplateBranch.Free;
  inherited Destroy;
end;

function TZNODSaveSession.GetCount: Integer;
begin
  Result := Length(FHandlers);
end;

function TZNODSaveSession.GetHandler(AIndex: Integer): TZNODHandler;
begin
  Result := FHandlers[AIndex];
end;

function TZNODSaveSession.GetDictHandle(AIndex: Integer): TDWGHandle;
begin
  Result := FDictHandles[AIndex];
end;

function TZNODSaveSession.GetTemplateDictHandle(AIndex: Integer): TDWGHandle;
begin
  Result := FTemplateDictHandles[AIndex];
end;

function TZNODSaveSession.GetPreservedWritten(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex <= High(FPreservedWritten)) and
    FPreservedWritten[AIndex];
end;

function TZNODSaveSession.HasPreservedBranches: Boolean;
begin
  Result := (FPreserved <> nil) and (FPreserved.BranchCount > 0);
end;

procedure TZNODSaveSession.SelectPreservedBranches;
var
  I: Integer;
  Key: string;
begin
  if not HasPreservedBranches then
    Exit;
  for I := 0 to FPreserved.BranchCount - 1 do begin
    Key := FPreserved.Branches[I].Key;
    FPreservedWritten[I] := False;
    if FTemplateNODHandle = 0 then
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: template has no NOD, preserved key "%s" is not written',
        [Key])
    else if FTemplateNODKeys.IndexOf(Key) >= 0 then
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: preserved key "%s" exists in template NOD, template branch is written',
        [Key])
    else if IndexOfNODHandler(Key) >= 0 then
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: preserved key "%s" has a handler now, not written',
        [Key])
    else begin
      FPreservedWritten[I] := True;
      NODLogTraceFormatStr(
        'uzeffdxfnodregistry: save: preserved key "%s" is written', [Key]);
    end;
  end;
end;

{ Является ли код группы ссылкой на хэндл (те же коды, что перемапливает
  savedxf20XX, кроме собственного хэндла 5) }
function IsHandleRefGroupCode(ACode: Integer): Boolean;
begin
  case ACode of
    320, 330, 340, 350, 360, 390, 105, 1005:
      Result := True;
  else
    Result := False;
  end;
end;

procedure TZNODSaveSession.BuildTemplateBranches(AModel: TZNODModel);
var
  I, J, K, Owner: Integer;
  Entry: TZDXFDictEntry;
  Obj: TZDXFRawObject;
  Dict: TZDXFDictionary;
  Changed: Boolean;
  Ref: TDWGHandle;
  Refs: TDictionary<TDWGHandle, Boolean>;

  { Добавляет хэндл в ветку обработчика AIndex; True — добавлен впервые.
    NOD и 0 в ветку не входят никогда. }
  function AddToBranch(AHandle: TDWGHandle; AIndex: Integer): Boolean;
  begin
    Result := (AHandle <> 0) and (AHandle <> FTemplateNODHandle) and
      not FTemplateBranch.ContainsKey(AHandle);
    if Result then
      FTemplateBranch.Add(AHandle, AIndex);
  end;

  { Ключ объекта AHandle в словаре его ветки ('' — не найден) }
  function BranchKeyOf(AHandle: TDWGHandle): string;
  var
    D: TZDXFDictionary;
    E: Integer;
  begin
    Result := '';
    for D in AModel.Dictionaries do
      if FTemplateBranch.ContainsKey(D.Handle) then
        for E := 0 to D.Count - 1 do
          if D[E].TargetHandle = AHandle then
            Exit(D[E].Key);
  end;

begin
  FTemplateBranch.Clear;
  SetLength(FTemplateRefs, 0);
  if AModel.NOD = nil then
    Exit;
  { Корни веток — словари по ключам обработчиков в NOD шаблона }
  for I := 0 to High(FHandlers) do
    if AModel.NOD.FindEntry(FHandlers[I].Key, Entry) then begin
      FTemplateDictHandles[I] := Entry.TargetHandle;
      AddToBranch(Entry.TargetHandle, I);
    end;
  { Замыкание: записи словарей ветки, расширенные словари объектов ветки и
    объекты, владелец которых (330) — объект ветки }
  repeat
    Changed := False;
    for Obj in AModel.Objects do begin
      if FTemplateBranch.TryGetValue(Obj.Handle, K) then begin
        if AddToBranch(Obj.XDictHandle, K) then
          Changed := True;
        Dict := AModel.FindDictionary(Obj.Handle);
        if Dict <> nil then
          for J := 0 to Dict.Count - 1 do
            if AddToBranch(Dict[J].TargetHandle, K) then
              Changed := True;
      end else if Obj.HasOwnerGroup and
         FTemplateBranch.TryGetValue(Obj.OwnerHandle, Owner) then
        if AddToBranch(Obj.Handle, Owner) then
          Changed := True;
    end;
  until not Changed;
  { Ссылки на объекты веток из остальных объектов шаблона (ссылка NOD на
    словарь-ветку — тоже: она перемапится на новый словарь) }
  Refs := TDictionary<TDWGHandle, Boolean>.Create;
  try
    for Obj in AModel.Objects do begin
      if FTemplateBranch.ContainsKey(Obj.Handle) then
        Continue;
      for J := 0 to Obj.PairCount - 1 do
        if IsHandleRefGroupCode(Obj.Pairs[J].Code) and
           TryDXFStrToHandle(Trim(Obj.Pairs[J].Value), Ref) and
           FTemplateBranch.TryGetValue(Ref, K) and
           not Refs.ContainsKey(Ref) then begin
          Refs.Add(Ref, True);
          I := Length(FTemplateRefs);
          SetLength(FTemplateRefs, I + 1);
          FTemplateRefs[I].Handle := Ref;
          FTemplateRefs[I].HandlerIndex := K;
          FTemplateRefs[I].Name := BranchKeyOf(Ref);
          NODLogTraceFormatStr(
            'uzeffdxfnodregistry: save: template %s %s refers to %s ("%s") of key "%s" branch',
            [Obj.ObjType, Obj.HandleStr, DXFHandleToStr(Ref),
             FTemplateRefs[I].Name, FHandlers[K].Key]);
        end;
    end;
  finally
    Refs.Free;
  end;
  for I := 0 to High(FHandlers) do
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: save: template key "%s": dictionary %s',
      [FHandlers[I].Key, DXFHandleToStr(FTemplateDictHandles[I])]);
  NODLogTraceFormatStr(
    'uzeffdxfnodregistry: save: template branches: %d objects, %d external references',
    [FTemplateBranch.Count, Length(FTemplateRefs)]);
end;

function TZNODSaveSession.LoadTemplate(const ATemplateFileName: string): Boolean;
begin
  FTemplateNODHandle := 0;
  if (Count = 0) and not HasPreservedBranches then
    Exit(False);
  try
    Result := LoadTemplateText(ReadDXFObjectsSectionText(ATemplateFileName));
  except
    on E: Exception do begin
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: template "%s": %s: %s',
        [ATemplateFileName, E.ClassName, E.Message]);
      Result := False;
    end;
  end;
  if not Result then
    NODLogWarningFormatStr(
      'uzeffdxfnodregistry: save: template "%s" has no NOD',
      [ATemplateFileName]);
end;

function TZNODSaveSession.LoadTemplateText(const AObjectsSection: string): Boolean;
var
  Model: TZNODModel;
  I: Integer;
begin
  FTemplateNODHandle := 0;
  FTemplateBranch.Clear;
  SetLength(FTemplateRefs, 0);
  for I := 0 to High(FTemplateDictHandles) do
    FTemplateDictHandles[I] := 0;
  FTemplateNODKeys.Clear;
  for I := 0 to High(FPreservedWritten) do
    FPreservedWritten[I] := False;
  if (Count = 0) and not HasPreservedBranches then
    Exit(False);
  Model := TZNODModel.Create;
  try
    if not Model.LoadFromText(AObjectsSection) then
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: template OBJECTS parse error: %s',
        [Model.ParseError]);
    if Model.NOD <> nil then begin
      FTemplateNODHandle := Model.NOD.Handle;
      for I := 0 to Model.NOD.Count - 1 do
        FTemplateNODKeys.Add(Model.NOD[I].Key);
    end;
    BuildTemplateBranches(Model);
  finally
    Model.Free;
  end;
  SelectPreservedBranches;
  Result := FTemplateNODHandle <> 0;
  if Result then
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: save: template NOD %s',
      [DXFHandleToStr(FTemplateNODHandle)]);
end;

procedure TZNODSaveSession.ReserveHandles(var ADrawing: TSimpleDrawing;
  var AIODXFContext: TIODXFSaveContext);
var
  I: Integer;
begin
  if FHandlesReserved then
    Exit;
  FHandlesReserved := True;
  for I := 0 to High(FHandlers) do
    if Assigned(FHandlers[I].ReserveHandlesProc) then begin
      FDictHandles[I] := FHandlers[I].ReserveHandlesProc(ADrawing, AIODXFContext);
      NODLogTraceFormatStr(
        'uzeffdxfnodregistry: save: key "%s": dictionary handle %s',
        [FHandlers[I].Key, DXFHandleToStr(FDictHandles[I])]);
    end;
  { Этап 7: новые хэндлы объектов записываемых сохранённых веток }
  if HasPreservedBranches then begin
    FPreservedHandles.Clear;
    for I := 0 to FPreserved.ObjectCount - 1 do
      if FPreservedWritten[FPreserved.ObjectBranch[I]] then begin
        FPreservedHandles.AddOrSetValue(FPreserved.Objects[I].Handle,
          AIODXFContext.handle);
        Inc(AIODXFContext.handle);
      end;
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: save: preserved branches: %d objects get new handles',
      [FPreservedHandles.Count]);
  end;
end;

function TZNODSaveSession.PreservedNewHandle(ASourceHandle: TDWGHandle): TDWGHandle;
begin
  if not FPreservedHandles.TryGetValue(ASourceHandle, Result) then
    Result := 0;
end;

procedure NODPairOut(var AOutStream: TZctnrVectorBytes; ACode: Integer;
  const AValue: string);
begin
  AOutStream.TXTAddStringEOL(dxfGroupCode(ACode));
  AOutStream.TXTAddStringEOL(AValue);
end;

function TZNODSaveSession.ResolvePreservedRef(ABranch: Integer;
  AHandle: TDWGHandle; ANODHandle: TDWGHandle;
  var AIODXFContext: TIODXFSaveContext; out ANewHandle: TDWGHandle): Boolean;
var
  R: TZNODPreservedRef;
  I, K: Integer;
begin
  ANewHandle := 0;
  if AHandle = 0 then
    Exit(True);
  if FPreservedHandles.TryGetValue(AHandle, ANewHandle) then
    Exit(True);
  if AHandle = FPreserved.Branches[ABranch].SourceNODHandle then begin
    ANewHandle := ANODHandle;
    Exit(ANewHandle <> 0);
  end;
  Result := False;
  if not FPreserved.FindRef(AHandle, R) then
    Exit;
  K := -1;
  for I := 0 to High(FHandlers) do
    if SameText(FHandlers[I].Key, R.HandlerKey) then begin
      K := I;
      Break;
    end;
  if (K < 0) or (FDictHandles[K] = 0) then
    Exit;
  if R.Name = '' then
    ANewHandle := FDictHandles[K]
  else if Assigned(FHandlers[K].FindObjectHandleProc) then begin
    ANewHandle := FHandlers[K].FindObjectHandleProc(R.Name, AIODXFContext);
    if (ANewHandle = 0) and (FHandlers[K].DefaultName <> '') then
      ANewHandle := FHandlers[K].FindObjectHandleProc(
        FHandlers[K].DefaultName, AIODXFContext);
  end;
  Result := ANewHandle <> 0;
end;

procedure TZNODSaveSession.WritePreservedObject(var AOutStream: TZctnrVectorBytes;
  AObjIndex: Integer; var AIODXFContext: TIODXFSaveContext;
  ANODHandle: TDWGHandle);
var
  Obj: TZDXFRawObject;
  B, J, K, Last: Integer;
  Key, V, BlockName: string;
  IsDict, HandleWritten: Boolean;
  Kept: TZDXFGroupPairs;
  KeptCount: Integer;

  { Значение ссылки AValue (группа ACode): новый хэндл; ссылка на объект,
    которого нет в новом файле, — '0' с предупреждением (AResolved = False) }
  function RefValue(ACode: Integer; const AValue: string;
    out AResolved: Boolean): string;
  var
    H, NewH: TDWGHandle;
  begin
    AResolved := True;
    if not TryDXFStrToHandle(Trim(AValue), H) then
      Exit(dxfEnCodeString(AValue, AIODXFContext.Header));
    AResolved := ResolvePreservedRef(B, H, ANODHandle, AIODXFContext, NewH);
    if AResolved then
      Result := IntToHex(NewH, 0)
    else
      Result := '0';
  end;

  procedure WarnUnresolved(ACode: Integer; const AValue, AAction: string);
  begin
    NODLogWarningFormatStr(
      'uzeffdxfnodregistry: save: key "%s": %s %s refers to %s (group %d), which is not in the file; %s',
      [Key, Obj.ObjType, Obj.HandleStr, Trim(AValue), ACode, AAction]);
  end;

  procedure OutPair(ACode: Integer; const AValue: string);
  var
    Resolved: Boolean;
    S: string;
  begin
    if IsNODPreservedRefGroupCode(ACode) then begin
      S := RefValue(ACode, AValue, Resolved);
      if not Resolved then
        WarnUnresolved(ACode, AValue, 'written as 0');
      NODPairOut(AOutStream, ACode, S);
    end else
      NODPairOut(AOutStream, ACode, dxfEnCodeString(AValue, AIODXFContext.Header));
  end;

var
  Resolved: Boolean;
  S: string;
begin
  Obj := FPreserved.Objects[AObjIndex];
  B := FPreserved.ObjectBranch[AObjIndex];
  Key := FPreserved.Branches[B].Key;
  IsDict := IsDXFDictionaryObjType(Obj.ObjType);
  HandleWritten := False;
  NODPairOut(AOutStream, 0, Obj.ObjType);
  J := 0;
  while J < Obj.PairCount do begin
    { Собственный хэндл }
    if (Obj.Pairs[J].Code = 5) and not HandleWritten then begin
      HandleWritten := True;
      NODPairOut(AOutStream, 5, IntToHex(PreservedNewHandle(Obj.Handle), 0));
      Inc(J);
      Continue;
    end;
    { Блоки реакторов и расширенного словаря: ссылки на объекты, которых
      нет в новом файле, удаляются; пустой блок не пишется }
    if Obj.Pairs[J].Code = 102 then begin
      V := Trim(Obj.Pairs[J].Value);
      BlockName := UpperCase(Trim(Copy(V, 2, Length(V) - 1)));
      if (V <> '') and (V[1] = '{') and
         ((BlockName = CDXFReactorsBlockName) or
          (BlockName = CDXFXDictionaryBlockName)) then begin
        Last := -1;
        for K := J + 1 to Obj.PairCount - 1 do
          if Obj.Pairs[K].Code = 102 then begin
            if Trim(Obj.Pairs[K].Value) = '}' then
              Last := K;
            Break;
          end;
        if Last > 0 then begin
          SetLength(Kept, Last - J - 1);
          KeptCount := 0;
          for K := J + 1 to Last - 1 do begin
            if IsNODPreservedRefGroupCode(Obj.Pairs[K].Code) then begin
              S := RefValue(Obj.Pairs[K].Code, Obj.Pairs[K].Value, Resolved);
              if not Resolved or (S = '0') then begin
                WarnUnresolved(Obj.Pairs[K].Code, Obj.Pairs[K].Value,
                  'removed from ' + V);
                Continue;
              end;
            end else
              S := dxfEnCodeString(Obj.Pairs[K].Value, AIODXFContext.Header);
            Kept[KeptCount].Code := Obj.Pairs[K].Code;
            Kept[KeptCount].Value := S;
            Inc(KeptCount);
          end;
          if KeptCount > 0 then begin
            NODPairOut(AOutStream, 102, Obj.Pairs[J].Value);
            for K := 0 to KeptCount - 1 do
              NODPairOut(AOutStream, Kept[K].Code, Kept[K].Value);
            NODPairOut(AOutStream, 102, Obj.Pairs[Last].Value);
          end;
          J := Last + 1;
          Continue;
        end;
      end;
    end;
    { Запись словаря 3 + 350/360 на объект, которого нет в новом файле, —
      удаляется целиком }
    if IsDict and (Obj.Pairs[J].Code = 3) and (J + 1 < Obj.PairCount) and
       ((Obj.Pairs[J + 1].Code = 350) or (Obj.Pairs[J + 1].Code = 360)) then begin
      S := RefValue(Obj.Pairs[J + 1].Code, Obj.Pairs[J + 1].Value, Resolved);
      if not Resolved or (S = '0') then
        WarnUnresolved(Obj.Pairs[J + 1].Code, Obj.Pairs[J + 1].Value,
          'dictionary entry "' + Obj.Pairs[J].Value + '" removed')
      else begin
        OutPair(3, Obj.Pairs[J].Value);
        NODPairOut(AOutStream, Obj.Pairs[J + 1].Code, S);
      end;
      Inc(J, 2);
      Continue;
    end;
    OutPair(Obj.Pairs[J].Code, Obj.Pairs[J].Value);
    Inc(J);
  end;
end;

procedure TZNODSaveSession.WriteClasses(var AOutStream: TZctnrVectorBytes;
  var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext);
var
  I, J, N: Integer;
  C: TZDXFRawObject;
  Name: string;
begin
  for I := 0 to High(FHandlers) do
    if Assigned(FHandlers[I].ClassesProc) then
      FHandlers[I].ClassesProc(AOutStream, ADrawing, AIODXFContext);
  if not HasPreservedBranches then
    Exit;
  { Этап 7: классы объектов сохранённых веток, которые реально пишутся и
    которых нет в CLASSES шаблона. Группа 91 (число экземпляров) — с DXF
    2004. }
  for I := 0 to FPreserved.ClassCount - 1 do begin
    C := FPreserved.Classes[I];
    Name := Trim(C.ValueOf(1));
    N := 0;
    for J := 0 to FPreserved.ObjectCount - 1 do
      if FPreservedWritten[FPreserved.ObjectBranch[J]] and
         SameText(FPreserved.Objects[J].ObjType, Name) then
        Inc(N);
    if N = 0 then
      Continue;
    if (AIODXFContext.TemplateClassNames <> nil) and
       (AIODXFContext.TemplateClassNames.IndexOf(Name) >= 0) then
      Continue;
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: save: class "%s" of preserved objects (%d)', [Name, N]);
    NODPairOut(AOutStream, 0, 'CLASS');
    NODPairOut(AOutStream, 1, Name);
    NODPairOut(AOutStream, 2, Trim(C.ValueOf(2)));
    NODPairOut(AOutStream, 3, dxfEnCodeString(C.ValueOf(3), AIODXFContext.Header));
    NODPairOut(AOutStream, 90, Trim(C.ValueOf(90, '0')));
    if AIODXFContext.Header.Version >= AC1018 then
      NODPairOut(AOutStream, 91, IntToStr(N));
    NODPairOut(AOutStream, 280, Trim(C.ValueOf(280, '0')));
    NODPairOut(AOutStream, 281, Trim(C.ValueOf(281, '0')));
  end;
end;

procedure TZNODSaveSession.GetPreservedXDataAppNames(AList: TStrings);
var
  I, J: Integer;
  Obj: TZDXFRawObject;
  Name: string;
begin
  if not HasPreservedBranches then
    Exit;
  for I := 0 to FPreserved.ObjectCount - 1 do begin
    if not FPreservedWritten[FPreserved.ObjectBranch[I]] then
      Continue;
    Obj := FPreserved.Objects[I];
    for J := 0 to Obj.PairCount - 1 do
      if Obj.Pairs[J].Code = 1001 then begin
        Name := Trim(Obj.Pairs[J].Value);
        if (Name <> '') and (AList.IndexOf(Name) < 0) then
          AList.Add(Name);
      end;
  end;
end;

procedure TZNODSaveSession.WriteObjects(var AOutStream: TZctnrVectorBytes;
  var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext;
  ANODHandle: TDWGHandle);
var
  I: Integer;
begin
  if FObjectsWritten then
    Exit;
  FObjectsWritten := True;
  ReserveHandles(ADrawing, AIODXFContext);
  for I := 0 to High(FHandlers) do
    if Assigned(FHandlers[I].SaveProc) then begin
      NODLogTraceFormatStr(
        'uzeffdxfnodregistry: save: key "%s": objects (dictionary %s, NOD %s)',
        [FHandlers[I].Key, DXFHandleToStr(FDictHandles[I]),
         DXFHandleToStr(ANODHandle)]);
      FHandlers[I].SaveProc(AOutStream, ADrawing, AIODXFContext,
        FDictHandles[I], ANODHandle);
    end;
  { Этап 7: сохранённые ветки — после веток обработчиков }
  if HasPreservedBranches then begin
    if ANODHandle = 0 then
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: NOD handle is unknown, owners of preserved branches are written as 0', []);
    for I := 0 to FPreserved.ObjectCount - 1 do
      if FPreservedWritten[FPreserved.ObjectBranch[I]] then
        WritePreservedObject(AOutStream, I, AIODXFContext, ANODHandle);
  end;
end;

procedure TZNODSaveSession.MapTemplateHandles(AMap: TMapHandleToHandle;
  var AIODXFContext: TIODXFSaveContext);

  procedure MapHandle(AOld, ANew: TDWGHandle; const AKey: string);
  var
    Prev: TDWGHandle;
  begin
    if AMap.TryGetValue(AOld, Prev) and (Prev <> ANew) then
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: key "%s": template handle %s was already mapped to %s, remapped to %s',
        [AKey, DXFHandleToStr(AOld), DXFHandleToStr(Prev), DXFHandleToStr(ANew)]);
    AMap.AddOrSetValue(AOld, ANew);
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: save: key "%s": template %s -> %s',
      [AKey, DXFHandleToStr(AOld), DXFHandleToStr(ANew)]);
  end;

var
  I, K: Integer;
  NewHandle: TDWGHandle;
  H: TZNODHandler;
begin
  if FTemplateHandlesMapped or not FHandlesReserved then
    Exit;
  FTemplateHandlesMapped := True;
  for I := 0 to High(FHandlers) do
    if FDictHandles[I] <> 0 then begin
      if FTemplateDictHandles[I] <> 0 then
        MapHandle(FTemplateDictHandles[I], FDictHandles[I], FHandlers[I].Key)
      else if FTemplateNODHandle = 0 then
        NODLogWarningFormatStr(
          'uzeffdxfnodregistry: save: key "%s": template has no NOD, dictionary %s is not referenced from NOD',
          [FHandlers[I].Key, DXFHandleToStr(FDictHandles[I])]);
    end;
  for I := 0 to High(FTemplateRefs) do begin
    K := FTemplateRefs[I].HandlerIndex;
    H := FHandlers[K];
    { Словарь-ветка уже перемаплен выше; ветка, которую обработчик не
      заменяет, копируется из шаблона как есть }
    if (FDictHandles[K] = 0) or
       (FTemplateRefs[I].Handle = FTemplateDictHandles[K]) then
      Continue;
    NewHandle := 0;
    if Assigned(H.FindObjectHandleProc) then begin
      if FTemplateRefs[I].Name <> '' then
        NewHandle := H.FindObjectHandleProc(FTemplateRefs[I].Name, AIODXFContext);
      if (NewHandle = 0) and (H.DefaultName <> '') then
        NewHandle := H.FindObjectHandleProc(H.DefaultName, AIODXFContext);
    end;
    if NewHandle <> 0 then
      MapHandle(FTemplateRefs[I].Handle, NewHandle, H.Key)
    else
      NODLogWarningFormatStr(
        'uzeffdxfnodregistry: save: key "%s": template object %s ("%s") is referenced outside the branch and has no replacement',
        [H.Key, DXFHandleToStr(FTemplateRefs[I].Handle), FTemplateRefs[I].Name]);
  end;
end;

function TZNODSaveSession.IsTemplateHandleSkipped(AHandle: TDWGHandle): Boolean;
var
  K: Integer;
begin
  Result := FTemplateBranch.TryGetValue(AHandle, K) and (FDictHandles[K] <> 0);
end;

function TZNODSaveSession.HasTemplateSkips: Boolean;
var
  I: Integer;
begin
  for I := 0 to High(FHandlers) do
    if (FDictHandles[I] <> 0) and (FTemplateDictHandles[I] <> 0) then
      Exit(True);
  Result := False;
end;

function TZNODSaveSession.TakeNODInsertions(const ANextKey: string): TZDXFDictEntries;
var
  I, N: Integer;
  E: TZDXFDictEntry;
  Res: TZDXFDictEntries;

  { Вставка с сохранением порядка по ключу }
  procedure Insert(const AEntry: TZDXFDictEntry);
  var
    J: Integer;
  begin
    J := N;
    while (J > 0) and (CompareText(Res[J - 1].Key, AEntry.Key) > 0) do begin
      Res[J] := Res[J - 1];
      Dec(J);
    end;
    Res[J] := AEntry;
    Inc(N);
    NODLogTraceFormatStr(
      'uzeffdxfnodregistry: save: NOD entry "%s" -> %s (%d) added',
      [AEntry.Key, DXFHandleToStr(AEntry.TargetHandle), AEntry.OwnershipCode]);
  end;

begin
  N := 0;
  Result := nil;
  if FTemplateNODHandle = 0 then
    Exit;
  SetLength(Res, Length(FHandlers) + Length(FPreservedWritten));
  for I := 0 to High(FHandlers) do
    if (FDictHandles[I] <> 0) and (FTemplateDictHandles[I] = 0) and
       not FNODEntryInserted[I] and
       ((ANextKey = '') or (CompareText(FHandlers[I].Key, ANextKey) < 0)) then begin
      FNODEntryInserted[I] := True;
      E.Key := FHandlers[I].Key;
      E.TargetHandle := FDictHandles[I];
      E.OwnershipCode := 350;
      Insert(E);
    end;
  { Этап 7: записываемые сохранённые ветки — с исходным кодом 350/360 }
  if HasPreservedBranches then
    for I := 0 to FPreserved.BranchCount - 1 do
      if FPreservedWritten[I] and not FPreservedInserted[I] and
         ((ANextKey = '') or
          (CompareText(FPreserved.Branches[I].Key, ANextKey) < 0)) then begin
        FPreservedInserted[I] := True;
        E.Key := FPreserved.Branches[I].Key;
        E.TargetHandle := PreservedNewHandle(FPreserved.Branches[I].RootHandle);
        E.OwnershipCode := FPreserved.Branches[I].OwnershipCode;
        if (E.OwnershipCode <> 350) and (E.OwnershipCode <> 360) then
          E.OwnershipCode := 350;
        if E.TargetHandle = 0 then
          Continue;
        Insert(E);
      end;
  SetLength(Res, N);
  Result := Res;
end;

end.
