{ Version 050519. Copyright © Alexey A.Chernobaev, 2003-5 }

unit VFileLst;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows,{$ENDIF}
  SysUtils, ExtType, ExtSys, StrLst, VectStr, VFileSys;

procedure ForceDeleteFiles(List: TStrLst);
procedure ForceDeleteFilesOrDirs(List: TStrLst);
{ применяет ForceDeleteFile... ко всем элементам List }
{ applies ForceDelete... to all elements of List }

procedure ForceDeleteDirs(List: TStrLst; SubDirs: Boolean);
{ удаляет директории из списка List; при SubDirs = True рекурсивно удаляет
  также все их поддиректории }
{ deletes all directories from List; if SubDirs = True then recursively deletes
  all their subdirectories }

function GetFileList(List: TStrLst; Path, Mask: String;
  SubDirs: Boolean{$IFDEF V_D4} = False{$ENDIF}
  {$IFDEF V_WIN}; FileExcludeAttrs: UInt16 = 0{$ENDIF}): Integer;
{ сканирует директорию Path (а также все поддиректории Path при SubDirs = True)
  и записывает в List полные имена всех файлов, соответствующих маске Mask
  (маска по умолчанию - '*'); если FileExcludeAttrs <> 0, то файлы, у которых
  установлен хотя бы один из атрибутов FileExcludeAttrs, не включаются в список
  результатов; возвращает количество найденных файлов }
{ scans the directory Path (and all it's subdirectories if SubDirs = True) and
  writes full names of files matching Mask (the default mask is '*') to List;
  if FileExcludeAttrs <> 0 then files which have at least one attribute from
  FileExcludeAttrs set will not be included into the result list; returns the
  number of the files found }

function GetFileListEx(List: TStrLst; Path, Mask: String;
  SubDirs: Boolean{$IFDEF V_D4} = False{$ENDIF}): Boolean;
{ если Path является именем директории, то работает так же, как GetFileList,
  иначе вызывает GetFileList(List, ExtractFilePath(Path), ExtractFileName(Path),
  SubDirs); возвращает True, если существует либо директория Path, либо
  ExtractFilePath(Path), и False - иначе }
{ if Path is a directory name then works in the same way as GetFileList else
  calls GetFileList(List, ExtractFilePath(Path), ExtractFileName(Path), SubDirs);
  returns True if either Path or ExtractFilePath(Path) directory exist and
  False otherwise }

function GetDirList(List: TStrLst; const Path: String;
  Mask: String{$IFDEF V_D4} = ''{$ENDIF}
  {$IFDEF V_WIN}; DirExcludeAttrs: UInt16 = 0{$ENDIF}): Integer;
{ сканирует директорию Path и записывает в List список поддиректорий Path (без
  полных путей), соответствующих маске Mask; если Mask = '', то принимаются все
  поддиректории; возвращает количество найденных поддиректорий }
{ scans the directory Path and writes names of subdirectories of Path matching
  Mask to the List (without full paths); if Mask = '' then all subdirectories
  are accepted; returns the number of the subdirectories found }

{$IFDEF LINUX}
function GetAnyCaseFileName(const FileName: String): String;
{$ENDIF}

implementation

{$IFDEF V_D6}{$IFDEF V_WIN}{$IFDEF NOWARN}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}{$ENDIF}{$ENDIF}

procedure ForceDeleteFiles(List: TStrLst);
var
  I: Integer;
begin
  for I:=0 to List.Count - 1 do
    ForceDeleteFile(List[I]);
end;

procedure ForceDeleteFilesOrDirs(List: TStrLst);
var
  I: Integer;
begin
  for I:=0 to List.Count - 1 do
    ForceDeleteFileOrDir(List[I]);
end;

procedure ForceDeleteDirs(List: TStrLst; SubDirs: Boolean);

  procedure DeleteDir(Path: String);
  var
    I: Integer;
    Dirs: TStrLst;
  begin
    if SubDirs then begin
      Path:=IncludeTrailingPathDelimiter(Path);
      Dirs:=TStrLst.Create;
      try
        GetDirList(Dirs, Path, '');
        for I:=0 to Dirs.Count - 1 do
          DeleteDir(Path + Dirs[I]);
      finally
        Dirs.Free;
      end;
    end;
    ForceDeleteDir(Path);
  end;

var
  I: Integer;
begin
  List.SortDesc;
  for I:=0 to List.Count - 1 do
    DeleteDir(List[I]);
end;

function GetExtLen(const Mask: String): Integer;
begin
  Result:=LastPos('.', Mask);
  if (Result > 0) and (CharPos('*', Mask, Result) = 0) then
    Result:=Length(Mask) - Result
  else
    Result:=-1;
end;

