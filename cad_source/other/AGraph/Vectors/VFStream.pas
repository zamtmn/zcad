{ Version 041102. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VFStream;

interface

{$I VCheck.inc}

uses
  {$IFDEF WIN32}Windows,{$ENDIF}
  {$IFDEF LINUX}{$IFDEF V_DELPHI}Libc{$ELSE}Linux{$ENDIF},{$ENDIF}
  SysUtils, ExtType, ExtSys, VStream, VectErr;

type
  ILong = Int32;

  TVBaseStream = TVStream;

{$I VFStrm.def}

  TVFileStream32 = TVFileStream;
  TVBufFileStream32 = TVBufFileStream;

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
  {$IFDEF WIN32}
  FileSize;
  {$ELSE}
  FSize:=-1;
  {$ENDIF}
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
    FileSize;
  end
  else
  {$ENDIF}
    Create(AFileName, Mode);
end;
{$ENDIF}

function TVFileStream.FileSize: ILong;
{$IFDEF WIN32}
var
  Err: Int32;
{$ENDIF}
begin
  if FHandle = BadHandle then
    ReopenHandle;
  {$IFDEF WIN32}
  Result:=GetFileSize(FHandle, @Err);
  if (DWORD(Result) = DWORD(-1)) and (GetLastError <> NO_ERROR) then
    Error(SFileGetSizeError, CFileGetSizeError);
  if (Err <> 0) or (Result < 0) then
    Error(SFileTooLarge, CFileTooLarge);
  {$ELSE}
  Result:=FileSeek(FHandle, 0, 2);
  if (Result < 0) or (FileSeek(FHandle, FPosition, 0) < 0) then
    Error(SFileGetSizeError, CFileGetSizeError);
  {$ENDIF}
  FSize:=Result;
end;

end.
