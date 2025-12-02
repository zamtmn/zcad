{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Vladimir Bobrov)
}
{**
  Модуль NurbsCurve_CAPI - обёртка для работы с NURBS-кривыми.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для создания,
  анализа, модификации и преобразования NURBS-кривых.

  NURBS (Non-Uniform Rational B-Spline) — это математическое представление
  кривых и поверхностей, широко используемое в компьютерной графике и CAD.
  NURBS-кривая определяется степенью, узловым вектором и взвешенными
  контрольными точками.

  Оригинальный C-заголовок: NurbsCurve_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI, XYZW_CAPI, Matrix4d_CAPI,
               LNEnums_CAPI
}
unit NurbsCurve_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  XYZ_CAPI,
  XYZW_CAPI,
  Matrix4d_CAPI,
  LNEnums_CAPI;

type
  {**
    Структура для представления NURBS-кривой.

    Содержит все данные, необходимые для определения NURBS-кривой:
    степень, узловой вектор и взвешенные контрольные точки.

    @member degree Степень кривой (порядок минус 1)
    @member knot_vector Указатель на массив узловых значений
    @member knot_count Количество узлов в узловом векторе
    @member control_points Указатель на массив контрольных точек в
                           однородных координатах
    @member control_point_count Количество контрольных точек
  }
  TLN_NurbsCurve = record
    degree: Integer;
    knot_vector: PDouble;
    knot_count: Integer;
    control_points: PXYZW;
    control_point_count: Integer;
  end;
  PLN_NurbsCurve = ^TLN_NurbsCurve;

{ ========================================================================== }
{                      Функции создания NURBS-кривых                         }
{ ========================================================================== }

{**
  Создание линейного сегмента как NURBS-кривой первой степени.

  Линия представляется как NURBS-кривая степени 1 с двумя контрольными
  точками (начальной и конечной).

  @param start_point Начальная точка линии
  @param end_point Конечная точка линии
  @return NURBS-кривая, представляющая линейный сегмент
}
function nurbs_curve_create_line(
  start_point: TXYZ;
  end_point: TXYZ): TLN_NurbsCurve;
  cdecl; external LNLIB_DLL;

