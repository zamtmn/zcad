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
  Модуль: uzedwgnod
  Назначение: Named Object Dictionary при загрузке DWG (этап 9 ТЗ
  cad_source/zengine/TZ_NOD_NamedObjectDictionary.md).

  Объекты DWG, разобранные LibreDWG, переводятся в те же сырые объекты
  TZDXFRawObject, что строит разбор секции OBJECTS DXF, и собираются в
  TZNODModel. Корневой словарь берётся из заголовка DWG
  (header_vars.DICTIONARY_NAMED_OBJECT). Дальше работают те же обработчики
  реестра NOD (RunNODLoadHandlers / RunNODEnsureDefaults), что и для DXF.

  Перевод «поле DWG → группа DXF» повторяет dwg.spec LibreDWG
  (секции DXF объектов DICTIONARY, ACDBDICTIONARYWDFLT, TABLESTYLE,
  MLEADERSTYLE):
  * DICTIONARY / ACDBDICTIONARYWDFLT — 280, 281, записи 3 → 350 (360 у
    словаря с is_hardowner), 340 у словаря со значением по умолчанию;
  * TABLESTYLE — 3, 70, 71, 40, 41, 280, 281 и три блока строк (7 — имя
    текстового стиля по индексу символьных таблиц, 140, 170, 62, 63, 283,
    границы 274–279, 284–289, 64–69). В R2010+ стиль таблицы хранится
    стилями ячеек, которые не переводятся (блоки строк в dwg.spec — только
    до R2007): для таких файлов переносится имя, направление LibreDWG
    теряет (70 = 0), остальное — значения по умолчанию;
  * MLEADERSTYLE — все группы подкласса AcDbMLeaderStyle; цвета 91/93/94 —
    упакованное значение AcCmEntityColor, ссылки 340–343 — хэндлы записей
    LTYPE, BLOCK_RECORD и STYLE.
  Остальные объекты (не сущности) попадают в модель заглушкой: тип, хэндл и
  владелец — этого достаточно для навигации по словарям и пометки
  «забранных» хэндлов. Ветки неизвестных ключей NOD из DWG не сохраняются
  (этап 7 работает по тексту DXF).

  Индекс символьных таблиц (ссылки MLEADERSTYLE и TABLESTYLE по хэндлам)
  строится по записям LTYPE, STYLE и BLOCK_HEADER (тип BLOCK_RECORD).
}
unit uzedwgnod;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$PointerMath on}

interface

uses
  SysUtils,
  dwg,
  uzeTypes,
  uzedrawingsimple,
  uzeffdxfobjects,
  uzeffdxfnod;

const
  { Тип записи символьной таблицы блоков в индексе модели (как в DXF) }
  CDWGNODBlockRecordTableType = 'BLOCK_RECORD';

{ Хэндл корневого словаря из заголовка DWG
  (header_vars.DICTIONARY_NAMED_OBJECT), 0 — ссылки нет }
function DWGHeaderNODHandle(const Raw: Dwg_Data): TDWGHandle;

{ Сырой объект для модели NOD по объекту DWG. AModel — индекс символьных
  таблиц для имён текстовых стилей TABLESTYLE (может быть nil).
  nil — сущность или объект без данных. }
function DWGObjectToNODRawObject(const Raw: Dwg_Data; const Obj: Dwg_Object;
  AModel: TZNODModel): TZDXFRawObject;

{ Строит модель NOD по объектам DWG: индекс символьных таблиц, объекты,
  NOD из заголовка (если ссылки нет — DICTIONARY без владельца). Модель
  предварительно очищается. False — NOD не найден. }
function BuildDWGNODModel(var Raw: Dwg_Data; AModel: TZNODModel): Boolean;

{ Загрузка данных NOD из DWG в чертёж: BuildDWGNODModel,
  RunNODLoadHandlers, RunNODEnsureDefaults. Возвращает количество
  вызванных LoadProc обработчиков. }
function DWGNODLoad(var Raw: Dwg_Data; var ADrawing: TSimpleDrawing): Integer;

