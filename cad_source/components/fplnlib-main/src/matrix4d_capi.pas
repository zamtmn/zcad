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
  Модуль Matrix4d_CAPI - операции с матрицами преобразования 4x4.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для работы
  с матрицами 4x4, используемыми для аффинных преобразований
  в трёхмерном пространстве: перемещения, вращения, масштабирования
  и отражения.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: Matrix4d_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI
}
unit Matrix4d_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI;

type
  {**
    Матрица преобразования 4x4.

    Хранит 16 элементов матрицы в одномерном массиве (построчно).
    Используется для представления аффинных преобразований
    в однородных координатах.

    @member m Массив из 16 элементов матрицы (хранятся построчно)
  }
  TMatrix4d = record
    m: array[0..15] of Double;
  end;
  PMatrix4d = ^TMatrix4d;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  matrix4d_identity, matrix4d_create_translation, matrix4d_create_rotation,
  matrix4d_create_scale, matrix4d_create_reflection, matrix4d_get_basis_x,
  matrix4d_get_basis_y, matrix4d_get_basis_z, matrix4d_get_basis_w,
  matrix4d_of_point, matrix4d_of_vector, matrix4d_multiply,
  matrix4d_get_inverse, matrix4d_get_determinant }

implementation

end.
