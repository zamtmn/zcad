{ Version 050601. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit ExtType;

interface

{$I VCheck.inc}

{$IFDEF V_FREEPASCAL}uses SysUtils;{$ENDIF}

const
{$IFDEF V_32}
  {$IFDEF CLR}
  MaxBytes = 100 * 1048576; // 100 Mb
  {$ELSE}
  MaxBytes = MaxInt div 2; // 1073741823 = 2^30 - 1 (1Gb - 1)
  {$ENDIF}
{$ELSE}
  MaxBytes = 65527;
{$ENDIF}

  KILOBYTE = 1024;
  MEGABYTE = KILOBYTE * KILOBYTE;
  GIGABYTE = KILOBYTE * MEGABYTE;

{$IFNDEF LINUX}
  DefaultLineDelimiter = #13#10;
{$ELSE}
  DefaultLineDelimiter = #10;
{$ENDIF}

type
  Positive = 1..MaxInt;

  Int8 = ShortInt;
  UInt8 = Byte;
  Bool = Boolean;
{$IFDEF V_32}
  UInt32 = Cardinal;
{$ELSE}
  SmallInt = Integer;
  Cardinal = Word;
  UInt32 = 0..MaxLongInt;
{$ENDIF}
  Int16 = SmallInt;
  UInt16 = Word;
  Int32 = LongInt;
{$IFDEF INT64_EQ_COMP}
  Int64 = Comp;
{$ENDIF}

const
  BoolStr: array [Bool] of String[5] = ('False', 'True');

type
  DWord = UInt32;

  UInt = 0..MaxInt;

  Float32 = Single;
  Float64 = Double;
  Float80 = Extended;

  PInt8 = ^Int8;
  PUInt8 = ^UInt8;
  PBool = ^Bool;
  PBoolean = ^Boolean;
  PInt16 = ^Int16;
  PUInt16 = ^UInt16;
  PInt32 = ^Int32;
  PUInt32 = ^UInt32;
  PInt64 = ^Int64;
  PFloat32 = ^Float32;
  PFloat64 = ^Float64;
  PFloat80 = ^Float80;

  {$IFDEF BCB}
  PDateTime = ^TDateTime;
  {$ELSE}{$IFNDEF V_D4}
  PDateTime = ^TDateTime;
  {$ENDIF}{$ENDIF}

  PPointer = ^Pointer;
  {$IFDEF CLR}
  PAnsiString = ^AnsiString;
  PWideString = ^WideString;
  {$ENDIF}
  PVString = {$IFDEF V_LONGSTRINGS}PAnsiString{$ELSE}PString{$ENDIF};
  PPVString = ^PVString;
  {$IFDEF V_32}
  PPWideString = ^PWideString;
  {$ENDIF}

  {$IFNDEF V_WIN} { to prevent a conflict with Windows.PInteger }
  PInteger = ^Integer;
  {$ENDIF}

const
  MinFloat32 = 1.5E-45; { from Delphi 3 Help }
  MaxFloat32 = 3.4E+38;
  MinFloat64 = 5.0E-324;
  MaxFloat64 = 1.7E+308;
  MinFloat80 = 3.4E-4932;
{$IFNDEF V_FREEPASCAL}
  MaxFloat80 = 1.1E+4932;
{$ELSE} { FPC 0.99.14 GO32 V2 bug fix (-g mode) }
  MaxFloat80 = 1.1E+4931;
{$ENDIF}

{$IFDEF FLOAT_EQ_FLOAT32}
type
  Float = Float32;
const
  { MinFloat и MaxFloat должны храниться в памяти, иначе возможно, что после
    T:=MaxFloat сравнение (T < MaxFloat) даст результат "True" }
  { MinFloat and MaxFloat should be stored in memory, otherwise it's possible
    that after T:=MaxFloat the comparison (T < MaxFloat) will give "True" }
  MinFloat: Float = MinFloat32;
  MaxFloat: Float = MaxFloat32;
{$ELSE} {$IFDEF FLOAT_EQ_FLOAT64}
type
  Float = Float64;
const
  MinFloat: Float = MinFloat64;
  MaxFloat: Float = MaxFloat64;
{$ELSE} {$IFDEF FLOAT_EQ_FLOAT80}
type
  Float = Float80;
const
  MinFloat: Float = MinFloat80;
  MaxFloat: Float = MaxFloat80;
{$ENDIF} {$ENDIF} {$ENDIF}

type
  PFloat = ^Float;

  TBase8 = packed record case Byte of
    0:  (AsUInt8: UInt8);
    1:  (AsInt8: Int8);
    2:  (AsBool: Bool);
    3:  (AsChar: Char);
  end;

  TBase16 = packed record case Byte of
    0:  (AsUInt16: UInt16);
    1:  (AsInt16: Int16);
  end;

  TBase32 = packed record case Byte of
    0:  (AsInt32: Int32);
    1:  (AsUInt32: UInt32);
    2:  (AsFloat32: Float32);
  end;

  TBase64 = packed record case Byte of
    0: (AsInt64: Int64);
    1: (AsFloat64: Float64);
  end;

  {$IFDEF CLR}
  WordRec = packed record
    Lo, Hi: UInt16;
  end;
  {$ENDIF}

  DWordRec = packed record case Byte of
    0: (Lo, Hi: UInt16);
    1: (Byte1, Byte2, Byte3, Byte4: UInt8);
  end;

  QWordRec = packed record case Byte of
    0: (Lo, Hi: UInt32);
    1: (Word1, Word2, Word3, Word4: UInt16);
    2: (Byte1, Byte2, Byte3, Byte4, Byte5, Byte6, Byte7, Byte8: UInt8);
  end;

  TInt8Array = array [0..MaxBytes] of Int8;
  TUInt8Array = array [0..MaxBytes] of UInt8;
  TBoolArray = array [0..MaxBytes] of Bool;

  TCharArray = array [0..MaxBytes] of Char;

  TInt16Array = array [0..MaxBytes div SizeOf(Int16)] of Int16;
  TUInt16Array = array [0..MaxBytes div SizeOf(UInt16)] of UInt16;

  TInt32Array = array [0..MaxBytes div SizeOf(Int32)] of Int32;
  TUInt32Array = array [0..MaxBytes div SizeOf(UInt32)] of UInt32;
  TInt64Array = array [0..MaxBytes div SizeOf(Int64)] of Int64;

  TFloat32Array = array [0..MaxBytes div SizeOf(Float32)] of Float32;
  TFloat64Array = array [0..MaxBytes div SizeOf(Float64)] of Float64;
  TFloat80Array = array [0..MaxBytes div SizeOf(Float80)] of Float80;

  TFloatArray = array [0..MaxBytes div SizeOf(Float)] of Float;

  PFloat32Array = ^TFloat32Array;
  PFloat64Array = ^TFloat64Array;
  PFloat80Array = ^TFloat80Array;

  PFloatArray = ^TFloatArray;

  PInt8Array = ^TInt8Array;
  PUInt8Array = ^TUInt8Array;
  PBoolArray = ^TBoolArray;

  PCharArray = ^TCharArray;

  PInt16Array = ^TInt16Array;
  PUInt16Array = ^TUInt16Array;

  PInt32Array = ^TInt32Array;
  PUInt32Array = ^TUInt32Array;
  PInt64Array = ^TInt64Array;

  {$IFNDEF CLR}
  TBase8Array = array [0..MaxBytes] of TBase8;
  TBase16Array = array [0..MaxBytes div SizeOf(TBase16)] of TBase16;
  TBase32Array = array [0..MaxBytes div SizeOf(TBase32)] of TBase32;
  TBase64Array = array [0..MaxBytes div SizeOf(TBase64)] of TBase64;

  PBase8Array = ^TBase8Array;
  PBase16Array = ^TBase16Array;
  PBase32Array = ^TBase32Array;
  PBase64Array = ^TBase64Array;

  TPointerArray = array [0..MaxBytes div SizeOf(Pointer)] of Pointer;
  TPVStringArray = array [0..MaxBytes div SizeOf(PVString)] of PVString;
  TObjectArray = array [0..MaxBytes div SizeOf(TObject)] of TObject;

  PPointerArray = ^TPointerArray;
  PPVStringArray = ^TPVStringArray;
  PObjectArray = ^TObjectArray;

  PRegular = ^TRegular;
  TRegular = record case Byte of
    0: (Int8Array: TInt8Array);
    1: (UInt8Array: TUInt8Array);
    2: (BoolArray: TBoolArray);
    3: (CharArray: TCharArray);
    4: (Int16Array: TInt16Array);
    5: (UInt16Array: TUInt16Array);
    6: (Int32Array: TInt32Array);
    7: (UInt32Array: TUInt32Array);
    8: (Int64Array: TInt64Array);
    9: (PointerArray: TPointerArray);
    10: (PVStringArray: TPVStringArray);
    11: (ObjectArray: TObjectArray);
    12: (Float32Array: TFloat32Array);
    13: (Float64Array: TFloat64Array);
    14: (Float80Array: TFloat80Array);
  end;
  {$ENDIF}

function UpRound(X: Extended): LongInt;
{ в отличие от System.Round, округляет вещественные числа, дробная часть которых
  равна 0.5, всегда "вверх" (Round округляет числа с четной целой частью "вниз",
  а с нечетной - "вверх", т.е. Round(1.5) = Round(2.5) = 2; UpRound(2.5) = 2);
  т.е. если Frac(X) = 0.5 то UpRound(X) = Trunc(X) + 1 иначе UpRound(X) = Round(X) }
{ unlike System.Round always rounds off floating-point numbers which fractional
  part is equal to 0.5 "upward" (Round rounds off numbers with even integral
  part "downward" and with odd one - "upward", i.e. Round(1.5) = Round(2.5) = 2;
  UpRound(2.5) = 2); i.e. if Frac(X) = 0.5 then UpRound(X) = Trunc(X) + 1 else
  UpRound(X) = Round(X) }

{$IFDEF V_DELPHI}{$IFNDEF V_D3}
procedure SetLength(var S: String; ALength: Byte);
procedure SetString(var S: String; Buffer: PChar; Len: Integer);
{$ENDIF}{$ENDIF}

{$IFNDEF BCB}
function IntToComp(I: Integer): Comp;
{$ENDIF}

{$IFDEF V_FREEPASCAL}
procedure Abort;
{$ENDIF}

{$IFNDEF V_D5}
procedure FreeAndNil(var Obj);
{$ENDIF}

type
  TVNotifyEvent = procedure (Sender: TObject) of object;

  TVProgressEvent = function (UserData: Pointer): Boolean of object;
  { позволяет прерывать длительные операции; UserData - это "пользовательский"
    указатель, ранее переданный объекту, который вызывает данное событие, кодом,
    инициировавшим длительную операцию; событие возвращает True, чтобы
    продолжить выполнение операции, и False, чтобы прервать её }
  { allows to interrupt long operations; UserData is a "user" pointer supplied
    earlier to the object which calls this event by the code initiated the long
    operation; the event returns True to continue the operation and False to
    interrupt it }

  PVProgressData = ^TVProgressData;
  TVProgressData = record case ProgressType: (
    ptNone, ptIntPercent, ptFloatPercent, ptInt32{$IFDEF V_32}, ptInt64{$ENDIF})
  of
    ptNone: ();
    ptIntPercent: (iPercent: Int32);
    ptFloatPercent: (fPercent: Float32);
    ptInt32: (Done32, Total32: Int32);
    {$IFDEF V_32}
    ptInt64: (Done64, Total64: Int64);
    {$ENDIF}
  end;

  TVProgressEventEx = function (const Info: PVProgressData;
    UserData: Pointer): Boolean of object;
  { расширенный вариант TVProgressEvent, который позволяет информировать
    сторону, инициировавшую длительную операцию, о ходе её выполнения }
  { extended variant of TVProgressEvent which allows to inform the code which
    initiated the long operation about its progress }

  {$IFDEF V_INTERFACE}
  IProgress = interface
    function Progress(Done, Total: Integer): Boolean; stdcall;
  end;
  {$ENDIF}

implementation

function UpRound(X: Extended): LongInt;
begin
(*  Result:=Trunc(X) + Trunc(Frac(X) * 2); { медленнее (на AMD K6-2, Celeron) }*)
  if X >= 0 then X:=X + 0.5 else X:=X - 0.5;
  Result:=Trunc(X);
end;

{$IFDEF V_DELPHI}{$IFNDEF V_D3}
procedure SetLength(var S: String; ALength: Byte);
begin
  S[0]:=Chr(ALength);
end;

procedure SetString(var S: String; Buffer: PChar; Len: Integer);
begin
  if Len > 255 then
    Len:=255;
  S[0]:=Chr(Len);
  Move(Buffer^, S[1], Len);
end;
{$ENDIF}{$ENDIF}

{$IFNDEF BCB}
function IntToComp(I: Integer): Comp;
begin
  Result:=I;
end;
{$ENDIF}

{$IFDEF V_FREEPASCAL}
procedure Abort;
begin
  raise Exception.Create('Abort');
end;
{$ENDIF}

{$IFNDEF V_D5}
procedure FreeAndNil(var Obj);
var
  P: TObject;
begin
  P:=TObject(Obj);
  TObject(Obj):=nil; { clear the reference before destroying the object }
  P.Free;
end;
{$ENDIF}

end.
