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
  Модуль LNObject_CAPI - структуры данных для геометрических объектов.

  Предоставляет определения структур C-библиотеки LNLib для представления
  геометрических объектов: информация о дугах и полигональные сетки.

  Оригинальный C-заголовок: LNObject_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, UV_CAPI, XYZ_CAPI
}
unit LNObject_CAPI;

{$mode delphi}{$H+}

interface

uses
  UV_CAPI,
  XYZ_CAPI;

type
  {**
    Информация о дуге окружности.

    Структура содержит параметры дуги: радиус и центр.
    Используется для представления дуговых сегментов кривых.

    @member radius Радиус дуги
    @member center Центр дуги (координаты центра окружности)
  }
  TLNArcInfo = record
    radius: Double;
    center: TXYZ;
  end;
  PLNArcInfo = ^TLNArcInfo;

  {**
    Полигональная сетка (меш).

    Структура для представления триангулированной поверхности.
    Содержит вершины, грани, UV-координаты для текстурирования
    и нормали для освещения.

    @member vertices Указатель на массив вершин (координаты XYZ)
    @member vertices_count Количество вершин
    @member faces Указатель на массив индексов граней
    @member faces_data_count Общее количество индексов в массиве граней
    @member uvs Указатель на массив UV-координат для текстурирования
    @member uvs_count Количество UV-координат
    @member uv_indices Указатель на массив индексов UV-координат
    @member uv_indices_data_count Общее количество индексов UV
    @member normals Указатель на массив нормалей
    @member normals_count Количество нормалей
    @member normal_indices Указатель на массив индексов нормалей
    @member normal_indices_data_count Общее количество индексов нормалей
  }
  TLNMesh = record
    vertices: PXYZ;
    vertices_count: Integer;

    faces: PInteger;
    faces_data_count: Integer;

    uvs: PUV;
    uvs_count: Integer;

    uv_indices: PInteger;
    uv_indices_data_count: Integer;

    normals: PXYZ;
    normals_count: Integer;

    normal_indices: PInteger;
    normal_indices_data_count: Integer;
  end;
  PLNMesh = ^TLNMesh;

implementation

end.
