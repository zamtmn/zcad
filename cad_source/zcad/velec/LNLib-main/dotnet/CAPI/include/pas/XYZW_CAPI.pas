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
  Модуль XYZW_CAPI - обёртка для работы с однородными координатами.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для работы
  с четырёхмерными однородными координатами, используемыми для представления
  взвешенных контрольных точек NURBS-кривых и поверхностей.

  Оригинальный C-заголовок: XYZW_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI
}
unit XYZW_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
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

{** Создание XYZW-координаты из четырёх значений **}
function xyzw_create(wx, wy, wz, w: Double): TXYZW; cdecl; external LNLIB_DLL;

{** Создание XYZW-координаты из XYZ-координаты и веса **}
function xyzw_create_from_xyz(xyz: TXYZ; w: Double): TXYZW;
  cdecl; external LNLIB_DLL;

{**
  Преобразование XYZW в XYZ координаты.
  @param v Однородная координата
  @param divideWeight 1 - делить на вес (получить декартовы координаты),
                      0 - не делить (получить предумноженные координаты)
  @return Трёхмерная координата
}
function xyzw_to_xyz(v: TXYZW; divideWeight: Integer): TXYZ;
  cdecl; external LNLIB_DLL;

{** Сложение двух XYZW-координат (покомпонентное) **}
function xyzw_add(a, b: TXYZW): TXYZW; cdecl; external LNLIB_DLL;

{** Умножение XYZW-координаты на скаляр **}
function xyzw_multiply(a: TXYZW; scalar: Double): TXYZW;
  cdecl; external LNLIB_DLL;

{** Деление XYZW-координаты на скаляр **}
function xyzw_divide(a: TXYZW; scalar: Double): TXYZW;
  cdecl; external LNLIB_DLL;

{** Вычисление расстояния между двумя XYZW-координатами **}
function xyzw_distance(a, b: TXYZW): Double; cdecl; external LNLIB_DLL;

{** Получение компоненты wx **}
function xyzw_get_wx(v: TXYZW): Double; cdecl; external LNLIB_DLL;

{** Получение компоненты wy **}
function xyzw_get_wy(v: TXYZW): Double; cdecl; external LNLIB_DLL;

{** Получение компоненты wz **}
function xyzw_get_wz(v: TXYZW): Double; cdecl; external LNLIB_DLL;

{** Получение веса w **}
function xyzw_get_w(v: TXYZW): Double; cdecl; external LNLIB_DLL;

implementation

end.
