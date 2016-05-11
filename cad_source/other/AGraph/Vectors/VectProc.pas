{ Version 040823. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VectProc;

interface

{$I VCheck.inc}
{$IFDEF V_D3}{$J+}{$ENDIF}

{
 Операции над логическими, целочисленными и вещественными векторами.
 Ассемблерные фрагменты оптимизированы (если они оптимизированы) под
 процессоры класса Pentium.

 Внимание:
 1. В ассемблерных процедурах не реализованы проверки на выход из диапазона и
    переполнение, поэтому при включенных опциях компилятора R или Q ассемблерные
    фрагменты не используются.
 2. Для включения MMX-вариантов процедур и функций необходимо разрешить
    использование ассемблера (USE_ASM).
 3. Расширенные наборы команд 3DNow! (K6-2 и др.) и SSE (Pentium III и др.)
    в настоящее время не поддерживаются.
}

{$IFDEF USE_ASM}
  {$IFOPT R-} {$IFOPT Q-}
    {$DEFINE USE_ASM_VECT}
      {$IFDEF USE_MMX}
        {$DEFINE USE_MMX_VECT}
      {$ENDIF}
    {$IFDEF USE_3DNow}
      {$DEFINE USE_3DNow_VECT}
    {$ENDIF}
  {$ENDIF} {$ENDIF}
{$ENDIF}

uses
  ExtType{$IFDEF USE_MMX_VECT}, CheckCPU{$ENDIF};

procedure AndBoolProc(var Vector1; const Vector2; Count: Integer);
procedure OrBoolProc(var Vector1; const Vector2; Count: Integer);
procedure XorBoolProc(var Vector1; const Vector2; Count: Integer);
procedure NotBoolProc(var Vector1; const Vector2; Count: Integer);
function BoolDominateFunc(const Vector1, Vector2; Count: Integer): Bool;

procedure AddInt8Proc(var Vector1; const Vector2; Count: Integer);
procedure SubInt8Proc(var Vector1; const Vector2; Count: Integer);
procedure AddUInt8Proc(var Vector1; const Vector2; Count: Integer);
procedure SubUInt8Proc(var Vector1; const Vector2; Count: Integer);
procedure AddInt16Proc(var Vector1; const Vector2; Count: Integer);
procedure SubInt16Proc(var Vector1; const Vector2; Count: Integer);
procedure AddUInt16Proc(var Vector1; const Vector2; Count: Integer);
procedure SubUInt16Proc(var Vector1; const Vector2; Count: Integer);
procedure AddInt32Proc(var Vector1; const Vector2; Count: Integer);
procedure SubInt32Proc(var Vector1; const Vector2; Count: Integer);
procedure AddUInt32Proc(var Vector1; const Vector2; Count: Integer);
procedure SubUInt32Proc(var Vector1; const Vector2; Count: Integer);
procedure AddInt64Proc(var Vector1; const Vector2; Count: Integer);
procedure SubInt64Proc(var Vector1; const Vector2; Count: Integer);

procedure AddFloat32Proc(var Vector1; const Vector2; Count: Integer);
procedure SubFloat32Proc(var Vector1; const Vector2; Count: Integer);
procedure AddFloat64Proc(var Vector1; const Vector2; Count: Integer);
procedure SubFloat64Proc(var Vector1; const Vector2; Count: Integer);
procedure AddFloat80Proc(var Vector1; const Vector2; Count: Integer);
procedure SubFloat80Proc(var Vector1; const Vector2; Count: Integer);

procedure AddScalarInt8Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarInt8Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarUInt8Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarUInt8Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarInt16Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarInt16Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarUInt16Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarUInt16Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarInt32Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarInt32Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarUInt32Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarUInt32Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarInt64Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarInt64Proc(var Vector1; const Value; Count: Integer);

procedure MulVectorFloat32Proc(var Vector1; const Vector2; Count: Integer);
procedure MulVectorFloat64Proc(var Vector1; const Vector2; Count: Integer);
procedure MulVectorFloat80Proc(var Vector1; const Vector2; Count: Integer);

procedure DivVectorFloat32Proc(var Vector1; const Vector2; Count: Integer);
procedure DivVectorFloat64Proc(var Vector1; const Vector2; Count: Integer);
procedure DivVectorFloat80Proc(var Vector1; const Vector2; Count: Integer);

procedure MulScalarInt8Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarInt8Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarUInt8Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarUInt8Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarInt16Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarInt16Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarUInt16Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarUInt16Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarInt32Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarInt32Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarUInt32Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarUInt32Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarInt64Proc(var Vector1; const Value; Count: Integer);
procedure DivScalarInt64Proc(var Vector1; const Value; Count: Integer);

procedure AddScalarFloat32Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarFloat32Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarFloat64Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarFloat64Proc(var Vector1; const Value; Count: Integer);
procedure AddScalarFloat80Proc(var Vector1; const Value; Count: Integer);
procedure SubScalarFloat80Proc(var Vector1; const Value; Count: Integer);

procedure MulScalarFloat32Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarFloat64Proc(var Vector1; const Value; Count: Integer);
procedure MulScalarFloat80Proc(var Vector1; const Value; Count: Integer);

procedure AddScaledFloat32Proc(var Vector1; const Vector2; Count: Integer;
  Factor: Float80);
procedure AddScaledFloat64Proc(var Vector1; const Vector2; Count: Integer;
  Factor: Float80);
procedure AddScaledFloat80Proc(var Vector1; const Vector2; Count: Integer;
  Factor: Float80);

function SumInt8Func(const Vector1, Dummy; Count: Integer): Int32;
function SumUInt8Func(const Vector1, Dummy; Count: Integer): Int32;
function SumInt16Func(const Vector1, Dummy; Count: Integer): Int32;
function SumUInt16Func(const Vector1, Dummy; Count: Integer): Int32;
function SumInt32Func(const Vector1, Dummy; Count: Integer): Int32;
function SumUInt32Func(const Vector1, Dummy; Count: Integer): Int32;

function SumFloat32Func(const Vector1, Dummy; Count: Integer): Float80;
function SqrSumFloat32Func(const Vector1, Dummy; Count: Integer): Float80;
function SumFloat64Func(const Vector1, Dummy; Count: Integer): Float80;
function SqrSumFloat64Func(const Vector1, Dummy; Count: Integer): Float80;
function SumFloat80Func(const Vector1, Dummy; Count: Integer): Float80;
function SqrSumFloat80Func(const Vector1, Dummy; Count: Integer): Float80;

function DotProductInt16Func(const Vector1, Vector2; Count: Integer): Int32;

function DotProductFloat32Func(const Vector1, Vector2; Count: Integer): Float80;
function DotProductFloat64Func(const Vector1, Vector2; Count: Integer): Float80;
function DotProductFloat80Func(const Vector1, Vector2; Count: Integer): Float80;

procedure MatrixProductInt8Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductUInt8Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductInt16Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductUInt16Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductInt32Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductUInt32Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductInt64Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductFloat32Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductFloat64Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
procedure MatrixProductFloat80Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);

function XorUInt8(P: PUInt8; Count: Integer): UInt8;
function XorUInt16(P: PUInt16; Count: Integer): UInt16;

