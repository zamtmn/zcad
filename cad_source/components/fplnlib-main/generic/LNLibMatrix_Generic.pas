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
  Модуль LNLibMatrix_Generic - generic-биндинг для работы с матрицами 4x4.

  Предоставляет типобезопасный механизм подключения к функциям библиотеки
  LNLib для работы с матрицами преобразования 4x4.

  Особенности реализации:
  - Использует generic для подстановки пользовательских типов матриц и векторов
  - Работает ТОЛЬКО через указатели на функции (не extern)
  - Получает доступ к DLL только через LNLibManager
  - Содержит ABI-проверки при загрузке
  - Поддерживает передачу по указателям для ABI-безопасности

  Дата создания: 2025-12-03
  Зависимости: SysUtils, LNLibManager, LNLibABI
}
unit LNLibMatrix_Generic;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, LNLibManager, LNLibABI;

type
  {**
    Generic-класс биндинга для функций работы с матрицами 4x4.

    Параметры типов:
    - TMat: запись с массивом m[0..15] типа Double (128 байт)
    - TVec: запись с полями x, y, z типа Double (24 байта)

    Пример использования:
    ```pascal
    type
      TMatrix4d = record
        m: array[0..15] of Double;
      end;
      TXYZ = record
        x, y, z: Double;
      end;

      TLNMatrixBind = specialize TLNMatrix<TMatrix4d, TXYZ>;

    // После загрузки
    if TLNMatrixBind.LoadSymbols then
    begin
      var mat := TLNMatrixBind.matrix4d_identity;
      var translate := TLNMatrixBind.matrix4d_create_translation(v);
    end;
    ```
  }
  generic TLNMatrix<TMat, TVec> = class
  public type
    { Указатели на типы }
    PMat = ^TMat;
    PVec = ^TVec;

    { ====================================================================== }
    {                         Типы функций DLL                                }
    { ====================================================================== }

    { Создание матриц }
    Tmatrix4d_identity = function: TMat; cdecl;
    Tmatrix4d_create_translation = function(vector: TVec): TMat; cdecl;
    Tmatrix4d_create_rotation = function(axis: TVec; rad: Double): TMat; cdecl;
    Tmatrix4d_create_scale = function(scale: TVec): TMat; cdecl;
    Tmatrix4d_create_reflection = function(normal: TVec): TMat; cdecl;

    { Получение базисных векторов }
    Tmatrix4d_get_basis_x = function(matrix: TMat): TVec; cdecl;
    Tmatrix4d_get_basis_y = function(matrix: TMat): TVec; cdecl;
    Tmatrix4d_get_basis_z = function(matrix: TMat): TVec; cdecl;
    Tmatrix4d_get_basis_w = function(matrix: TMat): TVec; cdecl;

    { Применение преобразований }
    Tmatrix4d_of_point = function(matrix: TMat; point: TVec): TVec; cdecl;
    Tmatrix4d_of_vector = function(matrix: TMat; vector: TVec): TVec; cdecl;

    { Операции с матрицами }
    Tmatrix4d_multiply = function(a, b: TMat): TMat; cdecl;
    Tmatrix4d_get_inverse = function(matrix: TMat; out_inverse: PMat): Integer; cdecl;
    Tmatrix4d_get_determinant = function(matrix: TMat): Double; cdecl;

    { ====================================================================== }
    {              Типы функций DLL (передача по указателям)                  }
    { ====================================================================== }
    { Альтернативные безопасные версии для кроссплатформенного использования }

    Tmatrix4d_identity_p = procedure(out r: TMat); cdecl;
    Tmatrix4d_create_translation_p = procedure(const vector: TVec;
      out r: TMat); cdecl;
    Tmatrix4d_create_rotation_p = procedure(const axis: TVec; rad: Double;
      out r: TMat); cdecl;
    Tmatrix4d_create_scale_p = procedure(const scale: TVec; out r: TMat); cdecl;
    Tmatrix4d_create_reflection_p = procedure(const normal: TVec;
      out r: TMat); cdecl;
    Tmatrix4d_multiply_p = procedure(const a, b: TMat; out r: TMat); cdecl;
    Tmatrix4d_of_point_p = procedure(const matrix: TMat; const point: TVec;
      out r: TVec); cdecl;
    Tmatrix4d_of_vector_p = procedure(const matrix: TMat; const vector: TVec;
      out r: TVec); cdecl;

  public class var
    { ====================================================================== }
    {                    Указатели на функции (по значению)                   }
    { ====================================================================== }

    matrix4d_identity: Tmatrix4d_identity;
    matrix4d_create_translation: Tmatrix4d_create_translation;
    matrix4d_create_rotation: Tmatrix4d_create_rotation;
    matrix4d_create_scale: Tmatrix4d_create_scale;
    matrix4d_create_reflection: Tmatrix4d_create_reflection;
    matrix4d_get_basis_x: Tmatrix4d_get_basis_x;
    matrix4d_get_basis_y: Tmatrix4d_get_basis_y;
    matrix4d_get_basis_z: Tmatrix4d_get_basis_z;
    matrix4d_get_basis_w: Tmatrix4d_get_basis_w;
    matrix4d_of_point: Tmatrix4d_of_point;
    matrix4d_of_vector: Tmatrix4d_of_vector;
    matrix4d_multiply: Tmatrix4d_multiply;
    matrix4d_get_inverse: Tmatrix4d_get_inverse;
    matrix4d_get_determinant: Tmatrix4d_get_determinant;

    { ====================================================================== }
    {                  Указатели на функции (по указателям)                   }
    { ====================================================================== }
    { Опционально - могут отсутствовать в библиотеке }

    matrix4d_identity_p: Tmatrix4d_identity_p;
    matrix4d_create_translation_p: Tmatrix4d_create_translation_p;
    matrix4d_create_rotation_p: Tmatrix4d_create_rotation_p;
    matrix4d_create_scale_p: Tmatrix4d_create_scale_p;
    matrix4d_create_reflection_p: Tmatrix4d_create_reflection_p;
    matrix4d_multiply_p: Tmatrix4d_multiply_p;
    matrix4d_of_point_p: Tmatrix4d_of_point_p;
    matrix4d_of_vector_p: Tmatrix4d_of_vector_p;

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
      Проверка ABI-совместимости типа TMat.

      @return Результат проверки
    }
    class function ValidateABI: TABICheckResult; static;
  end;

