{ Version 000613. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit Int8v;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Base8v, Int8g, VectErr;

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
    procedure Sort; override; { use counting sort if the vector is small enough }
    procedure SortDesc; override;
  end;

  TInt8Vector = TNumberVector;
  TShortIntVector = TInt8Vector;

implementation

uses VectProc;

const
  AddVectCode = AddInt8;
  SubVectCode = SubInt8;
  AddScalarCode = AddScalarInt8;
  SubScalarCode = SubScalarInt8;
  MulScalarCode = MulScalarInt8;
  DivScalarCode = DivScalarInt8;
  SumVectCode = SumInt8;

{$I VFast.imp}

{$I Sort8.inc}
{$DEFINE V_SORT_DESC}
{$I Sort8.inc}
{$UNDEF V_SORT_DESC}

end.
