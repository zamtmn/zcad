{ Version 050625. Copyright © Alexey A.Chernobaev, 2000-5 }

unit VFileSys;

interface

{$I VCheck.inc}

uses
  {$IFNDEF V_WIN}{$IFNDEF LINUX}{$DEFINE V_WIN}{$ENDIF}{$ENDIF}
  {$IFDEF V_WIN}Windows,{$ENDIF}
  {$IFDEF LINUX}{$IFDEF V_KYLIX}Libc{$ELSE}Linux{$ENDIF},{$ENDIF}
  SysUtils, ExtType, ExtSys, VectStr, VectErr;

//{$IFNDEF V_WIN}{$IFNDEF LINUX}Error!{$ENDIF}{$ENDIF}

const
  InvalidWinFileNameChars = ['"', '*', '?', '/', ':', '<', '>', '\', '|'];
  {$IFDEF LINUX}
  InvalidFileNameChars = ['*', '?', '/'];
  {$ELSE}
  InvalidFileNameChars = InvalidWinFileNameChars;
  {$ENDIF}
  InvalidFileMaskChars = InvalidFileNameChars - ['*', '?'];

  MaxFileLen = 1023;

{$IFNDEF V_D4} // Delphi 3 or Free Pascal
function IsPathDelimiter(const S: String; Index: Integer): Boolean;
{$ENDIF} {V_D4}

{$IFNDEF V_D5}
// Delphi 3 or Delphi 4 or Free Pascal
function IncludeTrailingBackslash(const S: String): String;
function ExcludeTrailingBackslash(const S: String): String;

{$IFDEF V_WIN}
function SafeLoadLibrary(const FileName: String;
  ErrorMode: UINT{$IFDEF V_DEFAULTS} = SEM_NOOPENFILEERRORBOX{$ENDIF}): HMODULE;
{$ENDIF} {V_WIN}

{$ENDIF} {V_D5}

{$IFNDEF V_D6}
function IncludeTrailingPathDelimiter(const S: String): String;
function ExcludeTrailingPathDelimiter(const S: String): String;
{$ENDIF} {V_D6}

{$IFDEF V_WIN}
function SafeLoadLibraryW(const FileName: WideString;
  ErrorMode: UINT{$IFDEF V_DEFAULTS} = SEM_NOOPENFILEERRORBOX{$ENDIF}): HMODULE;
{$ENDIF}

type
  TFileBuf = array [0..MaxFileLen] of AnsiChar;
  TFileBufW = array [0..MaxFileLen] of WideChar;

function GetCurrentDirW: WideString;
function SetCurrentDirW(const Dir: WideString): Boolean;
function LastDelimiterW(const Delimiters, W: WideString): Integer;
function ChangeFileExtW(const FileName, Extension: WideString): WideString;
function ExtractFilePathW(const FileName: WideString): WideString;
function ExtractFileExtW(const FileName: WideString): WideString;
function ExtractFileNameW(const FileName: WideString): WideString;
function ExpandFileNameW(const FileName: WideString): WideString;
function IncludePathDelimiterW(const S: WideString): WideString;
function ExcludePathDelimiterW(const S: WideString): WideString;

{ why use pLastOSError: GetLastError will be altered by WideString cleaning
  code (under Windows) }
{$IFDEF V_WIN}
{$ENDIF}

{$IFDEF LINUX}

//function UserName(uid: __uid_t): WideString;

//function GroupName(gid: __gid_t): WideString;
{$ENDIF}

function ValidateFileName(const FileName: String; MaxLen: Integer): String;

function IsFileNameSyntaxValid(const FileName: WideString): Boolean;

function IsAbsolutePathSyntaxValid(const Path: WideString): Boolean;

function GetTempDir: String;

type
  TFileLock = {$IFDEF LINUX}Integer{$ELSE}THandle{$ENDIF};

{ блокирует файл на запись; в случае успеха возвращает дескриптор файла, иначе
  возвращает INVALID_HANDLE_VALUE (Linux: -1) }
{ write-locks the given file; returns a file handle if successful or
  INVALID_HANDLE_VALUE (Linux: -1) if failed }

{$IFDEF V_WIN}
function GetTempDirW: WideString;

function GetWindowsDir: String;
function GetWindowsDirW: WideString;

function GetSystemDir: String;
function GetSystemDirW: WideString;

function LockFileRead(const FileName: String): THandle;

function GetLongFileName(const Name: String): String;
  {$IFDEF V_D6}platform;{$ENDIF}
{ возвращает "длинное" имя, соответствующее заданному "короткому" имени файла
  или директории либо пустую строку, если файл или директория не найдены; в
  функцию можно передавать "длинные" имена }
{ returns the long name corresponding to the specified short file or directory
  name or the empty string if the file or directory were not found; it's legal
  to pass long names to the function }


{$ENDIF} {V_WIN}

{$IFDEF V_DELPHI}{$IFNDEF V_D6}
function DirectoryExists(const Name: String): Boolean;
{$ENDIF}{$ENDIF}

{$IFDEF V_DELPHI}{$IFNDEF V_D6}
function ForceDirectories(Dir: String): Boolean;
{$ENDIF}{$ENDIF}

function ExcludeFileExt(const Name: String): String;
function ExcludeFileExtW(const Name: WideString): WideString;
{ возвращает имя файла без расширения }
{ excludes an extension from the given file name }

function ShortenFileName(const FileName: String; MaxLen: Integer;
  DelimitChars: TCharSet{$IFDEF V_DEFAULTS} = []{$ENDIF}): String;
function ShortenFileNameW(const FileName: WideString; MaxLen: Integer;
  DelimitChars: TCharSet{$IFDEF V_DEFAULTS} = []{$ENDIF}): WideString;

function GetModuleNameW(Module: HMODULE): WideString;
{ returns a name of a file which contains the specified module }

procedure ParseFileName(const FileName: String; var Path, Name: String);
procedure ParseFileNameW(const FileName: WideString; var Path, Name: WideString);

function FirstItemDelimiterW(const Path: WideString): Integer;
{ returns an index of the first PathDelim or '|' character (0 if not found) }

function LastItemDelimiterW(const Path: WideString): Integer;
{ returns an index of the last PathDelim or '|' character (0 if not found) }

procedure ParseItemName(const FullItemName: String; var Path, Name: String);
procedure ParseItemNameW(const FullItemName: WideString; var Path,
  Name: WideString);

function GetItemNameW(const FullItemName: WideString): WideString;
function GetItemPathW(const FullItemName: WideString): WideString;

function CorrectFileName(const Name: String;
  DefaultChar: AnsiChar{$IFDEF V_DEFAULTS} = '_'{$ENDIF}): String;
function CorrectFileNameW(const Name: WideString;
  DefaultChar: WideChar{$IFDEF V_DEFAULTS} = '_'{$ENDIF}): WideString;

function CorrectPathName(const Name: String;
  DefaultChar: AnsiChar{$IFDEF V_DEFAULTS} = '_'{$ENDIF}): String;
function CorrectPathNameW(const Name: WideString;
  DefaultChar: WideChar{$IFDEF V_DEFAULTS} = '_'{$ENDIF}): WideString;

function GetStdFileExt(const FileName: String): String;
{ возвращает расширение файла без начальной точки, всегда в нижнем регистре }
{ returns an extension portion of the given file name without a leading dot,
  always in lowercase }

{$IFDEF V_DEFAULTS}

{$IFDEF V_WIN}
function GetFileProps(const FileName: String; pSize: PInt64;
  pModifyTime: PDateTime = nil; pCreationTime: PDateTime = nil;
  pLastAccessTime: PDateTime = nil; pAttributes: PDWORD = nil;
  pLastOSError: PDWORD = nil): Boolean;

function GetFilePropsW(const FileName: WideString; pSize: PInt64;
  pModifyTime: PDateTime = nil; pCreationTime: PDateTime = nil;
  pLastAccessTime: PDateTime = nil; pAttributes: PDWORD = nil;
  pLastOSError: PDWORD = nil): Boolean;
{$ENDIF}

{$IFDEF LINUX}
function GetFileProps(const FileName: String; pSize: PInt64;
  pModifyTime: PDateTime = nil; pLastStatusChangeTime: PDateTime = nil;
  pLastAccessTime: PDateTime = nil; pAttributes: PUInt32 = nil;
  pUser: PUInt32  = nil; pGroup: PUInt32  = nil): Boolean;

function GetFilePropsW(const FileName: WideString; pSize: PInt64;
  pModifyTime: PDateTime = nil; pLastStatusChangeTime: PDateTime = nil;
  pLastAccessTime: PDateTime = nil; pAttributes: PUInt32 = nil;
  pUser: PUInt32  = nil; pGroup: PUInt32  = nil): Boolean;

function GetLinkTarget(const PathOnly: String): String;
{$ENDIF} {LINUX}

{$ELSE}

{$ENDIF} {V_DEFAULTS}

function IsRelativePath(const FileName: String): Boolean;

implementation

{$IFNDEF V_D4}
function IsPathDelimiter(const S: String; Index: Integer): Boolean;
begin
  Result:=(Index > 0) and (Index <= Length(S)) and (S[Index] = PathDelim) and
    (ByteType(S, Index) = mbSingleByte);
end;
{$ENDIF}

{$IFNDEF V_D5}
function IncludeTrailingBackslash(const S: String): String;
begin
  Result:=S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result:=Result + PathDelim;
end;

function ExcludeTrailingBackslash(const S: String): String;
begin
  Result:=S;
  if IsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result) - 1);
