{ Version 000613. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit UInt16v;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Base16v, UInt16g, VectErr;

{$DEFINE UINT}

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
    procedure Sort; override; { use radix sort if the vector is small enough }
    procedure SortDesc; override;
  end;

  TUInt16Vector = TNumberVector;
  TWordVector = TUInt16Vector;

implementation

uses VectProc;

const
  AddVectCode = AddUInt16;
  SubVectCode = SubUInt16;
  AddScalarCode = AddScalarUInt16;
  SubScalarCode = SubScalarUInt16;
  MulScalarCode = MulScalarUInt16;
  DivScalarCode = DivScalarUInt16;
  SumVectCode = SumUInt16;

{$I VFast.imp}

{$I Sort16u.inc}
{$DEFINE V_SORT_DESC}
{$I Sort16u.inc}
{$UNDEF V_SORT_DESC}

{$UNDEF UINT}

end.
