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
  Модуль: uzestylesmleaderdxfnod
  Назначение: NOD-обработчик словаря ACAD_MLEADERSTYLE — чтение и запись
  стилей мультивыносок (MLEADERSTYLE) через реестр uzeffdxfnodregistry.
  ТЗ cad_source/zengine/TZ_NOD_NamedObjectDictionary.md, этап 6.

  Сущности MULTILEADER в ZCAD нет (мультивыноски читаются как прокси),
  стили хранятся в TSimpleDrawing.DXFMLeaderStyleTable, чтобы сохранить
  их без потерь.

  Чтение (LoadProc, DXF 2000+, до ENTITIES): каждая запись 3/350 словаря
  ACAD_MLEADERSTYLE — объект MLEADERSTYLE модели NOD, поля разбираются из
  его пар. Ссылки 340 (LTYPE), 341/343 (BLOCK_RECORD) и 342 (STYLE)
  переводятся в имена по индексу символьных таблиц модели
  (NeedsSymbolTables); исходные хэндлы тоже сохраняются. Группы тела,
  которые модель стиля не знает (например, 271-273 AutoCAD 2010+),
  хранятся в ExtraPairs и пишутся обратно. Объект стиля помечается
  «забранным» (его расширенный словарь тоже, записи словаря не
  переносятся — предупреждение в лог). Стиль с именем, которое уже есть в
  чертеже, не меняется.

  Значения по умолчанию (EnsureDefaultsProc, любая версия DXF): если после
  загрузки стилей нет — создаётся 'Standard' (параметры стиля Standard
  AutoCAD).

  Запись (DXF 2007+, MinVersion AC1021): ReserveHandlesProc — хэндлы
  словаря-ветки и стилей (стилей нет — ветка не пишется, как у стилей
  таблиц этапа 5). SaveProc — словарь-ветка и объекты;
  ссылки 340/341/342/343 перемапливаются по именам через
  LineTypeNameHandleMap, BlockNameHandleMap и TextStyleNameHandleMap.
  ClassesProc — класс MLEADERSTYLE, если его нет в шаблоне. Приложение
  расширенных данных ACAD_MLEADERVER регистрируется в APPID
  (XDataAppName).

  Детальная трасса — модуль лога NOD (lem NOD), выключен по умолчанию.
}
unit uzestylesmleaderdxfnod;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzeTypes,
  uzctnrVectorBytesStream,
  uzedrawingsimple,
  uzeffdxfsupport,
  uzeffdxfobjects,
  uzeffdxfnod,
  uzeffdxfnodregistry,
  uzestylesmleaderdxf;

const
  { Ключ NOD словаря стилей мультивыносок }
  CNODMLeaderStyleKey = 'ACAD_MLEADERSTYLE';
  { Тип объекта стиля мультивыноски }
  CDXFMLeaderStyleObjType = 'MLEADERSTYLE';
  { Имя класса C++ стиля мультивыноски (секция CLASSES, маркер 100) }
  CDXFMLeaderStyleClassName = 'AcDbMLeaderStyle';
  { Имя обязательного стиля мультивыноски }
  CDefaultMLeaderStyleName = 'Standard';
  { Приложение расширенных данных стиля (версия формата стиля) }
  CDXFMLeaderStyleXDataApp = 'ACAD_MLEADERVER';

{ Заполняет AStyle по парам объекта MLEADERSTYLE. Ссылки 340/341/342/343
  переводятся в имена по индексу символьных таблиц AModel (nil — только
  хэндлы). Блоки 102 и расширенные данные других приложений
  пропускаются; неизвестные группы тела (кроме ссылок) — в ExtraPairs. }
procedure ParseMLeaderStyleRawObject(AModel: TZNODModel; AObj: TZDXFRawObject;
  var AStyle: TGDBDXFMLeaderStyle);

{ Загружает стили словаря ADict (ветка ACAD_MLEADERSTYLE) в ATable и
  помечает забранными хэндлы объектов стилей и их расширенных словарей.
  Возвращает количество добавленных стилей. }
function LoadMLeaderStylesFromDictionary(AModel: TZNODModel;
  ADict: TZDXFDictionary; var ATable: GDBDXFMLeaderStyleArray): Integer;

{ То же по ключу ACAD_MLEADERSTYLE в NOD модели (0 — ключа нет) }
function LoadMLeaderStylesFromNOD(AModel: TZNODModel;
  var ATable: GDBDXFMLeaderStyleArray): Integer;