end;

{$IFDEF V_WIN}
function SafeLoadLibrary(const FileName: String; ErrorMode: UINT): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  OldMode:=SetErrorMode(ErrorMode);
  try
    asm
      FNSTCW  FPUControlWord
    end;
    try
      Result:=LoadLibrary(PChar(FileName));
    finally
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;
{$ENDIF} {V_WIN}

{$ENDIF} {V_D5}

{$IFNDEF V_D6}
function IncludeTrailingPathDelimiter(const S: String): String;
begin
  Result:=IncludeTrailingBackslash(S);
end;

function ExcludeTrailingPathDelimiter(const S: String): String;
begin
  Result:=ExcludeTrailingBackslash(S);
end;
{$ENDIF} {V_D6}

{$IFDEF V_WIN}
function SafeLoadLibraryW(const FileName: WideString; ErrorMode: UINT): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    OldMode:=SetErrorMode(ErrorMode);
    try
      asm
        FNSTCW  FPUControlWord
      end;
      try
        Result:=LoadLibraryW(PWideChar(FileName));
      finally
        asm
          FNCLEX
          FLDCW FPUControlWord
        end;
      end;
    finally
      SetErrorMode(OldMode);
    end;
  end
  else
    Result:=SafeLoadLibrary(FileName, ErrorMode);