implementation

uses
  uzedwghandle,
  uzedwgtext,
  uzeffdxfnodlog,
  uzeffdxfnodregistry,
  { Регистрация обработчиков NOD (initialization модулей) }
  uzestylestablesdxfnod,
  uzestylesmleaderdxfnod;

const
  { Упакованный цвет AcCmEntityColor (группы 90–99): метод в старшем байте }
  CColorMethodByLayer = $C0;
  CColorMethodByBlock = $C1;
  CColorMethodACI = $C3;
  CColorMethodNone = $C8;

var
  { Формат вещественных чисел DXF: десятичная точка независимо от локали }
  DXFFormat: TFormatSettings;

type
  { Массивы строк и ссылок словаря DWG (texts / itemhandles) }
  PDWGNODTexts = ^BITCODE_T;
  PDWGNODRefs = ^BITCODE_H;

  { Параметры разбора строк DWG }
  TDWGNODTextCtx = record
    Version: DWG_VERSION_TYPE;
    CodePage: Integer;
  end;

function MakeTextCtx(const Raw: Dwg_Data): TDWGNODTextCtx;
begin
  { Как TDWGCtx.CreateRec в dwgproc }
  Result.Version := Raw.header.version;
  if Result.Version = R_INVALID then
    Result.Version := Raw.header.from_version;
  Result.CodePage := Raw.header.codepage;
end;

function DecodeText(const ACtx: TDWGNODTextCtx; P: BITCODE_T): string;
begin
  DWGSafeDecodeText(P, ACtx.Version, ACtx.CodePage, Result);
end;

function DWGHeaderNODHandle(const Raw: Dwg_Data): TDWGHandle;
var
  H: QWord;
begin
  if DWGRefHandleValue(Raw.header_vars.DICTIONARY_NAMED_OBJECT, H) then
    Result := H
  else
    Result := 0;
end;

function RefHandle(Ref: BITCODE_H): TDWGHandle;
var
  H: QWord;
begin
  if DWGRefHandleValue(Ref, H) then
    Result := H
  else
    Result := 0;
end;

procedure AddInt(AObj: TZDXFRawObject; ACode: Integer; AValue: Int64);
begin
  AObj.AddPair(ACode, IntToStr(AValue));
end;

procedure AddFloat(AObj: TZDXFRawObject; ACode: Integer; AValue: Double);
begin
  AObj.AddPair(ACode, FloatToStr(AValue, DXFFormat));
end;

procedure AddHandle(AObj: TZDXFRawObject; ACode: Integer; AHandle: TDWGHandle);
begin
  AObj.AddPair(ACode, DXFHandleToStr(AHandle));
end;

{ Ссылка на объект: пустая ссылка не пишется (как у AutoCAD для 341/343) }
procedure AddRef(AObj: TZDXFRawObject; ACode: Integer; Ref: BITCODE_H);
var
  H: TDWGHandle;
begin
  H := RefHandle(Ref);
  if H <> 0 then
    AddHandle(AObj, ACode, H);
end;

{ Цвет ACI (группы 62–69 TABLESTYLE) }
function ColorToACI(const Color: Dwg_Color): Integer;
begin
  DWGColorIndexToACI(Color, Result);
end;

{ Упакованный цвет (группы 91/93/94 MLEADERSTYLE). В DWG R2004+ поле rgb
  хранит значение целиком (метод в старшем байте); в старых версиях —
  только индекс ACI. }
function ColorToPacked(const Color: Dwg_Color): Integer;
var
  Method: Integer;
begin
  Method := (Color.rgb shr 24) and $FF;
  if (Method >= CColorMethodByLayer) and (Method <= CColorMethodNone) then
    Exit(Integer(Color.rgb));
  case ColorToACI(Color) of
    0: Result := Integer(DWord(CColorMethodByBlock) shl 24);
    256: Result := Integer(DWord(CColorMethodByLayer) shl 24);
  else
    Result := Integer((DWord(CColorMethodACI) shl 24) or DWord(ColorToACI(Color)));
  end;
