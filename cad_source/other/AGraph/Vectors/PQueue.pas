{ Version 010608. Copyright © Alexey A.Chernobaev, 1996-2001 }

unit PQueue;
{
  Очередь с элементами типа Pointer.

  Queue with elements of type Pointer.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, VectErr;

type
  NumberType = Pointer;

  {$I VQueue.def}
    procedure ClearAndFreeItems;
    { очищает очередь; каждый элемент считается объектом TObject и уничтожается }
    { clears the queue and frees all it's items interpreting them as TObject }
  end;

  TPointerQueue = TVGenericQueue;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I VQueue.imp}

procedure TVGenericQueue.ClearAndFreeItems;
var
  I: Integer;
begin
  if Self <> nil then
    for I:=0 to Count - 1 do
      TObject(DeleteHead).Free;
end;

end.
