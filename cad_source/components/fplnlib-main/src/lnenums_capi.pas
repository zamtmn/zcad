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
  Модуль LNEnums_CAPI - перечисления для библиотеки LNLib.

  Содержит определения всех перечислимых типов, используемых в C API
  библиотеки LNLib для работы с NURBS-кривыми и поверхностями.

  Оригинальный C-заголовок: LNEnums_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: нет
}
unit LNEnums_CAPI;

{$mode delphi}{$H+}

interface

type
  {**
    Тип пересечения двух кривых.

    Определяет результат анализа взаимного расположения двух кривых
    в пространстве.

    @value CURVE_CURVE_INTERSECTING Кривые пересекаются в одной или нескольких точках
    @value CURVE_CURVE_PARALLEL Кривые параллельны (не пересекаются)
    @value CURVE_CURVE_COINCIDENT Кривые совпадают (бесконечное множество точек)
    @value CURVE_CURVE_SKEW Кривые скрещиваются (не пересекаются в 3D)
  }
  TCurveCurveIntersectionType = (
    CURVE_CURVE_INTERSECTING = 0,
    CURVE_CURVE_PARALLEL = 1,
    CURVE_CURVE_COINCIDENT = 2,
    CURVE_CURVE_SKEW = 3
  );

  {**
    Тип пересечения линии и плоскости.

    Определяет результат анализа взаимного расположения линии
    и плоскости в пространстве.

    @value LINE_PLANE_INTERSECTING Линия пересекает плоскость в одной точке
    @value LINE_PLANE_PARALLEL Линия параллельна плоскости
    @value LINE_PLANE_ON Линия лежит на плоскости
  }
  TLinePlaneIntersectionType = (
    LINE_PLANE_INTERSECTING = 0,
    LINE_PLANE_PARALLEL = 1,
    LINE_PLANE_ON = 2
  );

  {**
    Тип нормали кривой.

    Определяет способ вычисления нормали к кривой в заданной точке.

    @value CURVE_NORMAL_NORMAL Главная нормаль кривой
    @value CURVE_NORMAL_BINORMAL Бинормаль кривой
  }
  TCurveNormal = (
    CURVE_NORMAL_NORMAL = 0,
    CURVE_NORMAL_BINORMAL = 1
  );

  {**
    Направление на поверхности.

    Указывает направление параметризации поверхности для различных
    операций (производные, кривизна и т.д.)

    @value SURFACE_DIRECTION_ALL Оба направления (U и V)
    @value SURFACE_DIRECTION_U Только направление U
    @value SURFACE_DIRECTION_V Только направление V
  }
  TSurfaceDirection = (
    SURFACE_DIRECTION_ALL = 0,
    SURFACE_DIRECTION_U = 1,
    SURFACE_DIRECTION_V = 2
  );

  {**
    Тип кривизны поверхности.

    Определяет метод вычисления кривизны поверхности в заданной точке.

    @value SURFACE_CURVATURE_MAXIMUM Максимальная главная кривизна
    @value SURFACE_CURVATURE_MINIMUM Минимальная главная кривизна
    @value SURFACE_CURVATURE_GAUSS Гауссова кривизна (произведение главных кривизн)
    @value SURFACE_CURVATURE_MEAN Средняя кривизна (среднее главных кривизн)
    @value SURFACE_CURVATURE_ABS Абсолютная кривизна
    @value SURFACE_CURVATURE_RMS Среднеквадратичная кривизна
  }
  TSurfaceCurvature = (
    SURFACE_CURVATURE_MAXIMUM = 0,
    SURFACE_CURVATURE_MINIMUM = 1,
    SURFACE_CURVATURE_GAUSS = 2,
    SURFACE_CURVATURE_MEAN = 3,
    SURFACE_CURVATURE_ABS = 4,
    SURFACE_CURVATURE_RMS = 5
  );

  {**
    Тип интегратора.

    Определяет метод численного интегрирования, используемый для
    вычисления длины кривой, площади поверхности и других интегралов.

    @value INTEGRATOR_SIMPSON Метод Симпсона
    @value INTEGRATOR_GAUSS_LEGENDRE Квадратура Гаусса-Лежандра
    @value INTEGRATOR_CHEBYSHEV Квадратура Чебышева
  }
  TIntegratorType = (
    INTEGRATOR_SIMPSON = 0,
    INTEGRATOR_GAUSS_LEGENDRE = 1,
    INTEGRATOR_CHEBYSHEV = 2
  );

  {**
    Тип смещения (офсета) кривой.

    Определяет алгоритм построения эквидистантной кривой.

    @value OFFSET_TILLER_HANSON Метод Тиллера-Хэнсона
    @value OFFSET_PIEGL_TILLER Метод Пигла-Тиллера
  }
  TOffsetType = (
    OFFSET_TILLER_HANSON = 0,
    OFFSET_PIEGL_TILLER = 1
  );

implementation

end.
