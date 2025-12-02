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
  Модуль Intersection_CAPI - обёртка для функций пересечения геометрических
  объектов.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  пересечений между лучами, линиями и плоскостями.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: Intersection_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNEnums_CAPI, XYZ_CAPI
}
unit Intersection_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNEnums_CAPI,
  XYZ_CAPI;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  intersection_compute_rays, intersection_compute_line_and_plane }

implementation

end.
