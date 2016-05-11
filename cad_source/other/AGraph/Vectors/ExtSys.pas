{ Version 050702. Copyright © Alexey A.Chernobaev, 2000-5 }

unit ExtSys;

interface

{$I VCheck.inc}
{$IFDEF V_D3}{$WRITEABLECONST ON}{$ENDIF}
{$IFDEF CLR}{$UNSAFECODE ON}{$ENDIF}

uses
  {$IFDEF V_WIN32}{$ENDIF}
  {$IFDEF LINUX}{$IFDEF V_DELPHI}Libc{$ELSE}Linux{$ENDIF},{$ENDIF}
  SysUtils, {$IFDEF V_D4}SysConst, {$ENDIF}ExtType, VectErr, Windows;

const
  DefaultBufferSize = {$IFDEF V_32}32768{$ELSE}16384{$ENDIF};

  DefaultDateTime = 29221.000694; { 1/1/80 12:01 am }
  DefaultFileTimeLo = 93518240;
  DefaultFileTimeHi = 27846560; { 1/1/80 12:01 am }

  MemoryReserve: UInt32 = 1048576; { 1 Mb }

  {$IFDEF DYNAMIC_NLS}
  DLLName = 'NPNLS2.DLL'; // function indexes reserved for ExtSys: 301-399
  {$IFDEF V_D6}{$WARN SYMBOL_PLATFORM OFF}{$ENDIF}
  {$ENDIF} {DYNAMIC_NLS}

{$IFDEF LINUX}
type
  PFileTime = ^TFileTime;
  TFileTime = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;
{$ENDIF} {LINUX}

type
  EVStream = class(Exception);

  EVFileStream = class(EVStream)
    Code, LastOSError: Integer;
    RaisedByClass, SimpleMessage: String;
    FileName, ParamStr: {$IFDEF W_STREAM}WideString{$ELSE}String{$ENDIF};
    constructor CreateEx(const AMsg: String;
      const AFileName, AParamStr: {$IFDEF W_STREAM}WideString{$ELSE}String{$ENDIF};
      const ASimpleMessage: String; ACode, ALastOSError: Integer);
    {$IFDEF V_32}
    function FormatErrorMessage: String;
    {$ENDIF}
  end;

  {$IFDEF V_32}
  WideException = class(Exception)
    WideMessage: WideString;
    constructor CreateW(const Msg: WideString);
  end;
  {$ENDIF} {V_32}

{$IFDEF V_DELPHI}
  {$IFNDEF V_D6}
  {$IFDEF WIN32}
  EOSError = EWin32Error;
  {$ENDIF} {WIN32}
const
  PathDelim = {$IFDEF LINUX}'/'{$ELSE}'\'{$ENDIF};
  DriveDelim = {$IFDEF LINUX}''{$ELSE}':'{$ENDIF};
  PathSep = {$IFDEF LINUX}':'{$ELSE}';'{$ENDIF};
  {$ENDIF} {V_D6}
{$ENDIF} {V_DELPHI}

function IntMin(A, B: Integer): Integer; {$IFDEF V_INLINE}inline;{$ENDIF}
{ Result:=min(A, B) }

function IntMax(A, B: Integer): Integer; {$IFDEF V_INLINE}inline;{$ENDIF}
{ Result:=max(A, B) }

function FloatMin(A, B: Float): Float; {$IFDEF V_INLINE}inline;{$ENDIF}
{ Result:=min(A, B) }

function FloatMax(A, B: Float): Float; {$IFDEF V_INLINE}inline;{$ENDIF}
{ Result:=max(A, B) }

function IntMinMax(Value, Floor, Ceil: Integer): Integer;
{ see code }

function PhysicalMemorySize: UInt32;
{ возвращает объем физической памяти }
{ returns the physical memory size }

function PhysicalMemoryFree: UInt32;
{ возвращает объем свободной физической памяти }
{ returns the free physical memory size }

function HaveMemoryReserve: Boolean;
{ возвращает True, если в системе свободно не менее MemoryReserve байт физической
  памяти; функция применяется для того, чтобы определить, есть ли в системе
  "лишняя" память, которую можно использовать для хранения "необязательных",
  но ускоряющих выполнение данных (например, каких-либо буферов) }
{ returns True iff there's not less then MemoryReserve bytes of free physical
  memory in the system; this function can be used to determine is there any
  "spare" memory in the system which can be used for storing some "unnecessary"
  but useful in terms of efficiency data (e.g. some buffers) }

{$IFNDEF CLR}
procedure SetNull(var X; Count: Integer);
{ заполнить блок памяти X длины Count нулями (оптимизированный вариант процедуры
  FillChar(x, n, 0)) }
{ fills the memory block X of length Count bytes with nulls (the optimized
  variant of the FillChar(x, n, 0) procedure ) }

