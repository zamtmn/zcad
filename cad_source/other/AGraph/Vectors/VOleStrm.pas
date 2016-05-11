{ Version 040810. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit VOleStrm;
{
  Реализует OLE IStream поверх TVStream и наоборот, а также ILockBytes
  поверх TVMemStream.
  Implements OLE IStream upon TVStream and vice versa, and also ILockBytes
  upon TVMemStream.
}

interface

{$I VCheck.inc}

uses
  Windows, ActiveX, ExtType, ExtSys,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VComUtil;

type
  TIStreamAdapter = class(TVStream)
  protected
    FIStream: IStream;
    function GetPos: ILong; override;
    function GetSize: ILong; override;
    procedure SetSize(NewSize: ILong); override;
  public
    constructor Create(AnIStream: IStream);
    procedure Seek(Pos: ILong); override;
    procedure WriteProc(const Buffer; Count: Int32); override;
    function ReadFunc(var Buffer; Count: Int32): Int32; override;
    property Stream: IStream read FIStream;
  end;

  TVStreamAdapter = class(TInterfacedObject, IStream)
  protected
    FStream: TVStream;
  public
    Ownership: Boolean;
    constructor Create(Stream: TVStream);
    destructor Destroy; override;
    function Read(pv: Pointer; cb: Longint;
      pcbRead: PLongint): HResult; virtual; stdcall;
    function Write(pv: Pointer; cb: Longint;
      pcbWritten: PLongint): HResult; virtual; stdcall;
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; virtual; stdcall;
    function SetSize(libNewSize: Largeint): HResult; virtual; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; virtual; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall;
    function Revert: HResult; virtual; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function Stat(out statstg: TStatStg;
      grfStatFlag: Longint): HResult; virtual; stdcall;
    function Clone(out stm: IStream): HResult; virtual; stdcall;
    property Stream: TVStream read FStream;
  end;

  TILockBytesAdapter = class(TInterfacedObject, ILockBytes)
  protected
    FStream: TVStream;
  public
    Ownership: Boolean;
    constructor Create(Stream: TVStream);
    destructor Destroy; override;
    function ReadAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
      pcbRead: PLongint): HResult; virtual; stdcall;
    function WriteAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
      pcbWritten: PLongint): HResult; virtual; stdcall;
    function Flush: HResult; virtual; stdcall;
    function SetSize(cb: Largeint): HResult; virtual; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      virtual; stdcall;
    property Stream: TVStream read FStream;
  end;

implementation

{$IFDEF INT64_EQ_COMP}{$IFDEF USE_STREAM64}
  {$DEFINE FLOAT_ILONG}
{$ENDIF}{$ENDIF}

{$IFNDEF V_D4}{$IFNDEF FLOAT_ILONG}
  {$DEFINE ROUND_LARGEINT}
{$ENDIF}{$ENDIF}

{ TIStreamAdapter }

constructor TIStreamAdapter.Create(AnIStream: IStream);
begin
  inherited Create;
  FIStream:=AnIStream;
end;

function TIStreamAdapter.GetPos: ILong;
var
  NewPos: Largeint;
begin
  ComCheck(FIStream.Seek(0, STREAM_SEEK_CUR, NewPos));
  Result:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(NewPos);
end;

function TIStreamAdapter.GetSize: ILong;
var
  statstg: TStatStg;
begin
  ComCheck(FIStream.Stat(statstg, STATFLAG_NONAME));
  Result:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(statstg.cbSize);
end;

procedure TIStreamAdapter.SetSize(NewSize: ILong);
begin
  IStreamSetSize64(FIStream, NewSize);
end;

procedure TIStreamAdapter.Seek(Pos: ILong);
begin
  IStreamSeek64(FIStream, Pos);
end;

procedure TIStreamAdapter.WriteProc(const Buffer; Count: Int32);
begin
  IStreamWrite(FIStream, Buffer, Count);
end;

function TIStreamAdapter.ReadFunc(var Buffer; Count: Int32): Int32;
begin
  Result:=IStreamReadFunc(FIStream, Buffer, Count);
end;

{ TVStreamAdapter }

constructor TVStreamAdapter.Create(Stream: TVStream);
begin
  inherited Create;
  FStream:=Stream;
end;

destructor TVStreamAdapter.Destroy;
begin
  if Ownership then
    FStream.Free;
  inherited Destroy;
end;

function TVStreamAdapter.Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
var
  NumRead: Longint;
begin
  try
    if pv = nil then begin
      Result:=STG_E_INVALIDPOINTER;
      Exit;
    end;
    NumRead:=FStream.ReadFunc(pv^, cb);
    if pcbRead <> nil then
      pcbRead^:=NumRead;
    Result:=S_OK;
  except
    Result:=S_FALSE;
  end;
end;

function TVStreamAdapter.Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
begin
  try
    if pv = nil then begin
      Result:=STG_E_INVALIDPOINTER;
      Exit;
    end;
    FStream.WriteProc(pv^, cb);
    if pcbWritten <> nil then
      pcbWritten^:=cb;
    Result:=S_OK;
  except
    Result:=STG_E_CANTSAVE;
  end;
end;

function TVStreamAdapter.Seek(dlibMove: Largeint; dwOrigin: Longint;
  out libNewPosition: Largeint): HResult;
