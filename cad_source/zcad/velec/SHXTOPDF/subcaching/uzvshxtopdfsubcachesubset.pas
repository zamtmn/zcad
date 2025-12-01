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
@author(Vladimir Bobrov)
}

{
  Модуль: uzvshxtopdfsubcachesubset
  Назначение: Управление субсетами глифов для Этапа 6

  Данный модуль реализует:
  - Отслеживание используемых глифов
  - Формирование субсета для PDF
  - Построение маппинга logicalGlyph -> pdfCharCode
  - Генерацию Type3 Font на основе субсета

  Основной принцип:
    В PDF попадают ТОЛЬКО реально используемые глифы,
    что уменьшает размер итогового файла.

  Зависимости:
  - uzvshxtopdfsubcachetypes: типы данных
  - uzvshxtopdfsubcache: кеш CharProcs
  - uzvshxtopdfcharprocstypes: типы CharProcs
  - uzvshxtopdfcmaptypes: типы ToUnicode CMap
  - uzclog: логирование

  Module: uzvshxtopdfsubcachesubset
  Purpose: Glyph subset management for Stage 6

  This module implements:
  - Used glyphs tracking
  - PDF subset formation
  - Mapping construction logicalGlyph -> pdfCharCode
  - Type3 Font generation based on subset

  Main principle:
    Only ACTUALLY used glyphs are included in PDF,
    which reduces final file size.
}

unit uzvshxtopdfsubcachesubset;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  uzvshxtopdfsubcachetypes,
  uzvshxtopdfsubcache,
  uzvshxtopdfcharprocstypes,
  uzclog;

type
  // Менеджер субсетов
  // Subset manager class
  TUzvSubsetManager = class
  private
    // Имя SHX-шрифта
    // SHX font name
    FShxFontName: AnsiString;

    // Список используемых глифов (коды символов)
    // Used glyphs list (character codes)
    FUsedGlyphs: TStringList;

    // Маппинг: исходный код -> индекс в субсете
    // Mapping: original code -> subset index
    FMappings: TUzvSubsetMappingArray;

    // Ссылка на кеш CharProcs
    // Reference to CharProcs cache
    FCache: TUzvSubCache;

    // Параметры субсетинга
    // Subsetting parameters
    FParams: TUzvSubsetParams;

    // Флаг включения логирования
    // Logging enabled flag
    FLoggingEnabled: Boolean;

    // Логировать сообщение
    // Log message
    procedure Log(const Msg: AnsiString);

    // Отсортировать коды глифов
    // Sort glyph codes
    procedure SortGlyphCodes;

  public
    // Конструктор
    // Constructor
    //
    // AShxFontName: имя SHX-шрифта
    // ACache: ссылка на кеш CharProcs (не владеет объектом)
    //
    // AShxFontName: SHX font name
    // ACache: reference to CharProcs cache (does not own the object)
    constructor Create(
      const AShxFontName: AnsiString;
      ACache: TUzvSubCache
    );

    // Деструктор
    // Destructor
    destructor Destroy; override;

    // Отметить глиф как используемый
    // Mark glyph as used
    procedure MarkGlyphUsed(GlyphCode: Integer);

    // Отметить массив глифов как используемых
    // Mark array of glyphs as used
    procedure MarkGlyphsUsed(const GlyphCodes: array of Integer);

    // Отметить все глифы из строки как используемые
    // Mark all glyphs from string as used
    procedure MarkStringGlyphsUsed(const Text: AnsiString);

    // Проверить, используется ли глиф
    // Check if glyph is used
    function IsGlyphUsed(GlyphCode: Integer): Boolean;

    // Получить количество используемых глифов
    // Get used glyphs count
    function GetUsedGlyphCount: Integer;

    // Получить список используемых кодов глифов
    // Get list of used glyph codes
    function GetUsedGlyphCodes: TIntegerDynArray;

    // Построить субсет шрифта
    // Build font subset
    //
    // Собирает CharProcs из кеша для всех используемых глифов
    // и формирует структуру TUzvFontSubset
    //
    // Collects CharProcs from cache for all used glyphs
    // and builds TUzvFontSubset structure
    function BuildSubset: TUzvFontSubset;

    // Получить PDF-код символа для исходного кода глифа
    // Get PDF character code for original glyph code
    //
    // Возвращает -1 если глиф не в субсете
    // Returns -1 if glyph is not in subset
    function GetPdfCharCode(LogicalGlyphCode: Integer): Integer;

    // Очистить список используемых глифов
    // Clear used glyphs list
    procedure Clear;

    // Установить параметры субсетинга
    // Set subsetting parameters
    procedure SetParams(const AParams: TUzvSubsetParams);

    // Получить параметры субсетинга
    // Get subsetting parameters
    function GetParams: TUzvSubsetParams;

    // Свойства
    // Properties
    property ShxFontName: AnsiString read FShxFontName;
    property UsedGlyphCount: Integer read GetUsedGlyphCount;
    property LoggingEnabled: Boolean read FLoggingEnabled write FLoggingEnabled;
  end;

