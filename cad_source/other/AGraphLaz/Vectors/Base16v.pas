{ Version 020417. Copyright © Alexey A.Chernobaev, 1996-2002 }

unit Base16v;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors;

type
  TBase = TBase16;

  TBase16Vector = class(TSortableVector)
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

procedure TBase16Vector.FillMem(Offset, InitCount: Integer; Value: TBase);
begin
  FillValue16(FItems^.Int8Array[Offset], Value.AsInt16, InitCount);
end;

function TBase16Vector.IndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I < 0 then I:=0;
  Result:=IndexOfValue16(FItems^.Int16Array[I], Value.AsInt16, FCount - I);
  if Result >= 0 then Inc(Result, I);
end;

function TBase16Vector.LastIndexOfBaseValue(I: Integer; Value: TBase): Integer;
begin
  if I >= FCount then I:=FCount - 1;
  Result:=LastIndexOfValue16(FItems^, Value.AsInt16, I + 1);
end;

function TBase16Vector.CountValuesEqualTo(Value: TBase): Integer;
begin
  Result:=CountEqualToValue16(FItems^, Value.AsInt16, FCount);
end;

procedure TBase16Vector.GetUntyped(I: Integer; var Result);
begin
  Int16(Result):=FItems^.Int16Array[I];
end;

end.