{**
  Создание дуги как NURBS-кривой.

  Дуга определяется центром, двумя ортогональными осями (задающими
  плоскость дуги), начальным и конечным углами, а также радиусами.
  Для эллиптических дуг радиусы по осям X и Y различаются.

  @param center Центр дуги
  @param x_axis Направление оси X (должно быть нормализовано)
  @param y_axis Направление оси Y (должно быть нормализовано и
                перпендикулярно x_axis)
  @param start_rad Начальный угол в радианах
  @param end_rad Конечный угол в радианах
  @param x_radius Радиус по оси X
  @param y_radius Радиус по оси Y
  @param out_curve Выходной параметр: созданная NURBS-кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_create_arc(
  center: TXYZ;
  x_axis: TXYZ;
  y_axis: TXYZ;
  start_rad: Double;
  end_rad: Double;
  x_radius: Double;
  y_radius: Double;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Создание открытого конического сечения как NURBS-кривой.

  Коническое сечение определяется начальной и конечной точками,
  касательными в этих точках и одной точкой на кривой.
  Результатом может быть параболический, эллиптический или
  гиперболический сегмент.

  @param start_point Начальная точка кривой
  @param start_tangent Касательный вектор в начальной точке
  @param end_point Конечная точка кривой
  @param end_tangent Касательный вектор в конечной точке
  @param point_on_conic Точка, через которую проходит кривая
  @param out_curve Выходной параметр: созданная NURBS-кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_create_open_conic(
  start_point: TXYZ;
  start_tangent: TXYZ;
  end_point: TXYZ;
  end_tangent: TXYZ;
  point_on_conic: TXYZ;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                   Функции интерполяции и аппроксимации                     }
{ ========================================================================== }

{**
  Глобальная интерполяция точек NURBS-кривой.

  Создаёт NURBS-кривую заданной степени, которая проходит через все
  указанные точки. Узловой вектор вычисляется автоматически методом
  хордовой параметризации.

  @param degree Требуемая степень кривой
  @param points Указатель на массив точек для интерполяции
  @param point_count Количество точек
  @param out_curve Выходной параметр: интерполирующая NURBS-кривая
}
procedure nurbs_curve_global_interpolation(
  degree: Integer;
  points: PXYZ;
  point_count: Integer;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Глобальная интерполяция точек с заданными касательными.

  Создаёт NURBS-кривую, проходящую через все точки с соблюдением
  заданных касательных векторов. Подходит для создания плавных
  кривых с контролем направления в каждой точке.

  @param degree Требуемая степень кривой
  @param points Указатель на массив точек для интерполяции
  @param tangents Указатель на массив касательных векторов
                  (должен иметь ту же длину, что и points)
  @param tangent_factor Коэффициент масштабирования касательных (обычно 1.0)
  @param point_count Количество точек
  @param out_curve Выходной параметр: интерполирующая NURBS-кривая
}
procedure nurbs_curve_global_interpolation_with_tangents(
  degree: Integer;
  points: PXYZ;
  tangents: PXYZ;
  tangent_factor: Double;
  point_count: Integer;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Локальная кубическая интерполяция точек.

  Создаёт кубическую NURBS-кривую (степень 3), проходящую через
  все точки. Использует локальный метод вычисления касательных,
  что обеспечивает хорошую форму кривой без осцилляций.

  @param points Указатель на массив точек для интерполяции
  @param point_count Количество точек (минимум 2)
  @param out_curve Выходной параметр: интерполирующая NURBS-кривая
  @return 1 при успехе, 0 при ошибке (например, недостаточно точек)
}
function nurbs_curve_cubic_local_interpolation(
  points: PXYZ;
  point_count: Integer;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Аппроксимация точек методом наименьших квадратов.

  Создаёт NURBS-кривую заданной степени, которая приближает
  заданные точки в смысле наименьших квадратов. Количество
  контрольных точек меньше количества исходных точек.

  @param degree Требуемая степень кривой
  @param points Указатель на массив точек для аппроксимации
  @param point_count Количество исходных точек
  @param control_point_count Желаемое количество контрольных точек
                              (должно быть меньше point_count)
  @param out_curve Выходной параметр: аппроксимирующая NURBS-кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_least_squares_approximation(
  degree: Integer;
  points: PXYZ;
  point_count: Integer;
  control_point_count: Integer;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Взвешенная аппроксимация с ограничениями.

  Создаёт NURBS-кривую с использованием метода взвешенных
  наименьших квадратов с дополнительными ограничениями на
  касательные в отдельных точках.

  @param degree Требуемая степень кривой
  @param points Указатель на массив точек для аппроксимации
  @param point_weights Указатель на массив весов точек
  @param tangents Указатель на массив касательных векторов
  @param tangent_indices Указатель на массив индексов точек с касательными
  @param tangent_weights Указатель на массив весов касательных
  @param tangent_count Количество заданных касательных
  @param control_point_count Желаемое количество контрольных точек
  @param out_curve Выходной параметр: аппроксимирующая NURBS-кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_weighted_constrained_least_squares(
  degree: Integer;
  points: PXYZ;
  point_weights: PDouble;
  tangents: PXYZ;
  tangent_indices: PInteger;
  tangent_weights: PDouble;
  tangent_count: Integer;
  control_point_count: Integer;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Глобальная аппроксимация с ограничением по ошибке.

  Автоматически подбирает количество контрольных точек так,
  чтобы максимальная ошибка аппроксимации не превышала заданного
  порогового значения.

  @param degree Требуемая степень кривой
  @param points Указатель на массив точек для аппроксимации
  @param point_count Количество исходных точек
  @param max_error Максимально допустимая ошибка аппроксимации
  @param out_curve Выходной параметр: аппроксимирующая NURBS-кривая
}
procedure nurbs_curve_global_approximation_by_error_bound(
  degree: Integer;
  points: PXYZ;
  point_count: Integer;
  max_error: Double;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                   Функции вычисления точек на кривой                       }
{ ========================================================================== }

{**
  Вычисление точки на NURBS-кривой по параметру.

  Использует стандартный алгоритм вычисления через базисные
  функции B-сплайна.

  @param curve NURBS-кривая
  @param paramT Параметр на кривой (обычно в диапазоне [0, 1])
  @return Координаты точки на кривой
}
function nurbs_curve_get_point_on_curve(
  curve: TLN_NurbsCurve;
  paramT: Double): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Вычисление точки на NURBS-кривой методом углового среза.

  Использует алгоритм де Бура для вычисления точки на кривой.
  Численно более стабилен для некоторых случаев.

  @param curve NURBS-кривая
  @param paramT Параметр на кривой
  @return Координаты точки на кривой
}
function nurbs_curve_get_point_on_curve_by_corner_cut(
  curve: TLN_NurbsCurve;
  paramT: Double): TXYZ;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                    Функции вычисления производных                          }
{ ========================================================================== }

{**
  Вычисление рациональных производных NURBS-кривой.

  Вычисляет производные до указанного порядка в заданной точке.
  Учитывает рациональную природу кривой.

  @param curve NURBS-кривая
  @param derivative_order Максимальный порядок производной
  @param paramT Параметр на кривой
  @param out_derivatives Выходной массив производных (должен быть
                         предварительно выделен с размером
                         derivative_order + 1)
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_compute_rational_derivatives(
  curve: TLN_NurbsCurve;
  derivative_order: Integer;
  paramT: Double;
  out_derivatives: PXYZ): Integer;
  cdecl; external LNLIB_DLL;

{**
  Вычисление кривизны NURBS-кривой в точке.

  Кривизна — это величина, обратная радиусу соприкасающейся
  окружности в данной точке.

  @param curve NURBS-кривая
  @param paramT Параметр на кривой
  @return Значение кривизны (может быть 0 для прямой линии)
}
function nurbs_curve_curvature(
  curve: TLN_NurbsCurve;
  paramT: Double): Double;
  cdecl; external LNLIB_DLL;

{**
  Вычисление кручения NURBS-кривой в точке.

  Кручение характеризует отклонение кривой от плоскости
  соприкосновения.

  @param curve NURBS-кривая
  @param paramT Параметр на кривой
  @return Значение кручения (0 для плоских кривых)
}
function nurbs_curve_torsion(
  curve: TLN_NurbsCurve;
  paramT: Double): Double;
  cdecl; external LNLIB_DLL;

{**
  Вычисление нормали к NURBS-кривой в точке.

  Возвращает главную нормаль или бинормаль в зависимости
  от указанного типа.

  @param curve NURBS-кривая
  @param normal_type Тип нормали (главная нормаль или бинормаль)
  @param paramT Параметр на кривой
  @return Вектор нормали (единичной длины)
}
function nurbs_curve_normal(
  curve: TLN_NurbsCurve;
  normal_type: TCurveNormal;
  paramT: Double): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Проекция нормалей вдоль всей кривой.

  Вычисляет нормальные векторы для ряда точек вдоль кривой.
  Количество выходных нормалей зависит от внутренней логики.

  @param curve NURBS-кривая
  @param out_normals Выходной массив нормалей (должен быть
                     предварительно выделен достаточного размера)
  @return Количество вычисленных нормалей
}
function nurbs_curve_project_normal(
  curve: TLN_NurbsCurve;
  out_normals: PXYZ): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                     Функции анализа параметризации                         }
{ ========================================================================== }

{**
  Определение параметра на кривой по ближайшей точке.

  Находит значение параметра t, при котором точка на кривой
  наиболее близка к заданной точке в пространстве.

  @param curve NURBS-кривая
  @param given_point Точка в пространстве
  @return Параметр ближайшей точки на кривой
}
function nurbs_curve_get_param_on_curve_by_point(
  curve: TLN_NurbsCurve;
  given_point: TXYZ): Double;
  cdecl; external LNLIB_DLL;

{**
  Вычисление приблизительной длины кривой.

  Использует численное интегрирование для оценки длины кривой.

  @param curve NURBS-кривая
  @param integrator_type Метод численного интегрирования
  @return Приблизительная длина кривой
}
function nurbs_curve_approximate_length(
  curve: TLN_NurbsCurve;
  integrator_type: TIntegratorType): Double;
  cdecl; external LNLIB_DLL;

{**
  Определение параметра по длине вдоль кривой.

  Находит значение параметра, при котором длина дуги от начала
  кривой равна заданной величине.

  @param curve NURBS-кривая
  @param given_length Требуемая длина дуги от начала
  @param integrator_type Метод численного интегрирования
  @return Параметр точки на заданном расстоянии от начала
}
function nurbs_curve_get_param_by_length(
  curve: TLN_NurbsCurve;
  given_length: Double;
  integrator_type: TIntegratorType): Double;
  cdecl; external LNLIB_DLL;

{**
  Разбиение кривой на равные по длине сегменты.

  Вычисляет массив параметров, делящих кривую на сегменты
  заданной длины.

  @param curve NURBS-кривая
  @param segment_length Требуемая длина каждого сегмента
  @param integrator_type Метод численного интегрирования
  @param out_params Выходной массив параметров (должен быть
                    предварительно выделен достаточного размера)
  @return Количество параметров в выходном массиве
}
function nurbs_curve_get_params_by_equal_length(
  curve: TLN_NurbsCurve;
  segment_length: Double;
  integrator_type: TIntegratorType;
  out_params: PDouble): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                       Функции разбиения кривой                             }
{ ========================================================================== }

