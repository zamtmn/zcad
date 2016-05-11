{ Version 040728. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VMapStrm;
{
  Memory-mapped streams (Win32). This code is partly based on the
  TMemoryMappedFileStream class by Dmitry Streblechenko.
}

interface

{$I VCheck.inc}

uses
  Windows, SysUtils, ExtType, ExtSys, VectErr,
  {$IFDEF USE_STREAM64}VStrm64, VFStrm64{$ELSE}VStream, VFStream{$ENDIF};

type
  TVMemoryMappedStream = class(TVFileStream)
  protected
    FMemory: Pointer;
    FMapHandle: THandle;
    FAccess, { file access attributes }
    FShare, { file sharing attributes }
    FPageProtect, { mapping object page protection attributes }
    FMemProtect: DWORD; { protection of the mapped memory }
    FCapacity: ILong;
    FMapName: WideString;
    FNewMapping: Boolean;
    procedure SetAttributes(Mode: Word);
    procedure CreateMapping;
    procedure CloseHandles;
    function GetSize: ILong; override;
    procedure SetSize(NewSize: ILong); override;
    procedure SetCapacity(NewCapacity:  ILong);
  public
    constructor Create(const AFileName, AMapName: String; Mode: Word);
    constructor CreateWithCapacity(const AFileName, AMapName: String; Mode: Word;
      ACapacity: ILong);
    constructor Open(const AMapName: String; Mode: Word);
    constructor CreateW(const AFileName, AMapName: WideString; Mode: Word);
    constructor CreateWithCapacityW(const AFileName, AMapName: WideString;
      Mode: Word; ACapacity: ILong);
    constructor OpenW(const AMapName: WideString; Mode: Word);
    destructor Destroy; override;
    procedure Seek(Offset: ILong); override;
    procedure WriteProc(const Buffer; Count: Int32); override;
    function ReadFunc(var Buffer; Count: Int32): Int32; override;
    function Flush: Boolean; override;
    function Search(const SearchBytes; SearchCount: Integer;
      MaxBytesRead: ILong): Boolean; override;
    property Memory: Pointer read FMemory;
    property Capacity: ILong read FCapacity;
    property MapName: WideString read FMapName;
    { name of the file mapping object }
    property NewMapping: Boolean read FNewMapping;
    { allows to determine whether the file mapping object existed before
      creation of Self }
  end{$IFDEF V_D7}platform{$ENDIF};

implementation

{ TVMemoryMappedStream }

const
  MemoryDelta = 65536; { file size increment; must be a degree of 2! }

procedure TVMemoryMappedStream.SetAttributes(Mode: Word);
begin
{$IFDEF LINUX}
{$ELSE}
  FAccess:=DWORD(GENERIC_READ or GENERIC_WRITE);
  FPageProtect:=PAGE_READWRITE or SEC_COMMIT or SEC_NOCACHE;
  if Mode and fmOpenReadWrite <> 0 then
    FMemProtect:=FILE_MAP_ALL_ACCESS
  else if Mode and fmOpenWrite <> 0 then
    FMemProtect:=FILE_MAP_WRITE
  else begin { all others including fmOpenRead = 0 }
    FAccess:=DWORD(GENERIC_READ);
    FPageProtect:=PAGE_READONLY or SEC_COMMIT or SEC_NOCACHE;
    FMemProtect:=FILE_MAP_READ;
  end;
  FShare:=0;
  if Mode and fmShareExclusive = 0 then
    if Mode and fmShareDenyRead <> 0 then
      FShare:=FILE_SHARE_WRITE
    else if Mode and fmShareDenyWrite <> 0 then
      FShare:=FILE_SHARE_READ
    else if Mode and fmShareDenyNone <> 0 then
      FShare:=FILE_SHARE_READ or FILE_SHARE_WRITE;
{$ENDIF}
end;

procedure TVMemoryMappedStream.CreateMapping;
begin
{$IFDEF LINUX}
{$ELSE}
  {$IFDEF USE_STREAM64}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    FMapHandle:=CreateFileMappingW(THandle(FHandle), nil, FPageProtect,
      PUInt32(PChar(@FCapacity) + 4)^, UInt32(FCapacity), PWideChar(FMapName))
  else
    FMapHandle:=CreateFileMapping(THandle(FHandle), nil, FPageProtect,
      PUInt32(PChar(@FCapacity) + 4)^, UInt32(FCapacity), PChar(String(FMapName)));
  {$ELSE}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    FMapHandle:=CreateFileMappingW(THandle(FHandle), nil, FPageProtect, 0,
      FCapacity, PWideChar(FMapName))
  else
    FMapHandle:=CreateFileMapping(THandle(FHandle), nil, FPageProtect, 0,
      FCapacity, PChar(String(FMapName)));
  {$ENDIF}
  if FMapHandle = 0 then
    raise EVStream.CreateFmt(SCreateMappingError_sd, [FMapName, GetLastError]);
  FNewMapping:=GetLastError = 0;
  FMemory:=MapViewOfFile(FMapHandle, FMemProtect, 0, 0, 0);
  if FMemory = nil then
    raise EVStream.CreateFmt(SFileMappingError_sd, [FFileName, GetLastError]);
{$ENDIF}
end;

constructor TVMemoryMappedStream.Create(const AFileName, AMapName: String;
  Mode: Word);
begin
  CreateWithCapacityW(AFileName, AMapName, Mode, MemoryDelta);
end;

constructor TVMemoryMappedStream.CreateWithCapacity(const AFileName,
  AMapName: String; Mode: Word; ACapacity: ILong);
begin
  CreateWithCapacityW(AFileName, AMapName, Mode, ACapacity);
end;

constructor TVMemoryMappedStream.Open(const AMapName: String; Mode: Word);
begin
  OpenW(AMapName, Mode);
end;

constructor TVMemoryMappedStream.CreateW(const AFileName, AMapName: WideString;
  Mode: Word);
begin
  CreateWithCapacityW(AFileName, AMapName, Mode, MemoryDelta);
end;

constructor TVMemoryMappedStream.CreateWithCapacityW(const AFileName,
  AMapName: WideString; Mode: Word; ACapacity: ILong);
var
  CreateDisp: DWORD;
begin
  CreateInherited;
{$IFDEF LINUX}
{$ELSE}
  FFileName:=AFileName;
  FMapName:=AMapName;
  SetAttributes(Mode);
  FCapacity:=ACapacity;
  if AFileName <> '' then begin
    if Mode = fmCreate then
      CreateDisp:=CREATE_ALWAYS
    else
      CreateDisp:=OPEN_EXISTING;
    if Win32Platform = VER_PLATFORM_WIN32_NT then
      FHandle:=CreateFileW(PWideChar(AFileName), FAccess, FShare, nil,
        CreateDisp, 0, 0)
    else
      FHandle:=CreateFile(PChar(String(AFileName)), FAccess, FShare, nil,
        CreateDisp, 0, 0);
    if THandle(FHandle) = INVALID_HANDLE_VALUE then
      Error(SFileCreateError, CFileCreateError);
    if Mode <> fmCreate then begin
      {$IFDEF USE_STREAM64}
      PUInt32(@FSize)^:=GetFileSize(FHandle, PChar(@FSize) + 4);
      if (PUInt32(@FSize)^ = $FFFFFFFF) and (GetLastError <> NO_ERROR) then
        Error(SFileGetSizeError, CFileGetSizeError);
      {$ELSE}
      FSize:=GetFileSize(FHandle, @CreateDisp);
      if (CreateDisp <> 0) or (FSize < 0) then
        Error(SFileTooLarge, CFileTooLarge);
      {$ENDIF}
      if FSize > ACapacity then
        FCapacity:=FSize;
    end;
  end
  else begin
    DWORD(FHandle):=DWORD($FFFFFFFF);
    FSize:=ACapacity;
  end;
  CreateMapping;
{$ENDIF}
end;

constructor TVMemoryMappedStream.OpenW(const AMapName: WideString; Mode: Word);
begin
  CreateInherited;
{$IFDEF LINUX}
{$ELSE}
  FMapName:=AMapName;
  SetAttributes(Mode);
  FSize:=MemoryDelta;
  FCapacity:=MemoryDelta;
  THandle(FHandle):=INVALID_HANDLE_VALUE;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    FMapHandle:=OpenFileMappingW(FMemProtect, False, PWideChar(AMapName))
  else
    FMapHandle:=OpenFileMapping(FMemProtect, False, PChar(String(AMapName)));
  if FMapHandle = 0 then
    raise EVStream.CreateFmt(SOpenMappingError_sd, [AMapName, GetLastError]);
  FMemory:=MapViewOfFile(FMapHandle, FMemProtect, 0, 0, 0);
  if FMemory = nil then
    raise EVStream.CreateFmt(SFileMappingError_sd, [AMapName, GetLastError]);
{$ENDIF}
end;

procedure TVMemoryMappedStream.CloseHandles;
begin
  try
    if FMemory <> nil then
      if not (FlushViewOfFile(FMemory, 0) and UnmapViewOfFile(FMemory)) then
        Error(SFlushError, 0);
  finally
    FMemory:=nil;
    if FMapHandle <> 0 then
      Windows.CloseHandle(FMapHandle);
  end;
end;

destructor TVMemoryMappedStream.Destroy;
begin
  try
    CloseHandles;
  finally
    if (FAccess <> GENERIC_READ) and (FileSeek(FHandle, FSize, 0) = FSize) then
      SetEndOfFile(FHandle);
    inherited Destroy;
  end;
end;

function TVMemoryMappedStream.GetSize: ILong;
begin
  Result:=FSize;
end;

procedure TVMemoryMappedStream.SetSize(NewSize: ILong);
begin
  if NewSize <> FSize then begin
    SetCapacity(NewSize);
    FSize:=NewSize;
    if FPosition > NewSize then
      FPosition:=NewSize;
  end;
end;

procedure TVMemoryMappedStream.SetCapacity(NewCapacity: ILong);
var
  Err: Int32;
begin
  NewCapacity:=(NewCapacity + MemoryDelta - 1) and -MemoryDelta;
  if FCapacity <> NewCapacity then begin
    { Close MMF and try to recreate it with the new size.
      FHandle = INVALID_HANDLE_VALUE for the opened (not created!) named
      mapping object. }
    if THandle(FHandle) <> INVALID_HANDLE_VALUE then begin
      CloseHandles;
      CloseHandle;
      FHandle:=CreateFile(PChar(FFileName), FAccess, FShare, nil, OPEN_EXISTING, 0, 0);
      if THandle(FHandle) = INVALID_HANDLE_VALUE then
        Error(SFileCreateError, CFileCreateError);
      FSize:=GetFileSize(FHandle, @Err);
      if (Err <> 0) or (FSize < 0) then
        Error(SFileTooLarge, CFileTooLarge);
    end
    else
      Error(SSetSizeError, 0);
    FCapacity:=NewCapacity;
    CreateMapping;
  end;
end;

procedure TVMemoryMappedStream.Seek(Offset: ILong);
begin
  if (Offset < 0) or (Offset > FSize) then
    Error(Format(SSeekError_d, [Offset]), 0);
  FPosition:=Offset;
end;

procedure TVMemoryMappedStream.WriteProc(const Buffer; Count: Int32);
var
  Pos: Int32;
begin
  if FSize < 0 then
    Error(SFileWriteError, 0); { FSize = -1 after CloseHandle }
  if Count >= 0 then begin
    Pos:=FPosition + Count;
    if Pos > 0 then begin
      if Pos > FSize then begin
        if Pos > FCapacity then
          SetCapacity(Pos);
        FSize:=Pos;
      end;
      Move(Buffer, (PChar(FMemory) + FPosition)^, Count);
      FPosition:=Pos;
    end;
  end;
end;

function TVMemoryMappedStream.ReadFunc(var Buffer; Count: Int32): Int32;
begin
  if Count > 0 then begin
    Result:=FSize - FPosition;
    if Result < 0 then
      Error(SFileReadError, 0);
    if Result > Count then
      Result:=Count;
    Move((PChar(FMemory) + FPosition)^, Buffer, Result);
    Inc(FPosition, Result);
  end
  else
    Result:=0;
end;

function TVMemoryMappedStream.Flush: Boolean;
begin
  Result:=FlushViewOfFile(FMemory, 0);
end;

function TVMemoryMappedStream.Search(const SearchBytes; SearchCount: Integer;
  MaxBytesRead: ILong): Boolean;
var
  I: Integer;
begin
  if ReadFilter = nil then begin
    I:=FSize - FPosition;
    if I < 0 then
      Error(SFileReadError, 0);
    if MaxBytesRead > I then
      MaxBytesRead:=I;
    I:=FindInBuf(SearchBytes, SearchCount, (PChar(FMemory) + FPosition)^,
      MaxBytesRead);
    if I >= 0 then begin
      Inc(FPosition, I);
      Result:=True;
    end
    else
      Result:=False;
  end
  else
    Result:=inherited Search(SearchBytes, SearchCount, MaxBytesRead);
end;

end.
