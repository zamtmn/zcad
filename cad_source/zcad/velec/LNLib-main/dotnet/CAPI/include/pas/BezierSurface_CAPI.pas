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
  Модуль BezierSurface_CAPI - обёртка для работы с поверхностями Безье.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  точек на поверхностях Безье.

  Поверхность Безье — это параметрическая поверхность, определяемая
  двумерной сеткой контрольных точек и тензорным произведением
  полиномов Бернштейна по направлениям U и V.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: BezierSurface_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI, UV_CAPI
}
unit BezierSurface_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI,
  UV_CAPI;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  bezier_surface_get_point_by_de_casteljau }

implementation

end.
