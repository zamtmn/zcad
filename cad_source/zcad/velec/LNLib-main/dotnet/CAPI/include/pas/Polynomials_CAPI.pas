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
  Модуль Polynomials_CAPI - функции для работы с полиномами и базисами.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  полиномов Бернштейна, базисных функций B-сплайнов, работы с узловыми
  векторами и преобразования между представлениями кривых.

  Оригинальный C-заголовок: Polynomials_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI, UV_CAPI
}
unit Polynomials_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  XYZ_CAPI,
  UV_CAPI;

{**
  Вычисление полинома Бернштейна.

  Вычисляет значение i-го полинома Бернштейна степени n в точке t.
  Формула: B_{i,n}(t) = C(n,i) * t^i * (1-t)^(n-i)

  @param index Индекс полинома (0 <= index <= degree)
  @param degree Степень полинома
  @param paramT Значение параметра t (обычно в диапазоне [0, 1])
  @return Значение полинома Бернштейна
}
function polynomials_bernstein(
  index: Integer;
  degree: Integer;
  paramT: Double
): Double; cdecl; external LNLIB_DLL;

{**
  Вычисление всех полиномов Бернштейна заданной степени.

  Вычисляет значения всех (degree + 1) полиномов Бернштейна в точке t.
  Результат записывается в предварительно выделенный массив.

  @param degree Степень полиномов
  @param paramT Значение параметра t
  @param out_array Выходной массив размером (degree + 1) для результатов
}
procedure polynomials_all_bernstein(
  degree: Integer;
  paramT: Double;
  out_array: PDouble
); cdecl; external LNLIB_DLL;

{**
  Вычисление полинома методом Горнера для кривой.

  Эффективный метод вычисления значения полинома в точке
  с использованием схемы Горнера.

  @param degree Степень полинома
  @param coefficients Указатель на массив коэффициентов полинома
  @param coeff_count Количество коэффициентов
  @param paramT Значение параметра t
  @return Значение полинома в точке t
}
function polynomials_horner_curve(
  degree: Integer;
  const coefficients: PDouble;
  coeff_count: Integer;
  paramT: Double
): Double; cdecl; external LNLIB_DLL;

{**
  Определение индекса спана (интервала) узлового вектора.

  Находит индекс спана, в котором находится параметр t.
  Спан - это интервал между соседними узлами.

  @param degree Степень B-сплайна
  @param knot_vector Указатель на массив узлового вектора
  @param knot_count Количество узлов
  @param paramT Значение параметра t
  @return Индекс спана, содержащего paramT
}
function polynomials_get_knot_span_index(
  degree: Integer;
  const knot_vector: PDouble;
  knot_count: Integer;
  paramT: Double
): Integer; cdecl; external LNLIB_DLL;

{**
  Определение кратности узла в узловом векторе.

  Подсчитывает, сколько раз значение paramT повторяется
  в узловом векторе (с учётом числовой погрешности).

  @param knot_vector Указатель на массив узлового вектора
  @param knot_count Количество узлов
  @param paramT Значение узла для проверки кратности
  @return Кратность узла (0 если узел отсутствует)
}
function polynomials_get_knot_multiplicity(
  const knot_vector: PDouble;
  knot_count: Integer;
  paramT: Double
): Integer; cdecl; external LNLIB_DLL;

{**
  Вычисление базисных функций B-сплайна.

  Вычисляет ненулевые базисные функции B-сплайна в заданной точке.
  Количество ненулевых функций равно (degree + 1).

  @param span_index Индекс спана (из polynomials_get_knot_span_index)
  @param degree Степень B-сплайна
  @param knot_vector Указатель на массив узлового вектора
  @param knot_count Количество узлов
  @param paramT Значение параметра t
  @param basis_functions Выходной массив размером (degree + 1) для результатов
}
procedure polynomials_basis_functions(
  span_index: Integer;
  degree: Integer;
  const knot_vector: PDouble;
  knot_count: Integer;
  paramT: Double;
  basis_functions: PDouble
); cdecl; external LNLIB_DLL;

{**
  Построение матрицы преобразования Безье в степенную форму.

  Вычисляет матрицу преобразования из представления кривой
  в форме Безье в степенную (полиномиальную) форму.

  @param degree Степень кривой
  @param out_matrix Выходная матрица размером (degree+1) x (degree+1),
                    хранится построчно
}
procedure polynomials_bezier_to_power_matrix(
  degree: Integer;
  out_matrix: PDouble
); cdecl; external LNLIB_DLL;

implementation

end.
