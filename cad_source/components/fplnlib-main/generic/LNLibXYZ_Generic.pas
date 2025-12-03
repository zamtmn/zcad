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
  Модуль LNLibXYZ_Generic - generic-биндинг для работы с 3D векторами.

  Предоставляет типобезопасный механизм подключения к функциям библиотеки
  LNLib для работы с трёхмерными векторами и координатами.

  Особенности реализации:
  - Использует generic для подстановки пользовательских типов
  - Работает ТОЛЬКО через указатели на функции (не extern)
  - Получает доступ к DLL только через LNLibManager
  - Содержит ABI-проверки при загрузке
  - Поддерживает передачу по указателям для ABI-безопасности

  Дата создания: 2025-12-03
  Зависимости: SysUtils, LNLibManager, LNLibABI
}
unit LNLibXYZ_Generic;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, LNLibManager, LNLibABI;

type
  {**
    Generic-класс биндинга для функций работы с 3D векторами.

    Параметр типа TVec должен быть записью с полями x, y, z типа Double
    и размером 24 байта (3 * Double).

    Пример использования:
    ```pascal
    type
      TXYZ = record
        x, y, z: Double;
      end;

      TLNXYZBind = specialize TLNXYZ<TXYZ>;

    // После загрузки
    if TLNXYZBind.LoadSymbols then
    begin
      var v := TLNXYZBind.xyz_create(1, 2, 3);
      var len := TLNXYZBind.xyz_length(v);
    end;
    ```
  }
  generic TLNXYZ<TVec> = class
  public type
    { Указатель на тип вектора }
    PVec = ^TVec;

    { ====================================================================== }
    {                     Типы функций DLL (передача по значению)             }
    { ====================================================================== }

    { Создание и базовые операции }
    Txyz_create = function(x, y, z: Double): TVec; cdecl;
    Txyz_zero = function: TVec; cdecl;

    { Арифметические операции }
    Txyz_add = function(a, b: TVec): TVec; cdecl;
    Txyz_subtract = function(a, b: TVec): TVec; cdecl;
    Txyz_negative = function(a: TVec): TVec; cdecl;
    Txyz_multiply = function(a: TVec; scalar: Double): TVec; cdecl;
    Txyz_divide = function(a: TVec; scalar: Double): TVec; cdecl;

    { Свойства вектора }
    Txyz_length = function(v: TVec): Double; cdecl;
    Txyz_sqr_length = function(v: TVec): Double; cdecl;
    Txyz_is_zero = function(v: TVec; epsilon: Double): Integer; cdecl;
    Txyz_is_unit = function(v: TVec; epsilon: Double): Integer; cdecl;

    { Нормализация }
    Txyz_normalize = function(v: TVec): TVec; cdecl;

    { Скалярные и векторные операции }
    Txyz_dot = function(a, b: TVec): Double; cdecl;
    Txyz_cross = function(a, b: TVec): TVec; cdecl;
    Txyz_distance = function(a, b: TVec): Double; cdecl;

    { Сравнение }
    Txyz_equals = function(a, b: TVec): Integer; cdecl;

    { ====================================================================== }
    {                  Типы функций DLL (передача по указателям)              }
    { ====================================================================== }
    { Альтернативные безопасные версии для кроссплатформенного использования }

    Txyz_add_p = procedure(const a, b: TVec; out r: TVec); cdecl;
    Txyz_subtract_p = procedure(const a, b: TVec; out r: TVec); cdecl;
    Txyz_negative_p = procedure(const a: TVec; out r: TVec); cdecl;
    Txyz_multiply_p = procedure(const a: TVec; scalar: Double; out r: TVec); cdecl;
    Txyz_divide_p = procedure(const a: TVec; scalar: Double; out r: TVec); cdecl;
    Txyz_normalize_p = procedure(const v: TVec; out r: TVec); cdecl;
    Txyz_cross_p = procedure(const a, b: TVec; out r: TVec); cdecl;

  public class var
    { ====================================================================== }
    {                    Указатели на функции (по значению)                   }
    { ====================================================================== }

    xyz_create: Txyz_create;
    xyz_zero: Txyz_zero;
    xyz_add: Txyz_add;
    xyz_subtract: Txyz_subtract;
    xyz_negative: Txyz_negative;
    xyz_multiply: Txyz_multiply;
    xyz_divide: Txyz_divide;
    xyz_length: Txyz_length;
    xyz_sqr_length: Txyz_sqr_length;
    xyz_is_zero: Txyz_is_zero;
    xyz_is_unit: Txyz_is_unit;
    xyz_normalize: Txyz_normalize;
    xyz_dot: Txyz_dot;
    xyz_cross: Txyz_cross;
    xyz_distance: Txyz_distance;
    xyz_equals: Txyz_equals;

    { ====================================================================== }
    {                  Указатели на функции (по указателям)                   }
    { ====================================================================== }
    { Опционально - могут отсутствовать в библиотеке }

    xyz_add_p: Txyz_add_p;
    xyz_subtract_p: Txyz_subtract_p;
    xyz_negative_p: Txyz_negative_p;
    xyz_multiply_p: Txyz_multiply_p;
    xyz_divide_p: Txyz_divide_p;
    xyz_normalize_p: Txyz_normalize_p;
    xyz_cross_p: Txyz_cross_p;

    { Флаг успешной загрузки всех обязательных символов }
    Loaded: Boolean;

  public
    {**
      Загрузка всех обязательных символов из библиотеки.

      Библиотека должна быть предварительно загружена через LNLibManager.
      Все обязательные функции должны быть найдены для успешной загрузки.

      @return True если все обязательные символы загружены
    }
    class function LoadSymbols: Boolean; static;

    {**
      Выгрузка (обнуление) всех указателей.
    }
    class procedure UnloadSymbols; static;

    {**
      Проверка ABI-совместимости типа TVec.

      @param OffsetX Смещение поля X в байтах (должно быть 0)
      @param OffsetY Смещение поля Y в байтах (должно быть 8)
      @param OffsetZ Смещение поля Z в байтах (должно быть 16)
      @return Результат проверки
    }
    class function ValidateABI(OffsetX, OffsetY, OffsetZ: Integer):
      TABICheckResult; static;
  end;

