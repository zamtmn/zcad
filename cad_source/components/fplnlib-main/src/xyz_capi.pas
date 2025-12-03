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

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: XYZ_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions
}
unit XYZ_CAPI;

{$mode delphi}{$H+}

interface

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

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  xyz_create, xyz_zero, xyz_add, xyz_subtract, xyz_negative,
  xyz_multiply, xyz_divide, xyz_length, xyz_sqr_length,
  xyz_is_zero, xyz_is_unit, xyz_normalize, xyz_dot, xyz_cross,
  xyz_distance, xyz_equals }

implementation

end.
