{ Version 000510. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit IQueue;
{
  Очередь с элементами типа Integer.

  Queue with elements of type Integer.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, VectErr;

type
  NumberType = Integer;

  {$I VQueue.def}
  end;
  
  TIntegerQueue = TVGenericQueue;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I VQueue.imp}

end.
