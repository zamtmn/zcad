{ Version 000828. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit F32v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Base32v, F32g, VectErr;

{$DEFINE FLOAT}

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
  end;

  TFloat32Vector = TNumberVector;
  TSingleVector = TFloat32Vector;

implementation

uses VectProc;

const
  AddVectCode = AddFloat32;
  SubVectCode = SubFloat32;
  AddScalarCode = AddScalarFloat32;
  SubScalarCode = SubScalarFloat32;
  MulCode = MulVectFloat32;
  DivCode = DivVectFloat32;
  MulScalarCode = MulScalarFloat32;
  SumVectCode = SumFloat32;
  SqrSumVectCode = SqrSumFloat32;
  DotProductCode = DotProductFloat32;
  AddScaledCode = AddScaledFloat32;

{$I VFast.imp}

{$UNDEF FLOAT}

end.