{ Параметры стиля Standard AutoCAD (AStyle уже init) }
procedure FillDefaultMLeaderStyle(var AStyle: TGDBDXFMLeaderStyle);

{ Если в ATable нет стилей — создаёт 'Standard' (FillDefaultMLeaderStyle)
  и возвращает его, иначе nil. }
function EnsureDefaultMLeaderStyle(
  var ATable: GDBDXFMLeaderStyleArray): PTGDBDXFMLeaderStyle;

{ Регистрирует NOD-обработчик ACAD_MLEADERSTYLE (вызывается в
  initialization модуля) }
procedure RegisterMLeaderStyleNODHandler;

implementation

uses
  SysUtils,
  gzctnrVectorTypes,
  usimplegenerics,
  uzeffdxfnodlog;

var
  { Формат вещественных чисел DXF: десятичная точка независимо от локали }
  DXFFormat: TFormatSettings;

{ === Чтение === }

{ Коды групп — ссылки на объекты (хэндлы): такие неизвестные группы не
  переносятся, их значения после сохранения указывали бы в никуда }
function IsHandleGroupCode(ACode: Integer): Boolean;
begin
  case ACode of
    105, 320..369, 390..399, 480..481, 1005:
      Result := True;
  else
    Result := False;
  end;
end;

function BoolOf(const AValue: string; ADefault: Boolean): Boolean;
var
  IntVal: Integer;
begin
  if TryStrToInt(AValue, IntVal) then
    Result := IntVal <> 0
  else
    Result := ADefault;
end;

{ Хэндл ссылки AValue: строка DXF (как в файле) и имя записи таблицы
  ATableType ('' — не найдена) }
procedure ResolveSymbolRef(AModel: TZNODModel; const AValue, ATableType,
  AStyleName: string; ACode: Integer; out AHandleStr, AName: string);
var
  H: TDWGHandle;
begin
  AName := '';
  AHandleStr := NormalizeDXFHandleStr(AValue);
  if not TryDXFStrToHandle(AValue, H) or (H = 0) then begin
    AHandleStr := '';
    Exit;
  end;
  if AModel = nil then
    Exit;
  if not AModel.FindSymbolName(H, ATableType, AName) then
    NODLogWarningFormatStr(
      'uzestylesmleaderdxfnod: style "%s": %d/%s is not a %s record',
      [AStyleName, ACode, AHandleStr, ATableType]);
end;

procedure ParseMLeaderStyleRawObject(AModel: TZNODModel; AObj: TZDXFRawObject;
  var AStyle: TGDBDXFMLeaderStyle);
var
  I, Code, IntVal, N: Integer;
  Value, RawValue, XDataApp: string;
  { Внутри блока 102 (реакторы, расширенный словарь) }
  In102: Boolean;
  { Расширенные данные (после первой группы 1001) }
  InXData: Boolean;
  { Заголовок объекта (до маркера подкласса 100) }
  InHeader: Boolean;
