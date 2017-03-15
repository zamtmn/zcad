{ Version 040828. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VStrm64;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows,{$ENDIF}
  {$IFDEF LINUX}{$IFDEF V_DELPHI}Libc{$ELSE}Linux{,cmem}{$ENDIF},{$ENDIF}
  SysUtils, ExtType, ExtSys, VectErr;

type
  ILong = Int64;

{$IFDEF INT64_EQ_COMP}
  {$DEFINE FLOAT_ILONG}
{$ENDIF}

{$I VStrm.def}

  TVStream64 = TVStream;
  TVMemStream64 = TVMemStream;
  TVReadOnlyMemStream64 = TVReadOnlyMemStream;
  TVStreamOnStream64 = TVStreamOnStream;
  TVLimitedStream64 = TVLimitedStream;
  TLowerCaseFilter64 = TLowerCaseFilter;
  TUpperCaseFilter64 = TUpperCaseFilter;
  TBigEndianFilter64 = TBigEndianFilter;

implementation

{$I VStrm.imp}

end.
