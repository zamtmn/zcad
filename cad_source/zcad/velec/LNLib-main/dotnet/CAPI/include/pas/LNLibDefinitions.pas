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
  Модуль LNLibDefinitions - базовые определения для обёртки C-библиотеки LNLib.

  Содержит определения констант и базовых типов, необходимых для работы
  с библиотекой LNLib через внешний интерфейс.

  Оригинальный C-заголовок: LNLibDefinitions.h
  Дата создания: 2025-12-02
  Зависимости: нет
}
unit LNLibDefinitions;

{$mode delphi}{$H+}

interface

const
  {** Имя динамической библиотеки LNLib для разных платформ **}
  {$IFDEF WINDOWS}
  LNLIB_DLL = 'lnlib.dll';
  {$ELSE}
    {$IFDEF DARWIN}
    LNLIB_DLL = 'liblnlib.dylib';
    {$ELSE}
    LNLIB_DLL = 'liblnlib.so';
    {$ENDIF}
  {$ENDIF}

implementation

end.
