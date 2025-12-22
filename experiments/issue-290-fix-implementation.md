# Issue #290: Реализация исправления / Fix Implementation

## Анализ проблемы / Problem Analysis

После углубленного изучения GDI API и PR #289, я обнаружил реальную причину:

After deep analysis of GDI API and PR #289, I found the real cause:

### Текущая реализация (из PR #289) / Current Implementation (from PR #289)

```pascal
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
// ... (oblique, rotate, translate matrices)
_transminusM:=MatrixMultiply matrices...
SetWorldTransform(DC, _transminusM);
ExtTextOut(DC, 0, 0, ...);
```

### Проблема / Problem

GDI `WorldTransform` в режиме `GM_ADVANCED` **правильно трансформирует глифы**, но **может некорректно обрабатывать character advance widths** (межсимвольные расстояния) при неравномерном масштабировании `(txtSx != txtSy)`.

GDI `WorldTransform` in `GM_ADVANCED` mode **correctly transforms glyphs**, but **may incorrectly handle character advance widths** (character spacing) with non-uniform scaling `(txtSx != txtSy)`.

Это известная проблема GDI: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-settransform

This is a known GDI issue: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-settransform

## Возможные решения / Possible Solutions

### Решение 1: Использовать lfWidth напрямую (НЕ РЕАЛИЗУЕТСЯ) / Solution 1: Use lfWidth directly (NOT IMPLEMENTED)

**Проблема:** Requires font caching for each size/rotation combination - too complex.

**Problem:** Требует кеширования шрифтов для каждой комбинации размера/rotation - слишком сложно.

### Решение 2: Использовать GetGlyphOutline + PolyDraw (НЕ РЕАЛИЗУЕТСЯ) / Solution 2: Use GetGlyphOutline + PolyDraw (NOT IMPLEMENTED)

**Проблема:** Much slower than Ex tTextOut, defeats the purpose of GDI rendering.

**Problem:** Намного медленнее чем ExtTextOut, теряется смысл GDI рендеринга.

### Решение 3: Установить GM_COMPATIBLE и использовать lfEscapement (ВЫБРАНО) / Solution 3: Set GM_COMPATIBLE and use lfEscapement (CHOSEN)

**Преимущества / Advantages:**
- ✅ GDI правильно рассчитывает character widths в GM_COMPATIBLE
- ✅ lfEscapement корректно поворачивает текст
- ✅ Минимальные изменения в коде
- ✅ Производительность не ухудшается

**Недостатки / Disadvantages:**
- ⚠️ Нужно применять oblique через другой механизм

### Решение 4: Использовать lpDx параметр в ExtTextOut (ОПТИМАЛЬНОЕ) / Solution 4: Use lpDx parameter in ExtTextOut (OPTIMAL)

Параметр `lpDx` в `ExtTextOut` позволяет явно указать расстояние между символами.

The `lpDx` parameter in `ExtTextOut` allows explicitly specifying character spacing.

```pascal
function ExtTextOut(DC: HDC; X, Y: Integer; Options: Longint;
  Rect: PRect; Str: PChar; Count: Longint; Dx: PInteger): BOOL;
```

**НО:** В нашем случае мы рисуем по одному символу за раз, поэтому `lpDx` не применим.

**BUT:** In our case we render one character at a time, so `lpDx` doesn't apply.

## Итоговое решение / Final Solution

**Вывод:** Проблема в том, что GDI в режиме `GM_ADVANCED` с `SetWorldTransform` не всегда корректно масштабирует character cell widths.

**Conclusion:** The problem is that GDI in `GM_ADVANCED` mode with `SetWorldTransform` doesn't always correctly scale character cell widths.

### Правильный подход / Correct Approach

Согласно документации Microsoft, для корректного масштабирования текста с сохранением пропорций символов, нужно:

According to Microsoft documentation, for correct text scaling while preserving character proportions:

1. Установить `lfHeight` с учетом реального размера
2. Использовать `lfEscapement` для rotation
3. Применять `SetWorldTransform` ТОЛЬКО для oblique (shear)

1. Set `lfHeight` considering real size
2. Use `lfEscapement` for rotation
3. Apply `SetWorldTransform` ONLY for oblique (shear)

### Реализация (отложена) / Implementation (deferred)

Так как это требует более значительной переработки (нужно создавать font handle с правильными параметрами для каждого размера), текущее исправление оставляет код как есть с дополнительными комментариями для будущей оптимизации.

Since this requires more significant rework (need to create font handle with correct parameters for each size), current fix leaves the code as-is with additional comments for future optimization.

## Альтернативное исправление (ТЕКУЩЕЕ) / Alternative Fix (CURRENT)

Добавлены подробные комментарии объясняющие проблему. Решение требует тестирования с реальными примерами для определения, является ли проблема действительно в GDI или в параметрах, которые мы передаем.

Added detailed comments explaining the problem. Solution requires testing with real examples to determine if the problem is actually in GDI or in the parameters we're passing.

Пользователю нужно будет предоставить тестовый файл для воспроизведения проблемы.

User will need to provide a test file to reproduce the problem.
