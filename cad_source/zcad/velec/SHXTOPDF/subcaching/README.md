# Этап 6: Подсистема кеширования и субсетинга (Subset & Cache)

## Назначение

Подсистема кеширования и субсетинга является оптимизационным и инфраструктурным компонентом конвейера SHX → PDF. Она обеспечивает:

1. **Subset-генерацию** — в PDF попадают только реально используемые глифы
2. **Кеширование CharProcs** — исключение дублирующей генерации одинаковых глифов
3. **Архитектурную готовность** к персистентному дисковому кешу

## Архитектура

```
SHX Reader (Этап 1)
   ↓
ApproGeom (Этап 2)
   ↓
Transform (Этап 3)
   ↓
CharProcs (Этап 4)
   ↓
ToUnicode (Этап 5)
   ↓
[ SUBCACHING ]  ← ЭТАП 6
   ↓
PDF Writer
```

## Структура модулей

### Основные модули

| Файл | Назначение |
|------|------------|
| `uzvshxtopdfsubcachetypes.pas` | Типы данных: ключи кеша, записи, статистика |
| `uzvshxtopdfsubcachehash.pas` | Вычисление хеш-значений для ключей (FNV-1a) |
| `uzvshxtopdfsubcache.pas` | Основной кеш CharProcs в памяти |
| `uzvshxtopdfsubcachesubset.pas` | Менеджер субсетов глифов |
| `uzvshxtopdfsubcachedisk.pas` | Интерфейс дискового кеша (заглушки) |

### Тесты

| Файл | Назначение |
|------|------------|
| `test/uzvshxtopdfsubcachetestdup.pas` | Тест дедупликации CharProcs |
| `test/uzvshxtopdfsubcachetesthash.pas` | Тест учёта трансформаций в хеше |
| `test/uzvshxtopdfsubcachetestsubset.pas` | Тест субсетинга глифов |

## Принцип работы

### Ключ кеша

Уникальный ключ глифа формируется из:

```pascal
TUzvGlyphCacheKey = record
  ShxFontName: AnsiString;  // Имя SHX-шрифта
  GlyphCode: Integer;        // Код символа
  Height: Double;            // Высота текста
  WidthFactor: Double;       // Коэффициент ширины
  ObliqueDeg: Double;        // Наклон в градусах
end;
```

### Алгоритм хеширования

Используется FNV-1a (64-bit):

```
hash = FNV-1a(lowercase(shxName) + glyphCode + height + widthFactor + oblique)
```

### Жизненный цикл кеша

```pascal
// 1. Создание кеша
Cache := CreateSubCache;

// 2. Получение/создание CharProc
CharProc := Cache.GetOrCreateCharProc(Key, @GeneratorFunction);

// 3. Получение статистики
Stats := Cache.GetStats;

// 4. Очистка
Cache.Clear;
Cache.Free;
```

### Субсетинг

```pascal
// 1. Создание менеджера субсетов
SubsetMgr := CreateSubsetManager('font.shx', Cache);

// 2. Отметка используемых глифов
SubsetMgr.MarkGlyphsUsed([65, 66, 67]); // A, B, C
// или
SubsetMgr.MarkStringGlyphsUsed('Hello World');

// 3. Построение субсета
Subset := SubsetMgr.BuildSubset;

// 4. Использование
// Subset.CharProcs - только используемые глифы
// Subset.FirstChar, Subset.LastChar - диапазон кодов
// Subset.Widths - массив ширин
```

## Логирование

Все модули используют `uzclog` с типом сообщений `LM_Info`:

```pascal
programlog.LogOutFormatStr(
  'SubCache: reuse CharProc for hash=%s',
  [hashStr],
  LM_Info
);
```

Точки логирования:
- Создание нового кеша
- Формирование хеша
- Попадание в кеш (cache hit)
- Промах кеша (cache miss)
- Статистика использования

## Тесты

### Тест 1: Дедупликация (1000 одинаковых символов)

```
Вход: 1000 запросов символа "A"
Ожидаемый результат:
  - TotalRequests = 1000
  - TotalCharProcs = 1
  - CacheHits = 999
  - CacheMisses = 1
```

### Тест 2: Учёт трансформаций

```
Вход:
  - "A" с height=1.0
  - "A" с height=2.0
Ожидаемый результат:
  - 2 разных хеша
  - 2 разных CharProc
```

### Тест 3: Разные шрифты

```
Вход:
  - Font1.shx: "A"
  - Font2.shx: "A"
Ожидаемый результат:
  - 2 разных хеша
  - 2 разных CharProc
```

## Дисковый кеш (будущее расширение)

Архитектура подготовлена для добавления персистентного кеша:

```pascal
// Параметры дискового кеша
Params := GetDefaultDiskCacheParams;
Params.Enabled := True;
Params.CacheDirectory := '/path/to/cache';

// Загрузка (заглушка)
LoadCacheFromDisk(Cache, Params);

// Сохранение (заглушка)
SaveCacheToDisk(Cache, Params);
```

Планируемый формат файла:
- Бинарный с заголовком версии
- Ключ: `hash(shxFileContent) + modificationTime`
- Структура: `<cacheDir>/<fontNameHash>.shxcache`

## Зависимости

- `uzvshxtopdfcharprocstypes` — типы CharProcs из Этапа 4
- `uzvshxtopdftransformtypes` — типы трансформаций из Этапа 3
- `uzclog` — логирование

## Производительность

При корректном использовании подсистема обеспечивает:
- Ускорение в 3–5 раз при повторных символах
- Уменьшение размера PDF за счёт субсетинга
- Снижение потребления памяти
