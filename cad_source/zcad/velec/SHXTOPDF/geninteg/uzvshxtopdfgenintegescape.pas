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

{
  Модуль: uzvshxtopdfgenintegescape
  Назначение: Обработка escape-последовательностей для PDF строк (Этап 7)

  Данный модуль реализует экранирование специальных символов в PDF-строках:
  - \( -> экранированная открывающая скобка
  - \) -> экранированная закрывающая скобка
  - \\ -> экранированный обратный слэш
  - \n, \r, \t -> управляющие символы
  - \xxx -> восьмеричные коды для байтов > 0x7F

  Формат PDF-строк:
    (текст) - литеральная строка
    <hex>   - шестнадцатеричная строка

  Зависимости:
  - uzclog: логирование

  Module: uzvshxtopdfgenintegescape
  Purpose: Escape sequence handling for PDF strings (Stage 7)

  This module implements special character escaping in PDF strings:
  - \( -> escaped opening parenthesis
  - \) -> escaped closing parenthesis
  - \\ -> escaped backslash
  - \n, \r, \t -> control characters
  - \xxx -> octal codes for bytes > 0x7F
}

unit uzvshxtopdfgenintegescape;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzclog;

// Экранировать строку для PDF литеральной строки (...)
// Escape string for PDF literal string (...)
//
// Преобразует специальные символы в escape-последовательности:
//   ( -> \(
//   ) -> \)
//   \ -> \\
//   CR -> \r
//   LF -> \n
//   TAB -> \t
//   байты > 127 -> \xxx (восьмеричный код)
//
// Converts special characters to escape sequences:
//   ( -> \(
//   ) -> \)
//   \ -> \\
//   CR -> \r
//   LF -> \n
//   TAB -> \t
//   bytes > 127 -> \xxx (octal code)
function EscapePdfLiteralString(const Str: AnsiString): AnsiString;

// Преобразовать строку в шестнадцатеричную PDF-строку <...>
// Convert string to hexadecimal PDF string <...>
//
// Каждый байт преобразуется в двухсимвольный hex-код
// Each byte is converted to two-character hex code
function StringToHexPdf(const Str: AnsiString): AnsiString;

// Преобразовать один символ в escape-последовательность
// Convert single character to escape sequence
//
// Возвращает:
//   - Экранированный символ, если требуется экранирование
//   - Исходный символ, если экранирование не нужно
//
// Returns:
//   - Escaped character if escaping is required
//   - Original character if no escaping needed
function EscapePdfChar(Ch: AnsiChar): AnsiString;

// Проверить, требует ли символ экранирования
// Check if character requires escaping
function NeedsEscaping(Ch: AnsiChar): Boolean;

// Проверить, является ли символ печатным ASCII
// Check if character is printable ASCII
function IsPrintableAscii(Ch: AnsiChar): Boolean;

// Преобразовать байт в восьмеричный код \xxx
// Convert byte to octal code \xxx
function ByteToOctalEscape(B: Byte): AnsiString;

// Преобразовать массив байт в PDF-строку с экранированием
// Convert byte array to escaped PDF string
function BytesToEscapedPdfString(const Bytes: array of Byte): AnsiString;

// Преобразовать массив PDF-кодов символов в экранированную строку
// Convert array of PDF character codes to escaped string
function PdfCodesToEscapedString(const Codes: array of Integer): AnsiString;

// Обернуть строку в PDF-скобки с экранированием
// Wrap string in PDF parentheses with escaping
//
// Результат: (экранированный текст)
// Result: (escaped text)
function WrapInPdfParens(const Str: AnsiString): AnsiString;

// Обернуть строку в hex-скобки
// Wrap string in hex brackets
//
// Результат: <hex-строка>
// Result: <hex-string>
function WrapInHexBrackets(const HexStr: AnsiString): AnsiString;

// Включить/выключить логирование escape-операций
// Enable/disable logging of escape operations
procedure SetEscapeLogging(Enable: Boolean);

// Проверить, включено ли логирование
// Check if logging is enabled
function IsEscapeLoggingEnabled: Boolean;

implementation

var
  // Глобальный флаг логирования
  // Global logging flag
  GLoggingEnabled: Boolean = False;

const
  LOG_PREFIX = 'PdfEscape: ';

  // ASCII коды специальных символов
  // ASCII codes of special characters
  CHAR_TAB        = #9;
  CHAR_LF         = #10;
  CHAR_CR         = #13;
  CHAR_BACKSLASH  = '\';
  CHAR_LPAREN     = '(';
  CHAR_RPAREN     = ')';

// Логировать сообщение
procedure Log(const Msg: AnsiString);
begin
  if GLoggingEnabled then
    programlog.LogOutStr(LOG_PREFIX + Msg, LM_Info);
