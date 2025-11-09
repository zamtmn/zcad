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

unit uzvcablecollector_utils;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzvcablecollector_types;

// Функция сравнения для сортировки по имени кабеля и методу монтажа
function CompareCableGroupInfo(const Item1, Item2: TCableGroupInfo): Integer;

// Функция форматирования длины кабеля
function FormatCableLength(const Length: Double): String;

// Функция создания уникального ключа для группировки
function GetGroupKey(const CableName, MountingMethod: String): String;

implementation

// Сравнение групп для сортировки
// Сначала по имени кабеля, затем по методу монтажа
function CompareCableGroupInfo(const Item1, Item2: TCableGroupInfo): Integer;
begin
  Result := CompareText(Item1.CableName, Item2.CableName);
  if Result = 0 then
    Result := CompareText(Item1.MountingMethod, Item2.MountingMethod);
end;

// Форматирование длины кабеля с двумя знаками после запятой
function FormatCableLength(const Length: Double): String;
begin
  Result := FormatFloat('0.00', Length);
end;

// Создание уникального ключа для группировки кабелей
function GetGroupKey(const CableName, MountingMethod: String): String;
begin
  Result := CableName + '|' + MountingMethod;
end;

end.