begin
  if AObj.XDictHandle <> 0 then
    AStyle.XDictHandle := DXFHandleToStr(AObj.XDictHandle);
  In102 := False;
  InXData := False;
  InHeader := True;
  XDataApp := '';
  AStyle.ExtraPairs := nil;
  for I := 0 to AObj.PairCount - 1 do begin
    Code := AObj.Pairs[I].Code;
    RawValue := AObj.Pairs[I].Value;
    Value := Trim(RawValue);
    if Code = 1001 then begin
      InXData := True;
      XDataApp := Value;
      if not SameText(XDataApp, CDXFMLeaderStyleXDataApp) then
        NODLogWarningFormatStr(
          'uzestylesmleaderdxfnod: style "%s": extended data of "%s" is not kept',
          [AStyle.Name, XDataApp]);
      Continue;
    end;
    if InXData then begin
      if (Code = 1070) and SameText(XDataApp, CDXFMLeaderStyleXDataApp) and
         TryStrToInt(Value, IntVal) then
        AStyle.MLeaderVersion := IntVal;
      Continue;
    end;
    if Code = 102 then begin
      In102 := (Value <> '') and (Value[1] = '{') and (Value <> '{}');
      Continue;
    end;
    if In102 then
      Continue;
    if InHeader then begin
      { 5 (хэндл) и 330 (владелец) заголовка пишутся заново }
      if Code = 100 then
        InHeader := False;
      Continue;
    end;
    case Code of
      100: ;
      170: AStyle.LeaderLineType := StrToIntDef(Value, AStyle.LeaderLineType);
      171: AStyle.LeaderLineTypeId := StrToIntDef(Value, AStyle.LeaderLineTypeId);
      172: AStyle.FirstSegAngleConstraint :=
             StrToIntDef(Value, AStyle.FirstSegAngleConstraint);
      173: AStyle.SecondSegAngleConstraint :=
             StrToIntDef(Value, AStyle.SecondSegAngleConstraint);
      174: AStyle.TextAttachmentLeft := StrToIntDef(Value, AStyle.TextAttachmentLeft);
      175: AStyle.TextAngleType := StrToIntDef(Value, AStyle.TextAngleType);
      176: AStyle.TextAlignmentType := StrToIntDef(Value, AStyle.TextAlignmentType);
      177: AStyle.TextAttachmentDirection :=
             StrToIntDef(Value, AStyle.TextAttachmentDirection);
      178: AStyle.TextAttachmentRight := StrToIntDef(Value, AStyle.TextAttachmentRight);
      90: AStyle.ContentType := StrToIntDef(Value, AStyle.ContentType);
      91: AStyle.LeaderLineColor := StrToIntDef(Value, AStyle.LeaderLineColor);
      92: AStyle.LeaderLineWeight := StrToIntDef(Value, AStyle.LeaderLineWeight);
      93: AStyle.TextColor := StrToIntDef(Value, AStyle.TextColor);
      94: AStyle.BlockContentColor := StrToIntDef(Value, AStyle.BlockContentColor);
      40: AStyle.FirstSegAngle := StrToFloatDef(Value, AStyle.FirstSegAngle, DXFFormat);
      41: AStyle.SecondSegAngle := StrToFloatDef(Value, AStyle.SecondSegAngle, DXFFormat);
      42: AStyle.DoglegLength := StrToFloatDef(Value, AStyle.DoglegLength, DXFFormat);
      43: AStyle.LandingGap := StrToFloatDef(Value, AStyle.LandingGap, DXFFormat);
      44: AStyle.TextHeight := StrToFloatDef(Value, AStyle.TextHeight, DXFFormat);
      45: AStyle.ArrowHeadSize := StrToFloatDef(Value, AStyle.ArrowHeadSize, DXFFormat);
      46: AStyle.BlockContentScale :=
            StrToFloatDef(Value, AStyle.BlockContentScale, DXFFormat);
      47: AStyle.BlockContentScaleX :=
            StrToFloatDef(Value, AStyle.BlockContentScaleX, DXFFormat);
      49: AStyle.BlockContentScaleY :=
            StrToFloatDef(Value, AStyle.BlockContentScaleY, DXFFormat);
      140: AStyle.OverallScale := StrToFloatDef(Value, AStyle.OverallScale, DXFFormat);
      141: AStyle.BreakGapSize := StrToFloatDef(Value, AStyle.BreakGapSize, DXFFormat);
      142: AStyle.BlockContentScaleZ :=
             StrToFloatDef(Value, AStyle.BlockContentScaleZ, DXFFormat);
      143: AStyle.BlockContentRotation :=
             StrToFloatDef(Value, AStyle.BlockContentRotation, DXFFormat);
      290: AStyle.EnableDogleg := BoolOf(Value, AStyle.EnableDogleg);
      291: AStyle.EnableLanding := BoolOf(Value, AStyle.EnableLanding);
      292: AStyle.TextAlignAlwaysLeft := BoolOf(Value, AStyle.TextAlignAlwaysLeft);
      293: AStyle.Annotative := BoolOf(Value, AStyle.Annotative);
      294: AStyle.TextDirectionNegative := BoolOf(Value, AStyle.TextDirectionNegative);
      295: AStyle.IsBlockContent := BoolOf(Value, AStyle.IsBlockContent);
      296: AStyle.IsMTextContent := BoolOf(Value, AStyle.IsMTextContent);
      297: AStyle.AlignSpace := BoolOf(Value, AStyle.AlignSpace);
      { Строки — как в файле (пробелы значимы) }
      3: AStyle.Description := RawValue;
      300: AStyle.DefaultTextContent := RawValue;
      340: ResolveSymbolRef(AModel, Value, 'LTYPE', AStyle.Name, Code,
             AStyle.LeaderLinetypeHandle, AStyle.LeaderLinetypeName);
      341: ResolveSymbolRef(AModel, Value, 'BLOCK_RECORD', AStyle.Name, Code,
             AStyle.ArrowHeadBlockHandle, AStyle.ArrowHeadBlockName);
      342: ResolveSymbolRef(AModel, Value, 'STYLE', AStyle.Name, Code,
             AStyle.TextStyleHandle, AStyle.TextStyleName);
      343: ResolveSymbolRef(AModel, Value, 'BLOCK_RECORD', AStyle.Name, Code,
             AStyle.BlockContentHandle, AStyle.BlockContentName);
    else
      if IsHandleGroupCode(Code) then
        NODLogTraceFormatStr(
          'uzestylesmleaderdxfnod: style "%s": reference %d/%s is not kept',
          [AStyle.Name, Code, Value])
      else begin
        N := Length(AStyle.ExtraPairs);
        SetLength(AStyle.ExtraPairs, N + 1);
        AStyle.ExtraPairs[N].Code := Code;
        AStyle.ExtraPairs[N].Value := RawValue;
        NODLogTraceFormatStr(
          'uzestylesmleaderdxfnod: style "%s": group %d/"%s" kept as is',
          [AStyle.Name, Code, RawValue]);
      end;
    end;
  end;
