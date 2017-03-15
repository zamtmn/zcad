{ Version 050130. Copyright © Alexey A.Chernobaev, 1996-2004 }

{ Some functions of this unit are based on RX Library (unit StrUtils)
  Copyright (c) 1995, 1996 AO ROSNO; Copyright (c) 1997, 1998 Master-Bank;
  StrUtils is based on AlexGraf String Library by Alexei Lukin (c) 1992 }

unit VFormat;

interface

{$I VCheck.inc}
{$IFDEF V_D3}{$WRITEABLECONST ON}{$ENDIF}

uses
  SysUtils, ExtType, ExtSys, VectStr, VectErr;

const
  DefaultRealFormat = '%g';

  Y2KLimit = 80;

type
  TFormat = (WindowsLong, WindowsShort, RussianLong, RussianShort,
    EnglishLong, EnglishShort, Simple, RFC822);
{
  Для даты константы данного перечислимого типа означают соответственно:
  WindowsLong: длинный Windows-формат;
  WindowsShort: короткий Windows-формат;
  RussianLong: '<день> <название месяца по-русски> <год>' (Windows 1251);
  RussianShort: dd.mm.yyyy;
  EnglishLong: '<название месяца по-английски> <день>, <год>';
  EnglishShort: mm/dd/yyyy;
  Simple: yyyymmdd;

  Для времени:
  WindowsLong: Windows-формат с секундами;
  WindowsShort: Windows-формат без секунд;
  RussianLong: hh:mm:ss;
  RussianShort: hh:mm;
  EnglishLong: hh:mm:ss AM|PM', где hh <= 12;
  EnglishShort: 'hh:mm AM|PM', где hh <= 12;
  Simple: hhmm.

  Для даты и времени:
  RFC822: '<краткое название дня недели по-английски>, <день> ' +
    <краткое название месяца по-английски> <год> hh:mm:ss' (без часового пояса!)

  Для логических значений: Yes/No, Y/N, Да/Нет, Д/Н, True/False, T/F, 1/0.

  For dates constants of this enumarated type stand for:
  long Windows-format,
  short Windows-format,
  '<day> <russian name of month> <year>',
  dd.mm.yyyy,
  '<english name of month> <day>, <year>',
  mm/dd/yyyy,
  yyyymmdd.

  For time:
  Windows-format with seconds,
  Windows-format without seconds,
  hh:mm:ss,
  hh:mm,
  'hh:mm:ss AM|PM', where hh <= 12,
  'hh:mm AM|PM', where hh <= 12,
  hhmm.

  For date and time:
  RFC822: '<short english name of day of week>, <day> ' +
    <short english name of month> <year> hh:mm:ss' (without time zone!)'

  For boolean values: Yes/No, Y/N, Да/Нет, Д/Н, True/False, T/F, 1/0.
}

function StdStrToInt(const Value: String): Integer;
function StdStrToInt64(const Value: String): Int64;
{ преобразует строку в целое число; Value может содержать запись числа в
  десятичном или шестнадцатеричном формате (в последнем случае строка должна
  начинаться с '$' или '0x' либо оканчиваться символом 'h') }
{ converts string to integer; Value can be in decimal or hexadecimal formats
  (in latter case the string either begins from '$' or '0x' or ends with 'h') }

function StringToReal(Value: String): Extended;
{ преобразует строку в вещественное число; в качестве разделителя целой и
  дробной части допускаются '.', ',' и системный разделитель DecimalSeparator }
{ converts string to floating-point number; it's possible to use '.', ',' and
  system-defined DecimalSeparator for delimiting integral and fractional parts }

function RealToString(Value: Extended;
  const RealFormat: String{$IFDEF V_D4} = DefaultRealFormat{$ENDIF}): String;
{ преобразует вещественное число в строку, используя RealFormat; в качестве
  разделителя целой и дробной части используется '.' }
{ converts floating-point number to string using RealFormat and '.' as the
  decimal separator }

function RealToStringF(Value: Extended; Precision, Digits_: Integer;
  const RealFormat: String{$IFDEF V_D4} = DefaultRealFormat{$ENDIF}): String;
{ преобразует вещественное число в строку, используя ffGeneral и заданные
  параметры; в качестве разделителя целой и дробной части используется '.' }
{ converts floating-point number to string using ffGeneral and '.' as the
  decimal separator }

