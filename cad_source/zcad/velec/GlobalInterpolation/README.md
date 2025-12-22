# Global Interpolation Module / Модуль глобальной интерполяции

## Описание / Description

**Russian:**
Модуль глобальной интерполяции NURBS-кривых, портированный из библиотеки LNLib (C++) в FreePascal/Lazarus для проекта ZCAD.

Реализует алгоритмы глобальной интерполяции из книги "The NURBS Book" 2nd Edition (Piegl & Tiller).

**English:**
NURBS curve global interpolation module, ported from LNLib library (C++) to FreePascal/Lazarus for ZCAD project.

Implements global interpolation algorithms from "The NURBS Book" 2nd Edition (Piegl & Tiller).

## Источник / Source

Основано на реализации из LNLib:
Based on implementation from LNLib:
- Repository: https://github.com/BIMCoderLiang/LNLib
- File: `src/LNLib/Geometry/Curve/NurbsCurve.cpp`
- Functions: `GlobalInterpolation` (two overloads)

## Файлы модуля / Module Files

```
cad_source/zcad/velec/GlobalInterpolation/
├── uGlobalInterpolation.pas      # Основной модуль / Main module
├── examples/
│   └── test_global_interpolation.pas  # Тестовая программа / Test program
└── README.md                     # Эта документация / This documentation
```

## API Функции / API Functions

### 1. GlobalInterpolation (Basic Version / Базовая версия)

```pascal
procedure GlobalInterpolation(
  const ADegree: Integer;
  const AThroughPoints: array of TzePoint3d;
  var ACurve: TNurbsCurveData;
  const AParams: array of Double
); overload;
```

**Описание / Description:**
Вычисляет NURBS-кривую заданной степени, которая точно проходит через все указанные точки.
Computes a NURBS curve of given degree that passes exactly through all specified points.

**Параметры / Parameters:**
- `ADegree`: Степень кривой (должна быть >= 1) / Curve degree (must be >= 1)
- `AThroughPoints`: Массив точек, через которые должна пройти кривая / Array of points the curve should pass through
- `ACurve`: Выходная структура с данными кривой / Output curve data structure
- `AParams`: Опциональные параметры (если пустой - используется хордовая параметризация) / Optional parameters (if empty - chord parameterization is used)

**Алгоритм / Algorithm:**
Соответствует Algorithm A9.1 из "The NURBS Book" (Piegl & Tiller).
Corresponds to Algorithm A9.1 from "The NURBS Book" (Piegl & Tiller).

**Пример использования / Usage Example:**

```pascal
var
  points: array[0..3] of TzePoint3d;
  curve: TNurbsCurveData;
begin
  // Определение точек интерполяции
  // Define interpolation points
  points[0] := CreatePoint3d(0.0, 0.0, 0.0);
  points[1] := CreatePoint3d(1.0, 1.0, 0.0);
  points[2] := CreatePoint3d(2.0, 0.5, 0.0);
  points[3] := CreatePoint3d(3.0, 1.5, 0.0);

  // Вызов глобальной интерполяции
  // Call global interpolation
  GlobalInterpolation(3, points, curve, []);

  // Результат: кривая степени 3 с 4 контрольными точками
  // Result: degree 3 curve with 4 control points
end;
```

### 2. GlobalInterpolation (With Tangents / С касательными)

```pascal
procedure GlobalInterpolation(
  const ADegree: Integer;
  const AThroughPoints: array of TzePoint3d;
  const ATangents: array of TzePoint3d;
  const ATangentFactor: Double;
  var ACurve: TNurbsCurveData
); overload;
```

**Описание / Description:**
Вычисляет NURBS-кривую, которая проходит через заданные точки и имеет указанные касательные векторы в этих точках.
Computes a NURBS curve that passes through specified points and has given tangent vectors at those points.

**Параметры / Parameters:**
- `ADegree`: Степень кривой (должна быть >= 2) / Curve degree (must be >= 2)
- `AThroughPoints`: Массив точек интерполяции / Array of interpolation points
- `ATangents`: Касательные векторы в каждой точке / Tangent vectors at each point
- `ATangentFactor`: Множитель для касательных (должен быть > 0) / Multiplier for tangents (must be > 0)
- `ACurve`: Выходная структура с данными кривой / Output curve data structure