end;

{ Помечает забранным расширенный словарь стиля: при записи он не пишется,
  записи словаря не переносятся (в лог — предупреждение). }
procedure ClaimMLeaderStyleXDict(AModel: TZNODModel; AObj: TZDXFRawObject;
  const AStyleName: string);
var
  XDict: TZDXFDictionary;
  I: Integer;
begin
  if AObj.XDictHandle = 0 then
    Exit;
  XDict := AModel.FindDictionary(AObj.XDictHandle);
  if XDict = nil then begin
    NODLogTraceFormatStr(
      'uzestylesmleaderdxfnod: style "%s": extension dictionary %s not found',
      [AStyleName, DXFHandleToStr(AObj.XDictHandle)]);
    Exit;
  end;
  AModel.ClaimHandle(XDict.Handle);
  for I := 0 to XDict.Count - 1 do
    NODLogWarningFormatStr(
      'uzestylesmleaderdxfnod: style "%s": extension dictionary entry "%s" (%s) is not kept',
      [AStyleName, XDict[I].Key, DXFHandleToStr(XDict[I].TargetHandle)]);
end;

function LoadMLeaderStylesFromDictionary(AModel: TZNODModel;
  ADict: TZDXFDictionary; var ATable: GDBDXFMLeaderStyleArray): Integer;
var
  I: Integer;
  Entry: TZDXFDictEntry;
  Obj: TZDXFRawObject;
  Style: PTGDBDXFMLeaderStyle;
begin
  Result := 0;
  if (AModel = nil) or (ADict = nil) then
    Exit;
  for I := 0 to ADict.Count - 1 do begin
    Entry := ADict[I];
    Obj := AModel.FindObject(Entry.TargetHandle);
    if (Obj = nil) or not SameText(Obj.ObjType, CDXFMLeaderStyleObjType) then begin
      NODLogWarningFormatStr(
        'uzestylesmleaderdxfnod: %s/%s: %s is not a %s object, skipped',
        [CNODMLeaderStyleKey, Entry.Key, DXFHandleToStr(Entry.TargetHandle),
         CDXFMLeaderStyleObjType]);
      Continue;
    end;
    if Entry.Key = '' then begin
      NODLogWarningFormatStr(
        'uzestylesmleaderdxfnod: %s: %s %s without name, skipped',
        [CNODMLeaderStyleKey, CDXFMLeaderStyleObjType, Obj.HandleStr]);
      Continue;
    end;
    AModel.ClaimHandle(Obj.Handle);
    ClaimMLeaderStyleXDict(AModel, Obj, Entry.Key);
    if ATable.getAddres(Entry.Key) <> nil then begin
      { Стиль с таким именем уже есть (вставка/слияние чертежей или
        повтор имени в словаре) — существующий не меняется }
      NODLogTraceFormatStr(
        'uzestylesmleaderdxfnod: style "%s" (%s) already exists, kept',
        [Entry.Key, Obj.HandleStr]);
      Continue;
    end;
    Style := ATable.AddStyle(Entry.Key);
    if Style = nil then
      Continue;
    ParseMLeaderStyleRawObject(AModel, Obj, Style^);
    Inc(Result);
    NODLogTraceFormatStr(
      'uzestylesmleaderdxfnod: стиль мультивыноски "%s" загружен (хэндл %s)',
      [Style^.Name, Obj.HandleStr]);
  end;
end;

function LoadMLeaderStylesFromNOD(AModel: TZNODModel;
  var ATable: GDBDXFMLeaderStyleArray): Integer;
