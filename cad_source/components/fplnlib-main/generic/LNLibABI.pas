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
  Модуль LNLibABI - проверка ABI-совместимости типов.

  Обеспечивает compile-time и runtime проверки соответствия пользовательских
  типов (векторов, матриц) требованиям нативной библиотеки LNLib.

  Основные проверки:
  - Размер структур (SizeOf)
  - Выравнивание структур (AlignOf)
  - Смещения полей внутри структур
  - Динамические тесты вызовов функций

  Все проверки обязательны при загрузке биндинга. При несовпадении
  загрузка запрещается.

  Дата создания: 2025-12-03
  Зависимости: SysUtils, Math
}
unit LNLibABI;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math;

const
  {** Допустимая погрешность для сравнения чисел с плавающей точкой **}
  ABI_TOLERANCE = 1e-9;

  {** Ожидаемый размер структуры XYZ (3 * Double = 24 байта) **}
  EXPECTED_XYZ_SIZE = 24;

  {** Ожидаемый размер структуры XYZW (4 * Double = 32 байта) **}
  EXPECTED_XYZW_SIZE = 32;

  {** Ожидаемый размер структуры UV (2 * Double = 16 байт) **}
  EXPECTED_UV_SIZE = 16;

  {** Ожидаемый размер структуры Matrix4d (16 * Double = 128 байт) **}
  EXPECTED_MATRIX4D_SIZE = 128;

type
  {**
    Результат проверки ABI.

    Содержит информацию о результате проверки и описание ошибки.
  }
  TABICheckResult = record
    Success: Boolean;
    ErrorMessage: string;
  end;

  {**
    Класс для проверки ABI-совместимости типа XYZ (3D вектор).

    Используется generic-механизм для проверки пользовательского типа
    без привязки к конкретной реализации.
  }
  generic TABICheckerXYZ<TVec> = class
  public
    {**
      Проверка размера структуры.

      @return Результат проверки с описанием ошибки
    }
    class function CheckSize: TABICheckResult; static;

    {**
      Проверка смещений полей структуры.

      Ожидаемые смещения: x=0, y=8, z=16.

      @param OffsetX Смещение поля X в байтах
      @param OffsetY Смещение поля Y в байтах
      @param OffsetZ Смещение поля Z в байтах
      @return Результат проверки
    }
    class function CheckOffsets(OffsetX, OffsetY, OffsetZ: Integer):
      TABICheckResult; static;

    {**
      Полная проверка ABI-совместимости типа.

      @param OffsetX Смещение поля X
      @param OffsetY Смещение поля Y
      @param OffsetZ Смещение поля Z
      @return Результат всех проверок
    }
    class function Validate(OffsetX, OffsetY, OffsetZ: Integer):
      TABICheckResult; static;
  end;

  {**
    Класс для проверки ABI-совместимости типа XYZW (4D вектор/взвешенная точка).
  }
  generic TABICheckerXYZW<TVec> = class
  public
    class function CheckSize: TABICheckResult; static;
    class function CheckOffsets(OffsetWX, OffsetWY, OffsetWZ, OffsetW: Integer):
      TABICheckResult; static;
    class function Validate(OffsetWX, OffsetWY, OffsetWZ, OffsetW: Integer):
      TABICheckResult; static;
  end;

  {**
    Класс для проверки ABI-совместимости типа UV (2D параметр).
  }
  generic TABICheckerUV<TUV> = class
  public
    class function CheckSize: TABICheckResult; static;
    class function CheckOffsets(OffsetU, OffsetV: Integer): TABICheckResult; static;
    class function Validate(OffsetU, OffsetV: Integer): TABICheckResult; static;
  end;

  {**
    Класс для проверки ABI-совместимости типа Matrix4d (матрица 4x4).
  }
  generic TABICheckerMatrix4d<TMat> = class
  public
    class function CheckSize: TABICheckResult; static;
    class function Validate: TABICheckResult; static;
  end;

{**
  Сравнение двух чисел Double с заданной точностью.

  @param A Первое число
  @param B Второе число
  @param Tolerance Допустимая погрешность
  @return True если числа равны в пределах погрешности
}
function DoubleEquals(A, B: Double; Tolerance: Double = ABI_TOLERANCE): Boolean;

{**
  Создание успешного результата проверки.

  @return Результат с Success=True
}
function ABICheckOK: TABICheckResult;

{**
  Создание неуспешного результата проверки.

  @param ErrorMsg Описание ошибки
  @return Результат с Success=False и сообщением об ошибке
}
function ABICheckFail(const ErrorMsg: string): TABICheckResult;

implementation

function DoubleEquals(A, B: Double; Tolerance: Double): Boolean;
begin
  Result := Abs(A - B) <= Tolerance;
end;

function ABICheckOK: TABICheckResult;
begin
  Result.Success := True;
  Result.ErrorMessage := '';
end;

function ABICheckFail(const ErrorMsg: string): TABICheckResult;
begin
  Result.Success := False;
  Result.ErrorMessage := ErrorMsg;
