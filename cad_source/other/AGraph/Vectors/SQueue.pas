{ Version 001020. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit SQueue;
{
  Очередь с элементами типа String.

  Queue with elements of type String.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, VectErr;

type
  NumberType = String;

  {$I VQueue.def}
  end;
  
  TStringQueue = TVGenericQueue;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I VQueue.imp}

end.