**Особенности / Features:**
- Количество контрольных точек удваивается (2 * количество точек интерполяции)
- Number of control points doubles (2 * number of interpolation points)
- Касательные векторы автоматически нормализуются
- Tangent vectors are automatically normalized
- Вектор узлов строится специальным образом в зависимости от степени кривой
- Knot vector is constructed specially depending on curve degree

**Пример использования / Usage Example:**

```pascal
var
  points: array[0..3] of TzePoint3d;
  tangents: array[0..3] of TzePoint3d;
  curve: TNurbsCurveData;
begin
  // Определение точек и касательных
  // Define points and tangents
  points[0] := CreatePoint3d(0.0, 0.0, 0.0);
  tangents[0] := CreatePoint3d(1.0, 0.0, 0.0);
  // ... остальные точки и касательные
  // ... other points and tangents

  // Вызов интерполяции с касательными
  // Call interpolation with tangents
  GlobalInterpolation(3, points, tangents, 1.0, curve);

  // Результат: кривая степени 3 с 8 контрольными точками
  // Result: degree 3 curve with 8 control points
end;
```

## Типы данных / Data Types

### TNurbsCurveData

```pascal
type
  TNurbsCurveData = record
    Degree: Integer;                      // Степень кривой / Curve degree
    KnotVector: TKnotsVector;             // Вектор узлов / Knot vector
    ControlPoints: TControlPointsArray;   // Контрольные точки / Control points
  end;
```

## Зависимости / Dependencies

Модуль использует следующие существующие модули ZCAD:
Module uses the following existing ZCAD modules:

- `uzegeometrytypes` - Типы точек и векторов / Point and vector types
- `uzeNURBSTypes` - Типы NURBS (TKnotsVector, TControlPointsArray) / NURBS types
- `uzcLog` - Система логирования / Logging system

## Внутренние вспомогательные функции / Internal Helper Functions

Модуль включает портированные из LNLib вспомогательные функции:
Module includes helper functions ported from LNLib:

1. **GetKnotSpanIndex** - Поиск индекса интервала узлов (Algorithm A2.1) / Knot span index search
2. **BasisFunctionsArray** - Вычисление базисных функций (Algorithm A2.2) / Basis functions computation
3. **BasisFunctionsDerivatives** - Вычисление производных базисных функций (Algorithm A2.3) / Basis function derivatives
4. **GetChordParameterization** - Хордовая параметризация / Chord length parameterization
5. **AverageKnotVector** - Генерация вектора узлов методом усреднения (Algorithm A9.1) / Knot vector generation by averaging
6. **GetTotalChordLength** - Вычисление общей длины хорд / Total chord length computation
7. **SolveLinearSystem** - Решение системы линейных уравнений / Linear system solver
8. **NormalizeVector** - Нормализация вектора / Vector normalization

## Логирование / Logging

Все функции модуля используют систему логирования `uzcLog` с уровнем `LM_Info`.
All module functions use `uzcLog` logging system with `LM_Info` level.

Логируемые события:
Logged events:
- Начало интерполяции с параметрами / Interpolation start with parameters
- Вычисление параметризации / Parameterization computation
- Генерация вектора узлов / Knot vector generation
- Построение матрицы интерполяции / Interpolation matrix construction
- Решение системы уравнений / System solution
- Успешное завершение с результатами / Successful completion with results

Пример вывода в лог:
Example log output:
```
GlobalInterpolation: Start with 7 points, degree=3
GlobalInterpolation: Computing chord parameterization
GlobalInterpolation: Generating knot vector
GlobalInterpolation: Building interpolation matrix 7x7
GlobalInterpolation: Solving linear system
GlobalInterpolation: Success - generated 7 control points, 11 knots
```

## Сборка и тестирование / Build and Testing

### Компиляция тестовой программы / Compiling Test Program

```bash
cd cad_source/zcad/velec/GlobalInterpolation/examples
fpc -Fu../../.. -Fu../../../zengine/core/entities -Fu../../../components/zbaseutils -Fu.. test_global_interpolation.pas
```

### Запуск тестов / Running Tests

```bash
./test_global_interpolation
```