type
  TVectProc = procedure (var Vector1; const Vector2; Count: Integer);

  TVectFuncInt32 = function (const Vector1, Vector2; Count: Integer): Int32;

  TVectFuncFloat80 = function (const Vector1, Vector2; Count: Integer): Float80;

  TAddScaledProc = procedure (var Vector1; const Vector2; Count: Integer;
    Factor: Float80);

  TMatrixProductProc = procedure (var Result; const Matrix1, Matrix2;
    ResultRowCount, ResultColCount, Matrix1ColCount: Integer);

  TVectProcs = (
    AddInt8, SubInt8, AddUInt8, SubUInt8,
    AddInt16, SubInt16, AddUInt16, SubUInt16, 
    AddInt32, SubInt32, AddUInt32, SubUInt32,
    AddInt64, SubInt64,
    AddScalarInt8, SubScalarInt8, AddScalarUInt8, SubScalarUInt8,
    AddScalarInt16, SubScalarInt16, AddScalarUInt16, SubScalarUInt16,
    AddScalarInt32, SubScalarInt32, AddScalarUInt32, SubScalarUInt32,
    AddScalarInt64, SubScalarInt64,
    MulVectFloat32, MulVectFloat64, MulVectFloat80,
    DivVectFloat32, DivVectFloat64, DivVectFloat80,
    MulScalarInt8, DivScalarInt8, MulScalarUInt8, DivScalarUInt8,
    MulScalarInt16, DivScalarInt16, MulScalarUInt16, DivScalarUInt16,
    MulScalarInt32, DivScalarInt32, MulScalarUInt32, DivScalarUInt32,
    MulScalarInt64, DivScalarInt64,
    AddFloat32, SubFloat32,
    AddFloat64, SubFloat64,
    AddFloat80, SubFloat80,
    AddScalarFloat32, SubScalarFloat32,
    AddScalarFloat64, SubScalarFloat64,
    AddScalarFloat80, SubScalarFloat80,
    MulScalarFloat32, MulScalarFloat64, MulScalarFloat80);

  TVectFuncsInt32 = (SumInt8, SumUInt8, SumInt16, SumUInt16, SumInt32, SumUInt32,
    DotProductInt16);

  TVectFuncsFloat80 = (SumFloat32, SumFloat64, SumFloat80,
    SqrSumFloat32, SqrSumFloat64, SqrSumFloat80,
    DotProductFloat32, DotProductFloat64, DotProductFloat80);

  TAddScaled = (AddScaledFloat32, AddScaledFloat64, AddScaledFloat80);

  TMatrixProduct = (MatrixProductInt8, MatrixProductUInt8, MatrixProductInt16,
    MatrixProductUInt16, MatrixProductInt32, MatrixProductUInt32,
    MatrixProductInt64,
    MatrixProductFloat32, MatrixProductFloat64, MatrixProductFloat80);

const
  VectProcs: array [TVectProcs] of TVectProc = (
{$IFNDEF USE_ASM_VECT} { signed and unsigned procedures are different (due to R+, Q+) }
    AddInt8Proc, SubInt8Proc, AddUInt8Proc, SubUInt8Proc,
    AddInt16Proc, SubInt16Proc, AddUInt16Proc, SubUInt16Proc, 
    AddInt32Proc, SubInt32Proc, AddUInt32Proc, SubUInt32Proc,
    AddInt64Proc, SubInt64Proc,
    AddScalarInt8Proc, SubScalarInt8Proc, AddScalarUInt8Proc, SubScalarUInt8Proc,
    AddScalarInt16Proc, SubScalarInt16Proc, AddScalarUInt16Proc, SubScalarUInt16Proc,
    AddScalarInt32Proc, SubScalarInt32Proc, AddScalarUInt32Proc, SubScalarUInt32Proc,
{$ELSE} { signed and unsigned procedures are the same }
    AddInt8Proc, SubInt8Proc, AddInt8Proc, SubInt8Proc,
    AddInt16Proc, SubInt16Proc, AddInt16Proc, SubInt16Proc, 
    AddInt32Proc, SubInt32Proc, AddInt32Proc, SubInt32Proc,
    AddInt64Proc, SubInt64Proc,
    AddScalarInt8Proc, SubScalarInt8Proc, AddScalarInt8Proc, SubScalarInt8Proc,
    AddScalarInt16Proc, SubScalarInt16Proc, AddScalarInt16Proc, SubScalarInt16Proc,
    AddScalarInt32Proc, SubScalarInt32Proc, AddScalarInt32Proc, SubScalarInt32Proc,
{$ENDIF}
    AddScalarInt64Proc, SubScalarInt64Proc,
    MulVectorFloat32Proc, MulVectorFloat64Proc, MulVectorFloat80Proc,
    DivVectorFloat32Proc, DivVectorFloat64Proc, DivVectorFloat80Proc,
    MulScalarInt8Proc, DivScalarInt8Proc, MulScalarUInt8Proc, DivScalarUInt8Proc,
    MulScalarInt16Proc, DivScalarInt16Proc, MulScalarUInt16Proc, DivScalarUInt16Proc,
    MulScalarInt32Proc, DivScalarInt32Proc, MulScalarUInt32Proc, DivScalarUInt32Proc,
    MulScalarInt64Proc, DivScalarInt64Proc,
    AddFloat32Proc, SubFloat32Proc,
    AddFloat64Proc, SubFloat64Proc,
    AddFloat80Proc, SubFloat80Proc,
    AddScalarFloat32Proc, SubScalarFloat32Proc,
    AddScalarFloat64Proc, SubScalarFloat64Proc,
    AddScalarFloat80Proc, SubScalarFloat80Proc,
    MulScalarFloat32Proc, MulScalarFloat64Proc, MulScalarFloat80Proc);

  VectFuncsInt32: array [TVectFuncsInt32] of TVectFuncInt32 = (
{$IFNDEF USE_ASM_VECT} { signed and unsigned procedures are different (due to R+, Q+) }
    SumInt8Func, SumUInt8Func, SumInt16Func, SumUInt16Func,
    SumInt32Func, SumUInt32Func,
{$ELSE} { signed and unsigned procedures are the same }
    SumInt8Func, SumInt8Func, SumInt16Func, SumInt16Func,
    SumInt32Func, SumInt32Func,
{$ENDIF}
    DotProductInt16Func);

  VectFuncsFloat80: array [TVectFuncsFloat80] of TVectFuncFloat80 = (
    SumFloat32Func, SumFloat64Func, SumFloat80Func,
    SqrSumFloat32Func, SqrSumFloat64Func, SqrSumFloat80Func,
    DotProductFloat32Func, DotProductFloat64Func, DotProductFloat80Func);

  AddScaledProcs: array [TAddScaled] of TAddScaledProc = (
    AddScaledFloat32Proc, AddScaledFloat64Proc,
    AddScaledFloat80Proc);

  MatrixProductProcs: array [TMatrixProduct] of TMatrixProductProc = (
    MatrixProductInt8Proc, MatrixProductUInt8Proc, MatrixProductInt16Proc,
    MatrixProductUInt16Proc, MatrixProductInt32Proc, MatrixProductUInt32Proc,
    MatrixProductInt64Proc,
    MatrixProductFloat32Proc, MatrixProductFloat64Proc, MatrixProductFloat80Proc);

implementation

