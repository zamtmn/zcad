{ Version 000828. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit F64v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Base64v, F64g, VectErr;

{$DEFINE FLOAT}

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
  end;

  TFloat64Vector = TNumberVector;
  TDoubleVector = TFloat64Vector;

implementation

uses VectProc;

const
  AddVectCode = AddFloat64;
  SubVectCode = SubFloat64;
  AddScalarCode = AddScalarFloat64;
  SubScalarCode = SubScalarFloat64;
  MulCode = MulVectFloat64;
  DivCode = DivVectFloat64;
  MulScalarCode = MulScalarFloat64;
  SumVectCode = SumFloat64;
  SqrSumVectCode = SqrSumFloat64;
  DotProductCode = DotProductFloat64;
  AddScaledCode = AddScaledFloat64;

{$I VFast.imp}

{$UNDEF FLOAT}

end.
