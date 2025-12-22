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
  Модуль UV_CAPI - обёртка для работы с 2D параметрическими координатами UV.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для работы
  с двумерными параметрическими координатами, используемыми при работе
  с NURBS-поверхностями.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: UV_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: нет
}
unit UV_CAPI;

{$mode delphi}{$H+}

interface

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

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  uv_create, uv_get_u, uv_get_v, uv_add, uv_subtract,
  uv_negative, uv_normalize, uv_scale, uv_divide, uv_length,
  uv_sqr_length, uv_distance, uv_is_zero, uv_is_unit,
  uv_is_almost_equal, uv_dot, uv_cross }

implementation

end.
