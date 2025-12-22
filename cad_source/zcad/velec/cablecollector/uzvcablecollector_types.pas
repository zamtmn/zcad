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

unit uzvcablecollector_types;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVector;

type
  // Запись для хранения информации о кабеле
  PTCableInfo = ^TCableInfo;
  TCableInfo = record
    NMO_Name: String;              // Наименование кабеля
    CABLE_Segment: String;         // Номер сегмента
    CABLE_MountingMethod: String;  // Метод монтажа
    AmountD: Double;               // Длина кабеля
  end;

  // Вектор для хранения информации о кабелях
  TCableInfoVector = object(GZVector<TCableInfo>)
  end;

  // Запись для хранения сгруппированной информации
  PTCableGroupInfo = ^TCableGroupInfo;
  TCableGroupInfo = record
    CableName: String;             // Наименование кабеля
    MountingMethod: String;        // Метод монтажа
    TotalLength: Double;           // Суммарная длина
  end;

  // Вектор для хранения сгруппированной информации
  TCableGroupInfoVector = object(GZVector<TCableGroupInfo>)
  end;

implementation

end.
