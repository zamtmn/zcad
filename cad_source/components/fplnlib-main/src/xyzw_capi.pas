{
*****************************************************************************
*                                                                           *
*  This file is part of the fpLNLib                                         *
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
{**
  Модуль XYZW_CAPI - обёртка для работы с однородными координатами.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для работы
  с четырёхмерными однородными координатами, используемыми для представления
  взвешенных контрольных точек NURBS-кривых и поверхностей.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: XYZW_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI
}
unit XYZW_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI;

type
  {**
    Структура для хранения однородных координат.

    Используется для представления взвешенных контрольных точек в NURBS.
    Координаты хранятся в предумноженной форме: (wx, wy, wz, w),
    где (wx, wy, wz) = (x*w, y*w, z*w).

    @member wx Координата X, умноженная на вес (x * w)
    @member wy Координата Y, умноженная на вес (y * w)
    @member wz Координата Z, умноженная на вес (z * w)
    @member w Вес точки (w > 0 для корректных NURBS)
  }
  TXYZW = record
    wx: Double;
    wy: Double;
    wz: Double;
    w: Double;
  end;
  PXYZW = ^TXYZW;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  xyzw_create, xyzw_create_from_xyz, xyzw_to_xyz, xyzw_add,
  xyzw_multiply, xyzw_divide, xyzw_distance, xyzw_get_wx,
  xyzw_get_wy, xyzw_get_wz, xyzw_get_w }

implementation

end.
