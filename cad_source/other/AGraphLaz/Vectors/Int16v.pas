{ Version 030516. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int16v;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Base16v, Int16g, VectErr;

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
    procedure Sort; override; { use radix sort if the vector is small enough }
    procedure SortDesc; override;
  end;

  TInt16Vector = TNumberVector;
  TSmallIntVector = TInt16Vector;

implementation

uses VectProc;

const
  AddVectCode = AddInt16;
  SubVectCode = SubInt16;
  AddScalarCode = AddScalarInt16;
  SubScalarCode = SubScalarInt16;
  MulScalarCode = MulScalarInt16;
  DivScalarCode = DivScalarInt16;
  SumVectCode = SumInt16;
  DotProductCode = DotProductInt16;

{$DEFINE SPECIAL_DOT_PRODUCT}
{$I VFast.imp}
{$UNDEF SPECIAL_DOT_PRODUCT}

{$I Sort16s.inc}
{$DEFINE V_SORT_DESC}
{$I Sort16s.inc}
{$UNDEF V_SORT_DESC}

end.