procedure AndBoolProc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TBoolArray(Vector1)[I]:=TBoolArray(Vector1)[I] and TBoolArray(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        push     ecx
        mov      esi, edx
        shr      ecx, 2
        mov      edx, eax
        jz       @@Continue
@@DwordOp:
        lodsd
        and      [edx], eax
        add      edx, 4
        dec      ecx
        jnz      @@DwordOp
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@ByteOp:
        lodsb
        and      [edx], al
        inc      edx
        dec      ecx
        jnz      @@ByteOp
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure OrBoolProc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TBoolArray(Vector1)[I]:=TBoolArray(Vector1)[I] or TBoolArray(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        push     ecx
        mov      esi, edx
        shr      ecx, 2
        mov      edx, eax
        jz       @@Continue
@@DwordOp:
        lodsd
        or       [edx], eax
        add      edx, 4
        dec      ecx
        jnz      @@DwordOp
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@ByteOp:
        lodsb
        or       [edx], al
        inc      edx
        dec      ecx
        jnz      @@ByteOp
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure XorBoolProc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TBoolArray(Vector1)[I]:=TBoolArray(Vector1)[I] xor TBoolArray(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        push     ecx
        mov      esi, edx
        shr      ecx, 2
        mov      edx, eax
        jz       @@Continue
@@DwordOp:
        lodsd
        xor      [edx], eax
        add      edx, 4
        dec      ecx
        jnz      @@DwordOp
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@ByteOp:
        lodsb
        xor      [edx], al
        inc      edx
        dec      ecx
        jnz      @@ByteOp
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure NotBoolProc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TBoolArray(Vector1)[I]:=not TBoolArray(Vector1)[I];
end;
{$ELSE}
asm
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, ecx
        and      edx, 3 // 11b
        shr      ecx, 2
        jz       @@Continue
@@DwordOp:
        xor      dword ptr [eax], $01010101
        add      eax, 4
        dec      ecx
        jnz      @@DwordOp
@@Continue:
        mov      ecx, edx
        jecxz    @@End
@@ByteOp:
        xor      dword ptr [eax], $01
        inc      eax
        dec      ecx
        jnz      @@ByteOp
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function BoolDominateFunc(const Vector1, Vector2; Count: Integer): Bool;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    if TBoolArray(Vector2)[I] and not TBoolArray(Vector1)[I] then begin
      Result:=False;
      Exit;
    end;
  Result:=True;
end;

procedure AddInt8Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt8Array(Vector1)[I]:=TInt8Array(Vector1)[I] + TInt8Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
        push     ecx
        shr      ecx, 1
        jz       @@Continue
        push     ebx
@@Loop: mov	 al, [edx]
	mov	 bl, [esi]
	mov	 ah, [edx + 1]
	mov	 bh, [esi + 1]
	add	 al, bl
	add	 ah, bh
	mov	 [edx], al
	mov	 [edx + 1], ah
	add	 esi, 2
	add	 edx, 2
	dec	 ecx
	jnz	 @@Loop
        pop      ebx
@@Continue:
        pop      ecx
        test     ecx, 1
        jz       @@Skip
        mov      al, [esi]
        add      [edx], al
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubInt8Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt8Array(Vector1)[I]:=TInt8Array(Vector1)[I] - TInt8Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
        push     ecx
        shr      ecx, 1
        jz       @@Continue
        push     ebx
@@Loop: mov	 al, [edx]
	mov	 bl, [esi]
	mov	 ah, [edx + 1]
	mov	 bh, [esi + 1]
	sub	 al, bl
	sub	 ah, bh
	mov	 [edx], al
	mov	 [edx + 1], ah
	add	 esi, 2
	add	 edx, 2
	dec	 ecx
	jnz	 @@Loop
        pop      ebx
@@Continue:
        pop      ecx
        test     ecx, 1
        jz       @@Skip
        mov      al, [esi]
        sub      [edx], al
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddUInt8Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt8Array(Vector1)[I]:=TUInt8Array(Vector1)[I] + TUInt8Array(Vector2)[I];
end;

procedure SubUInt8Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt8Array(Vector1)[I]:=TUInt8Array(Vector1)[I] - TUInt8Array(Vector2)[I];
end;

procedure AddInt16Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt16Array(Vector1)[I]:=TInt16Array(Vector1)[I] + TInt16Array(Vector2)[I];
end;

procedure SubInt16Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt16Array(Vector1)[I]:=TInt16Array(Vector1)[I] - TInt16Array(Vector2)[I];
end;

procedure AddUInt16Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt16Array(Vector1)[I]:=TUInt16Array(Vector1)[I] + TUInt16Array(Vector2)[I];
end;

procedure SubUInt16Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt16Array(Vector1)[I]:=TUInt16Array(Vector1)[I] - TUInt16Array(Vector2)[I];
end;

procedure AddInt32Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt32Array(Vector1)[I]:=TInt32Array(Vector1)[I] + TInt32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
        push     ecx
        shr      ecx, 1
        jz       @@Continue
        push     ebx
@@Loop: mov	 eax, [esi]
	mov	 ebx, [esi + 4]
	add	 [edx], eax
	add	 [edx + 4], ebx
	add	 esi, 8
	add	 edx, 8
	dec	 ecx
	jnz	 @@Loop
        pop      ebx
@@Continue:
        pop      ecx
        test     ecx, 1
        jz       @@Skip
        mov      eax, [esi]
        add      [edx], eax
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubInt32Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt32Array(Vector1)[I]:=TInt32Array(Vector1)[I] - TInt32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
        push     ecx
        shr      ecx, 1
        jz       @@Continue
        push     ebx
@@Loop: mov	 eax, [esi]
	mov	 ebx, [esi + 4]
	sub	 [edx], eax
	sub	 [edx + 4], ebx
	add	 esi, 8
	add	 edx, 8
	dec	 ecx
	jnz	 @@Loop
        pop      ebx
@@Continue:
        pop      ecx
        test     ecx, 1
        jz       @@Skip
        mov      eax, [esi]
        sub      [edx], eax
@@Skip:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddUInt32Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt32Array(Vector1)[I]:=TUInt32Array(Vector1)[I] + TUInt32Array(Vector2)[I];
end;

procedure SubUInt32Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt32Array(Vector1)[I]:=TUInt32Array(Vector1)[I] - TUInt32Array(Vector2)[I];
end;

procedure AddInt64Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt64Array(Vector1)[I]:=TInt64Array(Vector1)[I] + TInt64Array(Vector2)[I];
end;

procedure SubInt64Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt64Array(Vector1)[I]:=TInt64Array(Vector1)[I] - TInt64Array(Vector2)[I];
end;

procedure AddFloat32Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] + TFloat32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      dword ptr [eax + ecx * 4]
        fadd     dword ptr [edx + ecx * 4]
        fstp     dword ptr [eax + ecx * 4]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubFloat32Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] - TFloat32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      dword ptr [eax + ecx * 4]
        fsub     dword ptr [edx + ecx * 4]
        fstp     dword ptr [eax + ecx * 4]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddFloat64Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] + TFloat64Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      qword ptr [eax + ecx * 8]
        fadd     qword ptr [edx + ecx * 8]
        fstp     qword ptr [eax + ecx * 8]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubFloat64Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] - TFloat64Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      qword ptr [eax + ecx * 8]
        fsub     qword ptr [edx + ecx * 8]
        fstp     qword ptr [eax + ecx * 8]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddFloat80Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] + TFloat80Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