begin
  Result := 0;
  if AModel <> nil then
    Result := LoadMLeaderStylesFromDictionary(AModel,
      AModel.ResolveDictionary(CNODMLeaderStyleKey), ATable);
end;

procedure FillDefaultMLeaderStyle(var AStyle: TGDBDXFMLeaderStyle);
begin
  { Числовые параметры init совпадают со стилем Standard AutoCAD }
  AStyle.Description := CDefaultMLeaderStyleName;
  AStyle.LeaderLinetypeName := 'ByBlock';
  AStyle.TextStyleName := 'Standard';
end;

function EnsureDefaultMLeaderStyle(
  var ATable: GDBDXFMLeaderStyleArray): PTGDBDXFMLeaderStyle;
begin
  Result := nil;
  if ATable.Count > 0 then
    Exit;
  Result := ATable.AddStyle(CDefaultMLeaderStyleName);
  if Result = nil then
    Exit;
  FillDefaultMLeaderStyle(Result^);
  NODLogTraceFormatStr(
    'uzestylesmleaderdxfnod: стилей мультивыносок нет, создан "%s"',
    [CDefaultMLeaderStyleName]);
end;

{ LoadProc обработчика }
procedure MLeaderStyleNODLoad(const AModel: TZNODModel;
  const ADict: TZDXFDictionary; var ADrawing: TSimpleDrawing);
begin
  LoadMLeaderStylesFromDictionary(AModel, ADict, ADrawing.DXFMLeaderStyleTable);
end;

{ EnsureDefaultsProc обработчика }
procedure MLeaderStyleNODEnsureDefaults(var ADrawing: TSimpleDrawing);
begin
  EnsureDefaultMLeaderStyle(ADrawing.DXFMLeaderStyleTable);
end;

{ === Запись === }

{ Преобразует вещественное число в строку DXF с гарантией десятичной точки }
function DXFFloatStr(Value: Double): string;
begin
  Result := FloatToStr(Value, DXFFormat);
  if Pos('.', Result) = 0 then
    Result := Result + '.0';
end;

function DXFBoolStr(Value: Boolean): string;
begin
  if Value then
    Result := '1'
  else
    Result := '0';
end;

{ Пара «код/значение» в поток (сокращение для читаемости кода ниже) }
procedure dxfPairOut(var outstream: TZctnrVectorBytes;
                     const Code: Integer; const Value: string); inline;
begin
  outstream.TXTAddStringEOL(dxfGroupCode(Code));
  outstream.TXTAddStringEOL(Value);
end;

{ Новый хэндл записи таблицы по имени: сначала AName, затем запасные
  имена AFallbacks. '' — ни одно имя не найдено в AMap. }
function MapSymbolHandle(AMap: TString2StringDictionary; const AName: string;
  const AFallbacks: array of string): string;
var
  I: Integer;
begin
  Result := '';
  if (AName <> '') and AMap.MyGetValue(AName, Result) then
    Exit;
  for I := 0 to High(AFallbacks) do
    if AMap.MyGetValue(AFallbacks[I], Result) then
      Exit;
  Result := '';
end;

{ Записывает один объект MLEADERSTYLE (порядок групп — как у AutoCAD) }
procedure WriteMLeaderStyleObjectToStream(var outstream: TZctnrVectorBytes;
  const AStyle: TGDBDXFMLeaderStyle; AStyleHandle, AOwnerHandle: TDWGHandle;
  var AIODXFContext: TIODXFSaveContext);
var
  I: Integer;
  hs: string;

  { Ссылка на блок (341/343): группа пишется, только если имя блока
    задано и блок есть в сохраняемом файле }
  procedure BlockRefOut(ACode: Integer; const ABlockName: string);
  var
    bh: string;
  begin
    if ABlockName = '' then
      Exit;
    if AIODXFContext.BlockNameHandleMap.MyGetValue(ABlockName, bh) then
      dxfPairOut(outstream, ACode, bh)
    else
      NODLogWarningFormatStr(
        'uzestylesmleaderdxfnod: style "%s": block "%s" (%d) is not saved, reference dropped',
        [AStyle.Name, ABlockName, ACode]);
  end;

