{ Version 000828. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit F80v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Base80v, F80g, VectErr;

{$DEFINE FLOAT}

type
  NumberType = Float80;
  PArrayType = PFloat80Array;

  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
  end;

  TFloat80Vector = TNumberVector;
  TExtendedVector = TFloat80Vector;

implementation

uses VectProc;

const
  AddVectCode = AddFloat80;
  SubVectCode = SubFloat80;
  AddScalarCode = AddScalarFloat80;
  SubScalarCode = SubScalarFloat80;
  MulCode = MulVectFloat80;
  DivCode = DivVectFloat80;
  MulScalarCode = MulScalarFloat80;
  SumVectCode = SumFloat80;
  SqrSumVectCode = SqrSumFloat80;
  DotProductCode = DotProductFloat80;
  AddScaledCode = AddScaledFloat80;

{$I VFast.imp}

{$UNDEF FLOAT}

end.