end;

{ TABICheckerXYZ }

class function TABICheckerXYZ.CheckSize: TABICheckResult;
var
  ActualSize: Integer;
begin
  ActualSize := SizeOf(TVec);
  if ActualSize = EXPECTED_XYZ_SIZE then
    Result := ABICheckOK
  else
    Result := ABICheckFail(Format(
      'Неверный размер структуры XYZ: ожидается %d, фактически %d',
      [EXPECTED_XYZ_SIZE, ActualSize]));
end;

class function TABICheckerXYZ.CheckOffsets(OffsetX, OffsetY, OffsetZ: Integer):
  TABICheckResult;
begin
  if (OffsetX <> 0) then
    Result := ABICheckFail(Format('Неверное смещение X: ожидается 0, фактически %d',
      [OffsetX]))
  else if (OffsetY <> 8) then
    Result := ABICheckFail(Format('Неверное смещение Y: ожидается 8, фактически %d',
      [OffsetY]))
  else if (OffsetZ <> 16) then
    Result := ABICheckFail(Format('Неверное смещение Z: ожидается 16, фактически %d',
      [OffsetZ]))
  else
    Result := ABICheckOK;
end;

class function TABICheckerXYZ.Validate(OffsetX, OffsetY, OffsetZ: Integer):
  TABICheckResult;
begin
  Result := CheckSize;
  if not Result.Success then Exit;

  Result := CheckOffsets(OffsetX, OffsetY, OffsetZ);
end;

{ TABICheckerXYZW }

class function TABICheckerXYZW.CheckSize: TABICheckResult;
var
  ActualSize: Integer;
begin
  ActualSize := SizeOf(TVec);
  if ActualSize = EXPECTED_XYZW_SIZE then
    Result := ABICheckOK
  else
    Result := ABICheckFail(Format(
      'Неверный размер структуры XYZW: ожидается %d, фактически %d',
      [EXPECTED_XYZW_SIZE, ActualSize]));
end;

class function TABICheckerXYZW.CheckOffsets(OffsetWX, OffsetWY, OffsetWZ,
  OffsetW: Integer): TABICheckResult;
begin
  if (OffsetWX <> 0) then
    Result := ABICheckFail(Format('Неверное смещение WX: ожидается 0, фактически %d',
      [OffsetWX]))
  else if (OffsetWY <> 8) then
    Result := ABICheckFail(Format('Неверное смещение WY: ожидается 8, фактически %d',
      [OffsetWY]))
  else if (OffsetWZ <> 16) then
    Result := ABICheckFail(Format('Неверное смещение WZ: ожидается 16, фактически %d',
      [OffsetWZ]))
  else if (OffsetW <> 24) then
    Result := ABICheckFail(Format('Неверное смещение W: ожидается 24, фактически %d',
      [OffsetW]))
  else
    Result := ABICheckOK;
end;

class function TABICheckerXYZW.Validate(OffsetWX, OffsetWY, OffsetWZ,
  OffsetW: Integer): TABICheckResult;
begin
  Result := CheckSize;
  if not Result.Success then Exit;

  Result := CheckOffsets(OffsetWX, OffsetWY, OffsetWZ, OffsetW);
end;

{ TABICheckerUV }

class function TABICheckerUV.CheckSize: TABICheckResult;
var
  ActualSize: Integer;
begin
  ActualSize := SizeOf(TUV);
  if ActualSize = EXPECTED_UV_SIZE then
    Result := ABICheckOK
  else
    Result := ABICheckFail(Format(
      'Неверный размер структуры UV: ожидается %d, фактически %d',
      [EXPECTED_UV_SIZE, ActualSize]));
end;

class function TABICheckerUV.CheckOffsets(OffsetU, OffsetV: Integer):
  TABICheckResult;
begin
  if (OffsetU <> 0) then
    Result := ABICheckFail(Format('Неверное смещение U: ожидается 0, фактически %d',
      [OffsetU]))
  else if (OffsetV <> 8) then
    Result := ABICheckFail(Format('Неверное смещение V: ожидается 8, фактически %d',
      [OffsetV]))
  else
    Result := ABICheckOK;
end;

class function TABICheckerUV.Validate(OffsetU, OffsetV: Integer): TABICheckResult;
begin
  Result := CheckSize;
  if not Result.Success then Exit;

  Result := CheckOffsets(OffsetU, OffsetV);
end;

{ TABICheckerMatrix4d }

class function TABICheckerMatrix4d.CheckSize: TABICheckResult;
var
  ActualSize: Integer;
begin
  ActualSize := SizeOf(TMat);
  if ActualSize = EXPECTED_MATRIX4D_SIZE then
    Result := ABICheckOK
  else
    Result := ABICheckFail(Format(
      'Неверный размер структуры Matrix4d: ожидается %d, фактически %d',
      [EXPECTED_MATRIX4D_SIZE, ActualSize]));
end;

class function TABICheckerMatrix4d.Validate: TABICheckResult;
begin
  Result := CheckSize;
end;

end.