Тестовая программа включает 5 наборов тестов:
Test program includes 5 test suites:
1. Базовая интерполяция простой кривой / Basic interpolation of simple curve
2. Интерполяция сложной кривой из 7 точек / Interpolation of complex 7-point curve
3. Интерполяция с касательными векторами / Interpolation with tangent constraints
4. Тестирование различных степеней кривых / Testing different curve degrees
5. Проверка обработки ошибок / Error handling checks

## Ограничения и особенности / Limitations and Features

**Russian:**
1. Максимальная степень кривой: 20 (NURBS_MAX_DEGREE)
2. Минимальная степень для базовой интерполяции: 1
3. Минимальная степень для интерполяции с касательными: 2
4. Количество точек должно быть больше степени кривой
5. Для интерполяции с касательными количество касательных должно равняться количеству точек
6. Эпсилон для сравнения вещественных чисел: 1e-10
7. Все касательные векторы автоматически нормализуются

**English:**
1. Maximum curve degree: 20 (NURBS_MAX_DEGREE)
2. Minimum degree for basic interpolation: 1
3. Minimum degree for interpolation with tangents: 2
4. Number of points must be greater than curve degree
5. For interpolation with tangents, number of tangents must equal number of points
6. Epsilon for floating point comparison: 1e-10
7. All tangent vectors are automatically normalized

## Математические основы / Mathematical Background

Реализация основана на алгоритмах из книги:
Implementation is based on algorithms from the book:

**"The NURBS Book" 2nd Edition**
Authors: Les Piegl, Wayne Tiller

Использованные алгоритмы:
Used algorithms:
- Algorithm A2.1: FindSpan (поиск интервала узлов / knot span search)
- Algorithm A2.2: BasisFuns (базисные функции / basis functions)
- Algorithm A2.3: DersBasisFuns (производные базисных функций / basis function derivatives)
- Algorithm A9.1: GlobalCurveInterp (глобальная интерполяция кривой / global curve interpolation)

## Отличия от оригинальной реализации LNLib / Differences from Original LNLib Implementation

**Russian:**
1. Использованы типы данных ZCAD (TzePoint3d, TKnotsVector) вместо XYZ, XYZW из LNLib
2. Добавлено подробное логирование через систему uzcLog
3. Все комментарии на русском и английском языках
4. Функции адаптированы под стиль кодирования Pascal/Delphi
5. Использован существующий механизм управления памятью FreePascal (dynamic arrays)
6. Добавлена валидация входных параметров с понятными сообщениями об ошибках
7. Создана расширенная тестовая программа

**English:**
1. Used ZCAD data types (TzePoint3d, TKnotsVector) instead of XYZ, XYZW from LNLib
2. Added detailed logging through uzcLog system
3. All comments in both Russian and English
4. Functions adapted to Pascal/Delphi coding style
5. Used FreePascal's native memory management (dynamic arrays)
6. Added input parameter validation with clear error messages
7. Created extended test program

## Производительность / Performance

Сложность алгоритма глобальной интерполяции:
Complexity of global interpolation algorithm:
- Временная сложность: O(n³) / Time complexity: O(n³)
  - Где n - количество точек интерполяции / Where n is the number of interpolation points
  - Основная сложность - решение системы линейных уравнений / Main complexity is solving linear system
- Пространственная сложность: O(n²) / Space complexity: O(n²)
  - Для хранения матрицы интерполяции / For storing interpolation matrix

Для интерполяции с касательными:
For interpolation with tangents:
- Временная сложность: O((2n)³) = O(8n³) / Time complexity: O((2n)³) = O(8n³)
- Пространственная сложность: O((2n)²) = O(4n²) / Space complexity: O((2n)²) = O(4n²)

## Автор / Author

Vladimir Bobrov

Портировано для проекта ZCAD из библиотеки LNLib.
Ported for ZCAD project from LNLib library.

## Лицензия / License

Этот файл является частью проекта ZCAD.
This file is part of the ZCAD project.

См. файл COPYING.txt для информации об авторских правах.
See the file COPYING.txt for copyright information.

## Ссылки / References

- LNLib Repository: https://github.com/BIMCoderLiang/LNLib
- The NURBS Book: https://www.springer.com/gp/book/9783642973857
- ZCAD Project: https://github.com/zamtmn/zcad

## История изменений / Change History

См. файл CHANGELOG.md
See CHANGELOG.md file
