# Issue #279: TTF Font LCS Transformation Analysis

## Проблема / Problem

TTF шрифты некорректно отображаются при включенном GDI рендеринге. Текст реагирует на изменения LCS (Local Coordinate System) и "плавает" при перемещении по чертежу.

TTF fonts display incorrectly with GDI rendering enabled. Text reacts to LCS (Local Coordinate System) changes and "floats" when navigating the drawing.

## Корневая причина / Root Cause

Текущий код смешивает трансформации в мировых и экранных координатах:

Current code mixes transformations in world and screen coordinates:

```pascal
// Строки 634-640 / Lines 634-640
point.x:=0;
point.y:=0;
point.z:=0;
point:=VectorTransform3d(point,self.SymMatr);  // Трансформация в мировых координатах
spoint:=TZGLGDIDrawer(drawer).TranslatePoint(point);  // Конвертация в экранные координаты
x:=round(spoint.x);
y:=round(spoint.y);

// Строки 685-702 / Lines 685-702
_transminusM:=CreateTranslationMatrix(CreateVertex(-x,-y,0));  // Используем экранные координаты
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
_obliqueM:=... // Наклон
_rotateM:=CreateRotationMatrixZ(-txtRotate);
_transplusM:=CreateTranslationMatrix(CreateVertex(x,y,0));

// Применяем: T(-x,-y) × Scale × Oblique × Rotate × T(x,y)
_transminusM:=MatrixMultiply(_transminusM,_scaleM);
_transminusM:=MatrixMultiply(_transminusM,_obliqueM);
_transminusM:=MatrixMultiply(_transminusM,_rotateM);
_transminusM:=MatrixMultiply(_transminusM,_transplusM);

SetWorldTransform_(DC,_transminusM);
ExtTextOut(DC,0,0,...);  // Рисуем в (0,0)
```

**Проблема:**
1. `SymMatr` содержит полную трансформацию символа в мировых координатах (позиция, поворот, масштаб)
2. Мы применяем `SymMatr` к точке (0,0,0) и получаем экранную позицию (x,y)
3. Затем строим матрицу трансформации ВОКРУГ экранной позиции (x,y)
4. Но экранные координаты уже учитывают zoom/pan LCS, поэтому при изменении LCS текст "плавает"

**Problem:**
1. `SymMatr` contains full symbol transformation in world coordinates (position, rotation, scale)
2. We apply `SymMatr` to point (0,0,0) and get screen position (x,y)
3. Then we build transformation matrix AROUND screen position (x,y)
4. But screen coordinates already account for zoom/pan LCS, so when LCS changes, text "floats"

## Правильное решение / Correct Solution

Для GDI WorldTransform нужно построить матрицу, которая:
1. Применяет все трансформации символа в МИРОВЫХ координатах
2. Затем конвертирует результат в ЭКРАННЫЕ координаты

For GDI WorldTransform we need to build a matrix that:
1. Applies all symbol transformations in WORLD coordinates
2. Then converts the result to SCREEN coordinates

### Вариант 1: Использовать SymMatr напрямую / Option 1: Use SymMatr directly

```pascal
// SymMatr уже содержит все мировые трансформации
// Нужно только преобразовать в экранные координаты и применить GDI трансформацию
worldToScreenMatrix := GetWorldToScreenMatrix(drawer);
gdiMatrix := SymMatr * worldToScreenMatrix;
SetWorldTransform_(DC, gdiMatrix);
ExtTextOut(DC, 0, 0, ...);
```

Но это сложно, так как нужно получить матрицу world-to-screen.

### Вариант 2: Вернуться к использованию (x,y) в ExtTextOut / Option 2: Return to using (x,y) in ExtTextOut