begin
  dxfPairOut(outstream, 0, CDXFMLeaderStyleObjType);
  dxfPairOut(outstream, 5, inttohex(AStyleHandle, 0));
  { Расширенный словарь стиля не переносится (ClaimMLeaderStyleXDict) —
    ссылку 360 на него не пишем }
  dxfPairOut(outstream, 102, '{ACAD_REACTORS');
  dxfPairOut(outstream, 330, inttohex(AOwnerHandle, 0));
  dxfPairOut(outstream, 102, '}');
  dxfPairOut(outstream, 330, inttohex(AOwnerHandle, 0));
  dxfPairOut(outstream, 100, CDXFMLeaderStyleClassName);
  dxfPairOut(outstream, 170, IntToStr(AStyle.LeaderLineType));
  dxfPairOut(outstream, 171, IntToStr(AStyle.LeaderLineTypeId));
  dxfPairOut(outstream, 172, IntToStr(AStyle.FirstSegAngleConstraint));
  dxfPairOut(outstream, 90, IntToStr(AStyle.ContentType));
  dxfPairOut(outstream, 40, DXFFloatStr(AStyle.FirstSegAngle));
  dxfPairOut(outstream, 41, DXFFloatStr(AStyle.SecondSegAngle));
  dxfPairOut(outstream, 173, IntToStr(AStyle.SecondSegAngleConstraint));
  dxfPairOut(outstream, 91, IntToStr(AStyle.LeaderLineColor));
  { 340 — тип линии выноски; нет в файле — ByBlock (как у Standard) }
  hs := MapSymbolHandle(AIODXFContext.LineTypeNameHandleMap,
    AStyle.LeaderLinetypeName, ['ByBlock', 'Continuous']);
  if (hs <> '') and (AStyle.LeaderLinetypeName <> '') and
     not AIODXFContext.LineTypeNameHandleMap.MyContans(AStyle.LeaderLinetypeName) then
    NODLogWarningFormatStr(
      'uzestylesmleaderdxfnod: style "%s": linetype "%s" is not saved, 340 -> %s',
      [AStyle.Name, AStyle.LeaderLinetypeName, hs]);
  if hs = '' then
    hs := '0';
  dxfPairOut(outstream, 340, hs);
  dxfPairOut(outstream, 92, IntToStr(AStyle.LeaderLineWeight));
  dxfPairOut(outstream, 290, DXFBoolStr(AStyle.EnableDogleg));
  dxfPairOut(outstream, 42, DXFFloatStr(AStyle.DoglegLength));
  dxfPairOut(outstream, 291, DXFBoolStr(AStyle.EnableLanding));
  dxfPairOut(outstream, 43, DXFFloatStr(AStyle.LandingGap));
  dxfPairOut(outstream, 3, AStyle.Description);
  BlockRefOut(341, AStyle.ArrowHeadBlockName);
  dxfPairOut(outstream, 44, DXFFloatStr(AStyle.TextHeight));
  dxfPairOut(outstream, 300, AStyle.DefaultTextContent);
  { 342 — текстовый стиль; нет в файле — Standard }
  hs := MapSymbolHandle(AIODXFContext.TextStyleNameHandleMap,
    AStyle.TextStyleName, ['Standard']);
  if (hs <> '') and (AStyle.TextStyleName <> '') and
     not AIODXFContext.TextStyleNameHandleMap.MyContans(AStyle.TextStyleName) then
    NODLogWarningFormatStr(
      'uzestylesmleaderdxfnod: style "%s": text style "%s" is not saved, 342 -> %s',
      [AStyle.Name, AStyle.TextStyleName, hs]);
  if hs = '' then
    hs := '0';
  dxfPairOut(outstream, 342, hs);
  dxfPairOut(outstream, 174, IntToStr(AStyle.TextAttachmentLeft));
  dxfPairOut(outstream, 178, IntToStr(AStyle.TextAttachmentRight));
  dxfPairOut(outstream, 175, IntToStr(AStyle.TextAngleType));
  dxfPairOut(outstream, 176, IntToStr(AStyle.TextAlignmentType));
  dxfPairOut(outstream, 93, IntToStr(AStyle.TextColor));
  dxfPairOut(outstream, 45, DXFFloatStr(AStyle.ArrowHeadSize));
  dxfPairOut(outstream, 292, DXFBoolStr(AStyle.TextAlignAlwaysLeft));
  dxfPairOut(outstream, 297, DXFBoolStr(AStyle.AlignSpace));
  dxfPairOut(outstream, 46, DXFFloatStr(AStyle.BlockContentScale));
  BlockRefOut(343, AStyle.BlockContentName);
  dxfPairOut(outstream, 94, IntToStr(AStyle.BlockContentColor));
  dxfPairOut(outstream, 47, DXFFloatStr(AStyle.BlockContentScaleX));
  dxfPairOut(outstream, 49, DXFFloatStr(AStyle.BlockContentScaleY));
  dxfPairOut(outstream, 140, DXFFloatStr(AStyle.OverallScale));
  dxfPairOut(outstream, 293, DXFBoolStr(AStyle.Annotative));
  dxfPairOut(outstream, 141, DXFFloatStr(AStyle.BreakGapSize));
  dxfPairOut(outstream, 294, DXFBoolStr(AStyle.TextDirectionNegative));
  dxfPairOut(outstream, 177, IntToStr(AStyle.TextAttachmentDirection));
  dxfPairOut(outstream, 142, DXFFloatStr(AStyle.BlockContentScaleZ));
  dxfPairOut(outstream, 295, DXFBoolStr(AStyle.IsBlockContent));
  dxfPairOut(outstream, 296, DXFBoolStr(AStyle.IsMTextContent));
  dxfPairOut(outstream, 143, DXFFloatStr(AStyle.BlockContentRotation));
  { Группы, которые модель стиля не разбирает — в исходном порядке }
  for I := 0 to High(AStyle.ExtraPairs) do
    dxfPairOut(outstream, AStyle.ExtraPairs[I].Code, AStyle.ExtraPairs[I].Value);
  dxfPairOut(outstream, 1001, CDXFMLeaderStyleXDataApp);
  dxfPairOut(outstream, 1070, IntToStr(AStyle.MLeaderVersion));
  NODLogTraceFormatStr(
    'uzestylesmleaderdxfnod: MLEADERSTYLE "%s" written, handle %s',
    [AStyle.Name, inttohex(AStyleHandle, 0)]);
