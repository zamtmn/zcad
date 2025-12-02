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
  Модуль UV_CAPI - обёртка для работы с 2D параметрическими координатами UV.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для работы
  с двумерными параметрическими координатами, используемыми при работе
  с NURBS-поверхностями.

  Оригинальный C-заголовок: UV_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions
}
unit UV_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions;

type
  {**
    Структура для хранения параметрических координат UV.

    Используется для представления точки в параметрическом пространстве
    NURBS-поверхности.

    @member u Координата по параметру U (обычно в диапазоне [0, 1])
    @member v Координата по параметру V (обычно в диапазоне [0, 1])
  }
  TUV = record
    u: Double;
    v: Double;
  end;
  PUV = ^TUV;

{** Создание UV-координаты из двух значений **}
function uv_create(u, v: Double): TUV; cdecl; external LNLIB_DLL;

{** Получение компоненты U из UV-координаты **}
function uv_get_u(uv: TUV): Double; cdecl; external LNLIB_DLL;

{** Получение компоненты V из UV-координаты **}
function uv_get_v(uv: TUV): Double; cdecl; external LNLIB_DLL;

{** Сложение двух UV-координат (покомпонентное) **}
function uv_add(a, b: TUV): TUV; cdecl; external LNLIB_DLL;

{** Вычитание UV-координат (a - b) **}
function uv_subtract(a, b: TUV): TUV; cdecl; external LNLIB_DLL;

{** Инверсия UV-координаты (изменение знака компонент) **}
function uv_negative(uv: TUV): TUV; cdecl; external LNLIB_DLL;

{** Нормализация UV-вектора (приведение к единичной длине) **}
function uv_normalize(uv: TUV): TUV; cdecl; external LNLIB_DLL;

{** Масштабирование UV-координаты на заданный множитель **}
function uv_scale(uv: TUV; factor: Double): TUV; cdecl; external LNLIB_DLL;

{** Деление UV-координаты на делитель **}
function uv_divide(uv: TUV; divisor: Double): TUV; cdecl; external LNLIB_DLL;

{** Вычисление длины UV-вектора (евклидова норма) **}
function uv_length(uv: TUV): Double; cdecl; external LNLIB_DLL;

{** Вычисление квадрата длины UV-вектора (без извлечения корня) **}
function uv_sqr_length(uv: TUV): Double; cdecl; external LNLIB_DLL;

{** Вычисление расстояния между двумя UV-координатами **}
function uv_distance(a, b: TUV): Double; cdecl; external LNLIB_DLL;

{**
  Проверка, является ли UV-вектор нулевым с заданной точностью.
  @return 1 если вектор нулевой, 0 в противном случае
}
function uv_is_zero(uv: TUV; epsilon: Double): Integer; cdecl; external LNLIB_DLL;

{**
  Проверка, является ли UV-вектор единичным с заданной точностью.
  @return 1 если вектор единичный, 0 в противном случае
}
function uv_is_unit(uv: TUV; epsilon: Double): Integer; cdecl; external LNLIB_DLL;

{**
  Проверка приблизительного равенства двух UV-координат.
  @return 1 если координаты равны с точностью epsilon, 0 в противном случае
}
function uv_is_almost_equal(a, b: TUV; epsilon: Double): Integer;
  cdecl; external LNLIB_DLL;

{** Скалярное произведение двух UV-векторов **}
function uv_dot(a, b: TUV): Double; cdecl; external LNLIB_DLL;

{**
  Псевдовекторное произведение двух UV-векторов (2D аналог).
  Возвращает z-компоненту векторного произведения при расширении до 3D.
}
function uv_cross(a, b: TUV): Double; cdecl; external LNLIB_DLL;

implementation

end.