{$IFNDEF NO_DATETIME}
function StdDateToStr(ADate: TDateTime;
  DateFormat: TFormat{$IFDEF V_D4} = RussianShort{$ENDIF}): String;
{ преобразует дату в строку, используя формат DateFormat; если год не задан,
  то принимается текущий год }
{ converts date to string using DateFormat; if year isn't specified then current
  year is used }

function StdStrToDate(const Value: String): TDateTime;
{ преобразует строку, находящуюся в любом из форматов TFormat, в дату }
{ converts string which can be in every of formats TFormat to date }

function StdTimeToStr(ATime: TDateTime;
  TimeFormat: TFormat{$IFDEF V_D4} = RussianShort{$ENDIF}): String;
{ преобразует время в строку, используя формат TimeFormat }
{ converts time to string using TimeFormat format }

function StdStrToTime(Value: String): TDateTime;
{ преобразует строку, находящуюся в любом из форматов TTimeFormat, во время }
{ converts string which can be in every of formats TTimeFormat to time }

function StdDateTimeToStr(ADate: TDateTime;
  Format: TFormat{$IFDEF V_D4} = RussianShort{$ENDIF}): String;
{ преобразует дату-время в строку, используя форматы DateFormat и TimeFormat }
{ converts date-time to string using formats DateFormat and TimeFormat }

function StdStrToDateTime(Value: String): TDateTime;
{ преобразует строку, находящуюся в любом из форматов TFormat, в дату-время }
{ converts string which can be in every of formats TFormat to date-time }
{$ENDIF}

