# Анализ проблемы с масштабированием TTF шрифтов / TTF Font Scaling Issue Analysis

## Проблема / Problem

TTF шрифты отображаются сжатыми по вертикали (compressed vertically), как видно на скриншотах:
- **Текущее состояние**: Глифы выглядят сжатыми
- **Ожидаемое состояние**: Глифы должны иметь правильные пропорции

При увеличении высоты текста (параметр Height) текст начинает "сжиматься сам в себя".

When increasing text height (Height parameter), the text starts "compressing into itself".

## Корневая причина / Root Cause

### Создание шрифта / Font Creation

В `uzgldrawergdi.pas:607-626` шрифт создается с фиксированными параметрами:

```pascal
lfcp.lfHeight:=deffonth;  // deffonth = 100 пикселей
lfcp.lfWidth:=0;          // 0 = автоматическая ширина на основе высоты
```

Когда `lfWidth=0`, GDI **автоматически вычисляет ширину** на основе метрик дизайна шрифта. Это означает, что шрифт уже имеет правильное соотношение сторон.

When `lfWidth=0`, GDI **automatically calculates width** based on font design metrics. This means the font already has correct aspect ratio.

### Применение трансформации / Transformation Application

В `uzgldrawergdi.pas:652-654` вычисляются параметры масштабирования:

```pascal
txtSy:=PSymbolsParam^.NeededFontHeight/(rc.DrawingContext.zoom)/(deffonth);
txtSx:=txtSy*PSymbolsParam^.sx;
```

Затем в строках 686-702 создается матрица трансформации:

```pascal
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
// ... применяется через SetWorldTransform
```

### Проблема / The Problem

1. Шрифт создается с `lfWidth=0` → GDI автоматически устанавливает ширину
2. Затем применяется матрица масштабирования с `txtSx` и `txtSy`
3. Но `txtSx` и `txtSy` **оба зависят от одной и той же базы** (`txtSy`)
4. В результате происходит **некорректное масштабирование**

The font is created with `lfWidth=0` → GDI automatically sets width
Then a scaling matrix is applied with `txtSx` and `txtSy`
But `txtSx` and `txtSy` **both depend on the same base** (`txtSy`)
This results in **incorrect scaling**

## Дополнительный анализ / Additional Analysis

При более детальном изучении обнаружена **РЕАЛЬНАЯ проблема**:

Upon closer inspection, found the **REAL problem**:

### Двойная трансформация координат / Double Coordinate Transformation

В строке 711 вызывается:
```pascal
ExtTextOut(DC, x, y, ...)
```

Но ПЕРЕД этим в строке 707 устанавливается:
```pascal
SetWorldTransform_(DC, _transminusM);
```

**Проблема:** Когда активна world transformation, координаты, переданные в ExtTextOut, **трансформируются ещё раз**!

**Problem:** When world transformation is active, coordinates passed to ExtTextOut are **transformed again**!

Последовательность:
1. (0,0,0) трансформируется в (x,y) через SymMatr и TranslatePoint
2. Матрица _transminusM строится как: T(-x,-y) * Scale * Oblique * Rotate * T(x,y)
3. SetWorldTransform устанавливает эту матрицу
4. ExtTextOut(x,y) → координаты (x,y) трансформируются матрицей → **неверный результат**

Sequence:
1. (0,0,0) is transformed to (x,y) via SymMatr and TranslatePoint
2. Matrix _transminusM is built as: T(-x,-y) * Scale * Oblique * Rotate * T(x,y)
3. SetWorldTransform sets this matrix
4. ExtTextOut(x,y) → coordinates (x,y) are transformed by matrix → **incorrect result**

## Решение / Solution

Использовать (0,0) в ExtTextOut, так как матрица трансформации уже содержит позиционирование!

Use (0,0) in ExtTextOut, since the transformation matrix already contains positioning!

Изменить строку 711:
```pascal
// Было / Was:
ExtTextOut(DC, x, y, ...)

// Должно быть / Should be:
ExtTextOut(DC, 0, 0, ...)
```

Матрица _transminusM уже правильно построена для трансформации точки (0,0) в финальную позицию с масштабом, наклоном и поворотом.

Matrix _transminusM is already correctly built to transform point (0,0) to final position with scale, oblique, and rotation.

## Реализация / Implementation

Изменить вызов ExtTextOut с (x,y) на (0,0).

Change ExtTextOut call from (x,y) to (0,0).

## Ожидаемый результат / Expected Result

- ✅ TTF шрифты будут отображаться с правильными пропорциями
- ✅ Параметр Height будет корректно влиять на размер
- ✅ Width factor (sx) будет правильно применяться
- ✅ SHX шрифты продолжат работать корректно

- ✅ TTF fonts will display with correct proportions
- ✅ Height parameter will correctly affect size
- ✅ Width factor (sx) will be applied correctly
- ✅ SHX fonts will continue to work correctly
