{ Version 040212. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit RBTree;
{
  Красно-черные деревья указателей.

  Red-black pointer trees.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TTreeData = Pointer;

  {$I RBTree.def}

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

function CMP(a, b: TTreeData): Integer;
begin
  if a = b then
    Result:=0
  else
    if {Int32}PtrInt(a) < {Int32}PtrInt(b) then
      Result:=-1
    else
      Result:=1;
end;

{$I RBTree.imp}

end.
