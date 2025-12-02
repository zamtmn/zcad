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
  Модуль NurbsSurface_CAPI - обёртка для работы с NURBS-поверхностями.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для создания,
  анализа, модификации и преобразования NURBS-поверхностей.

  NURBS-поверхность определяется степенями по направлениям U и V,
  двумя узловыми векторами и двумерной сеткой взвешенных контрольных точек.
  Поверхность параметризуется двумя параметрами: U и V.

  Оригинальный C-заголовок: NurbsSurface_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, UV_CAPI, XYZ_CAPI, XYZW_CAPI,
               LNObject_CAPI, NurbsCurve_CAPI, LNEnums_CAPI
}
unit NurbsSurface_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  UV_CAPI,
  XYZ_CAPI,
  XYZW_CAPI,
  LNObject_CAPI,
  NurbsCurve_CAPI,
  LNEnums_CAPI;

type
  {**
    Структура для представления NURBS-поверхности.

    Содержит все данные, необходимые для определения NURBS-поверхности:
    степени по направлениям U и V, узловые векторы и двумерную сетку
    взвешенных контрольных точек.

    @member degree_u Степень поверхности по параметру U
    @member degree_v Степень поверхности по параметру V
    @member knot_vector_u Указатель на массив узловых значений по U
    @member knot_count_u Количество узлов в узловом векторе по U
    @member knot_vector_v Указатель на массив узловых значений по V
    @member knot_count_v Количество узлов в узловом векторе по V
    @member control_points Указатель на массив контрольных точек в
                           однородных координатах (хранятся построчно)
    @member control_point_rows Количество строк контрольных точек
    @member control_point_cols Количество столбцов контрольных точек
  }
  TLN_NurbsSurface = record
    degree_u: Integer;
    degree_v: Integer;
    knot_vector_u: PDouble;
    knot_count_u: Integer;
    knot_vector_v: PDouble;
    knot_count_v: Integer;
    control_points: PXYZW;
    control_point_rows: Integer;
    control_point_cols: Integer;
  end;
  PLN_NurbsSurface = ^TLN_NurbsSurface;

{ ========================================================================== }
{                  Функции вычисления точек на поверхности                   }
{ ========================================================================== }

{**
  Вычисление точки на NURBS-поверхности по параметрам UV.

  Использует стандартный алгоритм вычисления через базисные функции
  B-сплайна для обоих направлений.

  @param surface NURBS-поверхность
  @param uv Параметрические координаты точки (U и V обычно в [0, 1])
  @return Координаты точки на поверхности
}
function nurbs_surface_get_point_on_surface(
  surface: TLN_NurbsSurface;
  uv: TUV): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Вычисление рациональных производных NURBS-поверхности.

  Вычисляет частные производные до указанного порядка в заданной точке.
  Учитывает рациональную природу поверхности.

  @param surface NURBS-поверхность
  @param derivative_order Максимальный порядок производной
  @param uv Параметрические координаты точки
  @param out_derivatives Выходной массив производных (должен быть
                         предварительно выделен достаточного размера)
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_compute_rational_derivatives(
  surface: TLN_NurbsSurface;
  derivative_order: Integer;
  uv: TUV;
  out_derivatives: PXYZ): Integer;
  cdecl; external LNLIB_DLL;

{**
  Вычисление производных первого порядка NURBS-поверхности.

  Вычисляет точку на поверхности и частные производные по U и V.
  Эффективнее, чем общий метод, когда нужны только производные
  первого порядка.

  @param surface NURBS-поверхность
  @param uv Параметрические координаты точки
  @param out_S Выходной параметр: точка на поверхности
  @param out_Su Выходной параметр: частная производная по U
  @param out_Sv Выходной параметр: частная производная по V
}
procedure nurbs_surface_compute_first_order_derivative(
  surface: TLN_NurbsSurface;
  uv: TUV;
  out_S: PXYZ;
  out_Su: PXYZ;
  out_Sv: PXYZ);
  cdecl; external LNLIB_DLL;

