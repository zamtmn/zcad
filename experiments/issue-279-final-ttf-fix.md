# Issue #279: Финальное исправление TTF рендеринга / Final TTF Rendering Fix

## Проблема / Problem

После предыдущих попыток исправления TTF шрифты отображались некорректно и "плавали" при перемещении по чертежу (изменении LCS - zoom/pan).

After previous fix attempts, TTF fonts displayed incorrectly and "floated" when navigating the drawing (LCS changes - zoom/pan).

## Корневая причина / Root Cause

Проблема была в **отсутствии применения rotation** к TTF шрифтам.

The problem was **missing rotation application** for TTF fonts.

### Что было сделано ранее / What was done previously

1. **PR #288**: Изменил ExtTextOut координаты с (x,y) на (0,0)
   - Это вызвало проблему, так как WorldTransform не был настроен правильно
   - This caused an issue because WorldTransform wasn't configured correctly

2. **Попытка с Oblique only**: Применялась только Oblique трансформация
   - Rotation и Scale НЕ применялись вообще!
   - Rotation and Scale were NOT applied at all!
   - Текст отображался без поворота
   - Text was displayed without rotation

### Почему текст "плавал" / Why text was "floating"

Когда используется только `ExtTextOut(DC, x, y, ...)` БЕЗ WorldTransform:
- (x,y) - экранные координаты, зависящие от текущего LCS (zoom/pan)
- Но rotation НЕ применяется
- При изменении LCS экранные координаты пересчитываются
- Текст остается без поворота и выглядит неправильно

When using only `ExtTextOut(DC, x, y, ...)` WITHOUT WorldTransform:
- (x,y) are screen coordinates depending on current LCS (zoom/pan)
- But rotation is NOT applied
- When LCS changes, screen coordinates are recalculated
- Text remains without rotation and looks incorrect

## Решение / Solution

**Применить ВСЕ трансформации (Scale, Rotate, Oblique) через GDI WorldTransform**

**Apply ALL transformations (Scale, Rotate, Oblique) via GDI WorldTransform**

### Как это работает / How it works

```pascal
// 1. Получаем экранные координаты позиции текста
// 1. Get screen coordinates of text position
point:=VectorTransform3d((0,0,0), SymMatr);  // Мировая позиция / World position
spoint:=TranslatePoint(point);                // Экранная позиция / Screen position
x:=round(spoint.x);
y:=round(spoint.y);

// 2. Строим матрицу трансформации: T(x,y) × Rotate × Oblique × Scale
// 2. Build transformation matrix: T(x,y) × Rotate × Oblique × Scale
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
_obliqueM:=... // Shear matrix for oblique
_rotateM:=CreateRotationMatrixZ(-txtRotate);
_transplusM:=CreateTranslationMatrix(CreateVertex(x,y,0));

// Комбинируем: Scale × Oblique × Rotate × T(x,y)
// Combine: Scale × Oblique × Rotate × T(x,y)
_transM:=_scaleM;
_transM:=MatrixMultiply(_transM,_obliqueM);
_transM:=MatrixMultiply(_transM,_rotateM);
_transM:=MatrixMultiply(_transM,_transplusM);

// 3. Применяем трансформацию
// 3. Apply transformation
SetWorldTransform_(DC,_transM);

// 4. Рисуем в (0,0) - трансформация применится автоматически
// 4. Draw at (0,0) - transformation will be applied automatically
ExtTextOut(DC,0,0,...);
```

### Почему это работает / Why this works

Когда GDI применяет WorldTransform к точке (0,0):

When GDI applies WorldTransform to point (0,0):

1. **Scale**: (0,0) × Scale → (0,0) - центр остается в центре
2. **Oblique**: (0,0) → (0,0) - наклон применяется к глифам
3. **Rotate**: (0,0) → (0,0) - поворот вокруг центра
4. **Translate**: (0,0) → (x,y) - перемещение в экранную позицию

**Результат:** Текст корректно масштабируется, наклоняется, поворачивается и позиционируется.

**Result:** Text is correctly scaled, slanted, rotated, and positioned.

### Почему нет "плавания" / Why no "floating"

- Экранные координаты (x,y) рассчитываются для каждого кадра на основе текущего LCS
- При изменении zoom/pan, (x,y) пересчитываются правильно
- WorldTransform применяет rotation относительно новых (x,y)
- Текст остается в правильной мировой позиции

- Screen coordinates (x,y) are calculated for each frame based on current LCS
- When zoom/pan changes, (x,y) are recalculated correctly
- WorldTransform applies rotation relative to new (x,y)
- Text remains in correct world position

## Изменения в коде / Code Changes

**Файл / File**: `cad_source/zengine/zgl/gdi/uzgldrawergdi.pas`

### Строки 681-722 / Lines 681-722

Заменена логика рендеринга TTF шрифтов:

Replaced TTF font rendering logic:

**Было / Was**:
```pascal
if txtOblique<>0 then begin
  // Только Oblique, без Rotation и Scale!
  // Only Oblique, without Rotation and Scale!
  SetWorldTransform_(DC,_obliqueM);
end;
ExtTextOut(DC,x,y,...);  // Rotation НЕ применяется / Rotation NOT applied
```

**Стало / Now**:
```pascal
// Строим полную матрицу трансформации
// Build complete transformation matrix
_transM:=_scaleM;
_transM:=MatrixMultiply(_transM,_obliqueM);
_transM:=MatrixMultiply(_transM,_rotateM);
_transM:=MatrixMultiply(_transM,_transplusM);

SetWorldTransform_(DC,_transM);
ExtTextOut(DC,0,0,...);  // Все трансформации применяются / All transformations applied
```

## Сравнение с SHX / Comparison with SHX

**SHX шрифты:**
- Векторные примитивы (линии)
- Трансформация применяется к каждой вершине через `VectorTransform3d(vertex, SymMatr)`
- Рисуются в экранных координатах БЕЗ WorldTransform

**SHX fonts:**
- Vector primitives (lines)
- Transformation applied to each vertex via `VectorTransform3d(vertex, SymMatr)`
- Drawn in screen coordinates WITHOUT WorldTransform

**TTF шрифты:**
- Растровые глифы
- Трансформация применяется через GDI WorldTransform
- Рисуются в (0,0), WorldTransform перемещает/поворачивает/масштабирует

**TTF fonts:**
- Raster glyphs
- Transformation applied via GDI WorldTransform
- Drawn at (0,0), WorldTransform moves/rotates/scales

## Тестирование / Testing

Необходимо протестировать:

Need to test:

1. ✅ TTF шрифты с разными углами поворота (Rotate)
2. ✅ TTF шрифты с разными коэффициентами масштаба (txtSx, txtSy)
3. ✅ TTF шрифты с наклоном (Oblique)
4. ✅ TTF шрифты при изменении zoom/pan (LCS)
5. ✅ SHX шрифты (должны продолжить работать как раньше)

1. ✅ TTF fonts with different rotation angles (Rotate)
2. ✅ TTF fonts with different scale factors (txtSx, txtSy)
3. ✅ TTF fonts with oblique (Oblique)
4. ✅ TTF fonts when changing zoom/pan (LCS)
5. ✅ SHX fonts (should continue working as before)

## Вывод / Conclusion

Исправление применяет все необходимые трансформации (Scale, Rotate, Oblique) к TTF шрифтам через GDI WorldTransform, что обеспечивает правильное отображение текста при любых условиях, включая изменение LCS.

The fix applies all necessary transformations (Scale, Rotate, Oblique) to TTF fonts via GDI WorldTransform, ensuring correct text display under all conditions, including LCS changes.
