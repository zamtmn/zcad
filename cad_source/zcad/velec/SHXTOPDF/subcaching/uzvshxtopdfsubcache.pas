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
  Модуль: uzvshxtopdfsubcache
  Назначение: Основной модуль кеширования CharProcs для Этапа 6

  Данный модуль реализует:
  - Хранение CharProcs в памяти (map<hash, CharProc>)
  - Поиск существующих CharProcs по ключу
  - Добавление новых CharProcs в кеш
  - Статистику использования кеша

  Жизненный цикл:
    1. CreateSubCache() - создание экземпляра кеша
    2. GetOrCreateCharProc() - получение/создание CharProc
    3. GetSubCacheStats() - получение статистики
    4. ClearSubCache() - очистка кеша

  Зависимости:
  - uzvshxtopdfsubcachetypes: типы данных
  - uzvshxtopdfsubcachehash: вычисление хешей
  - uzvshxtopdfcharprocstypes: типы CharProcs
  - uzclog: логирование

  Module: uzvshxtopdfsubcache
  Purpose: Main CharProcs caching module for Stage 6

  This module implements:
  - In-memory CharProcs storage (map<hash, CharProc>)
  - Existing CharProcs lookup by key
  - New CharProcs addition to cache
  - Cache usage statistics

  Lifecycle:
    1. CreateSubCache() - create cache instance
    2. GetOrCreateCharProc() - get/create CharProc
    3. GetSubCacheStats() - get statistics
    4. ClearSubCache() - clear cache
}

unit uzvshxtopdfsubcache;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  uzvshxtopdfsubcachetypes,
  uzvshxtopdfsubcachehash,
  uzvshxtopdfcharprocstypes,
  uzclog;

type
  // Callback-функция для генерации CharProc
  // Callback function for CharProc generation
  //
  // Вызывается когда CharProc не найден в кеше
  // Called when CharProc is not found in cache
  TCharProcGeneratorFunc = function(
    const Key: TUzvGlyphCacheKey
  ): TUzvPdfCharProc;

  // Класс кеша CharProcs
  // CharProcs cache class
  TUzvSubCache = class
  private
    // Внутренний список записей кеша
    // Internal cache entries list
    FEntries: TUzvCharProcCacheEntryArray;

    // Список хешей для быстрого поиска
    // Hash list for fast lookup
    FHashList: TStringList;

    // Статистика кеша
    // Cache statistics
    FStats: TUzvSubCacheStats;

    // Флаг включения логирования
    // Logging enabled flag
    FLoggingEnabled: Boolean;

    // Найти индекс записи по хешу
    // Find entry index by hash
    function FindEntryByHash(const Hash: AnsiString): Integer;

    // Добавить запись в кеш
    // Add entry to cache
    procedure AddEntry(const Entry: TUzvCharProcCacheEntry);

    // Обновить статистику
    // Update statistics
    procedure UpdateStats;

    // Логировать сообщение
    // Log message
    procedure Log(const Msg: AnsiString);

  public
    // Конструктор
    // Constructor
    constructor Create;

    // Деструктор
    // Destructor
    destructor Destroy; override;

    // Найти CharProc в кеше по ключу
    // Find CharProc in cache by key
    //
    // Возвращает True если найден, CharProc записывается в OutCharProc
    // Returns True if found, CharProc is written to OutCharProc
    function FindCharProc(
      const Key: TUzvGlyphCacheKey;
      out OutCharProc: TUzvPdfCharProc
    ): Boolean;

    // Добавить CharProc в кеш
    // Add CharProc to cache
    procedure PutCharProc(
      const Key: TUzvGlyphCacheKey;
      const CharProc: TUzvPdfCharProc
    );

    // Получить или создать CharProc
    // Get or create CharProc
    //
    // Если CharProc есть в кеше - возвращает его
    // Если нет - вызывает GeneratorFunc для создания
    //
    // If CharProc is in cache - returns it
    // If not - calls GeneratorFunc to create it
    function GetOrCreateCharProc(
      const Key: TUzvGlyphCacheKey;
      GeneratorFunc: TCharProcGeneratorFunc
    ): TUzvPdfCharProc;

    // Очистить кеш
    // Clear cache
    procedure Clear;

    // Получить количество записей в кеше
    // Get cache entry count
    function GetEntryCount: Integer;

    // Получить статистику кеша
    // Get cache statistics
    function GetStats: TUzvSubCacheStats;

    // Получить все записи кеша (для субсетинга)
    // Get all cache entries (for subsetting)
    function GetAllEntries: TUzvCharProcCacheEntryArray;

    // Получить массив CharProcs для указанных ключей
    // Get CharProcs array for specified keys
    function GetCharProcsForKeys(
      const Keys: array of TUzvGlyphCacheKey
    ): TUzvPdfCharProcsArray;

    // Включить/выключить логирование
    // Enable/disable logging
    property LoggingEnabled: Boolean read FLoggingEnabled write FLoggingEnabled;
  end;

