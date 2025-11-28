# Changelog / История изменений

Все заметные изменения в модуле GlobalInterpolation будут документированы в этом файле.
All notable changes to the GlobalInterpolation module will be documented in this file.

## [1.0.0] - 2025-11-28

### Added / Добавлено

#### Основная функциональность / Core Functionality
- ✅ Портирована функция `GlobalInterpolation` (базовая версия) из LNLib
  - Ported `GlobalInterpolation` function (basic version) from LNLib
- ✅ Портирована функция `GlobalInterpolation` (с касательными) из LNLib
  - Ported `GlobalInterpolation` function (with tangents) from LNLib
- ✅ Реализован тип данных `TNurbsCurveData` для результатов интерполяции
  - Implemented `TNurbsCurveData` data type for interpolation results

#### Вспомогательные функции / Helper Functions
- ✅ `GetKnotSpanIndex` - поиск индекса интервала узлов (Algorithm A2.1 from The NURBS Book)
  - Knot span index search
- ✅ `BasisFunctionsArray` - вычисление базисных функций (Algorithm A2.2)
  - Basis functions computation
- ✅ `BasisFunctionsDerivatives` - вычисление производных базисных функций (Algorithm A2.3)
  - Basis function derivatives computation
- ✅ `GetChordParameterization` - хордовая параметризация точек
  - Chord length parameterization
- ✅ `AverageKnotVector` - генерация вектора узлов методом усреднения (Algorithm A9.1)
  - Knot vector generation by averaging
- ✅ `GetTotalChordLength` - вычисление общей длины хорд
  - Total chord length computation
- ✅ `SolveLinearSystem` - решение системы линейных уравнений методом Гаусса
  - Linear system solver using Gaussian elimination
- ✅ `NormalizeVector` - нормализация вектора
  - Vector normalization

#### Документация / Documentation
- ✅ Создан файл `README.md` с подробным описанием модуля на русском и английском языках
  - Created `README.md` file with detailed module description in Russian and English
- ✅ Добавлены комментарии к каждой функции на русском и английском языках
  - Added comments to each function in Russian and English
- ✅ Документированы все параметры функций и типы данных
  - Documented all function parameters and data types
- ✅ Добавлены примеры использования
  - Added usage examples
- ✅ Создан файл `CHANGELOG.md` (этот файл)
  - Created `CHANGELOG.md` file (this file)

#### Тестирование / Testing
- ✅ Создана тестовая программа `test_global_interpolation.pas`
  - Created test program `test_global_interpolation.pas`
- ✅ Тест 1: Базовая интерполяция простой кривой из 4 точек
  - Test 1: Basic interpolation of simple 4-point curve