implementation

{ TLNMatrix }

class function TLNMatrix.LoadSymbols: Boolean;
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

  AllLoaded := LoadFunc('matrix4d_identity', matrix4d_identity) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_create_translation',
    matrix4d_create_translation) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_create_rotation',
    matrix4d_create_rotation) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_create_scale',
    matrix4d_create_scale) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_create_reflection',
    matrix4d_create_reflection) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_get_basis_x',
    matrix4d_get_basis_x) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_get_basis_y',
    matrix4d_get_basis_y) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_get_basis_z',
    matrix4d_get_basis_z) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_get_basis_w',
    matrix4d_get_basis_w) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_of_point', matrix4d_of_point) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_of_vector', matrix4d_of_vector) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_multiply', matrix4d_multiply) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_get_inverse',
    matrix4d_get_inverse) and AllLoaded;
  AllLoaded := LoadFunc('matrix4d_get_determinant',
    matrix4d_get_determinant) and AllLoaded;

  { Загружаем опциональные функции (передача по указателям) }
  LoadFunc('matrix4d_identity_p', matrix4d_identity_p);
  LoadFunc('matrix4d_create_translation_p', matrix4d_create_translation_p);
  LoadFunc('matrix4d_create_rotation_p', matrix4d_create_rotation_p);
  LoadFunc('matrix4d_create_scale_p', matrix4d_create_scale_p);
  LoadFunc('matrix4d_create_reflection_p', matrix4d_create_reflection_p);
  LoadFunc('matrix4d_multiply_p', matrix4d_multiply_p);
  LoadFunc('matrix4d_of_point_p', matrix4d_of_point_p);
  LoadFunc('matrix4d_of_vector_p', matrix4d_of_vector_p);

  { Частичная загрузка запрещена }
  if not AllLoaded then
  begin
    UnloadSymbols;
    Exit;
  end;

  Loaded := True;
  Result := True;
end;

class procedure TLNMatrix.UnloadSymbols;
begin
  matrix4d_identity := nil;
  matrix4d_create_translation := nil;
  matrix4d_create_rotation := nil;
  matrix4d_create_scale := nil;
  matrix4d_create_reflection := nil;
  matrix4d_get_basis_x := nil;
  matrix4d_get_basis_y := nil;
  matrix4d_get_basis_z := nil;
  matrix4d_get_basis_w := nil;
  matrix4d_of_point := nil;
  matrix4d_of_vector := nil;
  matrix4d_multiply := nil;
  matrix4d_get_inverse := nil;
  matrix4d_get_determinant := nil;

  matrix4d_identity_p := nil;
  matrix4d_create_translation_p := nil;
  matrix4d_create_rotation_p := nil;
  matrix4d_create_scale_p := nil;
  matrix4d_create_reflection_p := nil;
  matrix4d_multiply_p := nil;
  matrix4d_of_point_p := nil;
  matrix4d_of_vector_p := nil;

  Loaded := False;
end;

class function TLNMatrix.ValidateABI: TABICheckResult;
type
  TChecker = specialize TABICheckerMatrix4d<TMat>;
begin
  Result := TChecker.Validate;
end;

end.
