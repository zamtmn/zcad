{ Version 020417. Copyright © Alexey A.Chernobaev, 1996-2002 }

unit Base80v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors;

type
  TBase = Float80;

  TBase80Vector = class(TSortableVector)
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

procedure TBase80Vector.FillMem(Offset, InitCount: Integer; Value: TBase);
begin
  FillValue80(FItems^.Int8Array[Offset], Value, InitCount);
end;

function TBase80Vector.IndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I < 0 then I:=0;
  Result:=IndexOfValue80(FItems^.Float80Array[I], Value, FCount - I);
  if Result >= 0 then Inc(Result, I);
end;

function TBase80Vector.LastIndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I >= FCount then I:=FCount - 1;
  Result:=LastIndexOfValue80(FItems^, Value, I + 1);
end;

function TBase80Vector.CountValuesEqualTo(Value: TBase): Integer;
begin
  Result:=CountEqualToValue80(FItems^, Value, FCount);
end;

procedure TBase80Vector.GetUntyped(I: Integer; var Result);
begin
  Float80(Result):=FItems^.Float80Array[I];
end;

end.