end;

function IsTypedObject(const Obj: Dwg_Object): Boolean;
begin
  Result := (Obj.supertype = DWG_SUPERTYPE_OBJECT) and (Obj.tio.&object <> nil);
end;

{ Тип объекта DXF (группа 0) }
function DWGObjectDXFType(const Obj: Dwg_Object): string;
begin
  case Obj.fixedtype of
    DWG_TYPE_DICTIONARY: Result := CDXFDictionaryObjType;
    DWG_TYPE_DICTIONARYWDFLT: Result := CDXFDictionaryWithDefaultObjType;
    DWG_TYPE_TABLESTYLE: Result := 'TABLESTYLE';
    DWG_TYPE_MLEADERSTYLE: Result := 'MLEADERSTYLE';
  else
    if Obj.dxfname <> nil then
      Result := UpperCase(string(Obj.dxfname))
    else if Obj.name <> nil then
      Result := UpperCase(string(Obj.name))
    else
      Result := '';
  end;
end;

{ Заголовок объекта: 5, 102 ACAD_REACTORS, 102 ACAD_XDICTIONARY, 330
  (порядок — как в DXF). Общие поля сырого объекта заполняются здесь же. }
procedure AddObjectHeader(AObj: TZDXFRawObject; const Obj: Dwg_Object);
var
  Inner: ^Dwg_Object_Object;
  I: Integer;
  H: TDWGHandle;
  Owner: QWord;
begin
  AObj.Handle := DWGObjectHandleValue(Obj);
  AddHandle(AObj, 5, AObj.Handle);
  Inner := Obj.tio.&object;
  if (Inner^.num_reactors > 0) and (Inner^.reactors <> nil) then begin
    AObj.AddPair(102, '{' + CDXFReactorsBlockName);
    for I := 0 to Integer(Inner^.num_reactors) - 1 do begin
      H := RefHandle(Inner^.reactors[I]);
      if H = 0 then
        Continue;
      SetLength(AObj.Reactors, Length(AObj.Reactors) + 1);
      AObj.Reactors[High(AObj.Reactors)] := H;
      AddHandle(AObj, 330, H);
    end;
    AObj.AddPair(102, '}');
  end;
  AObj.XDictHandle := RefHandle(Inner^.xdicobjhandle);
  if AObj.XDictHandle <> 0 then begin
    AObj.AddPair(102, '{' + CDXFXDictionaryBlockName);
    AddHandle(AObj, 360, AObj.XDictHandle);
    AObj.AddPair(102, '}');
  end;
  if not DWGObjectOwnerHandleValue(Obj, Owner) then
    Owner := 0;
  AObj.OwnerHandle := Owner;
  AObj.HasOwnerGroup := True;
  AddHandle(AObj, 330, AObj.OwnerHandle);
end;

{ Записи словаря (общая часть DICTIONARY и DICTIONARYWDFLT) }
procedure AddDictionaryItems(AObj: TZDXFRawObject; const ACtx: TDWGNODTextCtx;
  NumItems: BITCODE_BL; IsHardOwner: BITCODE_RC; Cloning: BITCODE_BS;
  Texts: PDWGNODTexts; ItemHandles: PDWGNODRefs);
var
  I, Code: Integer;
  H: TDWGHandle;
  Key: string;
begin
  AObj.AddPair(100, 'AcDbDictionary');
  if IsHardOwner <> 0 then
    AddInt(AObj, 280, IsHardOwner);
  AddInt(AObj, 281, Cloning);
  if (Texts = nil) or (ItemHandles = nil) then
    Exit;
  if IsHardOwner and 1 <> 0 then
    Code := 360
  else
    Code := 350;
  for I := 0 to Integer(NumItems) - 1 do begin
    Key := DecodeText(ACtx, Texts[I]);
    H := RefHandle(ItemHandles[I]);
    if H = 0 then begin
      NODLogTraceFormatStr(
        'uzedwgnod: dictionary %s: key "%s" has no item handle, skipped',
        [AObj.HandleStr, Key]);
      Continue;
    end;
    AObj.AddPair(3, Key);
    AddHandle(AObj, Code, H);
  end;