{**
  Разделение кривой на две части в заданной точке.

  Создаёт две новые кривые: левую (от начала до точки разделения)
  и правую (от точки разделения до конца).

  @param curve Исходная NURBS-кривая
  @param paramT Параметр точки разделения
  @param out_left Выходной параметр: левая часть кривой
  @param out_right Выходной параметр: правая часть кривой
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_split_at(
  curve: TLN_NurbsCurve;
  paramT: Double;
  out_left: PLN_NurbsCurve;
  out_right: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Выделение сегмента кривой.

  Создаёт новую кривую, представляющую часть исходной кривой
  между двумя параметрическими значениями.

  @param curve Исходная NURBS-кривая
  @param start_param Начальный параметр сегмента
  @param end_param Конечный параметр сегмента
  @param out_segment Выходной параметр: сегмент кривой
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_segment(
  curve: TLN_NurbsCurve;
  start_param: Double;
  end_param: Double;
  out_segment: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Декомпозиция NURBS-кривой в сегменты Безье.

  Разбивает кривую на отдельные кривые Безье, вставляя узлы
  для достижения максимальной кратности.

  @param curve Исходная NURBS-кривая
  @param out_segments Выходной массив сегментов Безье
  @param max_segments Максимальное количество сегментов
  @return Фактическое количество созданных сегментов
}
function nurbs_curve_decompose_to_beziers(
  curve: TLN_NurbsCurve;
  out_segments: PLN_NurbsCurve;
  max_segments: Integer): Integer;
  cdecl; external LNLIB_DLL;

{**
  Тесселяция кривой в набор точек.

  Создаёт приближённое полилинейное представление кривой.
  Количество точек определяется внутренней логикой.

  @param curve NURBS-кривая
  @param out_points Выходной массив точек (должен быть
                    предварительно выделен достаточного размера)
  @return Количество точек в результате
}
function nurbs_curve_tessellate(
  curve: TLN_NurbsCurve;
  out_points: PXYZ): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                      Функции преобразования кривой                         }
{ ========================================================================== }

{**
  Применение матричного преобразования к кривой.

  Создаёт новую кривую путём применения матрицы преобразования
  ко всем контрольным точкам исходной кривой.

  @param curve Исходная NURBS-кривая
  @param matrix Матрица преобразования 4x4
  @param out_curve Выходной параметр: преобразованная кривая
}
procedure nurbs_curve_create_transformed(
  curve: TLN_NurbsCurve;
  matrix: TMatrix4d;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Обращение направления кривой.

  Создаёт новую кривую с обратным направлением обхода:
  точка при t=0 становится точкой при t=1 и наоборот.

  @param curve Исходная NURBS-кривая
  @param out_curve Выходной параметр: обращённая кривая
}
procedure nurbs_curve_reverse(
  curve: TLN_NurbsCurve;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Перепараметризация кривой на заданный интервал.

  Линейно преобразует диапазон параметров кривой в новый
  интервал [min_val, max_val].

  @param curve Исходная NURBS-кривая
  @param min_val Минимальное значение нового диапазона
  @param max_val Максимальное значение нового диапазона
  @param out_curve Выходной параметр: перепараметризованная кривая
}
procedure nurbs_curve_reparametrize_to_interval(
  curve: TLN_NurbsCurve;
  min_val: Double;
  max_val: Double;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Линейно-рациональная перепараметризация кривой.

  Применяет преобразование параметра вида:
  t' = (alpha * t + beta) / (gamma * t + delta)

  @param curve Исходная NURBS-кривая
  @param alpha Числитель, коэффициент при t
  @param beta Числитель, свободный член
  @param gamma Знаменатель, коэффициент при t
  @param delta Знаменатель, свободный член
  @param out_curve Выходной параметр: перепараметризованная кривая
}
procedure nurbs_curve_reparametrize_linear_rational(
  curve: TLN_NurbsCurve;
  alpha: Double;
  beta: Double;
  gamma: Double;
  delta: Double;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                     Функции модификации узлов                              }
{ ========================================================================== }

{**
  Вставка узла в узловой вектор кривой.

  Вставляет новое узловое значение указанное количество раз.
  Форма кривой не изменяется, но добавляются контрольные точки.

  @param curve Исходная NURBS-кривая
  @param knot_value Значение вставляемого узла
  @param times Количество вставок (кратность)
  @param out_curve Выходной параметр: модифицированная кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_insert_knot(
  curve: TLN_NurbsCurve;
  knot_value: Double;
  times: Integer;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Удаление узла из узлового вектора кривой.

  Пытается удалить узловое значение указанное количество раз.
  Успешность зависит от того, можно ли это сделать без
  существенного изменения формы кривой.

  @param curve Исходная NURBS-кривая
  @param knot_value Значение удаляемого узла
  @param times Количество удалений
  @param out_curve Выходной параметр: модифицированная кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_remove_knot(
  curve: TLN_NurbsCurve;
  knot_value: Double;
  times: Integer;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Удаление избыточных узлов из кривой.

  Автоматически определяет и удаляет узлы, которые можно
  удалить без существенного изменения формы кривой.

  @param curve Исходная NURBS-кривая
  @param out_curve Выходной параметр: упрощённая кривая
}
procedure nurbs_curve_remove_excessive_knots(
  curve: TLN_NurbsCurve;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Уточнение узлового вектора кривой.

  Вставляет массив новых узловых значений, сохраняя форму кривой.
  Используется для подготовки кривых к различным операциям.

  @param curve Исходная NURBS-кривая
  @param insert_knots Указатель на массив вставляемых узлов
  @param insert_count Количество вставляемых узлов
  @param out_curve Выходной параметр: уточнённая кривая
}
procedure nurbs_curve_refine_knot_vector(
  curve: TLN_NurbsCurve;
  insert_knots: PDouble;
  insert_count: Integer;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Повышение степени кривой.

  Увеличивает степень кривой на указанную величину.
  Форма кривой не изменяется, но увеличивается количество
  контрольных точек и узлов.

  @param curve Исходная NURBS-кривая
  @param times Количество раз повышения степени
  @param out_curve Выходной параметр: кривая повышенной степени
}
procedure nurbs_curve_elevate_degree(
  curve: TLN_NurbsCurve;
  times: Integer;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Понижение степени кривой.

  Уменьшает степень кривой на 1. Операция возможна только
  если кривая допускает аппроксимацию меньшей степени.

  @param curve Исходная NURBS-кривая
  @param out_curve Выходной параметр: кривая пониженной степени
  @return 1 при успехе, 0 если понижение невозможно
}
function nurbs_curve_reduce_degree(
  curve: TLN_NurbsCurve;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                       Функции проверки свойств                             }
{ ========================================================================== }

{**
  Проверка, является ли кривая замкнутой.

  Кривая считается замкнутой, если начальная и конечная
  точки совпадают.

  @param curve NURBS-кривая
  @return 1 если кривая замкнута, 0 в противном случае
}
function nurbs_curve_is_closed(curve: TLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Проверка, является ли кривая линейной.

  Линейная кривая — это кривая первой степени или кривая,
  все контрольные точки которой лежат на одной прямой.

  @param curve NURBS-кривая
  @return 1 если кривая линейна, 0 в противном случае
}
function nurbs_curve_is_linear(curve: TLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Проверка, является ли кривая зажатой (clamped).

  Зажатая кривая имеет узлы с максимальной кратностью на
  концах, что обеспечивает прохождение через крайние
  контрольные точки.

  @param curve NURBS-кривая
  @return 1 если кривая зажата, 0 в противном случае
}
function nurbs_curve_is_clamped(curve: TLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Проверка, является ли кривая периодической.

  Периодическая кривая — это бесконечно гладко замкнутая
  кривая с равномерным узловым вектором.

  @param curve NURBS-кривая
  @return 1 если кривая периодическая, 0 в противном случае
}
function nurbs_curve_is_periodic(curve: TLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Проверка возможности вычисления производной в точке.

  Производная может быть не определена в узловых точках
  с низкой непрерывностью.

  @param curve NURBS-кривая
  @param paramT Параметр на кривой
  @return 1 если производная вычислима, 0 в противном случае
}
function nurbs_curve_can_compute_derivative(
  curve: TLN_NurbsCurve;
  paramT: Double): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                 Функции модификации контрольных точек                      }
{ ========================================================================== }

{**
  Перемещение контрольной точки для изменения формы кривой.

  Модифицирует положение контрольной точки так, чтобы кривая
  сместилась на заданное расстояние в заданном направлении
  в указанной параметрической точке.

  @param curve Исходная NURBS-кривая
  @param paramT Параметр точки на кривой, которую нужно сместить
  @param move_index Индекс контрольной точки для перемещения
  @param move_direction Направление перемещения
  @param move_distance Расстояние перемещения
  @param out_curve Выходной параметр: модифицированная кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_control_point_reposition(
  curve: TLN_NurbsCurve;
  paramT: Double;
  move_index: Integer;
  move_direction: TXYZ;
  move_distance: Double;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Модификация веса контрольной точки.

  Изменяет вес указанной контрольной точки, что влияет
  на форму кривой вблизи этой точки.

  @param curve Исходная NURBS-кривая
  @param paramT Параметр точки на кривой для анализа влияния
  @param move_index Индекс контрольной точки
  @param move_distance Величина изменения веса
  @param out_curve Выходной параметр: модифицированная кривая
}
procedure nurbs_curve_weight_modification(
  curve: TLN_NurbsCurve;
  paramT: Double;
  move_index: Integer;
  move_distance: Double;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Модификация весов соседних контрольных точек.

  Изменяет веса нескольких контрольных точек в окрестности
  указанной, с учётом коэффициента масштабирования.

  @param curve Исходная NURBS-кривая
  @param paramT Параметр точки на кривой
  @param move_index Центральный индекс модификации
  @param move_distance Величина изменения
  @param scale Коэффициент масштабирования для соседних точек
  @param out_curve Выходной параметр: модифицированная кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_neighbor_weights_modification(
  curve: TLN_NurbsCurve;
  paramT: Double;
  move_index: Integer;
  move_distance: Double;
  scale: Double;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                      Функции деформации кривой                             }
{ ========================================================================== }

{**
  Деформация кривой по заданному профилю.

  Применяет профиль деформации к участку кривой между
  двумя параметрическими значениями.

  @param curve Исходная NURBS-кривая
  @param warp_shape Указатель на массив значений профиля деформации
  @param warp_shape_count Количество значений в профиле
  @param warp_distance Амплитуда деформации
  @param plane_normal Нормаль к плоскости деформации
  @param start_param Начальный параметр участка деформации
  @param end_param Конечный параметр участка деформации
  @param out_curve Выходной параметр: деформированная кривая
}
procedure nurbs_curve_warping(
  curve: TLN_NurbsCurve;
  warp_shape: PDouble;
  warp_shape_count: Integer;
  warp_distance: Double;
  plane_normal: TXYZ;
  start_param: Double;
  end_param: Double;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Выравнивание участка кривой на линию.

  Деформирует участок кривой так, чтобы он приблизился
  к заданному линейному сегменту.

  @param curve Исходная NURBS-кривая
  @param line_start Начальная точка целевой линии
  @param line_end Конечная точка целевой линии
  @param start_param Начальный параметр участка
  @param end_param Конечный параметр участка
  @param out_curve Выходной параметр: модифицированная кривая
  @return 1 при успехе, 0 при ошибке
}
function nurbs_curve_flattening(
  curve: TLN_NurbsCurve;
  line_start: TXYZ;
  line_end: TXYZ;
  start_param: Double;
  end_param: Double;
  out_curve: PLN_NurbsCurve): Integer;
  cdecl; external LNLIB_DLL;

{**
  Изгиб участка кривой по дуге окружности.

  Деформирует участок кривой, изгибая его по дуге с
  заданным центром и радиусом.

  @param curve Исходная NURBS-кривая
  @param start_param Начальный параметр участка
  @param end_param Конечный параметр участка
  @param bend_center Центр изгиба
  @param radius Радиус изгиба
  @param cross_ratio Кросс-отношение для управления формой
  @param out_curve Выходной параметр: изогнутая кривая
}
procedure nurbs_curve_bending(
  curve: TLN_NurbsCurve;
  start_param: Double;
  end_param: Double;
  bend_center: TXYZ;
  radius: Double;
  cross_ratio: Double;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Модификация кривой на основе ограничений.

  Модифицирует кривую для соблюдения заданных ограничений
  на производные в определённых точках с возможностью
  фиксации отдельных контрольных точек.

  @param curve Исходная NURBS-кривая
  @param constraint_params Указатель на массив параметров ограничений
  @param derivative_constraints Указатель на массив ограничений на производные
  @param applied_indices Указатель на массив индексов применения
  @param applied_degrees Указатель на массив порядков производных
  @param fixed_cp_indices Указатель на массив индексов фиксированных точек
  @param constraint_count Количество ограничений
  @param fixed_count Количество фиксированных контрольных точек
  @param out_curve Выходной параметр: модифицированная кривая
}
procedure nurbs_curve_constraint_based_modification(
  curve: TLN_NurbsCurve;
  constraint_params: PDouble;
  derivative_constraints: PXYZ;
  applied_indices: PInteger;
  applied_degrees: PInteger;
  fixed_cp_indices: PInteger;
  constraint_count: Integer;
  fixed_count: Integer;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                      Функции преобразования типа                           }
{ ========================================================================== }

{**
  Преобразование в зажатую кривую.

  Создаёт зажатую (clamped) версию кривой с узлами
  максимальной кратности на концах.

  @param curve Исходная NURBS-кривая
  @param out_curve Выходной параметр: зажатая кривая
}
procedure nurbs_curve_to_clamp_curve(
  curve: TLN_NurbsCurve;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Преобразование в незажатую кривую.

  Создаёт незажатую версию кривой с равномерными узлами
  на концах.

  @param curve Исходная NURBS-кривая
  @param out_curve Выходной параметр: незажатая кривая
}
procedure nurbs_curve_to_unclamp_curve(
  curve: TLN_NurbsCurve;
  out_curve: PLN_NurbsCurve);
  cdecl; external LNLIB_DLL;

{**
  Равномерная тесселяция кривой.

  Разбивает кривую на равные по параметру сегменты,
  возвращая точки и соответствующие параметрические значения.

  @param curve NURBS-кривая
  @param out_points Выходной массив точек
  @param out_knots Выходной массив параметрических значений
  @param max_count Максимальное количество точек
}
procedure nurbs_curve_equally_tessellate(
  curve: TLN_NurbsCurve;
  out_points: PXYZ;
  out_knots: PDouble;
  max_count: Integer);
  cdecl; external LNLIB_DLL;

implementation

end.