type
  // Динамический массив Integer (объявлен здесь для совместимости)
  // Dynamic integer array (declared here for compatibility)
  TIntegerDynArray = array of Integer;

// Создать менеджер субсетов
// Create subset manager
function CreateSubsetManager(
  const ShxFontName: AnsiString;
  Cache: TUzvSubCache
): TUzvSubsetManager;

implementation

const
  LOG_PREFIX = 'SubsetManager: ';

// Создать менеджер субсетов
function CreateSubsetManager(
  const ShxFontName: AnsiString;
  Cache: TUzvSubCache
): TUzvSubsetManager;
begin
  Result := TUzvSubsetManager.Create(ShxFontName, Cache);
end;

{ TUzvSubsetManager }

constructor TUzvSubsetManager.Create(
  const AShxFontName: AnsiString;
  ACache: TUzvSubCache
);
begin
  inherited Create;

  FShxFontName := AShxFontName;
  FCache := ACache;

  FUsedGlyphs := TStringList.Create;
  FUsedGlyphs.Sorted := True;
  FUsedGlyphs.Duplicates := dupIgnore; // Игнорируем дубликаты

  SetLength(FMappings, 0);

  FParams := GetDefaultSubsetParams;
  FLoggingEnabled := True;

  Log(Format('создан для шрифта "%s"', [FShxFontName]));
end;

destructor TUzvSubsetManager.Destroy;
begin
  FUsedGlyphs.Free;
  SetLength(FMappings, 0);

  Log(Format('уничтожен для шрифта "%s"', [FShxFontName]));

  inherited Destroy;
end;

procedure TUzvSubsetManager.Log(const Msg: AnsiString);
begin
  if FLoggingEnabled then
    programlog.LogOutStr(LOG_PREFIX + Msg, LM_Info);
end;

procedure TUzvSubsetManager.SortGlyphCodes;
begin
  // TStringList уже отсортирован, ничего не делаем
  // TStringList is already sorted, nothing to do
end;

procedure TUzvSubsetManager.MarkGlyphUsed(GlyphCode: Integer);
var
  CodeStr: AnsiString;
begin
  // Проверяем диапазон кодов
  // Check code range
  if (GlyphCode < FParams.MinCharCode) or (GlyphCode > FParams.MaxCharCode) then
  begin
    Log(Format('код глифа %d вне диапазона [%d..%d], пропущен',
      [GlyphCode, FParams.MinCharCode, FParams.MaxCharCode]));
    Exit;
  end;

  // Добавляем код в список (дубликаты игнорируются)
  // Add code to list (duplicates are ignored)
  CodeStr := IntToStr(GlyphCode);
  if FUsedGlyphs.IndexOf(CodeStr) < 0 then
  begin
    FUsedGlyphs.Add(CodeStr);
    Log(Format('глиф %d отмечен как используемый, всего: %d',
      [GlyphCode, FUsedGlyphs.Count]));
  end;
end;

procedure TUzvSubsetManager.MarkGlyphsUsed(const GlyphCodes: array of Integer);
var
  I: Integer;
begin
  for I := 0 to High(GlyphCodes) do
    MarkGlyphUsed(GlyphCodes[I]);
end;

procedure TUzvSubsetManager.MarkStringGlyphsUsed(const Text: AnsiString);
var
  I: Integer;
begin
  for I := 1 to Length(Text) do
    MarkGlyphUsed(Ord(Text[I]));
end;

function TUzvSubsetManager.IsGlyphUsed(GlyphCode: Integer): Boolean;
begin
  Result := FUsedGlyphs.IndexOf(IntToStr(GlyphCode)) >= 0;
end;

function TUzvSubsetManager.GetUsedGlyphCount: Integer;
begin
  Result := FUsedGlyphs.Count;
end;

function TUzvSubsetManager.GetUsedGlyphCodes: TIntegerDynArray;
var
  I: Integer;
begin
  SetLength(Result, FUsedGlyphs.Count);
  for I := 0 to FUsedGlyphs.Count - 1 do
    Result[I] := StrToInt(FUsedGlyphs[I]);
end;

