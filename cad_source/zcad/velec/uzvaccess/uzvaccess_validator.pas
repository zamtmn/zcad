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

unit uzvaccess_validator;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, Variants, Math,
  uzvaccess_types, uzvaccess_logger;

type
  {**
    Класс для валидации и преобразования типов данных

    Обеспечивает проверку и конвертацию значений из Variant
    в требуемые типы (integer, float, string) с учётом
    строгого или мягкого режима валидации
  **}
  TTypeValidator = class
  private
    FLogger: TExportLogger;
    FStrictMode: Boolean;
    FAllowNull: Boolean;

    // Проверить, является ли значение пустым/NULL
    function IsNullOrEmpty(const AValue: Variant): Boolean;

    // Валидация строки
    function ValidateString(
      const AValue: Variant;
      out AResult: String
    ): Boolean;

    // Валидация целого числа
    function ValidateInteger(
      const AValue: Variant;
      out AResult: Integer
    ): Boolean;

    // Валидация числа с плавающей точкой
    function ValidateFloat(
      const AValue: Variant;
      out AResult: Double
    ): Boolean;

  public
    constructor Create(
      ALogger: TExportLogger;
      AStrictMode: Boolean;
      AAllowNull: Boolean
    );
    destructor Destroy; override;

    // Валидация и преобразование типа
    function ValidateAndConvert(
      const AValue: Variant;
      ATargetType: TColumnDataType;
      out AResult: Variant
    ): Boolean;

    // Валидация списка значений
    function ValidateArray(
      const AValues: array of Variant;
      const ATypes: array of TColumnDataType;
      out AResults: array of Variant
    ): Boolean;

    property StrictMode: Boolean read FStrictMode write FStrictMode;
    property AllowNull: Boolean read FAllowNull write FAllowNull;
  end;

implementation

{ TTypeValidator }

constructor TTypeValidator.Create(
  ALogger: TExportLogger;
  AStrictMode: Boolean;
  AAllowNull: Boolean
);
begin
  FLogger := ALogger;
  FStrictMode := AStrictMode;
  FAllowNull := AAllowNull;
end;

destructor TTypeValidator.Destroy;
begin
  inherited Destroy;
end;

function TTypeValidator.IsNullOrEmpty(const AValue: Variant): Boolean;
begin
  Result := VarIsNull(AValue) or VarIsEmpty(AValue) or
            (VarToStr(AValue) = '');
end;

function TTypeValidator.ValidateString(
  const AValue: Variant;
  out AResult: String
): Boolean;
begin
  Result := True;

  // Проверка на NULL
  if IsNullOrEmpty(AValue) then
  begin
    if not FAllowNull then
    begin
      FLogger.LogWarning('Пустое значение для строкового поля');
      Result := False;
    end;

    AResult := '';
    Exit;
  end;

  // Преобразование в строку
  try
    AResult := VarToStr(AValue);
  except
    on E: Exception do
    begin
      FLogger.LogError(Format(
        'Ошибка преобразования в строку: %s',
        [E.Message]
      ));
      AResult := '';
      Result := False;
    end;
  end;
end;

function TTypeValidator.ValidateInteger(
  const AValue: Variant;
  out AResult: Integer
): Boolean;
var
  valueStr: String;
  floatValue: Double;
begin
  Result := True;
  AResult := 0;

  // Проверка на NULL
  if IsNullOrEmpty(AValue) then
  begin
    if not FAllowNull then
    begin
      FLogger.LogWarning('Пустое значение для целочисленного поля');
      Result := False;
    end;
    Exit;
  end;

  // Попытка прямого преобразования
  try
    AResult := VarAsType(AValue, varInteger);
    Exit;
  except
    // Ничего не делаем, пробуем другие способы
  end;

  // Попытка преобразования через строку
  valueStr := Trim(VarToStr(AValue));

  try
    // Проверяем, не является ли это числом с плавающей точкой
    if Pos('.', valueStr) > 0 then
    begin
      floatValue := StrToFloat(valueStr);
      AResult := Round(floatValue);

      if not FStrictMode then
      begin
        FLogger.LogWarning(Format(
          'Преобразование float→integer: %s → %d',
          [valueStr, AResult]
        ));
      end
      else
      begin
        FLogger.LogError(Format(
          'Строгий режим: недопустимое преобразование float→integer: %s',
          [valueStr]
        ));
        Result := False;
      end;
    end
    else
    begin
      AResult := StrToInt(valueStr);
    end;

  except
    on E: Exception do
    begin
      FLogger.LogError(Format(
        'Ошибка преобразования в integer: "%s" - %s',
        [valueStr, E.Message]
      ));
      AResult := 0;
      Result := False;
    end;
  end;
end;

function TTypeValidator.ValidateFloat(
  const AValue: Variant;
  out AResult: Double
): Boolean;
var
  valueStr: String;
begin
  Result := True;
  AResult := 0.0;

  // Проверка на NULL
  if IsNullOrEmpty(AValue) then
  begin
    if not FAllowNull then
    begin
      FLogger.LogWarning('Пустое значение для числового поля');
      Result := False;
    end;
    Exit;
  end;

  // Попытка прямого преобразования
  try
    AResult := VarAsType(AValue, varDouble);
    Exit;
  except
    // Ничего не делаем, пробуем другие способы
  end;

  // Попытка преобразования через строку
  valueStr := Trim(VarToStr(AValue));

  try
    AResult := StrToFloat(valueStr);
  except
    on E: Exception do
    begin
      FLogger.LogError(Format(
        'Ошибка преобразования в float: "%s" - %s',
        [valueStr, E.Message]
      ));
      AResult := 0.0;
      Result := False;
    end;
  end;
end;

function TTypeValidator.ValidateAndConvert(
  const AValue: Variant;
  ATargetType: TColumnDataType;
  out AResult: Variant
): Boolean;
var
  strValue: String;
  intValue: Integer;
  floatValue: Double;
begin
  Result := True;
  AResult := Null;

  case ATargetType of
    cdtString:
    begin
      if ValidateString(AValue, strValue) then
        AResult := strValue
      else
        Result := False;
    end;

    cdtInteger:
    begin
      if ValidateInteger(AValue, intValue) then
        AResult := intValue
      else
        Result := False;
    end;

    cdtFloat:
    begin
      if ValidateFloat(AValue, floatValue) then
        AResult := floatValue
      else
        Result := False;
    end;

  else
    FLogger.LogError(Format(
      'Неизвестный тип данных: %d',
      [Ord(ATargetType)]
    ));
    Result := False;
  end;

  if Result then
  begin
    FLogger.LogDebug(Format(
      'Валидация успешна: %s → %s (%s)',
      [VarToStr(AValue), VarToStr(AResult),
       ColumnDataTypeToString(ATargetType)]
    ));
  end;
end;

function TTypeValidator.ValidateArray(
  const AValues: array of Variant;
  const ATypes: array of TColumnDataType;
  out AResults: array of Variant
): Boolean;
var
  i: Integer;
  count: Integer;
begin
  Result := True;

  // Проверяем соответствие размеров массивов
  count := Min(Length(AValues), Min(Length(ATypes), Length(AResults)));

  // Валидируем каждое значение
  for i := 0 to count - 1 do
  begin
    if not ValidateAndConvert(AValues[i], ATypes[i], AResults[i]) then
      Result := False;
  end;
end;

end.
