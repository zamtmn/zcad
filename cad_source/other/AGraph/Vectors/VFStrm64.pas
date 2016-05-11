{ Version 041101. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VFStrm64;

interface

{$I VCheck.inc}

uses
  {$IFDEF WIN32}Windows, {$ENDIF}SysUtils, ExtType, ExtSys, VStrm64, VectErr;

{$IFDEF INT64_EQ_COMP}
  {$DEFINE FLOAT_ILONG}
{$ENDIF}

type
  TVBaseStream = TVStream64;

{$I VFStrm.def}

  TVFileStream64 = TVFileStream;
  TVBufFileStream64 = TVBufFileStream;

implementation

{$I VFStrm.imp}

constructor TVFileStream.Create(const AFileName: String; Mode: Word);
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
  inherited Create;
  FFileName:=AFileName;
  FFileMode:=Mode;
  OpenHandle(Mode);
  FSize:=-1;
end;

{$IFDEF W_STREAM}
constructor TVFileStream.CreateW(const AFileName: WideString; Mode: Word);
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    {$IFDEF CHECK_OBJECTS_FREE}
    RegisterObjectCreate(Self);
    {$ENDIF}
    inherited Create;
    FFileNameW:=AFileName;
    FFileMode:=Mode;
    OpenHandle(Mode);
    FSize:=-1;
  end
  else
  {$ENDIF}
    Create(AFileName, Mode);
end;
{$ENDIF}

function TVFileStream.FileSize: ILong;
begin
  if FHandle = BadHandle then
    ReopenHandle;
  QWordRec(Result).Lo:=GetFileSize(FHandle, @QWordRec(Result).Hi);
  if (QWordRec(Result).Lo = $FFFFFFFF) and (GetLastError <> NO_ERROR) then
    Error(SFileGetSizeError, CFileGetSizeError);
  FSize:=Result;
end;

end.