{**
  Вычисление кривизны NURBS-поверхности в точке.

  Вычисляет один из типов кривизны поверхности: главные кривизны,
  гауссову, среднюю и др.

  @param surface NURBS-поверхность
  @param curvature_type Тип кривизны для вычисления
  @param uv Параметрические координаты точки
  @return Значение кривизны выбранного типа
}
function nurbs_surface_curvature(
  surface: TLN_NurbsSurface;
  curvature_type: Integer;
  uv: TUV): Double;
  cdecl; external LNLIB_DLL;

{**
  Вычисление нормали к NURBS-поверхности в точке.

  Возвращает единичный вектор нормали, вычисленный как векторное
  произведение частных производных по U и V.

  @param surface NURBS-поверхность
  @param uv Параметрические координаты точки
  @return Единичный вектор нормали
}
function nurbs_surface_normal(
  surface: TLN_NurbsSurface;
  uv: TUV): TXYZ;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                     Функции преобразования поверхности                     }
{ ========================================================================== }

{**
  Перестановка направлений U и V поверхности.

  Создаёт новую поверхность с переставленными параметрами:
  то, что было U, становится V, и наоборот.

  @param surface Исходная NURBS-поверхность
  @param out_surface Выходной параметр: поверхность с переставленными U и V
}
procedure nurbs_surface_swap_uv(
  surface: TLN_NurbsSurface;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Обращение направления параметризации поверхности.

  Создаёт новую поверхность с обратным направлением обхода
  по указанному параметру (U или V).

  @param surface Исходная NURBS-поверхность
  @param direction Направление для обращения (1 = U, другое = V)
  @param out_surface Выходной параметр: обращённая поверхность
}
procedure nurbs_surface_reverse(
  surface: TLN_NurbsSurface;
  direction: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Проверка, является ли поверхность замкнутой по указанному направлению.

  Поверхность считается замкнутой по направлению, если граничные кривые
  по этому направлению совпадают.

  @param surface NURBS-поверхность
  @param is_u_direction 1 для проверки по U, 0 для проверки по V
  @return 1 если поверхность замкнута, 0 в противном случае
}
function nurbs_surface_is_closed(
  surface: TLN_NurbsSurface;
  is_u_direction: Integer): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                       Функции модификации узлов                            }
{ ========================================================================== }

{**
  Вставка узла в узловой вектор поверхности.

  Вставляет новое узловое значение указанное количество раз
  в указанном направлении. Форма поверхности не изменяется.

  @param surface Исходная NURBS-поверхность
  @param knot_value Значение вставляемого узла
  @param times Количество вставок (кратность)
  @param is_u_direction 1 для вставки по U, 0 для вставки по V
  @param out_surface Выходной параметр: модифицированная поверхность
}
procedure nurbs_surface_insert_knot(
  surface: TLN_NurbsSurface;
  knot_value: Double;
  times: Integer;
  is_u_direction: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Уточнение узлового вектора поверхности.

  Вставляет массив новых узловых значений в указанном направлении,
  сохраняя форму поверхности.

  @param surface Исходная NURBS-поверхность
  @param insert_knots Указатель на массив вставляемых узлов
  @param insert_count Количество вставляемых узлов
  @param is_u_direction 1 для вставки по U, 0 для вставки по V
  @param out_surface Выходной параметр: уточнённая поверхность
}
procedure nurbs_surface_refine_knot_vector(
  surface: TLN_NurbsSurface;
  insert_knots: PDouble;
  insert_count: Integer;
  is_u_direction: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Удаление узла из узлового вектора поверхности.

  Пытается удалить узловое значение указанное количество раз
  в указанном направлении. Успешность зависит от возможности
  сохранить форму поверхности.

  @param surface Исходная NURBS-поверхность
  @param knot_value Значение удаляемого узла
  @param times Количество удалений
  @param is_u_direction 1 для удаления по U, 0 для удаления по V
  @param out_surface Выходной параметр: модифицированная поверхность
}
procedure nurbs_surface_remove_knot(
  surface: TLN_NurbsSurface;
  knot_value: Double;
  times: Integer;
  is_u_direction: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                      Функции изменения степени                             }
{ ========================================================================== }

