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
  Модуль XYZ_CAPI - обёртка для работы с трёхмерными координатами.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для работы
  с трёхмерными декартовыми координатами и векторами.

  Оригинальный C-заголовок: XYZ_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions
}
unit XYZ_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions;

type
  {**
    Структура для хранения трёхмерных координат.

    Используется для представления точек и векторов в 3D-пространстве.
    Применяется для контрольных точек NURBS-кривых и поверхностей.

    @member x Координата по оси X
    @member y Координата по оси Y
    @member z Координата по оси Z
  }
  TXYZ = record
    x: Double;
    y: Double;
    z: Double;
  end;
  PXYZ = ^TXYZ;

{** Создание XYZ-координаты из трёх значений **}
function xyz_create(x, y, z: Double): TXYZ; cdecl; external LNLIB_DLL;

{** Создание нулевого вектора (0, 0, 0) **}
function xyz_zero: TXYZ; cdecl; external LNLIB_DLL;

{** Сложение двух XYZ-координат (покомпонентное) **}
function xyz_add(a, b: TXYZ): TXYZ; cdecl; external LNLIB_DLL;

{** Вычитание XYZ-координат (a - b) **}
function xyz_subtract(a, b: TXYZ): TXYZ; cdecl; external LNLIB_DLL;

{** Инверсия XYZ-вектора (изменение знака всех компонент) **}
function xyz_negative(a: TXYZ): TXYZ; cdecl; external LNLIB_DLL;

{** Умножение XYZ-вектора на скаляр **}
function xyz_multiply(a: TXYZ; scalar: Double): TXYZ; cdecl; external LNLIB_DLL;

{** Деление XYZ-вектора на скаляр **}
function xyz_divide(a: TXYZ; scalar: Double): TXYZ; cdecl; external LNLIB_DLL;

{** Вычисление длины XYZ-вектора (евклидова норма) **}
function xyz_length(v: TXYZ): Double; cdecl; external LNLIB_DLL;

{** Вычисление квадрата длины XYZ-вектора (без извлечения корня) **}
function xyz_sqr_length(v: TXYZ): Double; cdecl; external LNLIB_DLL;

{**
  Проверка, является ли XYZ-вектор нулевым с заданной точностью.
  @return 1 если вектор нулевой, 0 в противном случае
}
function xyz_is_zero(v: TXYZ; epsilon: Double): Integer; cdecl; external LNLIB_DLL;

{**
  Проверка, является ли XYZ-вектор единичным с заданной точностью.
  @return 1 если вектор единичный, 0 в противном случае
}
function xyz_is_unit(v: TXYZ; epsilon: Double): Integer; cdecl; external LNLIB_DLL;

{** Нормализация XYZ-вектора (приведение к единичной длине) **}
function xyz_normalize(v: TXYZ): TXYZ; cdecl; external LNLIB_DLL;

{** Скалярное произведение двух XYZ-векторов **}
function xyz_dot(a, b: TXYZ): Double; cdecl; external LNLIB_DLL;

{** Векторное произведение двух XYZ-векторов **}
function xyz_cross(a, b: TXYZ): TXYZ; cdecl; external LNLIB_DLL;

{** Вычисление расстояния между двумя точками **}
function xyz_distance(a, b: TXYZ): Double; cdecl; external LNLIB_DLL;

{**
  Проверка точного равенства двух XYZ-координат.
  @return 1 если координаты равны, 0 в противном случае
}
function xyz_equals(a, b: TXYZ): Integer; cdecl; external LNLIB_DLL;

implementation

end.