Исходный код (до PR #288) работал так:
```pascal
SetWorldTransform_(DC, T(-x,-y) × Scale × Oblique × Rotate × T(x,y));
ExtTextOut(DC, x, y, ...);
```

Когда GDI применяет WorldTransform к точке (x,y):
1. T(x,y): (x,y) → (2x, 2y)
2. Rotate: поворот вокруг (0,0)
3. Oblique: наклон
4. Scale: масштабирование
5. T(-x,-y): смещение назад

Это тоже неправильно, так как поворот происходит вокруг (0,0), а не вокруг (x,y).

### Вариант 3: Правильная матрица для локальных трансформаций / Option 3: Correct matrix for local transformations

Для правильной трансформации вокруг точки (x,y) матрица должна быть:

For correct transformation around point (x,y), the matrix should be:
```
M = T(x,y) × Rotate × Oblique × Scale × T(0,0)
```

И точка рисования должна быть (0,0).

And drawing point should be (0,0).

Но WAIT! Мы уже пробовали это и это не сработало. Проблема в том, что:
- x,y - это экранные координаты, которые зависят от LCS
- При изменении zoom/pan экранные координаты меняются
- Поэтому текст "плавает"

But WAIT! We already tried this and it didn't work. The problem is:
- x,y are screen coordinates that depend on LCS
- When zoom/pan changes, screen coordinates change
- Therefore text "floats"

## Настоящая проблема / Real Problem

**Ключевое понимание:** GDI WorldTransform работает в DEVICE COORDINATES (пиксели экрана), а не в логических координатах!

**Key insight:** GDI WorldTransform works in DEVICE COORDINATES (screen pixels), not logical coordinates!

Когда мы используем `TranslatePoint`, мы уже учитываем LCS (zoom, pan). Поэтому если мы строим GDI матрицу с этими координатами, при изменении LCS текст будет трансформироваться дважды:
1. Через `TranslatePoint` (который учитывает новый LCS)
2. Через GDI WorldTransform (который все еще использует старые координаты)

When we use `TranslatePoint`, we already account for LCS (zoom, pan). So if we build GDI matrix with these coordinates, when LCS changes text will be transformed twice:
1. Through `TranslatePoint` (which accounts for new LCS)
2. Through GDI WorldTransform (which still uses old coordinates)

## Решение / Solution

**Для TTF шрифтов НЕ нужно использовать WorldTransform с предварительно рассчитанными экранными координатами!**

**For TTF fonts we should NOT use WorldTransform with pre-calculated screen coordinates!**

Вместо этого нужно:
1. Применить SymMatr для получения экранной позиции (x,y)
2. НЕ использовать WorldTransform для дополнительных трансформаций
3. Применить только Scale и Oblique через WorldTransform БЕЗ Translation и Rotation
4. Рисовать в точке (x,y) с правильным углом через lfEscapement в LogFont

Instead:
1. Apply SymMatr to get screen position (x,y)
2. Do NOT use WorldTransform for additional transformations
3. Apply only Scale and Oblique through WorldTransform WITHOUT Translation and Rotation
4. Draw at point (x,y) with correct angle via lfEscapement in LogFont

**Но это тоже не совсем правильно...**

Давайте посмотрим, как работают SHX шрифты - они работают корректно!

Let's look at how SHX fonts work - they work correctly!

## Анализ SHX рендеринга / SHX Rendering Analysis

```pascal
RenderSHXPrimitivesWithGDI(DC, FontData, ..., SymMatr, drawer);
```

В `RenderSHXPrimitivesWithGDI`:
```pascal
// Применяем трансформацию символа к вершинам
v1:=VectorTransform3d(pv1^,Transform);  // Transform = SymMatr
v2:=VectorTransform3d(pv2^,Transform);

// Преобразуем в экранные координаты
v1:=ScreenTransform.TranslatePoint(v1);
v2:=ScreenTransform.TranslatePoint(v2);

// Рисуем линию в экранных координатах
MoveToEx(DC,round(v1.x),round(v1.y),nil);
LineTo(DC,round(v2.x),round(v2.y));
```

**SHX работает так:**
1. Применяет SymMatr к каждой вершине
2. Конвертирует в экранные координаты
3. Рисует в экранных координатах БЕЗ WorldTransform

**SHX works like this:**
1. Applies SymMatr to each vertex
2. Converts to screen coordinates
3. Draws in screen coordinates WITHOUT WorldTransform

## Правильное решение для TTF / Correct Solution for TTF

**TTF должен работать аналогично SHX:**

**TTF should work similarly to SHX:**

1. Применить SymMatr к точке (0,0,0) → получить мировую позицию
2. Конвертировать в экранные координаты (x,y)
3. Рисовать в (x,y) БЕЗ WorldTransform, но с правильным LogFont

```pascal
// Получаем экранную позицию (уже делается)
point:=VectorTransform3d((0,0,0), SymMatr);
spoint:=TranslatePoint(point);
x:=round(spoint.x);
y:=round(spoint.y);

// Создаем шрифт с правильными параметрами
lfcp.lfHeight:=round(txtSy * deffonth);
lfcp.lfWidth:=round(txtSx * deffonth);  // Width factor!
lfcp.lfEscapement:=round(txtRotate * 1800 / pi);  // Rotation in tenths of degree
lfcp.lfOrientation:=round(txtRotate * 1800 / pi);

// НЕ используем SetWorldTransform!
// Рисуем напрямую в экранных координатах
ExtTextOut(DC, x, y, ...);
```

Но ПРОБЛЕМА: LogFont не поддерживает Oblique (наклон) через lfItalic - это другое.
Oblique нужно делать через WorldTransform.

But PROBLEM: LogFont doesn't support Oblique (slant) via lfItalic - that's different.
Oblique needs to be done via WorldTransform.

## Финальное решение / Final Solution

Комбинированный подход:

Combined approach:

```pascal
// 1. Получаем экранную позицию
point:=VectorTransform3d((0,0,0), SymMatr);
spoint:=TranslatePoint(point);
x:=round(spoint.x);
y:=round(spoint.y);

// 2. Применяем ТОЛЬКО Oblique через WorldTransform (если нужно)
if txtOblique <> 0 then begin
  _obliqueM.CreateRec(OneMtr,CMTShear);
  _obliqueM.mtr[1].v[0]:=-cotan(txtOblique);
  SetGraphicsMode_(DC, GM_ADVANCED);
  SetWorldTransform_(DC, _obliqueM);
end;

// 3. Создаем шрифт с правильными параметрами (Scale и Rotate в LogFont)
lfcp.lfHeight:=round(txtSy * deffonth);
lfcp.lfWidth:=round(txtSx * lfcp.lfHeight);  // Width = Height * sx
lfcp.lfEscapement:=round(txtRotate * 1800 / pi);

// 4. Рисуем в экранных координатах
ExtTextOut(DC, x, y, ...);

// 5. Восстанавливаем режим
if txtOblique <> 0 then begin
  SetWorldTransform_(DC, OneMatrix);
  SetGraphicsMode_(DC, GM_COMPATIBLE);
end;
```

Это должно работать правильно!

This should work correctly!