{**
  Повышение степени поверхности.

  Увеличивает степень поверхности на указанную величину
  в указанном направлении. Форма поверхности не изменяется.

  @param surface Исходная NURBS-поверхность
  @param times Количество раз повышения степени
  @param is_u_direction 1 для повышения по U, 0 для повышения по V
  @param out_surface Выходной параметр: поверхность повышенной степени
}
procedure nurbs_surface_elevate_degree(
  surface: TLN_NurbsSurface;
  times: Integer;
  is_u_direction: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Понижение степени поверхности.

  Уменьшает степень поверхности на 1 в указанном направлении.
  Операция возможна только если поверхность допускает аппроксимацию
  меньшей степени.

  @param surface Исходная NURBS-поверхность
  @param is_u_direction 1 для понижения по U, 0 для понижения по V
  @param out_surface Выходной параметр: поверхность пониженной степени
  @return 1 при успехе, 0 если понижение невозможно
}
function nurbs_surface_reduce_degree(
  surface: TLN_NurbsSurface;
  is_u_direction: Integer;
  out_surface: PLN_NurbsSurface): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                     Функции декомпозиции и тесселяции                      }
{ ========================================================================== }

{**
  Декомпозиция NURBS-поверхности в патчи Безье.

  Разбивает поверхность на отдельные патчи Безье путём вставки узлов
  для достижения максимальной кратности во всех внутренних узлах.

  @param surface Исходная NURBS-поверхность
  @param out_patches Выходной массив патчей Безье
  @param max_patches Максимальное количество патчей
  @return Фактическое количество созданных патчей
}
function nurbs_surface_decompose_to_beziers(
  surface: TLN_NurbsSurface;
  out_patches: PLN_NurbsSurface;
  max_patches: Integer): Integer;
  cdecl; external LNLIB_DLL;

{**
  Равномерная тесселяция поверхности.

  Разбивает поверхность на равные по параметрам сегменты,
  возвращая точки и соответствующие UV-координаты.

  @param surface NURBS-поверхность
  @param out_points Выходной массив точек на поверхности
  @param out_uvs Выходной массив UV-координат точек
  @param max_count Максимальное количество точек
}
procedure nurbs_surface_equally_tessellate(
  surface: TLN_NurbsSurface;
  out_points: PXYZ;
  out_uvs: PUV;
  max_count: Integer);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                    Функции поиска параметров на поверхности                }
{ ========================================================================== }

{**
  Определение параметров UV на поверхности по ближайшей точке.

  Находит значения параметров U и V, при которых точка на поверхности
  наиболее близка к заданной точке в пространстве.

  @param surface NURBS-поверхность
  @param given_point Точка в пространстве
  @return UV-координаты ближайшей точки на поверхности
}
function nurbs_surface_get_param_on_surface(
  surface: TLN_NurbsSurface;
  given_point: TXYZ): TUV;
  cdecl; external LNLIB_DLL;

{**
  Определение параметров UV методом обобщённого поиска (GSA).

  Использует генетический алгоритм для поиска ближайшей точки
  на поверхности. Может быть более надёжным для сложных поверхностей.

  @param surface NURBS-поверхность
  @param given_point Точка в пространстве
  @return UV-координаты ближайшей точки на поверхности
}
function nurbs_surface_get_param_on_surface_by_gsa(
  surface: TLN_NurbsSurface;
  given_point: TXYZ): TUV;
  cdecl; external LNLIB_DLL;

{**
  Вычисление UV-касательной на поверхности.

  Вычисляет направление в параметрическом пространстве,
  соответствующее заданному 3D-касательному вектору.

  @param surface NURBS-поверхность
  @param param UV-координаты точки на поверхности
  @param tangent 3D-касательный вектор
  @param out_uv_tangent Выходной параметр: касательная в UV-пространстве
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_get_uv_tangent(
  surface: TLN_NurbsSurface;
  param: TUV;
  tangent: TXYZ;
  out_uv_tangent: PUV): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                      Функции перепараметризации                            }
{ ========================================================================== }

