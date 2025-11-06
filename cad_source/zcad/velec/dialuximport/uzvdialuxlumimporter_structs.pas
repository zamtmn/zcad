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
{$mode objfpc}{$H+}

{**Модуль структур данных для импорта светильников Dialux}
unit uzvdialuxlumimporter_structs;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  uzegeometrytypes,
  uzeentity;

const
  // Имена слоев Dialux
  LAYER_DLX_LUM = 'DLX_LUM';
  LAYER_DLX_LUMKEY_IDX = 'DLX_LUMKEY_IDX';

  // Радиус поиска соответствия между текстом и геометрией (мм)
  SEARCH_RADIUS_MM = 600.0;

  // Допуск для группировки блоков в одной точке (мм)
  GROUPING_TOLERANCE_MM = 0.1;

  // Префикс для фильтра блоков
  BLOCK_FILTER_PREFIX = 'DEVICE_VEL_LIGHT';

type
  {**Список сущностей геометрии}
  TEntityList = class(TList)
  end;

  {**Запись о распознанном светильнике}
  TLightItem = record
    LumKey: string;             // Номер светильника (например, "L1")
    Center: GDBvertex;          // Геометрический центр светильника
    GeometryEntities: TEntityList;  // Список геометрических примитивов
    TextEntity: PGDBObjEntity;  // Ссылка на текстовый примитив
  end;

  {**Массив распознанных светильников}
  TLightItemArray = array of TLightItem;

  {**Список геометрии светильников}
  TLuminairesGeometryList = class(TList)
  end;

  {**Список текстовых обозначений светильников}
  TLuminairesKeysList = class(TList)
  end;

  {**Список загруженных блоков}
  TLoadedBlocksList = class(TStringList)
  end;

  {**Структура данных для результатов парсинга}
  TParsedData = record
    LuminairesGeometry: TLuminairesGeometryList;
    LuminairesKeys: TLuminairesKeysList;
    GeometryCount: Integer;
    KeysCount: Integer;
  end;

implementation

end.
