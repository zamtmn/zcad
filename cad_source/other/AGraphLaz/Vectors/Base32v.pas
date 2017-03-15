{ Version 020417. Copyright © Alexey A.Chernobaev, 1996-2002 }

unit Base32v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors;

type
  TBase = TBase32;

  TBase32Vector = class(TSortableVector)
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

procedure TBase32Vector.FillMem(Offset, InitCount: Integer; Value: TBase);
begin
  FillValue32(FItems^.Int8Array[Offset], Value.AsInt32, InitCount);
end;

function TBase32Vector.IndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I < 0 then I:=0;
  Result:=IndexOfValue32(FItems^.Int32Array[I], Value.AsInt32, FCount - I);
  if Result >= 0 then Inc(Result, I);
end;

function TBase32Vector.LastIndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I >= FCount then I:=FCount - 1;
  Result:=LastIndexOfValue32(FItems^, Value.AsInt32, I + 1);
end;

function TBase32Vector.CountValuesEqualTo(Value: TBase): Integer;
begin
  Result:=CountEqualToValue32(FItems^, Value.AsInt32, FCount);
end;

procedure TBase32Vector.GetUntyped(I: Integer; var Result);
begin
  Int32(Result):=FItems^.Int32Array[I];
end;

end.
