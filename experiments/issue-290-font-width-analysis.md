# Issue #290: Анализ проблемы с шириной TTF шрифтов / TTF Font Width Problem Analysis

## Проблема / Problem

При изменении высоты текста буквы начинают налагаться друг на друга и слипаться. Это указывает на неправильную ширину символов при масштабировании шрифта.

When text height is changed, letters start overlapping and sticking together. This indicates incorrect character width parameters when scaling fonts.

### Скриншоты / Screenshots

**Сейчас (неправильно) / Current (incorrect)**:
- Символы сжаты и налагаются друг на друга
- Characters are compressed and overlap each other

**Должно быть (правильно) / Expected (correct)**:
- Символы с правильными пропорциями и интервалами
- Characters with correct proportions and spacing

## Корневая причина / Root Cause

### Текущая реализация / Current Implementation

```pascal
// Создание шрифта с фиксированной высотой
// Creating font with fixed height
lfcp.lfHeight:=deffonth;  // deffonth = 100
lfcp.lfWidth:=0;           // 0 = GDI auto-calculates width

// Затем шрифт масштабируется через WorldTransform
// Then font is scaled via WorldTransform
txtSy:=PSymbolsParam^.NeededFontHeight/(rc.DrawingContext.zoom)/(deffonth);
txtSx:=txtSy*PSymbolsParam^.sx;
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
SetWorldTransform_(DC,_transM);  // includes _scaleM
```

### Проблема / Problem

Когда `lfWidth=0`, GDI автоматически рассчитывает ширину символа для **исходного** шрифта высотой 100.

When `lfWidth=0`, GDI automatically calculates character width for the **original** font with height 100.

Затем `WorldTransform` масштабирует:
1. ✅ **Форму глифа** (контуры букв) - работает правильно
2. ❌ **Ширину ячейки символа** (advance width) - может работать некорректно

Then `WorldTransform` scales:
1. ✅ **Glyph shape** (letter outlines) - works correctly
2. ❌ **Character cell width** (advance width) - may not work correctly

**Результат / Result**: При сильном масштабировании (например, txtSx << 1) ширина ячейки символа может не уменьшаться пропорционально, вызывая наложение букв.

With strong scaling (e.g., txtSx << 1), character cell width may not scale proportionally, causing letter overlap.

## GDI Font Width Mechanism

### Параметры TLogFont / TLogFont Parameters

```pascal
lfHeight: Integer;  // Высота шрифта / Font height
lfWidth: Integer;   // Средняя ширина символа / Average character width
```

**Когда lfWidth = 0:**
- GDI выбирает ширину автоматически на основе `lfHeight`
- Ширина рассчитывается для ОРИГИНАЛЬНОГО размера шрифта
- WorldTransform может некорректно масштабировать интервалы между символами

**When lfWidth = 0:**
- GDI chooses width automatically based on `lfHeight`
- Width is calculated for the ORIGINAL font size
- WorldTransform may incorrectly scale character spacing

**Когда lfWidth > 0:**
- GDI создает шрифт с указанной шириной символа
- Ширина учитывается при создании шрифта, до применения трансформаций
- Интервалы между символами рассчитываются правильно

**When lfWidth > 0:**
- GDI creates font with specified character width
- Width is taken into account when creating font, before transformations
- Character spacing is calculated correctly

## Решение / Solution

### Вариант 1: Указать lfWidth явно / Option 1: Specify lfWidth explicitly

Вместо масштабирования фиксированного шрифта, создавать шрифт с правильными размерами:

Instead of scaling a fixed font, create a font with correct dimensions:

```pascal
// Рассчитываем реальную высоту в пикселях
// Calculate real height in pixels
realHeight := round(PSymbolsParam^.NeededFontHeight / rc.DrawingContext.zoom);

// Создаем шрифт с правильными размерами
// Create font with correct dimensions
lfcp.lfHeight := realHeight;
lfcp.lfWidth := round(realHeight * PSymbolsParam^.sx);  // Пропорциональная ширина / Proportional width
```

**Проблема:** Нужно создавать новый HFONT для каждого размера, что дорого по производительности.

**Problem:** Need to create new HFONT for each size, which is expensive for performance.

### Вариант 2: Использовать ExtTextOut с lpDx (рекомендуется) / Option 2: Use ExtTextOut with lpDx (recommended)

ExtTextOut имеет параметр `lpDx` для управления интервалами между символами:

ExtTextOut has `lpDx` parameter for controlling character spacing:

```pascal
function ExtTextOut(DC: HDC; X, Y: Integer; Options: Longint;
  Rect: PRect; Str: PChar; Count: Longint; Dx: PInteger): BOOL;
```

Параметр `Dx: PInteger` - массив расстояний между символами.

`Dx: PInteger` parameter - array of distances between characters.

**Но:** В нашем случае мы отрисовываем по одному символу за раз, поэтому lpDx не поможет.

**But:** In our case we render one character at a time, so lpDx won't help.

