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

{**Модуль структур данных для управления подключениями устройств}
unit uzvconnect_struct;

{$INCLUDE zengineconfig.inc}

interface
uses
  gvector,
  uzeentdevice;

type
  {**Структура данных одного подключения устройства}
  TConnectItem = record
    Device: PGDBObjDevice;        // Ссылка на объект устройства
    NMO_Name: String;             // Имя устройства (параметр NMO_Name)
    SLTypeagen: String;           // Имя суперлинии (SLCABAGEN_SLTypeagen)
    HeadDeviceName: String;       // Имя головного устройства (SLCABAGEN_HeadDeviceName)
    NGHeadDevice: String;         // Номер фидера (SLCABAGEN_NGHeadDevice)
  end;

  {**Список подключений устройств}
  TConnectList = specialize TVector<TConnectItem>;

var
  {**Глобальный список подключений}
  ConnectList: TConnectList;

implementation

initialization
  ConnectList := TConnectList.Create;

finalization
  ConnectList.Free;

end.
