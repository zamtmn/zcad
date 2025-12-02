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
  Модуль Projection_CAPI - функции проецирования точек.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для проецирования
  точек на геометрические примитивы: лучи, отрезки, а также для
  стереографических проекций.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: Projection_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI
}
unit Projection_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  projection_point_to_ray, projection_point_to_line, projection_stereographic }

implementation

end.