@@Loop: fld      tbyte ptr [eax]
        fld      tbyte ptr [edx]
        faddp
        add      edx, 10
        fstp     tbyte ptr [eax]
        add      eax, 10
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubFloat80Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] - TFloat80Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
@@Loop: fld      tbyte ptr [eax]
        fld      tbyte ptr [edx]
        db 0DEh, 0E9h // fsubp    st(1), st { work-around for Free Pascal bug }
        add      edx, 10
        fstp     tbyte ptr [eax]
        add      eax, 10
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScalarInt8Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt8Array(Vector1)[I]:=TInt8Array(Vector1)[I] + Int8(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
@@Loop: add	 [eax], dl
        inc      eax
        dec      ecx
        jnz      @@Loop
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubScalarInt8Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt8Array(Vector1)[I]:=TInt8Array(Vector1)[I] - Int8(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
@@Loop: sub	 [eax], dl
        inc      eax
        dec      ecx
        jnz      @@Loop
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScalarUInt8Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt8Array(Vector1)[I]:=TUInt8Array(Vector1)[I] + UInt8(Value);
end;

procedure SubScalarUInt8Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt8Array(Vector1)[I]:=TUInt8Array(Vector1)[I] - UInt8(Value);
end;

procedure AddScalarInt16Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt16Array(Vector1)[I]:=TInt16Array(Vector1)[I] + Int16(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
@@Loop: add	 [eax], dx
        add      eax, 2
        dec      ecx
        jnz      @@Loop
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubScalarInt16Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt16Array(Vector1)[I]:=TInt16Array(Vector1)[I] - Int16(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
@@Loop: sub	 [eax], dx
        add      eax, 2
        dec      ecx
        jnz      @@Loop
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScalarUInt16Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt16Array(Vector1)[I]:=TUInt16Array(Vector1)[I] + UInt16(Value);
end;

procedure SubScalarUInt16Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt16Array(Vector1)[I]:=TUInt16Array(Vector1)[I] - UInt16(Value);
end;

procedure AddScalarInt32Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt32Array(Vector1)[I]:=TInt32Array(Vector1)[I] + Int32(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
@@Loop: add	 [eax], edx
        add      eax, 4
        dec      ecx
        jnz      @@Loop
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubScalarInt32Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt32Array(Vector1)[I]:=TInt32Array(Vector1)[I] - Int32(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
@@Loop: sub	 [eax], edx
        add      eax, 4
        dec      ecx
        jnz      @@Loop
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScalarUInt32Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt32Array(Vector1)[I]:=TUInt32Array(Vector1)[I] + UInt32(Value);
end;

procedure SubScalarUInt32Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt32Array(Vector1)[I]:=TUInt32Array(Vector1)[I] - UInt32(Value);
end;

procedure AddScalarInt64Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt64Array(Vector1)[I]:=TInt64Array(Vector1)[I] + Int64(Value);
end;

procedure SubScalarInt64Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt64Array(Vector1)[I]:=TInt64Array(Vector1)[I] - Int64(Value);
end;

procedure MulVectorFloat32Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] * TFloat32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      dword ptr [eax + ecx * 4]
        fmul     dword ptr [edx + ecx * 4]
        fstp     dword ptr [eax + ecx * 4]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure MulVectorFloat64Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] * TFloat64Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      qword ptr [eax + ecx * 8]
        fmul     qword ptr [edx + ecx * 8]
        fstp     qword ptr [eax + ecx * 8]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure MulVectorFloat80Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] * TFloat80Array(Vector2)[I];
end;

procedure DivVectorFloat32Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] / TFloat32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      dword ptr [eax + ecx * 4]
        fdiv     dword ptr [edx + ecx * 4]
        fstp     dword ptr [eax + ecx * 4]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure DivVectorFloat64Proc(var Vector1; const Vector2; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] / TFloat64Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        dec      ecx
@@Loop: fld      qword ptr [eax + ecx * 8]
        fdiv     qword ptr [edx + ecx * 8]
        fstp     qword ptr [eax + ecx * 8]
        dec      ecx
        jge      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure DivVectorFloat80Proc(var Vector1; const Vector2; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] / TFloat80Array(Vector2)[I];
end;

procedure MulScalarInt8Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt8Array(Vector1)[I]:=TInt8Array(Vector1)[I] * Int8(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
        push     ecx
        and      edx, 0FFh
        shr      ecx, 1
        jz       @@Continue
        push     ebx
@@WordOp:
        xor      ebx, ebx
        mov      bl, [eax]
        shl      ebx, 16
        mov      bl, [eax + 1]
        imul     ebx, edx
        mov      [eax + 1], bl
        shr      ebx, 16
        mov      [eax], bl
        add      eax, 2
        dec      ecx
        jnz      @@WordOp
        pop      ebx
@@Continue:
        pop      ecx
        test     ecx, 1
        jz       @@End
        imul     edx, [eax]
        mov      [eax], dl
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure DivScalarInt8Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt8Array(Vector1)[I]:=TInt8Array(Vector1)[I] div Int8(Value);
end;

procedure MulScalarUInt8Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt8Array(Vector1)[I]:=TUInt8Array(Vector1)[I] * UInt8(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     esi
        mov      ebx, [edx]
        mov      esi, eax
        push     ecx
        and      ebx, 0FFh
        shr      ecx, 1
        jz       @@Continue
@@WordOp:
        xor      eax, eax
        mov      al, [esi]
        shl      eax, 16
        mov      al, [esi + 1]
        mul      ebx
        mov      [esi + 1], al
        shr      eax, 16
        mov      [esi], al
        add      esi, 2
        dec      ecx
        jnz      @@WordOp
@@Continue:
        pop      ecx
        test     ecx, 1
        jz       @@Finish
        mov      al, [esi]
        mul      bl
        mov      [esi], al
@@Finish:
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure DivScalarUInt8Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt8Array(Vector1)[I]:=TUInt8Array(Vector1)[I] div UInt8(Value);
end;

procedure MulScalarInt16Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt16Array(Vector1)[I]:=TInt16Array(Vector1)[I] * Int16(Value);
end;

procedure DivScalarInt16Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt16Array(Vector1)[I]:=TInt16Array(Vector1)[I] div Int16(Value);
end;

procedure MulScalarUInt16Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt16Array(Vector1)[I]:=TUInt16Array(Vector1)[I] * UInt16(Value);
end;

procedure DivScalarUInt16Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt16Array(Vector1)[I]:=TUInt16Array(Vector1)[I] div UInt16(Value);
end;

procedure MulScalarInt32Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt32Array(Vector1)[I]:=TInt32Array(Vector1)[I] * Int32(Value);
end;

procedure DivScalarInt32Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt32Array(Vector1)[I]:=TInt32Array(Vector1)[I] div Int32(Value);
end;

procedure MulScalarUInt32Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt32Array(Vector1)[I]:=TUInt32Array(Vector1)[I] * UInt32(Value);
end;

procedure DivScalarUInt32Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TUInt32Array(Vector1)[I]:=TUInt32Array(Vector1)[I] div UInt32(Value);
end;

procedure MulScalarInt64Proc(var Vector1; const Value; Count: Integer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt64Array(Vector1)[I]:=TInt64Array(Vector1)[I] * Int64(Value);
end;

procedure DivScalarInt64Proc(var Vector1; const Value; Count: Integer);
{$IFDEF V_DELPHI}
  {$IFNDEF V_D4}{$DEFINE FLOATDIV}{$ENDIF}
  {$IFDEF INT64_EQ_COMP}{$DEFINE FLOATDIV}{$ENDIF}
{$ENDIF}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TInt64Array(Vector1)[I]:=
      TInt64Array(Vector1)[I]{$IFDEF FLOATDIV}/{$ELSE}div{$ENDIF}Int64(Value);
end;

procedure AddScalarFloat32Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] + Float32(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      dword ptr [edx]
@@Loop: fld      dword ptr [eax]
        fadd     st, st(1)
        add      eax, 4
        fstp     dword ptr [eax - 4]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubScalarFloat32Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] - Float32(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      dword ptr [edx]
@@Loop: fld      dword ptr [eax]
        fsub     st, st(1)
        add      eax, 4
        fstp     dword ptr [eax - 4]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScalarFloat64Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] + Float64(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      qword ptr [edx]
@@Loop: fld      qword ptr [eax]
        fadd     st, st(1)
        add      eax, 8
        fstp     qword ptr [eax - 8]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubScalarFloat64Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] - Float64(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      qword ptr [edx]
@@Loop: fld      qword ptr [eax]
        fsub     st, st(1)
        add      eax, 8
        fstp     qword ptr [eax - 8]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScalarFloat80Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] + Float80(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      tbyte ptr [edx]
@@Loop: fld      tbyte ptr [eax]
        fadd     st, st(1)
        add      eax, 10
        fstp     tbyte ptr [eax - 10]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure SubScalarFloat80Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] - Float80(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      tbyte ptr [edx]
@@Loop: fld      tbyte ptr [eax]
        fsub     st, st(1)
        add      eax, 10
        fstp     tbyte ptr [eax - 10]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure MulScalarFloat32Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] * Float32(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      dword ptr [edx]
@@Loop: fld      dword ptr [eax]
        fmul     st, st(1)
        add      eax, 4
        fstp     dword ptr [eax - 4]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure MulScalarFloat64Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] * Float64(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      qword ptr [edx]
@@Loop: fld      qword ptr [eax]
        fmul     st, st(1)
        add      eax, 8
        fstp     qword ptr [eax - 8]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure MulScalarFloat80Proc(var Vector1; const Value; Count: Integer);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] * Float80(Value);
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        fld      tbyte ptr [edx]
@@Loop: fld      tbyte ptr [eax]
        fmul     st, st(1)
        add      eax, 10
        fstp     tbyte ptr [eax - 10]
        dec      ecx
        jnz      @@Loop
        ffree    st
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScaledFloat32Proc(var Vector1; const Vector2; Count: Integer;
  Factor: Float80);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat32Array(Vector1)[I]:=TFloat32Array(Vector1)[I] +
      Factor * TFloat32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        push     esi
        xor      esi, esi
        sub      ecx, 3
        jl       @@Continue
@@Op3:  fld      tbyte ptr Factor
        fmul     dword ptr [edx + esi * 4]
        fld      tbyte ptr Factor
        fmul     dword ptr [edx + esi * 4 + 4]
        fxch     st(1)
        fadd     dword ptr [eax + esi * 4]
        fld      tbyte ptr Factor
        fmul     dword ptr [edx + esi * 4 + 8]
        fxch     st(2)
        fadd     dword ptr [eax + esi * 4 + 4]
        fxch     st(1)
        fstp     dword ptr [eax + esi * 4]
        fxch     st(1)
        fadd     dword ptr [eax + esi * 4 + 8]
        fxch     st(1)
        fstp     dword ptr [eax + esi * 4 + 4]
        fstp     dword ptr [eax + esi * 4 + 8]
        add      esi, 3
        sub      ecx, 3
        jge      @@Op3
@@Continue:
        add      ecx, 3
        jz       @@Skip
@@Op1:  fld      tbyte ptr Factor
        fmul     dword ptr [edx + esi * 4]
        fadd     dword ptr [eax + esi * 4]
        fstp     dword ptr [eax + esi * 4]
        inc      esi
        dec      ecx
        jnz      @@Op1
@@Skip:
        pop      esi
        fwait
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScaledFloat64Proc(var Vector1; const Vector2; Count: Integer;
  Factor: Float80);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat64Array(Vector1)[I]:=TFloat64Array(Vector1)[I] +
      Factor * TFloat64Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        push     esi
        xor      esi, esi
        sub      ecx, 3
        jl       @@Continue
@@Op3:  fld      tbyte ptr Factor
        fmul     qword ptr [edx + esi * 8]
        fld      tbyte ptr Factor
        fmul     qword ptr [edx + esi * 8 + 8]
        fxch     st(1)
        fadd     qword ptr [eax + esi * 8]
        fld      tbyte ptr Factor
        fmul     qword ptr [edx + esi * 8 + 16]
        fxch     st(2)
        fadd     qword ptr [eax + esi * 8 + 8]
        fxch     st(1)
        fstp     qword ptr [eax + esi * 8]
        fxch     st(1)
        fadd     qword ptr [eax + esi * 8 + 16]
        fxch     st(1)
        fstp     qword ptr [eax + esi * 8 + 8]
        fstp     qword ptr [eax + esi * 8 + 16]
        add      esi, 3
        sub      ecx, 3
        jge      @@Op3
@@Continue:
        add      ecx, 3
        jz       @@Skip
@@Op1:  fld      tbyte ptr Factor
        fmul     qword ptr [edx + esi * 8]
        fadd     qword ptr [eax + esi * 8]
        fstp     qword ptr [eax + esi * 8]
        inc      esi
        dec      ecx
        jnz      @@Op1
@@Skip:
        pop      esi
        fwait
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

procedure AddScaledFloat80Proc(var Vector1; const Vector2; Count: Integer;
  Factor: Float80);
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TFloat80Array(Vector1)[I]:=TFloat80Array(Vector1)[I] +
      Factor * TFloat80Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        sub      ecx, 3
        jl       @@Continue           // st(0)         st(1)         st(2)
@@Op3:  fld      tbyte ptr Factor     // F
        fld      tbyte ptr [edx]      // v2(0)         F
        fmulp                         // v2(0)*F
        fld      tbyte ptr Factor     // F             v2(0)*F
        fld      tbyte ptr [edx + 10] // v2(1)         F             v2(0)*F
        fmulp                         // v2(1)*F       v2(0)*F
        fxch     st(1)                // v2(0)*F       v2(1)*F
        fld      tbyte ptr [eax]      // v1(0)         v2(0)*F       v2(1)*F
        faddp                         // v1(0)+v2(0)*F v2(1)*F
        fld      tbyte ptr Factor     // F             v1(0)+v2(0)*F v2(1)*F
        fld      tbyte ptr [edx + 20] // v2(2)         F             v1(0)+v2(0)*F ...
        fmulp                         // v2(2)*F       v1(0)+v2(0)*F v2(1)*F
        fxch     st(2)                // v2(1)*F       v1(0)+v2(0)*F v2(2)*F
        fld      tbyte ptr [eax + 10] // v1(1)         v2(1)*F       v1(0)+v2(0)*F ...
        faddp                         // v1(1)+v2(1)*F v1(0)+v2(0)*F v2(2)*F
        fxch     st(1)                // v1(0)+v2(0)*F v1(1)+v2(1)*F v2(2)*F
        fstp     tbyte ptr [eax]      // v1(1)+v2(1)*F v2(2)*F
        fxch     st(1)                // v2(2)*F       v1(1)+v2(1)*F
        fld      tbyte ptr [eax + 20] // v1(2)         v2(2)*F       v1(1)+v2(1)*F
        faddp                         // v1(2)+v2(2)*F v1(1)+v2(1)*F
        fxch     st(1)                // v1(1)+v2(1)*F v1(2)+v2(2)*F
        fstp     tbyte ptr [eax + 10] // v1(2)+v2(2)*F
        add      edx, 30
        fstp     tbyte ptr [eax + 20]
        add      eax, 30
        sub      ecx, 3
        jge      @@Op3
@@Continue:
        add      ecx, 3
        jz       @@Skip
@@Op1:  fld      tbyte ptr Factor
        fld      tbyte ptr [edx]
        fmulp
        fld      tbyte ptr [eax]
        faddp
        fstp     tbyte ptr [eax]
        add      edx, 10
        add      eax, 10
        dec      ecx
        jnz      @@Op1
@@Skip:
        fwait
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SumInt8Func(const Vector1, Dummy; Count: Integer): Int32;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TInt8Array(Vector1)[I];
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
        xor      edx, edx
        or       ecx, ecx
        jle      @@End
        push     esi
        push     ecx
        mov      esi, eax
        xor      eax, eax
        shr      ecx, 2
        jz       @@Continue
        push     ebx
        xor      ebx, ebx
@@Loop: mov	 al, [esi]
        mov	 bl, [esi + 1]
        add      edx, eax
        mov	 al, [esi + 2]
        add      edx, ebx
        mov	 bl, [esi + 3]
        add      edx, eax
        add	 esi, 4
        add      edx, ebx
        dec	 ecx
        jnz	 @@Loop
        pop      ebx
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@ByteOp:
        mov      al, [esi]
        inc      esi
        add      edx, eax
        dec      ecx
        jnz      @@ByteOp
@@Skip:
        pop      esi
@@End:
        mov      eax, edx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SumUInt8Func(const Vector1, Dummy; Count: Integer): Int32;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TUInt8Array(Vector1)[I];
end;

function SumInt16Func(const Vector1, Dummy; Count: Integer): Int32;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TInt16Array(Vector1)[I];
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
        xor      edx, edx
        or       ecx, ecx
        jle      @@End
        push     esi
        push     ecx
        mov      esi, eax
        xor      eax, eax
        shr      ecx, 2
        jz       @@Continue
        push     ebx
        xor      ebx, ebx
@@Loop: mov	 ax, [esi]
        mov	 bx, [esi + 2]
        add      edx, eax
        mov	 ax, [esi + 4]
        add      edx, ebx
        mov	 bx, [esi + 6]
        add      edx, eax
        add	 esi, 8
        add      edx, ebx
        dec	 ecx
        jnz	 @@Loop
        pop      ebx
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@WordOp:
        mov      ax, [esi]
        add      esi, 2
        add      edx, eax
        dec      ecx
        jnz      @@WordOp
@@Skip:
        pop      esi
@@End:
        mov      eax, edx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SumUInt16Func(const Vector1, Dummy; Count: Integer): Int32;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TUInt16Array(Vector1)[I];
end;

function SumInt32Func(const Vector1, Dummy; Count: Integer): Int32;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TInt32Array(Vector1)[I];
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
{$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        push     esi
        mov      esi, eax
        xor      eax, eax
        or       ecx, ecx
        jle      @@End
@@DWordOp:
        add      eax, [esi]
        add      esi, 4
        dec      ecx
        jnz      @@DWordOp
@@End:
        pop      esi
{$ELSE}
// more effective: based on Math unit, Copyright (C) 1996,99 Inprise Corporation
// loop unrolled 4 times, 5 clocks per loop, 1.2 clocks per datum
      MOV  EDX, EAX         // EDX = ptr to data
      XOR  EAX, EAX
      or   ecx, ecx
      jle  @@End
      dec  ecx
      PUSH EBX
      MOV  EBX, ECX
      AND  ECX, not 3
      AND  EBX, 3
      SHL  ECX, 2
      JMP  @Vector.Pointer[EBX*4]
@Vector:
      DD   @@1
      DD   @@2
      DD   @@3
      DD   @@4
@@4:  ADD  EAX, [ECX+EDX+12]
@@3:  ADD  EAX, [ECX+EDX+8]
@@2:  ADD  EAX, [ECX+EDX+4]
@@1:  ADD  EAX, [ECX+EDX]
      SUB  ECX, 16
      JNS  @@4
      POP  EBX
@@End:
{$ENDIF}
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SumUInt32Func(const Vector1, Dummy; Count: Integer): Int32;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do UInt32(Result):=UInt32(Result) + TUInt32Array(Vector1)[I];
end;

function SumFloat32Func(const Vector1, Dummy; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TFloat32Array(Vector1)[I];
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
(*
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fadd     dword ptr [eax]
        add      eax, 4
        dec      ecx
        jnz      @@Loop
        fwait
*)
// more effective: based on Math unit, Copyright (C) 1996,99 Inprise Corporation
        FLDZ
        or       ecx, ecx
        jle      @@End
        dec      ecx
        MOV      EDX, ECX
        FLD      ST(0)
        AND      EDX, not 3
        FLD      ST(0)
        AND      ECX, 3
        FLD      ST(0)
        SHL      EDX, 2      // count * sizeof(Single) = count * 4
        {$IFNDEF V_FREEPASCAL}
        JMP      @Vector.Pointer[ECX*4]
@Vector:
        DD @@1
        DD @@2
        DD @@3
        DD @@4
        {$ELSE} // Free Pascal doesn't accept "@Vector.Pointer"
        jecxz    @@1
        cmp      ecx, 1
        jz       @@2
        cmp      ecx, 2
        jz       @@3
        {$ENDIF}
@@4:    FADD     dword ptr [EAX+EDX+12]    // 1
        FXCH     ST(3)                     // 0
@@3:    FADD     dword ptr [EAX+EDX+8]     // 1
        FXCH     ST(2)                     // 0
@@2:    FADD     dword ptr [EAX+EDX+4]     // 1
        FXCH     ST(1)                     // 0
@@1:    FADD     dword ptr [EAX+EDX]       // 1
        FXCH     ST(2)                     // 0
        SUB      EDX, 16
        JNS      @@4
        FADDP    ST(3), ST                 // ST(3) := ST + ST(3); Pop ST
        FADDP                              // ST(1) := ST + ST(1); Pop ST
        FADDP                              // ST(1) := ST + ST(1); Pop ST
        FWAIT
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SqrSumFloat32Func(const Vector1, Dummy; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + Sqr(TFloat32Array(Vector1)[I]);
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      dword ptr [eax]
        fmul     st(0), st(0)
        add      eax, 4
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SumFloat64Func(const Vector1, Dummy; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TFloat64Array(Vector1)[I];
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
(*
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fadd     qword ptr [eax]
        add      eax, 8
        dec      ecx
        jnz      @@Loop
        fwait
*)
// more effective: based on Math unit, Copyright (C) 1996,99 Inprise Corporation }
// Uses 4 accumulators to minimize read-after-write delays and loop overhead
// 5 clocks per loop, 4 items per loop = 1.2 clocks per item
        FLDZ
        or       ecx, ecx
        jle      @@End
        dec      ecx
        MOV      EDX, ECX
        FLD      ST(0)
        AND      EDX, not 3
        FLD      ST(0)
        AND      ECX, 3
        FLD      ST(0)
        SHL      EDX, 3      // count * sizeof(Double) = count * 8
        {$IFNDEF V_FREEPASCAL}
        JMP      @Vector.Pointer[ECX*4]
@Vector:
        DD @@1
        DD @@2
        DD @@3
        DD @@4
        {$ELSE} // Free Pascal doesn't accept "@Vector.Pointer"
        jecxz    @@1
        cmp      ecx, 1
        jz       @@2
        cmp      ecx, 2
        jz       @@3
        {$ENDIF}
@@4:    FADD     qword ptr [EAX+EDX+24]    // 1
        FXCH     ST(3)                     // 0
@@3:    FADD     qword ptr [EAX+EDX+16]    // 1
        FXCH     ST(2)                     // 0
@@2:    FADD     qword ptr [EAX+EDX+8]     // 1
        FXCH     ST(1)                     // 0
@@1:    FADD     qword ptr [EAX+EDX]       // 1
        FXCH     ST(2)                     // 0
        SUB      EDX, 32
        JNS      @@4
        FADDP    ST(3), ST                 // ST(3) := ST + ST(3); Pop ST
        FADDP                              // ST(1) := ST + ST(1); Pop ST
        FADDP                              // ST(1) := ST + ST(1); Pop ST
        FWAIT
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SqrSumFloat64Func(const Vector1, Dummy; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + Sqr(TFloat64Array(Vector1)[I]);
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      qword ptr [eax]
        fmul     st(0), st(0)
        add      eax, 8
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SumFloat80Func(const Vector1, Dummy; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + TFloat80Array(Vector1)[I];
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      tbyte ptr [eax]
        add      eax, 10
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function SqrSumFloat80Func(const Vector1, Dummy; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result + Sqr(TFloat80Array(Vector1)[I]);
end;
{$ELSE}
asm     // eax = @Vector1, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      tbyte ptr [eax]
        fmul     st(0), st(0)
        add      eax, 10
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function DotProductInt16Func(const Vector1, Vector2; Count: Integer): Int32;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    Result:=Result + Int32(TInt16Array(Vector1)[I]) * TInt16Array(Vector2)[I];
end;

function DotProductFloat32Func(const Vector1, Vector2; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result +
    TFloat32Array(Vector1)[I] * TFloat32Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      dword ptr [eax]
        fld      dword ptr [edx]
        fmulp
        add      eax, 4
        add      edx, 4
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function DotProductFloat64Func(const Vector1, Vector2; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result +
    TFloat64Array(Vector1)[I] * TFloat64Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      qword ptr [eax]
        fld      qword ptr [edx]
        fmulp
        add      eax, 8
        add      edx, 8
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

function DotProductFloat80Func(const Vector1, Vector2; Count: Integer): Float80;
{$IFNDEF USE_ASM_VECT}
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do Result:=Result +
    TFloat80Array(Vector1)[I] * TFloat80Array(Vector2)[I];
end;
{$ELSE}
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        fldz
        or       ecx, ecx
        jle      @@End
@@Loop: fld      tbyte ptr [eax]
        fld      tbyte ptr [edx]
        fmulp
        add      eax, 10
        add      edx, 10
        faddp
        dec      ecx
        jnz      @@Loop
        fwait
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF}

{$IFDEF USE_MMX_VECT}

procedure AddInt8ProcMMX(var Vector1; const Vector2; Count: Integer);
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     ecx
        shr      ecx, 3
        jz       @@Continue
@@QwordOp:
        db       0Fh, 06Fh, 0 // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0FCh, 2 // 00000010b     // PADDB mm0, [edx]
        db       0Fh, 07Fh, 0 // 00000000b     // MOVQ [eax], mm0
        add      edx, 8
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 7 // 111b
        jz       @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
@@ByteOp:
        lodsb
        add      [edx], al
        inc      edx
        dec      ecx
        jnz      @@ByteOp
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure SubInt8ProcMMX(var Vector1; const Vector2; Count: Integer);
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     ecx
        shr      ecx, 3
        jz       @@Continue
@@QwordOp:
        db       0Fh, 06Fh, 0 // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0F8h, 2 // 00000010b     // PSUBB mm0, [edx]
        db       0Fh, 07Fh, 0 // 00000000b     // MOVQ [eax], mm0
        add      edx, 8
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 7 // 111b
        jz       @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
@@ByteOp:
        lodsb
        sub      [edx], al
        inc      edx
        dec      ecx
        jnz      @@ByteOp
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure AddInt16ProcMMX(var Vector1; const Vector2; Count: Integer);
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     ecx
        shr      ecx, 2
        jz       @@Continue
@@QwordOp:
        db       0Fh, 06Fh, 0 // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0FDh, 2 // 00000010b     // PADDW mm0, [edx]
        db       0Fh, 07Fh, 0 // 00000000b     // MOVQ [eax], mm0
        add      edx, 8
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
@@ByteOp:
        lodsw
        add      [edx], ax
        add      edx, 2
        dec      ecx
        jnz      @@ByteOp
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure SubInt16ProcMMX(var Vector1; const Vector2; Count: Integer);
asm     // eax = @Vector1, edx = @Vector2, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Vector2
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        push     ecx
        shr      ecx, 2
        jz       @@Continue
@@QwordOp:
        db       0Fh, 06Fh, 0 // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0F9h, 2 // 00000010b     // PSUBW mm0, [edx]
        db       0Fh, 07Fh, 0 // 00000000b     // MOVQ [eax], mm0
        add      edx, 8
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@End
        push     esi
        mov      esi, edx
        mov      edx, eax
@@ByteOp:
        lodsw
        sub      [edx], ax
        add      edx, 2
        dec      ecx
        jnz      @@ByteOp
        pop      esi
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure MulScalarInt16ProcMMX(var Vector1; const Value; Count: Integer);
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
        push     ebx
        and      edx, 0FFFFh
        push     ecx
        shr      ecx, 2
        jz       @@Continue
        mov      ebx, edx
        shl      ebx, 16
        or       ebx, edx
        db       0Fh, 06Eh, 0C3h     // 11000011b     // MOVD mm0, ebx
        db       0Fh, 06Fh, 0C8h     // 11001000b     // MOVQ mm1, mm0
        db       0Fh, 073h, 0F0h, 32 // 11110000b, 32 // PSLLQ mm0, 32
        db       0Fh, 0EBh, 0C8h     // 11001000b     // POR mm1, mm0
@@QwordOp:
        db       0Fh, 06Fh, 0    // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0D5h, 0C1h // 11000001b     // PMULLW mm0, mm1
        db       0Fh, 07Fh, 0    // 00000000b     // MOVQ [eax], mm0
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
        mov      ebx, edx
@@WordOp:
        mov      dx, [eax]
        imul     edx, ebx
        mov      [eax], dx
        add      eax, 2
        dec      ecx
        jnz      @@WordOp
@@Skip:
        pop      ebx
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure AddScalarInt8ProcMMX(var Vector1; const Value; Count: Integer);
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
        push     ebx
        push     ecx
        shr      ecx, 3
        jz       @@Continue
        mov      dh, dl
        mov      bx, dx
        shl      ebx, 16
        mov      bx, dx
        db       0Fh, 06Eh, 0C3h     // 11000011b     // MOVD mm0, ebx
        db       0Fh, 06Fh, 0C8h     // 11001000b     // MOVQ mm1, mm0
        db       0Fh, 073h, 0F0h, 32 // 11110000b, 32 // PSLLQ mm0, 32
        db       0Fh, 0EBh, 0C8h     // 11001000b     // POR mm1, mm0
@@QwordOp:
        db       0Fh, 06Fh, 0    // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0FCh, 0C1h // 11000001b     // PADDB mm0, mm1
        db       0Fh, 07Fh, 0    // 00000000b     // MOVQ [eax], mm0
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 7 // 111b
        jz       @@Skip
@@ByteOp:
        add      [eax], dl
        inc      eax
        dec      ecx
        jnz      @@ByteOp
@@Skip:
        pop      ebx
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure SubScalarInt8ProcMMX(var Vector1; const Value; Count: Integer);
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
        push     ebx
        push     ecx
        shr      ecx, 3
        jz       @@Continue
        mov      dh, dl
        mov      bx, dx
        shl      ebx, 16
        mov      bx, dx
        db       0Fh, 06Eh, 0C3h     // 11000011b     // MOVD mm0, ebx
        db       0Fh, 06Fh, 0C8h     // 11001000b     // MOVQ mm1, mm0
        db       0Fh, 073h, 0F0h, 32 // 11110000b, 32 // PSLLQ mm0, 32
        db       0Fh, 0EBh, 0C8h     // 11001000b     // POR mm1, mm0
@@QwordOp:
        db       0Fh, 06Fh, 0    // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0F8h, 0C1h // 11000001b     // PSUBB mm0, mm1
        db       0Fh, 07Fh, 0    // 00000000b     // MOVQ [eax], mm0
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 7 // 111b
        jz       @@Skip
@@ByteOp:
        sub      [eax], dl
        inc      eax
        dec      ecx
        jnz      @@ByteOp
@@Skip:
        pop      ebx
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure AddScalarInt16ProcMMX(var Vector1; const Value; Count: Integer);
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
        push     ebx
        push     ecx
        shr      ecx, 2
        jz       @@Continue
        mov      bx, dx
        shl      ebx, 16
        mov      bx, dx
        db       0Fh, 06Eh, 0C3h     // 11000011b     // MOVD mm0, ebx
        db       0Fh, 06Fh, 0C8h     // 11001000b     // MOVQ mm1, mm0
        db       0Fh, 073h, 0F0h, 32 // 11110000b, 32 // PSLLQ mm0, 32
        db       0Fh, 0EBh, 0C8h     // 11001000b     // POR mm1, mm0
@@QwordOp:
        db       0Fh, 06Fh, 0    // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0FDh, 0C1h // 11000001b     // PADDW mm0, mm1
        db       0Fh, 07Fh, 0    // 00000000b     // MOVQ [eax], mm0
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@WordOp:
        add      [eax], dx
        add      eax, 2
        dec      ecx
        jnz      @@WordOp
@@Skip:
        pop      ebx
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

procedure SubScalarInt16ProcMMX(var Vector1; const Value; Count: Integer);
asm     // eax = @Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        or       ecx, ecx
        jle      @@End
        mov      edx, [edx]
        push     ebx
        push     ecx
        shr      ecx, 2
        jz       @@Continue
        mov      bx, dx
        shl      ebx, 16
        mov      bx, dx
        db       0Fh, 06Eh, 0C3h     // 11000011b     // MOVD mm0, ebx
        db       0Fh, 06Fh, 0C8h     // 11001000b     // MOVQ mm1, mm0
        db       0Fh, 073h, 0F0h, 32 // 11110000b, 32 // PSLLQ mm0, 32
        db       0Fh, 0EBh, 0C8h     // 11001000b     // POR mm1, mm0
@@QwordOp:
        db       0Fh, 06Fh, 0    // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0F9h, 0C1h // 11000001b     // PSUBW mm0, mm1
        db       0Fh, 07Fh, 0    // 00000000b     // MOVQ [eax], mm0
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
@@WordOp:
        sub      [eax], dx
        add      eax, 2
        dec      ecx
        jnz      @@WordOp
@@Skip:
        pop      ebx
@@End:
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

function DotProductInt16FuncMMX(const Vector1, Value; Count: Integer): Int32;
asm     // eax = Vector1, edx = @Value, ecx = Count
        {$IFDEF V_FREEPASCAL}
        mov      eax, Vector1
        mov      ecx, Count
        mov      edx, Value
        {$ENDIF}
        push     ebx
        xor      ebx, ebx  // accumulator
        or       ecx, ecx
        jle      @@End
        push     esi
        push     ecx
        shr      ecx, 2
        jz       @@Continue
@@QwordOp:
        db       0Fh, 06Fh, 0        // 00000000b     // MOVQ mm0, [eax]
        db       0Fh, 0F5h, 2        // 00000010b     // PMADDWD mm0, [edx]
        db       0Fh, 07Eh, 0C6h     // 11000110b     // MOVD esi, mm0
        db       0Fh, 073h, 0D0h, 32 // 11010000b, 32 // PSRLQ mm0, 32
        add      ebx, esi
        db       0Fh, 07Eh, 0C6h // 11000110b     // MOVD esi, mm0
        add      ebx, esi
        add      edx, 8
        add      eax, 8
        dec      ecx
        jnz      @@QwordOp
        db       0Fh, 77h                 // EMMS
@@Continue:
        pop      ecx
        and      ecx, 3 // 11b
        jz       @@Skip
        push     edi
        mov      esi, edx
        mov      edi, eax
        xor      edx, edx
@@WordOp:
        mov      dx, [edi]
        xor      eax, eax
        lodsw
        imul     eax, edx
        add      edi, 2
        add      ebx, eax
        dec      ecx
        jnz      @@WordOp
        pop      edi
@@Skip:
        pop      esi
@@End:
        mov      eax, ebx
        pop      ebx
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};

{$ENDIF} {USE_MMX_VECT}

procedure MatrixProductInt8Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Int8;
  ArrayType = TInt8Array;
{$I MatrProd.inc}

procedure MatrixProductUInt8Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = UInt8;
  ArrayType = TUInt8Array;
{$I MatrProd.inc}

procedure MatrixProductInt16Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Int16;
  ArrayType = TInt16Array;
{$I MatrProd.inc}

procedure MatrixProductUInt16Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = UInt16;
  ArrayType = TUInt16Array;
{$I MatrProd.inc}

procedure MatrixProductInt32Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Int32;
  ArrayType = TInt32Array;
{$I MatrProd.inc}

procedure MatrixProductUInt32Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = UInt32;
  ArrayType = TUInt32Array;
{$I MatrProd.inc}

procedure MatrixProductInt64Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Int64;
  ArrayType = TInt64Array;
{$I MatrProd.inc}

procedure MatrixProductFloat32Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Float32;
  ArrayType = TFloat32Array;
{$I MatrProd.inc}

procedure MatrixProductFloat64Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Float64;
  ArrayType = TFloat64Array;
{$I MatrProd.inc}

procedure MatrixProductFloat80Proc(var Result; const Matrix1, Matrix2;
  ResultRowCount, ResultColCount, Matrix1ColCount: Integer);
type
  NumberType = Float80;
  ArrayType = TFloat80Array;
{$I MatrProd.inc}

function XorUInt8(P: PUInt8; Count: Integer): UInt8;
begin
  Result:=0;
  while Count > 0 do begin
    Result:=Result xor P^;
    Inc(P);
    Dec(Count);
  end;
end;

function XorUInt16(P: PUInt16; Count: Integer): UInt16;
begin
  Result:=0;
  while Count > 0 do begin
    Result:=Result xor P^;
    Inc(P);
    Dec(Count);
  end;
end;

initialization
  {$IFDEF USE_MMX_VECT}
  if MMXCPU then begin
    VectProcs[AddInt8]:=AddInt8ProcMMX;
    VectProcs[SubInt8]:=SubInt8ProcMMX;
    VectProcs[AddUInt8]:=AddInt8ProcMMX;
    VectProcs[SubUInt8]:=SubInt8ProcMMX;
    VectProcs[AddInt16]:=AddInt16ProcMMX;
    VectProcs[SubInt16]:=SubInt16ProcMMX;
    VectProcs[AddUInt16]:=AddInt16ProcMMX;
    VectProcs[SubUInt16]:=SubInt16ProcMMX;

    VectProcs[AddScalarInt8]:=AddScalarInt8ProcMMX;
    VectProcs[SubScalarInt8]:=SubScalarInt8ProcMMX;
    VectProcs[AddScalarUInt8]:=AddScalarInt8ProcMMX;
    VectProcs[SubScalarUInt8]:=SubScalarInt8ProcMMX;
    VectProcs[AddScalarInt16]:=AddScalarInt16ProcMMX;
    VectProcs[SubScalarInt16]:=SubScalarInt16ProcMMX;
    VectProcs[AddScalarUInt16]:=AddScalarInt16ProcMMX;
    VectProcs[SubScalarUInt16]:=SubScalarInt16ProcMMX;

    VectProcs[MulScalarInt16]:=MulScalarInt16ProcMMX;
    VectFuncsInt32[DotProductInt16]:=DotProductInt16FuncMMX;
  end;
  {$ENDIF}
end.
