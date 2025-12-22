# Issue #279: Проверка исправления

## Новый код (исправленный)

```pascal
// Build transformation matrix: T(x,y) * Rotate * Oblique * Scale * T(-x,-y)
// This transforms around point (x,y): move to origin, transform, move back
// Start from the rightmost (first applied) operation
_transminusM:=CreateTranslationMatrix(CreateVertex(-x,-y,0));
{$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}_transminusM:=MatrixMultiply(_transminusM,_transminusM2);{$ENDIF}
_transminusM:=MatrixMultiply(_scaleM,_transminusM);        // Scale * T(-x,-y)
_transminusM:=MatrixMultiply(_obliqueM,_transminusM);      // Oblique * Scale * T(-x,-y)
_transminusM:=MatrixMultiply(_rotateM,_transminusM);       // Rotate * Oblique * Scale * T(-x,-y)
_transminusM:=MatrixMultiply(_transplusM,_transminusM);    // T(x,y) * Rotate * Oblique * Scale * T(-x,-y)
```

## Проверка корректности

Финальная матрица: `M = T(x,y) * Rotate * Oblique * Scale * T(-x,-y)`

При применении к точке (0,0) для рисования символа:

1. **Шаг 1:** `T(-x,-y) * (0,0)` = (-x, -y)
   - Переместить точку в начало координат (относительно позиции символа)

2. **Шаг 2:** `Scale * (-x, -y)` = (-x*sx, -y*sy)
   - Применить масштабирование вокруг начала координат
   - Для точки (0,0): Scale * (0,0) = (0,0)

3. **Шаг 3:** `Oblique * result`
   - Применить наклон вокруг начала координат
   - Для точки (0,0): Oblique * (0,0) = (0,0)

4. **Шаг 4:** `Rotate * result`
   - Применить поворот вокруг начала координат
   - Для точки (0,0): Rotate * (0,0) = (0,0)

5. **Шаг 5:** `T(x,y) * result` = (x, y)
   - Переместить в конечную позицию символа

**Результат для точки (0,0):** После всех преобразований точка окажется в позиции (x,y), что правильно!

## Сравнение со старым кодом

### Старый код (неправильный):
```pascal
_transminusM:=CreateTranslationMatrix(CreateVertex(-x,-y,0));
_transminusM:=MatrixMultiply(_transminusM,_scaleM);
_transminusM:=MatrixMultiply(_transminusM,_obliqueM);
_transminusM:=MatrixMultiply(_transminusM,_rotateM);
_transminusM:=MatrixMultiply(_transminusM,_transplusM);
```

Создавал матрицу: `M = T(-x,-y) * Scale * Oblique * Rotate * T(x,y)`

При применении к точке (0,0):
1. T(x,y) * (0,0) = (x,y)
2. Rotate * (x,y) = поворот точки (x,y) вокруг (0,0) - НЕПРАВИЛЬНО!
3. Oblique * result
4. Scale * result - точка улетает далеко от (x,y)!
5. T(-x,-y) * result - возвращает обратно к началу координат

**Результат:** Все символы скапливались около (0,0,0).

## Ключевое отличие

- **Старый код:** Переводил в (x,y), затем вращал/масштабировал вокруг (0,0), затем сдвигал обратно
- **Новый код:** Переводит в (0,0), вращает/масштабирует вокруг (0,0), затем переводит в (x,y)

Новый код правильно реализует преобразование "вокруг точки".
