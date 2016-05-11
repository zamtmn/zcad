{ Version 020417. Copyright © Alexey A.Chernobaev, 1996-2002 }

unit Base8v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors;

type
  TBase = TBase8;

  TBase8Vector = class(TSortableVector)
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

procedure TBase8Vector.FillMem(Offset, InitCount: Integer; Value: TBase);
begin
  FillChar(FItems^.Int8Array[Offset], InitCount, Value.AsInt8);
end;

function TBase8Vector.IndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I < 0 then I:=0;
  Result:=IndexOfValue8(FItems^.Int8Array[I], Value.AsInt8, FCount - I);
  if Result >= 0 then Inc(Result, I);
end;

function TBase8Vector.LastIndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I >= FCount then I:=FCount - 1;
  Result:=LastIndexOfValue8(FItems^, Value.AsInt8, I + 1);
end;

function TBase8Vector.CountValuesEqualTo(Value: TBase): Integer;
begin
  Result:=CountEqualToValue8(FItems^, Value.AsInt8, FCount);
end;

procedure TBase8Vector.GetUntyped(I: Integer; var Result);
begin
  Int8(Result):=FItems^.Int8Array[I];
end;

end.
