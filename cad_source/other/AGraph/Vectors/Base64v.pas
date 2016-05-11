{ Version 020417. Copyright © Alexey A.Chernobaev, 1996-2002 }

unit Base64v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors;

type
  TBase = TBase64;

  TBase64Vector = class(TSortableVector)
  protected
    procedure FillMem(Offset, InitCount: Integer; Value: TBase);
    function IndexOfBaseValue(I: Integer; Value: TBase): Integer;
    function LastIndexOfBaseValue(I: Integer; Value: TBase): Integer;
    function CountValuesEqualTo(Value: TBase): Integer;
  public
    procedure GetUntyped(I: Integer; var Result); override;
  end;

implementation

uses ExtSys;

procedure TBase64Vector.FillMem(Offset, InitCount: Integer; Value: TBase);
begin
  FillValue64(FItems^.Int8Array[Offset], Value, InitCount);
end;

function TBase64Vector.IndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I < 0 then I:=0;
  Result:=IndexOfValue64(FItems^.Float64Array[I], Value, FCount - I);
  if Result >= 0 then Inc(Result, I);
end;

function TBase64Vector.LastIndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I >= FCount then I:=FCount - 1;
  Result:=LastIndexOfValue64(FItems^, Value, I + 1);
end;

function TBase64Vector.CountValuesEqualTo(Value: TBase): Integer;
begin
  Result:=CountEqualToValue64(FItems^, Value, FCount);
end;

procedure TBase64Vector.GetUntyped(I: Integer; var Result);
begin
  Float64(Result):=FItems^.Float64Array[I];
end;

end.