{**
  Перепараметризация поверхности на новый диапазон.

  Линейно преобразует диапазоны параметров U и V в новые
  интервалы [min_u, max_u] и [min_v, max_v].

  @param surface Исходная NURBS-поверхность
  @param min_u Минимальное значение нового диапазона по U
  @param max_u Максимальное значение нового диапазона по U
  @param min_v Минимальное значение нового диапазона по V
  @param max_v Максимальное значение нового диапазона по V
  @param out_surface Выходной параметр: перепараметризованная поверхность
}
procedure nurbs_surface_reparametrize(
  surface: TLN_NurbsSurface;
  min_u: Double;
  max_u: Double;
  min_v: Double;
  max_v: Double;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                 Функции создания примитивных поверхностей                  }
{ ========================================================================== }

{**
  Создание билинейной поверхности.

  Создаёт простейшую NURBS-поверхность степени 1x1, определённую
  четырьмя угловыми точками. Результат — плоская или гиперболическая
  поверхность в зависимости от расположения точек.

  @param top_left Верхняя левая угловая точка
  @param top_right Верхняя правая угловая точка
  @param bottom_left Нижняя левая угловая точка
  @param bottom_right Нижняя правая угловая точка
  @param out_surface Выходной параметр: билинейная поверхность
}
procedure nurbs_surface_create_bilinear(
  top_left: TXYZ;
  top_right: TXYZ;
  bottom_left: TXYZ;
  bottom_right: TXYZ;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Создание цилиндрической поверхности.

  Создаёт NURBS-представление части цилиндра с заданным
  центром, осями, радиусом, высотой и угловым диапазоном.

  @param origin Центр основания цилиндра
  @param x_axis Направление оси X (нормализованное)
  @param y_axis Направление оси Y (нормализованное, перпендикулярно x_axis)
  @param start_rad Начальный угол в радианах
  @param end_rad Конечный угол в радианах
  @param radius Радиус цилиндра
  @param height Высота цилиндра
  @param out_surface Выходной параметр: цилиндрическая поверхность
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_create_cylindrical(
  origin: TXYZ;
  x_axis: TXYZ;
  y_axis: TXYZ;
  start_rad: Double;
  end_rad: Double;
  radius: Double;
  height: Double;
  out_surface: PLN_NurbsSurface): Integer;
  cdecl; external LNLIB_DLL;

{**
  Создание линейчатой поверхности.

  Создаёт поверхность, образованную линейной интерполяцией между
  двумя граничными кривыми. Результат — поверхность степени 1
  по направлению, соединяющему кривые.

  @param curve0 Первая граничная NURBS-кривая
  @param curve1 Вторая граничная NURBS-кривая
  @param out_surface Выходной параметр: линейчатая поверхность
}
procedure nurbs_surface_create_ruled(
  curve0: TLN_NurbsCurve;
  curve1: TLN_NurbsCurve;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Создание поверхности вращения.

  Создаёт NURBS-поверхность путём вращения профильной кривой
  вокруг заданной оси на указанный угол.

  @param origin Точка на оси вращения
  @param axis Направление оси вращения
  @param rad Угол вращения в радианах
  @param profile Профильная NURBS-кривая для вращения
  @param out_surface Выходной параметр: поверхность вращения
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_create_revolved(
  origin: TXYZ;
  axis: TXYZ;
  rad: Double;
  profile: TLN_NurbsCurve;
  out_surface: PLN_NurbsSurface): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                  Функции интерполяции и аппроксимации                      }
{ ========================================================================== }

{**
  Глобальная интерполяция точек NURBS-поверхностью.

  Создаёт NURBS-поверхность заданных степеней, которая проходит через
  все указанные точки, организованные в двумерную сетку.

  @param points Указатель на массив точек для интерполяции
                (организованы построчно: rows x cols)
  @param rows Количество строк точек
  @param cols Количество столбцов точек
  @param degree_u Требуемая степень по U
  @param degree_v Требуемая степень по V
  @param out_surface Выходной параметр: интерполирующая поверхность
}
procedure nurbs_surface_global_interpolation(
  points: PXYZ;
  rows: Integer;
  cols: Integer;
  degree_u: Integer;
  degree_v: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Бикубическая локальная интерполяция точек.

  Создаёт бикубическую NURBS-поверхность (степень 3x3), проходящую
  через все точки. Использует локальный метод вычисления касательных.

  @param points Указатель на массив точек для интерполяции
  @param rows Количество строк точек
  @param cols Количество столбцов точек
  @param out_surface Выходной параметр: интерполирующая поверхность
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_bicubic_local_interpolation(
  points: PXYZ;
  rows: Integer;
  cols: Integer;
  out_surface: PLN_NurbsSurface): Integer;
  cdecl; external LNLIB_DLL;

{**
  Глобальная аппроксимация точек NURBS-поверхностью.

  Создаёт NURBS-поверхность заданных степеней, которая приближает
  заданные точки в смысле наименьших квадратов.

  @param points Указатель на массив точек для аппроксимации
  @param rows Количество строк исходных точек
  @param cols Количество столбцов исходных точек
  @param degree_u Требуемая степень по U
  @param degree_v Требуемая степень по V
  @param ctrl_rows Желаемое количество строк контрольных точек
  @param ctrl_cols Желаемое количество столбцов контрольных точек
  @param out_surface Выходной параметр: аппроксимирующая поверхность
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_global_approximation(
  points: PXYZ;
  rows: Integer;
  cols: Integer;
  degree_u: Integer;
  degree_v: Integer;
  ctrl_rows: Integer;
  ctrl_cols: Integer;
  out_surface: PLN_NurbsSurface): Integer;
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{              Функции создания поверхностей методом развёртки               }
{ ========================================================================== }

{**
  Создание поверхности методом качания (swung surface).

  Создаёт поверхность путём масштабирования профильной кривой
  вдоль траекторной кривой.

  @param profile Профильная NURBS-кривая
  @param trajectory Траекторная NURBS-кривая
  @param scale Коэффициент масштабирования
  @param out_surface Выходной параметр: поверхность качания
  @return 1 при успехе, 0 при ошибке
}
function nurbs_surface_create_swung(
  profile: TLN_NurbsCurve;
  trajectory: TLN_NurbsCurve;
  scale: Double;
  out_surface: PLN_NurbsSurface): Integer;
  cdecl; external LNLIB_DLL;

{**
  Создание поверхности методом лофтинга.

  Создаёт поверхность, проходящую через набор сечений (кривых).
  Поддерживает пользовательскую степень траектории и узловой вектор.

  @param sections Указатель на массив NURBS-кривых сечений
  @param section_count Количество сечений
  @param out_surface Выходной параметр: поверхность лофтинга
  @param custom_trajectory_degree Пользовательская степень траектории
                                  (0 для автоматического выбора)
  @param custom_knots Указатель на пользовательский узловой вектор
                      (NULL для автоматического вычисления)
  @param knot_count Количество пользовательских узлов
}
procedure nurbs_surface_create_loft(
  sections: PLN_NurbsCurve;
  section_count: Integer;
  out_surface: PLN_NurbsSurface;
  custom_trajectory_degree: Integer;
  custom_knots: PDouble;
  knot_count: Integer);
  cdecl; external LNLIB_DLL;

{**
  Создание поверхности обобщённым трансляционным методом.

  Создаёт поверхность путём перемещения профильной кривой
  вдоль траекторной кривой с сохранением ориентации.

  @param profile Профильная NURBS-кривая
  @param trajectory Траекторная NURBS-кривая
  @param out_surface Выходной параметр: поверхность развёртки
}
procedure nurbs_surface_create_generalized_translational_sweep(
  profile: TLN_NurbsCurve;
  trajectory: TLN_NurbsCurve;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Создание поверхности развёрткой с интерполяцией.

  Создаёт поверхность путём протягивания профиля вдоль траектории
  с интерполяцией промежуточных положений профиля.

  @param profile Профильная NURBS-кривая
  @param trajectory Траекторная NURBS-кривая
  @param min_profiles Минимальное количество промежуточных профилей
  @param out_surface Выходной параметр: поверхность развёртки
}
procedure nurbs_surface_create_sweep_interpolated(
  profile: TLN_NurbsCurve;
  trajectory: TLN_NurbsCurve;
  min_profiles: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Создание поверхности развёрткой без интерполяции.

  Создаёт поверхность путём протягивания профиля вдоль траектории
  без интерполяции промежуточных положений.

  @param profile Профильная NURBS-кривая
  @param trajectory Траекторная NURBS-кривая
  @param min_profiles Минимальное количество промежуточных профилей
  @param trajectory_degree Степень поверхности по направлению траектории
  @param out_surface Выходной параметр: поверхность развёртки
}
procedure nurbs_surface_create_sweep_noninterpolated(
  profile: TLN_NurbsCurve;
  trajectory: TLN_NurbsCurve;
  min_profiles: Integer;
  trajectory_degree: Integer;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{            Функции создания поверхностей по сетке кривых                   }
{ ========================================================================== }

{**
  Создание поверхности Гордона.

  Создаёт поверхность по сетке пересекающихся кривых
  в направлениях U и V и точкам их пересечения.

  @param u_curves Указатель на массив кривых в направлении U
  @param u_count Количество кривых в направлении U
  @param v_curves Указатель на массив кривых в направлении V
  @param v_count Количество кривых в направлении V
  @param intersections Указатель на массив точек пересечения
                       (размер u_count x v_count)
  @param out_surface Выходной параметр: поверхность Гордона
}
procedure nurbs_surface_create_gordon(
  u_curves: PLN_NurbsCurve;
  u_count: Integer;
  v_curves: PLN_NurbsCurve;
  v_count: Integer;
  intersections: PXYZ;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{**
  Создание поверхности Кунса.

  Создаёт поверхность по четырём граничным кривым, образующим
  замкнутый контур. Результат — гладкая поверхность, проходящая
  через все границы.

  @param left Левая граничная кривая
  @param bottom Нижняя граничная кривая
  @param right Правая граничная кривая
  @param top Верхняя граничная кривая
  @param out_surface Выходной параметр: поверхность Кунса
}
procedure nurbs_surface_create_coons(
  left: TLN_NurbsCurve;
  bottom: TLN_NurbsCurve;
  right: TLN_NurbsCurve;
  top: TLN_NurbsCurve;
  out_surface: PLN_NurbsSurface);
  cdecl; external LNLIB_DLL;

{ ========================================================================== }
{                 Функции вычисления площади и триангуляции                  }
{ ========================================================================== }

{**
  Вычисление приблизительной площади поверхности.

  Использует численное интегрирование для оценки площади поверхности.

  @param surface NURBS-поверхность
  @param integrator_type Метод численного интегрирования
  @return Приблизительная площадь поверхности
}
function nurbs_surface_approximate_area(
  surface: TLN_NurbsSurface;
  integrator_type: Integer): Double;
  cdecl; external LNLIB_DLL;

{**
  Триангуляция NURBS-поверхности.

  Создаёт полигональную сетку (меш), аппроксимирующую поверхность,
  с заданным разрешением по направлениям U и V.

  @param surface NURBS-поверхность
  @param resolution_u Разрешение сетки по направлению U
  @param resolution_v Разрешение сетки по направлению V
  @param use_delaunay 1 для использования триангуляции Делоне, 0 для обычной
  @return Полигональная сетка, аппроксимирующая поверхность
}
function nurbs_surface_triangulate(
  surface: TLN_NurbsSurface;
  resolution_u: Integer;
  resolution_v: Integer;
  use_delaunay: Integer): TLNMesh;
  cdecl; external LNLIB_DLL;

implementation

end.