// Создать экземпляр кеша (удобная функция)
// Create cache instance (convenience function)
function CreateSubCache: TUzvSubCache;

implementation

const
  LOG_PREFIX = 'SubCache: ';

// Создать экземпляр кеша
function CreateSubCache: TUzvSubCache;
begin
  Result := TUzvSubCache.Create;
end;

{ TUzvSubCache }

constructor TUzvSubCache.Create;
begin
  inherited Create;

  SetLength(FEntries, 0);

  FHashList := TStringList.Create;
  FHashList.Sorted := True;        // Для бинарного поиска
  FHashList.Duplicates := dupError; // Дубликаты запрещены

  FStats := CreateEmptySubCacheStats;
  FLoggingEnabled := True;

  Log('кеш создан');
end;

destructor TUzvSubCache.Destroy;
begin
  Clear;
  FHashList.Free;

  Log('кеш уничтожен');

  inherited Destroy;
end;

procedure TUzvSubCache.Log(const Msg: AnsiString);
begin
  if FLoggingEnabled then
    programlog.LogOutStr(LOG_PREFIX + Msg, LM_Info);
end;

function TUzvSubCache.FindEntryByHash(const Hash: AnsiString): Integer;
var
  Idx: Integer;
begin
  Result := -1;

  // Бинарный поиск в отсортированном списке
  // Binary search in sorted list
  if FHashList.Find(Hash, Idx) then
    Result := PtrInt(FHashList.Objects[Idx]);
end;

procedure TUzvSubCache.AddEntry(const Entry: TUzvCharProcCacheEntry);
var
  Hash: AnsiString;
  NewIndex: Integer;
begin
  Hash := CalcGlyphHash(Entry.Key);

  // Добавляем в массив записей
  // Add to entries array
  NewIndex := Length(FEntries);
  SetLength(FEntries, NewIndex + 1);
  FEntries[NewIndex] := Entry;

  // Добавляем хеш в список для быстрого поиска
  // Add hash to list for fast lookup
  FHashList.AddObject(Hash, TObject(PtrInt(NewIndex)));
end;

procedure TUzvSubCache.UpdateStats;
begin
  // Вычисляем процент повторного использования
  // Calculate reuse percentage
  if FStats.TotalRequests > 0 then
    FStats.ReusePercent := (FStats.CacheHits / FStats.TotalRequests) * 100.0
  else
    FStats.ReusePercent := 0.0;
end;

function TUzvSubCache.FindCharProc(
  const Key: TUzvGlyphCacheKey;
  out OutCharProc: TUzvPdfCharProc
): Boolean;
var
  Hash: AnsiString;
  EntryIndex: Integer;
