# Этап 5 — Формирование ToUnicode CMap для SHX-шрифтов

## Назначение

Модуль `cmap` реализует **Этап 5** конвейера SHX → PDF:
формирование ToUnicode CMap для корректного копирования и поиска текста в PDF-документах.

ToUnicode CMap сопоставляет:
```
код глифа в Type3 PDF → Unicode символ
```

## Место в конвейере

```
Этап 1: SHXReader  (парсинг SHX-файла)
    ↓
Этап 2: approgeom  (аппроксимация геометрии)
    ↓
Этап 3: transform  (трансформации матриц)
    ↓
Этап 4: charprocs  (генерация CharProcs)
    ↓
Этап 5: cmap       ← ТЕКУЩИЙ МОДУЛЬ
```

## Структура модуля

```
cmap/
├── uzvshxtopdfcmaptypes.pas      # Типы данных
├── uzvshxtopdfcmapmapping.pas    # Таблицы маппинга SHX → Unicode
├── uzvshxtopdfcmapwriter.pas     # Генерация CMap стрима
├── uzvshxtopdfcmap.pas           # Основной интерфейс
├── README.md                     # Документация
└── test/
    ├── uzvshxtopdfcmaptesthelper.pas    # Вспомогательные функции
    ├── uzvshxtopdfcmaptestmapping.pas   # Тест 1 и 2: полнота и корректность
    ├── uzvshxtopdfcmaptestduplicate.pas # Тест 3: дублирование кодов
    └── uzvshxtopdfcmapteststream.pas    # Тест структуры стрима
```

## Использование

### Базовый пример

```pascal
uses
  uzvshxtopdfcmap,
  uzvshxtopdfcharprocstypes;

var
  Type3Font: TUzvPdfType3Font;
  CMap: TUzvPdfToUnicodeCMap;
begin
  // Получаем Type3Font из Этапа 4
  Type3Font := BuildType3FontCharProcsAuto(WorldBezierFont);

  // Генерируем ToUnicode CMap
  CMap := BuildToUnicodeCMapSimple(Type3Font);

  // CMap.CMapStream содержит готовый PDF-стрим для /ToUnicode
end;
```

### С указанием локали

```pascal
uses
  uzvshxtopdfcmap,
  uzvshxtopdfcmapmapping;

// Для кириллицы Windows-1251
CMap := BuildToUnicodeCMapWithLocale(Type3Font, mlWindows1251);

// Для DOS CP866
CMap := BuildToUnicodeCMapWithLocale(Type3Font, mlCP866);

// Автоопределение локали
CMap := BuildToUnicodeCMapWithLocale(Type3Font, mlAuto);
```

### С параметрами

```pascal
var
  Params: TUzvCMapParams;
begin
  Params := GetDefaultCMapParams;
  Params.CMapName := 'MyCustomCMap';
  Params.IncludeComments := True;  // Для отладки

  CMap := BuildToUnicodeCMap(Type3Font, mlAuto, Params);
end;
```

## Поддерживаемые кодировки

| Локаль | Описание | Диапазон |
|--------|----------|----------|
| `mlAscii` | Стандартный ASCII | $20-$7E |
| `mlWindows1251` | Windows-1251 (кириллица) | $C0-$FF + $A8, $B8 |
| `mlCP866` | DOS CP866 (кириллица) | $80-$AF + $E0-$F1 |
| `mlAuto` | Автоопределение | — |

## Формат CMap стрима

Генерируемый стрим соответствует спецификации PDF:

```
/CIDInit /ProcSet findresource begin
12 dict begin
begincmap
/CIDSystemInfo <<
  /Registry (Adobe)
  /Ordering (UCS)
  /Supplement 0
>> def
/CMapName /UZVSHXToUnicode def
/CMapType 2 def
1 begincodespacerange
<00> <FF>
endcodespacerange
N beginbfchar
<41> <0041>
<42> <0042>
...
endbfchar
endcmap
CMapName currentdict /CMap defineresource pop
end
end
```

## Интеграция с PDF

После генерации CMap необходимо:

1. Создать PDF-объект для CMap стрима:
```
X 0 obj
<< /Length Y >>
stream
[CMap.CMapStream]
endstream
endobj
```

2. Добавить ссылку в объект шрифта:
```
/ToUnicode X 0 R
```

## Тестирование

### Тест 1 — Полнота маппинга

Проверяет, что каждый глиф из CharProcs имеет соответствующую запись в ToUnicode.

```pascal
uses uzvshxtopdfcmaptestmapping;
RunMappingCompletenessTest;
```

### Тест 2 — Корректность Unicode

Проверяет корректность преобразования:
- `A` → `U+0041`
- `Б` → `U+0411`
- `1` → `U+0031`
- `+` → `U+002B`

```pascal
uses uzvshxtopdfcmaptestmapping;
RunUnicodeCorrectnessTest;
```

### Тест 3 — Дублирование кодов

Проверяет отсутствие дублирующихся кодов символов.

```pascal
uses uzvshxtopdfcmaptestduplicate;
RunDuplicateCodesTest;
```

### Тест структуры стрима

Проверяет наличие всех обязательных элементов CMap.

```pascal
uses uzvshxtopdfcmapteststream;
RunCMapStreamStructureTest;
```

## Валидация

```pascal
var
  ValidationResult: TUzvCMapValidationResult;
begin
  ValidationResult := ValidateToUnicodeCMap(CMap, Type3Font.CharProcs);

  if ValidationResult.IsValid then
    // CMap корректен
  else
    // ValidationResult.ErrorMessage содержит описание ошибки
end;
```

## Логирование

Модуль использует стандартную систему логирования ZCAD:

```pascal
uses uzclog;

programlog.LogOutFormatStr(
  'ToUnicodeCMap: маппинг code=%d -> unicode=$%04X',
  [CharCode, UnicodeValue],
  LM_Info
);
```

## Инструментальная проверка

После генерации PDF можно проверить наличие ToUnicode утилитой `pdffonts`:

```bash
pdffonts document.pdf
```

В колонке `unicode` должно быть значение **yes**.

## Зависимости

- `uzvshxtopdfcharprocstypes` — типы данных Этапа 4
- `uzclog` — система логирования

## Ограничения

- Поддерживается только BMP (Basic Multilingual Plane) Unicode
- Суррогатные пары (символы выше U+FFFF) не поддерживаются
- Максимум 100 записей в одном блоке `bfchar` (ограничение PDF)

## Автор

Vladimir Bobrov
