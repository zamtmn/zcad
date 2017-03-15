{ Version 000613. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit UInt8v;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Base8v, UInt8g, VectErr;

{$DEFINE UINT}

type
  TNumberVector = class(TGenericNumberVector)
  {$I VFast.def}
    procedure Sort; override; { use counting sort if the vector is small enough }
    procedure SortDesc; override;
  end;

  TUInt8Vector = TNumberVector;
  TByteVector = TUInt8Vector;

implementation

uses VectProc;

const
  AddVectCode = AddUInt8;
  SubVectCode = SubUInt8;
  AddScalarCode = AddScalarUInt8;
  SubScalarCode = SubScalarUInt8;
  MulScalarCode = MulScalarUInt8;
  DivScalarCode = DivScalarUInt8;
  SumVectCode = SumUInt8;

{$I VFast.imp}

{$I Sort8.inc}
{$DEFINE V_SORT_DESC}
{$I Sort8.inc}
{$UNDEF V_SORT_DESC}

{$UNDEF UINT}

end.