begin
  Result := False;
  OutCharProc := CreateEmptyCharProc(Key.GlyphCode);

  // Увеличиваем счётчик запросов
  // Increment request counter
  Inc(FStats.TotalRequests);

  // Вычисляем хеш ключа
  // Calculate key hash
  Hash := CalcGlyphHash(Key);

  // Ищем в кеше
  // Search in cache
  EntryIndex := FindEntryByHash(Hash);

  if EntryIndex >= 0 then
  begin
    // Найдено в кеше
    // Found in cache
    Inc(FStats.CacheHits);
    Inc(FEntries[EntryIndex].UseCount);

    OutCharProc := FEntries[EntryIndex].CharProc;
    Result := True;

    Log(Format('попадание в кеш для hash=%s', [Hash]));
  end
  else
  begin
    // Не найдено в кеше
    // Not found in cache
    Inc(FStats.CacheMisses);

    Log(Format('промах кеша для hash=%s', [Hash]));
  end;

  UpdateStats;
end;

procedure TUzvSubCache.PutCharProc(
  const Key: TUzvGlyphCacheKey;
  const CharProc: TUzvPdfCharProc
);
var
  Hash: AnsiString;
  Entry: TUzvCharProcCacheEntry;
  ExistingIndex: Integer;
begin
  // Проверяем, нет ли уже такой записи
  // Check if entry already exists
  Hash := CalcGlyphHash(Key);
  ExistingIndex := FindEntryByHash(Hash);

  if ExistingIndex >= 0 then
  begin
    // Запись уже существует, обновляем CharProc
    // Entry already exists, update CharProc
    FEntries[ExistingIndex].CharProc := CharProc;
    Inc(FEntries[ExistingIndex].UseCount);

    Log(Format('обновлён CharProc для hash=%s', [Hash]));
  end
  else
  begin
    // Создаём новую запись
    // Create new entry
    Entry.Key := Key;
    Entry.CharProc := CharProc;
    Entry.UseCount := 1;
    Entry.CreatedAt := Now;

    AddEntry(Entry);

    Inc(FStats.TotalCharProcs);

    Log(Format('добавлен новый CharProc для hash=%s, всего в кеше: %d',
      [Hash, FStats.TotalCharProcs]));
  end;
end;

function TUzvSubCache.GetOrCreateCharProc(
  const Key: TUzvGlyphCacheKey;
  GeneratorFunc: TCharProcGeneratorFunc
): TUzvPdfCharProc;
begin
  // Пытаемся найти в кеше
  // Try to find in cache
  if FindCharProc(Key, Result) then
    Exit;

  // Не найдено - генерируем новый CharProc
  // Not found - generate new CharProc
  if Assigned(GeneratorFunc) then
  begin
    Result := GeneratorFunc(Key);

    // Добавляем в кеш
    // Add to cache
    PutCharProc(Key, Result);

    Log(Format('CharProc сгенерирован и закеширован для code=%d',
      [Key.GlyphCode]));
  end
  else
  begin
    // Нет функции генератора - возвращаем пустой CharProc
    // No generator function - return empty CharProc
    Result := CreateEmptyCharProc(Key.GlyphCode);

    Log('предупреждение: нет функции генератора CharProc');
  end;
end;

procedure TUzvSubCache.Clear;
begin
  SetLength(FEntries, 0);
  FHashList.Clear;
  FStats := CreateEmptySubCacheStats;

  Log('кеш очищен');
end;

function TUzvSubCache.GetEntryCount: Integer;
begin
  Result := Length(FEntries);
end;

function TUzvSubCache.GetStats: TUzvSubCacheStats;
begin
  UpdateStats;
  Result := FStats;
end;

function TUzvSubCache.GetAllEntries: TUzvCharProcCacheEntryArray;
begin
  Result := FEntries;
end;

function TUzvSubCache.GetCharProcsForKeys(
  const Keys: array of TUzvGlyphCacheKey
): TUzvPdfCharProcsArray;
var
  I: Integer;
  CharProc: TUzvPdfCharProc;
  Count: Integer;
begin
  SetLength(Result, 0);
  Count := 0;

  for I := 0 to High(Keys) do
  begin
    if FindCharProc(Keys[I], CharProc) then
    begin
      SetLength(Result, Count + 1);
      Result[Count] := CharProc;
      Inc(Count);
    end;
  end;
end;

end.
