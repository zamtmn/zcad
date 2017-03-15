{ Version 030515. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Aliasv;

interface

{$I VCheck.inc}

uses
  ExtType, Int16g, Int16v, Int16sv, Int32g, Int32v, Int32sv, 
  UInt16g, UInt16v, UInt16sv, UInt32g, UInt32v, UInt32sv,
  F32g, F32v, F32sv, F64g, F64v, F64sv, F80g, F80v, F80sv;

type
{$IFDEF V_32}
  TGenericIntVector = TGenericInt32Vector;
  TIntVector = TInt32Vector;
  TSparseIntVector = TSparseInt32Vector;

  TGenericCardinalVector = TGenericUInt32Vector;
  TCardinalVector = TUInt32Vector;
  TSparseCardinalVector = TSparseUInt32Vector;

{$IFDEF BCB}
{$NODEFINE TGenericIntVector}
{$HPPEMIT 'typedef TGenericInt32Vector TGenericIntVector;'}
{$NODEFINE TIntVector}
{$HPPEMIT 'typedef TInt32Vector TIntVector;'}
{$NODEFINE TSparseIntVector}
{$HPPEMIT 'typedef TSparseInt32Vector TSparseIntVector;'}

{$NODEFINE TGenericCardinalVector}
{$HPPEMIT 'typedef TGenericUInt32Vector TGenericCardinalVector;'}
{$NODEFINE TCardinalVector}
{$HPPEMIT 'typedef TUInt32Vector TCardinalVector;'}
{$NODEFINE TSparseCardinalVector}
{$HPPEMIT 'typedef TSparseUInt32Vector TSparseCardinalVector;'}
{$ENDIF}

{$ELSE}
  TGenericIntVector = TGenericInt16Vector;
  TIntVector = TInt16Vector;
  TSparseIntVector = TSparseInt16Vector;

  TGenericCardinalVector = TGenericUInt16Vector;
  TCardinalVector = TUInt16Vector;
  TSparseCardinalVector = TSparseUInt16Vector;
{$ENDIF}

  TGenericIntegerVector = TGenericIntVector;
  TIntegerVector = TIntVector;
  TSparseIntegerVector = TSparseIntVector;

  TUIntVector = TCardinalVector;

{$IFDEF BCB}
{$NODEFINE TGenericIntegerVector}
{$HPPEMIT 'typedef TGenericIntVector TGenericIntegerVector;'}
{$NODEFINE TIntegerVector}
{$HPPEMIT 'typedef TIntVector TIntegerVector;'}
{$NODEFINE TSparseIntegerVector}
{$HPPEMIT 'typedef TSparseIntVector TSparseIntegerVector;'}
{$NODEFINE TUIntVector}
{$HPPEMIT 'typedef TCardinalVector TUIntVector;'}
{$ENDIF}

{$IFDEF FLOAT_EQ_FLOAT32}
  TGenericFloatVector = TGenericFloat32Vector;
  TFloatVector = TFloat32Vector;
  TSparseFloatVector = TSparseFloat32Vector;

{$IFDEF BCB}
{$NODEFINE TGenericFloatVector}
{$HPPEMIT 'typedef TGenericFloat32Vector TGenericFloatVector;'}
{$NODEFINE TFloatVector}
{$HPPEMIT 'typedef TFloat32Vector TFloatVector;'}
{$NODEFINE TSparseFloatVector}
{$HPPEMIT 'typedef TSparseFloat32Vector TSparseFloatVector;'}
{$ENDIF}

{$ELSE} {$IFDEF FLOAT_EQ_FLOAT64}
  TGenericFloatVector = TGenericFloat64Vector;
  TFloatVector = TFloat64Vector;
  TSparseFloatVector = TSparseFloat64Vector;

{$IFDEF BCB}
{$NODEFINE TGenericFloatVector}
{$HPPEMIT 'typedef TGenericFloat64Vector TGenericFloatVector;'}
{$NODEFINE TFloatVector}
{$HPPEMIT 'typedef TFloat64Vector TFloatVector;'}
{$NODEFINE TSparseFloatVector}
{$HPPEMIT 'typedef TSparseFloat64Vector TSparseFloatVector;'}
{$ENDIF}

{$ELSE} {$IFDEF FLOAT_EQ_FLOAT80}
  TGenericFloatVector = TGenericFloat80Vector;
  TFloatVector = TFloat80Vector;
  TSparseFloatVector = TSparseFloat80Vector;

{$IFDEF BCB}
{$NODEFINE TGenericFloatVector}
{$HPPEMIT 'typedef TGenericFloat80Vector TGenericFloatVector;'}
{$NODEFINE TFloatVector}
{$HPPEMIT 'typedef TFloat80Vector TFloatVector;'}
{$NODEFINE TSparseFloatVector}
{$HPPEMIT 'typedef TSparseFloat80Vector TSparseFloatVector;'}
{$ENDIF}

{$ENDIF} {$ENDIF} {$ENDIF}

implementation

end.
