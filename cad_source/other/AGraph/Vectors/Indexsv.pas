{ Version 011017. Copyright © Alexey A.Chernobaev, 1996-2001 }

unit Indexsv;
{
  Вспомогательный вектор индексов для реализации разреженных векторов.

  Auxiliary vector of indexes for the implementation of the sparse vectors.
}

interface

{$I VCheck.inc}

uses
  ExtType, Indexv, Int32g;

type
  TExpandEvent = procedure (I: Integer) of object;
  TExchangeEvent = procedure (I, J: Integer) of object;

  TSVIndexVector =  class(TIndexVector)
  protected
    FExpandEvent: TExpandEvent;
    FExchangeEvent: TExchangeEvent;
  public
    constructor Create(ElemCount: Integer; AnExpandEvent: TExpandEvent;
      AnExchangeEvent: TExchangeEvent);
    procedure Expand(I: Integer); override;
    procedure Exchange(I, J: Integer); override;
  end;

implementation

procedure TSVIndexVector.Expand(I: Integer);
begin
  inherited Expand(I);
  FExpandEvent(I);
end;

procedure TSVIndexVector.Exchange(I, J: Integer);
begin
  inherited Exchange(I, J);
  FExchangeEvent(I, J);
end;

constructor TSVIndexVector.Create(ElemCount: Integer; AnExpandEvent: TExpandEvent;
  AnExchangeEvent: TExchangeEvent);
begin
  inherited Create(ElemCount);
  FExchangeEvent:=AnExchangeEvent;
  FExpandEvent:=AnExpandEvent;
end;

end.