end;
{$ENDIF}

function GetCurrentDirW: WideString;
{$IFDEF V_WIN}
var
  Sz: DWORD;
  Buf: TFileBufW;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Sz:=GetCurrentDirectoryW(SizeOf(Buf) div 2, Buf);
    if (Sz > 0) and (Sz < SizeOf(Buf) div 2) then begin
      SetWideString(Result, Buf, Sz);
      Exit;
    end;
  end;
  {$ENDIF}
  Result:=GetCurrentDir;
end;

function SetCurrentDirW(const Dir: WideString): Boolean;
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=SetCurrentDirectoryW(PWideChar(Dir))
  else
  {$ENDIF}
    Result:=SetCurrentDir(Dir);
end;

function LastDelimiterW(const Delimiters, W: WideString): Integer;
var
  L: Integer;
  P: PWideChar;
begin
  Result:=Length(W);
  L:=Length(Delimiters);
  P:=PWideChar(Delimiters);
  while Result > 0 do begin
    if (W[Result] <> #0) and (IndexOfValue16(P^, Smallint(W[Result]), L) >= 0) then
      Exit;
    Dec(Result);
  end;
end;

function ChangeFileExtW(const FileName, Extension: WideString): WideString;
var
  I: Integer;
begin
  I:=LastDelimiterW('.' + PathDelim + DriveDelim, FileName);
  if (I = 0) or (FileName[I] <> '.') then
    I:=MaxInt;
  Result:=Copy(FileName, 1, I - 1) + Extension;
end;

function ExtractFilePathW(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I:=LastDelimiterW(PathDelim + DriveDelim, FileName);
  Result:=Copy(FileName, 1, I);
end;

function ExtractFileExtW(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I:=LastDelimiterW('.' + PathDelim + DriveDelim, FileName);
  if (I > 0) and (FileName[I] = '.') then
    Result:=Copy(FileName, I, MaxInt)
  else
    Result:='';
end;

function ExtractFileNameW(const FileName: WideString): WideString;
var
  I: Integer;
begin
  I:=LastDelimiterW(PathDelim + DriveDelim, FileName);
  Result:=Copy(FileName, I + 1, MaxInt);
end;

function ExpandFileNameW(const FileName: WideString): WideString;
{$IFDEF V_WIN}
var
  L: DWORD;
  LastDot: Boolean;
  PW: PWideChar;
  P: PChar;
  BufW: TFileBufW;
  Buf: TFileBuf absolute BufW;
begin
  if FileName = '' then begin
    {$IFNDEF V_AUTOINITSTRINGS}
    Result:='';
    {$ENDIF}
    Exit;
  end;
  BufW[0]:=#0;
  LastDot:=FileName[Length(FileName)] = '.';
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    L:=GetFullPathNameW(Pointer(FileName), SizeOf(BufW) div 2, BufW, PW);
    if (L = 0) or (L >= SizeOf(BufW) div 2) then begin
      Result:=FileName;
      Exit;
    end;
    Result:=LWideString(@BufW, L);
  end
  else begin
    L:=GetFullPathName(PChar(String(FileName)), SizeOf(Buf), @Buf, P);
    if (L = 0) or (L >= SizeOf(Buf)) then begin
      Result:=FileName;
      Exit;
    end;
    Result:=WideString(LString(@Buf, L));
  end;
  if LastDot then
    Result:=Result + '.';
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result:=ExpandFileName(FileName);
end;
{$ENDIF}

function IncludePathDelimiterW(const S: WideString): WideString;
begin
  Result:=S;
  if (Result = '') or (Result[Length(Result)] <> PathDelim) then
    Result:=Result + PathDelim;
end;

function ExcludePathDelimiterW(const S: WideString): WideString;
var
  L: Integer;
begin
  Result:=S;
  L:=Length(Result);
  if (L > 0) and (Result[L] = PathDelim) then
    SetLength(Result, L - 1);
end;



{$IFDEF V_WIN}

{$ENDIF}

function ValidateFileName(const FileName: String; MaxLen: Integer): String;
var
  I: Integer;
begin
  Result:=Copy(FileName, 1, MaxLen);
  for I:=1 to Length(Result) do
    if Result[I] in InvalidFileNameChars then
      Result[I]:='_';
end;

{$IFDEF LINUX}

{$ENDIF} {LINUX}

function IsFileNameSyntaxValid(const FileName: WideString): Boolean;
var
  I: Integer;
  {$IFDEF V_WIN}
  Path: WideString;
  {$ENDIF}
begin
  Result:=False;
  if FileName = '' then
    Exit;
  I:=LastDelimiterW(PathDelim + DriveDelim, FileName);
  if WideContainsChars(Copy(FileName, I + 1, MaxInt), InvalidFileNameChars) then
    Exit;
  if I <= 0 then begin
    Result:=True;
    Exit;
  end;
  {$IFDEF V_WIN}
  Path:=Copy(FileName, 1, I - 1);
  if (FileName[I] = DriveDelim) and not IsAbsolutePathSyntaxValid(Path) then
    Exit;
  Result:=not WideContainsChars(Path, InvalidFileNameChars - [PathDelim, DriveDelim]);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=not WideContainsChars(Copy(FileName, 1, I - 1), InvalidFileNameChars -
    [PathDelim]);
  {$ENDIF}
end;

function IsAbsolutePathSyntaxValid(const Path: WideString): Boolean;
begin
  {$IFDEF V_WIN}
  Result:=(Length(Path) >= 2) and
    (
      WideCharIn(Path[1], ASCIIAlpha) and (Path[2] = ':') or
      (Path[1] = '\') and (Path[2] = '\')
    ) and
    (WideCharPos(':', Path, 3) = 0);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=(Path <> '') and (Path[1] = '/');
  {$ENDIF}
end;


function GetTempDir: String;
{$IFDEF V_WIN}
var
  L: DWORD;
  Buf: array [0..MAX_PATH] of AnsiChar;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  L:=GetTempPath(SizeOf(Buf), Buf);
  OSCheck((L > 0) and (L <= High(Buf)));
  SetString(Result, Buf, L);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=GetTempDir;
  if Result = '' then
    Result:='/tmp/'
  else
    if Result[Length(Result)] <> '/' then
      Result:=Result + '/';
  {$ENDIF}
end;


{$IFDEF V_WIN}
function GetTempDirW: WideString;
var
  L: DWORD;
  Buf: array [0..MAX_PATH] of WideChar;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    L:=GetTempPathW(SizeOf(Buf) div 2, Buf);
    OSCheck((L > 0) and (L <= High(Buf)));
    Result:=WideString(Buf);
  end
  else
    Result:=GetTempDir;
end;

function GetWindowsDir: String;
var
  L: UINT;
  Buf: array [0..MAX_PATH] of AnsiChar;
begin
  L:=GetWindowsDirectory(Buf, SizeOf(Buf));
  OSCheck((L > 0) and (L <= High(Buf)));
  SetString(Result, Buf, L);
end;

function GetWindowsDirW: WideString;
var
  L: UINT;
  Buf: array [0..MAX_PATH] of WideChar;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    L:=GetWindowsDirectoryW(Buf, SizeOf(Buf) div 2);
    OSCheck((L > 0) and (L <= High(Buf)));
    Result:=WideString(Buf);
  end
  else
    Result:=GetWindowsDir;
end;

function GetSystemDir: String;
var
  L: UINT;
  Buf: array [0..MAX_PATH] of AnsiChar;
begin
  L:=GetSystemDirectory(Buf, SizeOf(Buf));
  OSCheck((L > 0) and (L <= High(Buf)));
  SetString(Result, Buf, L);
end;

function GetSystemDirW: WideString;
var
  L: UINT;
  Buf: array [0..MAX_PATH] of WideChar;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    L:=GetSystemDirectoryW(Buf, SizeOf(Buf) div 2);
    OSCheck((L > 0) and (L <= High(Buf)));
    Result:=WideString(Buf);
  end
  else
    Result:=GetSystemDir;
end;

function LockFileRead(const FileName: String): THandle;
begin
  Result:=CreateFile(PChar(FileName), GENERIC_READ, 0, nil, OPEN_EXISTING,
    FILE_FLAG_NO_BUFFERING, 0);
end;

function GetLongFileName(const Name: String): String;

  function ProcessExpanded(const ExpName: String): String;
  var
    I: Integer;
    S, Path: String;
    SR: TSearchRec;
  begin
    Result:=ExpName;
    I:=Length(Result);
    if I > 0 then begin
      if Result[I] = '\' then begin
        Dec(I);
        if (I > 0) and (Result[I] = ':') then
          Exit;
        SetLength(Result, I);
      end
      else
        if Result[I] = ':' then
          Exit;
      ParseFileName(Result, Path, S);
      if (CharPos('*', S, 1) = 0) and (CharPos('?', S, 1) = 0) then begin
        if SysUtils.FindFirst(Result, faAnyFile and not faVolumeID, SR) = 0 then
          SysUtils.FindClose(SR)
        else
          Exit;
        if SR.Name = '.' then // бывает... can happen...
          Exit;
        if SysUtils.FindFirst(Path + SR.Name, faAnyFile and not faVolumeID, SR) = 0 then
          SysUtils.FindClose(SR)
        else // тоже бывает... can happen too...
          SR.Name:=S;
      end
      else
        SR.Name:=S;
      if Length(Path) < I then begin
        if CharPos('~', Path, 1) > 0 then begin
          Path:=ProcessExpanded(Path);
          I:=Length(Path);
          if (I > 0) and (Path[I] <> '\') then
            Path:=Path + '\';
        end;
        Result:=Path + SR.Name;
      end;
    end;
  end;

begin
  Result:=Name;
  if Result <> '' then begin
    if Result[Length(Result)] = ':' then
      Result:=Result + '\';
    Result:=ExpandFileName(Result);
    if CharPos('~', Result, 1) > 0 then
      Result:=ProcessExpanded(Result);
  end;
end;

{$ENDIF}

{$IFDEF V_DELPHI}{$IFNDEF V_D6}
function DirectoryExists(const Name: String): Boolean;
var
  Code: DWORD;
begin
  Code:=GetFileAttributes(PChar(Name));
  Result:=(Code <> DWORD(-1)) and (Code and FILE_ATTRIBUTE_DIRECTORY <> 0);
end;
{$ENDIF}{$ENDIF}

{$IFDEF V_DELPHI}{$IFNDEF V_D6}
function ForceDirectories(Dir: String): Boolean;
var
  L: Integer;
  E: EInOutError;
begin
  Result:=True;
  if Dir = '' then begin
    E:=EInOutError.Create(SCreateDirError);
    E.ErrorCode:=3;
    raise E;
  end;
  L:=Length(Dir);
  if IsPathDelimiter(Dir, L) then
    SetLength(Dir, L - 1);
  {$IFDEF V_WIN}
  if (Length(Dir) < 3) or DirectoryExists(Dir) or (ExtractFilePath(Dir) = Dir) then
    Exit; // avoid 'xyz:\' problem.
  {$ENDIF}
  {$IFDEF LINUX}
  if (Dir = '') or DirectoryExists(Dir) then
    Exit;
  {$ENDIF}
  Result:=ForceDirectories(ExtractFilePath(Dir)) and CreateDir(Dir);
end;
{$ENDIF}{$ENDIF}

function ExcludeFileExt(const Name: String): String;
begin
  Result:=Name;
  SetLength(Result, Length(Result) - Length(ExtractFileExt(Name)));
end;

function ExcludeFileExtW(const Name: WideString): WideString;
begin
  Result:=Name;
  SetLength(Result, Length(Result) - Length(ExtractFileExtW(Name)));
end;

function ShortenFileName(const FileName: String; MaxLen: Integer;
  DelimitChars: TCharSet): String;

  procedure SetDots(FromIndex: Integer);
  begin
    Result[FromIndex]:='.';
    Result[FromIndex - 1]:='.';
    Result[FromIndex - 2]:='.';
  end;

var
  I, J, K, L, Len: Integer;
  B: Boolean;
begin
  Result:=FileName;
  Len:=Length(Result);
  if MaxLen < 4 then
    MaxLen:=4;
  L:=Len - MaxLen;
  if L > 0 then begin
    if DelimitChars = [] then
      DelimitChars:=[PathDelim];
    I:=CharInSetPos(DelimitChars, Result, 1);
    if I > 0 then begin
      J:=Len;
      while (J > I) and not (Result[J] in DelimitChars) do Dec(J);
      K:=J - I - 5; { how many chars in the "middle" can we delete }
      if K > 0 then begin
        if K >= L then begin
          K:=L;
          B:=True;
        end
        else
          B:=False;
        Dec(J, K);
        Delete(Result, J, K);
        SetDots(J - 1);
        if B then
          Exit;
      end;
    end;
    SetLength(Result, MaxLen);
    SetDots(MaxLen);
  end;
end;

function ShortenFileNameW(const FileName: WideString; MaxLen: Integer;
  DelimitChars: TCharSet): WideString;

  procedure SetDots(FromIndex: Integer);
  begin
    Result[FromIndex]:='.';
    Result[FromIndex - 1]:='.';
    Result[FromIndex - 2]:='.';
  end;

var
  I, J, K, L, Len: Integer;
  B: Boolean;
begin
  Result:=FileName;
  Len:=Length(Result);
  if MaxLen < 4 then
    MaxLen:=4;
  L:=Len - MaxLen;
  if L > 0 then begin
    if DelimitChars = [] then
      DelimitChars:=[PathDelim];
    I:=WideCharInSetPos(DelimitChars, Result, 1);
    if I > 0 then begin
      J:=Len;
      while (J > I) and (Result[J] < #256) and
        not (AnsiChar(Result[J]) in DelimitChars)
      do
        Dec(J);
      K:=J - I - 5; { how many chars in the "middle" can we delete }
      if K > 0 then begin
        if K >= L then begin
          K:=L;
          B:=True;
        end
        else
          B:=False;
        Dec(J, K);
        Delete(Result, J, K);
        SetDots(J - 1);
        if B then
          Exit;
      end;
    end;
    SetLength(Result, MaxLen);
    SetDots(MaxLen);
  end;
end;

function GetModuleNameW(Module: HMODULE): WideString;
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    SetLength(Result, MAX_PATH);
    SetLength(Result, GetModuleFileNameW(Module, Pointer(Result), MAX_PATH));
  end
  else
  {$ENDIF}
    Result:=GetModuleName(Module);
end;

procedure ParseFileName(const FileName: String; var Path, Name: String);
var
  I: Integer;
begin
  I:=LastDelimiter(PathDelim + DriveDelim, FileName);
  Path:=Copy(FileName, 1, I);
  Name:=Copy(FileName, I + 1, MaxInt);
end;

procedure ParseFileNameW(const FileName: WideString; var Path, Name: WideString);
var
  I: Integer;
begin
  I:=LastDelimiterW(PathDelim + DriveDelim, FileName);
  Path:=Copy(FileName, 1, I);
  Name:=Copy(FileName, I + 1, MaxInt);
end;

function FirstItemDelimiterW(const Path: WideString): Integer;
var
  I: Integer;
begin
  for I:=1 to Length(Path) do
    if (Path[I] = PathDelim) or (Path[I] = '|') then begin
      Result:=I;
      Exit;
    end;
  Result:=0;
end;

function LastItemDelimiterW(const Path: WideString): Integer;
var
  I: Integer;
begin
  for I:=Length(Path) downto 1 do
    if (Path[I] = PathDelim) or (Path[I] = '|') then begin
      Result:=I;
      Exit;
    end;
  Result:=0;
end;

const
  ItemDelimiters = '|' + PathDelim + DriveDelim;

procedure ParseItemName(const FullItemName: String; var Path, Name: String);
var
  I: Integer;
begin
  I:=LastDelimiter(ItemDelimiters, FullItemName);
  Path:=Copy(FullItemName, 1, I - 1);
  Name:=Copy(FullItemName, I + 1, MaxInt);
end;

procedure ParseItemNameW(const FullItemName: WideString; var Path, Name: WideString);
var
  I: Integer;
begin
  I:=LastDelimiterW(ItemDelimiters, FullItemName);
  Path:=Copy(FullItemName, 1, I - 1);
  Name:=Copy(FullItemName, I + 1, MaxInt);
end;

function GetItemNameW(const FullItemName: WideString): WideString;
begin
  Result:=Copy(FullItemName, LastDelimiterW(ItemDelimiters, FullItemName) + 1, MaxInt);
end;

function GetItemPathW(const FullItemName: WideString): WideString;
begin
  Result:=Copy(FullItemName, 1, LastDelimiterW(ItemDelimiters, FullItemName) - 1);
end;

function CorrectFilePathName(const Name: String; DefaultChar: AnsiChar;
  ProhibitedChars: TCharSet): String;
var
  I: Integer;
  C: AnsiChar;
begin
  Result:=Name;
  for I:=1 to Length(Name) do begin
    C:=Name[I];
    if C < #32 then
      Result[I]:=DefaultChar
    else if C in ProhibitedChars then begin
      {$IFDEF V_WIN}
      Case C of
        '"': C:='''';
        '<': C:=#$AB;
        '>': C:=#$BB;
        '|': C:=#$A6;
      Else
        C:=DefaultChar;
      End;
      Result[I]:=C;
      {$ENDIF}
      {$IFDEF LINUX}
      Result[I]:=DefaultChar;
      {$ENDIF}
    end;
  end; {for}
end;

function CorrectFilePathNameW(const Name: WideString; DefaultChar: WideChar;
  ProhibitedChars: TCharSet): WideString;
var
  I: Integer;
  W: WideChar;
begin
  Result:=Name;
  for I:=1 to Length(Name) do begin
    W:=Name[I];
    if W < #32 then
      Result[I]:=DefaultChar
    else if (W < #256) and (AnsiChar(W) in ProhibitedChars) then begin
      {$IFDEF V_WIN}
      Case AnsiChar(W) of
        '"': W:='''';
        '<': W:=#$AB;
        '>': W:=#$BB;
        '|': W:=#$A6;
      Else
        W:=DefaultChar;
      End;
      Result[I]:=W;
      {$ENDIF}
      {$IFDEF LINUX}
      Result[I]:=DefaultChar;
      {$ENDIF}
    end;
  end; {for}
end;

function CorrectFileName(const Name: String; DefaultChar: AnsiChar): String;
begin
  Result:=CorrectFilePathName(Name, DefaultChar, InvalidFileNameChars);
end;

function CorrectFileNameW(const Name: WideString; DefaultChar: WideChar): WideString;
begin
  Result:=CorrectFilePathNameW(Name, DefaultChar, InvalidFileNameChars);
end;

function CorrectPathName(const Name: String; DefaultChar: AnsiChar): String;
begin
  Result:=CorrectFilePathName(Name, DefaultChar, InvalidFileNameChars - [PathDelim]);
end;

function CorrectPathNameW(const Name: WideString; DefaultChar: WideChar): WideString;
begin
  Result:=CorrectFilePathNameW(Name, DefaultChar, InvalidFileNameChars - [PathDelim]);
end;

function GetStdFileExt(const FileName: String): String;
begin
  Result:=AnsiLowerCase(Copy(ExtractFileExt(FileName), 2, MaxInt));
end;

{$IFDEF V_WIN}

{$ENDIF}

{$IFDEF LINUX}

{$ENDIF} {LINUX}

{$IFDEF V_WIN}
type
  TReadFileSize =
    {$IFDEF V_D3}{$IFNDEF V_D4}Integer{$ELSE}DWORD{$ENDIF}{$ELSE}DWORD{$ENDIF};
{$ENDIF}


function IsRelativePath(const FileName: String): Boolean;
begin
  {$IFDEF V_WIN}
  Result:=(Length(FileName) > 1) and (FileName[2] <> ':');
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=(FileName <> '') and not (FileName[1] in [PathDelim, '~', '$']);
  {$ENDIF}
end;

end.
