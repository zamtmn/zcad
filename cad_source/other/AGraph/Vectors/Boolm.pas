{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Boolm;
{
  Ћогические матрицы.

  Boolean matrixes.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Boolv, Pointerv, Int16g, Aliasv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE BOOL}

type
  BaseType = Bool;
  TGenericBaseVector = TBoolVector;
  TBaseVector = TBoolVector;
  TSparseVector = TPackedBoolVector;

  {$I NumMatr.def}

  TBoolMatrix = TNumberMatrix;
  TSquareBoolMatrix = TSquareMatrix;
  TSparseBoolMatrix = TSparseMatrix;
  TPackedBoolMatrix = TSparseMatrix;
  TSimBoolMatrix = TSimMatrix;
  TSparseSimBoolMatrix = TSparseSimMatrix;
  TPackedSimBoolMatrix = TSparseSimMatrix;

  TBooleanMatrix = TBoolMatrix;
  TSparseBooleanMatrix = TSparseBoolMatrix;
  TPackedBooleanMatrix = TPackedBoolMatrix;
  TSparseSimBooleanMatrix = TSparseSimBoolMatrix;
  TPackedSimBooleanMatrix = TPackedSimBoolMatrix;

function CreateBoolMatrix(ARowCount, AColCount: Integer; ADefaultValue: Bool): TBoolMatrix;
{ если объем свободной физической пам€ти достаточен дл€ хранени€ матрицы класса
  TBoolMatrix заданного размера, то создает матрицу класса TBoolMatrix, иначе
  создает матрицу класса TPackedBoolMatrix }
{ if amount of free physical memory is large enough to store matrix of class
  TBoolMatrix with dimensionality ARowCount * AColCount then creates such matrix
  else creates matrix of class TPackedBoolMatrix }

function CreateSimBoolMatrix(ASize: Integer; ADefaultValue: Bool): TBoolMatrix;
{ аналог CreateBoolMatrix дл€ симметричных матриц (создает матрицу класса
  TSimBoolMatrix либо TPackedSimBoolMatrix) }
{ analog of CreateBoolMatrix for symmetric matrixes (creates matrix of classes
  either TSimBoolMatrix or TPackedSimBoolMatrix) }

implementation

{$I NumMatr.imp}

{$UNDEF BOOL}

function CreateBoolMatrix(ARowCount, AColCount: Integer; ADefaultValue: Bool): TBoolMatrix;
begin
  if PhysicalMemoryFree > UInt32(ARowCount * AColCount) then
    Result:=TBoolMatrix.Create(ARowCount, AColCount, ADefaultValue)
  else
    Result:=TPackedBoolMatrix.Create(ARowCount, AColCount, ADefaultValue);
end;

function CreateSimBoolMatrix(ASize: Integer; ADefaultValue: Bool): TBoolMatrix;
begin
  if PhysicalMemoryFree > UInt32(ASize div 2 * ASize) then
    Result:=TSimBoolMatrix.Create(ASize, ADefaultValue)
  else
    Result:=TPackedSimBoolMatrix.Create(ASize, ADefaultValue);
end;

end.
