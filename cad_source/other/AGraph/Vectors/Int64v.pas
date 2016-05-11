{ Version 000616. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit Int64v;

interface

{$I VCheck.inc}

{$IFDEF VER130}
{ обходим баг Delphi 5.0, связанный с использованием Int64 }
{ work-around for Delphi 5.0 bug connected with use of Int64 }
{$O-}
{$ENDIF}

uses
  ExtType, Vectors, Base64v, Int64g, VectErr;

{$DEFINE INT64_VECT}

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
    function Sum: Int64; override;
    function SqrSum: Int64; override;
  end;

  TInt64Vector = TNumberVector;

implementation

uses VectProc;

const
  AddVectCode = AddInt64;
  SubVectCode = SubInt64;
  AddScalarCode = AddScalarInt64;
  SubScalarCode = SubScalarInt64;
  MulScalarCode = MulScalarInt64;
  DivScalarCode = DivScalarInt64;

{$I VFast.imp}

function TInt64Vector.Sum: Int64;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to FCount - 1 do Result:=Result + PArrayType(FItems)^[I];
end;

function TInt64Vector.SqrSum: Int64;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to FCount - 1 do
    Result:=Result + PArrayType(FItems)^[I] * PArrayType(FItems)^[I]; { именно так, не Sqr }
end;

{$UNDEF INT64_VECT}

end.