end;

procedure AddTableStyleData(AObj: TZDXFRawObject; const ACtx: TDWGNODTextCtx;
  const TS: Dwg_Object_TABLESTYLE; AModel: TZNODModel);
var
  R, B: Integer;
  Row: ^Dwg_TABLESTYLE_rowstyles;
  Border: ^Dwg_TABLESTYLE_border;
  StyleName: string;
  H: TDWGHandle;
begin
  AObj.AddPair(100, 'AcDbTableStyle');
  AObj.AddPair(3, DecodeText(ACtx, TS.name));
  { R2010+: dwg.spec пишет в flow_direction (BS, 16 бит)
    property_override_flags & 0x10000 — после усечения всегда 0 }
  AddInt(AObj, 70, TS.flow_direction);
  { R2010+: остальные поля заголовка LibreDWG не заполняет }
  if ACtx.Version <= R_2007 then begin
    AddInt(AObj, 71, TS.flags);
    AddFloat(AObj, 40, TS.horiz_cell_margin);
    AddFloat(AObj, 41, TS.vert_cell_margin);
    AddInt(AObj, 280, TS.is_title_suppressed);
    AddInt(AObj, 281, TS.is_header_suppressed);
  end;
  if TS.rowstyles = nil then
    Exit;
  { Блоки строк: 0 — data, 1 — title, 2 — header (порядок DXF) }
  for R := 0 to Integer(TS.num_rowstyles) - 1 do begin
    Row := @TS.rowstyles[R];
    StyleName := '';
    H := RefHandle(Row^.text_style);
    if (H <> 0) and ((AModel = nil) or
       not AModel.FindSymbolName(H, 'STYLE', StyleName)) then
      NODLogWarningFormatStr(
        'uzedwgnod: table style %s: text style %s of row %d is not a STYLE record',
        [AObj.HandleStr, DXFHandleToStr(H), R]);
    AObj.AddPair(7, StyleName);
    AddFloat(AObj, 140, Row^.text_height);
    AddInt(AObj, 170, Row^.text_alignment);
    AddInt(AObj, 62, ColorToACI(Row^.text_color));
    AddInt(AObj, 63, ColorToACI(Row^.fill_color));
    AddInt(AObj, 283, Row^.has_bgcolor);
    if Row^.borders = nil then
      Continue;
    for B := 0 to Integer(Row^.num_borders) - 1 do begin
      if B > 5 then
        Break;
      Border := @Row^.borders[B];
      AddInt(AObj, 274 + B, Border^.linewt);
      AddInt(AObj, 284 + B, Border^.visible);
      AddInt(AObj, 64 + B, ColorToACI(Border^.color));
    end;
  end;
end;

procedure AddMLeaderStyleData(AObj: TZDXFRawObject; const ACtx: TDWGNODTextCtx;
  const MS: Dwg_Object_MLEADERSTYLE);
