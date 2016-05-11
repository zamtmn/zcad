{ Version 050625. Copyright © Alexey A.Chernobaev, 2000-5 }

unit VFileSys;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows,{$ENDIF}
  {$IFDEF LINUX}{$IFDEF V_KYLIX}Libc{$ELSE}Linux{$ENDIF},{$ENDIF}
  SysUtils, ExtType, ExtSys, VectStr, VectErr;

{$IFNDEF V_WIN}{$IFNDEF LINUX}Error!{$ENDIF}{$ENDIF}

const
  InvalidWinFileNameChars = ['"', '*', '?', '/', ':', '<', '>', '\', '|'];
  {$IFDEF V_WIN}
  InvalidFileNameChars = InvalidWinFileNameChars;
  {$ENDIF}
  {$IFDEF LINUX}
  InvalidFileNameChars = ['*', '?', '/'];
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
function FileExistsW(const FileName: WideString;
  pLastOSError: PUInt32{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
{ why use pLastOSError: GetLastError will be altered by WideString cleaning
  code (under Windows) }
{$IFDEF V_WIN}
function FileGetAttrW(const FileName: WideString): DWORD;
function FileSetAttrW(const FileName: WideString; Attr: DWORD): DWORD;
{$ENDIF}

{$IFDEF LINUX}
function ExpandDirectoryName(const Directory: String): String;

function GetHomeDirectory: String;

function UserName(uid: __uid_t): WideString;

function GroupName(gid: __gid_t): WideString;
{$ENDIF}

function ValidateFileName(const FileName: String; MaxLen: Integer): String;

function IsFileNameSyntaxValid(const FileName: WideString): Boolean;

function IsAbsolutePathSyntaxValid(const Path: WideString): Boolean;

function RenameFileW(const OldName, NewName: WideString): Boolean;

function ApiCreateDirectoryW(const PathName: WideString): Boolean;

function ApiDeleteFileW(const FileName: WideString): Boolean;

function GetTempDir: String;

type
  TFileLock = {$IFDEF V_WIN}THandle{$ENDIF}{$IFDEF LINUX}Integer{$ENDIF};

function LockFileWrite(const FileName: String): TFileLock;
function LockFileWriteW(const FileName: WideString): TFileLock;
{ блокирует файл на запись; в случае успеха возвращает дескриптор файла, иначе
  возвращает INVALID_HANDLE_VALUE (Linux: -1) }
{ write-locks the given file; returns a file handle if successful or
  INVALID_HANDLE_VALUE (Linux: -1) if failed }

function UnlockFileWrite(var Handle: TFileLock): Boolean;
{ снимает блокировку с файла, блокированного с помощью LockFileRead/Write[W] и
  устанавливает Handle в INVALID_HANDLE_VALUE }
{ unlocks the file locked with LockFileRead/Write[W] and sets Handle to
  INVALID_HANDLE_VALUE }

function ApiCopyFileW(const FromName, ToName: WideString;
  FailIfExists: Boolean): Boolean;

{$IFDEF V_WIN}
function GetTempDirW: WideString;

function GetWindowsDir: String;
function GetWindowsDirW: WideString;

function GetSystemDir: String;
function GetSystemDirW: WideString;

function LockFileRead(const FileName: String): THandle;
function LockFileReadW(const FileName: WideString): THandle;
{ блокирует файл на чтение; в случае успеха возвращает дескриптор файла, иначе
  возвращает INVALID_HANDLE_VALUE }
{ read-locks the given file; returns a file handle if successful or
  INVALID_HANDLE_VALUE if failed }

function GetLongFileName(const Name: String): String;
  {$IFDEF V_D6}platform;{$ENDIF}
function GetLongFileNameW(const Name: WideString): WideString;
  {$IFDEF V_D6}platform;{$ENDIF}
{ возвращает "длинное" имя, соответствующее заданному "короткому" имени файла
  или директории либо пустую строку, если файл или директория не найдены; в
  функцию можно передавать "длинные" имена }
{ returns the long name corresponding to the specified short file or directory
  name or the empty string if the file or directory were not found; it's legal
  to pass long names to the function }

function WideFileNameToAnsiName(const FileName: WideString): String;
{ возвращает ANSI-имя файла, соответствующее заданному Unicode-имени файла;
  файл должен существовать }
{ returns ANSI file name corresponding to the given Unicode file name; the file
  must exists }

function CheckCreateFileByWideName(const FileName: WideString;
  var AnsiName: String; pCreated: PBoolean{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
{$ENDIF} {V_WIN}

{$IFDEF V_DELPHI}{$IFNDEF V_D6}
function DirectoryExists(const Name: String): Boolean;
{$ENDIF}{$ENDIF}
function DirectoryExistsW(const Name: WideString): Boolean;
{ проверяет, существует ли заданная директория }
{ checks whether the specified directory exists }

{$IFDEF V_DELPHI}{$IFNDEF V_D6}
function ForceDirectories(Dir: String): Boolean;
{$ENDIF}{$ENDIF}
function ForceDirectoriesW(const Dir: WideString;
  pError: PUInt32{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;
{ создает все директории на протяжении заданного пути директорий, если они еще
  не существовали }
{ creates all directories along the specified directory path if they don't exist
  already }

function ForceDeleteFile(const Name: String): Boolean;
function ForceDeleteFileW(const Name: WideString): Boolean;
function ForceDeleteDir(const Name: String): Boolean;
function ForceDeleteDirW(const Name: WideString): Boolean;
function ForceDeleteFileOrDir(const Name: String): Boolean;
function ForceDeleteFileOrDirW(const Name: WideString): Boolean;
{ удаляет файл и/или директорию, несмотря на наличие у них атрибута READONLY }
{ deletes the specified file and/or directory even if it has READONLY attribute }

function ExcludeFileExt(const Name: String): String;
function ExcludeFileExtW(const Name: WideString): WideString;
{ возвращает имя файла без расширения }
{ excludes an extension from the given file name }

function ShortenFileName(const FileName: String; MaxLen: Integer;
  DelimitChars: TCharSet{$IFDEF V_DEFAULTS} = []{$ENDIF}): String;
function ShortenFileNameW(const FileName: WideString; MaxLen: Integer;
  DelimitChars: TCharSet{$IFDEF V_DEFAULTS} = []{$ENDIF}): WideString;

function GetModuleName(Module: HMODULE): String;
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

function GetFileProps(const FileName: String; pSize: PInt64; pModifyTime,
  pCreationTime, pLastAccessTime: PDateTime; pAttributes,
  pLastOSError: PDWORD): Boolean;

function GetFilePropsW(const FileName: WideString; pSize: PInt64;
  pModifyTime: PDateTime; pCreationTime: PDateTime; pLastAccessTime: PDateTime;
  pAttributes, pLastOSError: PDWORD): Boolean;
{$ENDIF} {V_DEFAULTS}

function SetFileDate(const FileName: String; DateTime: TDateTime): Boolean;
function SetFileDateW(const FileName: WideString; DateTime: TDateTime): Boolean;

function ReadFileBlockW(const FileName: WideString; Buf: PChar; Count: Integer;
  Offset: Integer{$IFDEF V_DEFAULTS} = 0{$ENDIF}): Boolean;
function SafeReadFileBlockW(const FileName: WideString; Buf: PChar;
  Count: Integer; Offset: Integer{$IFDEF V_DEFAULTS} = 0{$ENDIF}): Boolean;

function CheckFileSignW(const FileName: WideString; const Sign: String;
  Offset: Integer{$IFDEF V_DEFAULTS} = 0{$ENDIF}): Boolean;
function SafeCheckFileSignW(const FileName: WideString; const Sign: String;
  Offset: Integer{$IFDEF V_DEFAULTS} = 0{$ENDIF}): Boolean;

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

function FileExistsW(const FileName: WideString; pLastOSError: PUInt32): Boolean;
{$IFDEF V_WIN}
var
  Code: DWORD;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Code:=GetFileAttributesW(PWideChar(UNCPath(FileName)))
  else
    Code:=GetFileAttributes(PChar(String(FileName)));
  Result:=Code and FILE_ATTRIBUTE_DIRECTORY = 0;
  if pLastOSError <> nil then
    pLastOSError^:=GetLastError;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  st: TStatBuf64;
begin
  if __xstat64(_STAT_VER, PChar(String(FileName)), st) = 0 then
    Result:=S_ISREG(st.st_mode)
  else
    Result:=False;
  if pLastOSError <> nil then
    pLastOSError^:=GetLastError;
end;
{$ENDIF}

{$IFDEF V_WIN}
function FileGetAttrW(const FileName: WideString): DWORD;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=GetFileAttributesW(PWideChar(UNCPath(FileName)))
  else
    Result:=GetFileAttributes(PChar(String(FileName)));
end;

function FileSetAttrW(const FileName: WideString; Attr: DWORD): DWORD;
var
  Success: Boolean;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Success:=SetFileAttributesW(PWideChar(UNCPath(FileName)), Attr)
  else
    Success:=SetFileAttributes(PChar(String(FileName)), Attr);
  Result:=0;
  if not Success then
    Result:=GetLastError;
end;
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
function ExpandDirectoryName(const Directory: String): String;
var
  I: Integer;
  PP: PPChar;
  wet: wordexp_t;
begin
  if wordexp(PChar(Directory), wet, WRDE_NOCMD) = 0 then
  try
    PP:=wet.we_wordv;
    Result:='';
    for I:=0 to wet.we_wordc - 1 do begin
      if I > 0 then
        Result:=Result + ' ';
      Result:=Result + LString(PP^, MAX_PATH);
      Inc(PP);
    end; {for}
  finally
    wordfree(wet);
  end
  else
    Result:=Directory;
  if Result <> PathDelim then
    Result:=ExpandFileName(Result);
  if Result = '' then
    Result:='/';
end;

function GetHomeDirectory: String;
begin
  Result:=IncludeTrailingPathDelimiter(ExpandDirectoryName('$HOME'));
end;

function UserName(uid: __uid_t): WideString;
var
  PwdRec: PPasswordRecord;
begin
  Result:='?';
  PwdRec:=getpwuid(uid);
  if Assigned(PwdRec) then
    Result:=PwdRec^.pw_name;
end;

function GroupName(gid: __gid_t): WideString;
var
  Group: PGroup;
begin
  Result:='?';
  Group:=getgrgid(gid);
  if Assigned(Group) then
    Result:= Group.gr_name;
end;
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

function RenameFileW(const OldName, NewName: WideString): Boolean;
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=MoveFileW(PWideChar(UNCPath(OldName)), PWideChar(UNCPath(NewName)))
  else
  {$ENDIF}
    Result:=RenameFile(OldName, NewName);
end;

function ApiCreateDirectoryW(const PathName: WideString): Boolean;
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=CreateDirectoryW(PWideChar(UNCPath(PathName)), nil)
  else
    Result:=CreateDirectory(PChar(String(PathName)), nil);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=__mkdir(PChar(String(PathName)), mode_t(-1)) = 0;
  {$ENDIF}
end;

function ApiDeleteFileW(const FileName: WideString): Boolean;
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=DeleteFileW(PWideChar(UNCPath(FileName)))
  else
    Result:=DeleteFile(PChar(String(FileName)));
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=unlink(PChar(String(FileName))) <> -1;
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
  Result:=GetEnv('TMPDIR');
  if Result = '' then
    Result:='/tmp/'
  else
    if Result[Length(Result)] <> '/' then
      Result:=Result + '/';
  {$ENDIF}
end;

function LockFileWrite(const FileName: String): TFileLock;
{$IFDEF LINUX}
var
  Flock: TFlock;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  Result:=CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_FLAG_NO_BUFFERING, 0);
  {$ENDIF}
  {$IFDEF LINUX}{$WARN SYMBOL_PLATFORM OFF}
  Result:=THandle(open64(PChar(FileName), O_RDONLY, FileAccessRights));
  if Result = TFileLock(-1) then
    Exit;
  With Flock do begin
    l_whence:=SEEK_SET;
    l_start:=0;
    l_len:=0;
    l_type:=F_RDLCK or F_UNLCK;
  end;
  if fcntl(Result, F_SETLK, Flock) = -1 then begin
    __close(Result);
    Result:=TFileLock(-1);
  end;
  {$WARN SYMBOL_PLATFORM ON}{$ENDIF}
end;

function LockFileWriteW(const FileName: WideString): TFileLock;
{$IFDEF V_WIN}
var
  L: Integer;
  P1, P2: PWideChar;
  BufW: array [0..2047] of WideChar;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    // don't call UNCPath to prevent clearing last error code by SysFreeString
    L:=Length(FileName);
    P1:=@BufW;
    P2:=Pointer(FileName);
    if (L >= MAX_PATH) and (FileName[1] <> '.') and (L < SizeOf(BufW) - 7) then begin
      BufW[0]:='\';
      BufW[1]:='\';
      BufW[2]:='?';
      BufW[3]:='\';
      Inc(P1, 4);
      if (FileName[1] = '\') and (FileName[2] = '\') then begin
        BufW[4]:='U';
        BufW[5]:='N';
        BufW[6]:='C';
        Inc(P1, 3);
        Inc(P2);
        Dec(L);
      end;
    end;
    Move(P2^, P1^, L * 2);
    P1[L]:=#0;
    Result:=CreateFileW(BufW, GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING,
      FILE_FLAG_NO_BUFFERING, 0);
  end
  else
    Result:=LockFileWrite(FileName);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=LockFileWrite(FileName);
  {$ENDIF}
end;

function UnlockFileWrite(var Handle: TFileLock): Boolean;
begin
  {$IFDEF V_WIN}
  Result:=(Handle <> INVALID_HANDLE_VALUE) and CloseHandle(THandle(Handle));
  Handle:=INVALID_HANDLE_VALUE;
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=(Handle <> -1) and (__close(Handle) = 0);
  Handle:=-1;
  {$ENDIF}
end;

function ApiCopyFileW(const FromName, ToName: WideString;
  FailIfExists: Boolean): Boolean;
{$IFDEF LINUX}
var
  ToHandle, BytesRead, FromHandle: Integer;
  Buf: array [0..32 * KILOBYTE - 1] of Byte;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=CopyFileW(PWideChar(UNCPath(FromName)), PWideChar(UNCPath(ToName)),
      FailIfExists)
  else
    Result:=CopyFile(PChar(String(FromName)), PChar(String(ToName)),
      FailIfExists);
  {$ENDIF}
  {$IFDEF LINUX}
  Result:=False;
  if FailIfExists and FileExists(ToName) then
    Exit;
  FromHandle:=FileOpen(FromName, fmOpenRead + fmShareDenyWrite);
  if FromHandle < 0 then
    Exit;
  ToHandle:=FileCreate(ToName);
  if ToHandle < 0 then begin
    FileClose(FromHandle);
    Exit;
  end;
  try
    repeat
      BytesRead:=FileRead(FromHandle, Buf, SizeOf(Buf));
      if BytesRead < 0 then
        Exit;
      if FileWrite(ToHandle, Buf, BytesRead) <> BytesRead then
        Exit;
    until BytesRead < SizeOf(Buf);
  finally
    FileClose(FromHandle);
    FileClose(ToHandle);
  end;
  Result:=True;
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

function LockFileReadW(const FileName: WideString): THandle;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result:=CreateFileW(PWideChar(UNCPath(FileName)), GENERIC_READ, 0, nil,
      OPEN_EXISTING, FILE_FLAG_NO_BUFFERING, 0)
  else
    Result:=LockFileWrite(FileName);
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

function GetLongFileNameW(const Name: WideString): WideString;

  function ProcessExpanded(const ExpName: WideString): WideString;
  var
    I: Integer;
    Name, Path: WideString;
    hFind: THandle;
    FindData: TWin32FindDataW;
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
      ParseFileNameW(Result, Path, Name);
      if (WideCharPos('*', Name, 1) = 0) and (WideCharPos('?', Name, 1) = 0) then begin
        hFind:=Windows.FindFirstFileW(PWideChar(Result),
          {$IFDEF V_FREEPASCAL}@{$ENDIF}FindData);
        if hFind = INVALID_HANDLE_VALUE then
          Exit;
        Windows.FindClose(hFind);
        if (FindData.cFileName[0] = '.') and (FindData.cFileName[1] = #0) then
          Exit;
        Name:=LWideString(@FindData.cFileName, SizeOf(FindData.cFileName) div 2);
      end;
      if Length(Path) < I then begin
        if WideCharPos('~', Result, 1) > 0 then begin
          Path:=ProcessExpanded(Path);
          I:=Length(Path);
          if (I > 0) and (Path[I] <> '\') then
            Path:=Path + '\';
        end;
        Result:=Path + Name;
      end;
    end;
  end;

var
  UNC: Boolean;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Result:=Name;
    if Result <> '' then begin
      if Result[Length(Result)] = ':' then
        Result:=Result + '\';
      Result:=ExpandFileNameW(Result);
      if WideCharPos('~', Result, 1) > 0 then begin
        UNC:=False;
        if Length(Result) >= MAX_PATH then begin
          Result:=UNCPath(Result);
          UNC:=True;
        end;
        Result:=ProcessExpanded(Result);
        if UNC and (Copy(Result, 1, 4) = '\\?\') then
          Delete(Result, 1, 4);
      end;
    end;
  end
  else
    Result:=GetLongFileName(Name);
end;

function WideFileNameToAnsiName(const FileName: WideString): String;
var
  L, N: Integer;
  ShortPath: PWideChar;
begin
  Result:=FileName;
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    L:=Length(FileName);
    if (L >= MAX_PATH) or (Result <> FileName) then begin
      Inc(L);
      GetMem(ShortPath, L * 2);
      try
        N:=GetShortPathNameW(PWideChar(UNCPath(FileName)), ShortPath, L);
        if (N > 0) and (N < L) then begin
          ShortPath[N]:=#0;
          Result:=String(WideString(ShortPath));
          if StrLComp(PChar(Result), '\\?\', 4) = 0 then
            Delete(Result, 1, 4);
        end;
      finally
        FreeMem(ShortPath);
      end;
    end;
  end;
end;

function CheckCreateFileByWideName(const FileName: WideString;
  var AnsiName: String; pCreated: PBoolean{$IFDEF V_DEFAULTS} = nil{$ENDIF}): Boolean;

  function WideCreateFile: Boolean;
  var
    hFile: THandle;
  begin
    hFile:=CreateFileW(PWideChar(UNCPath(FileName)), GENERIC_WRITE, 0, nil,
      CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_NO_BUFFERING, 0);
    if hFile = INVALID_HANDLE_VALUE then begin
      Result:=False;
      Exit;
    end;
    CloseHandle(hFile);
    if pCreated <> nil then
      pCreated^:=True;
    Result:=True;
  end;

var
  L, N: Integer;
  hFile: THandle;
  ShortPath: PWideChar;
begin
  Result:=False;
  AnsiName:=FileName;
  if pCreated <> nil then
    pCreated^:=False;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    if AnsiName <> FileName then begin
      L:=Length(FileName) + 1;
      GetMem(ShortPath, L * 2);
      try
        N:=GetShortPathNameW(PWideChar(FileName), ShortPath, L);
        if N = 0 then
          if WideCreateFile then
            N:=GetShortPathNameW(PWideChar(FileName), ShortPath, L)
          else
            Exit;
        if (N > 0) and (N < L) then begin
          ShortPath[N]:=#0;
          AnsiName:=String(WideString(ShortPath));
          Result:=True;
        end;
      finally
        FreeMem(ShortPath);
      end;
    end
    else
      Result:=WideCreateFile
  else
    if FileExists(AnsiName) then
      Result:=True
    else begin
      hFile:=CreateFile(PAnsiChar(Result), GENERIC_WRITE, 0, nil, CREATE_ALWAYS,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_NO_BUFFERING, 0);
      if hFile = INVALID_HANDLE_VALUE then
        Exit;
      CloseHandle(hFile);
      if pCreated <> nil then
        pCreated^:=True;
      Result:=True;
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

function DirectoryExistsW(const Name: WideString): Boolean;
{$IFDEF V_WIN}
var
  Code: DWORD;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Code:=GetFileAttributesW(PWideChar(UNCPath(Name)));
    Result:=(Code <> DWORD(-1)) and (Code and FILE_ATTRIBUTE_DIRECTORY <> 0);
  end
  else
    Result:=DirectoryExists(Name);
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result:=DirectoryExists(Name);
end;
{$ENDIF}

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

function ForceDirectoriesW(const Dir: WideString; pError: PUInt32): Boolean;

  {$IFDEF V_WIN}
  function DoForce(W: WideString): Boolean;
  var
    L: Integer;
    Path: WideString;
  begin
    L:=Length(W);
    if W[L] = '\' then begin
      Dec(L);
      SetLength(W, L);
    end;
    Path:=ExtractFilePathW(W);
    if (L < 3) or (L = Length(Path)) or DirectoryExistsW(W) then begin
      Result:=True;
      Exit; // avoid 'xyz:\' problem.
    end;
    Result:=DoForce(Path);
    if Result then begin
      Result:=CreateDirectoryW(Pointer(W), nil);
      if not Result and (pError <> nil) then
        pError^:=GetLastError;
    end;
  end;
  {$ENDIF}

begin
  if pError <> nil then
    pError^:=0;
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    if Dir = '' then
      raise Exception.CreateFmt(SDirCreateError_s, ['']);
    Result:=DoForce(UNCPath(Dir));
  end
  else
  {$ENDIF}
  begin
    Result:=ForceDirectories(Dir);
    if pError <> nil then
      pError^:=UInt32(GetLastError);
  end;
end;

function ForceDeleteFile(const Name: String): Boolean;
{$IFDEF V_WIN}
var
  Attr: DWORD;
  P: PChar;
begin
  Result:=False;
  if Name = '' then
    Exit;
  P:=@Name[1];
  Attr:=GetFileAttributes(P);
  if (Attr <> DWORD(-1)) and (Attr and FILE_ATTRIBUTE_DIRECTORY = 0) then begin
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      SetFileAttributes(P, Attr and not FILE_ATTRIBUTE_READONLY);
    Result:=Windows.DeleteFile(P);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  st: TStatBuf;
begin
  Result:=DeleteFile(Name);
  if Result then
    Exit;
  if (stat(PChar(Name), st) <> 0) or S_ISDIR(st.st_mode) then
    Exit;
  Result:=(chmod(PChar(Name), st.st_mode or (S_IWUSR or S_IWGRP or S_IWOTH)) = 0) and
    DeleteFile(Name);
end;
{$ENDIF}

function ForceDeleteFileW(const Name: WideString): Boolean;
{$IFDEF V_WIN}
var
  L: Integer;
  Attr: DWORD;
  P: PWideChar;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Result:=False;
    L:=Length(Name);
    if L < MAX_PATH then begin
      if L = 0 then
        Exit;
      P:=Pointer(Name);
    end
    else
      P:=Pointer(UNCPath(Name));
    Attr:=GetFileAttributesW(P);
    if (Attr <> DWORD(-1)) and (Attr and FILE_ATTRIBUTE_DIRECTORY = 0) then begin
      if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
        SetFileAttributesW(P, Attr and not FILE_ATTRIBUTE_READONLY);
      Result:=DeleteFileW(P);
    end;
  end
  else
  {$ENDIF}
    Result:=ForceDeleteFile(Name);
end;

function ForceDeleteDir(const Name: String): Boolean;
{$IFDEF V_WIN}
var
  Attr: DWORD;
  P: PChar;
begin
  Result:=False;
  P:=PChar(Name);
  Attr:=GetFileAttributes(P);
  if (Attr <> DWORD($FFFFFFFF)) and (Attr and FILE_ATTRIBUTE_DIRECTORY <> 0) then begin
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      SetFileAttributes(P, Attr and not FILE_ATTRIBUTE_READONLY);
    Result:=RemoveDirectory(P);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  st: TStatBuf;
begin
  Result:=RemoveDir(Name);
  if Result then
    Exit;
  if (stat(PChar(Name), st) <> 0) or not S_ISDIR(st.st_mode) then
    Exit;
  Result:=(chmod(PChar(Name), st.st_mode or (S_IWUSR or S_IWGRP or S_IWOTH)) = 0) and
    RemoveDir(Name);
end;
{$ENDIF}

function ForceDeleteDirW(const Name: WideString): Boolean;
{$IFDEF V_WIN}
var
  L: Integer;
  Attr: DWORD;
  P: PWideChar;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Result:=False;
    L:=Length(Name);
    if L < MAX_PATH then begin
      if L = 0 then
        Exit;
      P:=Pointer(Name);
    end
    else
      P:=Pointer(UNCPath(Name));
    Attr:=GetFileAttributesW(P);
    if (Attr <> DWORD($FFFFFFFF)) and (Attr and FILE_ATTRIBUTE_DIRECTORY <> 0) then begin
      if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
        SetFileAttributesW(P, Attr and not FILE_ATTRIBUTE_READONLY);
      Result:=RemoveDirectoryW(P);
    end;
  end
  else
  {$ENDIF}
    Result:=ForceDeleteDir(Name);
end;

function ForceDeleteFileOrDir(const Name: String): Boolean;
{$IFDEF V_WIN}
var
  Attr: DWORD;
  P: PChar;
begin
  Result:=False;
  P:=PChar(Name);
  Attr:=GetFileAttributes(P);
  if Attr <> DWORD($FFFFFFFF) then begin
    if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
      SetFileAttributes(P, Attr and not FILE_ATTRIBUTE_READONLY);
    if Attr and FILE_ATTRIBUTE_DIRECTORY = 0 then
      Result:=Windows.DeleteFile(P)
    else
      Result:=RemoveDirectory(P);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result:=ForceDeleteFile(Name) or ForceDeleteDir(Name);
end;
{$ENDIF}

function ForceDeleteFileOrDirW(const Name: WideString): Boolean;
{$IFDEF V_WIN}
var
  L: Integer;
  Attr: DWORD;
  P: PWideChar;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Result:=False;
    L:=Length(Name);
    if L < MAX_PATH then begin
      if L = 0 then
        Exit;
      P:=Pointer(Name);
    end
    else
      P:=Pointer(UNCPath(Name));
    Attr:=GetFileAttributesW(P);
    if Attr <> DWORD($FFFFFFFF) then begin
      if Attr and FILE_ATTRIBUTE_READONLY <> 0 then
        SetFileAttributesW(P, Attr and not FILE_ATTRIBUTE_READONLY);
      if Attr and FILE_ATTRIBUTE_DIRECTORY = 0 then
        Result:=DeleteFileW(P)
      else
        Result:=RemoveDirectoryW(P);
    end;
  end
  else
  {$ENDIF}
    Result:=ForceDeleteFileOrDir(Name);
end;

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

function GetModuleName(Module: HMODULE): String; // from SysUtils implementation
var
  Buf: TFileBuf;
begin
  SetString(Result, Buf, GetModuleFileName(Module, Buf, SizeOf(Buf)));
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
function GetFileProps(const FileName: String; pSize: PInt64; pModifyTime,
  pCreationTime, pLastAccessTime: PDateTime; pAttributes,
  pLastOSError: PDWORD): Boolean;
var
  HSearch: THandle;
  FindData: TWin32FindData;
begin
  Result:=False;
  if pSize <> nil then
    pSize^:=-1;
  HSearch:=Windows.FindFirstFile(PChar(FileName), FindData);
  if HSearch <> INVALID_HANDLE_VALUE then begin
    Windows.FindClose(HSearch);
    if pAttributes <> nil then
      pAttributes^:=FindData.dwFileAttributes;
    if pCreationTime <> nil then
      pCreationTime^:=FileTimeToLocalDateTime(FindData.ftCreationTime);
    if pLastAccessTime <> nil then
      pLastAccessTime^:=FileTimeToLocalDateTime(FindData.ftLastAccessTime);
    if pModifyTime <> nil then
      pModifyTime^:=FileTimeToLocalDateTime(FindData.ftLastWriteTime);
    if pSize <> nil then begin
      PDWORD(pSize)^:=FindData.nFileSizeLow;
      PDWORD(PChar(pSize) + 4)^:=FindData.nFileSizeHigh;
    end;
    Result:=True;
  end
  else
    if pLastOSError <> nil then
      pLastOSError^:=GetLastError;
end;

function GetFilePropsW(const FileName: WideString; pSize: PInt64;
  pModifyTime, pCreationTime, pLastAccessTime: PDateTime; pAttributes,
  pLastOSError: PDWORD): Boolean;
var
  HSearch: THandle;
  FindData: TWin32FindDataW;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Result:=False;
    if pSize <> nil then
      pSize^:=-1;
    HSearch:=Windows.FindFirstFileW(PWideChar(UNCPath(FileName)),
      {$IFDEF V_FREEPASCAL}@{$ENDIF}FindData);
    if HSearch <> INVALID_HANDLE_VALUE then begin
      Windows.FindClose(HSearch);
      if pAttributes <> nil then
        pAttributes^:=FindData.dwFileAttributes;
      if pCreationTime <> nil then
        pCreationTime^:=FileTimeToLocalDateTime(FindData.ftCreationTime);
      if pLastAccessTime <> nil then
        pLastAccessTime^:=FileTimeToLocalDateTime(FindData.ftLastAccessTime);
      if pModifyTime <> nil then
        pModifyTime^:=FileTimeToLocalDateTime(FindData.ftLastWriteTime);
      if pSize <> nil then begin
        PDWORD(pSize)^:=FindData.nFileSizeLow;
        PDWORD(PChar(pSize) + 4)^:=FindData.nFileSizeHigh;
      end;
      Result:=True;
    end
    else
      if pLastOSError <> nil then
        pLastOSError^:=GetLastError;
  end
  else
    Result:=GetFileProps(FileName, pSize, pModifyTime, pCreationTime,
      pLastAccessTime, pAttributes, pLastOSError);
end;
{$ENDIF}

{$IFDEF LINUX}
function GetFileProps(const FileName: String; pSize: PInt64; pModifyTime,
  pLastStatusChangeTime, pLastAccessTime: PDateTime; pAttributes, pUser,
  pGroup: PUInt32): Boolean;
var
  st: TStatBuf64;
begin
  Result:=False;
  if __lxstat64(_STAT_VER, PChar(FileName), st) <> 0 then
    Exit;
  if pSize <> nil then
    pSize^:=st.st_size;
  if pModifyTime <> nil then
    pModifyTime^:=FileDateToDateTime(st.st_mtime);
  if pLastStatusChangeTime <> nil then
    pLastStatusChangeTime^:=FileDateToDateTime(st.st_ctime);
  if pLastAccessTime <> nil then
    pLastAccessTime^:=FileDateToDateTime(st.st_atime);
  if pAttributes <> nil then
    pAttributes^:=st.st_mode;
  if pUser <> nil then
    pUser^:=st.st_uid;
  if pGroup <> nil then
    pGroup^:=st.st_gid;
  Result:= True;
end;

function GetFilePropsW(const FileName: WideString; pSize: PInt64;
  pModifyTime, pLastStatusChangeTime, pLastAccessTime: PDateTime;
  pAttributes, pUser, pGroup: PUInt32): Boolean;
begin
  Result:=GetFileProps(FileName, pSize, pModifyTime, pLastStatusChangeTime,
    pLastAccessTime, pAttributes, pUser, pGroup);
end;

function GetLinkTarget(const PathOnly: String): String;
var
  BufSize: UInt32;
  Buf: array [0.._POSIX_PATH_MAX - 1] of Char;
begin
  BufSize:=readlink(PChar(PathOnly), Buf, SizeOf(Buf));
  if BufSize > 0 then begin
    SetString(Result, Buf, BufSize);
    if IsRelativePath(Result) then
      Result:=GetItemPathW(PathOnly) + '/' + Result;
    Result:=ExpandFileName(Result);
  end
  else
    Result:='';
end;
{$ENDIF} {LINUX}

function SetFileDate(const FileName: String; DateTime: TDateTime): Boolean;
{$IFDEF V_WIN}
var
  hFile: THandle;
  LastWrite: TFileTime;
begin
  Result:=False;
  hFile:=CreateFile(PChar(FileName), GENERIC_WRITE, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_NO_BUFFERING, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  try
    LastWrite:=LocalDateTimeToFileTime(DateTime);
    Result:=SetFileTime(hFile, nil, nil, @LastWrite);
  finally
    CloseHandle(hFile);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result:=FileSetDate(FileName, DateTimeToFileDate(DateTime)) = 0;
end;
{$ENDIF}

function SetFileDateW(const FileName: WideString; DateTime: TDateTime): Boolean;
{$IFDEF V_WIN}
var
  hFile: THandle;
  LastWrite: TFileTime;
{$ENDIF}
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    Result:=False;
    hFile:=CreateFileW(PWideChar(UNCPath(FileName)), GENERIC_WRITE,
      FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if hFile <> INVALID_HANDLE_VALUE then
    try
      LastWrite:=LocalDateTimeToFileTime(DateTime);
      Result:=SetFileTime(hFile, nil, nil, @LastWrite);
    finally
      CloseHandle(hFile);
    end;
  end
  else
  {$ENDIF}
    Result:=SetFileDate(FileName, DateTime);
end;

{$IFDEF V_WIN}
type
  TReadFileSize =
    {$IFDEF V_D3}{$IFNDEF V_D4}Integer{$ELSE}DWORD{$ENDIF}{$ELSE}DWORD{$ENDIF};
{$ENDIF}

function SafeReadFileBlockW(const FileName: WideString; Buf: PChar;
  Count: Integer; Offset: Integer): Boolean;
{$IFDEF V_WIN}
var
  Size: TReadFileSize;
  hFile: THandle;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    hFile:=CreateFileW(PWideChar(UNCPath(FileName)), GENERIC_READ,
      FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
  else
    hFile:=CreateFile(PChar(String(FileName)), GENERIC_READ, FILE_SHARE_READ, nil,
      OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then begin
    Result:=False;
    Exit;
  end;
  try
    Result:=((Offset = 0) or (FileSeek(hFile, Offset, 0) = Offset)) and
      ReadFile(hFile, Buf^, Count, Size, nil) and (Integer(Size) = Count);
  finally
    CloseHandle(hFile);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  Handle: Integer;
begin
  Handle:=FileOpen(PChar(String(FileName)), fmOpenRead + fmShareDenyNone);
  if Handle < 0 then begin
    Result:=False;
    Exit;
  end;
  try
    Result:=((Offset = 0) or (FileSeek(Handle, Offset, 0) = Offset)) and
      (FileRead(Handle, Buf^, Count) = Count);
  finally
    FileClose(Handle);
  end;
end;
{$ENDIF}

function ReadFileBlockW(const FileName: WideString; Buf: PChar;
  Count: Integer; Offset: Integer): Boolean;
{$IFDEF V_WIN}
var
  Size: TReadFileSize;
  hFile: THandle;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    hFile:=CreateFileW(PWideChar(UNCPath(FileName)), GENERIC_READ,
      FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
  else
    hFile:=CreateFile(PChar(String(FileName)), GENERIC_READ, FILE_SHARE_READ,
      nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  OSCheck(hFile <> INVALID_HANDLE_VALUE);
  try
    if Offset <> 0 then
      OSCheck(FileSeek(hFile, Offset, 0) = Offset);
    OSCheck(ReadFile(hFile, Buf^, Count, Size, nil));
    Result:=Integer(Size) = Count;
  finally
    CloseHandle(hFile);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  Handle: Integer;
begin
  Handle:=FileOpen(PChar(String(FileName)), fmOpenRead + fmShareDenyNone);
  OSCheck(Handle >= 0);
  try
    if Offset <> 0 then
      OSCheck(FileSeek(Handle, Offset, 0) = Offset);
    Result:=FileRead(Handle, Buf^, Count) = Count;
  finally
    FileClose(Handle);
  end;
end;
{$ENDIF}

function CheckFileSignW(const FileName: WideString; const Sign: String;
  Offset: Integer): Boolean;
var
  Count: Integer;
  Buf: PChar;
begin
  Count:=Length(Sign);
  GetMem(Buf, Count);
  try
    Result:=ReadFileBlockW(FileName, Buf, Count, Offset) and
      (StrLComp(Buf, @Sign[1], Count) = 0);
  finally
    FreeMem(Buf);
  end;
end;

function SafeCheckFileSignW(const FileName: WideString; const Sign: String;
  Offset: Integer): Boolean;
var
  Count: Integer;
  Buf: PChar;
begin
  Count:=Length(Sign);
  GetMem(Buf, Count);
  try
    Result:=SafeReadFileBlockW(FileName, Buf, Count, Offset) and
      (StrLComp(Buf, @Sign[1], Count) = 0);
  finally
    FreeMem(Buf);
  end;
end;

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
