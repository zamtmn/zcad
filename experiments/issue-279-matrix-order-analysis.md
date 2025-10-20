# Issue #279: Анализ проблемы с порядком умножения матриц в TLLGDISymbol.drawSymbol

## Описание проблемы
При включенном рендеринге GDI все текстовые символы собираются около координаты 0,0,0 вместо отображения в правильных позициях.

## Предыдущая попытка исправления (PR #280)
Был изменен вызов ExtTextOut с использования координат (x,y) на (0,0), предполагая, что world transformation уже содержит перемещение к нужной позиции.

**Результат:** Проблема не решена - текст все еще отображается около начала координат.

## Анализ корневой причины

### Текущий код (строки 600-617 в uzgldrawergdi.pas):

```pascal
_transminusM:=CreateTranslationMatrix(CreateVertex(-x,-y,0));
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
_obliqueM := ... // shear matrix if needed, else identity
_transplusM:=CreateTranslationMatrix(CreateVertex(x,y,0));
_rotateM:=CreateRotationMatrixZ(-txtRotate);

_transminusM:=MatrixMultiply(_transminusM,_scaleM);
_transminusM:=MatrixMultiply(_transminusM,_obliqueM);
_transminusM:=MatrixMultiply(_transminusM,_rotateM);
_transminusM:=MatrixMultiply(_transminusM,_transplusM);
```

Это создает матрицу: `M = T(-x,-y) * Scale * Oblique * Rotate * T(x,y)`

### Проблема: неправильный порядок умножения матриц

При применении к точке (0,0) операции выполняются **справа налево**:

```
Point(0,0) * M = Point(0,0) * [T(-x,-y) * Scale * Oblique * Rotate * T(x,y)]
```

Пошаговое выполнение:
1. `T(x,y) * (0,0)` → (x,y) - переместить к целевой позиции
2. `Rotate * (x,y)` → поворот вокруг начала координат, не вокруг (x,y)!
3. `Oblique * result` → наклон
4. `Scale * result` → масштабирование
5. `T(-x,-y) * result` → обратно к началу координат

**Результат:** Текст оказывается около (0,0) после всех преобразований!

### Правильный порядок

Для преобразования вокруг точки (x,y) нужен обратный порядок:

```
M = T(x,y) * Rotate * Oblique * Scale * T(-x,-y)
```

При применении к точке (0,0):
1. `T(-x,-y) * (0,0)` → (-x,-y) - переместить к началу координат
2. `Scale * (-x,-y)` → масштабирование вокруг начала координат
3. `Oblique * result` → наклон вокруг начала координат
4. `Rotate * result` → поворот вокруг начала координат
5. `T(x,y) * result` → переместить к целевой позиции

Или, если применять преобразования локально к точке в (0,0), а затем позиционировать:
```
M = T(x,y) * Rotate * Oblique * Scale
```

И рисовать в (0,0), так как T(x,y) в конце уже позиционирует результат.

## Решение

Нужно изменить порядок умножения матриц на обратный:

```pascal
_transminusM:=CreateTranslationMatrix(CreateVertex(-x,-y,0));
_scaleM:=CreateScaleMatrix(CreateVertex(txtSx,txtSy,1));
_obliqueM := ...
_transplusM:=CreateTranslationMatrix(CreateVertex(x,y,0));
_rotateM:=CreateRotationMatrixZ(-txtRotate);

// ПРАВИЛЬНЫЙ порядок - справа налево:
_transminusM:=_transplusM;                                    // начать с T(x,y)
_transminusM:=MatrixMultiply(_transminusM,_rotateM);          // T(x,y) * Rotate
_transminusM:=MatrixMultiply(_transminusM,_obliqueM);         // T(x,y) * Rotate * Oblique
_transminusM:=MatrixMultiply(_transminusM,_scaleM);           // T(x,y) * Rotate * Oblique * Scale
_transminusM:=MatrixMultiply(_transminusM,CreateTranslationMatrix(CreateVertex(-x,-y,0)));
// T(x,y) * Rotate * Oblique * Scale * T(-x,-y)
```

Или еще проще - убрать T(-x,-y) и T(x,y) из композиции, оставив только:
```pascal
_transminusM:=_scaleM;                              // начать с Scale
_transminusM:=MatrixMultiply(_transminusM,_obliqueM);  // Scale * Oblique
_transminusM:=MatrixMultiply(_transminusM,_rotateM);   // Scale * Oblique * Rotate
_transminusM:=MatrixMultiply(_transminusM,_transplusM); // Scale * Oblique * Rotate * T(x,y)
```

При этом точка (0,0):
1. Масштабируется → (0,0)
2. Наклоняется → (0,0)
3. Поворачивается → (0,0)
4. Перемещается к (x,y) → (x,y)

Это правильно!

## Файлы для изменения
- `cad_source/zengine/zgl/gdi/uzgldrawergdi.pas` (строки 600-617)