function TUzvSubsetManager.BuildSubset: TUzvFontSubset;
var
  I: Integer;
  GlyphCodes: TIntegerDynArray;
  CharProc: TUzvPdfCharProc;
  Mapping: TUzvSubsetMappingEntry;
  Key: TUzvGlyphCacheKey;
  FontBBox: TUzvPdfBBox;
  MinCode, MaxCode: Integer;
begin
  Result := CreateEmptyFontSubset;
  Result.ShxFontName := FShxFontName;

  // Получаем отсортированный список кодов
  // Get sorted codes list
  GlyphCodes := GetUsedGlyphCodes;

  if Length(GlyphCodes) = 0 then
  begin
    Log('субсет пуст, нет используемых глифов');
    Exit;
  end;

  Log(Format('построение субсета: %d глифов', [Length(GlyphCodes)]));

  // Инициализируем границы кодов
  // Initialize code boundaries
  MinCode := GlyphCodes[0];
  MaxCode := GlyphCodes[0];

  // Инициализируем FontBBox
  // Initialize FontBBox
  FontBBox := CreateEmptyPdfBBox;

  // Собираем CharProcs и строим маппинги
  // Collect CharProcs and build mappings
  SetLength(Result.CharProcs, Length(GlyphCodes));
  SetLength(Result.Mappings, Length(GlyphCodes));
  SetLength(FMappings, Length(GlyphCodes));

  for I := 0 to High(GlyphCodes) do
  begin
    // Создаём ключ для поиска в кеше
    // Create key for cache lookup
    Key := CreateGlyphCacheKey(
      FShxFontName,
      GlyphCodes[I],
      1.0,    // Стандартная высота (нормализованная)
      1.0,    // Стандартный WidthFactor
      0.0     // Без наклона
    );

    // Пытаемся найти CharProc в кеше
    // Try to find CharProc in cache
    if FCache.FindCharProc(Key, CharProc) then
    begin
      Result.CharProcs[I] := CharProc;
    end
    else
    begin
      // Если не найден, создаём пустой CharProc
      // If not found, create empty CharProc
      Result.CharProcs[I] := CreateEmptyCharProc(GlyphCodes[I]);
      Log(Format('предупреждение: CharProc для кода %d не найден в кеше',
        [GlyphCodes[I]]));
    end;

    // Строим маппинг
    // Build mapping
    Mapping.LogicalGlyphCode := GlyphCodes[I];
    Mapping.PdfCharCode := GlyphCodes[I];  // Используем тот же код
    Mapping.CharProcIndex := I;
    Mapping.ShxFontName := FShxFontName;

    Result.Mappings[I] := Mapping;
    FMappings[I] := Mapping;

    // Обновляем границы кодов
    // Update code boundaries
    if GlyphCodes[I] < MinCode then
      MinCode := GlyphCodes[I];
    if GlyphCodes[I] > MaxCode then
      MaxCode := GlyphCodes[I];

    // Обновляем FontBBox
    // Update FontBBox
    FontBBox := MergePdfBBoxes(FontBBox, Result.CharProcs[I].BBox);
  end;

  // Устанавливаем границы кодов
  // Set code boundaries
  Result.FirstChar := MinCode;
  Result.LastChar := MaxCode;

  // Строим массив ширин
  // Build widths array
  SetLength(Result.Widths, MaxCode - MinCode + 1);
  for I := 0 to High(Result.Widths) do
    Result.Widths[I] := 0.0;

  for I := 0 to High(Result.CharProcs) do
  begin
    if (Result.CharProcs[I].CharCode >= MinCode) and
       (Result.CharProcs[I].CharCode <= MaxCode) then
    begin
      Result.Widths[Result.CharProcs[I].CharCode - MinCode] :=
        Result.CharProcs[I].Width;
    end;
  end;

  // Устанавливаем FontBBox
  // Set FontBBox
  Result.FontBBox := FontBBox;

  Log(Format('субсет построен: CharProcs=%d, FirstChar=%d, LastChar=%d',
    [Length(Result.CharProcs), Result.FirstChar, Result.LastChar]));
end;

function TUzvSubsetManager.GetPdfCharCode(LogicalGlyphCode: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to High(FMappings) do
  begin
    if FMappings[I].LogicalGlyphCode = LogicalGlyphCode then
    begin
      Result := FMappings[I].PdfCharCode;
      Exit;
    end;
  end;
end;

procedure TUzvSubsetManager.Clear;
begin
  FUsedGlyphs.Clear;
  SetLength(FMappings, 0);

  Log('список используемых глифов очищен');
end;

procedure TUzvSubsetManager.SetParams(const AParams: TUzvSubsetParams);
begin
  FParams := AParams;
end;

function TUzvSubsetManager.GetParams: TUzvSubsetParams;
begin
  Result := FParams;
end;

end.