end;

{ Хэндлы, выделенные ReserveHandlesProc, хранятся до SaveProc того же
  сохранения (savedxf20XX не реентерабельна). }
var
  MLSNODStyles: array of PTGDBDXFMLeaderStyle;
  MLSNODHandles: array of TDWGHandle;
  { Имя стиля → новый хэндл (FindObjectHandleProc) }
  MLSNODNameHandleMap: TString2StringDictionary;

function MLeaderStyleNODReserveHandles(var ADrawing: TSimpleDrawing;
  var AIODXFContext: TIODXFSaveContext): TDWGHandle;
var
  style: PTGDBDXFMLeaderStyle;
  iter: itrec;
  n: Integer;
begin
  SetLength(MLSNODStyles, 0);
  SetLength(MLSNODHandles, 0);
  MLSNODNameHandleMap.Clear;
  if ADrawing.DXFMLeaderStyleTable.Count = 0 then
    Exit(0);
  { Словарь-ветка, затем по хэндлу на каждый стиль }
  Result := AIODXFContext.handle;
  Inc(AIODXFContext.handle);
  SetLength(MLSNODStyles, ADrawing.DXFMLeaderStyleTable.Count);
  SetLength(MLSNODHandles, Length(MLSNODStyles));
  n := 0;
  style := ADrawing.DXFMLeaderStyleTable.beginiterate(iter);
  while (style <> nil) and (n < Length(MLSNODStyles)) do begin
    if MLSNODNameHandleMap.MyContans(style^.Name) then
      NODLogWarningFormatStr(
        'uzestylesmleaderdxfnod: multileader style "%s" is duplicated, skipped',
        [style^.Name])
    else begin
      MLSNODStyles[n] := style;
      MLSNODHandles[n] := AIODXFContext.handle;
      Inc(AIODXFContext.handle);
      MLSNODNameHandleMap.Add(style^.Name, inttohex(MLSNODHandles[n], 0));
      Inc(n);
    end;
    style := ADrawing.DXFMLeaderStyleTable.iterate(iter);
  end;
  SetLength(MLSNODStyles, n);
  SetLength(MLSNODHandles, n);
  NODLogTraceFormatStr(
    'uzestylesmleaderdxfnod: выделены хэндлы для %d стилей мультивыносок (словарь %s)',
    [Length(MLSNODStyles), inttohex(Result, 0)]);
end;

procedure MLeaderStyleNODSave(var AOutStream: TZctnrVectorBytes;
  var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext;
  ADictHandle, ANODHandle: TDWGHandle);
var
  i: Integer;