end;

// Включить/выключить логирование escape-операций
procedure SetEscapeLogging(Enable: Boolean);
begin
  GLoggingEnabled := Enable;
end;

// Проверить, включено ли логирование
function IsEscapeLoggingEnabled: Boolean;
begin
  Result := GLoggingEnabled;
end;

// Проверить, является ли символ печатным ASCII
function IsPrintableAscii(Ch: AnsiChar): Boolean;
begin
  // Печатные ASCII: 0x20 (пробел) - 0x7E (~)
  // Printable ASCII: 0x20 (space) - 0x7E (~)
  Result := (Ord(Ch) >= 32) and (Ord(Ch) <= 126);
end;

// Проверить, требует ли символ экранирования
function NeedsEscaping(Ch: AnsiChar): Boolean;
begin
  case Ch of
    CHAR_BACKSLASH,
    CHAR_LPAREN,
    CHAR_RPAREN,
    CHAR_TAB,
    CHAR_LF,
    CHAR_CR:
      Result := True;
  else
    // Непечатные символы и байты > 127 требуют экранирования
    // Non-printable characters and bytes > 127 require escaping
    Result := not IsPrintableAscii(Ch);
  end;
end;

// Преобразовать байт в восьмеричный код \xxx
function ByteToOctalEscape(B: Byte): AnsiString;
begin
  // Формат: \xxx где xxx - три восьмеричные цифры
  // Format: \xxx where xxx is three octal digits
  Result := '\' + Format('%.3o', [B]);
end;

// Преобразовать один символ в escape-последовательность
function EscapePdfChar(Ch: AnsiChar): AnsiString;
begin
  case Ch of
    CHAR_BACKSLASH:
      Result := '\\';
    CHAR_LPAREN:
      Result := '\(';
    CHAR_RPAREN:
      Result := '\)';
    CHAR_TAB:
      Result := '\t';
    CHAR_LF:
      Result := '\n';
    CHAR_CR:
      Result := '\r';
  else
    begin
      if IsPrintableAscii(Ch) then
        // Печатный символ - без изменений
        // Printable character - no change
        Result := Ch
      else
        // Непечатный или > 127 - восьмеричный код
        // Non-printable or > 127 - octal code
        Result := ByteToOctalEscape(Ord(Ch));
    end;
  end;
end;

// Экранировать строку для PDF литеральной строки
function EscapePdfLiteralString(const Str: AnsiString): AnsiString;
var
  I: Integer;
  Ch: AnsiChar;
  EscapedCount: Integer;
begin
  Result := '';
  EscapedCount := 0;

  for I := 1 to Length(Str) do
  begin
    Ch := Str[I];

    if NeedsEscaping(Ch) then
      Inc(EscapedCount);

    Result := Result + EscapePdfChar(Ch);
  end;

  Log(Format('экранирование: длина=%d, экранировано=%d символов',
    [Length(Str), EscapedCount]));
end;

// Преобразовать строку в шестнадцатеричную PDF-строку
function StringToHexPdf(const Str: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to Length(Str) do
    Result := Result + IntToHex(Ord(Str[I]), 2);

  Log(Format('конвертация в hex: длина=%d, hex-длина=%d',
    [Length(Str), Length(Result)]));
end;

// Преобразовать массив байт в PDF-строку с экранированием
function BytesToEscapedPdfString(const Bytes: array of Byte): AnsiString;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to High(Bytes) do
    Result := Result + EscapePdfChar(AnsiChar(Bytes[I]));

  Log(Format('байты -> строка: %d байт', [Length(Bytes)]));
end;

// Преобразовать массив PDF-кодов символов в экранированную строку
function PdfCodesToEscapedString(const Codes: array of Integer): AnsiString;
var
  I: Integer;
  Code: Integer;
begin
  Result := '';

  for I := 0 to High(Codes) do
  begin
    Code := Codes[I];

    // Проверка диапазона кода
    // Code range check
    if (Code < 0) or (Code > 255) then
    begin
      Log(Format('предупреждение: код %d вне диапазона [0..255], пропущен',
        [Code]));
      Continue;
    end;

    Result := Result + EscapePdfChar(AnsiChar(Code));
  end;

  Log(Format('коды -> строка: %d кодов', [Length(Codes)]));
end;

// Обернуть строку в PDF-скобки с экранированием
function WrapInPdfParens(const Str: AnsiString): AnsiString;
begin
  Result := '(' + EscapePdfLiteralString(Str) + ')';
end;

// Обернуть строку в hex-скобки
function WrapInHexBrackets(const HexStr: AnsiString): AnsiString;
begin
  Result := '<' + HexStr + '>';
end;

end.