implementation

{ TLNXYZ }

class function TLNXYZ.LoadSymbols: Boolean;
var
  AllLoaded: Boolean;

  function LoadFunc(const Name: string; out FuncPtr): Boolean;
  var
    P: Pointer;
  begin
    P := LNLib_GetSymbol(PChar(Name));
    Pointer(FuncPtr) := P;
    Result := P <> nil;
  end;

begin
  Result := False;
  Loaded := False;

  { Проверяем, что библиотека загружена }
  if not LNLib_IsLoaded then
    Exit;

  { Загружаем все обязательные функции }
  AllLoaded := True;

  AllLoaded := LoadFunc('xyz_create', xyz_create) and AllLoaded;
  AllLoaded := LoadFunc('xyz_zero', xyz_zero) and AllLoaded;
  AllLoaded := LoadFunc('xyz_add', xyz_add) and AllLoaded;
  AllLoaded := LoadFunc('xyz_subtract', xyz_subtract) and AllLoaded;
  AllLoaded := LoadFunc('xyz_negative', xyz_negative) and AllLoaded;
  AllLoaded := LoadFunc('xyz_multiply', xyz_multiply) and AllLoaded;
  AllLoaded := LoadFunc('xyz_divide', xyz_divide) and AllLoaded;
  AllLoaded := LoadFunc('xyz_length', xyz_length) and AllLoaded;
  AllLoaded := LoadFunc('xyz_sqr_length', xyz_sqr_length) and AllLoaded;
  AllLoaded := LoadFunc('xyz_is_zero', xyz_is_zero) and AllLoaded;
  AllLoaded := LoadFunc('xyz_is_unit', xyz_is_unit) and AllLoaded;
  AllLoaded := LoadFunc('xyz_normalize', xyz_normalize) and AllLoaded;
  AllLoaded := LoadFunc('xyz_dot', xyz_dot) and AllLoaded;
  AllLoaded := LoadFunc('xyz_cross', xyz_cross) and AllLoaded;
  AllLoaded := LoadFunc('xyz_distance', xyz_distance) and AllLoaded;
  AllLoaded := LoadFunc('xyz_equals', xyz_equals) and AllLoaded;

  { Загружаем опциональные функции (передача по указателям) }
  { Эти функции не обязательны - могут отсутствовать в библиотеке }
  LoadFunc('xyz_add_p', xyz_add_p);
  LoadFunc('xyz_subtract_p', xyz_subtract_p);
  LoadFunc('xyz_negative_p', xyz_negative_p);
  LoadFunc('xyz_multiply_p', xyz_multiply_p);
  LoadFunc('xyz_divide_p', xyz_divide_p);
  LoadFunc('xyz_normalize_p', xyz_normalize_p);
  LoadFunc('xyz_cross_p', xyz_cross_p);

  { Частичная загрузка запрещена }
  if not AllLoaded then
  begin
    UnloadSymbols;
    Exit;
  end;

  Loaded := True;
  Result := True;
end;

class procedure TLNXYZ.UnloadSymbols;
begin
  xyz_create := nil;
  xyz_zero := nil;
  xyz_add := nil;
  xyz_subtract := nil;
  xyz_negative := nil;
  xyz_multiply := nil;
  xyz_divide := nil;
  xyz_length := nil;
  xyz_sqr_length := nil;
  xyz_is_zero := nil;
  xyz_is_unit := nil;
  xyz_normalize := nil;
  xyz_dot := nil;
  xyz_cross := nil;
  xyz_distance := nil;
  xyz_equals := nil;

  xyz_add_p := nil;
  xyz_subtract_p := nil;
  xyz_negative_p := nil;
  xyz_multiply_p := nil;
  xyz_divide_p := nil;
  xyz_normalize_p := nil;
  xyz_cross_p := nil;

  Loaded := False;
end;

class function TLNXYZ.ValidateABI(OffsetX, OffsetY, OffsetZ: Integer):
  TABICheckResult;
type
  TChecker = specialize TABICheckerXYZ<TVec>;
begin
  Result := TChecker.Validate(OffsetX, OffsetY, OffsetZ);
end;

end.