begin
  AObj.AddPair(100, 'AcDbMLeaderStyle');
  if ACtx.Version >= R_2010 then
    AddInt(AObj, 179, MS.class_version);
  AddInt(AObj, 170, MS.content_type);
  AddInt(AObj, 171, MS.mleader_order);
  AddInt(AObj, 172, MS.leader_order);
  AddInt(AObj, 90, MS.max_points);
  AddFloat(AObj, 40, MS.first_seg_angle);
  AddFloat(AObj, 41, MS.second_seg_angle);
  AddInt(AObj, 173, MS._type);
  AddInt(AObj, 91, ColorToPacked(MS.line_color));
  AddRef(AObj, 340, MS.line_type);
  AddInt(AObj, 92, MS.linewt);
  AddInt(AObj, 290, MS.has_landing);
  AddFloat(AObj, 42, MS.landing_gap);
  AddInt(AObj, 291, MS.has_dogleg);
  AddFloat(AObj, 43, MS.landing_dist);
  AObj.AddPair(3, DecodeText(ACtx, MS.description));
  AddRef(AObj, 341, MS.arrow_head);
  AddFloat(AObj, 44, MS.arrow_head_size);
  AObj.AddPair(300, DecodeText(ACtx, MS.text_default));
  AddRef(AObj, 342, MS.text_style);
  AddInt(AObj, 174, MS.attach_left);
  AddInt(AObj, 178, MS.attach_right);
  { До R2010 LibreDWG ставит class_version = 2 }
  if MS.class_version >= 2 then
    AddInt(AObj, 175, MS.text_angle_type);
  AddInt(AObj, 176, MS.text_align_type);
  AddInt(AObj, 93, ColorToPacked(MS.text_color));
  AddFloat(AObj, 45, MS.text_height);
  AddInt(AObj, 292, MS.has_text_frame);
  AddInt(AObj, 297, MS.text_always_left);
  AddFloat(AObj, 46, MS.align_space);
  AddRef(AObj, 343, MS.block);
  AddInt(AObj, 94, ColorToPacked(MS.block_color));
  AddFloat(AObj, 47, MS.block_scale.x);
  AddFloat(AObj, 49, MS.block_scale.y);
  AddFloat(AObj, 140, MS.block_scale.z);
  AddInt(AObj, 293, MS.use_block_scale);
  AddFloat(AObj, 141, MS.block_rotation);
  AddInt(AObj, 294, MS.use_block_rotation);
  AddInt(AObj, 177, MS.block_connection);
  AddFloat(AObj, 142, MS.scale);
  AddInt(AObj, 295, MS.is_changed);
  AddInt(AObj, 296, MS.is_annotative);
  AddFloat(AObj, 143, MS.break_size);
  if ACtx.Version >= R_2010 then begin
    AddInt(AObj, 271, MS.attach_dir);
    AddInt(AObj, 273, MS.attach_top);
    AddInt(AObj, 272, MS.attach_bottom);
  end;
  if ACtx.Version >= R_2013 then
    AddInt(AObj, 298, MS.text_extended);
end;

function ObjectToRaw(const Obj: Dwg_Object; const ACtx: TDWGNODTextCtx;
  AModel: TZNODModel): TZDXFRawObject;
var
  Inner: ^Dwg_Object_Object;
  ObjType: string;
begin
  Result := nil;
  if not IsTypedObject(Obj) then
    Exit;
  ObjType := DWGObjectDXFType(Obj);
  if ObjType = '' then
    Exit;
  Inner := Obj.tio.&object;
  Result := TZDXFRawObject.Create;
  try
    Result.ObjType := ObjType;
    AddObjectHeader(Result, Obj);
    case Obj.fixedtype of
      DWG_TYPE_DICTIONARY:
        if Inner^.tio.DICTIONARY <> nil then
          with Inner^.tio.DICTIONARY^ do
            AddDictionaryItems(Result, ACtx, numitems, is_hardowner, cloning,
              texts, itemhandles);
      DWG_TYPE_DICTIONARYWDFLT:
        if Inner^.tio.DICTIONARYWDFLT <> nil then
          with Inner^.tio.DICTIONARYWDFLT^ do begin
            AddDictionaryItems(Result, ACtx, numitems, is_hardowner, cloning,
              texts, itemhandles);
            Result.AddPair(100, 'AcDbDictionaryWithDefault');
            AddRef(Result, 340, defaultid);
          end;
      DWG_TYPE_TABLESTYLE:
        if Inner^.tio.TABLESTYLE <> nil then
          AddTableStyleData(Result, ACtx, Inner^.tio.TABLESTYLE^, AModel);
      DWG_TYPE_MLEADERSTYLE:
        if Inner^.tio.MLEADERSTYLE <> nil then
          AddMLeaderStyleData(Result, ACtx, Inner^.tio.MLEADERSTYLE^);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function DWGObjectToNODRawObject(const Raw: Dwg_Data; const Obj: Dwg_Object;
  AModel: TZNODModel): TZDXFRawObject;