procedure MemExchange(var X, Y; Count: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 302{$ENDIF}
{ обменивает содержимое блоков памяти X и Y длины Count байт; блоки памяти
  не должны перекрываться }
{ echanges data in the memory blocks X and Y of length Count bytes; the memory
  blocks must not overlap }
{$ENDIF} {CLR}

function MemEqual(const X, Y; Count: Integer): Boolean;
  {$IFDEF DYNAMIC_NLS}external DLLName index 301{$ENDIF}
{ сравнивает блоки памяти X и Y длины Count байт каждый и возвращает True, если
  они равны или Count = 0 }
{ compares the memory blocks X and Y of length Count bytes each and returns True
  iff they are equal or Count = 0 }

function FindInBuf(const SearchBytes; SearchCount: Integer; const Buffer;
  BufferLength: Integer): Integer;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 303{$ENDIF}
{ ищет первое вхождение последовательности байт SearchBytes длины SearchCount
  в буфере Buffer длины BufferLength и возвращает индекс этого вхождения, либо
  -1, если искомая последовательность не найдена }
{ finds the first occurrence of the pattern SearchBytes of length SearchCount in
  the buffer Buffer of length BufferLength and returns the index of this
  occurrence or -1 if the pattern was not found }

function FindWordsInBuf(const SearchWords; WordCount: Integer; const Buffer;
  BufferWordCount: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 304{$ENDIF}
{ ищет первое вхождение последовательности слов (16-битных значений) SearchWords
  длины WordCount (это количество слов, а не байт!) в буфере Buffer, состоящем
  из BufferWordCount слов, и возвращает индекс этого вхождения (в словах) либо
  -1, если искомая последовательность не найдена }
{ finds the first occurrence of the sequence of words (16-bit values) SearchWords
  of length WordCount (this is a number of words, not bytes!) in the buffer
  Buffer containing BufferWordCount words and returns the index (in words) of
  this occurrence or -1 if the pattern was not found }

{$IFNDEF CLR}
procedure FillPattern(var X; Count: Integer; const Pattern; PatternLength: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 305{$ENDIF}
{ заполнить блок памяти X длины Count байт, повторив Pattern длины PatternLength
  нужное количество раз (расширенный вариант процедуры FillChar) }
{ fills the memory block X of length Count bytes with the pattern Pattern of
  length PatternLength bytes (the extended variant of the FillChar procedure) }
procedure FillValue16(var X; Value: Int16; Count: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 306{$ENDIF}
{ заполнить блок памяти X длины (Count * 2) байт, повторив Count раз Value;
  при вызове желательно явно приводить Value к типу Int16 (во избежание
  Range Check Error) }
{ fills the memory block X of length (Count * 2) bytes with Count copies of
  Value; it's recommended to cast Value to Int16 (to avoid Range Check Error) }
procedure FillValue32(var X; Value: Int32; Count: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 307{$ENDIF}
{ заполнить блок памяти X длины (Count * 4) байт, повторив Count раз Value;
  при вызове желательно явно приводить Value к типу Int32 (во избежание
  Range Check Error) }
{ fills the memory block X of length (Count * 4) bytes with Count copies of
  Value; it's recommended to cast Value to Int32 (to avoid Range Check Error) }
procedure FillValue64(var X; const Value; Count: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 308{$ENDIF}
{ заполнить блок памяти X длины (Count * 8) байт, повторив Count раз 64-битное
  значение Value }
{ fills the memory block X of length (Count * 8) bytes with Count copies of
  64-bit value Value }
procedure FillValue80(var X; const Value; Count: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 309{$ENDIF}
{ заполнить блок памяти X длины (Count * 10) байт, повторив Count раз 80-битное
  значение Value }
{ fills the memory block X of length (Count * 10) bytes with Count copies of
  80-bit value Value }
{$ENDIF} {CLR}

function CountEqualToPattern(const X; Count: Integer; const Pattern;
  PatternLength: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 310{$ENDIF}
{ подсчитывает число вхождений Pattern длины PatternLength в блок памяти X,
  состоящий из Count элементов длины PatternLength каждый }
{ counts the number of occurrences of the pattern Pattern of length PatternLength
  in the memory block X containing Count elements with length PatternLength each }
function CountEqualToValue8(const X; Value: Int8; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 311{$ENDIF}
function CountEqualToValue16(const X; Value: Int16; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 312{$ENDIF}
function CountEqualToValue32(const X; Value: Int32; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 313{$ENDIF}
function CountEqualToValue64(const X; const Value; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 314{$ENDIF}
function CountEqualToValue80(const X; const Value; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 315{$ENDIF}

function IndexOfPattern(const X; Count: Integer; const Pattern;
  PatternLength: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 316{$ENDIF}
{ возвращает индекс первого вхождения Pattern длины PatternLength в
  блоке памяти X, состоящем из Count элементов длины PatternLength каждый }
{ returns the index of the first occurrence of Pattern of length PatternLength
  in the memory block X containing Count elements of length PatternLength each }
function IndexOfValue8(const X; Value: Int8; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 317{$ENDIF}
function IndexOfValue16(const X; Value: Int16; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 318{$ENDIF}
function IndexOfValue32(const X; Value: Int32; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 319{$ENDIF}
function IndexOfValue64(const X; const Value; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 320{$ENDIF}
function IndexOfValue80(const X; const Value; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 321{$ENDIF}

function LastIndexOfPattern(const X; Count: Integer; const Pattern;
  PatternLength: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 322{$ENDIF}
{ возвращает индекс последнего вхождения Pattern длины PatternLength в
  блоке памяти X, состоящем из Count элементов длины PatternLength каждый }
{ returns the index of the last occurrence of Pattern of length PatternLength in
  the memory block X containing Count elements of length PatternLength each }
function LastIndexOfValue8(const X; Value: Int8; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 323{$ENDIF}
function LastIndexOfValue16(const X; Value: Int16; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 324{$ENDIF}
function LastIndexOfValue32(const X; Value: Int32; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 325{$ENDIF}
function LastIndexOfValue64(const X; const Value; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 326{$ENDIF}
function LastIndexOfValue80(const X; const Value; Count: Integer): Integer;
  {$IFDEF DYNAMIC_NLS}external DLLName index 327{$ENDIF}

function FirstHighChar(Buf: PChar; Count: Integer): PChar;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 328{$ENDIF}
{ если в строку Buf длины Count входит символ с кодом >= 128, то возвращает
  указатель на первый такой символ, иначе возвращает nil }
{ if a string Buf of length Count contains a character with code >= 128 then
  returns a pointer to the first occurrence of such character else returns nil }

function ReplaceValue8(const X; FromValue, ToValue: Int8; Count: Integer): Integer;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 329{$ENDIF}
{$IFDEF V_32}
function ReplaceValue16(const X; FromValue, ToValue: Int16; Count: Integer): Integer;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 330{$ENDIF}
{$ENDIF}
{ заменяет все вхождения FromValue на ToValue в блоке памяти X длины Count
  элементов; ReplaceValue16: Count - длина в словах, не в байтах! }
{ replaces all occurrences of FromValue to ToValue in the memory block X of
  length Count elements; ReplaceValue16: Count is length in words, not in bytes! }

procedure ReverseBytes(var X; Count: Integer);
  {$IFDEF CLR}unsafe;{$ENDIF}

{$IFNDEF CLR}
function NewVStr(const S: String): PVString;
procedure DisposeVStr(P: PVString);
{$ENDIF} {CLR}

{$IFDEF V_32}
{$IFNDEF CLR}
procedure SwapWordsInBuf(P: PWideChar; Bytes: Integer);
  {$IFDEF DYNAMIC_NLS}external DLLName index 331{$ENDIF}
{$ENDIF} {CLR}
function LString(P: Pointer; MaxLen: Integer): AnsiString;
  {$IFDEF CLR}unsafe;{$ENDIF}
{$IFDEF CLR}
function LNetString(P: Pointer; MaxLen: Integer): String; unsafe;
{$ENDIF} {CLR}
function LStringCheck(P: Pointer; MaxLen: Integer; var S: String): Boolean;
  {$IFDEF CLR}unsafe;{$ENDIF}
function CreateString(P: Pointer; Len: Integer): String;
  {$IFDEF CLR}unsafe;{$ENDIF}
procedure TruncateAtZero(var S: AnsiString); {$IFDEF CLR}overload;{$ENDIF}
{$IFDEF CLR}
procedure TruncateAtZero(var S: String); overload;
{$ENDIF} {CLR}
function LWideString(P: Pointer; MaxLen: Integer): WideString;
  {$IFDEF CLR}unsafe;{$ENDIF}
function LWideStringCheck(P: Pointer; MaxLen: Integer; var W: WideString): Boolean;
  {$IFDEF CLR}unsafe;{$ENDIF}
procedure SetWideString(var W: WideString; Buffer: PWideChar; Len: Integer);
  {$IFDEF CLR}unsafe;{$ENDIF}
function CreateWideString(Buffer: PWideChar; Len: Integer): WideString;
  {$IFDEF CLR}unsafe;{$ENDIF}
function WString(const S: String): WideString;
  {$IFDEF CLR}unsafe;{$ENDIF}
function WidenString(const S: String): String;
function ASCIIStringToWide(const S: String): WideString;
function WideStringToASCII(const W: WideString): String;

{$IFNDEF CLR}
function NewWideStr(const W: WideString): PWideString;
procedure DisposeWideStr(P: PWideString);
{$ENDIF} {CLR}

{$ENDIF} {V_32}

function FindTwoBytesInBuf(TwoBytes: UInt16; const Buffer;
  BufferLength: Integer): Integer;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 332{$ENDIF}
{ ищет первое вхождение двух байт TwoBytes (порядок байт - little endian, b2b1)
  в буфере Buffer длины BufferLength и возвращает индекс этого вхождения, либо
  -1, если искомая последовательность не найдена }
{ finds the first occurrence of two bytes TwoBytes (byte order is little endian,
  b2b1) in the buffer Buffer of length BufferLength and returns the index of
  this occurrence or -1 if the pattern was not found }

{ BMH: modified Boyer-Moore-Horspool pattern search }

type
  TBMHTable = array [0..255] of Integer;

procedure PrepareFindBMH(const SearchBytes; SearchCount: Integer;
  var BMH: TBMHTable);
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 333{$ENDIF}

function FindBMHPrepared(const SearchBytes; SearchCount: Integer;
  const Buffer; BufferLength: Integer; const BMH: TBMHTable): Integer;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 334{$ENDIF}

function FindInBufBMH(const SearchBytes; SearchCount: Integer; const Buffer;
  BufferLength: Integer): Integer;
  {$IFDEF CLR}unsafe;{$ENDIF}
  {$IFDEF DYNAMIC_NLS}external DLLName index 335{$ENDIF}

{$IFDEF V_WIN}{$IFDEF V_WIDESTRINGS}
function UNCPath(const Path: WideString): WideString;
{$ENDIF}{$ENDIF}

{$IFDEF V_INTERFACE}{$IFNDEF CLR}
type
  ISafeGuard = interface
    procedure FreeItem;
  end;

function GuardMem(P: Pointer; out SafeGuard: ISafeGuard): Pointer;
function GuardObj(Obj: TObject; out SafeGuard: ISafeGuard): Pointer;
{$ENDIF}{$ENDIF}

{$IFDEF V_32}
const
  AllocGlobalGranularity = 512;

type
  TGMEM = {$IFDEF V_WIN}HGLOBAL;{$ENDIF}{$IFDEF LINUX}Pointer;{$ENDIF}

function AllocGlobal(Size: Integer{$IFDEF CHECK_ALLOC_GLOBAL}; const Id: Int32
  {$IFDEF V_WIN}; Flags: DWORD = GMEM_FIXED{$ENDIF}{$ENDIF}): TGMEM;
{ calls GlobalAlloc(GMEM_FIXED...) under Windows and malloc under Linux }

{$IFDEF CHECK_ALLOC_GLOBAL}
function ReAllocGlobal(Mem: TGMEM; OldSize, NewSize: Integer): TGMEM;

function GetGlobalMemCount: Integer;
{$ENDIF} {CHECK_ALLOC_GLOBAL}

procedure FreeGlobal(Mem: TGMEM);
{ calls GlobalFree under Windows and free under Linux }
{$ENDIF} {V_32}

{$IFDEF V_FREEPASCAL}
{$IFDEF WIN32}
var
  Win32Platform: Integer = VER_PLATFORM_WIN32_WINDOWS;
  //Win32Platform: Integer = 4;
type
  EWin32Error = class(Exception)
    ErrorCode: UInt32;
  end;

procedure RaiseLastWin32Error;

function Win32Check(RetVal: Windows.BOOL): Windows.BOOL;
{$ENDIF}
procedure OSCheck(RetVal: Boolean);
{$ENDIF}

{$IFDEF V_DELPHI}
{$IFDEF V_D3}
procedure OSCheck(RetVal: Boolean);
{$IFNDEF CLR}
procedure RaiseLastOSErrorEx(LastError: Integer);
{$IFNDEF V_D6}
procedure RaiseLastOSError;
{$ENDIF} {V_D6}
{$ENDIF} {CLR}
{$ENDIF} {V_D3}
{$ENDIF} {V_DELPHI}

{$IFDEF V_KYLIX}
function SysErrorMessageW(ErrorCode: Integer): WideString;
{$ENDIF} {V_KYLIX}

{ Date/Time }

{$IFDEF V_32}
function SafeDOSFileDateToDateTime(FileDate: Integer): TDateTime;
function GetTimeZoneBias: Double;
function GetTimeZoneStr: String;
function UTCToLocalDateTime(const DateTime: TDateTime): TDateTime;
{ converts Universal Coordinated Time (UTC) to local date/time }
function LocalToUTCDateTime(const DateTime: TDateTime): TDateTime;
{ converts local date/time to Universal Coordinated Time (UTC) }
{$ENDIF}

{$IFNDEF CLR}
const
  PackedDT40Lo = 35796; { 1/1/1998 }
  PackedDT40Hi = PackedDT40Lo + 8192; { 6/6/2020; 8192 = 2^13 }

type
  { packed 40-bit date and time format; 13 bits for date (number of days from
    PackedDT40Lo) and 27 bits for time in "ticks" (2^27 ticks = 24 hours) }
  TPackedDT40 = packed record case Byte of
    0: (Bytes: array [0..4] of UInt8);
    1: (D: packed record Lo32: UInt32; Hi8: UInt8 end);
  end;

function DateTimeToPackedDT40(const DateTime: TDateTime;
  var PackedDT: TPackedDT40): Boolean;
{ converts Delphi date/time to TPackedDT40; returns False and sets PackedDT to
  zero values if the date/time passed is not in the allowed range }

function PackedDT40ToDateTime(const PackedDT: TPackedDT40): TDateTime;
{ converts TPackedDT40 to Delphi date/time }

{$IFDEF V_32}
function FileTimeToDateTime(const FileTime: TFileTime): TDateTime;

function ComparePackedDT40(const PackedDT1, PackedDT2: TPackedDT40): Integer;
{ returns a positive number if PackedDT1 > PackedDT2, a negative number if
  PackedDT1 < PackedDT2 and zero if PackedDT1 = PackedDT2 }
{$ENDIF} {V_32}

{$ENDIF} {CLR}

{$IFDEF V_WIN32}

{$IFNDEF V_FREEPASCAL}
{$IFNDEF CLR}
function SysErrorMessageW(ErrorCode: Integer): WideString;
{$ENDIF} {CLR}
{$IFNDEF V_D5}
function SameText(const S1, S2: String): Boolean;
{$ENDIF} {V_D5}
{$ENDIF} {V_FREEPASCAL}

{ Date/Time }

{$IFNDEF CLR}
function FileTimeToLocalDateTime(const FileTime: TFileTime): TDateTime;
function SafeFileTimeToDateTime(const FileTime: TFileTime): TDateTime;
function SafeFileTimeToLocalDateTime(const FileTime: TFileTime): TDateTime;
function SafeDosDateTimeToDateTime(ADate, ATime: Word): TDateTime;
{$ENDIF}
function DateTimeToFileTime(const DateTime: TDateTime): TFileTime;
function SafeDateTimeToFileTime(const DateTime: TDateTime): TFileTime;
function LocalDateTimeToFileTime(const DateTime: TDateTime): TFileTime;
function SafeFileDateToDateTime(FileDate: Integer): TDateTime;
function SafeSystemTimeToDateTime(const ST: TSystemTime): TDateTime;
{$ENDIF} {V_WIN32}

function SameDateTime(D1, D2: TDateTime): Boolean;
{ compares two date-time values with 1-msec precision }

function UnixDateTimeToDateTime(UnixDateTime: Int32): TDateTime;

{$IFDEF V_32}

function UnixDateTimeToLocalDateTime(UnixDateTime: Integer): TDateTime;
{$IFNDEF CLR}
function GetMemAlign(var P: Pointer; Size: Integer): Pointer;
function GetMemIfNilAlign(var P: Pointer; Size: Integer): Pointer;
{ gets memory and returns aligned pointer to it }
{$ENDIF}

{$ENDIF} {V_32}

function IntToStr2(I: Integer): String;

{$IFNDEF CLR}
function BigToLittleEndian32(From: Int32): Int32;
{$ENDIF} {CLR}

{$IFDEF LINUX}
var
  _euid, _egid: __uid_t;

function GetTickCount: UInt32;
{$ENDIF} {LINUX}

implementation

constructor EVFileStream.CreateEx(const AMsg: String;
  const AFileName, AParamStr: {$IFDEF W_STREAM}WideString{$ELSE}String{$ENDIF};
  const ASimpleMessage: String; ACode, ALastOSError: Integer);
begin
  inherited Create(AMsg);
  FileName:=AFileName;
  ParamStr:=AParamStr;
  SimpleMessage:=ASimpleMessage;
  Code:=ACode;
  LastOSError:=ALastOSError;
end;

{$IFDEF V_32}
function EVFileStream.FormatErrorMessage: String;
begin
  Result:=FormatFileError(FileName, SimpleMessage, Code, LastOSError);
end;

constructor WideException.CreateW(const Msg: WideString);
begin
  inherited Create(Msg);
  WideMessage:=Msg;
end;
{$ENDIF}

function IntMin(A, B: Integer): Integer;
begin
  if A <= B then Result:=A else Result:=B;
end;

function IntMax(A, B: Integer): Integer;
begin
  if A >= B then Result:=A else Result:=B;
end;

function FloatMin(A, B: Float): Float;
begin
  if A <= B then Result:=A else Result:=B;
end;

function FloatMax(A, B: Float): Float;
begin
  if A >= B then Result:=A else Result:=B;
end;

function IntMinMax(Value, Floor, Ceil: Integer): Integer;
begin
  Result:=Value;
  if Result < Floor then Result:=Floor;
  if Result > Ceil then Result:=Ceil;
end;

function PhysicalMemorySize: UInt32;
{$IFDEF V_WIN32}
const
  MemSize: UInt32 = 0;
var
  MemoryStatus: TMemoryStatus;
begin
  if MemSize = 0 then begin
    MemoryStatus.dwLength:=SizeOf(TMemoryStatus);
    GlobalMemoryStatus({$IFDEF V_FREEPASCAL}@{$ENDIF}MemoryStatus);
    MemSize:=MemoryStatus.dwTotalPhys;
  end;
  Result:=MemSize;
{$ELSE}
{$IFDEF LINUX}
var
  SI: TSysInfo;
begin
  if sysinfo(SI){$IFDEF V_DELPHI} = 0{$ENDIF} then
    Result:=SI.totalram
  else
    Result:=0;
{$ELSE}
begin
  Result:=MaxAvail;
{$ENDIF} {LINUX}
{$ENDIF} {V_WIN32}
end;

function PhysicalMemoryFree: UInt32;
{$IFDEF V_WIN32}
var
  MemoryStatus: TMemoryStatus;
begin
  MemoryStatus.dwLength:=SizeOf(TMemoryStatus);
  GlobalMemoryStatus({$IFDEF V_FREEPASCAL}@{$ENDIF}MemoryStatus);
  Result:=MemoryStatus.dwAvailPhys;
{$ELSE}
{$IFDEF LINUX}
var
  SI: TSysInfo;
begin
  if sysinfo(SI){$IFDEF V_DELPHI} = 0{$ENDIF} then
    Result:=SI.freeram
  else
    Result:=0;
{$ELSE}
begin
  Result:=MemAvail;
{$ENDIF} {LINUX}
{$ENDIF} {V_WIN32}
end;

function HaveMemoryReserve: Boolean;
begin
  Result:=PhysicalMemoryFree >= MemoryReserve;
end;

{$IFNDEF CLR}

procedure SetNull(var X; Count: Integer);
{$IFNDEF USE_ASM}
begin
  FillChar(X, Count, 0);
end;
{$ELSE}
asm     // eax = @X; edx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      edx, Count
        {$ENDIF}
        push     edi
        mov      ecx, edx
        mov      edi, eax
        xor      eax, eax
        shr      ecx, 2
        and      edx, 3
        rep      stosd
        mov      ecx, edx
        rep      stosb
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

{$IFNDEF DYNAMIC_NLS}
procedure MemExchange(var X, Y; Count: Integer);
{$IFNDEF USE_ASM}
var
  I: Integer;
  T: Int8;
begin
  for I:=0 to Count - 1 do begin
    T:=TInt8Array(X)[I];
    TInt8Array(X)[I]:=TInt8Array(Y)[I];
    TInt8Array(Y)[I]:=T;
  end;
end;
{$ELSE}
asm     // eax = @X; edx = @Y; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      edx, Y
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     ebx
        push     esi
        push     ecx
        xor      esi, esi
        shr      ecx, 2
        jz       @@ByteOp
@@DWordLoop:
        mov      ebx, dword ptr [eax + esi]
        xchg     dword ptr [edx + esi], ebx
        mov      dword ptr [eax + esi], ebx
        add      esi, 4
        dec      ecx
        jnz      @@DWordLoop
@@ByteOp:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Exit
@@ByteLoop:
        mov      bl, byte ptr [eax + esi]
        xchg     byte ptr [edx + esi], bl
        mov      byte ptr [eax + esi], bl
        inc      esi
        dec      ecx
        jnz      @@ByteLoop
@@Exit:
        pop      esi
        pop      ebx
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}
{$ENDIF} {DYNAMIC_NLS}

{$ENDIF} {CLR}

{$IFNDEF DYNAMIC_NLS}
function MemEqual(const X, Y; Count: Integer): Boolean;
{$IFNDEF USE_ASM}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    if TInt8Array(X)[I] <> TInt8Array(Y)[I] then begin
      Result:=False;
      Exit;
    end;
  Result:=True;
end;
{$ELSE}
asm     // eax = @X; edx = @Y; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      edx, Y
        mov      ecx, Count
        {$ENDIF}
        push     esi
        push     edi
        mov      esi, edx
        mov      edi, eax
        xor      eax, eax
        or       ecx, ecx
        jl       @@Exit
        je       @@True
        mov      edx, ecx
        and      edx, 3 // 11b
        shr      ecx, 2
        jz       @@ByteOp
        repe     cmpsd
        jne      @@Exit
@@ByteOp:
        mov      ecx, edx
        repe     cmpsb
        jne      @@Exit
@@True:
        inc      eax
@@Exit:
        pop      edi
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function FindInBuf(const SearchBytes; SearchCount: Integer; const Buffer;
  BufferLength: Integer): Integer;
var
  I: Integer;
  {$IFNDEF USE_ASM}
  First4: Integer;
  Found: Boolean;
  {$ENDIF}
  Byte3: UInt8;
  P, Limit: PChar;
begin
  Case SearchCount of
    1: Result:=IndexOfValue8(Buffer, Int8(SearchBytes), BufferLength);
    2: Result:=FindTwoBytesInBuf(UInt16(SearchBytes), Buffer, BufferLength);
    3: begin
      Result:=-1;
      if SearchCount <= 0 then
        Exit;
      I:=BufferLength - 2;
      if I <= 0 then
        Exit;
      P:=@Buffer;
      Limit:=P + I;
      Byte3:=PUInt8(PChar(@SearchBytes) + 2)^;
      repeat
        Result:=FindTwoBytesInBuf(UInt16(SearchBytes), P^, Limit - P + 1);
        if Result < 0 then
          Exit;
        Inc(P, Result + 2);
        if PUInt8(P)^ = Byte3 then begin
          Result:=P - PChar(@Buffer) - 2;
          Exit;
        end;
      until P >= Limit;
    end
  Else { SearchCount >= 4 }
    Result:=-1;
    if SearchCount <= 0 then
      Exit;
    I:=BufferLength - SearchCount + 1;
    if I <= 0 then
      Exit;
    {$IFNDEF USE_ASM}
    P:=@Buffer;
    Limit:=P + I;
    First4:=Int32(SearchBytes);
    repeat
      if PInt32(P)^ = First4 then begin
        Found:=True;
        for I:=4 to SearchCount - 1 do
          if P[I] <> PChar(@SearchBytes)[I] then begin
            Found:=False;
            Break;
          end;
        if Found then begin
          Result:=P - PChar(@Buffer);
          Exit;
        end;
      end;
      Inc(P);
    until P >= Limit;
    {$ELSE}
    asm
      {$IFDEF V_FREEPASCAL}
      push  eax
      push  ecx
      push  edx
      {$ENDIF}
      push  ebx
      push  esi
      push  edi
      mov   eax, SearchBytes
      mov   esi, Buffer
      mov   edi, I
   @@Start:
      mov   ecx, edi
      mov   edx, [eax]     // first 4 bytes
      shr   ecx, 3
      jz    @@SmallLoop
    @@Unrolled:
      cmp   [esi], edx     // 1
      je    @@Check
      cmp   [esi + 1], edx // 2
      je    @@Check2
      cmp   [esi + 2], edx // 3
      je    @@Check3
      cmp   [esi + 3], edx // 4
      je    @@Check4
      cmp   [esi + 4], edx // 5
      je    @@Check5
      cmp   [esi + 5], edx // 6
      je    @@Check6
      cmp   [esi + 6], edx // 7
      je    @@Check7
      cmp   [esi + 7], edx // 8
      je    @@Check8
      add   esi, 8
      sub   edi, 8
      dec   ecx
      jnz   @@Unrolled
      or    edi, edi
      jz    @@End
    @@SmallLoop:
      cmp   [esi], edx
      je    @@Check
    @@SmallNext:
      inc   esi
      dec   edi
      jnz   @@SmallLoop
      jmp   @@End
    @@Check2:
      inc   esi
      dec   edi
      jmp   @@Check
    @@Check3:
      add   esi, 2
      sub   edi, 2
      jmp   @@Check
    @@Check4:
      add   esi, 3
      sub   edi, 3
      jmp   @@Check
    @@Check5:
      add   esi, 4
      sub   edi, 4
      jmp   @@Check
    @@Check6:
      add   esi, 5
      sub   edi, 5
      jmp   @@Check
    @@Check7:
      add   esi, 6
      sub   edi, 6
      jmp   @@Check
    @@Check8:
      add   esi, 7
      sub   edi, 7
    @@Check:
      // for I:=4 to SearchCount - 1 do ...
      mov   ebx, 4
      mov   ecx, SearchCount
    @@CheckLoop:
      cmp   ebx, ecx
      jae   @@Found
      mov   dl, [eax + ebx]
      cmp   [esi + ebx], dl
      jne   @@NotEqual
      inc   ebx
      jmp   @@CheckLoop
    @@Found:
      sub   esi, Buffer
      mov   Result, esi
      jmp   @@End
    @@NotEqual:
      inc   esi
      dec   edi
      jnz   @@Start
    @@End:
      pop   edi
      pop   esi
      pop   ebx
      {$IFDEF V_FREEPASCAL}
      push  edx
      push  ecx
      push  eax
      {$ENDIF}
    end;
    {$ENDIF}
  End;
end;

function FindWordsInBuf(const SearchWords; WordCount: Integer; const Buffer;
  BufferWordCount: Integer): Integer;
{$IFNDEF USE_ASM}
var
  I, J, Limit: Integer;
begin
  if WordCount > 0 then begin
    Limit:=BufferWordCount - WordCount;
    Result:=0;
    while Result <= Limit do begin
      I:=Result;
      J:=0;
      while TInt16Array(Buffer)[I] = TInt16Array(SearchWords)[J] do begin
        Inc(I);
        Inc(J);
        if J >= WordCount then
          Exit;
      end;
      Inc(Result);
    end;
  end;
  Result:=-1;
end;
{$ELSE}
asm     // eax = @SearchWords; edx = WordCount; ecx = @Buffer
        {$IFDEF V_FREEPASCAL}
        mov      eax, SearchWords
        mov      edx, WordCount
        mov      ecx, Buffer
        {$ENDIF}
        or       edx, edx
        jle      @@IsEmpty
        push     ebx
        push     esi
        push     edi
        push     ebp
        mov      esi, eax
        mov      edi, ecx
        mov      ecx, BufferWordCount
        push     edi
        dec      edx
        mov      ax, [esi]
        add      esi, 2
        sub      ecx, edx
        jle      @@Fail
@@Loop:
        repne    scasw
        jne      @@Fail
        mov      ebx, ecx
        push     edi
        mov      ebp, esi
        mov      ecx, edx
        repe     cmpsw
        mov      esi, ebp
        pop      edi
        je       @@Found
        mov      ecx, ebx
        jmp      @@Loop
@@Fail:
        pop      edx
        xor      eax, eax
        jmp      @@Exit
@@IsEmpty:
        xor      eax, eax
        jmp      @@NoWork
@@Found:
        pop      edx
        mov      eax, edi
        sub      eax, edx
        shr      eax, 1
@@Exit:
        pop      ebp
        pop      edi
        pop      esi
        pop      ebx
@@NoWork:
        dec      eax
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

{$IFNDEF CLR}
procedure FillPattern(var X; Count: Integer; const Pattern; PatternLength: Integer);
var
  I, J: Integer;
begin
  if PatternLength > 0 then begin
    J:=0;
    for I:=0 to Count - 1 do begin
      TInt8Array(X)[I]:=TInt8Array(Pattern)[J];
      Inc(J);
      if J >= PatternLength then
        J:=0;
    end;
  end;
end;

procedure FillValue16(var X; Value: Int16; Count: Integer);
{$IFNDEF USE_ASM}
begin
  FillPattern(X, Count * 2, Value, 2);
end;
{$ELSE}
asm     // eax = @X; dx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      dx, Value
        mov      ecx, Count
        {$ENDIF}
        push     edi
        mov      edi, eax
        mov      eax, edx
        shl      eax, 16
        mov      ax, dx
        shr      ecx, 1
        rep      stosd
        adc      ecx, 0
        rep      stosw
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure FillValue32(var X; Value: Int32; Count: Integer);
{$IFNDEF USE_ASM}
begin
  FillPattern(X, Count * 4, Value, 4);
end;
{$ELSE}
asm     // eax = @X; edx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      edx, Value
        mov      ecx, Count
        {$ENDIF}
        push     edi
        mov      edi, eax
        mov      eax, edx
        rep      stosd
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure FillValue64(var X; const Value; Count: Integer);
{$IFNDEF USE_ASM}
begin
  FillPattern(X, Count * 8, Value, 8);
end;
{$ELSE}
asm     // eax = @X; edx = @Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      edx, Value
        mov      ecx, Count
        {$ENDIF}
        or       ecx, ecx
        jle      @@Exit
        push     edi
        mov      edi, [edx]
        dec      ecx
        mov      edx, [edx + 4]
@@Loop: mov      [eax + ecx * 8], edi
        mov      [eax + ecx * 8 + 4], edx
        dec      ecx
        jge      @@Loop
        pop      edi
@@Exit:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure FillValue80(var X; const Value; Count: Integer);
{$IFNDEF USE_ASM}
begin
  FillPattern(X, Count * 10, Value, 10);
end;
{$ELSE}
asm     // eax = @X; edx = @Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@Exit
        push     edi
        push     ebx
        mov      edi, [edx]
        mov      ebx, [edx + 4]
        mov      dx, word ptr [edx + 8]
@@Loop: mov      [eax], edi
        add      eax, 4
        mov      [eax], ebx
        add      eax, 4
        mov      word ptr [eax], dx
        add      eax, 2
        dec      ecx
        jnz      @@Loop
        pop      ebx
        pop      edi
@@Exit:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

{$ENDIF CLR}

function CountEqualToPattern(const X; Count: Integer; const Pattern;
  PatternLength: Integer): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if MemEqual(TInt8Array(X)[I * PatternLength], Pattern, PatternLength) then
      Inc(Result);
end;

function CountEqualToValue8(const X; Value: Int8; Count: Integer): Integer;
{$IFNDEF USE_ASM}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if TInt8Array(X)[I] = Value then
      Inc(Result);
end;
{$ELSE}
asm     // eax = @X; dl = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      dl, Value
        {$ENDIF}
        push     ebx
        push     esi
        xor      ebx, ebx
        or       ecx, ecx
        jle      @@Exit
        mov      esi, eax
        xor      eax, eax
@@Loop:
        cmp      byte ptr [esi], dl
        setz     al
        add      ebx, eax
        inc      esi
        dec      ecx
        jnz      @@Loop
@@Exit:
        mov      eax, ebx
        pop      esi
        pop      ebx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function CountEqualToValue16(const X; Value: Int16; Count: Integer): Integer;
{$IFNDEF USE_ASM}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if TInt16Array(X)[I] = Value then
      Inc(Result);
end;
{$ELSE}
asm     // eax = @X; dx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      dx, Value
        {$ENDIF}
        push     ebx
        push     esi
        xor      ebx, ebx
        or       ecx, ecx
        jle      @@Exit
        mov      esi, eax
        xor      eax, eax
@@Loop:
        cmp      word ptr [esi], dx
        setz     al
        add      ebx, eax
        add      esi, 2
        dec      ecx
        jnz      @@Loop
@@Exit:
        mov      eax, ebx
        pop      esi
        pop      ebx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function CountEqualToValue32(const X; Value: Int32; Count: Integer): Integer;
{$IFNDEF USE_ASM}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if TInt32Array(X)[I] = Value then
      Inc(Result);
end;
{$ELSE}
asm     // eax = @X; edx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        push     ebx
        push     esi
        xor      ebx, ebx
        or       ecx, ecx
        jle      @@Exit
        mov      esi, eax
        xor      eax, eax
@@Loop:
        cmp      [esi], edx
        setz     al
        add      ebx, eax
        add      esi, 4
        dec      ecx
        jnz      @@Loop
@@Exit:
        mov      eax, ebx
        pop      esi
        pop      ebx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function CountEqualToValue64(const X; const Value; Count: Integer): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if TFloat64Array(X)[I] = Float64(Value) then
      Inc(Result);
end;

function CountEqualToValue80(const X; const Value; Count: Integer): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if TFloat80Array(X)[I] = Float80(Value) then
      Inc(Result);
end;

function IndexOfPattern(const X; Count: Integer; const Pattern;
  PatternLength: Integer): Integer;
begin
  Result:=0;
  while Result < Count do
    if MemEqual(TInt8Array(X)[Result * PatternLength], Pattern, PatternLength) then
      Exit
    else
      Inc(Result);
  Result:=-1;
end;

function IndexOfValue8(const X; Value: Int8; Count: Integer): Integer;
{$IFNDEF USE_ASM}
begin
  Result:=0;
  while Result < Count do
    if TInt8Array(X)[Result] <> Value then
      Inc(Result)
    else
      Exit;
  Result:=-1;
end;
{$ELSE}
asm     // eax = @X; dl = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      dl, Value
        {$ENDIF}
        push     edi
        push     ebx
        or       ecx, ecx
        jle      @@NotFound
        mov      edi, eax
        mov      ebx, eax
        mov      eax, edx
        repne    scasb
        jne      @@NotFound
        mov      eax, edi
        inc      ebx
        sub      eax, ebx
        jmp      @@Exit
@@NotFound:
        mov      eax, -1
@@Exit:
        pop      ebx
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function IndexOfValue16(const X; Value: Int16; Count: Integer): Integer;
{$IFNDEF USE_ASM}
begin
  Result:=0;
  while Result < Count do
    if TInt16Array(X)[Result] <> Value then
      Inc(Result)
    else
      Exit;
  Result:=-1;
end;
{$ELSE}
asm     // eax = @X; dx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      dx, Value
        {$ENDIF}
        push     edi
        push     ebx
        or       ecx, ecx
        jle      @@NotFound
        mov      edi, eax
        mov      ebx, eax
        mov      eax, edx
        repne    scasw
        jne      @@NotFound
        mov      eax, edi
        add      ebx, 2
        sub      eax, ebx
        shr      eax, 1
        jmp      @@Exit
@@NotFound:
        mov      eax, -1
@@Exit:
        pop      ebx
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function IndexOfValue32(const X; Value: Int32; Count: Integer): Integer;
{$IFNDEF USE_ASM}
begin
  Result:=0;
  while Result < Count do
    if TInt32Array(X)[Result] <> Value then
      Inc(Result)
    else
      Exit;
  Result:=-1;
end;
{$ELSE}
asm     // eax = @X; edx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        push     edi
        push     ebx
        or       ecx, ecx
        jle      @@NotFound
        mov      edi, eax
        mov      ebx, eax
        mov      eax, edx
        repne    scasd
        jne      @@NotFound
        mov      eax, edi
        add      ebx, 4
        sub      eax, ebx
        shr      eax, 2
        jmp      @@Exit
@@NotFound:
        mov      eax, -1
@@Exit:
        pop      ebx
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function IndexOfValue64(const X; const Value; Count: Integer): Integer;
begin
  Result:=0;
  while Result < Count do
    if TFloat64Array(X)[Result] <> Float64(Value) then
      Inc(Result)
    else
      Exit;
  Result:=-1;
end;

function IndexOfValue80(const X; const Value; Count: Integer): Integer;
begin
  Result:=0;
  while Result < Count do
    if TFloat80Array(X)[Result] <> Float80(Value) then
      Inc(Result)
    else
      Exit;
  Result:=-1;
end;

function LastIndexOfPattern(const X; Count: Integer; const Pattern;
  PatternLength: Integer): Integer;
begin
  Result:=Count - 1;
  while Result >= 0 do
    if MemEqual(TInt8Array(X)[Result * PatternLength], Pattern, PatternLength) then
      Exit
    else
      Dec(Result);
end;

function LastIndexOfValue8(const X; Value: Int8; Count: Integer): Integer;
{$IFNDEF USE_ASM}
begin
  Result:=Count - 1;
  while Result >= 0 do
    if TInt8Array(X)[Result] <> Value then
      Dec(Result)
    else
      Exit;
end;
{$ELSE}
asm     // eax = @X; dl = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      dl, Value
        {$ENDIF}
        push     edi
        push     ebx
        or       ecx, ecx
        jle      @@NotFound
        mov      edi, eax
        mov      ebx, eax
        add      edi, ecx
        mov      eax, edx
        dec      edi
        std
        repne    scasb
        cld
        jne      @@NotFound
        mov      eax, edi
        dec      ebx
        sub      eax, ebx
        jmp      @@Exit
@@NotFound:
        mov      eax, -1
@@Exit:
        pop      ebx
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function LastIndexOfValue16(const X; Value: Int16; Count: Integer): Integer;
{$IFNDEF USE_ASM}
begin
  Result:=Count - 1;
  while Result >= 0 do
    if TInt16Array(X)[Result] <> Value then
      Dec(Result)
    else
      Exit;
end;
{$ELSE}
asm     // eax = @X; dx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      dx, Value
        {$ENDIF}
        push     edi
        push     ebx
        or       ecx, ecx
        jle      @@NotFound
        mov      edi, eax
        mov      ebx, eax
        mov      eax, ecx
        dec      eax
        shl      eax, 1
        add      edi, eax
        mov      eax, edx
        std
        repne    scasw
        cld
        jne      @@NotFound
        mov      eax, edi
        sub      ebx, 2
        sub      eax, ebx
        shr      eax, 1
        jmp      @@Exit
@@NotFound:
        mov      eax, -1
@@Exit:
        pop      ebx
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function LastIndexOfValue32(const X; Value: Int32; Count: Integer): Integer;
{$IFNDEF USE_ASM}
begin
  Result:=Count - 1;
  while Result >= 0 do
    if TInt32Array(X)[Result] <> Value then
      Dec(Result)
    else
      Exit;
end;
{$ELSE}
asm     // eax = @X; edx = Value; ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, X
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        push     edi
        push     ebx
        or       ecx, ecx
        jle      @@NotFound
        mov      edi, eax
        mov      ebx, eax
        mov      eax, ecx
        dec      eax
        shl      eax, 2
        add      edi, eax
        mov      eax, edx
        std
        repne    scasd
        cld
        jne      @@NotFound
        mov      eax, edi
        sub      ebx, 4
        sub      eax, ebx
        shr      eax, 2
        jmp      @@Exit
@@NotFound:
        mov      eax, -1
@@Exit:
        pop      ebx
        pop      edi
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function LastIndexOfValue64(const X; const Value; Count: Integer): Integer;
begin
  Result:=Count - 1;
  while Result >= 0 do
    if TFloat64Array(X)[Result] <> Float64(Value) then
      Dec(Result)
    else
      Exit;
end;

function LastIndexOfValue80(const X; const Value; Count: Integer): Integer;
begin
  Result:=Count - 1;
  while Result >= 0 do
    if TFloat80Array(X)[Result] <> Float80(Value) then
      Dec(Result)
    else
      Exit;
end;

function FirstHighChar(Buf: PChar; Count: Integer): PChar;
begin
  Result:=Buf;
  Inc(Buf, Count);
  while Result < Buf do begin
    if Result^ >= #$80 then
      Exit;
    Inc(Result);
  end;
  Result:=nil;
end;

function ReplaceValue8(const X; FromValue, ToValue: Int8; Count: Integer): Integer;
var
  P, Limit: PChar;
begin
  Result:=0;
  P:=@X;
  Limit:=P + Count;
  while P < Limit do begin
    if P^ = Char(FromValue) then begin
      P^:=Char(ToValue);
      Inc(Result);
    end;
    Inc(P);
  end;
end;
{$ENDIF} {DYNAMIC_NLS}

procedure ReverseBytes(var X; Count: Integer);
var
  I: Integer;
  T: UInt8;
  P1, P2: PUInt8;
begin
  P1:=@X;
  P2:=PUInt8(PChar(P1) + Count);
  for I:=0 to Count div 2 - 1 do begin
    Dec(P2);
    T:=P1^;
    P1^:=P2^;
    P2^:=T;
    Inc(P1);
  end;
end;

{$IFNDEF CLR}
function NewVStr(const S: String): PVString;
{$IFNDEF V_LONGSTRINGS}
var
  L: Integer;
{$ENDIF}
begin
  if S <> '' then begin
    {$IFDEF V_LONGSTRINGS}
    New(Result);
    Result^:=S;
    {$ELSE}
    L:=Length(S) + 1;
    GetMem(Result, L);
    Move(S, Result^, L);
    {$ENDIF}
  end
  else
    Result:=nil;
end;

procedure DisposeVStr(P: PVString);
begin
  if P <> nil then
    {$IFDEF V_LONGSTRINGS}
    Dispose(P);
    {$ELSE}
    FreeMem(P, Ord(P^[0]) + 1);
    {$ENDIF}
end;
{$ENDIF} {CLR}

{$IFDEF V_32}
{$IFNDEF DYNAMIC_NLS}
function ReplaceValue16(const X; FromValue, ToValue: Int16; Count: Integer): Integer;
var
  P: PInt16;
begin
  Result:=0;
  P:=@X;
  while Count > 0 do begin
    if P^ = FromValue then begin
      P^:=ToValue;
      Inc(Result);
    end;
    Inc(P);
    Dec(Count);
  end;
end;

{$IFNDEF CLR}
procedure SwapWordsInBuf(P: PWideChar; Bytes: Integer);
var
  B: Byte;
  Limit: PWideChar;
begin
  if P <> nil then begin
    Integer(Limit):=Integer(P) + Bytes - 1;
    while P < Limit do begin
      B:=WordRec(P^).Lo;
      WordRec(P^).Lo:=WordRec(P^).Hi;
      WordRec(P^).Hi:=B;
      Inc(P);
    end;
  end;
end;
{$ENDIF} {CLR}
{$ENDIF} {DYNAMIC_NLS}

function LString(P: Pointer; MaxLen: Integer): AnsiString;
var
  I: Integer;
begin
  if P <> nil then begin
    I:=IndexOfValue8(P^, 0, MaxLen);
    if I < 0 then
      I:=MaxLen;
    {$IFNDEF CLR}
    SetString(Result, PChar(P), I);
    {$ELSE}
    SetLength(Result, I);
    for I:=1 to I do
      Result[I]:=PAnsiChar(P)[I - 1];
    {$ENDIF}
  end
  else
    Result:='';
end;

{$IFDEF CLR}
function LNetString(P: Pointer; MaxLen: Integer): String;
var
  I: Integer;
begin
  if P <> nil then begin
    I:=IndexOfValue8(P^, 0, MaxLen);
    if I < 0 then
      I:=MaxLen;
    SetLength(Result, I);
    for I:=1 to I do
      Result[I]:=PChar(P)[I - 1];
  end
  else
    Result:='';
end;
{$ENDIF} {CLR}

function LStringCheck(P: Pointer; MaxLen: Integer; var S: String): Boolean;
var
  I: Integer;
begin
  if P <> nil then begin
    I:=IndexOfValue8(P^, 0, MaxLen);
    if I < 0 then begin
      S:='';
      Result:=False;
      Exit;
    end;
    {$IFNDEF CLR}
    SetString(S, PChar(P), I);
    {$ELSE}
    SetLength(S, I);
    for I:=1 to I do
      S[I]:=PChar(P)[I - 1];
    {$ENDIF}
  end
  else
    S:='';
  Result:=True;
end;

function CreateString(P: Pointer; Len: Integer): String;
begin
  if P <> nil then begin
    {$IFNDEF CLR}
    SetString(Result, PChar(P), Len)
    {$ELSE}
    SetLength(Result, Len);
    for Len:=1 to Len do
      Result[Len]:=PChar(P)[Len - 1];
    {$ENDIF}
  end
  else
    Result:='';
end;

procedure TruncateAtZero(var S: AnsiString);
var
  I: Integer;
begin
  {$IFNDEF CLR}
  I:=IndexOfValue8(Pointer(S)^, 0, Length(S));
  if I >= 0 then
    SetLength(S, I);
  {$ELSE}
  for I:=1 to Length(S) do
    if S[I] = #0 then begin
      SetLength(S, I - 1);
      Exit;
    end;
  {$ENDIF}
end;

{$IFDEF CLR}
procedure TruncateAtZero(var S: String);
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] = #0 then begin
      SetLength(S, I - 1);
      Exit;
    end;
end;
{$ENDIF} {CLR}

function LWideString(P: Pointer; MaxLen: Integer): WideString;
var
  I: Integer;
begin
  if P <> nil then begin
    I:=IndexOfValue16(P^, 0, MaxLen);
    if I < 0 then
      I:=MaxLen;
    SetLength(Result, I);
    {$IFNDEF CLR}
    Move(P^, Pointer(Result)^, I * 2);
    {$ELSE}
    for I:=1 to I do
      Result[I]:=PWideChar(P)[I - 1];
    {$ENDIF}
  end
  else
    Result:='';
end;

function LWideStringCheck(P: Pointer; MaxLen: Integer; var W: WideString): Boolean;
var
  I: Integer;
begin
  if P <> nil then begin
    I:=IndexOfValue16(P^, 0, MaxLen);
    if I < 0 then begin
      W:='';
      Result:=False;
      Exit;
    end;
    SetLength(W, I);
    {$IFNDEF CLR}
    Move(P^, Pointer(W)^, I * 2);
    {$ELSE}
    for I:=1 to I do
      W[I]:=PWideChar(P)[I - 1];
    {$ENDIF}
  end
  else
    W:='';
  Result:=True;
end;

procedure SetWideString(var W: WideString; Buffer: PWideChar; Len: Integer);
begin
  if Buffer <> nil then begin
    SetLength(W, Len);
    {$IFNDEF CLR}
    Move(Buffer^, Pointer(W)^, Len * 2);
    {$ELSE}
    for Len:=1 to Len do begin
      W[Len]:=Buffer^;
      Inc(Buffer);
    end;
    {$ENDIF}
  end
  else
    W:='';
end;

function CreateWideString(Buffer: PWideChar; Len: Integer): WideString;
begin
  if Buffer <> nil then begin
    SetLength(Result, Len);
    {$IFNDEF CLR}
    Move(Buffer^, Pointer(Result)^, Len * 2);
    {$ELSE}
    for Len:=1 to Len do begin
      Result[Len]:=Buffer^;
      Inc(Buffer);
    end;
    {$ENDIF}
  end
  else
    Result:='';
end;

function WString(const S: String): WideString;
var
  L: Integer;
  {$IFDEF CLR}
  I: Integer;
  {$ENDIF}
begin
  L:=Length(S);
  SetLength(Result, L div 2);
  {$IFNDEF CLR}
  Move(PChar(S)^, Pointer(Result)^, L and not 1);
  {$ELSE}
  I:=1;
  for L:=1 to L div 2 do begin
    Result[L]:=WideChar(Byte(S[I]) + Byte(S[I + 1]) shl 16);
    Inc(I, 2);
  end;
  {$ENDIF}
end;

function WidenString(const S: String): String;
var
  I, L: Integer;
  {$IFNDEF CLR}
  PW: PWideChar;
  {$ENDIF}
begin
  L:=Length(S);
  SetLength(Result, L * 2);
  {$IFNDEF CLR}
  PW:=Pointer(Result);
  for I:=1 to L do begin
    PW^:=WideChar(S[I]);
    Inc(PW);
  end;
  {$ELSE}
  I:=1;
  for L:=1 to L do begin
    Result[I]:=S[L];
    Result[I + 1]:=#0;
    Inc(I, 2);
  end;
  {$ENDIF}
end;

function ASCIIStringToWide(const S: String): WideString;
var
  I, L: Integer;
  {$IFNDEF CLR}
  PW: PWideChar;
  {$ENDIF}
begin
  L:=Length(S);
  SetLength(Result, L);
  {$IFNDEF CLR}
  PW:=Pointer(Result);
  for I:=1 to L do begin
    PW^:=WideChar(S[I]);
    Inc(PW);
  end;
  {$ELSE}
  for I:=1 to L do
    Result[I]:=S[I];
  {$ENDIF}
end;

function WideStringToASCII(const W: WideString): String;
var
  I, L: Integer;
  {$IFNDEF CLR}
  P: PChar;
  {$ENDIF}
begin
  L:=Length(W);
  SetLength(Result, L);
  {$IFNDEF CLR}
  P:=Pointer(Result);
  for I:=1 to L do begin
    P^:=Char(W[I]);
    Inc(P);
  end;
  {$ELSE}
  for I:=1 to L do
    Result[I]:=Char(W[I]);
  {$ENDIF}
end;

{$IFNDEF CLR}
function NewWideStr(const W: WideString): PWideString;
const
  EmptyWideStr: WideString = '';
  NullWideStr: PWideString = @EmptyWideStr;
begin
  if W = '' then
    Result:=NullWideStr
  else begin
    New(Result);
    Result^:=W;
  end;
end;

procedure DisposeWideStr(P: PWideString);
begin
  if (P <> nil) and (P^ <> '') then
    Dispose(P);
end;
{$ENDIF} {CLR}

{$ENDIF}

{$IFNDEF DYNAMIC_NLS}
function FindTwoBytesInBuf(TwoBytes: UInt16; const Buffer;
  BufferLength: Integer): Integer;
{ TwoBytes: 2 search bytes (reversed order: 0201) }
{$IFNDEF USE_ASM}
var
  P, Limit: PChar;
begin
  Result:=-1;
  if BufferLength < 2 then
    Exit;
  P:=@Buffer;
  Limit:=P + BufferLength - 1;
  repeat
    if PUInt16(P)^ = TwoBytes then begin
      Result:=P - PChar(@Buffer);
      Exit;
    end;
    Inc(P);
  until P >= Limit;
end;
{$ELSE}
asm     // ax = TwoBytes; edx = @Buffer; ecx = BufferLength
        {$IFDEF V_FREEPASCAL}
        mov      ax, TwoBytes
        mov      edx, Buffer
        mov      ecx, BufferLength
        {$ENDIF}
        push     ebx
        push     esi
        push     edi
        push     edx
        cmp      ecx, 2
        jl       @@Exit
        dec      ecx
        mov      esi, Buffer
        mov      edi, ecx
        mov      dx, TwoBytes   // 2 search bytes (reversed order: 0201)
        shr      edi, 3
        jz       @@CheckOther
        mov      eax, [esi]     // first 4 bytes (reversed order: 04030201)
@@Unrolled:
        cmp      ax, dx         // check 0201
        je       @@Found
        shr      eax, 8
        cmp      ax, dx         // check 0302
        je       @@Found2
        shr      eax, 8
        mov      ebx, [esi + 4] // next 4 bytes (reversed order: 08070605)
        cmp      ax, dx         // check 0403
        je       @@Found3
        shrd     ax, bx, 8
        cmp      ax, dx         // check 0504
        je       @@Found4
        cmp      bx, dx         // check 0605
        je       @@Found5
        shr      ebx, 8
        cmp      bx, dx         // check 0706
        je       @@Found6
        shr      ebx, 8
        cmp      bx, dx         // check 0807
        je       @@Found7
        dec      edi
        jz       @@ExitUnrolled
        mov      eax, [esi + 8] // next 4 bytes (reversed order: 0C0B0A09)
        shrd     bx, ax, 8      // check 0908
        cmp      bx, dx
        je       @@Found8
        add      esi, 8
        jmp      @@Unrolled
@@ExitUnrolled:
        and      ecx, 7
        jz       @@Exit
        add      esi, 7
        inc      ecx
        jmp      @@SmallLoop
@@Found8:
        add      esi, 7
        jmp      @@Found
@@Found7:
        add      esi, 6
        jmp      @@Found
@@Found6:
        add      esi, 5
        jmp      @@Found
@@Found5:
        add      esi, 4
        jmp      @@Found
@@Found4:
        inc      esi
@@Found3:
        inc      esi
@@Found2:
        inc      esi
        jmp      @@Found
@@CheckOther:
        and      ecx, 7
        jz       @@Exit
@@SmallLoop:
        cmp      dx, [esi]
        je       @@Found
        inc      esi
        dec      ecx
        jnz      @@SmallLoop
        jmp      @@Exit
@@Found:
        sub      esi, [esp]     // sub esi, Buffer
        mov      eax, esi
        jmp      @@PopEnd
@@Exit:
        mov      eax, -1
@@PopEnd:
        pop      edx
        pop      edi
        pop      esi
        pop      ebx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}
{$ENDIF} {DYNAMIC_NLS}

{$IFNDEF DYNAMIC_NLS}
procedure PrepareFindBMH(const SearchBytes; SearchCount: Integer;
  var BMH: TBMHTable);
var
  I, LastSearch: Integer;
  {$IFDEF CLR}
  P: PUInt8;
  {$ENDIF}
begin
  LastSearch:=SearchCount - 1;
  {$IFNDEF CLR}
  FillValue32(BMH, SearchCount, 256);
  for I:=0 to LastSearch - 1 do
    BMH[PUInt8Array(@SearchBytes)^[I]]:=LastSearch - I;
  {$ELSE}
  for I:=Low(BMH) to High(BMH) do
    BMH[I]:=256;
  P:=@SearchBytes;
  for I:=0 to LastSearch - 1 do begin
    BMH[P^]:=LastSearch - I;
    Inc(P);
  end;
  {$ENDIF}
end;

function FindBMHPrepared(const SearchBytes; SearchCount: Integer;
  const Buffer; BufferLength: Integer; const BMH: TBMHTable): Integer;
{ modified Boyer-Moore-Horspool pattern search }
var
  PredC, LastC, LastSearch: Integer;
  {$IFNDEF USE_ASM}
  I, C, LastBuffer: Integer;
  P: PChar;
  {$ENDIF}
begin
  if SearchCount = 1 then begin
    Result:=IndexOfValue8(Buffer, Int8(SearchBytes), BufferLength);
    Exit;
  end;
  Result:=-1;
  if (SearchCount <= 0) or (SearchCount > BufferLength) then
    Exit;
  LastSearch:=SearchCount - 1;
  LastC:=PUInt8Array(@SearchBytes)^[LastSearch];
  PredC:=PUInt8Array(@SearchBytes)^[LastSearch - 1];
  {$IFNDEF USE_ASM}
  I:=0;
  LastBuffer:=BufferLength - SearchCount;
  P:=PChar(@Buffer) + LastSearch;
  repeat
    C:=Ord(P[I]);
    if (C = LastC) and (Ord(P[I - 1]) = PredC) and
      MemEqual(PUInt8Array(@Buffer)^[I], SearchBytes, LastSearch - 1) then
    begin
      Result:=I;
      Exit;
    end;
    Inc(I, BMH[C]);
  until I > LastBuffer;
  {$ELSE}
  asm
    {$IFDEF V_FREEPASCAL}
    push  eax
    push  ecx
    push  edx
    {$ENDIF}
    push  ebx
    push  esi
    push  edi
    mov   ebx, BufferLength
    xor   eax, eax           // eax = I
    mov   cl, byte ptr LastC // cl = LastC
    mov   ch, byte ptr PredC // ch = PredC
    xor   edx, edx           // edx = C
    mov   esi, Buffer
    sub   ebx, SearchCount   // ebx = LastBuffer
    add   esi, LastSearch    // esi = Buffer + LastSearch
    mov   edi, BMH
@@Loop: // unrolled (4)
    mov   dl, [esi + eax]
    cmp   dl, cl
    je    @@CheckPredC
    add   eax, [edi + edx * 4]
    cmp   eax, ebx
    ja    @@Exit

    mov   dl, [esi + eax]
    cmp   dl, cl
    je    @@CheckPredC
    add   eax, [edi + edx * 4]
    cmp   eax, ebx
    ja    @@Exit

    mov   dl, [esi + eax]
    cmp   dl, cl
    je    @@CheckPredC
    add   eax, [edi + edx * 4]
    cmp   eax, ebx
    ja    @@Exit

    mov   dl, [esi + eax]
    cmp   dl, cl
    je    @@CheckPredC
    add   eax, [edi + edx * 4]
    cmp   eax, ebx
    jbe   @@Loop
    jmp   @@Exit
@@CheckPredC:
    cmp   ch, [esi + eax - 1]
    je    @@CheckEqual
    add   eax, [edi + edx * 4]
    cmp   eax, ebx
    jbe   @@Loop
    jmp   @@Exit
@@CheckEqual:
    push  esi
    push  edx
    push  edi
    // MemEqual inlined
    mov   ecx, LastSearch  // LastSearch > 0
    mov   edi, eax
    dec   ecx
    jz    @@Equal
    mov   edx, ecx
    mov   esi, SearchBytes
    add   edi, Buffer
    and   edx, 3 // 11b
    shr   ecx, 2
    jz    @@ByteOp
    repe  cmpsd
    jne   @@NotEqual
@@ByteOp:
    mov   ecx, edx
    repe  cmpsb
    je    @@Equal
@@NotEqual:
    pop   edi
    pop   edx
    pop   esi
    add   eax, [edi + edx * 4]
    mov   cl, byte ptr LastC // cl = LastC
    mov   ch, byte ptr PredC // ch = PredC
    cmp   eax, ebx
    jbe   @@Loop
    jmp   @@Exit
@@Equal:
    pop   edi
    pop   edx
    pop   esi
    mov   Result, eax
@@Exit:
    pop   edi
    pop   esi
    pop   ebx
    {$IFDEF V_FREEPASCAL}
    push  edx
    push  ecx
    push  eax
    {$ENDIF}
  end;
  {$ENDIF}
end;

function FindInBufBMH(const SearchBytes; SearchCount: Integer; const Buffer;
  BufferLength: Integer): Integer;
var
  BMH: TBMHTable;
begin
  PrepareFindBMH(SearchBytes, SearchCount, BMH);
  Result:=FindBMHPrepared(SearchBytes, SearchCount, Buffer, BufferLength, BMH);
end;
{$ENDIF} {DYNAMIC_NLS}

{$IFDEF V_WIN}{$IFDEF V_WIDESTRINGS}
function UNCPath(const Path: WideString): WideString;
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (Length(Path) >= MAX_PATH) and
    (Path[1] <> '.') then
  begin
    Result:='\\?\';
    if (Path[1] = '\') and (Path[2] = '\') then
      Result:=Result + 'UNC' + Copy(Path, 2, MaxInt)
    else
      Result:=Result + Path;
  end
  else
    Result:=Path;
end;
{$ENDIF}{$ENDIF}

{$IFDEF V_INTERFACE}{$IFNDEF CLR}
type
  TSafeGuard = class(TInterfacedObject, ISafeGuard)
  protected
    FItem: Pointer;
    procedure FreeItem; virtual;
  public
    constructor Create(P: Pointer);
    destructor Destroy; override;
  end;

  TObjSafeGuard = class(TSafeGuard, ISafeGuard)
  protected
    procedure FreeItem; override;
  end;

constructor TSafeGuard.Create(P: Pointer);
begin
  inherited Create;
  FItem:=P;
end;

destructor TSafeGuard.Destroy;
begin
  FreeItem;
  inherited Destroy;
end;

procedure TSafeGuard.FreeItem;
begin
  FreeMem(FItem);
  FItem:=nil;
end;

procedure TObjSafeGuard.FreeItem;
begin
  FreeAndNil(FItem);
end;

function GuardMem(P: Pointer; out SafeGuard: ISafeGuard): Pointer;
begin
  Result:=P;
  SafeGuard:=TSafeGuard.Create(Result);
end;

function GuardObj(Obj: TObject; out SafeGuard: ISafeGuard): Pointer;
begin
  Result:=Obj;
  SafeGuard:=TObjSafeGuard.Create(Result);
end;
{$ENDIF}{$ENDIF}

{$IFDEF V_32}
{$IFDEF CHECK_ALLOC_GLOBAL}
const
  AllocMagic = $FA5B9CFD;
type
  PAllocInfoList = ^TAllocInfoList;
  TAllocInfoList = record
    Magic: UInt32;
    Id, Size: Int32;
    Next, Prev: TGMEM;
  end;

var
  CurAllocInfo: TGMEM = TGMEM(0);
{$ENDIF} {CHECK_ALLOC_GLOBAL}

{$IFDEF CHECK_ALLOC_GLOBAL}
function GlobalMemSize(Mem: TGMEM): Integer;
begin
  {$IFDEF V_WIN}
  Result:=GlobalSize(Mem);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=malloc_usable_size(Mem);
  {$ENDIF}
  Dec(Result, SizeOf(TAllocInfoList));
end;

var
  AllocGlobalBlocks: Integer = 0;

  AllocCS: TRTLCriticalSection;
{$ENDIF} {CHECK_ALLOC_GLOBAL}

function AllocGlobal(Size: Integer{$IFDEF CHECK_ALLOC_GLOBAL}; const Id: Int32
  {$IFDEF V_WIN}; Flags: DWORD = GMEM_FIXED{$ENDIF}{$ENDIF}): TGMEM;
{$IFDEF CHECK_ALLOC_GLOBAL}
var
  {$IFDEF V_WIN}P: Pointer;{$ENDIF}
  AllocInfo: PAllocInfoList;
{$ENDIF}
begin
  {$IFDEF CHECK_ALLOC_GLOBAL}
  {$IFDEF V_WIN}
  Result:=GlobalAlloc(Flags, Size + SizeOf(TAllocInfoList));
  if Result = 0 then
    Exit;
  P:=GlobalLock(Result);
  FillChar(P^, Size + SizeOf(TAllocInfoList), $FF);
  AllocInfo:=Pointer(PChar(P) + Size);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=malloc(Size + SizeOf(TAllocInfoList));
  if Result = nil then
    Exit;
  AllocInfo:=Pointer(PChar(Result) + GlobalMemSize(Result));
  {$ENDIF}
  EnterCriticalSection(AllocCS);
  try
    Inc(AllocGlobalBlocks);
    AllocInfo^.Magic:=AllocMagic;
    AllocInfo^.Id:=Id;
    AllocInfo^.Size:=Size;
    AllocInfo^.Next:=TGMEM(0);
    if CurAllocInfo <> TGMEM(0) then begin
      AllocInfo^.Prev:=CurAllocInfo;
      AllocInfo:=Pointer(PChar({$IFDEF V_WIN}GlobalLock{$ENDIF}(CurAllocInfo)) +
        GlobalMemSize(CurAllocInfo));
      AllocInfo^.Next:=Result;
      {$IFDEF V_WIN}
      GlobalUnlock(CurAllocInfo);
      {$ENDIF}
    end
    else
      AllocInfo^.Prev:=TGMEM(0);
    CurAllocInfo:=Result;
    {$IFDEF V_WIN}
    GlobalUnlock(Result);
    {$ENDIF}
  finally
    LeaveCriticalSection(AllocCS);
  end;
  {$ELSE} {CHECK_ALLOC_GLOBAL}
  {$IFDEF V_WIN}
  Result:=GlobalAlloc(GMEM_FIXED, Size);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=malloc(Size);
  {$ENDIF}
  {$ENDIF} {CHECK_ALLOC_GLOBAL}
end;

{$IFDEF CHECK_ALLOC_GLOBAL}
function ReAllocGlobal(Mem: TGMEM; OldSize, NewSize: Integer): TGMEM;
var
  NextInfo, PrevInfo, AllocInfo: PAllocInfoList;
  SaveInfo: TAllocInfoList;
begin
  Result:=TGMEM(0);
  EnterCriticalSection(AllocCS);
  try
    {$IFDEF V_WIN}
    SaveInfo:=PAllocInfoList(PChar(GlobalLock(Mem)) + OldSize)^;
    GlobalUnlock(Mem);
    {$ENDIF}
    {$IFDEF LINUX}
    SaveInfo:=PAllocInfoList(PChar(Mem) + GlobalMemSize(Mem))^;
    {$ENDIF}
    if SaveInfo.Magic <> AllocMagic then
      raise Exception.Create('Memory passed to ReAllocGlobal was not allocated by AllocGlobal');
    if SaveInfo.Size <> OldSize then
      raise Exception.Create('Wrong old memory size value was passed to ReAllocGlobal');
    if SaveInfo.Next <> TGMEM(0) then
      NextInfo:=Pointer(PChar({$IFDEF V_WIN}GlobalLock{$ENDIF}(SaveInfo.Next)) +
        GlobalMemSize(SaveInfo.Next))
    else
      NextInfo:=nil;
    if SaveInfo.Prev <> TGMEM(0) then
      PrevInfo:=Pointer(PChar({$IFDEF V_WIN}GlobalLock{$ENDIF}(SaveInfo.Prev)) +
        GlobalMemSize(SaveInfo.Prev))
    else
      PrevInfo:=nil;
    {$IFDEF V_WIN}
    Result:=GlobalReAlloc(Mem, NewSize + SizeOf(TAllocInfoList), GMEM_MOVEABLE);
    if Result = 0 then begin
      if SaveInfo.Next <> TGMEM(0) then
        GlobalUnlock(SaveInfo.Next);
      if SaveInfo.Prev <> TGMEM(0) then
        GlobalUnlock(SaveInfo.Prev);
      Exit;
    end;
    {$ENDIF}
    {$IFDEF LINUX}
    Result:=realloc(Mem, NewSize + SizeOf(TAllocInfoList));
    if Result = nil then
      Exit;
    {$ENDIF}
    if NextInfo <> nil then
      NextInfo^.Prev:=Result;
    if PrevInfo <> nil then
      PrevInfo^.Next:=Result;
    {$IFDEF V_WIN}
    if SaveInfo.Next <> TGMEM(0) then
      GlobalUnlock(SaveInfo.Next);
    if SaveInfo.Prev <> TGMEM(0) then
      GlobalUnlock(SaveInfo.Prev);
    {$ENDIF}
    if Mem = CurAllocInfo then
      CurAllocInfo:=Result;
    {$IFDEF V_WIN}
    AllocInfo:=PAllocInfoList(PChar(GlobalLock(Result)) + NewSize);
    {$ENDIF}
    {$IFDEF LINUX}
    AllocInfo:=PAllocInfoList(PChar(Result) + GlobalMemSize(Result));
    {$ENDIF}
    AllocInfo^:=SaveInfo;
    AllocInfo^.Size:=NewSize;
    {$IFDEF V_WIN}
    GlobalUnlock(Result);
    {$ENDIF}
  finally
    LeaveCriticalSection(AllocCS);
  end;
end;

function GetGlobalMemCount: Integer;
begin
  EnterCriticalSection(AllocCS);
  try
    Result:=AllocGlobalBlocks;
  finally
    LeaveCriticalSection(AllocCS);
  end;
end;
{$ENDIF} {CHECK_ALLOC_GLOBAL}

procedure FreeGlobal(Mem: TGMEM);
{$IFDEF CHECK_ALLOC_GLOBAL}
var
  NextInfo, PrevInfo: PAllocInfoList;
  AllocInfo: TAllocInfoList;
{$ENDIF}
begin
  {$IFDEF CHECK_ALLOC_GLOBAL}
  EnterCriticalSection(AllocCS);
  try
    AllocInfo:=PAllocInfoList(PChar({$IFDEF V_WIN}GlobalLock{$ENDIF}(Mem)) +
      GlobalMemSize(Mem))^;
    if AllocInfo.Magic = AllocMagic then begin
      if Mem = TGMEM(CurAllocInfo) then
        CurAllocInfo:=AllocInfo.Prev;
      if AllocInfo.Prev <> TGMEM(0) then begin
        PrevInfo:=Pointer(PChar({$IFDEF V_WIN}GlobalLock{$ENDIF}(AllocInfo.Prev)) +
          GlobalMemSize(AllocInfo.Prev));
        PrevInfo^.Next:=AllocInfo.Next;
        {$IFDEF V_WIN}
        GlobalUnlock(AllocInfo.Prev);
        {$ENDIF}
      end;
      if AllocInfo.Next <> TGMEM(0) then begin
        NextInfo:=Pointer(PChar({$IFDEF V_WIN}GlobalLock{$ENDIF}(AllocInfo.Next)) +
          GlobalMemSize(AllocInfo.Next));
        NextInfo^.Prev:=AllocInfo.Prev;
        {$IFDEF V_WIN}
        GlobalUnlock(AllocInfo.Next);
        {$ENDIF}
      end;
      Dec(AllocGlobalBlocks);
    end;
    {$IFDEF V_WIN}
    GlobalUnlock(Mem);
    GlobalFree(Mem);
    {$ENDIF}
    {$IFDEF LINUX}
    free(Mem);
    {$ENDIF}
  finally
    LeaveCriticalSection(AllocCS);
  end;
  {$IFDEF STRICT_ALLOC_CHECK}
  if AllocInfo.Magic <> AllocMagic then // bad block?
    raise Exception.Create('Memory passed to FreeGlobal was not allocated by AllocGlobal');
  {$ENDIF}
  {$ELSE} {CHECK_ALLOC_GLOBAL}
  {$IFDEF V_WIN}
  GlobalFree(Mem);
  {$ENDIF}
  {$IFDEF LINUX}
  free(Mem);
  {$ENDIF}
  {$ENDIF} {CHECK_ALLOC_GLOBAL}
end;
{$ENDIF}

{$IFDEF V_FREEPASCAL}
{$IFDEF WIN32}
procedure RaiseLastWin32Error;
var
  LastError: UInt32;
  Error: EWin32Error;
begin
  LastError:=GetLastError;
  if LastError <> ERROR_SUCCESS then
    Error:=EWin32Error.CreateFmt('Win32 Error. Code: %d.'#10'%s', [LastError,
      SysErrorMessage(LastError)])
  else
    Error:=EWin32Error.Create('Win32 API function failed');
  Error.ErrorCode:=LastError;
  raise Error;
end;

function Win32Check(RetVal: Windows.BOOL): Windows.BOOL;
begin
  if not RetVal then
    RaiseLastWin32Error;
  Result:=RetVal;
end;
{$ENDIF} {WIN32}

procedure OSCheck(RetVal: Boolean);
begin
  if not RetVal then
    RaiseLastOSError;
end;
{$ENDIF} {V_FREEPASCAL}

{$IFDEF V_DELPHI}
{$IFDEF V_D3}

procedure OSCheck(RetVal: Boolean);
begin
  if not RetVal then
    {$IFDEF V_D6}
    RaiseLastOSError;
    {$ELSE}
    RaiseLastWin32Error;
    {$ENDIF}
end;

{$IFNDEF CLR}
procedure RaiseLastOSErrorEx(LastError: Integer);
var
  Error: EOSError;
begin
  if LastError <> 0 then
    Error:=EOSError.{$IFDEF V_D5}CreateResFmt(@{$ELSE}CreateFmt({$ENDIF}
      {$IFDEF V_D6}SOSError{$ELSE}SWin32Error{$ENDIF},
      [LastError, SysErrorMessage(LastError)])
  else
    Error:=EOSError.{$IFDEF V_D5}CreateRes(@{$ELSE}Create({$ENDIF}
      {$IFDEF V_D6}SUnkOSError{$ELSE}SUnkWin32Error{$ENDIF});
  Error.ErrorCode:=LastError;
  raise Error;
end;

{$IFNDEF V_D6}
procedure RaiseLastOSError;
begin
  RaiseLastWin32Error;
end;
{$ENDIF} {V_D6}

{$ENDIF} {CLR}
{$ENDIF} {V_D3}
{$ENDIF} {V_DELPHI}

{$IFDEF V_KYLIX}
function SysErrorMessageW(ErrorCode: Integer): WideString;
begin
  Result:=SysErrorMessage(ErrorCode);
end;
{$ENDIF}

{$IFDEF V_32}

function SafeDOSFileDateToDateTime(FileDate: Integer): TDateTime;
begin
  {$IFDEF V_WIN}
  Result:=SafeFileDateToDateTime(FileDate);
  {$ENDIF}
  {$IFDEF LINUX}
  try
    Result:=
      EncodeDate(
        LongRec(FileDate).Hi shr 9 + 1980,
        LongRec(FileDate).Hi shr 5 and 15,
        LongRec(FileDate).Hi and 31) +
      EncodeTime(
        LongRec(FileDate).Lo shr 11,
        LongRec(FileDate).Lo shr 5 and 63,
        LongRec(FileDate).Lo and 31 shl 1, 0);
  except
    Result:=DefaultDateTime;
  end
  {$ENDIF}
end;

function GetTimeZoneBias: Double;
{$IFDEF V_WIN}
var
  N: Integer;
  TzInfo: TTimeZoneInformation;
{$ENDIF}
{$IFDEF LINUX}
var
  abs_gmtoff: Integer;
  CurTime: TTime_T;
  LocalUnixTime: TUnixTime;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  Case GetTimeZoneInformation(TzInfo) of
    1{TIME_ZONE_ID_STANDARD}: N:=TzInfo.StandardBias;
    2{TIME_ZONE_ID_DAYLIGHT}: N:=TzInfo.DaylightBias;
  Else
    Result:=0;
    Exit;
  End;
  Result:=(N + TzInfo.Bias) / (24 * 60);
  {$ENDIF}
  {$IFDEF LINUX}
  if (__time(@CurTime) = -1) or (localtime_r(@CurTime, LocalUnixTime) = nil) then begin
    Result:=0;
    Exit;
  end;
  abs_gmtoff:=Abs(LocalUnixTime.__tm_gmtoff);
  Result:=EncodeTime(abs_gmtoff div 3600, (abs_gmtoff mod 3600) div 60, 0, 0);
  if LocalUnixTime.__tm_gmtoff < 0 then
    Result:=-Result;
  {$ENDIF}
end;

function GetTimeZoneStr: String;
{$IFDEF V_WIN}
var
  N: Integer;
  TzInfo: TTimeZoneInformation;
{$ENDIF}
{$IFDEF LINUX}
var
  H, M: Word;
  abs_gmtoff: Integer;
  CurTime: TTime_T;
  LocalUnixTime: TUnixTime;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  Case GetTimeZoneInformation(TzInfo) of
    1{TIME_ZONE_ID_STANDARD}: N:=TzInfo.StandardBias;
    2{TIME_ZONE_ID_DAYLIGHT}: N:=TzInfo.DaylightBias;
  Else
    Result:='GMT';
    Exit;
  End;
  Inc(N, TzInfo.Bias);
  if N > 0 then
    Result:='-'
  else begin
    Result:='+';
    N:=-N;
  end;
  Result:=Result + IntToStr2(N div 60) + IntToStr2(N mod 60);
  {$ENDIF}
  {$IFDEF LINUX}
  if (__time(@CurTime) = -1) or (localtime_r(@CurTime, LocalUnixTime) = nil) then begin
    Result:='GMT';
    Exit;
  end;
  if LocalUnixTime.__tm_gmtoff = 0 then begin
    Result:='GMT';
    Exit;
  end;
  abs_gmtoff:=Abs(LocalUnixTime.__tm_gmtoff);
  H:=abs_gmtoff div 3600;
  M:=(abs_gmtoff mod 3600) div 60;
  Result:=Format(' %0.2d%0.2d', [H, M]);
  if LocalUnixTime.__tm_gmtoff > 0 then
    Result[1]:='+'
  else
    Result[1]:='-';
  {$ENDIF}
end;

function UTCToLocalDateTime(const DateTime: TDateTime): TDateTime;
begin
  Result:=DateTime{$IFDEF V_WIN} - {$ENDIF}{$IFDEF LINUX} + {$ENDIF}
    GetTimeZoneBias; // local = UTC - bias (Windows); local = UTC + bias (Linux)
end;

function LocalToUTCDateTime(const DateTime: TDateTime): TDateTime;
begin
  Result:=DateTime{$IFDEF V_WIN} + {$ENDIF}{$IFDEF LINUX} - {$ENDIF}
    GetTimeZoneBias;
end;

{$ENDIF} {V_32}

{$IFNDEF CLR}
function DateTimeToPackedDT40(const DateTime: TDateTime;
  var PackedDT: TPackedDT40): Boolean;
var
  Date, Time: UInt32;
begin
  if (DateTime >= PackedDT40Lo) and (DateTime < PackedDT40Hi) then begin
    Date:=Trunc(DateTime) - PackedDT40Lo;
    Time:=Round(Frac(DateTime) * 134217728.0{ 2^27 });
    PackedDT.D.Lo32:=Time or Date shl 27;
    PackedDT.D.Hi8:=Date shr 5;
    Result:=True;
  end
  else begin
    PackedDT.D.Lo32:=0;
    PackedDT.D.Hi8:=0;
    Result:=False;
  end;
end;

function PackedDT40ToDateTime(const PackedDT: TPackedDT40): TDateTime;
begin
  Result:=PackedDT40Lo + (PackedDT.D.Lo32 shr 27 or PackedDT.D.Hi8 shl 5) +
    (PackedDT.D.Lo32 and $7FFFFFF) / 134217728.0{ 2^27 };
end;

{$IFDEF V_32}
function FileTimeToDateTime(const FileTime: TFileTime): TDateTime;
{
  TFileTime is a 64-bit value representing the number of 100-nanosecond
  intervals since January 1, 1601.

  TDateTime: the integral part is the number of days that have passed since
  12/30/1899. The fractional part of the TDateTime value is fraction of a 24
  hour day that has elapsed.
}
begin
  Result:=Int64(FileTime) / (1E7 * 24 * 60 * 60) - 109205;
  { 109205 = EncodeDate(1899, 12, 30) - EncodeDate(1601, 1, 1) }
end;

function ComparePackedDT40(const PackedDT1, PackedDT2: TPackedDT40): Integer;
begin
  Result:=PackedDT1.D.Hi8 - PackedDT2.D.Hi8;
  if Result = 0 then
    if PackedDT1.D.Lo32 > PackedDT2.D.Lo32 then
      Result:=1
    else
      if PackedDT1.D.Lo32 < PackedDT2.D.Lo32 then
        Result:=-1;
end;
{$ENDIF}

{$ENDIF} {CLR}

{$IFDEF V_WIN32}

{$IFNDEF V_FREEPASCAL}
{$IFNDEF CLR}
function SysErrorMessageW(ErrorCode: Integer): WideString;
var
  Len: Integer;
  Buf: array [0..511] of WideChar;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Len:=FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM or
      FORMAT_MESSAGE_ARGUMENT_ARRAY, nil, ErrorCode, 0, Buf, High(Buf), nil);
    while Len > 0 do begin
      Case Buf[Len - 1] of
        #0..#32, '.': Dec(Len);
      Else
        Break;
      End;
    end;
    Result:=CreateWideString(Buf, Len);
  end
  else
    Result:=SysErrorMessage(ErrorCode);
end;
{$ENDIF}
{$ENDIF} {V_FREEPASCAL}

{$IFNDEF V_D5}
function SameText(const S1, S2: String): Boolean; assembler;
asm
        CMP     EAX,EDX
        JZ      @1
        OR      EAX,EAX
        JZ      @2
        OR      EDX,EDX
        JZ      @3
        MOV     ECX,[EAX-4]
        CMP     ECX,[EDX-4]
        JNE     @3
        CALL    CompareText
        TEST    EAX,EAX
        JNZ     @3
@1:     MOV     AL,1
@2:     RET
@3:     XOR     EAX,EAX
end;
{$ENDIF}

{ Date/Time }

{$IFDEF V_FREEPASCAL}
function FileTimeToSystemTime(const lpFileTime: LPFILETIME;
  lpSystemTime: LPSYSTEMTIME): WINBOOL; stdcall; external kernel32;
{$ENDIF}

{$IFNDEF CLR}
function FileTimeToLocalDateTime(const FileTime: TFileTime): TDateTime;
var
  LocalFileTime: TFileTime;
begin
  OSCheck(FileTimeToLocalFileTime(FileTime, LocalFileTime));
  Result:=FileTimeToDateTime(LocalFileTime);
end;

function SafeFileTimeToDateTime(const FileTime: TFileTime): TDateTime;
begin
  try
    Result:=FileTimeToDateTime(FileTime);
  except
    Result:=DefaultDateTime;
  end;
end;

function SafeFileTimeToLocalDateTime(const FileTime: TFileTime): TDateTime;
begin
  try
    Result:=FileTimeToLocalDateTime(FileTime);
  except
    Result:=DefaultDateTime;
  end;
end;

function SafeDosDateTimeToDateTime(ADate, ATime: Word): TDateTime;
var
  FT: TFileTime;
begin
  if DosDateTimeToFileTime(ADate, ATime, FT) then
    Result:=FileTimeToDateTime(FT)
  else
    Result:=DefaultDateTime;
end;
{$ENDIF} {CLR}

{$IFDEF V_FREEPASCAL}
function SystemTimeToFileTime(var lpSystemTime: TSystemTime; lpFileTime: LPFILETIME): WINBOOL;
  stdcall; external kernel32;
{$ENDIF} {V_FREEPASCAL}

function DateTimeToFileTime(const DateTime: TDateTime): TFileTime;
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(DateTime, ST);
  OSCheck(SystemTimeToFileTime(ST, {$IFDEF V_FREEPASCAL}@{$ENDIF}Result));
end;

function SafeDateTimeToFileTime(const DateTime: TDateTime): TFileTime;
var
  ST: TSystemTime;
begin
  try
    DateTimeToSystemTime(DateTime, ST);
    OSCheck(SystemTimeToFileTime(ST, {$IFDEF V_FREEPASCAL}@{$ENDIF}Result));
  except
    Result.dwLowDateTime:=DefaultFileTimeLo;
    Result.dwHighDateTime:=DefaultFileTimeHi;
  end;
end;

function LocalDateTimeToFileTime(const DateTime: TDateTime): TFileTime;
var
  FileTime: TFileTime;
begin
  FileTime:=DateTimeToFileTime(DateTime);
  LocalFileTimeToFileTime(FileTime, Result);
end;

function SafeFileDateToDateTime(FileDate: Integer): TDateTime;
begin
  try
    Result:=FileDateToDateTime(FileDate);
  except
    Result:=DefaultDateTime;
  end;
end;

function SafeSystemTimeToDateTime(const ST: TSystemTime): TDateTime;
begin
  try
    Result:=SystemTimeToDateTime(ST);
  except
    Result:=DefaultDateTime;
  end;
end;

{$ENDIF} {V_WIN32}

function SameDateTime(D1, D2: TDateTime): Boolean;
begin
  Result:=Abs(D1 - D2) <= 1.15740741E-0008; { EncodeTime(0, 0, 0, 1) }
end;

function UnixDateTimeToDateTime(UnixDateTime: Int32): TDateTime;
const
  NumSecsInDay = 24 * 60 * 60;
begin
  Result:=25569{EncodeDate(1970, 1, 1)} + UnixDateTime / NumSecsInDay;
end;

{$IFDEF V_32}

function UnixDateTimeToLocalDateTime(UnixDateTime: Integer): TDateTime;
{$IFDEF V_WIN}
var
  UTime, LTime: TSystemTime;
  TZI: TTimeZoneInformation;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    DateTimeToSystemTime(UnixDateTimeToDateTime(UnixDateTime), UTime);
    if SystemTimeToTzSpecificLocalTime(nil,
      {$IFDEF V_FREEPASCAL}@{$ENDIF}UTime,
      {$IFDEF V_FREEPASCAL}@{$ENDIF}LTime) then
    begin
      Result:=SystemTimeToDateTime(LTime);
      Exit;
    end;
  end;
  if GetTimeZoneInformation(TZI) <> DWORD(-1) then
    Dec(UnixDateTime, TZI.Bias * 60);
{$ELSE}
begin
{$ENDIF}
  Result:=UnixDateTimeToDateTime(UnixDateTime);
end;

{$IFNDEF CLR}
function GetMemAlign(var P: Pointer; Size: Integer): Pointer;
const
  Align = 32;
begin
  GetMem(P, Size + Align);
  Result:=Pointer((Cardinal(P) + Align) and not (Align - 1));
end;

function GetMemIfNilAlign(var P: Pointer; Size: Integer): Pointer;
const
  Align = 32;
begin
  if P = nil then
    GetMem(P, Size + Align);
  Result:=Pointer((Cardinal(P) + Align) and not (Align - 1));
end;
{$ENDIF} {CLR}

{$ENDIF} {V_32}

function IntToStr2(I: Integer): String;
begin
  Result:=IntToStr(I);
  if Length(Result) < 2 then
    Result:='0' + Result;
end;

{$IFNDEF CLR}
function BigToLittleEndian32(From: Int32): Int32;
{$IFNDEF USE_ASM}
begin
  With DWordRec(Result) do begin
    Byte1:=DWordRec(From).Byte4;
    Byte2:=DWordRec(From).Byte3;
    Byte3:=DWordRec(From).Byte2;
    Byte4:=DWordRec(From).Byte1;
  end;
{$ELSE}
asm
        {$IFDEF V_FREEPASCAL}
        mov      eax, From
        {$ENDIF}
        xchg     al, ah
        ror      eax, 16
        xchg     al, ah
{$ENDIF}
end;
{$ENDIF}

{$IFDEF LINUX}
function GetTickCount: UInt32;
begin
  Result:=CLK_TCK * 1000;
end;
{$ENDIF}

{$IFDEF WIN32}{$IFDEF V_FREEPASCAL}
procedure InitPlatformId;
var
  OSVer: OSVersionInfo;
begin
  OSVer.dwOSVersionInfoSize:=SizeOf(OSVersionInfo);
  if GetVersionEx(OSVer) then
    Win32Platform:=OSVer.dwPlatformId;
end;
{$ENDIF}{$ENDIF}

{$IFDEF CHECK_ALLOC_GLOBAL}
procedure ShowUnfreedGlobalBlocks;
var
  I: Integer;
  S: String;
  CurInfo, PrevInfo: TGMEM;
  AllocInfo: PAllocInfoList;
begin
  if AllocGlobalBlocks = 0 then
    Exit;
  {$IFNDEF V_AUTOINITSTRINGS}
  S:='';
  {$ENDIF}
  CurInfo:=CurAllocInfo;
  for I:=0 to IntMin(AllocGlobalBlocks, 10) - 1 do begin
    if CurInfo = TGMEM(0) then // something wrong...
      Break;
    if S <> '' then
      S:=S + ^M;
    AllocInfo:={$IFDEF V_WIN}GlobalLock{$ENDIF}(CurInfo);
    if AllocInfo = nil then
      Break;
    AllocInfo:=Pointer(PChar(AllocInfo) + GlobalMemSize(CurInfo));
    S:=S + IntToHex(AllocInfo^.Id, 8);
    PrevInfo:=AllocInfo^.Prev;
    {$IFDEF V_WIN}
    GlobalUnlock(CurInfo);
    {$ENDIF}
    CurInfo:=PrevInfo;
  end; {for}
  S:=IntToStr(AllocGlobalBlocks) + ' blocks of memory allocated by ' +
    'AllocGlobal not freed.'^M +
    'IDs of these blocks (up to 10 last allocated):'^M + S;
  {$IFDEF V_WIN}
  MessageBox(0, PChar(S), nil, MB_OK or MB_ICONSTOP);
  {$ENDIF}
  {$IFDEF LINUX}
  writeln(S);
  {$ENDIF}
end;
{$ENDIF} {CHECK_ALLOC_GLOBAL}

{$IFDEF V_32}
initialization
  {$IFDEF CHECK_ALLOC_GLOBAL}
  InitializeCriticalSection(AllocCS);
  {$ENDIF}
  {$IFDEF WIN32}{$IFDEF V_FREEPASCAL}
  InitPlatformId;
  {$ENDIF}{$ENDIF}
  {$IFDEF LINUX}
  _euid:=geteuid;
  _egid:=getegid;
  {$ENDIF}
finalization
  {$IFDEF PATCHED_SYSUTILS}{$IFDEF CHECK_ALLOC_GLOBAL}
  if ShowUnfreedMem then
    ShowUnfreedGlobalBlocks;
  {$ENDIF}{$ENDIF}
  {$IFDEF CHECK_ALLOC_GLOBAL}
  DeleteCriticalSection(AllocCS);
  {$ENDIF}
{$ENDIF} {V_32}
end.
