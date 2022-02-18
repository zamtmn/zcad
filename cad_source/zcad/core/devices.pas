{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
} 
unit devices;
{$INCLUDE zcadconfig.inc}
interface
{Повторное описание типа в GDBDevice}
type

  PTDeviceClass=^TDeviceClass;
  TDeviceClass=(
               TDC_Unknown(*'Не определен'*),
               TDC_Connector(*'Коннестор'*),
               TDC_Shell(*'Оболочка устройства'*)
              );
  PTDeviceGroup=^TDeviceGroup;
  TDeviceGroup=(
               TDG_Unknown(*'Не определен'*),
               TDG_ElDevice(*'Электроустройство'*)
              );
  PTDeviceType=^TDeviceType;
  TDeviceType=(
               TDT_Unknown(*'Не определен'*),
               TDT_PriborOPS(*'Прибор ОПС'*),
               TDT_SensorPS(*'Извещатель ПС'*),
               TDT_SensorOS(*'Извещатель ОС'*),
               TDT_PriborKIPiA(*'Прибор автоматики'*),
               TDT_SensorKIPiA(*'Датчик'*),
               TDT_SilaIst(*'Источник энергии'*),
               TDT_SilaPotr(*'Потребитель энергии'*),
               TDT_SilaComm(*'Коммутационное устройство'*),
               TDT_Junction(*'Разветвительное устройство'*)
              );
    PTVoltage=^TVoltage;
    TVoltage=(_DC_6V(*'6В постоянного тока'*),
              _DC_12V(*'12В постоянного тока'*),
              _DC_24V(*'24В постоянного тока'*),
              _DC_27V(*'27В постоянного тока'*),
              _DC_48V(*'48В постоянного тока'*),
              _DC_60V(*'60В постоянного тока'*),
              _DC_110V(*'110В постоянного тока'*),
              _AC_12V_50Hz(*'12В,50Гц'*),
              _AC_24V_50Hz(*'24В,50Гц'*),
              _AC_36V_50Hz(*'37В,50Гц'*),
              _AC_40V_50Hz(*'40В,50Гц'*),
              _AC_110V_50Hz(*'110В,50Гц'*),
              _AC_220V_50Hz(*'220В,50Гц'*),
              _AC_380V_50Hz(*'380В,50Гц'*));
    PTCalcIP=^TCalcIP;
    TCalcIP=(_I_from_P(*'I=F(P,Cos)'*),
             _P_from_I(*'P=F(I,Cos)'*),
             _ICOS_from_P(*'I,Cos=F(P)'*));
    PTPhase=^TPhase;
    TPhase=(_ABC(*'ABC'*),
            _A(*'A'*),
            _B(*'B'*),
            _C(*'C'*));


implementation
begin
end.
