unit zvectorsimpletest;

interface

{define stringdata}

uses
  SysUtils,TypInfo,
  fpcunit,
  gzctnrVectorSimple,gvector,strutils,
  testregistry;

const
  MaxVectorLength=10000000;
  InitVectorLength=1;
  NeedSum=49994984640401;

type
  TZVectorSimpleTest = class(TTestCase)
  Published
    Procedure TestGVector_Integer_BasicOperations;
    Procedure TestGZVectorSimple_Integer_BasicOperations;
    Procedure doFailure;
  end;


implementation

procedure TZVectorSimpleTest.TestGZVectorSimple_Integer_BasicOperations;
type
  TZInegerVector=specialize GZVectorSimple<Integer>;
var
  InegerVector:TZInegerVector;
  i:integer;
  //data:Integer;
  sum:Int64;
begin
  InegerVector.init(InitVectorLength);

  for i:=0 to MaxVectorLength-1 do
    InegerVector.PushBackData(i);

  InegerVector.Invert;

  for i:=0 to 500 do
    InegerVector.deleteelement(0);

  for i:=0 to 1000 do
    InegerVector.deleteelement(InegerVector.Count-1);

  for i:=0 to 100 do
    InegerVector.InsertElement(0,i+100);

  sum:=0;
  for i:=0 to InegerVector.Count-1 do
    sum:=sum+InegerVector.getData(i);

  if sum<>NeedSum then
    raise(Exception.CreateFmt('Wrong summ : calc=%d, need=%d',[sum,NeedSum]));

  sum:=0;
  for i in InegerVector do
    sum:=sum+i;

  if sum<>NeedSum then
    raise(Exception.CreateFmt('Wrong summ : calc=%d, need=%d',[sum,NeedSum]));

  InegerVector.done;
end;

procedure TZVectorSimpleTest.TestGVector_Integer_BasicOperations;
type
  TZInegerVector=specialize Tvector<Integer>;
var
  InegerVector:TZInegerVector;
  i,j:integer;
  data,tdata:Integer;
  sum:Int64;
begin
  InegerVector:=TZInegerVector.Create;

  for i:=0 to MaxVectorLength-1 do
  begin
   data:=i;
   InegerVector.PushBack(data);
  end;

  j:=InegerVector.Size-1;
  for i:=0 to (InegerVector.Size-1)div 2 do
  begin
       tdata:=InegerVector[i];
       InegerVector[i]:=InegerVector[j];
       InegerVector[j]:=tdata;
       dec(j);
  end;

  for i:=0 to 500 do
  InegerVector.Erase(0);

  for i:=0 to 1000 do
  InegerVector.Erase(InegerVector.Size-1);

  for i:=0 to 100 do
    InegerVector.Insert(0,i+100);

  sum:=0;
  for i:=0 to InegerVector.Size-1 do
    sum:=sum+InegerVector[i];

  if sum<>NeedSum then
    raise(Exception.CreateFmt('Wrong summ : calc=%d, need=%d',[sum,NeedSum]));

  InegerVector.Destroy;
end;

Procedure TZVectorSimpleTest.doFailure;
begin
  raise(Exception.CreateFmt('Always failure',[]));
end;

begin
  RegisterTests([TZVectorSimpleTest]);
end.