begin
  if ADictHandle = 0 then
    Exit;
  if ANODHandle = 0 then
    NODLogWarningFormatStr(
      'uzestylesmleaderdxfnod: ACAD_MLEADERSTYLE dictionary %s is written without NOD',
      [inttohex(ADictHandle, 0)]);
  { Словарь-ветка — как у AutoCAD: владелец и реактор — NOD }
  dxfPairOut(AOutStream, 0, 'DICTIONARY');
  dxfPairOut(AOutStream, 5, inttohex(ADictHandle, 0));
  dxfPairOut(AOutStream, 102, '{ACAD_REACTORS');
  dxfPairOut(AOutStream, 330, inttohex(ANODHandle, 0));
  dxfPairOut(AOutStream, 102, '}');
  dxfPairOut(AOutStream, 330, inttohex(ANODHandle, 0));
  dxfPairOut(AOutStream, 100, 'AcDbDictionary');
  dxfPairOut(AOutStream, 281, '1');
  for i := 0 to High(MLSNODStyles) do begin
    dxfPairOut(AOutStream, 3, MLSNODStyles[i]^.Name);
    dxfPairOut(AOutStream, 350, inttohex(MLSNODHandles[i], 0));
  end;
  for i := 0 to High(MLSNODStyles) do
    WriteMLeaderStyleObjectToStream(AOutStream, MLSNODStyles[i]^,
      MLSNODHandles[i], ADictHandle, AIODXFContext);
  { Указатели на стили чертежа после записи не нужны }
  SetLength(MLSNODStyles, 0);
end;

{ Класс MLEADERSTYLE — если стили есть, а в CLASSES шаблона класса нет.
  Группа 91 (число экземпляров) — с DXF 2004. }
procedure MLeaderStyleNODClasses(var AOutStream: TZctnrVectorBytes;
  var ADrawing: TSimpleDrawing; var AIODXFContext: TIODXFSaveContext);
begin
  if ADrawing.DXFMLeaderStyleTable.Count = 0 then
    Exit;
  if AIODXFContext.TemplateClassNames.IndexOf(CDXFMLeaderStyleObjType) >= 0 then
    Exit;
  dxfPairOut(AOutStream, 0, 'CLASS');
  dxfPairOut(AOutStream, 1, CDXFMLeaderStyleObjType);
  dxfPairOut(AOutStream, 2, CDXFMLeaderStyleClassName);
  dxfPairOut(AOutStream, 3, 'ACDB_MLEADERSTYLE_CLASS');
  dxfPairOut(AOutStream, 90, '4095');
  if AIODXFContext.Header.Version >= AC1018 then
    dxfPairOut(AOutStream, 91, IntToStr(ADrawing.DXFMLeaderStyleTable.Count));
  dxfPairOut(AOutStream, 280, '0');
  dxfPairOut(AOutStream, 281, '0');
end;

{ Новый хэндл стиля мультивыноски по имени — для ссылок других объектов
  шаблона на пропущенные объекты ветки ACAD_MLEADERSTYLE шаблона }
function MLeaderStyleNODFindObjectHandle(const AName: string;
  var AIODXFContext: TIODXFSaveContext): TDWGHandle;
var
  hs: string;
begin
  Result := 0;
  if MLSNODNameHandleMap.MyGetValue(AName, hs) then
    Result := StrToQWord('$' + hs);
end;

procedure RegisterMLeaderStyleNODHandler;
var
  h: TZNODHandler;
begin
  h := Default(TZNODHandler);
  h.Key := CNODMLeaderStyleKey;
  h.ObjectType := CDXFMLeaderStyleObjType;
  { Стили мультивыносок появились в AutoCAD 2008 — пишутся в DXF 2007+ }
  h.MinVersion := AC1021;
  h.DefaultName := CDefaultMLeaderStyleName;
  h.LoadProc := MLeaderStyleNODLoad;
  h.ReserveHandlesProc := MLeaderStyleNODReserveHandles;
  h.SaveProc := MLeaderStyleNODSave;
  h.ClassesProc := MLeaderStyleNODClasses;
  h.FindObjectHandleProc := MLeaderStyleNODFindObjectHandle;
  h.EnsureDefaultsProc := MLeaderStyleNODEnsureDefaults;
  h.XDataAppName := CDXFMLeaderStyleXDataApp;
  h.NeedsSymbolTables := True;
  RegisterNODHandler(h);
end;

initialization
  DXFFormat := DefaultFormatSettings;
  DXFFormat.DecimalSeparator := '.';
  DXFFormat.ThousandSeparator := #0;
  MLSNODNameHandleMap := TString2StringDictionary.Create;
  RegisterMLeaderStyleNODHandler;
finalization
  MLSNODNameHandleMap.Free;
end.
