# Этап 3: Трансформации (матрицы)
# Stage 3: Transformations (matrices)

## Назначение / Purpose

Этап 3 конвейера SHX → PDF применяет все геометрические трансформации CAD-текста к примитивам символов:
- масштаб по высоте
- коэффициент ширины (widthFactor)
- наклон (oblique / shear)
- поворот (rotation)
- перенос (translate)
- зеркалирование (mirroring)
- базовая позиция символа (baseline + kerning)
- выравнивание (alignments)

Stage 3 of SHX → PDF pipeline applies all CAD text geometric transformations to symbol primitives:
- height scale
- width factor (widthFactor)
- oblique / shear
- rotation
- translate
- mirroring
- symbol base position (baseline + kerning)
- alignments

## Архитектура / Architecture

```
transform/
├── uzvshxtopdftransform.pas           # Главный модуль / Main module
├── uzvshxtopdftransformtypes.pas      # Типы данных / Data types
├── uzvshxtopdftransformmatrix.pas     # Матричные операции / Matrix operations
├── uzvshxtopdftransformapply.pas      # Применение к Безье / Apply to Bezier
├── uzvshxtopdftransformalign.pas      # Выравнивание / Alignment
├── README.md
└── test/
    ├── uzvshxtopdftransformtestunit.pas    # Unit-тесты примитивов
    ├── uzvshxtopdftransformtestmatrix.pas  # Unit-тесты матриц
    └── uzvshxtopdftransformtestpdf.pas     # Интеграционные тесты
```

## Входные данные / Input Data

### Из Этапа 2 (approgeom):
```pascal
TUzvBezierFont
TUzvBezierGlyph
TUzvBezierPath
TUzvBezierSegment
```

### Параметры трансформации:
```pascal
TUzvTextTransform = record
  Height: Double;           // Высота текста
  WidthFactor: Double;      // Коэффициент ширины
  UnitsPerEm: Double;       // Единицы SHX/EM
  ObliqueDeg: Double;       // Наклон (градусы)
  RotationDeg: Double;      // Поворот (градусы)
  MirrorX: Boolean;         // Зеркалирование по X
  MirrorY: Boolean;         // Зеркалирование по Y
  BasePoint: TPointF;       // Базовая точка вставки
  Kerning: Double;          // Межсимвольный интервал
  AlignmentH: TUzvAlignmentH; // Горизонтальное выравнивание
  AlignmentV: TUzvAlignmentV; // Вертикальное выравнивание
end;
```

## Выходные данные / Output Data

```pascal
TUzvWorldBezierFont = record
  Glyphs: array of TUzvWorldBezierGlyph;
end;

TUzvWorldBezierGlyph = record
  Code: Integer;
  Paths: array of TUzvBezierPath;  // Все точки в мировых координатах
end;
```

## Основной интерфейс / Main Interface

```pascal
function TransformBezierFont(
  const BezierFont: TUzvBezierFont;
  const Transform: TUzvTextTransform
): TUzvWorldBezierFont;
```

## Порядок применения трансформаций / Transformation Order

**ВАЖНО:** Порядок строго фиксирован!

1. Нормализация по `UnitsPerEm`
2. Масштаб по `Height`
3. Масштаб по `WidthFactor`
4. Oblique (shear)
5. Зеркалирование
6. Поворот
7. Выравнивание
8. Перенос в `BasePoint`
9. Кернинг

## Матрица трансформации 3×3 / 3×3 Transformation Matrix

```
| a  b  tx |
| c  d  ty |
| 0  0  1  |
```

Поддерживаемые операции:
- Scale (масштабирование)
- Rotate (поворот)
- Translate (перенос)
- Shear (наклон)
- Mirror X/Y (зеркалирование)
- Matrix multiplication (перемножение)
- Inverse (обратная матрица)

## Выравнивание / Alignment

### Горизонтальное / Horizontal:
- `alLeft` - по левому краю
- `alCenter` - по центру
- `alRight` - по правому краю

### Вертикальное / Vertical:
- `alTop` - по верхнему краю
- `alBaseline` - по базовой линии
- `alBottom` - по нижнему краю

Выравнивание производится по bounding-box всего текста.

## Тесты / Tests

### Unit-тест трансформации примитива (из ТЗ):
- Вход: линия (0,0) → (10,0)
- Применить: height=0.5, widthFactor=2.0, oblique=10°, rotation=45°
- Проверить: координаты результата, отклонение ≤ 0.001

### Unit-тест матриц:
- Корректность перемножения
- Обратная матрица
- Применение к точке
- Зеркалирование X/Y

### Интеграционный тест:
1. Взять шрифт → Этап 1
2. Аппроксимировать → Этап 2
3. Применить трансформации → Этап 3
4. Записать в PDF
5. Визуально проверить

## Логирование / Logging

Используется только встроенный логгер CAD-системы:
```pascal
uses uzclog;

programlog.LogOutFormatStr(
  'Transform: rotation=%f height=%f wf=%f',
  [Transform.RotationDeg, Transform.Height, Transform.WidthFactor],
  LM_Info
);
```

## Зависимости / Dependencies

- `uzvshxtopdfapprogeomtypes` - типы из Этапа 2
- `uzclog` - логирование CAD-системы

## Ограничения / Limitations

Этап 3:
- НЕ выполняет аппроксимацию
- НЕ содержит дуг
- НЕ работает с SHX-командами
- Принимает **исключительно результат Этапа 2**

Прямая работа с SHX считается архитектурным нарушением.
