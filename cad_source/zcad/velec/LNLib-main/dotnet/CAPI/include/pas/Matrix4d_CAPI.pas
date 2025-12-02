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

  Оригинальный C-заголовок: Matrix4d_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI
}
unit Matrix4d_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
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

{**
  Создание единичной матрицы 4x4.

  Единичная матрица не изменяет точки при преобразовании.

  @return Единичная матрица
}
function matrix4d_identity: TMatrix4d; cdecl; external LNLIB_DLL;

{**
  Создание матрицы перемещения (трансляции).

  @param vector Вектор перемещения (смещение по осям X, Y, Z)
  @return Матрица перемещения
}
function matrix4d_create_translation(vector: TXYZ): TMatrix4d;
  cdecl; external LNLIB_DLL;

{**
  Создание матрицы вращения вокруг произвольной оси.

  @param axis Ось вращения (должна быть нормализована)
  @param rad Угол вращения в радианах
  @return Матрица вращения
}
function matrix4d_create_rotation(axis: TXYZ; rad: Double): TMatrix4d;
  cdecl; external LNLIB_DLL;

{**
  Создание матрицы масштабирования.

  @param scale Коэффициенты масштабирования по осям X, Y, Z
  @return Матрица масштабирования
}
function matrix4d_create_scale(scale: TXYZ): TMatrix4d;
  cdecl; external LNLIB_DLL;

{**
  Создание матрицы отражения относительно плоскости.

  Плоскость отражения проходит через начало координат
  и задаётся вектором нормали.

  @param normal Нормаль к плоскости отражения (должна быть нормализована)
  @return Матрица отражения
}
function matrix4d_create_reflection(normal: TXYZ): TMatrix4d;
  cdecl; external LNLIB_DLL;

{**
  Получение базисного вектора X из матрицы (первый столбец).

  @param matrix Матрица преобразования
  @return Базисный вектор X
}
function matrix4d_get_basis_x(matrix: TMatrix4d): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Получение базисного вектора Y из матрицы (второй столбец).

  @param matrix Матрица преобразования
  @return Базисный вектор Y
}
function matrix4d_get_basis_y(matrix: TMatrix4d): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Получение базисного вектора Z из матрицы (третий столбец).

  @param matrix Матрица преобразования
  @return Базисный вектор Z
}
function matrix4d_get_basis_z(matrix: TMatrix4d): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Получение вектора перемещения из матрицы (четвёртый столбец).

  @param matrix Матрица преобразования
  @return Вектор перемещения (компоненты трансляции)
}
function matrix4d_get_basis_w(matrix: TMatrix4d): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Применение матрицы преобразования к точке.

  Преобразует точку с учётом компоненты перемещения матрицы.

  @param matrix Матрица преобразования
  @param point Исходная точка
  @return Преобразованная точка
}
function matrix4d_of_point(matrix: TMatrix4d; point: TXYZ): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Применение матрицы преобразования к вектору.

  Преобразует вектор без учёта компоненты перемещения матрицы.

  @param matrix Матрица преобразования
  @param vector Исходный вектор
  @return Преобразованный вектор
}
function matrix4d_of_vector(matrix: TMatrix4d; vector: TXYZ): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Умножение двух матриц 4x4.

  Порядок важен: результат = a * b, что соответствует
  применению сначала преобразования b, затем a.

  @param a Первая матрица (левый операнд)
  @param b Вторая матрица (правый операнд)
  @return Результат умножения матриц
}
function matrix4d_multiply(a, b: TMatrix4d): TMatrix4d;
  cdecl; external LNLIB_DLL;

{**
  Вычисление обратной матрицы.

  Обратная матрица существует только для невырожденных матриц
  (с ненулевым определителем).

  @param matrix Исходная матрица
  @param out_inverse Выходной параметр: обратная матрица
  @return 1 если обратная матрица вычислена успешно, 0 если матрица вырождена
}
function matrix4d_get_inverse(
  matrix: TMatrix4d;
  out_inverse: PMatrix4d
): Integer; cdecl; external LNLIB_DLL;

{**
  Вычисление определителя матрицы 4x4.

  Определитель характеризует изменение объёма при преобразовании.
  Нулевой определитель означает вырожденное преобразование.

  @param matrix Исходная матрица
  @return Значение определителя
}
function matrix4d_get_determinant(matrix: TMatrix4d): Double;
  cdecl; external LNLIB_DLL;

implementation

end.
