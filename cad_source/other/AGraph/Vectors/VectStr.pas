{ Version 050602. Copyright © Alexey A.Chernobaev, 1996-2005 }

{ Some functions are based on a code from other freeware units:
  1) StrUtils (RX Library) Copyright (c) 1995, 1996 AO ROSNO;
     Copyright (c) 1997, 1998 Master-Bank;
  2) QStrings Copyright (c) 2000, Andrew N. Driazgov; Portions (c) 2000,
     Sergey G. Shcherbakov) }

unit VectStr;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}{$IFNDEF WIN32}WinTypes, WinProcs,{$ELSE}Windows,{$ENDIF}{$ENDIF}
  SysUtils, ExtSys, ExtType
  {$IFDEF V_WIDESTRINGS}{$IFDEF V_D4},SysConst{$ENDIF}{$ENDIF};

const
  LoASCII = [#0..#31];
  LoASCIIAndSpace = LoASCII + [' '];
  Digits = ['0'..'9'];
  OctalDigits = ['0'..'7'];
  HexadecimalDigits = Digits + ['A'..'F', 'a'..'f'];
  ASCIIUpperAlpha = ['A'..'Z'];
  ASCIILowerAlpha = ['a'..'z'];
  ASCIIAlpha = ASCIIUpperAlpha + ASCIILowerAlpha;
  ASCIIAlphaNumeric = ASCIIAlpha + Digits;
  ASCII_32to127 = [#32..#127];
  Punctuation = ['!', ',', '.', ':', ';', '?'];
  Brackets = ['(', ')', '[', ']', '{', '}'];

type
  TCharSet = set of Char;

function LoCase(C: Char): Char; {$IFDEF V_INLINE}inline;{$ENDIF}
{ преобразует символ в нижний регистр ('A'..'Z' -> 'a'..'z') }
{ converts a character to lowercase ('A'..'Z' -> 'a'..'z') }

function NumOfChars(C: Char; const S: String): Integer;
{$IFDEF V_WIDESTRINGS}
function NumOfWideChars(C: WideChar; const S: WideString): Integer;
{$ENDIF}
{ возвращает количество вхождений символа C в строку S }
{ returns the number of occurrences of the character C in the string S }

function NumOfSubStr(const SubS, S: String): Integer;
{$IFDEF V_WIDESTRINGS}
function WideNumOfSubStr(const SubS, S: WideString): Integer;
{$ENDIF}
{ возвращает количество вхождений подстроки SubS в строку S }
{ returns the number of occurrences of the substring SubS in the string S }

{$IFDEF V_WIDESTRINGS}
function WideCharIn(W: WideChar; const Chars: TCharSet): Boolean;
{ Result:=(W < #256) and (Char(W) in Chars) }
{$ENDIF}

function IsASCIIString(const S: String): Boolean;
{$IFDEF V_WIDESTRINGS}
function IsASCIIWideString(const S: WideString): Boolean;
{$ENDIF}
{ возвращает True тогда и только тогда, когда строка S не содержит символов
  с кодами >= 128 }
{ returns True if and only if the string S doesn't contain characters with
  codes >= 128 }

function CharPos(C: Char; const S: String;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$IFDEF V_WIDESTRINGS}
function WideCharPos(C: WideChar; const S: WideString;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$ENDIF}
{ возвращает индекс первого вхождения символа С в строку S, начиная с позиции
  From (>= 1); возвращает 0, если символ не найден }
{ returns the index of the first occurrence of the character C in the string S
  starting from position From (>= 1); returns 0 if the character not found }

function CharNPos(C: Char; const S: String; N: Integer;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$IFDEF V_WIDESTRINGS}
function WideCharNPos(C: WideChar; const S: WideString; N: Integer;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$ENDIF}
{ возвращает индекс N-го (N >= 1) вхождения символа С в строку S, начиная с
  позиции From (>= 1); возвращает 0, если символ не найден }
{ returns the index of the Nth (N >= 1) occurrence of the character C in the
  string S starting from position From (>= 1); returns 0 if the character not
  found }

function LastPos(C: Char; const S: String): Integer;
{$IFDEF V_WIDESTRINGS}
function WideLastPos(C: WideChar; const S: WideString): Integer;
{$ENDIF}
{ если символ C входит в строку S, то возвращает индекс последнего вхождения
  этого символа, иначе возвращает 0 }
{ if the string S contains the character C then returns the index of the last
  occurrence of this character, otherwise returns 0 }

function CharInSetPos(const Chars: TCharSet; const S: String;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$IFDEF V_WIDESTRINGS}
function WideCharInSetPos(const Chars: TCharSet; const S: WideString;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$ENDIF}
{ возвращает индекс первого вхождения любого из символов, входящих в Chars, в
  строку S, начиная с позиции From (>= 1); возвращает 0, если символ не найден }
{ returns the index of the first occurrence of any character from Chars in the
  string S starting from position From (>= 1); returns 0 if the character
  not found }

function CharNotInSetPos(const Chars: TCharSet; const S: String;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$IFDEF V_WIDESTRINGS}
function WideCharNotInSetPos(const Chars: TCharSet; const S: WideString;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
{$ENDIF}
{ возвращает индекс первого вхождения любого из символов, НЕ входящих в Chars,
  в строку S, начиная с позиции From (>= 1); возвращает 0, если такой символ
  не был найден }
{ returns the index of the first occurrence of any character NOT from Chars in
  the string S starting from position From (>= 1); returns 0 if such character
  was not found }

{$IFDEF V_WIN}
function AnsiTextPos(const SubS, S: String): Integer;
{ аналог Pos, нечувствительный к регистру символов }
{ case-insensitive analog of Pos }
{$ENDIF}

function FirstUpper(const S: String): String;
procedure FirstUpperProc(var S: String);
{ заменяет первый символ S на заглавную букву }
{ changes the first character of S to uppercase }

function FirstLower(const S: String): String;
procedure FirstLowerProc(var S: String);
{ заменяет первый символ S на строчную букву }
{ changes the first character of S to lowercase }

function DelLastN(const S: String; N: Integer): String;
{ возвращает копию S без N последних символов }
{ returns a copy of S without the last N characters }

function DelLastIf(const S: String; C: Char): String;
{ если строка S оканчивается символом С, то уменьшает длину строки на 1 и
  возвращает ее, иначе возвращает копию S }
{ if the string S terminates with the character C then decreases the string
  length by 1 and returns it, otherwise returns a copy of S }

function FirstChar(const S: String): Char;
function LastChar(const S: String): Char;
{$IFDEF V_WIDESTRINGS}
function WideFirstChar(const S: WideString): WideChar;
function WideLastChar(const S: WideString): WideChar;
{$ENDIF}
{ see code }

function EnsureLast(const S: String; C: Char): String;
{ если строка S не пустая и не оканчивается символом С, то возвращает (S + C),
  иначе возвращает копию S }
{ if the string S is not empty and it doesn't end up with the character C then
  returns (S + C), otherwise returns a copy of S }
{$IFDEF V_WIDESTRINGS}
function WideEnsureLast(const S: WideString; C: WideChar): WideString;
{$ENDIF}

function CloseSentence(const S: String): String;
procedure CloseSentenceProc(var S: String);
{$IFDEF V_WIDESTRINGS}
function WideCloseSentence(const S: WideString): WideString;
procedure WideCloseSentenceProc(var S: WideString);
{$ENDIF}

procedure ConcatDelimited(var S: String; const Tail: String; Delimiter: Char);
{$IFDEF V_WIDESTRINGS}
procedure WideConcatDelimited(var S: WideString; const Tail: WideString; Delimiter: WideChar);
{$ENDIF}

{$IFDEF V_WIDESTRINGS}
procedure WideAppend(var S: WideString; C: WideChar);
{ S:=S + C }
procedure WideAppendStr(var S: WideString; const Tail: WideString);
{ S:=S + Tail }
{$ENDIF}

function PosFrom(const SubStr, S: String; From: Integer): Integer;
{ аналог System.Pos, но SubStr ищется, начиная с позиции From (>=1) }
{ analog of System.Pos which searches for SubStr from the position From (>=1) }
{$IFDEF V_WIDESTRINGS}
function WidePosFrom(const SubStr, S: WideString; From: Integer): Integer;
{$ENDIF}

function StartsWith(const S, What: String): Boolean;
{ Result = (Copy(S, 1, Length(What)) = What) }
{$IFDEF V_WIDESTRINGS}
function WideStartsWith(const S, What: WideString): Boolean;
{$ENDIF}

{$IFDEF V_WIN}
function AnsiStartsWith(const S, What: String): Boolean;
{ аналог StartsWith, нечувствительный к регистру символов }
{ case-insensitive analog of StartsWith }
{$ENDIF}

function EndsWith(const S, What: String): Boolean;
{$IFDEF V_WIDESTRINGS}
function WideEndsWith(const S, What: WideString): Boolean;
{$ENDIF}

{$IFDEF V_DELPHI}
{$IFNDEF V_D3}
function Trim(const S: String): String;
{ убирает символы с кодами <= ' ' в начале и конце строки }
{ removes leading and trailing characters with codes <= ' ' from the string }
{$ELSE}
function TrimW(const S: WideString): WideString;
{$ENDIF}
{$ENDIF}

{$IFNDEF V_D5} { Delphi 1-4, Free Pascal }
function AnsiSameText(const S1, S2: String): Boolean;
{$ENDIF}

{$IFDEF V_WIDESTRINGS}
{$IFNDEF V_D6}
function WideCompareText(const S1, S2: WideString): Integer;
function WideSameText(const S1, S2: WideString): Boolean;
{$ENDIF}
{$ENDIF}

function TrimTrail(const S: String): String;
{$IFDEF V_WIDESTRINGS}
function TrimTrailW(const S: WideString): WideString;
{$ENDIF}
{ убирает символы с кодами <= ' ' в конце строки }
{ removes trailing characters with codes <= ' ' from the string }

function TruncateAtZero(const S: String): String;
procedure TruncateAtZeroProc(var S: String);
{$IFDEF V_WIDESTRINGS}
function TruncateAtZeroWide(const S: WideString): WideString;
procedure TruncateAtZeroProcWide(var S: WideString);
{$ENDIF}
{ обрезает строку на первом вхождении #0 }
{ truncates the string at first #0 }

function TrimLastN(const S: String; N: Integer): String;
procedure TrimLastNProc(var S: String; N: Integer);
{$IFDEF V_WIDESTRINGS}
function WideTrimLastN(const S: WideString; N: Integer): WideString;
procedure WideTrimLastNProc(var S: WideString; N: Integer);
{$ENDIF}
{ обрезает последние N символов строки S (т.е. уменьшает длину S на N) }
{ truncates the last N characters from S (i.e. decreases the length of S by N) }

function IsWhiteSpace(const S: String): Boolean;
{ возвращает True, если все символы S меньше либо равны #32 }
{ returns True if all characters of S are lower or equal to #32 }

function MakeString(C: Char; N: Integer): String;
{$IFDEF V_WIDESTRINGS}
function MakeWideString(C: WideChar; N: Integer): WideString;
{$ENDIF}
{ аналог MakeStr из RX Library: возвращает строку, состоящую из N символов C }
{ analog of MakeStr from RX Library: returns the string consisting of N
  characters C }

function AddChar(C: Char; const S: String; N: Integer): String;
{ из RX Library: возвращает копию S, дополненную до длины N символами C слева }
{ from RX Library: returns copy of S left-padded to length N with characters C }

function ReplaceStr(const Value, FromStr, ToStr: String): String;
{$IFDEF V_WIDESTRINGS}
function WideReplaceStr(const Value, FromStr, ToStr: WideString): WideString;
{$ENDIF}
{ из RX Library: возвращает строку, полученную из Value заменой всех вхождений
  FromStr на ToStr }
{ from RX Library: returns the result of replacing all occurrences of FromStr in
  Value to ToStr }

procedure ReplaceCharProc(var S: String; FromChar, ToChar: Char);
function ReplaceChar(const S: String; FromChar, ToChar: Char): String;
{$IFDEF V_WIDESTRINGS}
procedure WideReplaceCharProc(var S: WideString; FromChar, ToChar: WideChar);
function WideReplaceChar(const S: WideString; FromChar, ToChar: WideChar): WideString;
{$ENDIF}
{ возвращает строку, полученную из Value заменой всех символов FromChar на
  ToChar }
{ returns the result of replacing all occurrences of the FromChar character in
  Value to ToChar }

function ContainsChars(const S: String; Chars: TCharSet): Boolean;
function ContainsCharsBuf(const Buf: PChar; Size: Integer;
  const Chars: TCharSet): Boolean;
{$IFDEF V_WIDESTRINGS}
function WideContainsChars(const S: WideString; Chars: TCharSet): Boolean;
{$ENDIF}
{ проверяет, содержит ли S хотя бы один символ из множества Chars }
{ checks whether S contains at least one character from Chars set }

function ContainsOnlyChars(const S: String; const Chars: TCharSet): Boolean;
function ContainsOnlyCharsBuf(const Buf: PChar; Size: Integer;
  const Chars: TCharSet): Boolean;
{ возвращает True, если строка содержит только символы из Chars }
{ returns True if the given string contains only characters from Chars }

function DelDupChar(const S: String; C: Char): String;
{ возвращают строку, полученную из S удалением повторяющихся символов C (другими
  словами, из каждой группы подряд идущих символов C остается один символ) }
{ returns the result of deleting duplicate characters C in the string S (in other
  words, only one character remains from every group of adjacent characters C) }

{$IFDEF V_LONGSTRINGS}
function DecodeCEscapes(const S: String): String;
{ возвращает строку, полученную из S заменой всех escape-последовательностей
  на соответствующие последовательности ASCII-символов, как это делают функции
  семейства printf стандартной библиотеки времени выполнения языка C (например,
  "\n" заменяется на #13#10, "\t" - на #9 и т.п.) }
{ returns the result of replacing all escape-sequences in the string S to the
  corresponding sequences of ASCII codes as the printf-family functions of the
  standard C-language run-time library do (e.g. "\n" will be replaced to #13#10,
  "\t" - to #9, etc.) }

function EncodeCEscapes(const S: String; Only7Bit: Boolean): String;
{ функция, обратная к DecodeCEscapes; все символы с кодами [#0..#31] будут
  закодированы escape-последовательностями \xNN, где NN - шестнадцатиричный код
  символа (если Only7Bit = True, то символы с кодами >= #128 также будут
  закодированы) }
{ inverse function for DecodeCEscapes; all characters with codes [#0..#31] will
  be encoded with escape-sequences \xNN, where NN is the hexadecimal character
  code (if Only7Bit = True then characters with codes >= #128 will be encoded
  also) }
{$ENDIF}

{$IFDEF WIN32}
function WordPos(SubWord, S: String; CaseSensitive: Boolean): Integer;
{ если SubWord входит в строку S как целое слово, то возвращает индекс первого
  такого вхождения, иначе возвращает 0 }
{ if the string S contains SubWord as the whole word then returns the index of
  the first such occurrence, otherwise returns 0 }

function AnsiToOem(const S: String): String;
function OemToAnsi(const S: String): String;

procedure AnsiToOemProc(var S: String);
procedure OemToAnsiProc(var S: String);
{$ENDIF}

function IsCorrectIdentifier(const S: String;
  AcceptIndexes: Boolean{$IFDEF V_DEFAULTS} = False{$ENDIF}): Boolean;
{ проверяет, является ли строка S правильным идентификатором (т.е. строка
  не пуста и состоит из латинских букв, цифр и символа подчеркивания, причем
  первый символ не является цифрой); если AcceptIndexes = True, то допускается
  индексирование, например, "Pixels[10, 20]" }
{ checks whether the string S is the correct identifier (i.e. the string is not
  empty and contains only latin characters, digits and '_' characters, moreover,
  first character isn't a digit); ; if AcceptIndexes = True then indexing is
  allowed, e.g. "Pixels[10, 20]" }

function IsCorrectQualifiedIdentifier(S: String;
  AcceptIndexes: Boolean{$IFDEF V_DEFAULTS} = False{$ENDIF}): Boolean;
{ обобщённый вариант IsCorrectIdentifier, который допускает квалифицированные
  идентификаторы (несколько идентификаторов, разделённых точками); если
  AcceptIndexes = True, то допускается индексирование, например,
  "Canvas.Pixels[10, 20]" }
{ more general variant of IsCorrectIdentifier which accepts qualified
  identifiers (several identifiers delimited by dots); if AcceptIndexes = True
  then indexing is allowed, e.g. "Canvas.Pixels[10, 20]" }

function RemoveChar(const S: String; C: Char): String;
{$IFDEF V_WIDESTRINGS}
function RemoveCharWide(const S: WideString; C: WideChar): WideString;
{$ENDIF}
{ удаляет из строки S все символы, равные C }
{ removes all characters equal to C from the string S }

function RemoveChars(const S: String; const CharsToRemove: TCharSet): String;
{$IFDEF V_WIDESTRINGS}
function RemoveCharsWide(const S: WideString; const CharsToRemove: TCharSet): WideString;
{$ENDIF}
{ удаляет из строки S все символы, входящие во множество CharsToRemove }
{ removes all characters containing in the set CharsToRemove from the string S }

function RemoveComment(const S: String; CommentPrefix: Char): String;
{ удаляет из S комментарий - часть строки, которая начинается с CommentPrefix,
  включая этот символ, если только CommentPrefix не находится внутри строкового
  литерала, ограниченного одинарными или двойными кавычками; функция возвращает
  оставшуюся часть строки, удаляя из нее начальные и концевые пробелы и
  специальные символы (символы с кодами <= ' '). Пример:
  RemoveComment('Point="2.0;3.5" ; coordinates', ';') = 'Point="2.0;3.5"' }
{ removes any comments from the string S; comment is the part of the string
  starting with CommentPrefix character, including this symbol, if only
  CommentPrefix isn't located inside the string literal enclosed in the single or
  double quotes; returns the remaining part of the string with deleted leading
  and trailing spaces and special characters (characters with codes <= ' ').
  E.g.: RemoveComment('Point="2.0;3.5" ; coordinates', ';') = 'Point="2.0;3.5"' }

function StringToLiteral(const S: String): String;
{$IFDEF V_WIDESTRINGS}
function WideStringToLiteral(const S: WideString): WideString;
{$ENDIF}
{ преобразует строку S в литерал, заключая S в одинарные кавычки и удваивая
  одинарные кавычки, входящие в S. Пример: 'cause => '''cause' }
{ converts the string S to the literal enclosing S in the single quotes and
  duplicating single quotes inside S. E.g.: 'cause => '''cause' }

function StringToLiteral2(const S: String): String;
{$IFDEF V_WIDESTRINGS}
function WideStringToLiteral2(const S: WideString): WideString;
{$ENDIF}
{ преобразует строку S в литерал, заключая S в двойные кавычки и удваивая
  двойные кавычки, входящие в S. Пример: "cause => """cause" }
{ converts the string S to the literal enclosing S in the double quotes and
  duplicating double quotes inside S. E.g.: "cause => """cause" }

function TextToLiteral(const S: String): String;
{$IFDEF V_WIDESTRINGS}
function WideTextToLiteral(const S: WideString): WideString;
{$ENDIF}
{ если в строку S входят символы, отличные от латинских букв, цифр и ряда других
  символов (см. CheckText), или S - пустая строка, то преобразует S в литерал,
  заключая S в одинарные кавычки и удваивая одинарные кавычки, входящие в S,
  иначе возвращает копию S }
{ if there are characters differing from the Latin letters, digits and some
  other characters (see CheckText) in the string S or S is the empty string then
  converts S to the literal enclosing S in the single quotes and duplicating
  single quotes inside S, otherwise returns the copy of S }

function TextToLiteral2(const S: String): String;
{$IFDEF V_WIDESTRINGS}
function WideTextToLiteral2(const S: WideString): WideString;
{$ENDIF}
{ если в строку S входят символы, отличные от латинских букв, цифр и ряда других
  символов (см. CheckText), или S - пустая строка, то преобразует S в литерал,
  заключая S в двойные кавычки и удваивая двойные кавычки, входящие в S,
  иначе возвращает копию S }
{ if there are characters differing from the Latin letters, digits and some
  other characters (see CheckText) in the string S or S is the empty string then
  converts S to the literal enclosing S in the double quotes and duplicating
  double quotes inside S, otherwise returns the copy of S }

function LiteralToString(const S: String): String;
{$IFDEF V_WIDESTRINGS}
function LiteralToWideString(const S: WideString): WideString;
{$ENDIF}
{ обратная функция к StringToLiteral: удаляет одинарные кавычки в начале и конце
  S, а из каждой пары одинарных кавычек внутри строки оставляет одну кавычку;
  допускается использование двойных кавычек вместо одинарных (в этом случае
  одинарные кавычки интерпретируются как обычные символы, а двойные кавычки
  обрабатываются, как одинарные в первом случае). Примеры: '''cause' => 'cause;
  "'cause" => 'cause; """London""" => "London"; "'London'" => 'London'; если S
  не заключена в кавычки (одинаковые в начале и конце), то возвращается копия S }
{ inverse function for StringToLiteral; accepts both single and double quotes.
  E.g.: '''cause' => 'cause; "'cause" => 'cause; """London""" => "London";
  "'London'" => 'London'; if the string S isn't enclosed in any quotes (the same
  at the beginning and at the end of the string) then returns the copy of S }

function GetValueByName(const S, Name: String; var Value: String;
  CaseSensitive: Boolean{$IFDEF V_DEFAULTS} = False{$ENDIF};
  const QuoteChars: TCharSet{$IFDEF V_DEFAULTS} = ['"', '''']{$ENDIF}): Boolean;
{ in: S = '... Name = XXXX ...'; out: Value = XXXX; example:
  if S = <META content="text/html; charset=ISO-8859-1" http-equiv=Content-Type>,
     Name = 'content', QuoteChars = ['"', '''']
  then
     Value:='text/html; charset=ISO-8859-1' }

{$IFDEF V_WIDESTRINGS}{$IFDEF V_D4}{$IFNDEF V_D6} { from Delphi 6 RTL (SysUtils) }
function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;

procedure WideFmtStr(var Result: WideString; const Format: WideString;
  const Args: array of const);

function WideFormat(const Format: WideString; const Args: array of const): WideString;
{$ENDIF}{$ENDIF}{$ENDIF}

{$IFDEF V_D4}
function IntToStrSeparated(Value: Int64): String;
{$ENDIF}

function IntToRoman(N: Integer): String;
{ if N in [1..5000] then converts it to Roman number else returns empty string;
  from unit QStrings; modified }

function ValOctPChar(P: PChar; L: Integer; var Value: Integer): Boolean;
function ValOctStr(const S: String; var Value: Integer): Boolean;
function OctToInt(P: PChar; MaxLen: Integer; var Value: Integer): Boolean;

const
{$IFDEF WIN32}
  iSystemLocale = LOCALE_SYSTEM_DEFAULT; { $0800: system default locale }
  iUserLocale = LOCALE_USER_DEFAULT; { $0400: user default locale }

  iCaseInsensitive = NORM_IGNORECASE; { $0001: case-insensitive }
  iIgnoreNonSpace = NORM_IGNORENONSPACE; { $0002: ignore non-spacing characters }
  iIgnoreSymbols = NORM_IGNORESYMBOLS; { $0004: ignore symbols }
  iStringSort = SORT_STRINGSORT; { $1000: use string-order instead of word-order }
  FlagsMask = iCaseInsensitive or iIgnoreNonSpace or iIgnoreSymbols or iStringSort;
{$ELSE}
  iSystemLocale = $0800; { iSystemLocale and iUserLocale are the same for D1 }
  iUserLocale = $0400;

  iCaseInsensitive = $0001; { case-insensitive }
  FlagsMask = iCaseInsensitive;
{$ENDIF}
  LocaleMask = iSystemLocale or iUserLocale;

  { iLocaled: user locale, ascending, case insensitive, word sort order }
  iLocaled = iUserLocale;
  { iDefault: don't take into account user locale, ascending, case insensitive,
    word sort order }
  iDefault = 0;

function CmpStrF(const S1, S2: String; Flags: LongInt): Integer;
{ Result value >0 if S1 greater then S2, <0 if S1 less then S2, and 0 if equal.
  If Flags = 0 then CmpStrF compares S1 and S2 in the same way as if they were
  compared using "<" and ">" operators.
  If Flags <> 0 then CmpStrF uses Windows API CompareString function which
  supports several methods for comparing strings: at first, it can use either
  System Locale or Current User Locale; then, it can treat strings in the
  case-sensitive or case-insensitive manner; and, at last, it uses "word sort"
  or "string sort" variants (see Windows Help for details). Specify the mode you
  want in the Flags parameter (see constants above). }

{$IFDEF V_WIDESTRINGS}
function WStrCmp(PLeft, PRight: PWideChar): Integer;
function CompareWide(const Left, Right: WideString): Integer;
function CompareStrBufWide(PW1, PW2: PWideChar; Count1, Count2: Integer): Integer;
function CompareStrWide(const W1, W2: WideString): Integer;
{ compare strings case sensitively }
{$ENDIF}

function CompareStrBuf(P1, P2: PChar; Count1, Count2: Integer): Integer;
function CompareTextBuf(P1, P2: PChar; Count1, Count2: Integer): Integer;

function MemEqualStr(const X; const S: String): Boolean;

function CompareVersions(Ver1, Ver2: String;
  pError: PBoolean{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Integer;
{ compares version strings; version string consists of several numbers,
  delimited by dots ('NN.NN.NN') }

implementation

{$IFDEF V_INLINE}
function LoCase(C: Char): Char;
begin
  Result:=C;
  if C in ['A'..'Z'] then
    Result:=Chr(Ord(Result) or $20);
end;
{$ELSE}
function LoCase(C: Char): Char;
{$IFNDEF USE_ASM}
begin
  Result:=C;
  if C in ['A'..'Z'] then
    Result:=Chr(Ord(Result) or $20);
end;
{$ELSE}
asm
{ ->    AL      Character       }
{ <-    AL      Result          }
        {$IFDEF V_FREEPASCAL}
        mov     al, C
        {$ENDIF}
        CMP     AL, 'A'
        JB      @@exit
        CMP     AL, 'Z'
        JA      @@exit
        ADD     AL, 'a' - 'A'
@@exit:
end;
{$ENDIF} {USSE_ASM}
{$ENDIF} {V_INLINE}

function NumOfChars(C: Char; const S: String): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=1 to Length(S) do
    if S[I] = C then
      Inc(Result);
end;

{$IFDEF V_WIDESTRINGS}
function NumOfWideChars(C: WideChar; const S: WideString): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=1 to Length(S) do
    if S[I] = C then
      Inc(Result);
end;
{$ENDIF}

function NumOfSubStr(const SubS, S: String): Integer;
var
  I: Integer;
begin
  Result:=0;
  I:=0;
  repeat
    I:=PosFrom(SubS, S, I);
    if I = 0 then
      Exit;
    Inc(Result);
    Inc(I, Length(SubS));
  until False;
end;

{$IFDEF V_WIDESTRINGS}
function WideNumOfSubStr(const SubS, S: WideString): Integer;
var
  I: Integer;
begin
  Result:=0;
  I:=0;
  repeat
    I:=WidePosFrom(SubS, S, I);
    if I = 0 then
      Exit;
    Inc(Result);
    Inc(I, Length(SubS));
  until False;
end;
{$ENDIF}

{$IFDEF V_WIDESTRINGS}
function WideCharIn(W: WideChar; const Chars: TCharSet): Boolean;
begin
  Result:=(W < #256) and (Char(W) in Chars);
end;
{$ENDIF}

function IsASCIIString(const S: String): Boolean;
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] >= #128 then begin
      Result:=False;
      Exit;
    end;
  Result:=True;
end;

{$IFDEF V_WIDESTRINGS}
function IsASCIIWideString(const S: WideString): Boolean;
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] >= #128 then begin
      Result:=False;
      Exit;
    end;
  Result:=True;
end;
{$ENDIF}

function CharPos(C: Char; const S: String; From: Integer): Integer;
var
  I, J: Integer;
begin
  if From < 1 then
    From:=1;
  {$IFDEF V_LONGSTRINGS}
  Result:=0;
  I:=Length(S);
  if From <= I then begin
    J:=From - 1;
    I:=IndexOfValue8((PChar(Pointer(S)) + J)^, Ord(C), I - J);
    if I >= 0 then
      Result:=I + From;
  end;
  {$ELSE}
  for I:=From to Length(S) do
    if S[I] = C then begin
      Result:=I;
      Exit;
    end;
  Result:=0;
  {$ENDIF}
end;

{$IFDEF V_WIDESTRINGS}
function WideCharPos(C: WideChar; const S: WideString; From: Integer): Integer;
var
  I, J: Integer;
begin
  Result:=0;
  if From < 1 then
    From:=1;
  I:=Length(S);
  if From <= I then begin
    J:=From - 1;
    I:=IndexOfValue16((PWideChar(Pointer(S)) + J)^, Ord(C), I - J);
    if I >= 0 then
      Result:=I + From;
  end;
end;
{$ENDIF}

function CharNPos(C: Char; const S: String; N: Integer;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
var
  I{$IFDEF V_LONGSTRINGS}, J, L{$ENDIF}: Integer;
begin
  if From < 1 then
    From:=1;
  {$IFDEF V_LONGSTRINGS}
  L:=Length(S);
  while From <= L do begin
    J:=From - 1;
    I:=IndexOfValue8((PChar(Pointer(S)) + J)^, Ord(C), L - J);
    if I < 0 then
      Break;
    Dec(N);
    if N <= 0 then begin
      Result:=I + From;
      Exit;
    end;
    Inc(From, I + 1);
  end;
  Result:=0;
  {$ELSE}
  for I:=From to Length(S) do
    if S[I] = C then begin
      Dec(N);
      if N <= 0 then begin
        Result:=I;
        Exit;
      end;
    end;
  Result:=0;
  {$ENDIF}
end;

{$IFDEF V_WIDESTRINGS}
function WideCharNPos(C: WideChar; const S: WideString; N: Integer;
  From: Integer{$IFDEF V_DEFAULTS} = 1{$ENDIF}): Integer;
var
  I, J, L: Integer;
begin
  if From < 1 then
    From:=1;
  L:=Length(S);
  while From <= L do begin
    J:=From - 1;
    I:=IndexOfValue16((PWideChar(Pointer(S)) + J)^, Ord(C), L - J);
    if I < 0 then
      Break;
    Dec(N);
    if N <= 0 then begin
      Result:=I + From;
      Exit;
    end;
    Inc(From, I + 1);
  end;
  Result:=0;
end;
{$ENDIF}

function LastPos(C: Char; const S: String): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=Length(S) downto 1 do
    if S[I] = C then begin
      Result:=I;
      Exit;
    end;
end;

{$IFDEF V_WIDESTRINGS}
function WideLastPos(C: WideChar; const S: WideString): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=Length(S) downto 1 do
    if S[I] = C then begin
      Result:=I;
      Exit;
    end;
end;
{$ENDIF}

function CharInSetPos(const Chars: TCharSet; const S: String; From: Integer): Integer;
var
  I: Integer;
begin
  if From < 1 then
    From:=1;
  for I:=From to Length(S) do
    if S[I] in Chars then begin
      Result:=I;
      Exit;
    end;
  Result:=0;
end;

{$IFDEF V_WIDESTRINGS}
function WideCharInSetPos(const Chars: TCharSet; const S: WideString; From: Integer): Integer;
var
  I: Integer;
  W: WideChar;
begin
  if From < 1 then
    From:=1;
  for I:=From to Length(S) do begin
    W:=S[I];
    if (W < #256) and (Char(W) in Chars) then begin
      Result:=I;
      Exit;
    end;
  end;
  Result:=0;
end;
{$ENDIF}

function CharNotInSetPos(const Chars: TCharSet; const S: String; From: Integer): Integer;
var
  I: Integer;
begin
  if From < 1 then
    From:=1;
  for I:=From to Length(S) do
    if not (S[I] in Chars) then begin
      Result:=I;
      Exit;
    end;
  Result:=0;
end;

{$IFDEF V_WIDESTRINGS}
function WideCharNotInSetPos(const Chars: TCharSet; const S: WideString; From: Integer): Integer;
var
  I: Integer;
  W: WideChar;
begin
  if From < 1 then
    From:=1;
  for I:=From to Length(S) do begin
    W:=S[I];
    if (W >= #256) or not (Char(W) in Chars) then begin
      Result:=I;
      Exit;
    end;
  end;
  Result:=0;
end;
{$ENDIF}

{$IFDEF V_WIN}
function AnsiTextPos(const SubS, S: String): Integer;
begin
  Result:=Pos(AnsiUpperCase(SubS), AnsiUpperCase(S));
end;
{$ENDIF}

function FirstUpper(const S: String): String;
begin
  Result:=S;
  FirstUpperProc(Result);
end;

procedure FirstUpperProc(var S: String);
{$IFDEF V_WIN}
var
  Buf: array [0..1] of Char;
{$ENDIF}
begin
  if S <> '' then begin
    {$IFDEF V_WIN}
    Buf[0]:=S[1];
    Buf[1]:=#0;
    {$IFDEF WIN32}
    CharUpper(Buf);
    {$ELSE}
    AnsiUpper(Buf);
    {$ENDIF}
    S[1]:=Buf[0];
    {$ELSE}
    S[1]:=UpCase(S[1]);
    {$ENDIF}
  end;
end;

function FirstLower(const S: String): String;
begin
  Result:=S;
  FirstLowerProc(Result);
end;

procedure FirstLowerProc(var S: String);
{$IFDEF V_WIN}
var
  Buf: array [0..1] of Char;
{$ENDIF}
begin
  if S <> '' then begin
    {$IFDEF V_WIN}
    Buf[0]:=S[1];
    Buf[1]:=#0;
    {$IFDEF WIN32}
    CharLower(Buf);
    {$ELSE}
    AnsiLower(Buf);
    {$ENDIF}
    S[1]:=Buf[0];
    {$ELSE}
    S[1]:=LoCase(S[1]);
    {$ENDIF}
  end;
end;

function DelLastN(const S: String; N: Integer): String;
begin
  N:=Length(S) - N;
  if N > 0 then
    Result:=Copy(S, 1, N)
  else
    Result:='';
end;

function DelLastIf(const S: String; C: Char): String;
begin
  Result:=S;
  if (S <> '') and (S[Length(S)] = C) then
    SetLength(Result, Length(S) - 1);
end;

function FirstChar(const S: String): Char;
begin
  Result:=#0;
  if S <> '' then
    Result:=S[1];
end;

function LastChar(const S: String): Char;
begin
  Result:=#0;
  if S <> '' then
    Result:=S[Length(S)];
end;

{$IFDEF V_WIDESTRINGS}
function WideFirstChar(const S: WideString): WideChar;
begin
  Result:=#0;
  if S <> '' then
    Result:=S[1];
end;

function WideLastChar(const S: WideString): WideChar;
begin
  Result:=#0;
  if S <> '' then
    Result:=S[Length(S)];
end;
{$ENDIF}

function EnsureLast(const S: String; C: Char): String;
var
  L: Integer;
begin
  Result:=S;
  L:=Length(S);
  if (L > 0) and (S[L] <> C) then
    Result:=Result + C;
end;

{$IFDEF V_WIDESTRINGS}
function WideEnsureLast(const S: WideString; C: WideChar): WideString;
var
  L: Integer;
begin
  Result:=S;
  L:=Length(Result);
  if (L > 0) and (Result[L] <> C) then begin
    Inc(L);
    SetLength(Result, L);
    Result[L]:=C;
  end;
end;
{$ENDIF}

function CloseSentence(const S: String): String;
begin
  Result:=S;
  CloseSentenceProc(Result);
end;

procedure CloseSentenceProc(var S: String);
begin
  if (S <> '') and not (S[Length(S)] in ['.', '!', '?']) then
    S:=S + '.';
end;

{$IFDEF V_WIDESTRINGS}
function WideCloseSentence(const S: WideString): WideString;
begin
  Result:=S;
  WideCloseSentenceProc(Result);
end;

procedure WideCloseSentenceProc(var S: WideString);
var
  WC: WideChar;
begin
  if S <> '' then begin
    WC:=S[Length(S)];
    if not ((WC < #256) and (Char(WC) in ['.', '!', '?'])) then
      S:=S + '.';
  end;
end;
{$ENDIF}

procedure ConcatDelimited(var S: String; const Tail: String; Delimiter: Char);
begin
  if Tail <> '' then begin
    if S <> '' then
      S:=S + Delimiter;
    S:=S + Tail;
  end;
end;

{$IFDEF V_WIDESTRINGS}
procedure WideConcatDelimited(var S: WideString; const Tail: WideString; Delimiter: WideChar);
begin
  if Tail <> '' then begin
    {$IFDEF V_WIDESTRING_PLUS}
    if S <> '' then
      S:=S + Delimiter;
    S:=S + Tail;
    {$ELSE}
    if S <> '' then
      WideAppend(S, Delimiter);
    WideAppendStr(S, Tail);
    {$ENDIF}
  end;
end;
{$ENDIF}

{$IFDEF V_WIDESTRINGS}
procedure WideAppend(var S: WideString; C: WideChar);
var
  L: Integer;
begin
  L:=Length(S) + 1;
  SetLength(S, L);
  S[L]:=C;
end;

procedure WideAppendStr(var S: WideString; const Tail: WideString);
var
  L, T: Integer;
begin
  T:=Length(Tail);
  if T = 0 then
    Exit;
  L:=Length(S);
  if L = 0 then
    S:=Tail
  else begin
    SetLength(S, L + T);
    Move(Pointer(Tail)^, PWideChar(Pointer(S))[L], T * 2);
  end;
end;
{$ENDIF}

function PosFrom(const SubStr, S: String; From: Integer): Integer;
begin
  if From < 1 then
    From:=1;
  Result:=Pos(SubStr, Copy(S, From, Length(S)));
  if Result > 0 then
    Inc(Result, From - 1);
end;

{$IFDEF V_WIDESTRINGS}
function WidePosFrom(const SubStr, S: WideString; From: Integer): Integer;
begin
  if From < 1 then
    From:=1;
  Result:=Pos(SubStr, Copy(S, From, Length(S)));
  if Result > 0 then
    Inc(Result, From - 1);
end;
{$ENDIF}

function StartsWith(const S, What: String): Boolean;
var
  I, L: Integer;
begin
  Result:=False;
  L:=Length(What);
  if L > Length(S) then
    Exit;
  for I:=1 to L do
    if S[I] <> What[I] then
      Exit;
  Result:=True;
end;

{$IFDEF V_WIDESTRINGS}
function WideStartsWith(const S, What: WideString): Boolean;
var
  I, L: Integer;
begin
  Result:=False;
  L:=Length(What);
  if L > Length(S) then
    Exit;
  for I:=1 to L do
    if S[I] <> What[I] then
      Exit;
  Result:=True;
end;
{$ENDIF}

function AnsiStartsWith(const S, What: String): Boolean;
var
  L: Integer;
begin
  Result:=False;
  L:=Length(What);
  if L > Length(S) then
    Exit;
  Result:=AnsiSameText(Copy(S, 1, L), What);
end;

function EndsWith(const S, What: String): Boolean;
var
  I, J, N, L: Integer;
begin
  Result:=False;
  L:=Length(S);
  N:=L - Length(What);
  if N < 0 then
    Exit;
  J:=1;
  for I:=N + 1 to L do begin
    if S[I] <> What[J] then
      Exit;
    Inc(J);
  end;
  Result:=True;
end;

{$IFDEF V_WIDESTRINGS}
function WideEndsWith(const S, What: WideString): Boolean;
var
  I, J, N, L: Integer;
begin
  Result:=False;
  L:=Length(S);
  N:=L - Length(What);
  if N < 0 then
    Exit;
  J:=1;
  for I:=N + 1 to L do begin
    if S[I] <> What[J] then
      Exit;
    Inc(J);
  end;
  Result:=True;
end;
{$ENDIF}

{$IFDEF V_DELPHI}
{$IFNDEF V_D3}
function Trim(const S: String): String;
{$ELSE}
function TrimW(const S: WideString): WideString;
{$ENDIF}
var
  I, J: Integer;
begin
  I:=1;
  while (I <= Length(S)) and (S[I] <= ' ') do Inc(I);
  J:=Length(S);
  while (J >= 1) and (S[J] <= ' ') do Dec(J);
  Result:=Copy(S, I, J - I + 1)
end;
{$ENDIF}

{$IFNDEF V_D5} { Delphi 1-4, Free Pascal }
function AnsiSameText(const S1, S2: String): Boolean;
begin
  {$IFDEF WIN32}
  Result:=CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    Length(S1), PChar(S2), Length(S2)) = 2;
  {$ELSE}
  Result:=AnsiCompareText(S1, S2) = 0;
  {$ENDIF}
end;
{$ENDIF}

{$IFDEF V_WIDESTRINGS}
{$IFNDEF V_D6}
function WideCompareText(const S1, S2: WideString): Integer;
begin
{$IFDEF MSWINDOWS}
  SetLastError(0);
  Result:=CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PWideChar(S1),
    Length(S1), PWideChar(S2), Length(S2)) - 2;
  Case GetLastError of
    0: ;
    ERROR_CALL_NOT_IMPLEMENTED:
      Result:=CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
        PChar(String(S1)), Length(S1), PChar(String(S2)), Length(S2)) - 2;
  Else
    RaiseLastOSError;
  End;
{$ENDIF}
{$IFDEF LINUX}
  Result:=WideCompareStr(WideUpperCase(S1), WideUpperCase(S2));
{$ENDIF}
end;

function WideSameText(const S1, S2: WideString): Boolean;
begin
  Result:=WideCompareText(S1, S2) = 0;
end;
{$ENDIF}
{$ENDIF}

function TrimTrail(const S: String): String;
var
  I: Integer;
begin
  I:=Length(S);
  while (I >= 1) and (S[I] <= ' ') do Dec(I);
  Result:=S;
  SetLength(Result, I);
end;

{$IFDEF V_WIDESTRINGS}
function TrimTrailW(const S: WideString): WideString;
var
  I: Integer;
begin
  I:=Length(S);
  while (I >= 1) and (S[I] <= ' ') do Dec(I);
  Result:=S;
  SetLength(Result, I);
end;
{$ENDIF}

function TruncateAtZero(const S: String): String;
begin
  Result:=S;
  TruncateAtZeroProc(Result);
end;

procedure TruncateAtZeroProc(var S: String);
var
  I: Integer;
begin
  I:=CharPos(#0, S, 1);
  if I > 0 then
    SetLength(S, I - 1);
end;

{$IFDEF V_WIDESTRINGS}
function TruncateAtZeroWide(const S: WideString): WideString;
begin
  Result:=S;
  TruncateAtZeroProcWide(Result);
end;

procedure TruncateAtZeroProcWide(var S: WideString);
var
  I: Integer;
begin
  I:=WideCharPos(#0, S, 1);
  if I > 0 then
    SetLength(S, I - 1);
end;
{$ENDIF}

function TrimLastN(const S: String; N: Integer): String;
var
  L: Integer;
begin
  L:=Length(S) - N;
  if L < 0 then
    L:=0;
  Result:=Copy(S, 1, L);
end;

procedure TrimLastNProc(var S: String; N: Integer);
var
  L: Integer;
begin
  L:=Length(S) - N;
  if L < 0 then
    L:=0;
  SetLength(S, L);
end;

{$IFDEF V_WIDESTRINGS}
function WideTrimLastN(const S: WideString; N: Integer): WideString;
var
  L: Integer;
begin
  L:=Length(S) - N;
  if L < 0 then
    L:=0;
  Result:=Copy(S, 1, L);
end;

procedure WideTrimLastNProc(var S: WideString; N: Integer);
var
  L: Integer;
begin
  L:=Length(S) - N;
  if L < 0 then
    L:=0;
  SetLength(S, L);
end;
{$ENDIF}

function IsWhiteSpace(const S: String): Boolean;
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] > ' ' then begin
      Result:=False;
      Exit;
    end;
  Result:=True;
end;

function MakeString(C: Char; N: Integer): String;
begin
  if N > 0 then begin
    {$IFDEF V_LONGSTRINGS}
    SetLength(Result, N);
    {$ELSE}
    if N > 255 then
      N:=255;
    Result[0]:=Chr(N);
    {$ENDIF}
    FillChar(Result[1], Length(Result), C);
  end
  else
    Result:='';
end;

{$IFDEF V_WIDESTRINGS}
function MakeWideString(C: WideChar; N: Integer): WideString;
begin
  SetLength(Result, N);
  if N > 0 then
    FillValue16(Result[1], Int16(C), N);
end;
{$ENDIF}

function AddChar(C: Char; const S: String; N: Integer): String;
begin
  if Length(S) < N then
    Result:=MakeString(C, N - Length(S)) + S
  else
    Result := S;
end;

function ReplaceStr(const Value, FromStr, ToStr: String): String;
var
  I: Integer;
  Source: String;
begin
  Source:=Value;
  Result:='';
  repeat
    I:=Pos(FromStr, Source);
    if I > 0 then begin
      Result:=Result + Copy(Source, 1, I - 1) + ToStr;
      Source:=Copy(Source, I + Length(FromStr), Length(Source));
    end
    else begin
      Result:=Result + Source;
      Break;
    end;
  until False;
end;

{$IFDEF V_WIDESTRINGS}
function WideReplaceStr(const Value, FromStr, ToStr: WideString): WideString;
var
  I: Integer;
  Source: WideString;
begin
  Source:=Value;
  Result:='';
  repeat
    I:=Pos(FromStr, Source);
    if I > 0 then begin
      Result:=Result + Copy(Source, 1, I - 1) + ToStr;
      Source:=Copy(Source, I + Length(FromStr), Length(Source));
    end
    else begin
      Result:=Result + Source;
      Break;
    end;
  until False;
end;
{$ENDIF}

procedure ReplaceCharProc(var S: String; FromChar, ToChar: Char);
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] = FromChar then
      S[I]:=ToChar;
end;

function ReplaceChar(const S: String; FromChar, ToChar: Char): String;
begin
  Result:=S;
  ReplaceCharProc(Result, FromChar, ToChar);
end;

{$IFDEF V_WIDESTRINGS}
procedure WideReplaceCharProc(var S: WideString; FromChar, ToChar: WideChar);
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] = FromChar then
      S[I]:=ToChar;
end;

function WideReplaceChar(const S: WideString; FromChar, ToChar: WideChar): WideString;
begin
  Result:=S;
  WideReplaceCharProc(Result, FromChar, ToChar);
end;
{$ENDIF}

function ContainsChars(const S: String; Chars: TCharSet): Boolean;
{ alternative:
    Result:=ContainsCharsBuf(PChar(S), Length(S), Chars); }
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] in Chars then begin
      Result:=True;
      Exit;
    end;
  Result:=False;
end;

function ContainsCharsBuf(const Buf: PChar; Size: Integer;
  const Chars: TCharSet): Boolean;
var
  P, Limit: PChar;
begin
  Result:=False;
  if (Buf = nil) or (Size <= 0) then
    Exit;
  P:=Buf;
  Limit:=Buf + Size;
  repeat
    if P^ in Chars then begin
      Result:=True;
      Exit;
    end;
    Inc(P);
  until P >= Limit;
end;

{$IFDEF V_WIDESTRINGS}
function WideContainsChars(const S: WideString; Chars: TCharSet): Boolean;
var
  I: Integer;
  C: WideChar;
begin
  for I:=1 to Length(S) do begin
    C:=S[I];
    if (C < #256) and (Char(C) in Chars) then begin
      Result:=True;
      Exit;
    end;
  end;
  Result:=False;
end;
{$ENDIF}

function ContainsOnlyChars(const S: String; const Chars: TCharSet): Boolean;
{ alternative:
    Result:=ContainsOnlyCharsBuf(PChar(S), Length(S), Chars); }
var
  I: Integer;
begin
  Result:=False;
  if S = '' then
    Exit;
  for I:=1 to Length(S) do
    if not (S[I] in Chars) then
      Exit;
  Result:=True;
end;

function ContainsOnlyCharsBuf(const Buf: PChar; Size: Integer;
  const Chars: TCharSet): Boolean;
var
  P, Limit: PChar;
begin
  Result:=False;
  if (Buf = nil) or (Size <= 0) then
    Exit;
  P:=Buf;
  Limit:=Buf + Size;
  repeat
    if not (P^ in Chars) then
      Exit;
    Inc(P);
  until P >= Limit;
  Result:=True;
end;

function DelDupChar(const S: String; C: Char): String;
var
  I, J: Integer;
  CurChar, LastChar: Char;
begin
  SetLength(Result, Length(S));
  if Length(S) > 0 then begin
    LastChar:=S[1];
    Result[1]:=LastChar;
    J:=1;
    for I:=2 to Length(S) do begin
      CurChar:=S[I];
      if (CurChar <> C) or (CurChar <> LastChar) then begin
        Inc(J);
        Result[J]:=CurChar;
        LastChar:=CurChar;
      end;
    end;
    SetLength(Result, J);
  end;
end;

{$IFDEF V_LONGSTRINGS}
function DecodeCEscapes(const S: String): String;
var
  State: (sNeutral, sWasSlash, sOct, sHex);

  function ConvertToNumber(S: String; var Num: Integer): Boolean;
  var
    I, J, Code: Integer;
  begin
    Result:=False;
    if State = sHex then begin
      Val(S, J, Code);
      if (Code <> 0) or (J > 255) then
        Exit;
    end
    else begin
      J:=0;
      for I:=1 to Length(S) do begin
        Code:=Ord(S[I]) - Ord('0');
        if (Code < 0) or (Code > 7) then
          Exit;
        J:=J * 8 + Code;
        if J > 255 then
          Exit;
      end;
    end;
    Num:=J;
    Result:=True;
  end;

var
  I, J, CharCode: Integer;
  C: Char;
  InP, OutP, InLimit: PChar;
  Number: String;
begin
  I:=CharPos('\', S, 1);
  if I = 0 then
    Result:=S
  else begin
    CharCode:=-1;
    State:=sWasSlash;
    J:=I - 1;
    Result:=Copy(S, 1, J);
    InP:=PChar(Pointer(S)) + I;
    I:=Length(S);
    InLimit:=PChar(Pointer(S)) + I;
    SetLength(Result, I);
    OutP:=PChar(Pointer(Result)) + J;
    while InP < InLimit do begin
      C:=InP^;
      Case State of
        sNeutral: begin
          if C <> '\' then begin
            OutP^:=C;
            Inc(OutP);
          end
          else
            State:=sWasSlash;
          Inc(InP);
        end;
        sWasSlash: begin
          Case C of
            '0'..'7': begin
              Number:=C;
              CharCode:=Ord(C) - Ord('0');
              State:=sOct;
              Inc(InP);
              Continue;
            end;
            'a': C:=#7;
            'b': C:=#8;
            'f': C:=#$0C;
            'n': begin
              OutP^:=#$0D;
              Inc(OutP);
              C:=#$0A;
            end;
            'r': C:=#$0D;
            't': C:=#9;
            'v': C:=#$0B;
            '\', '''', '"', '?': ; // C:=C
            'x': begin
              Number:='$';
              State:=sHex;
              Inc(InP);
              Continue;
            end;
          Else begin
            OutP^:='\';
            Inc(OutP);
          end;
          End;
          OutP^:=C;
          Inc(InP);
          Inc(OutP);
          State:=sNeutral;
        end;
        sOct, sHex: begin
          Number:=Number + C;
          if ConvertToNumber(Number, CharCode) then
            Inc(InP)
          else begin
            if CharCode >= 0 then begin
              OutP^:=Chr(CharCode);
              CharCode:=-1;
            end
            else begin
              OutP^:='\';
              if State = sHex then begin
                Inc(OutP);
                OutP^:='x';
              end;
            end;
            Inc(OutP);
            State:=sNeutral;
          end;
        end;
      End;
    end; {while}
    Case State of
      sOct, sHex:
        if CharCode >= 0 then begin
          OutP^:=Chr(CharCode);
          Inc(OutP);
        end;
      sWasSlash: begin
        OutP^:='\';
        Inc(OutP);
      end;
    End;
    SetLength(Result, OutP - PChar(Pointer(Result)));
  end;
end;

function EncodeCEscapes(const S: String; Only7Bit: Boolean): String;
var
  I, L: Integer;
  C, Slash: Char;
  OutP: PChar;
  Hex: String[2];
begin
  L:=Length(S);
  SetLength(Result, 4 * L);
  OutP:=Pointer(Result);
  I:=1;
  while I <= L do begin
    C:=S[I];
    Case C of
      #7: Slash:='a';
      #8: Slash:='b';
      #9: Slash:='t';
      #$0B: Slash:='v';
      #$0C: Slash:='f';
      #$0D:
        if (I < L) and (S[I + 1] = #$0A) then begin
          Slash:='n';
          Inc(I);
        end
        else
          Slash:='r';
      '\', '''', '"', '?': Slash:=C;
    Else begin
      Slash:=#0;
      if (C < ' ') or Only7Bit and (C >= #128) then
        if C < #8 then
          Slash:=Chr(Ord(C) + Ord('0'))
        else begin
          OutP^:='\';
          Inc(OutP);
          OutP^:='x';
          Inc(OutP);
          Hex:=IntToHex(Ord(C), 0);
          OutP^:=Hex[1];
          Inc(OutP);
          if Length(Hex) > 1 then begin
            OutP^:=Hex[2];
            Inc(OutP);
          end;
        end
      else begin
        OutP^:=C;
        Inc(OutP);
      end;
    end;
    End;
    if Slash <> #0 then begin
      OutP^:='\';
      Inc(OutP);
      OutP^:=Slash;
      Inc(OutP);
    end;
    Inc(I);
  end; {while}
  SetLength(Result, OutP - PChar(Pointer(Result)));
end;
{$ENDIF}

{$IFDEF WIN32}
function WordPos(SubWord, S: String; CaseSensitive: Boolean): Integer;
var
  LSub, LStr: Integer;
  P, PSub, PStr, Limit: PChar;
begin
  Result:=0;
  LSub:=Length(SubWord);
  LStr:=Length(S);
  if (LSub = 0) or (LSub > LStr) then
    Exit;
  if not CaseSensitive then begin
    UniqueString(SubWord);
    CharUpperBuff(Pointer(SubWord), LSub);
    UniqueString(S);
    CharUpperBuff(Pointer(S), LStr);
  end;
  PSub:=Pointer(SubWord);
  PStr:=Pointer(S);
  P:=PStr;
  Limit:=PStr + LStr;
  repeat
    P:=StrPos(P, PSub);
    if P = nil then
      Exit;
    if ((P = PStr) or not IsCharAlphaNumeric((P - 1)^)) and
      ((P + LSub >= Limit) or not IsCharAlphaNumeric((P + LSub)^))
    then
      Break;
    Inc(P);
  until P >= Limit;
  Result:=P - PStr + 1;
end;

function AnsiToOem(const S: String): String;
begin
  SetLength(Result, Length(S));
  if S <> '' then
    CharToOEM(Pointer(S), Pointer(Result));
end;

function OemToAnsi(const S: String): String;
begin
  SetLength(Result, Length(S));
  if S <> '' then
    OemToChar(Pointer(S), Pointer(Result));
end;

procedure AnsiToOemProc(var S: String);
begin
  UniqueString(S);
  CharToOEM(Pointer(S), Pointer(S));
end;

procedure OemToAnsiProc(var S: String);
begin
  UniqueString(S);
  OEMToChar(Pointer(S), Pointer(S));
end;
{$ENDIF}

function IsCorrectIdentifier(const S: String; AcceptIndexes: Boolean): Boolean;
var
  I, J, K, L, M, LT: Integer;
  T, Indexes: String;
begin
  Result:=False;
  if S <> '' then begin
    if S[1] in Digits then
      Exit;
    L:=Length(S);
    if AcceptIndexes then begin
      I:=CharPos('[', S, 1);
      if I > 0 then begin
        if S[L] <> ']' then
          Exit;
        Indexes:=Copy(S, I + 1, L - (I + 1));
        repeat
          J:=CharPos(',', Indexes, 1);
          if J > 0 then
            T:=Copy(Indexes, 1, J - 1)
          else
            T:=Indexes;
          K:=0;
          LT:=Length(T);
          repeat
            Inc(K);
            if K > LT then
              Exit;
          until T[K] <> ' ';
          while (LT > 0) and (T[LT] = ' ') do
            Dec(LT);
          for M:=K to LT do
            if not (T[M] in Digits) then
              Exit;
          if J = 0 then
            Break;
          Delete(Indexes, 1, J);
        until False;
        L:=I - 1;
      end;
    end;
    for I:=1 to L do
      if not (S[I] in ASCIIAlphaNumeric + ['_']) then
        Exit;
    Result:=True;
  end;
end;

function IsCorrectQualifiedIdentifier(S: String; AcceptIndexes: Boolean): Boolean;
var
  I: Integer;
begin
  repeat
    I:=CharPos('.', S, 1);
    if I = 0 then begin
      Result:=IsCorrectIdentifier(S, AcceptIndexes);
      Exit;
    end;
    if not IsCorrectIdentifier(Copy(S, 1, I - 1), AcceptIndexes) then
      Break;
    Delete(S, 1, I);
  until False;
  Result:=False;
end;

function RemoveChar(const S: String; C: Char): String;
var
  L: Integer;
  P1, P2, Limit: PChar;
begin
  L:=Length(S);
  P1:={$IFDEF V_LONGSTRINGS}Pointer(S){$ELSE}@S[1]{$ENDIF};
  SetLength(Result, L);
  P2:={$IFDEF V_LONGSTRINGS}Pointer(Result){$ELSE}@Result[1]{$ENDIF};
  Limit:=P1 + L;
  while P1 < Limit do begin
    if P1^ <> C then begin
      P2^:=P1^;
      Inc(P2);
    end;
    Inc(P1);
  end; {while}
  SetLength(Result,
    {$IFNDEF V_FREEPASCAL}
    P2 - {$IFDEF V_LONGSTRINGS}Pointer(Result){$ELSE}@Result[1]{$ENDIF}
    {$ELSE}
    Cardinal(P2) - Cardinal(Pointer(Result))
    {$ENDIF}
    );
end;

{$IFDEF V_WIDESTRINGS}
function RemoveCharWide(const S: WideString; C: WideChar): WideString;
var
  L: Integer;
  P1, P2, Limit: PWideChar;
begin
  L:=Length(S);
  P1:=Pointer(S);
  SetLength(Result, L);
  P2:=Pointer(Result);
  Limit:=P1 + L;
  while P1 < Limit do begin
    if P1^ <> C then begin
      P2^:=P1^;
      Inc(P2);
    end;
    Inc(P1);
  end; {while}
  SetLength(Result, P2 - Pointer(Result));
end;
{$ENDIF}

function RemoveChars(const S: String; const CharsToRemove: TCharSet): String;
var
  L: Integer;
  P1, P2, Limit: PChar;
begin
  L:=Length(S);
  P1:={$IFDEF V_LONGSTRINGS}Pointer(S){$ELSE}@S[1]{$ENDIF};
  SetLength(Result, L);
  P2:={$IFDEF V_LONGSTRINGS}Pointer(Result){$ELSE}@Result[1]{$ENDIF};
  Limit:=P1 + L;
  while P1 < Limit do begin
    if not (P1^ in CharsToRemove) then begin
      P2^:=P1^;
      Inc(P2);
    end;
    Inc(P1);
  end; {while}
  SetLength(Result,
    {$IFNDEF V_FREEPASCAL}
    P2 - {$IFDEF V_LONGSTRINGS}Pointer(Result){$ELSE}@Result[1]{$ENDIF}
    {$ELSE}
    Cardinal(P2) - Cardinal(Pointer(Result))
    {$ENDIF}
    );
end;

{$IFDEF V_WIDESTRINGS}
function RemoveCharsWide(const S: WideString; const CharsToRemove: TCharSet): WideString;
var
  L: Integer;
  P1, P2, Limit: PWideChar;
begin
  L:=Length(S);
  P1:=Pointer(S);
  SetLength(Result, L);
  P2:=Pointer(Result);
  Limit:=P1 + L;
  while P1 < Limit do begin
    if (P1^ >= #256) or not (PChar(P1)^ in CharsToRemove) then begin
      P2^:=P1^;
      Inc(P2);
    end;
    Inc(P1);
  end; {while}
  SetLength(Result, P2 - Pointer(Result));
end;
{$ENDIF}

function RemoveComment(const S: String; CommentPrefix: Char): String;
var
  I: Integer;
  C: Char;
begin
  if CharPos(CommentPrefix, S, 1) = 0 then
    Result:=Trim(S)
  else begin
    C:=#0;
    for I:=1 to Length(S) do
      if S[I] = CommentPrefix then
        if C = #0 then begin
          Result:=Trim(Copy(S, 1, I - 1));
          Exit;
        end
        else
      else
        if S[I] in ['''', '"'] then
          if C = #0 then
            C:=S[I]
          else
            if C = S[I] then
              C:=#0;
    Result:=Trim(S);
  end;
end;

function FStringToLiteral(const S: String; Quote: Char): String;
var
  I, J, K, N: Integer;
  C: Char;
begin
  I:=CharPos(Quote, S, 1);
  if I = 0 then
    Result:=Quote + S + Quote
  else begin
    Result:=Quote + Copy(S, 1, I) + Quote;
    N:=Length(S);
    SetLength(Result, N + 2 + NumOfChars(Quote, S));
    K:=I + 3;
    for J:=I + 1 to N do begin
      C:=S[J];
      if C = Quote then begin
        Result[K]:=C;
        Inc(K);
      end;
      Result[K]:=C;
      Inc(K);
    end;
    Result[K]:=Quote;
  end;
end;

function StringToLiteral(const S: String): String;
begin
  Result:=FStringToLiteral(S, '''');
end;

function StringToLiteral2(const S: String): String;
begin
  Result:=FStringToLiteral(S, '"');
end;

{$IFDEF V_WIDESTRINGS}
function FWideStringToLiteral(const S: WideString; Quote: WideChar): WideString;
var
  I, J, K, N: Integer;
  C: WideChar;
begin
  I:=WideCharPos(Quote, S, 1);
  if I = 0 then begin
    {$IFDEF V_D4}
    Result:=Quote + S + Quote
    {$ELSE}
    N:=Length(S);
    SetLength(Result, N + 2);
    Result[1]:=Quote;
    for I:=2 to N + 1 do
      Result[I]:=S[I - 1];
    Result[N + 2]:=Quote;
    {$ENDIF}
  end
  else begin
    N:=Length(S);
    {$IFDEF V_D4}
    Result:=Quote + Copy(S, 1, I) + Quote;
    {$ELSE}
    SetLength(Result, I + 2);
    Result[1]:=Quote;
    for J:=2 to I + 1 do
      Result[J]:=S[J - 1];
    Result[I + 2]:=Quote;
    {$ENDIF}
    SetLength(Result, N + 2 + NumOfWideChars(Quote, S));
    K:=I + 3;
    for J:=I + 1 to N do begin
      C:=S[J];
      if C = Quote then begin
        Result[K]:=C;
        Inc(K);
      end;
      Result[K]:=C;
      Inc(K);
    end;
    Result[K]:=Quote;
  end;
end;

function WideStringToLiteral(const S: WideString): WideString;
begin
  Result:=FWideStringToLiteral(S, '''');
end;

function WideStringToLiteral2(const S: WideString): WideString;
begin
  Result:=FWideStringToLiteral(S, '"');
end;
{$ENDIF}

function CheckText(const S: String): Boolean;
var
  I: Integer;
begin
  Result:=False;
  if S <> '' then begin
    for I:=1 to Length(S) do
      if S[I] in [#0..' ', '"', '''', #127..#255] then
        Exit;
    Result:=True;
  end;
end;

{$IFDEF V_WIDESTRINGS}
function CheckWideText(const W: WideString): Boolean;
var
  I: Integer;
  C: WideChar;
begin
  Result:=False;
  if W <> '' then begin
    for I:=1 to Length(W) do begin
      C:=W[I];
      if (C <= ' ') or (C = '"') or (C = '''') then
        Exit;
    end;
    Result:=True;
  end;
end;
{$ENDIF}

function TextToLiteral(const S: String): String;
begin
  if not CheckText(S) then
    Result:=StringToLiteral(S)
  else
    Result:=S;
end;

{$IFDEF V_WIDESTRINGS}
function WideTextToLiteral(const S: WideString): WideString;
begin
  if not CheckWideText(S) then
    Result:=WideStringToLiteral(S)
  else
    Result:=S;
end;
{$ENDIF}

function TextToLiteral2(const S: String): String;
begin
  if not CheckText(S) then
    Result:=StringToLiteral2(S)
  else
    Result:=S;
end;

{$IFDEF V_WIDESTRINGS}
function WideTextToLiteral2(const S: WideString): WideString;
begin
  if not CheckWideText(S) then
    Result:=WideStringToLiteral2(S)
  else
    Result:=S;
end;
{$ENDIF}

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function LiteralToString(const S: String): String;
var
  I, J, N: Integer;
  Quote, C: Char;
begin
  N:=Length(S);
  if N >= 2 then begin
    if (S[1] = '''') and (S[N] = '''') then
      Quote:=''''
    else if (S[1] = '"') and (S[N] = '"') then
      Quote:='"'
    else begin
      Result:=S;
      Exit;
    end;
    Dec(N);
    SetLength(Result, N - 1);
    I:=2;
    J:=0;
    while I <= N do begin
      C:=S[I];
      Inc(J);
      Result[J]:=C;
      Inc(I);
      if (C = Quote) and ((I > N) or (S[I] = Quote)) then
        Inc(I);
    end;
    SetLength(Result, J);
  end
  else
    Result:=S;
end;

{$IFDEF V_WIDESTRINGS}
function LiteralToWideString(const S: WideString): WideString;
var
  I, J, N: Integer;
  Quote, C: WideChar;
begin
  N:=Length(S);
  if N >= 2 then begin
    if (S[1] = '''') and (S[N] = '''') then
      Quote:=''''
    else if (S[1] = '"') and (S[N] = '"') then
      Quote:='"'
    else begin
      Result:=S;
      Exit;
    end;
    Dec(N);
    SetLength(Result, N - 1);
    I:=2;
    J:=0;
    while I <= N do begin
      C:=S[I];
      Inc(J);
      Result[J]:=C;
      Inc(I);
      if (C = Quote) and ((I > N) or (S[I] = Quote)) then
        Inc(I);
    end;
    SetLength(Result, J);
  end
  else
    Result:=S;
end;
{$ENDIF}
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

function GetValueByName(const S, Name: String; var Value: String;
  CaseSensitive: Boolean; const QuoteChars: TCharSet): Boolean;
var
  QuoteChar: Char;
  Valid: Boolean;
  ParamName: String;
  ReadState: (rsWaitName, rsName, rsWaitEqualSign, rsWaitValue, rsValue);

  procedure StateReadName(C: Char);
  begin
    ReadState:=rsName;
    if C in QuoteChars then begin
      ReadState:=rsValue;
      QuoteChar:=C;
      Valid:=False;
    end
    else
      ParamName:=C;
  end;

  function AnalyzeName: Boolean;
  begin
    if Valid then
      if CaseSensitive then
        Result:=CompareStr(ParamName, Name) = 0
      else
        Result:=CompareText(ParamName, Name) = 0
    else
      Result:=False;
    Valid:=True;
  end;

var
  C: Char;
  P, Limit: PChar;
begin
  Result:=True;
  Valid:=True;
  {$IFDEF V_LONGSTRINGS}
  P:=PChar(S);
  {$ELSE}
  P:=@S[1];
  {$ENDIF}
  Limit:=P + Length(S);
  {$IFNDEF V_AUTOINITSTRINGS}
  ParamName:='';
  {$ENDIF}
  ReadState:=rsWaitName;
  while P < Limit do begin
    C:=P^;
    Case ReadState of
      rsWaitName:
        if C > ' ' then
          StateReadName(C);
      rsName:
        if C > ' ' then
          if C = '=' then
            ReadState:=rsWaitValue
          else
            if Valid then
              ParamName:=ParamName + C
            else
        else
          ReadState:=rsWaitEqualSign;
      rsWaitEqualSign:
        if C > ' ' then
          if C = '=' then
            ReadState:=rsWaitValue
          else begin
            if AnalyzeName then
              Exit;
            StateReadName(C);
          end;
      rsWaitValue:
        if C > ' ' then begin
          if C in QuoteChars then begin
            QuoteChar:=C;
            Value:='';
          end
          else begin
            QuoteChar:=#0;
            Value:=C;
          end;
          ReadState:=rsValue;
        end;
      rsValue: begin
        if QuoteChar <> #0 then
          if C = QuoteChar then begin
            ReadState:=rsWaitName;
            QuoteChar:=#0;
          end
          else
        else
          if C <= ' ' then
            ReadState:=rsWaitName;
        if ReadState = rsWaitName then
          if AnalyzeName then
            Exit
          else
        else
          if Valid then
            Value:=Value + C;
      end;
    End;
    Inc(P);
  end; {while}
  if (ReadState = rsValue) and AnalyzeName then
    Exit;
  Result:=False;
end;

{$IFDEF V_WIDESTRINGS}{$IFDEF V_D4}{$IFNDEF V_D6}
procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const);
begin
  raise EConvertError.CreateFmt(LoadResString(ResString), Args);
end;

procedure FormatError(ErrorCode: Integer; Format: PChar; FmtLen: Cardinal);
var
  ResStr: PResStringRec;
  Buffer: array[0..31] of Char;
begin
  if FmtLen > 31 then
    FmtLen:=31;
  if StrByteType(Format, FmtLen-1) = mbLeadByte then
    Dec(FmtLen);
  StrMove(Buffer, Format, FmtLen);
  Buffer[FmtLen]:=#0;
  if ErrorCode = 0 then
    ResStr:=@SInvalidFormat
  else
    ResStr:=@SArgumentMissing;
  ConvertErrorFmt(ResStr, [PChar(@Buffer)]);
end;

procedure WideFormatError(ErrorCode: Integer; Format: PWideChar; FmtLen: Cardinal);
var
  WideFormat: WideString;
  FormatText: string;
begin
  SetLength(WideFormat, FmtLen);
  SetString(WideFormat, Format, FmtLen);
  FormatText := WideFormat;
  FormatError(ErrorCode, PChar(FormatText), FmtLen);
end;

{$IFDEF PACKAGE}
function FWideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; CurrencyDecimals: Byte; const Args: array of const): Cardinal;
{$ELSE}
function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
{$ENDIF}
var
  ArgIndex, Width, Prec: Integer;
  BufferOrg, FormatOrg, FormatPtr: PWideChar;
  JustFlag: WideChar;
  StrBuf: array[0..64] of WideChar;
  TempWideStr: WideString;
  TempInt64 : Int64;
  SaveGOT: Integer;
{ in: eax <-> Buffer }
{ in: edx <-> BufLen }
{ in: ecx <-> Format }

asm
        PUSH    EBX
        PUSH    ESI
        PUSH    EDI
        MOV     EDI,EAX
        MOV     ESI,ECX
{$IFDEF PIC}
        CALL    GetGOT
{$ELSE}
        XOR     EAX,EAX
{$ENDIF}
        MOV     SaveGOT,EAX
        MOV     ECX,FmtLen
        LEA     ECX,[ECX*2+ESI]
        MOV     BufferOrg,EDI
        XOR     EAX,EAX
        MOV     ArgIndex,EAX
        MOV     TempWideStr,EAX

@Loop:
        OR      EDX,EDX
        JE      @Done

@NextChar:
        CMP     ESI,ECX
        JE      @Done
        LODSW
        CMP     AX,'%'
        JE      @Format

@StoreChar:
        STOSW
        DEC     EDX
        JNE     @NextChar

@Done:
        MOV     EAX,EDI
        SUB     EAX,BufferOrg
        SHR     EAX,1
        JMP     @Exit

@Format:
        CMP     ESI,ECX
        JE      @Done
        LODSW
        CMP     AX,'%'
        JE      @StoreChar
        LEA     EBX,[ESI-4]
        MOV     FormatOrg,EBX
@A0:    MOV     JustFlag,AX
        CMP     AX,'-'
        JNE     @A1
        CMP     ESI,ECX
        JE      @Done
        LODSW
@A1:    CALL    @Specifier
        CMP     AX,':'
        JNE     @A2
        MOV     ArgIndex,EBX
        CMP     ESI,ECX
        JE      @Done
        LODSW
        JMP     @A0

@A2:    MOV     Width,EBX
        MOV     EBX,-1
        CMP     AX,'.'
        JNE     @A3
        CMP     ESI,ECX
        JE      @Done
        LODSW
        CALL    @Specifier
@A3:    MOV     Prec,EBX
        MOV     FormatPtr,ESI
        PUSH    ECX
        PUSH    EDX

        CALL    @Convert

        POP     EDX
        MOV     EBX,Width
        SUB     EBX,ECX        //(* ECX <=> number of characters output *)
        JAE     @A4            //(*         jump -> output smaller than width *)
        XOR     EBX,EBX

@A4:    CMP     JustFlag,'-'
        JNE     @A6
        SUB     EDX,ECX
        JAE     @A5
        ADD     ECX,EDX
        XOR     EDX,EDX

@A5:    REP     MOVSW

@A6:    XCHG    EBX,ECX
        SUB     EDX,ECX
        JAE     @A7
        ADD     ECX,EDX
        XOR     EDX,EDX
@A7:    MOV     AX,' '
        REP     STOSW
        XCHG    EBX,ECX
        SUB     EDX,ECX
        JAE     @A8
        ADD     ECX,EDX
        XOR     EDX,EDX
@A8:    REP     MOVSW
        POP     ECX
        MOV     ESI,FormatPtr
        JMP     @Loop

@Specifier:
        XOR     EBX,EBX
        CMP     AX,'*'
        JE      @B3
@B1:    CMP     AX,'0'
        JB      @B5
        CMP     AX,'9'
        JA      @B5
        IMUL    EBX,EBX,10
        SUB     AX,'0'
        MOVZX   EAX,AX
        ADD     EBX,EAX
        CMP     ESI,ECX
        JE      @B2
        LODSW
        JMP     @B1
@B2:    POP     EAX
        JMP     @Done
@B3:    MOV     EAX,ArgIndex
        CMP     EAX,Args.Integer[-4]
        JA      @B4
        INC     ArgIndex
        MOV     EBX,Args
        CMP     [EBX+EAX*8].Byte[4],vtInteger
        MOV     EBX,[EBX+EAX*8]
        JE      @B4
        XOR     EBX,EBX
@B4:    CMP     ESI,ECX
        JE      @B2
        LODSW
@B5:    RET

@Convert:
        AND     AL,0DFH
        MOV     CL,AL
        MOV     EAX,1
        MOV     EBX,ArgIndex
        CMP     EBX,Args.Integer[-4]
        JA      @ErrorExit
        INC     ArgIndex
        MOV     ESI,Args
        LEA     ESI,[ESI+EBX*8]
        MOV     EAX,[ESI].Integer[0]       // TVarRec.data
        MOVZX   EDX,[ESI].Byte[4]          // TVarRec.VType
{$IFDEF PIC}
        MOV     EBX, SaveGOT
        ADD     EBX, offset @CvtVector
        MOV     EBX, [EBX+EDX*4]
        ADD     EBX, SaveGOT
        JMP     EBX
{$ELSE}
        JMP     @CvtVector.Pointer[EDX*4]
{$ENDIF}

@CvtVector:
        DD      @CvtInteger                // vtInteger
        DD      @CvtBoolean                // vtBoolean
        DD      @CvtChar                   // vtChar
        DD      @CvtExtended               // vtExtended
        DD      @CvtShortStr               // vtString
        DD      @CvtPointer                // vtPointer
        DD      @CvtPChar                  // vtPChar
        DD      @CvtObject                 // vtObject
        DD      @CvtClass                  // vtClass
        DD      @CvtWideChar               // vtWideChar
        DD      @CvtPWideChar              // vtPWideChar
        DD      @CvtAnsiStr                // vtAnsiString
        DD      @CvtCurrency               // vtCurrency
        DD      @CvtVariant                // vtVariant
        DD      @CvtInterface              // vtInterface
        DD      @CvtWideString             // vtWideString
        DD      @CvtInt64                  // vtInt64

@CvtBoolean:
@CvtObject:
@CvtClass:
@CvtInterface:
@CvtError:
        XOR     EAX,EAX

@ErrorExit:
        CALL    @ClearTmpWideStr
        MOV     EDX,FormatOrg
        MOV     ECX,FormatPtr
        SUB     ECX,EDX
        SHR     ECX,1
        MOV     EBX, SaveGOT
{$IFDEF PC_MAPPED_EXCEPTIONS}
        //  Because of all the assembly code here, we can't call a routine
        //  that throws an exception if it looks like we're still on the
        //  stack.  The static disassembler cannot give sufficient unwind
        //  frame info to unwind the confusion that is generated from the
        //  assembly code above.  So before we throw the exception, we
        //  go to some lengths to excise ourselves from the stack chain.
        //  We were passed 12 bytes of parameters on the stack, and we have
        //  to make sure that we get rid of those, too.
        MOV     ESP, EBP        // Ditch everthing to the frame
        MOV     EBP, [ESP + 4]  // Get the return addr
        MOV     [ESP + 16], EBP // Move the ret addr up in the stack
        POP     EBP             // Ditch the rest of the frame
        ADD     ESP, 12         // Ditch the space that was taken by params
        JMP     WideFormatError // Off to FormatErr
{$ELSE}
        CALL    WideFormatError
{$ENDIF}
        // The above call raises an exception and does not return

@CvtInt64:
        // CL  <= format character
        // EAX <= address of int64
        // EBX <= TVarRec.VType

        LEA     EBX, TempInt64       // (input is array of const; save original)
        MOV     EDX, [EAX]
        MOV     [EBX], EDX
        MOV     EDX, [EAX + 4]
        MOV     [EBX + 4], EDX

        // EBX <= address of TempInt64

        CMP     CL,'D'
        JE      @DecI64
        CMP     CL,'U'
        JE      @DecI64_2
        CMP     CL,'X'
        JNE     @CvtError

@HexI64:
        MOV     ECX,16               // hex divisor
        JMP     @CvtI64

@DecI64:
        TEST    DWORD PTR [EBX + 4], $80000000      // sign bit set?
        JE      @DecI64_2            //   no -> bypass '-' output

        NEG     DWORD PTR [EBX]      // negate lo-order, then hi-order
        ADC     DWORD PTR [EBX+4], 0
        NEG     DWORD PTR [EBX+4]

        CALL    @DecI64_2

        MOV     AX,'-'
        INC     ECX
        INC     ECX
        DEC     ESI
        DEC     ESI
        MOV     [ESI],AX
        RET

@DecI64_2:                           // unsigned int64 output
        MOV     ECX,10               // decimal divisor

@CvtI64:
        LEA     ESI,StrBuf[64]

@CvtI64_1:
        PUSH    EBX
        PUSH    ECX                  // save radix
        PUSH    0
        PUSH    ECX                  // radix divisor (10 or 16 only)
        MOV     EAX, [EBX]
        MOV     EDX, [EBX + 4]
        MOV     EBX, SaveGOT
        CALL    System.@_llumod
        POP     ECX                  // saved radix
        POP     EBX

        XCHG    EAX, EDX             // lo-value to EDX for character output
        ADD     DX,'0'
        CMP     DX,'0'+10
        JB      @CvtI64_2

        ADD     DX,('A'-'0')-10

@CvtI64_2:
        DEC     ESI
        DEC     ESI
        MOV     [ESI],DX

        PUSH    EBX
        PUSH    ECX                  // save radix
        PUSH    0
        PUSH    ECX                  // radix divisor (10 or 16 only)
        MOV     EAX, [EBX]           // value := value DIV radix
        MOV     EDX, [EBX + 4]
        MOV     EBX, SaveGOT
        CALL    System.@_lludiv
        POP     ECX                  // saved radix
        POP     EBX
        MOV     [EBX], EAX
        MOV     [EBX + 4], EDX
        OR      EAX,EDX              // anything left to output?
        JNE     @CvtI64_1            //   no jump => EDX:EAX = 0

        LEA     ECX,StrBuf[64]
        SUB     ECX,ESI
        SHR     ECX,1
        MOV     EDX,Prec
        CMP     EDX,16
        JBE     @CvtI64_3
        RET

@CvtI64_3:
        SUB     EDX,ECX
        JBE     @CvtI64_5
        ADD     ECX,EDX
        MOV     AX,'0'

@CvtI64_4:
        DEC     ESI
        DEC     ESI
        MOV     [ESI],AX
        DEC     EDX
        JNE     @CvtI64_4

@CvtI64_5:
        RET
////////////////////////////////////////////////

@CvtInteger:
        CMP     CL,'D'
        JE      @C1
        CMP     CL,'U'
        JE      @C2
        CMP     CL,'X'
        JNE     @CvtError
        MOV     ECX,16
        JMP     @CvtLong
@C1:    OR      EAX,EAX
        JNS     @C2
        NEG     EAX
        CALL    @C2
        MOV     AX,'-'
        INC     ECX
        DEC     ESI
        DEC     ESI
        MOV     [ESI],AX
        RET
@C2:    MOV     ECX,10

@CvtLong:
        LEA     ESI,StrBuf[32]
@D1:    XOR     EDX,EDX
        DIV     ECX
        ADD     EDX,'0'
        CMP     EDX,'0'+10
        JB      @D2
        ADD     EDX,('A'-'0')-10
@D2:    DEC     ESI
        DEC     ESI
        MOV     [ESI],DX
        OR      EAX,EAX
        JNE     @D1
        LEA     ECX,StrBuf[32]
        SUB     ECX,ESI
        SHR     ECX,1
        MOV     EDX,Prec
        CMP     EDX,16
        JBE     @D3
        RET
@D3:    SUB     EDX,ECX
        JBE     @D5
        ADD     ECX,EDX
        MOV     AX,'0'
@D4:    DEC     ESI
        DEC     ESI
        MOV     [ESI],AX
        DEC     EDX
        JNE     @D4
@D5:    RET

@CvtChar:
        CMP     CL,'S'
        JNE     @CvtError
        MOV     EAX,ESI
        MOV     ECX,1
        JMP     @CvtAnsiThingLen

@CvtWideChar:
        CMP     CL,'S'
        JNE     @CvtError
        MOV     ECX,1
        RET

@CvtVariant:
        CMP     CL,'S'
        JNE     @CvtError
        CMP     [EAX].TVarData.VType,varNull
        JBE     @CvtEmptyStr
        MOV     EDX,EAX
        LEA     EAX,TempWideStr
        PUSH    EBX
        MOV     EBX, SaveGOT
        CALL    System.@VarToWStr
        POP     EBX
        MOV     ESI,TempWideStr
        JMP     @CvtWideStrRef

@CvtEmptyStr:
        XOR     ECX,ECX
        RET

@CvtShortStr:
        CMP     CL,'S'
        JNE     @CvtError
        MOVZX   ECX,BYTE PTR [EAX]
        INC     EAX

@CvtAnsiThingLen:
        MOV     ESI,OFFSET System.@WStrFromPCharLen
        JMP     @CvtAnsiThing

@CvtPChar:
        MOV    ESI,OFFSET System.@WStrFromPChar
        JMP    @CvtAnsiThingTest

@CvtAnsiStr:
        MOV    ESI,OFFSET System.@WStrFromLStr

@CvtAnsiThingTest:
        CMP    CL,'S'
        JNE    @CvtError

@CvtAnsiThing:
        ADD    ESI, SaveGOT
        MOV    EDX,EAX
        LEA    EAX,TempWideStr
        PUSH   EBX
        MOV    EBX, SaveGOT
        CALL   ESI
        POP    EBX
        MOV    ESI,TempWideStr
        JMP    @CvtWideStrRef

@CvtWideString:
        CMP     CL,'S'
        JNE     @CvtError
        MOV     ESI,EAX

@CvtWideStrRef:
        OR      ESI,ESI
        JE      @CvtEmptyStr
        MOV     ECX,[ESI-4]
        SHR     ECX,1

@CvtWideStrLen:
        CMP     ECX,Prec
        JA      @E1
        RET
@E1:    MOV     ECX,Prec
        RET

@CvtPWideChar:
        CMP     CL,'S'
        JNE     @CvtError
        MOV     ESI,EAX
        PUSH    EDI
        MOV     EDI,EAX
        XOR     EAX,EAX
        MOV     ECX,Prec
        JECXZ   @F1
        REPNE   SCASW
        JNE     @F1
        DEC     EDI
        DEC     EDI
@F1:    MOV     ECX,EDI
        SUB     ECX,ESI
        SHR     ECX,1
        POP     EDI
        RET

@CvtPointer:
        CMP     CL,'P'
        JNE     @CvtError
        MOV     Prec,8
        MOV     ECX,16
        JMP     @CvtLong

@CvtCurrency:
        MOV     BH,fvCurrency
        JMP     @CvtFloat

@CvtExtended:
        MOV     BH,fvExtended

@CvtFloat:
        MOV     ESI,EAX
        MOV     BL,ffGeneral
        CMP     CL,'G'
        JE      @G2
        MOV     BL,ffExponent
        CMP     CL,'E'
        JE      @G2
        MOV     BL,ffFixed
        CMP     CL,'F'
        JE      @G1
        MOV     BL,ffNumber
        CMP     CL,'N'
        JE      @G1
        CMP     CL,'M'
        JNE     @CvtError
        MOV     BL,ffCurrency
@G1:    MOV     EAX,18
        MOV     EDX,Prec
        CMP     EDX,EAX
        JBE     @G3
        MOV     EDX,2
        CMP     CL,'M'
        JNE     @G3
        MOVZX   EDX,CurrencyDecimals
        JMP     @G3
@G2:    MOV     EAX,Prec
        MOV     EDX,3
        CMP     EAX,18
        JBE     @G3
        MOV     EAX,15
@G3:    PUSH    EBX
        PUSH    EAX
        PUSH    EDX
        LEA     EAX,StrBuf
        MOV     EDX,ESI
        MOVZX   ECX,BH
        MOV     EBX, SaveGOT
        CALL    FloatToText
        MOV     ECX,EAX
        LEA     EAX,StrBuf
        JMP     @CvtAnsiThingLen

@ClearTmpWideStr:
        PUSH    EBX
        PUSH    EAX
        LEA     EAX,TempWideStr
        MOV     EBX, SaveGOT
        CALL    System.@WStrClr
        POP     EAX
        POP     EBX
        RET

@Exit:
        CALL    @ClearTmpWideStr
        POP     EDI
        POP     ESI
        POP     EBX
end;

{$IFDEF PACKAGE}
function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
begin
  Result:=FWideFormatBuf(Buffer, BufLen, Format, FmtLen, CurrencyDecimals, Args);
end;
{$ENDIF}

procedure WideFmtStr(var Result: WideString; const Format: WideString;
  const Args: array of const);
var
  Len, BufLen: Integer;
  Buffer: array[0..4095] of WideChar;
begin
  BufLen := SizeOf(Buffer);
  if Length(Format) < (sizeof(Buffer) - (sizeof(Buffer) div 4)) then
    Len := WideFormatBuf(Buffer, sizeof(Buffer) - 1, Pointer(Format)^, Length(Format), Args)
  else
  begin
    BufLen := Length(Format);
    Len := BufLen;
  end;
  if Len >= BufLen - 1 then
  begin
    while Len >= BufLen - 1 do
    begin
      Inc(BufLen, BufLen);
      Result := '';          // prevent copying of existing data, for speed
      SetLength(Result, BufLen);
      Len := WideFormatBuf(Pointer(Result)^, BufLen - 1, Pointer(Format)^,
        Length(Format), Args);
    end;
    SetLength(Result, Len);
  end
  else
    SetString(Result, Buffer, Len);
end;

function WideFormat(const Format: WideString; const Args: array of const): WideString;
begin
  WideFmtStr(Result, Format, Args);
end;
{$ENDIF}{$ENDIF}{$ENDIF}

{$IFDEF V_D4}
function IntToStrSeparated(Value: Int64): String;
var
  I, C: Integer;
  S: String;
begin
  S:=IntToStr(Value);
  Result:='';
  C:=0;
  for I:=Length(S) downto 1 do begin
    if C = 3 then begin
      Result:=ThousandSeparator + Result;
      C:=0;
    end;
    Result:=S[I] + Result;
    Inc(C);
  end;
end;
{$ENDIF}

function IntToRoman(N: Integer): String;
const
  T_s: array [0..5] of String = ('','M','MM','MMM','MMMM','MMMMM');
  S_s: array [0..9] of String = ('','C','CC','CCC','CD','D','DC','DCC','DCCC','CM');
  D_s: array [0..9] of String = ('','X','XX','XXX','XL','L','LX','LXX','LXXX','XC');
  E_s: array [0..9] of String = ('','I','II','III','IV','V','VI','VII','VIII','IX');
var
  T, S, D: Integer;
begin
  if (N >= 1) and (N <= 5000) then begin
    T:=0;
    while N >= 1000 do begin
      Dec(N, 1000);
      Inc(T);
    end;
    S:=0;
    if N >= 500 then begin
      Dec(N, 500);
      S:=5;
    end;
    while N >= 100 do begin
      Dec(N, 100);
      Inc(S);
    end;
    D:=0;
    if N >= 50 then begin
      Dec(N, 50);
      D:=5;
    end;
    while N >= 10 do begin
      Dec(N, 10);
      Inc(D);
    end;
    Result:=T_s[T] + S_s[S] + D_s[D] + E_s[N];
  end
  else
    Result:='';
end;

function ValOctPChar(P: PChar; L: Integer; var Value: Integer): Boolean;
var
  N: Integer;
begin
  Value:=0;
  if L = 0 then begin
    Result:=False;
    Exit;
  end;
  while L > 0 do begin
    N:=Ord(P^) - Ord('0');
    if (N < 0) or (N > 7) then begin
      Result:=False;
      Exit;
    end;
    Value:=Value * 8 + N;
    Inc(P);
    Dec(L);
  end;
  Result:=True;
end;

function ValOctStr(const S: String; var Value: Integer): Boolean;
begin
  Result:=ValOctPChar({$IFDEF V_LONGSTRINGS}Pointer(S){$ELSE}@S[1]{$ENDIF},
    Length(S), Value);
end;

function OctToInt(P: PChar; MaxLen: Integer; var Value: Integer): Boolean;
var
  I, J: Integer;
begin
  while (MaxLen > 0) and (P^ = ' ') do begin
    Dec(MaxLen);
    Inc(P);
  end; {while}
  if MaxLen <= 0 then begin
    Result:=False;
    Exit;
  end;
  I:=IndexOfValue8(P^, 0, MaxLen);
  if I < 0 then
    I:=MaxLen;
  J:=IndexOfValue8(P^, Ord(' '), MaxLen);
  if J < 0 then
    J:=MaxLen;
  if I > J then
    I:=J;
  Result:=ValOctPChar(P, I, Value);
end;

function CmpStrF(const S1, S2: String; Flags: LongInt): Integer;
begin
{$IFDEF V_WIN}
{$IFDEF V_LONGSTRINGS}
  if Flags = 0 then
    Result:=CompareStr(S1, S2)
  else
    Result:=CompareString(Flags and LocaleMask, Flags and FlagsMask, Pointer(S1),
      Length(S1), Pointer(S2), Length(S2)) - 2;
{$ELSE}
   if Flags and LocaleMask <> 0 then
     if Flags and iCaseInsensitive <> 0 then
       Result:=AnsiCompareText(S1, S2)
     else
       Result:=AnsiCompareStr(S1, S2)
   else
     if Flags and iCaseInsensitive <> 0 then
       Result:=CompareText(S1, S2)
     else
       Result:=CompareStr(S1, S2)
{$ENDIF}
{$ELSE}
   if Flags and LocaleMask <> 0 then
     if Flags and iCaseInsensitive <> 0 then
       Result:=AnsiCompareText(S1, S2)
     else
       Result:=AnsiCompareStr(S1, S2)
   else
     if Flags and iCaseInsensitive <> 0 then
       Result:=CompareText(S1, S2)
     else
       Result:=CompareStr(S1, S2)
{$ENDIF}
end;

{$IFDEF V_WIDESTRINGS}
{$IFNDEF USE_ASM}
function WStrCmp(PLeft, PRight: PWideChar): Integer;
begin
  Result:=CompareWide(WideString(PLeft), WideString(PRight));
end;

function CompareWide(const Left, Right: WideString): Integer;
begin
  if Left < Right then
    Result:=-1
  else if Left > Right then
    Result:=1
  else Result:=0;
end;
{$ELSE}
function WStrCmp(PLeft, PRight: PWideChar): Integer;
asm     // eax = PLeft; edx = PRight
        {$IFDEF V_FREEPASCAL}
        mov      edx, PRight
        {$ENDIF}
        push     esi
        xor      ecx, ecx
        mov      esi, PLeft
        xor      eax, eax
        cmp      esi, edx
        je       @@Exit
        or       esi, esi
        jz       @@str1null
        or       edx, edx
        jz       @@str2null
@@Loop: // unrolled to improve efficiency
        lodsw
        mov      cx, [edx]
        sub      eax, ecx
        jnz      @@Exit
        add      edx, 2
        or       ecx, ecx
        jz       @@Exit
        lodsw
        mov      cx, [edx]
        sub      eax, ecx
        jnz      @@Exit
        add      edx, 2
        or       ecx, ecx
        jz       @@Exit
        lodsw
        mov      cx, [edx]
        sub      eax, ecx
        jnz      @@Exit
        add      edx, 2
        or       ecx, ecx
        jz       @@Exit
        lodsw
        mov      cx, [edx]
        sub      eax, ecx
        jnz      @@Exit
        add      edx, 2
        or       ecx, ecx
        jnz      @@Loop
@@Exit:
        pop      esi
        ret
@@str1null:
        cmp      word ptr [edx], 0
        je       @@Exit
        dec      eax
        jmp      @@Exit
@@str2null:
        cmp      word ptr [esi], 0
        je       @@Exit
        inc      eax
        jmp      @@Exit
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

function CompareWide(const Left, Right: WideString): Integer;
begin
  Result:=WStrCmp(PWideChar(Left), PWideChar(Right));
end;
{$ENDIF} {USE_ASM}

function CompareStrBufWide(PW1, PW2: PWideChar; Count1, Count2: Integer): Integer;
var
  I, L, Delta: Integer;
begin
  L:=Count1;
  Delta:=Count1 - Count2;
  if Delta > 0 then L:=Count2;
  for I:=0 to L - 1 do begin
    Result:=Integer(PW1^) - Integer(PW2^);
    if Result <> 0 then Exit;
    Inc(PW1);
    Inc(PW2);
  end;
  Result:=Delta;
end;

function CompareStrWide(const W1, W2: WideString): Integer;
begin
  Result:=CompareStrBufWide(PWideChar(W1), PWideChar(W2), Length(W1), Length(W2));
end;
{$ENDIF} {V_WIDESTRINGS}

function CompareStrBuf(P1, P2: PChar; Count1, Count2: Integer): Integer;
var
  I, L, Delta: Integer;
begin
  L:=Count1;
  Delta:=Count1 - Count2;
  if Delta > 0 then
    L:=Count2;
  for I:=0 to L - 1 do begin
    Result:=Ord(P1^) - Ord(P2^);
    if Result <> 0 then
      Exit;
    Inc(P1);
    Inc(P2);
  end;
  Result:=Delta;
end;

function CompareTextBuf(P1, P2: PChar; Count1, Count2: Integer): Integer;
var
  I, L, C1, C2, Delta: Integer;
begin
  L:=Count1;
  Delta:=Count1 - Count2;
  if Delta > 0 then
    L:=Count2;
  for I:=0 to L - 1 do begin
    C1:=Ord(P1^);
    C2:=Ord(P2^);
    if (C1 >= Ord('A')) and (C1 <= Ord('Z')) then
      Inc(C1, Ord('a') - Ord('A'));
    if (C2 >= Ord('A')) and (C2 <= Ord('Z')) then
      Inc(C2, Ord('a') - Ord('A'));
    Result:=C1 - C2;
    if Result <> 0 then
      Exit;
    Inc(P1);
    Inc(P2);
  end;
  Result:=Delta;
end;

function MemEqualStr(const X; const S: String): Boolean;
begin
  Result:=MemEqual(X, {$IFDEF V_LONGSTRINGS}Pointer(S)^{$ELSE}S[1]{$ENDIF}, Length(S));
end;

function CompareVersions(Ver1, Ver2: String; pError: PBoolean): Integer;

  function GetPart(var Ver: String; var N: Integer): Boolean;
  var
    I, Code: Integer;
    S: String;
  begin
    N:=0;
    I:=CharPos('.', Ver, 1);
    if I > 0 then begin
      S:=Copy(Ver, 1, I - 1);
      Delete(Ver, 1, I);
    end
    else begin
      S:=Ver;
      Ver:='';
    end;
    if S <> '' then begin
      Val(S, N, Code);
      if (Code <> 0) or (N < 0) then begin
        Result:=False;
        Exit;
      end;
    end;
    Result:=True;
  end;

var
  N1, N2: Integer;
  Error: Boolean;
begin
  Result:=0;
  Error:=False;
  repeat
    if not (GetPart(Ver1, N1) and GetPart(Ver2, N2)) then begin
      Error:=True;
      Break;
    end;
    Result:=N1 - N2;
    if Result <> 0 then
      Break;
  until (Ver1 = '') and (Ver2 = '');
  if pError <> nil then
    Boolean(pError^):=Error; { Boolean(...) is for Free Pascal }
end;

end.