function GetFileList(List: TStrLst; Path, Mask: String; SubDirs: Boolean
  {$IFDEF V_WIN}; FileExcludeAttrs: UInt16{$ENDIF}): Integer;
{$IFDEF V_WIN}
var
  MaskExtLen: Integer;
{$ENDIF}

  procedure AddToList(const CurPath: String);
  var
    I: Integer;
    {$IFDEF V_WIN}
    hFind: THandle;
    S: String;
    FindData: TWin32FindData;
    {$ENDIF}
    {$IFDEF LINUX}
    SR: TSearchRec;
    {$ENDIF}
    SubDirList: TStrLst;
  begin
    {$IFDEF V_WIN}
    hFind:=FindFirstFile(PChar(CurPath + Mask), FindData);
    if hFind <> INVALID_HANDLE_VALUE then
    try
      repeat
        // бывает: при Mask = '*.txt' получаем '*.txt1' => проверяем по MaskExtLen
        // sometimes we get '*.txt1' when Mask = '*.txt' => check by MaskExtLen
        if FindData.dwFileAttributes and FileExcludeAttrs = 0 then begin
          S:=LString(@FindData.cFileName, SizeOf(FindData.cFileName));
          if (MaskExtLen < 0) or (MaskExtLen = Length(S) - LastPos('.', S)) then
            List.Add(CurPath + S);
        end;
      until not FindNextFile(hFind, FindData);
    finally
      Windows.FindClose(hFind);
    end;
    {$ENDIF}
    {$IFDEF LINUX}
    if FindFirst(CurPath + Mask,
      faAnyFile and not (faDirectory{$IFDEF V_WIN} or faVolumeID{$ENDIF}), SR) = 0 then
    try
      repeat
        {$IFDEF V_WIN}
        if MaskExtLen >= 0 then begin
          I:=LastPos('.', SR.Name);
          if I > 0 then
            I:=Length(SR.Name) - I;
          if MaskExtLen <> I then
            Continue;
        end;
        {$ENDIF}
        List.Add(CurPath + SR.Name);
      until FindNext(SR) <> 0;
    finally
      SysUtils.FindClose(SR);
    end;
    {$ENDIF}
    if SubDirs then begin
      SubDirList:=TStrLst.Create;
      try
        GetDirList(SubDirList, CurPath, '*');
        for I:=0 to SubDirList.Count - 1 do
          AddToList(CurPath + SubDirList.Items[I] + PathDelim);
      finally
        SubDirList.Free;
      end;
    end;
  end;

begin
  List.Clear;
  if Path <> '' then begin
    {$IFDEF V_WIN}
    FileExcludeAttrs:=FileExcludeAttrs or FILE_ATTRIBUTE_DIRECTORY;
    MaskExtLen:=GetExtLen(Mask);
    {$ENDIF}
    if Mask = '' then
      Mask:='*';
    AddToList(IncludeTrailingPathDelimiter(Path));
  end;
  Result:=List.Count;
end;

function GetFileListEx(List: TStrLst; Path, Mask: String; SubDirs: Boolean): Boolean;
var
  L: Integer;
begin
  if not DirectoryExists(Path) then begin
    Result:=False;
    Mask:=ExtractFileName(Path);
    L:=Length(Path) - Length(Mask) - 1;
    if L <= 0 then
      Exit;
    SetLength(Path, L);
    if not DirectoryExists(Path) then
      Exit;
  end;
  GetFileList(List, Path, Mask, SubDirs);
  Result:=True;
end;

{$IFDEF V_WIN}
function GetDirList(List: TStrLst; const Path: String; Mask: String
  {$IFDEF V_WIN}; DirExcludeAttrs: UInt16{$ENDIF}): Integer;
var
  MaskExtLen: Integer;
  S: String;
  hFind: THandle;
  FindData: TWin32FindData;
begin
  if Path = '' then begin
    Result:=0;
    Exit;
  end;
  List.Clear;
  MaskExtLen:=GetExtLen(Mask);
  if Mask = '' then
    Mask:='*';
  hFind:=FindFirstFile(PChar(IncludeTrailingPathDelimiter(Path) + Mask), FindData);
  if hFind <> INVALID_HANDLE_VALUE then
  try
    repeat
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
        (FindData.dwFileAttributes and DirExcludeAttrs = 0) then
      begin
        S:=LString(@FindData.cFileName, SizeOf(FindData.cFileName));
        if (S <> '.') and (S <> '..') and
          ((MaskExtLen < 0) or (MaskExtLen = Length(S) - LastPos('.', S)))
        then
          List.Add(S);
      end;
    until not FindNextFile(hFind, FindData);
  finally
    Windows.FindClose(hFind);
  end;
  Result:=List.Count;
end;
{$ENDIF}

{$IFDEF LINUX}
function GetDirList(List: TStrLst; const Path: String; Mask: String): Integer;
var
  I, MaskExtLen: Integer;
  SR: TSearchRec;
begin
  List.Clear;
  MaskExtLen:=GetExtLen(Mask);
  if Mask = '' then
    Mask:='*';
  if FindFirst(IncludeTrailingPathDelimiter(Path) + Mask,
    {$IFDEF V_WIN}faReadOnly + faHidden + faArchive + {$ENDIF}faDirectory, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory <> 0) and
        (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        if MaskExtLen >= 0 then begin
          I:=LastPos('.', SR.Name);
          if I > 0 then
            I:=Length(SR.Name) - I;
          if MaskExtLen <> I then
            Continue;
        end;
        List.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;
  finally
    SysUtils.FindClose(SR);
  end;
  Result:=List.Count;
end;

function GetAnyCaseFileName(const FileName: String): String;
var
  I: Integer;
  F1: Char;
  FilePath: String;
  Lst: TStrLst;
begin
  if FileExists(FileName) then begin
    Result:=FileName;
    Exit;
  end;
  Result:='';
  FilePath:=ExtractFilePath(FileName);
  I:=Length(FilePath);
  if I >= Length(FileName) then
    Exit;
  F1:=LoCase(FileName[I + 1]);
  Lst:=TStrLst.Create;
  try
    GetFileList(Lst, FilePath, F1 + '*');
    I:=Lst.IndexOf(FileName);
    if I >= 0 then begin
      Result:=Lst[I];
      Exit;
    end;
    GetFileList(Lst, FilePath, UpCase(F1) + '*');
    I:=Lst.IndexOf(FileName);
    if I >= 0 then
      Result:=Lst[I];
  finally
    Lst.Free;
  end;
end;
{$ENDIF}

end.