function CharToStr(C: Char): String;
{ переводит символ в строку; если C < #32, то Result:='#' + IntToStr(Ord(C)) }
{ converts character to string; if C < #32 then Result:='#' + IntToStr(Ord(C)) }

function StrToChar(const Value: String): Char;
{ функция, обратная к CharToStr }
{ function inverse to CharToStr }

function BoolToStr(B: Boolean; BoolFormat: TFormat{$IFDEF V_D4} = WindowsShort{$ENDIF}): String;
{ переводит логическое значение в строку }
{ converts boolean to string }

function StrToBool(Value: String): Boolean;
{ функция, обратная к BoolToStr }
{ function inverse to BoolToStr }

function StandardFormat(const FormatStr: String; const Args: array of const): String;
{ аналогична функции Format, но всегда использует '.' как разделитель целой
  и дробной части вещественных чисел }
{ analog of Format function which always uses '.' as the decimal separator }

implementation

function PrepareInt(const Value: String): String;
begin
  Result:=Trim(Value);
  if Result <> '' then begin
    if UpCase(Result[Length(Result)]) = 'H' then
      Result:='$' + Copy(Result, 1, Length(Result) - 1)
    else if Pos('0X', UpperCase(Result)) = 1 then
      Result:='$' + Copy(Result, 3, Length(Result));
  end;
end;

function StdStrToInt(const Value: String): Integer;
begin
  try
    Result:=StrToInt(PrepareInt(Value));
  except
    raise Exception.CreateFmt(SCanNotConvertToInteger_s, [Value]);
  end;
end;

{$IFDEF V_D4}
function StdStrToInt64(const Value: String): Int64;
begin
  try
    Result:=StrToInt64(PrepareInt(Value));
  except
    raise Exception.CreateFmt(SCanNotConvertToInteger_s, [Value]);
  end;
end;
{$ELSE}
function StdStrToInt64(const Value: String): Int64;
var
  I, L: Integer;
  S: String;
  Hex: Boolean;
  F: Float64;
begin
  S:=Trim(Value);
  L:=Length(S);
  try
    if L = 0 then
      Abort;
    Hex:=False;
    if UpCase(S[L]) = 'H' then begin
      Dec(L);
      SetLength(S, L);
      Hex:=True;
    end
    else if S[1] = '$' then begin
      Dec(L);
      Delete(S, 1, 1);
      Hex:=True;
    end;
    if Hex then begin
      if L = 0 then
        Abort;
      I:=L - 7;
      if I < 1 then
        I:=1;
      QWordRec(Result).Lo:=StrToInt('$' + Copy(S, I, 8));
      S:=Copy(S, 1, I - 1);
      if S <> '' then
        QWordRec(Result).Hi:=StrToInt('$' + S)
      else
        QWordRec(Result).Hi:=0;
    end
    else begin
      F:=StringToReal(S);
      if Frac(F) <> 0 then
        Abort;
      Result:={$IFNDEF INT64_EQ_COMP}Round{$ENDIF}(F);
    end;
  except
    raise Exception.CreateFmt(SCanNotConvertToInteger_s, [Value]);
  end;
end;
{$ENDIF}

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function StringToReal(Value: String): Extended;
var
  I: Integer;
begin
  Value:=Trim(Value);
  {$IFDEF V_DELPHI}
  if CharPos(DecimalSeparator, Value, 1) = 0 then begin
    I:=CharPos('.', Value, 1);
    if I > 0 then
      Value[I]:=DecimalSeparator
    else begin
      I:=CharPos(',', Value, 1);
      if I > 0 then
        Value[I]:=DecimalSeparator
    end;
  end;
  try
    Result:=StrToFloat(Value);
  except
    raise Exception.CreateFmt(SCanNotConvertToFloat_s, [Value]);
  end;
  {$ELSE}
  I:=CharPos(',', Value, 1);
  if I > 0 then
    Value[I]:='.';
  Val(Value, Result, I);
  if I <> 0 then
    raise Exception.CreateFmt(SCanNotConvertToFloat_s, [Value]);
  {$ENDIF}
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

function RealToString(Value: Extended; const RealFormat: String): String;
begin
  FmtStr(Result, RealFormat, [Value]);
  if DecimalSeparator <> '.' then
    ReplaceCharProc(Result, DecimalSeparator, '.');
end;

function RealToStringF(Value: Extended; Precision, Digits_: Integer;
  const RealFormat: String): String;
begin
  Result:=FloatToStrF(Value, ffGeneral, Precision, Digits_);
  if DecimalSeparator <> '.' then
    ReplaceCharProc(Result, DecimalSeparator, '.');
end;

{$IFNDEF NO_DATETIME}
type
  TMonth = 1..12;

const
  MonthNamesRus: array [TMonth] of String[11] = ('января', 'февраля', 'марта',
    'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября',
    'декабря');
  MonthNamesEng: array [TMonth] of String[9] = ('January', 'February', 'March',
    'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November',
    'December');
  DayOfWeekNamesEngShort: array [1..7] of String[3] = ('Mon', 'Tue', 'Wed',
    'Thu', 'Fri', 'Sat', 'Sun');

function StdDateToStr(ADate: TDateTime; DateFormat: TFormat): String;
var
  Day, Month, Year: Word;
begin
  Case DateFormat of
    WindowsLong: begin
      DateTimeToString(Result, LongDateFormat, ADate);
      Exit;
    end;
    WindowsShort: begin
      Result:=DateToStr(ADate);
      Exit;
    end;
  End;
  DecodeDate(ADate, Year, Month, Day);
  Case DateFormat of
    RussianLong:
      Result:=IntToStr(Day) + ' ' + MonthNamesRus[Month] + ' ' + IntToStr(Year) + ' г.';
    RussianShort:
      Result:=IntToStr2(Day) + '.' + IntToStr2(Month) + '.' + IntToStr(Year);
    EnglishLong:
      Result:=MonthNamesEng[Month] + ' ' + IntToStr(Day) + ', ' + IntToStr(Year);
    EnglishShort:
      Result:=IntToStr2(Month) + '/' + IntToStr2(Day) + '/' + IntToStr(Year);
    RFC822:
      Result:=Format('%s, %d %s %d', [DayOfWeekNamesEngShort[DayOfWeek(ADate)],
        Day, Copy(MonthNamesEng[Month], 1, 3), Year]);
  Else {Simple}
    Result:=AddChar('0', IntToStr(Year), 4) + IntToStr2(Month) + IntToStr2(Day);
  End;
end;

function FStdStrToDate(const Value: String; var LastPos: Integer): TDateTime;
const
  { символы, достаточные для однозначного определения месяца }
  MonthRus: array [TMonth] of string[3] = ('Я', 'Ф', 'МАР',
    'АП', 'МА', 'ИЮН', 'ИЮЛ', 'АВ', 'С', 'О', 'Н', 'Д');
  MonthEng: array [TMonth] of string[3] = ('JA', 'F', 'MAR',
    'AP', 'MAY', 'JUN', 'JUL', 'AU', 'S', 'O', 'N', 'D');
  Delimiters = [' ', '.', ',', ';', '/', '\', '-', '_'];
type
  TCharSet = set of Char;
var
  LPos: Integer;
  S: String;

  function PassChars(const Chars: TCharSet; Equal: Boolean): Boolean;
  begin
    Result:=False;
    if LPos <= Length(S) then begin
      while (S[LPos] in Chars) = Equal do begin
        Inc(LPos);
        if LPos > Length(S) then
          Exit;
      end;
      Result:=True;
    end;
  end;

  function GetMonth(const S: String): Integer;
  var
    I: Integer;
  begin
    for I:=1 to 12 do
      if (Pos(MonthRus[I], S) = 1) and ((I <> 5) or (Length(S) > 2) and
        (S[3] in ['Й', 'Я'])) or (Pos(MonthEng[I], S) = 1) then
      begin
        Result:=I;
        Exit;
      end;
    Result:=0;
  end;

  function GetYear(const S: String): Word;
  begin
    Result:=StrToInt(S);
    if Length(S) <= 2 then
      if Result <= Y2KLimit then
        Inc(Result, 2000)
      else
        Inc(Result, 1900);
  end;

var
  I, J, K, L, DelimEnd, DelimStart: Integer;
  DD, MM, Day, Year, Month: Word;
  HasSuffix: Boolean;
  T: String;
begin
  Year:=0;
  S:=AnsiUpperCase(Trim(Value));
  Month:=GetMonth(S);
  LPos:=1;
  try
    if Month > 0 then begin
      if not PassChars(Digits, False) then
        Abort;
      I:=LPos;
      J:=I;
      if PassChars(Digits, True) then begin
        I:=LPos;
        if PassChars(Digits, False) then begin
          K:=LPos;
          PassChars(Digits, True);
          L:=LPos;
          if L <> K then
            Year:=GetYear(Copy(S, K, L - K))
        end;
      end;
      Day:=StrToInt(Copy(S, J, I - J));
    end
    else begin
      if not PassChars(Digits, True) then
        Abort;
      I:=LPos;
      if I = 1 then
        Abort;
      Day:=StrToInt(Copy(S, 1, I - 1));
      DelimStart:=I;
      PassChars(Delimiters, True);
      I:=LPos;
      DelimEnd:=I;
      Month:=GetMonth(Copy(S, I, Length(S)));
      if Month = 0 then begin
        J:=I;
        HasSuffix:=PassChars(Digits, True);
        I:=LPos;
        Month:=StrToInt(Copy(S, J, I - J));
        T:=Trim(Copy(S, DelimStart, DelimEnd - DelimStart));
        if (T <> '') and ((T[1] = '/') or
          (T[1] <> '.') and (AnsiUpperCase(ShortDateFormat)[1] in ['M', 'М'])) then
        begin
          L:=Day;
          Day:=Month;
          Month:=L;
        end;
      end
      else
        HasSuffix:=True;
      if HasSuffix and PassChars(Digits, False) then begin
        K:=LPos;
        PassChars(Digits, True);
        L:=LPos;
        Year:=GetYear(Copy(S, K, L - K));
      end;
    end;
    PassChars(Digits, False);
    if Year = 0 then
      DecodeDate(Date, Year, MM, DD);
    Result:=EncodeDate(Year, Month, Day);
    LastPos:=LPos;
  except
    raise Exception.CreateFmt(SIllegalDateTime, [Value]);
  end;
end;

function StdStrToDate(const Value: String): TDateTime;
var
  LastPos: Integer;
begin
  Result:=FStdStrToDate(Value, LastPos);
end;

{$IFDEF LINUX}
var
  WinShortTimeFormat: String;
{$ENDIF}

function StdTimeToStr(ATime: TDateTime; TimeFormat: TFormat): String;

  function EnglishTime(English, Short: Boolean): String;
  var
    HH, MM, SS, MS: Word;
    S: String;
  begin
    DecodeTime(ATime, HH, MM, SS, MS);
    if English then
      if HH > 12 then begin
        Dec(HH, 12);
        S:='PM';
      end
      else
        S:='AM'
    else
      S:='';
    Result:=IntToStr2(HH) + ':' + IntToStr2(MM);
    if not Short then
      Result:=Result + ':' + IntToStr2(SS);
    if S <> '' then
      Result:=Result + ' ' + S;
  end;

var
  HH, MM, SS, MS: Word;
begin
  Case TimeFormat of
    WindowsLong:
      Result:=TimeToStr(ATime);
    WindowsShort:
      DateTimeToString(Result,
        {$IFDEF LINUX}WinShortTimeFormat{$ELSE}ShortTimeFormat{$ENDIF}, ATime);
    RussianLong, RFC822:
      Result:=EnglishTime(False, False);
    RussianShort:
      Result:=EnglishTime(False, True);
    EnglishLong:
      Result:=EnglishTime(True, False);
    EnglishShort:
      Result:=EnglishTime(True, True);
  Else {Simple}
    DecodeTime(ATime, HH, MM, SS, MS);
    Result:=IntToStr2(HH) + IntToStr2(MM);
  End;
end;

function StdStrToTime(Value: String): TDateTime;
begin
  Value:=Trim(Value);
  if TimeSeparator <> ':' then
    Value:=ReplaceStr(Value, ':', TimeSeparator);
  if CharPos(TimeSeparator, Value, 1) <= 0 then
    raise Exception.CreateFmt(SIllegalDateTime, [Value]);
  Result:=StrToTime(Value);
end;

function StdDateTimeToStr(ADate: TDateTime; Format: TFormat): String;
begin
  Result:=StdDateToStr(ADate, Format) + ' ' + StdTimeToStr(ADate, Format);
end;

function StdStrToDateTime(Value: String): TDateTime;
var
  I, L, LastChar: Integer;
  Negative: Boolean;
begin
  Value:=Trim(Value);
  Result:=FStdStrToDate(Value, LastChar);
  I:=LastChar - 1;
  L:=Length(Value);
  if (I > L) or (Value[I] in [':', TimeSeparator]) then
    raise Exception.CreateFmt(SIllegalDateTime, [Value]);
  Value:=Trim(Copy(Value, LastChar, L));
  if Value <> '' then begin
    Negative:=Result < 0;
    Result:=Abs(Result) + StdStrToTime(Value);
    if Negative then
      Result:=-Result;
  end;
end;
{$ENDIF}

function CharToStr(C: Char): String;
begin
  if C >= #32 then
    Result:=C
  else
    Result:='#' + IntToStr(Ord(C));
end;

function StrToChar(const Value: String): Char;
var
  I, L, Code: Integer;
begin
  L:=Length(Value);
  if L = 1 then
    Result:=Value[1]
  else if (L > 1) and (Value[1] = '#') then begin
    Val(Copy(Value, 2, L), I, Code);
    if (Code <> 0) or not (I in [0..255]) then
      raise Exception.CreateFmt(SIllegalChar, [Value]);
    Result:=Chr(I);
  end
  else
    raise Exception.CreateFmt(SIllegalChar, [Value]);
end;

function BoolToStr(B: Boolean; BoolFormat: TFormat): String;
begin
  Case BoolFormat of
    WindowsLong: if B then Result:='Yes' else Result:='No';
    WindowsShort: if B then Result:='Y' else Result:='N';
    RussianLong: if B then Result:='Да' else Result:='Нет';
    RussianShort: if B then Result:='Д' else Result:='Н';
    EnglishLong: if B then Result:='True' else Result:='False';
    EnglishShort: if B then Result:='T' else Result:='F';
  Else {Simple}
    Result:=Chr(Ord('0') + Ord(B));
  End;
end;

function StrToBool(Value: String): Boolean;
begin
  Value:=AnsiUpperCase(Trim(Value));
  if (Value = '1') or (Value = 'YES') or (Value = 'Y') or (Value = 'ДА') or
    (Value = 'Д') or (Value = 'TRUE') or (Value = 'T')
  then
    Result:=True
  else if (Value = '0') or (Value = 'NO') or (Value = 'N') or (Value = 'НЕТ') or
    (Value = 'Н') or (Value = 'FALSE') or (Value = 'F')
  then
    Result:=False
  else
    raise Exception.CreateFmt(SIllegalBool, [Value]);
end;

function StandardFormat(const FormatStr: String; const Args: array of const): String;
begin
  FmtStr(Result, FormatStr, Args);
  if DecimalSeparator <> '.' then
    ReplaceCharProc(Result, DecimalSeparator, '.');
end;

{$IFDEF LINUX}
initialization
  WinShortTimeFormat:=ReplaceStr(ShortTimeFormat, ':ss', '');
{$ENDIF}
end.
