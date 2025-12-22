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

unit uzvshxtopdf_shxutils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math;

// Константы для работы с SHX файлами
const
  // Магическое число в заголовке SHX файла
  SHX_MAGIC_HEADER = 'AutoCAD-86 shapes 1.0';

  // Размер заголовка SHX файла (в байтах)
  SHX_HEADER_SIZE = 26;

  // Максимальная длина имени шрифта
  MAX_FONT_NAME_LENGTH = 255;

// Нормализовать угол в диапазон [0, 2*Pi)
function NormalizeAngle(Angle: Double): Double;

// Вычислить расстояние между двумя точками
function CalculateDistance(X1, Y1, X2, Y2: Double): Double;

// Проверить, является ли значение NaN или Infinity
function IsInvalidFloat(Value: Double): Boolean;

// Безопасное чтение байта из потока
function SafeReadByte(var F: File; out Value: Byte): Boolean;

// Безопасное чтение слова (Word) из потока
function SafeReadWord(var F: File; out Value: Word): Boolean;

// Безопасное чтение двойного слова (DWord) из потока
function SafeReadDWord(var F: File; out Value: LongWord): Boolean;

// Безопасное чтение строки с заданной длиной
function SafeReadString(var F: File; Len: Integer): string;

// Преобразовать код символа с учетом кодовой страницы
function ConvertCharCode(Code: Byte; CodePage: Integer): Byte;

// Получить имя символа по коду (для отладки)
function GetCharName(Code: Byte): string;

// Масштабировать значение с учетом UnitsPerEm
function ScaleValue(Value: Double; UnitsPerEm: Double): Double;

implementation

// Нормализовать угол в диапазон [0, 2*Pi)
function NormalizeAngle(Angle: Double): Double;
begin
  Result := Angle;

  // Приводим угол к диапазону [0, 2*Pi)
  while Result < 0 do
    Result := Result + 2 * Pi;

  while Result >= 2 * Pi do
    Result := Result - 2 * Pi;
end;

// Вычислить расстояние между двумя точками
function CalculateDistance(X1, Y1, X2, Y2: Double): Double;
var
  DX, DY: Double;
begin
  DX := X2 - X1;
  DY := Y2 - Y1;
  Result := Sqrt(DX * DX + DY * DY);
end;

// Проверить, является ли значение NaN или Infinity
function IsInvalidFloat(Value: Double): Boolean;
begin
  Result := IsNaN(Value) or IsInfinite(Value);
end;

// Безопасное чтение байта из потока
function SafeReadByte(var F: File; out Value: Byte): Boolean;
var
  BytesRead: Integer;
begin
  BlockRead(F, Value, SizeOf(Byte), BytesRead);
  Result := (BytesRead = SizeOf(Byte));
end;

// Безопасное чтение слова (Word) из потока
function SafeReadWord(var F: File; out Value: Word): Boolean;
var
  BytesRead: Integer;
begin
  BlockRead(F, Value, SizeOf(Word), BytesRead);
  Result := (BytesRead = SizeOf(Word));
end;

// Безопасное чтение двойного слова (DWord) из потока
function SafeReadDWord(var F: File; out Value: LongWord): Boolean;
var
  BytesRead: Integer;
begin
  BlockRead(F, Value, SizeOf(LongWord), BytesRead);
  Result := (BytesRead = SizeOf(LongWord));
end;

// Безопасное чтение строки с заданной длиной
function SafeReadString(var F: File; Len: Integer): string;
var
  Buffer: array of Char;
  BytesRead: Integer;
  i: Integer;
begin
  Result := '';

  if Len <= 0 then
    Exit;

  SetLength(Buffer, Len);
  BlockRead(F, Buffer[0], Len, BytesRead);

  if BytesRead <> Len then
    Exit;

  // Преобразуем массив символов в строку, останавливаясь на нулевом символе
  for i := 0 to Len - 1 do
  begin
    if Buffer[i] = #0 then
      Break;
    Result := Result + Buffer[i];
  end;
end;

// Преобразовать код символа с учетом кодовой страницы
// Примечание: базовая реализация, может требовать расширения для других кодовых страниц
function ConvertCharCode(Code: Byte; CodePage: Integer): Byte;
begin
  // На данном этапе просто возвращаем исходный код
  // В будущем здесь может быть реализована таблица перекодировки
  Result := Code;
end;

// Получить имя символа по коду (для отладки)
function GetCharName(Code: Byte): string;
begin
  // Для ASCII символов возвращаем сам символ
  if (Code >= 32) and (Code <= 126) then
    Result := Chr(Code)
  // Для управляющих символов возвращаем hex-код
  else
    Result := Format('#$%2.2X', [Code]);
end;

// Масштабировать значение с учетом UnitsPerEm
function ScaleValue(Value: Double; UnitsPerEm: Double): Double;
begin
  if UnitsPerEm = 0.0 then
    Result := Value
  else
    Result := Value / UnitsPerEm;
end;

end.
