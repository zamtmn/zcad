# Этап 4: Генерация CharProcs (PDF path streams)

## Назначение

Модуль `charprocs` предназначен для преобразования трансформированной безьевой геометрии глифов в PDF path stream и генерации объектов CharProcs для Type3-шрифта.

## Структура модуля

```
charprocs/
├── README.md                          # Документация модуля
├── uzvshxtopdfcharprocs.pas           # Основной интерфейс
├── uzvshxtopdfcharprocstypes.pas      # Типы данных
├── uzvshxtopdfcharprocswriter.pas     # Генерация PDF-стримов
├── uzvshxtopdfcharprocsfont.pas       # Генерация Type3 Font
├── uzvshxtopdfcharprocsbbox.pas       # Расчёт bounding box
└── test/
    ├── uzvshxtopdfcharprocstestcount.pas   # Тест количества CharProcs
    ├── uzvshxtopdfcharprocstestfont.pas    # Тест структуры Font
    ├── uzvshxtopdfcharprocstestwidths.pas  # Тест ширин глифов
    └── uzvshxtopdfcharprocstestpdf.pas     # Интеграционный тест PDF
```

## Входные данные

Модуль принимает результат **Этапа 3** (transform):

```pascal
TUzvWorldBezierFont
└── TUzvWorldBezierGlyph[]
    └── TUzvBezierPath[]
        └── TUzvBezierSegment[]
            ├── P0: TPointF  (начальная точка)
            ├── P1: TPointF  (контрольная точка 1)
            ├── P2: TPointF  (контрольная точка 2)
            └── P3: TPointF  (конечная точка)
```

**Важно:** Координаты уже приведены к мировой системе координат.

## Выходные данные

```pascal
TUzvPdfType3Font = record
  FontObjectStream: AnsiString;  // Полное описание Font объекта
  CharProcs: TUzvPdfCharProcsArray;  // Массив CharProcs
  Widths: array of Double;  // Ширины глифов
  FirstChar: Integer;  // Первый код символа
  LastChar: Integer;   // Последний код символа
  FontBBox: TUzvPdfBBox;  // Общий bounding box
end;
```

## Основной интерфейс

```pascal
function BuildType3FontCharProcs(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double;
  const Params: TUzvCharProcsParams
): TUzvPdfType3Font;
```

### Упрощённые версии:

```pascal
// С параметрами по умолчанию
function BuildType3FontCharProcsSimple(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double
): TUzvPdfType3Font;

// С автоматическим вычислением ширин из bounding box
function BuildType3FontCharProcsAuto(
  const Font: TUzvWorldBezierFont
): TUzvPdfType3Font;
```

## PDF-операторы

Модуль генерирует следующие PDF path операторы:

| Оператор | Назначение |
|----------|------------|
| `m` | moveTo - перемещение без рисования |
| `l` | lineTo - линия до точки |
| `c` | curveTo - кубическая кривая Безье |
| `h` | closePath - замыкание контура |
| `S` | stroke - обводка |
| `f` | fill - заливка |
| `q` | gsave - сохранение состояния |
| `Q` | grestore - восстановление состояния |

## Структура CharProc

```
q
<path operators>
S (или f)
Q
```

## Параметры генерации

```pascal
TUzvCharProcsParams = record
  UseStroke: Boolean;        // True = stroke (S), False = fill (f)
  CoordPrecision: Integer;   // Знаков после запятой (по умолчанию 4)
  WrapWithGraphicsState: Boolean;  // Оборачивать в q/Q
end;
```

## Подход к трансформации координат

Выбран подход **прямой записи трансформированных координат**.
Координаты уже в мировой системе после Этапа 3, поэтому дополнительные
преобразования не требуются. FontMatrix = [1 0 0 1 0 0] (единичная).

## Логирование

```pascal
uses uzclog;

programlog.LogOutFormatStr(
  'CharProcs: generated glyph code=%d',
  [CharCode],
  LM_Info
);
```

## Тестирование

Команда для запуска тестов Этапа 4:

```
SHX_TO_PDF_TEST4
```

### Тесты:

1. **uzvshxtopdfcharprocstestcount** - проверка количества CharProcs
2. **uzvshxtopdfcharprocstestfont** - проверка структуры Font объекта
3. **uzvshxtopdfcharprocstestwidths** - проверка корректности ширин
4. **uzvshxtopdfcharprocstestpdf** - интеграционный тест PDF

## Зависимости

```
uzvshxtopdfcharprocs.pas
├── uzvshxtopdfcharprocstypes.pas
├── uzvshxtopdfcharprocsbbox.pas
├── uzvshxtopdfcharprocswriter.pas
├── uzvshxtopdfcharprocsfont.pas
├── uzvshxtopdftransformtypes.pas (Этап 3)
├── uzvshxtopdfapprogeomtypes.pas (Этап 2)
└── uzclog.pas
```

## Архитектурные ограничения

- ❌ **НЕ выполняет трансформации** (это задача Этапа 3)
- ❌ **НЕ содержит матриц преобразования**
- ❌ **НЕ работает с SHX-командами** (это задача Этапа 1)
- ✅ Принимает **только результат Этапа 3**
- ✅ Работает **только с мировыми координатами**
