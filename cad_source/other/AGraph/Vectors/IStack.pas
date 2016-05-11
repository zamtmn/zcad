{ Version 000510. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit IStack;
{
  Стек с элементами типа Integer.

  Stack with elements of type Integer.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, VectErr;

type
  NumberType = Integer;

  {$I VStack.def}
  end;

  TIntegerStack = TVGenericStack;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I VStack.imp}

end.
