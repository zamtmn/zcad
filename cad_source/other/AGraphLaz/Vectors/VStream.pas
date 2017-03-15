{ Version 050604. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit VStream;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}{$IFDEF V_32}Windows{$ELSE}WinTypes, WinProcs{$ENDIF},{$ENDIF}
  {$IFDEF LINUX}{$IFDEF V_DELPHI}Libc{$ELSE}Linux{$ENDIF},{$ENDIF}
  SysUtils, ExtType, ExtSys, VectErr;

type
  ILong = Int32;

{$I VStrm.def}

implementation

{$I VStrm.imp}

end.
