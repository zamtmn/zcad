{ Version 030515. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Aliasm;

interface

{$I VCheck.inc}

uses
  ExtType, Int16g, Int16v, Int16sv, Int16m, Int32g, Int32v, Int32sv, Int32m,
  UInt16g, UInt16v, UInt16sv, UInt16m, UInt32g, UInt32v, UInt32sv, UInt32m,
  F32g, F32v, F32sv, F32m, F64g, F64v, F64sv, F64m, F80g, F80v, F80sv, F80m;

type
{$IFDEF V_32}
  TIntMatrix = TInt32Matrix;
  TSparseIntMatrix = TSparseInt32Matrix;
  TSimIntMatrix = TSimInt32Matrix;
  TSparseSimIntMatrix = TSparseSimInt32Matrix;

  TUIntMatrix = TUInt32Matrix;
  TSparseUIntMatrix = TSparseUInt32Matrix;
  TSimUIntMatrix = TSimUInt32Matrix;
  TSparseSimUIntMatrix = TSparseSimUInt32Matrix;

  TCardinalMatrix = TUInt32Matrix;
  TSparseCardinalMatrix = TSparseUInt32Matrix;
  TSparseSimCardinalMatrix = TSparseSimUInt32Matrix;

{$IFDEF BCB}
{$NODEFINE TIntMatrix}
{$HPPEMIT 'typedef TInt32Matrix TIntMatrix;'}
{$NODEFINE TSparseIntMatrix}
{$HPPEMIT 'typedef TSparseInt32Matrix TSparseIntMatrix;'}
{$NODEFINE TSimIntMatrix}
{$HPPEMIT 'typedef TSimInt32Matrix TSimIntMatrix;'}
{$NODEFINE TSparseSimIntMatrix}
{$HPPEMIT 'typedef TSparseSimInt32Matrix TSparseSimIntMatrix;'}

{$NODEFINE TUIntMatrix}
{$HPPEMIT 'typedef TUInt32Matrix TUIntMatrix;'}
{$NODEFINE TSparseUIntMatrix}
{$HPPEMIT 'typedef TSparseUInt32Matrix TSparseUIntMatrix;'}
{$NODEFINE TSimUIntMatrix}
{$HPPEMIT 'typedef TSimUInt32Matrix TSimUIntMatrix;'}
{$NODEFINE TSparseSimUIntMatrix}
{$HPPEMIT 'typedef TSparseSimUInt32Matrix TSparseSimUIntMatrix;'}

{$NODEFINE TCardinalMatrix}
{$HPPEMIT 'typedef TUInt32Matrix TCardinalMatrix;'}
{$NODEFINE TSparseCardinalMatrix}
{$HPPEMIT 'typedef TSparseUInt32Matrix TSparseCardinalMatrix;'}
{$NODEFINE TSparseSimCardinalMatrix}
{$HPPEMIT 'typedef TSparseSimUInt32Matrix TSparseSimCardinalMatrix;'}
{$ENDIF}

{$ELSE}
  TIntMatrix = TInt16Matrix;
  TSparseIntMatrix = TSparseInt16Matrix;
  TSimIntMatrix = TSimInt16Matrix;
  TSparseSimIntMatrix = TSparseSimInt16Matrix;

  TUIntMatrix = TUInt16Matrix;
  TSparseUIntMatrix = TSparseUInt16Matrix;
  TSimUIntMatrix = TSimUInt16Matrix;
  TSparseSimUIntMatrix = TSparseSimUInt16Matrix;

  TCardinalMatrix = TUInt16Matrix;
  TSparseCardinalMatrix = TSparseUInt16Matrix;
  TSparseSimCardinalMatrix = TSparseSimUInt16Matrix;
{$ENDIF}

  TIntegerMatrix = TIntMatrix;
  TSparseIntegerMatrix = TSparseIntMatrix;
  TSimIntegerMatrix = TSimIntMatrix;
  TSparseSimIntegerMatrix = TSparseSimIntMatrix;

{$IFDEF BCB}
{$NODEFINE TIntegerMatrix}
{$HPPEMIT 'typedef TIntMatrix TIntegerMatrix;'}
{$NODEFINE TSparseIntegerMatrix}
{$HPPEMIT 'typedef TSparseIntMatrix TSparseIntegerMatrix;'}
{$NODEFINE TSimIntegerMatrix}
{$HPPEMIT 'typedef TSimIntMatrix TSimIntegerMatrix;'}
{$NODEFINE TSparseSimIntegerMatrix}
{$HPPEMIT 'typedef TSparseSimIntMatrix TSparseSimIntegerMatrix;'}
{$ENDIF}

{$IFDEF FLOAT_EQ_FLOAT32}
  TFloatMatrix = TFloat32Matrix;
  TSparseFloatMatrix = TSparseFloat32Matrix;
  TSimFloatMatrix = TSimFloat32Matrix;
  TSparseSimFloatMatrix = TSparseSimFloat32Matrix;

{$IFDEF BCB}
{$NODEFINE TFloatMatrix}
{$HPPEMIT 'typedef TFloat32Matrix TFloatMatrix;'}
{$NODEFINE TSparseFloatMatrix}
{$HPPEMIT 'typedef TSparseFloat32Matrix TSparseFloatMatrix;'}
{$NODEFINE TSimFloatMatrix}
{$HPPEMIT 'typedef TSimFloat32Matrix TSimFloatMatrix;'}
{$NODEFINE TSparseSimFloatMatrix}
{$HPPEMIT 'typedef TSparseSimFloat32Matrix TSparseSimFloatMatrix;'}
{$ENDIF}

{$ELSE} {$IFDEF FLOAT_EQ_FLOAT64}
  TFloatMatrix = TFloat64Matrix;
  TSparseFloatMatrix = TSparseFloat64Matrix;
  TSimFloatMatrix = TSimFloat64Matrix;
  TSparseSimFloatMatrix = TSparseSimFloat64Matrix;

{$IFDEF BCB}
{$NODEFINE TFloatMatrix}
{$HPPEMIT 'typedef TFloat64Matrix TFloatMatrix;'}
{$NODEFINE TSparseFloatMatrix}
{$HPPEMIT 'typedef TSparseFloat64Matrix TSparseFloatMatrix;'}
{$NODEFINE TSimFloatMatrix}
{$HPPEMIT 'typedef TSimFloat64Matrix TSimFloatMatrix;'}
{$NODEFINE TSparseSimFloatMatrix}
{$HPPEMIT 'typedef TSparseSimFloat64Matrix TSparseSimFloatMatrix;'}
{$ENDIF}

{$ELSE} {$IFDEF FLOAT_EQ_FLOAT80}
  TFloatMatrix = TFloat80Matrix;
  TSparseFloatMatrix = TSparseFloat80Matrix;
  TSimFloatMatrix = TSimFloat80Matrix;
  TSparseSimFloatMatrix = TSparseSimFloat80Matrix;

{$IFDEF BCB}
{$NODEFINE TFloatMatrix}
{$HPPEMIT 'typedef TFloat80Matrix TFloatMatrix;'}
{$NODEFINE TSparseFloatMatrix}
{$HPPEMIT 'typedef TSparseFloat80Matrix TSparseFloatMatrix;'}
{$NODEFINE TSimFloatMatrix}
{$HPPEMIT 'typedef TSimFloat80Matrix TSimFloatMatrix;'}
{$NODEFINE TSparseSimFloatMatrix}
{$HPPEMIT 'typedef TSparseSimFloat80Matrix TSparseSimFloatMatrix;'}
{$ENDIF}

{$ENDIF} {$ENDIF} {$ENDIF}

implementation

end.
