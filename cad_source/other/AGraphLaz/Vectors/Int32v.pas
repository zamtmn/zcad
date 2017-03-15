{ Version 000514. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit Int32v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Base32v, Int32g, VectErr;

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
  end;

  TInt32Vector = TNumberVector;
  TLongIntVector = TInt32Vector;

implementation

uses VectProc;

const
  AddVectCode = AddInt32;
  SubVectCode = SubInt32;
  AddScalarCode = AddScalarInt32;
  SubScalarCode = SubScalarInt32;
  MulScalarCode = MulScalarInt32;
  DivScalarCode = DivScalarInt32;
  SumVectCode = SumInt32;

{$IFDEF USE_ASM} {$IFNDEF V_FREEPASCAL}
  {$DEFINE SPECIAL_COMPARE}
{$ENDIF} {$ENDIF}

{$I VFast.imp}

{$IFDEF USE_ASM} {$IFNDEF V_FREEPASCAL}
  {$UNDEF SPECIAL_COMPARE}
{$ENDIF} {$ENDIF}

{$IFDEF USE_ASM} {$IFNDEF V_FREEPASCAL}
function TInt32Vector.Compare(I: Integer; const V): Int32; assembler;
asm
        {$IFDEF V_FREEPASCAL}
        mov      eax, Self
        mov      edx, I
        mov      ecx, V
        {$ENDIF}
        mov      eax, [eax].FItems
        mov      eax, [eax + edx * 4]
        cmp      eax, [ecx]
        jle      @@1
        mov      eax, 1
        ret
@@1:    je       @@2
        mov      eax, -1
        ret
@@2:    xor      eax, eax
end{$IFDEF V_FREEPASCAL} ['eax','ecx','edx']{$ENDIF};
{$ENDIF} {$ENDIF}

end.
