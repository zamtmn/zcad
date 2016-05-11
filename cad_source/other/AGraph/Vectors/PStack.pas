{ Version 010608. Copyright © Alexey A.Chernobaev, 1996-2001 }

unit PStack;
{
  Стек с элементами типа Pointer.

  Stack with elements of type Pointer.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, VectErr;

type
  NumberType = Pointer;

  {$I VStack.def}
    procedure ClearAndFreeItems;
    { очищает стек и освобождает все элементы, интерпретируя их как TObject }
    { clears the stack and frees all items interpreting them as TObject-s }
  end;

  TPointerStack = TVGenericStack;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I VStack.imp}

procedure TVGenericStack.ClearAndFreeItems;
var
  I: Integer;
begin
  if Self <> nil then
    for I:=0 to Count - 1 do
      TObject(Pop).Free;
end;

end.