begin
  try
    Case dwOrigin of
      STREAM_SEEK_SET:
        FStream.Seek({$IFDEF ROUND_LARGEINT}Round{$ENDIF}(dlibMove));
      STREAM_SEEK_CUR:
        FStream.SeekBy({$IFDEF ROUND_LARGEINT}Round{$ENDIF}(dlibMove));
      STREAM_SEEK_END:
        FStream.Seek(FStream.Size + {$IFDEF ROUND_LARGEINT}Round{$ENDIF}(dlibMove));
    Else
      begin
        Result:=STG_E_INVALIDFUNCTION;
        Exit;
      end;
    End;
    if @libNewPosition <> nil then
      libNewPosition:=FStream.Position;
    Result:=S_OK;
  except
    Result:=STG_E_INVALIDPOINTER;
  end;
end;

function TVStreamAdapter.SetSize(libNewSize: Largeint): HResult;
begin
  try
    FStream.Size:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(libNewSize);
    if libNewSize <> FStream.Size then
      Result:=E_FAIL
    else
      Result:=S_OK;
  except
    Result:=E_UNEXPECTED;
  end;
end;

function TVStreamAdapter.CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
  out cbWritten: Largeint): HResult;
const
  MaxBufSize = MEGABYTE;
var
  Buffer: Pointer;
  I, N, BufSize: Integer;
  W, BytesRead, BytesWritten: LargeInt;
begin
  Result:=S_OK;
  BytesRead:=0;
  BytesWritten:=0;
  try
    if cb > MaxBufSize then
      BufSize:=MaxBufSize
    else
      BufSize:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(cb);
    GetMem(Buffer, BufSize);
    try
      while cb > {$IFDEF FLOAT_ILONG}0.9{$ELSE}0{$ENDIF} do begin
        if cb > MaxInt then
          I:=MaxInt
        else
          I:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(cb);
        while I > 0 do begin
          if I > BufSize then
            N:=BufSize
          else
            N:=I;
          BytesRead:=BytesRead + FStream.ReadFunc(Buffer^, N);
          W:=0;
          Result:=stm.Write(Buffer, N, @W);
          BytesWritten:=BytesWritten + W;
          if (Result = S_OK) and ({$IFDEF ROUND_LARGEINT}Round{$ENDIF}(W) <> N) then
            Result:=E_FAIL;
          if Result <> S_OK then
            Exit;
          Dec(I, N);
        end;
        cb:=cb - I;
      end;
    finally
      FreeMem(Buffer);
      if @cbWritten <> nil then
        cbWritten:=BytesWritten;
      if @cbRead <> nil then
        cbRead:=BytesRead;
    end;
  except
    Result:=E_UNEXPECTED;
  end;
end;

function TVStreamAdapter.Commit(grfCommitFlags: Longint): HResult;
begin
  Result:=S_OK;
end;

function TVStreamAdapter.Revert: HResult;
begin
  Result:=STG_E_REVERTED;
end;

function TVStreamAdapter.LockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result:=STG_E_INVALIDFUNCTION;
end;

function TVStreamAdapter.UnlockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result:=STG_E_INVALIDFUNCTION;
end;

function TVStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
begin
  Result:=S_OK;
  try
    if @statstg <> nil then begin
      SetNull(statstg, SizeOf(statstg));
      With statstg do begin
        dwType:=STGTY_STREAM;
        cbSize:=FStream.Size;
      end;
    end;
  except
    Result:=E_UNEXPECTED;
  end;
end;

function TVStreamAdapter.Clone(out stm: IStream): HResult;
begin
  Result:=E_NOTIMPL;
end;

{ TILockBytesAdapter }

constructor TILockBytesAdapter.Create(Stream: TVStream);
begin
  inherited Create;
  FStream:=Stream;
end;

destructor TILockBytesAdapter.Destroy;
begin
  if Ownership then
    FStream.Free;
  inherited Destroy;
end;

function TILockBytesAdapter.ReadAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
  pcbRead: PLongint): HResult;
begin
  if pv = nil then begin
    Result:=E_FAIL;
    Exit;
  end;
  Result:=S_OK;
  try
    FStream.Seek({$IFDEF ROUND_LARGEINT}Round{$ENDIF}(ulOffset));
    cb:=FStream.ReadFunc(pv^, cb);
    if pcbRead <> nil then
      pcbRead^:=cb;
  except
    Result:=E_FAIL;
  end;
end;

function TILockBytesAdapter.WriteAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
  pcbWritten: PLongint): HResult;
begin
  if pv = nil then begin
    Result:=E_FAIL;
    Exit;
  end;
  Result:=S_OK;
  try
    FStream.Seek({$IFDEF ROUND_LARGEINT}Round{$ENDIF}(ulOffset));
    FStream.WriteProc(pv^, cb);
    if pcbWritten <> nil then
      pcbWritten^:=cb;
  except
    Result:=E_FAIL;
  end;
end;

function TILockBytesAdapter.Flush: HResult;
begin
  Result:=S_OK;
end;

function TILockBytesAdapter.SetSize(cb: Largeint): HResult;
begin
  if FStream = nil then begin
    Result:=STG_E_ACCESSDENIED;
    Exit;
  end;
  Result:=S_OK;
  try
    FStream.Size:={$IFDEF ROUND_LARGEINT}Round{$ENDIF}(cb);
  except
    Result:=STG_E_MEDIUMFULL;
  end;
end;

function TILockBytesAdapter.LockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result:=STG_E_INVALIDFUNCTION;
end;

function TILockBytesAdapter.UnlockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result:=STG_E_INVALIDFUNCTION;
end;

function TILockBytesAdapter.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
begin
  Result:=S_OK;
  try
    if @statstg <> nil then begin
      SetNull(statstg, SizeOf(statstg));
      With statstg do begin
        dwType:=STGTY_LOCKBYTES;
        cbSize:=FStream.Size;
      end;
    end;
  except
    Result:=E_UNEXPECTED;
  end;
end;

end.
