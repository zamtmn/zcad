{ Version 990825. Copyright © Alexey A.Chernobaev, 1996-1999 }

unit UInt32v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Base32v, UInt32g, VectErr;

{$DEFINE UINT}

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
  end;

  TUInt32Vector = TNumberVector;

implementation

uses VectProc;

const
  AddVectCode = AddUInt32;
  SubVectCode = SubUInt32;
  AddScalarCode = AddScalarUInt32;
  SubScalarCode = SubScalarUInt32;
  MulScalarCode = MulScalarUInt32;
  DivScalarCode = DivScalarUInt32;
  SumVectCode = SumUInt32;

{$I VFast.imp}

{$UNDEF UINT}

end.