### Вариант 3: Установить lfWidth базовый + WorldTransform (оптимальное решение) / Option 3: Set base lfWidth + WorldTransform (optimal solution)

Комбинированный подход:
1. Создать шрифт с базовой шириной символа (не 0)
2. Использовать WorldTransform только для дополнительного масштабирования

Combined approach:
1. Create font with base character width (not 0)
2. Use WorldTransform only for additional scaling

```pascal
// Создаем шрифт с базовой пропорциональной шириной
// Create font with base proportional width
lfcp.lfHeight := deffonth;
lfcp.lfWidth := round(deffonth * 0.5);  // Типичное соотношение / Typical ratio

// Затем масштабируем через WorldTransform
// Then scale via WorldTransform
txtSy := PSymbolsParam^.NeededFontHeight / (rc.DrawingContext.zoom) / (deffonth);
txtSx := txtSy * PSymbolsParam^.sx;
_scaleM := CreateScaleMatrix(CreateVertex(txtSx, txtSy, 1));
```

## Рекомендуемое решение / Recommended Solution

**Установить lfWidth = 0, НО применять scale ТОЛЬКО к lfHeight, а lfEscapement и lfOrientation использовать для rotation**

**Set lfWidth = 0, BUT apply scale ONLY to lfHeight, and use lfEscapement and lfOrientation for rotation**

После анализа документации GDI, лучший подход:

After analyzing GDI documentation, best approach:

```pascal
// Вычисляем ФИНАЛЬНУЮ высоту шрифта в пикселях экрана
// Calculate FINAL font height in screen pixels
realFontHeight := round(PSymbolsParam^.NeededFontHeight / rc.DrawingContext.zoom);

// Создаем шрифт с РЕАЛЬНОЙ высотой (не фиксированной!)
// Create font with REAL height (not fixed!)
lfcp.lfHeight := realFontHeight;
lfcp.lfWidth := 0;  // GDI правильно рассчитает ширину для РЕАЛЬНОЙ высоты / GDI will correctly calculate width for REAL height
lfcp.lfEscapement := round(-txtRotate * 1800 / pi);  // В десятых долях градуса / In tenths of degree
lfcp.lfOrientation := round(-txtRotate * 1800 / pi);

// WorldTransform используем ТОЛЬКО для Oblique и позиционирования
// Use WorldTransform ONLY for Oblique and positioning
_scaleM := OneMatrix;  // НЕТ масштабирования! / NO scaling!
_obliqueM := ...;  // Oblique
_rotateM := OneMatrix;  // НЕТ rotation! Используем lfEscapement / NO rotation! Use lfEscapement
_transplusM := CreateTranslationMatrix(CreateVertex(x, y, 0));
```

**Преимущества / Advantages:**
- ✅ GDI правильно рассчитывает ширину символов для реальной высоты шрифта
- ✅ Не нужно кешировать множество HFONT для разных размеров
- ✅ Rotation через lfEscapement работает лучше, чем через WorldTransform
- ✅ Oblique (shear) остается через WorldTransform

- ✅ GDI correctly calculates character widths for real font height
- ✅ No need to cache multiple HFONTs for different sizes
- ✅ Rotation via lfEscapement works better than via WorldTransform
- ✅ Oblique (shear) remains via WorldTransform

**Недостатки / Disadvantages:**
- ⚠️ Нужно создавать/кешировать HFONT для каждой комбинации (высота, rotation)
- ⚠️ Но это лучше чем неправильное отображение!

- ⚠️ Need to create/cache HFONT for each combination (height, rotation)
- ⚠️ But this is better than incorrect display!

## Итоговое решение / Final Solution

Использовать **lfWidth с явным указанием ширины** на основе `PSymbolsParam^.sx`:

Use **lfWidth with explicit width specification** based on `PSymbolsParam^.sx`:

```pascal
realFontHeight := round(PSymbolsParam^.NeededFontHeight / rc.DrawingContext.zoom);
realFontWidth := round(realFontHeight * PSymbolsParam^.sx);

lfcp.lfHeight := realFontHeight;
lfcp.lfWidth := realFontWidth;  // Явно указываем ширину! / Explicitly specify width!
lfcp.lfEscapement := round(-txtRotate * 1800 / pi);
lfcp.lfOrientation := round(-txtRotate * 1800 / pi);

// WorldTransform используем ТОЛЬКО для Oblique и Translation
// Use WorldTransform ONLY for Oblique and Translation
_scaleM := OneMatrix;  // Масштабирование уже в lfHeight/lfWidth / Scaling already in lfHeight/lfWidth
_obliqueM := ...;  // Oblique через shear / Oblique via shear
_rotateM := OneMatrix;  // Rotation через lfEscapement / Rotation via lfEscapement
_transplusM := CreateTranslationMatrix(CreateVertex(x, y, 0));
```

Это решит проблему с шириной символов, так как GDI будет использовать правильную ширину символа при создании шрифта.

This will solve the character width problem, as GDI will use the correct character width when creating the font.
