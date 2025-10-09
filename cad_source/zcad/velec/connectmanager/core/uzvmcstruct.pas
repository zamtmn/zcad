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

unit uzvmcstruct;
{$INCLUDE zengineconfig.inc}

interface

type
  PTVElectrDevStruct=^TVElectrDevStruct;
  TVElectrDevStruct = record
    zcadid: integer; // ид устройства внутри zcad
    fullname: string; // полное имя устройства
    basename: string; // базовое имя устройства
    realname: string; // реальное имя устройства
    tracename: string; // Имя трассы к которой принадлежит устройство
    headdev: string; // головное устройство
    feedernum: integer; // номер фидера
    canbehead: integer; // Я могу быть головным устройством
    devtype: string; // тип устройства
    opmode: string; // режим работы
    power: double; // мощность
    voltage: integer; // напряжение
    cosfi: double; // cosfi
  end;
  TListVElectrDevStruct=specialize TVector<TVElectrDevStruct>;

implementation

end.