begin
  Result := ObjectToRaw(Obj, MakeTextCtx(Raw), AModel);
end;

{ Запись символьной таблицы: LTYPE, STYLE, BLOCK_HEADER }
procedure AddSymbol(AModel: TZNODModel; const Obj: Dwg_Object;
  const ACtx: TDWGNODTextCtx);
var
  Inner: ^Dwg_Object_Object;
begin
  if not IsTypedObject(Obj) then
    Exit;
  Inner := Obj.tio.&object;
  case Obj.fixedtype of
    DWG_TYPE_LTYPE:
      if Inner^.tio.LTYPE <> nil then
        AModel.AddSymbolRecord(DWGObjectHandleValue(Obj), 'LTYPE',
          DecodeText(ACtx, Inner^.tio.LTYPE^.name));
    DWG_TYPE_STYLE:
      if Inner^.tio.STYLE <> nil then
        AModel.AddSymbolRecord(DWGObjectHandleValue(Obj), 'STYLE',
          DecodeText(ACtx, Inner^.tio.STYLE^.name));
    DWG_TYPE_BLOCK_HEADER:
      if Inner^.tio.BLOCK_HEADER <> nil then
        AModel.AddSymbolRecord(DWGObjectHandleValue(Obj),
          CDWGNODBlockRecordTableType,
          DecodeText(ACtx, Inner^.tio.BLOCK_HEADER^.name));
  end;
end;

function BuildDWGNODModel(var Raw: Dwg_Data; AModel: TZNODModel): Boolean;
var
  Ctx: TDWGNODTextCtx;
  I: BITCODE_BL;
  RawObj: TZDXFRawObject;
begin
  Result := False;
  if AModel = nil then
    Exit;
  AModel.Clear;
  Ctx := MakeTextCtx(Raw);
  { Идемпотентно: расширяет усечённые хэндлы объектов по таблицам ссылок }
  DWGNormalizeObjectHandles(Raw);
  if Raw.&object <> nil then begin
    { Сначала символьные таблицы: TABLESTYLE пишет имя стиля (группа 7) }
    I := 0;
    while I < Raw.num_objects do begin
      AddSymbol(AModel, Raw.&object[I], Ctx);
      Inc(I);
    end;
    I := 0;
    while I < Raw.num_objects do begin
      RawObj := ObjectToRaw(Raw.&object[I], Ctx, AModel);
      if RawObj <> nil then begin
        RawObj.LineNumber := Integer(I);
        AModel.AddObject(RawObj);
      end;
      Inc(I);
    end;
  end;
  AModel.EndBuild(DWGHeaderNODHandle(Raw));
  Result := AModel.NOD <> nil;
end;

function DWGNODLoad(var Raw: Dwg_Data; var ADrawing: TSimpleDrawing): Integer;
var
  Model: TZNODModel;
  StartTick: QWord;
begin
  Result := 0;
  StartTick := GetTickCount64;
  Model := TZNODModel.Create;
  try
    try
      if BuildDWGNODModel(Raw, Model) then
        Result := RunNODLoadHandlers(Model, ADrawing)
      else
        NODLogWarningFormatStr('uzedwgnod: NOD not found in DWG', []);
    except
      on E: Exception do
        NODLogWarningFormatStr('uzedwgnod: NOD load failed: %s: %s',
          [E.ClassName, E.Message]);
    end;
    { Обязательные записи, которых нет после загрузки (как для DXF) }
    RunNODEnsureDefaults(ADrawing);
    NODLogTraceFormatStr(
      'uzedwgnod: NOD loaded: %d objects, %d dictionaries, %d handlers, %d claimed, %d ms',
      [Model.Objects.Count, Model.Dictionaries.Count, Result,
       Model.ClaimedHandleCount, GetTickCount64 - StartTick]);
  finally
    Model.Free;
  end;
end;

initialization
  DXFFormat := DefaultFormatSettings;
  DXFFormat.DecimalSeparator := '.';
end.