- ✅ Тест 2: Интерполяция сложной кривой из 7 точек (из issue #253)
  - Test 2: Interpolation of complex 7-point curve (from issue #253)
- ✅ Тест 3: Интерполяция с касательными векторами
  - Test 3: Interpolation with tangent constraints
- ✅ Тест 4: Тестирование различных степеней кривых (2, 3, 4)
  - Test 4: Testing different curve degrees (2, 3, 4)
- ✅ Тест 5: Проверка обработки ошибок
  - Test 5: Error handling checks

#### Логирование / Logging
- ✅ Интеграция с системой логирования ZCAD (`uzcLog`)
  - Integration with ZCAD logging system (`uzcLog`)
- ✅ Логирование всех ключевых этапов алгоритма на уровне `LM_Info`
  - Logging of all key algorithm stages at `LM_Info` level
- ✅ Логирование параметров входных данных
  - Logging of input parameters
- ✅ Логирование результатов вычислений
  - Logging of computation results

#### Валидация / Validation
- ✅ Проверка степени кривой (должна быть >= 1 для базовой версии, >= 2 для версии с касательными)
  - Curve degree validation (must be >= 1 for basic version, >= 2 for version with tangents)
- ✅ Проверка количества точек (должно быть больше степени)
  - Point count validation (must be greater than degree)
- ✅ Проверка соответствия размеров массивов параметров и точек
  - Array size matching validation for parameters and points
- ✅ Проверка соответствия количества касательных количеству точек
  - Tangent count validation (must match point count)
- ✅ Проверка положительности tangentFactor
  - TangentFactor positivity validation
- ✅ Понятные сообщения об ошибках на русском и английском языках
  - Clear error messages in Russian and English

### Technical Details / Технические детали

#### Портирование из C++ / Porting from C++
- Исходный файл: `src/LNLib/Geometry/Curve/NurbsCurve.cpp` из репозитория LNLib
  - Source file: `src/LNLib/Geometry/Curve/NurbsCurve.cpp` from LNLib repository
- Репозиторий: https://github.com/BIMCoderLiang/LNLib
- Строки 2009-2067: Базовая версия `GlobalInterpolation`
  - Lines 2009-2067: Basic version of `GlobalInterpolation`
- Строки 2069-2200: Версия с касательными `GlobalInterpolation`
  - Lines 2069-2200: Version with tangents

#### Адаптация к ZCAD / Adaptation to ZCAD
- Использованы существующие типы ZCAD:
  - Used existing ZCAD types:
  - `TzePoint3d` вместо / instead of `XYZ`
  - `TKnotsVector` вместо / instead of `std::vector<double>` для узлов / for knots
  - `TControlPointsArray` вместо / instead of `std::vector<XYZW>`
- Использована система логирования ZCAD (`uzcLog`)
  - Used ZCAD logging system (`uzcLog`)
- Адаптирован стиль кодирования под стандарты ZCAD
  - Adapted coding style to ZCAD standards

#### Математические алгоритмы / Mathematical Algorithms
Все алгоритмы соответствуют книге "The NURBS Book" 2nd Edition (Piegl & Tiller):
All algorithms match "The NURBS Book" 2nd Edition (Piegl & Tiller):
- Algorithm A2.1: FindSpan - поиск интервала узлов / knot span search
- Algorithm A2.2: BasisFuns - базисные функции / basis functions
- Algorithm A2.3: DersBasisFuns - производные базисных функций / basis function derivatives
- Algorithm A9.1: GlobalCurveInterp - глобальная интерполяция / global curve interpolation

#### Зависимости / Dependencies
Модуль зависит от следующих модулей ZCAD:
Module depends on the following ZCAD modules:
- `uzegeometrytypes` - определения типов точек и векторов / point and vector type definitions
- `uzeNURBSTypes` - типы NURBS (TKnotsVector, TControlPointsArray) / NURBS types
- `uzcLog` - система логирования / logging system

Не использовались следующие функции из `uzeNURBSUtils`:
The following functions from `uzeNURBSUtils` were not used:
- `BasisFunction` - заменена на `BasisFunctionsArray` (возвращает массив вместо одного значения)
  - Replaced with `BasisFunctionsArray` (returns array instead of single value)
- `ComputeParameters` - заменена на `GetChordParameterization` (более точное соответствие LNLib)
  - Replaced with `GetChordParameterization` (more accurate match to LNLib)
- `GenerateKnotVector` - заменена на `AverageKnotVector` (другая сигнатура и алгоритм)
  - Replaced with `AverageKnotVector` (different signature and algorithm)
- `SolveLinearSystem` - переработана для работы с многоколоночной правой частью (x, y, z одновременно)
  - Reworked to handle multi-column right-hand side (x, y, z simultaneously)

### Known Issues / Известные проблемы

Нет известных проблем на данный момент.
No known issues at this time.

### Performance / Производительность

- Базовая интерполяция: O(n³) по времени, O(n²) по памяти
  - Basic interpolation: O(n³) time, O(n²) space
- Интерполяция с касательными: O(8n³) по времени, O(4n²) по памяти
  - Interpolation with tangents: O(8n³) time, O(4n²) space
- Где n - количество точек интерполяции
  - Where n is the number of interpolation points

### Testing Results / Результаты тестирования

Все тесты успешно пройдены:
All tests passed successfully:
- ✅ Базовая интерполяция простой кривой
  - Basic interpolation of simple curve
- ✅ Интерполяция сложной кривой из 7 точек
  - Interpolation of complex 7-point curve
- ✅ Интерполяция с касательными векторами
  - Interpolation with tangent constraints
- ✅ Различные степени кривых (2, 3, 4)
  - Different curve degrees (2, 3, 4)
- ✅ Обработка ошибок
  - Error handling

### Code Quality / Качество кода

- ✅ Все функции документированы на русском и английском языках
  - All functions documented in Russian and English
- ✅ Все публичные API имеют подробные комментарии
  - All public APIs have detailed comments
- ✅ Код соответствует стандартам ZCAD
  - Code follows ZCAD standards
- ✅ Использованы осмысленные имена переменных
  - Used meaningful variable names
- ✅ Добавлена валидация входных параметров
  - Added input parameter validation
- ✅ Нет магических чисел (все константы определены)
  - No magic numbers (all constants defined)

## Будущие улучшения / Future Improvements

### Планируемые функции / Planned Features
- [ ] Добавить поддержку периодических кривых
  - Add support for periodic curves
- [ ] Оптимизировать решение системы линейных уравнений для разреженных матриц
  - Optimize linear system solver for sparse matrices
- [ ] Добавить поддержку весовых коэффициентов для точек интерполяции
  - Add support for weights for interpolation points
- [ ] Добавить функцию локальной интерполяции (CubicLocalInterpolation)
  - Add local interpolation function (CubicLocalInterpolation)

### Оптимизации / Optimizations
- [ ] Использовать специализированные решатели для трехдиагональных матриц
  - Use specialized solvers for tridiagonal matrices
- [ ] Кэширование базисных функций для повторяющихся вычислений
  - Cache basis functions for repeated computations
- [ ] Параллельное вычисление для больших наборов данных
  - Parallel computation for large datasets

### Документация / Documentation
- [ ] Добавить визуальные примеры результатов интерполяции
  - Add visual examples of interpolation results
- [ ] Создать wiki-страницу с подробным описанием математики
  - Create wiki page with detailed mathematical description
- [ ] Добавить сравнение с другими методами интерполяции
  - Add comparison with other interpolation methods

---

## Формат версий / Version Format

Формат версий: [MAJOR.MINOR.PATCH]
Version format: [MAJOR.MINOR.PATCH]

- MAJOR: Несовместимые изменения API / Incompatible API changes
- MINOR: Новая функциональность с обратной совместимостью / New functionality with backward compatibility
- PATCH: Исправления ошибок с обратной совместимостью / Bug fixes with backward compatibility

---

**Автор / Author:** Vladimir Bobrov
**Дата первого релиза / First Release Date:** 2025-11-28
**Лицензия / License:** См. COPYING.txt / See COPYING.txt
