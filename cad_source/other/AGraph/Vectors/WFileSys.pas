{ Version 041208. Copyright © Alexey A.Chernobaev, 2000-2004 }

unit WFileSys;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows, {$ENDIF}SysUtils,
  ExtType, ExtSys, StrLst, WStrLst, VectStr, VFileSys, VFileLst;

procedure DeleteFilesW(List: TWideStrLst);
{ применяет ApiDeleteFileW ко всем элементам List }
{ applies ApiDeleteFileW to all elements of List }

procedure ForceDeleteFilesW(List: TWideStrLst);
procedure ForceDeleteFilesOrDirsW(List: TWideStrLst);
{ применяет ForceDelete... ко всем элементам List }
{ applies ForceDelete... to all elements of List }

procedure ForceDeleteDirsW(List: TWideStrLst; SubDirs: Boolean);
{ удаляет директории из списка List; при SubDirs = True рекурсивно удаляет
  также все их поддиректории }
{ deletes all directories from List; if SubDirs = True then recursively deletes
  all their subdirectories }

function GetFileListW(List: TWideStrLst; const Path: WideString;
  Mask: WideString{$IFDEF V_D4} = ''{$ENDIF};
  SubDirs: Boolean{$IFDEF V_D4} = False{$ENDIF}
  {$IFDEF V_WIN}; FileExcludeAttrs: UInt16 = 0{$ENDIF}): Integer;
{ сканирует директорию Path (а также все поддиректории Path при SubDirs = True)
  и записывает в List полные имена всех файлов, соответствующих маске Mask
  (маска по умолчанию - '*.*'); если FileExcludeAttrs <> 0, то файлы, у которых
  установлен хотя бы один из атрибутов FileExcludeAttrs, не включаются в список
  результатов; возвращает количество найденных файлов }
{ scans the directory Path (and all it's subdirectories if SubDirs = True) and
  adds full names of files matching Mask (the default mask is '*.*') to List;
  if FileExcludeAttrs <> 0 then files which have at least one attribute from
  FileExcludeAttrs set will not be included into the result list; returns the number
  of the files found }

function GetDirListW(List: TWideStrLst; const Path: WideString;
  Mask: WideString{$IFDEF V_D4} = ''{$ENDIF}
  {$IFDEF V_WIN}; DirExcludeAttrs: UInt16 = 0{$ENDIF}): Integer;
{ сканирует директорию Path и записывает в List список поддиректорий Path (без
  полных путей), соответствующих маске Mask; если Mask = '', то принимаются все
  поддиректории; возвращает количество найденных поддиректорий }
{ scans the directory Path and writes names of subdirectories of Path matching
  Mask to the List (without full paths); if Mask = '' then all subdirectories
  are accepted; returns the number of the subdirectories found }

function FindPart(const HelpWilds, InputStr: WideString): Integer;
function IsWild(InputStr, Wilds: WideString; IgnoreCase, LikeDOS: Boolean): Boolean;
{ FindPart and IsWild are based on functions from RX Library (Delphi VCL
  Extensions, unit StrUtils) but modified to support wide strings, etc. }

function IsWilds(const FileName: WideString; Masks: TWideStrLst): Boolean;

function GetStdFileExtW(const FileName: WideString): WideString;
{ возвращает расширение файла без начальной точки, всегда в нижнем регистре }
{ returns the extension portion of the given file name without a leading dot,
  always lowercase }

implementation

procedure DeleteFilesW(List: TWideStrLst);
var
  I: Integer;
begin
  for I:=0 to List.Count - 1 do
    ApiDeleteFileW(List[I]);
end;

procedure ForceDeleteFilesW(List: TWideStrLst);
var
  I: Integer;
begin
  for I:=0 to List.Count - 1 do
    ForceDeleteFileW(List[I]);
end;

procedure ForceDeleteFilesOrDirsW(List: TWideStrLst);
var
  I: Integer;
begin
  for I:=0 to List.Count - 1 do
    ForceDeleteFileOrDirW(List[I]);
end;

procedure ForceDeleteDirsW(List: TWideStrLst; SubDirs: Boolean);

  procedure DeleteDir(Path: WideString);
  var
    I: Integer;
    Dirs: TWideStrLst;
  begin
    if SubDirs then begin
      Path:=IncludePathDelimiterW(Path);
      Dirs:=TWideStrLst.Create;
      try
        GetDirListW(Dirs, Path, '');
        for I:=0 to Dirs.Count - 1 do
          DeleteDir(Path + Dirs[I]);
      finally
        Dirs.Free;
      end;
    end;
    ForceDeleteDirW(Path);
  end;

var
  I: Integer;
begin
  List.SortDesc;
  for I:=0 to List.Count - 1 do
    DeleteDir(List[I]);
end;

function GetExtLen(const Mask: WideString): Integer;
var
  I: Integer;
begin
  Result:=-1;
  if Mask <> '' then begin
    I:=WideLastPos('.', Mask);
    if WideCharPos('*', Mask, I + 1) = 0 then
      Result:=Length(Mask) - I;
  end;
end;

function GetFileListW(List: TWideStrLst; const Path: WideString;
  Mask: WideString; SubDirs: Boolean
  {$IFDEF V_WIN}; FileExcludeAttrs: UInt16{$ENDIF}): Integer;
{$IFDEF V_WIN}
var
  MaskExtLen: Integer;

  procedure AddToList(const CurPath: WideString);
  var
    I: Integer;
    hFind: THandle;
    W: WideString;
    FindData: TWin32FindDataW;
    SubDirList: TWideStrLst;
  begin
    W:=CurPath;
    I:=Length(Mask);
    if Length(W) + I >= MAX_PATH then begin
      W:=UNCPath(W);
      if Mask[I] = '.' then
        Mask:=Mask + '*'; // иначе не находится
    end;
    hFind:=FindFirstFileW(PWideChar(W + Mask), FindData);
    if hFind <> INVALID_HANDLE_VALUE then
    try
      repeat
        // бывает: при Mask = '*.txt' получаем '*.txt1' => проверяем по MaskExtLen
        // sometimes we get '*.txt1' when Mask = '*.txt' => check by MaskExtLen
        if FindData.dwFileAttributes and FileExcludeAttrs = 0 then begin
          W:=LWideString(@FindData.cFileName, High(FindData.cFileName) + 1);
          if (MaskExtLen < 0) or (MaskExtLen = Length(W) - WideLastPos('.', W)) then
            List.Add(CurPath + W);
        end;
      until not FindNextFileW(hFind, FindData);
    finally
      Windows.FindClose(hFind);
    end;
    if SubDirs then begin
      SubDirList:=TWideStrLst.Create;
      try
        GetDirListW(SubDirList, CurPath, '*');
        for I:=0 to SubDirList.Count - 1 do
          AddToList(CurPath + SubDirList.Items[I] + PathDelim);
      finally
        SubDirList.Free;
      end;
    end;
  end;
{$ENDIF}
var
  AnsiList: TStrLst;
begin
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    List.Clear;
    FileExcludeAttrs:=FileExcludeAttrs or FILE_ATTRIBUTE_DIRECTORY;
    if Path <> '' then begin
      MaskExtLen:=GetExtLen(Mask);
      if Mask = '' then
        Mask:='*.*';
      AddToList(IncludePathDelimiterW(Path));
    end;
    Result:=List.Count;
  end
  else
  {$ENDIF}
  begin
    AnsiList:=TStrLst.Create;
    try
      Result:=GetFileList(AnsiList, Path, Mask, SubDirs);
      List.AssignAnsi(AnsiList);
    finally
      AnsiList.Free;
    end;
  end;
end;

function GetDirListW(List: TWideStrLst; const Path: WideString;
  Mask: WideString{$IFDEF V_WIN}; DirExcludeAttrs: UInt16{$ENDIF}): Integer;
var
  {$IFDEF V_WIN}
  I, MaskExtLen: Integer;
  W: WideString;
  hFind: THandle;
  FindData: TWin32FindDataW;
  {$ENDIF}
  AnsiList: TStrLst;
begin
  if Path = '' then begin
    Result:=0;
    Exit;
  end;
  {$IFDEF V_WIN}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    List.Clear;
    MaskExtLen:=GetExtLen(Mask);
    if Mask = '' then
      Mask:='*';
    W:=IncludePathDelimiterW(Path);
    I:=Length(Mask);
    if Length(W) + I >= MAX_PATH then begin
      W:=UNCPath(W);
      if Mask[I] = '.' then
        Mask:=Mask + '*'; // иначе не находится
    end;
    hFind:=FindFirstFileW(PWideChar(W + Mask), FindData);
    if hFind <> INVALID_HANDLE_VALUE then
    try
      repeat
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
          (FindData.dwFileAttributes and DirExcludeAttrs = 0) then
        begin
          W:=LWideString(@FindData.cFileName, High(FindData.cFileName) + 1);
          if (W <> '.') and (W <> '..') and
            ((MaskExtLen < 0) or (MaskExtLen = Length(W) - WideLastPos('.', W)))
          then
            List.Add(W);
        end;
      until not FindNextFileW(hFind, FindData);
    finally
      Windows.FindClose(hFind);
    end;
  end
  else
  {$ENDIF}
  begin
    AnsiList:=TStrLst.Create;
    try
      GetDirList(AnsiList, Path, Mask{$IFDEF V_WIN}, DirExcludeAttrs{$ENDIF});
      List.AssignAnsi(AnsiList);
    finally
      AnsiList.Free;
    end;
  end;
  Result:=List.Count;
end;

{ FindPart and IsWild are based on functions from RX Library (Delphi VCL
  Extensions, unit StrUtils) but modified to support wide strings, etc. }

function FindPart(const HelpWilds, InputStr: WideString): Integer;
var
  I, J, L, Diff: Integer;
begin
  I:=WideCharPos('?', HelpWilds);
  if I = 0 then begin
    { if no '?' in HelpWilds }
    Result:=Pos(HelpWilds, InputStr);
    Exit;
  end;
  { '?' in HelpWilds }
  L:=Length(HelpWilds);
  Diff:=Length(InputStr) - L;
  if Diff < 0 then begin
    Result:=0;
    Exit;
  end;
  { now move HelpWilds over InputStr }
  for I:=0 to Diff do
    for J:=1 to L do
      if (InputStr[I + J] = HelpWilds[J]) or (HelpWilds[J] = '?') then begin
        if J = L then begin
          Result:=I + 1;
          Exit;
        end;
      end
      else
        Break;
  Result:=0;
end;

function IsWild(InputStr, Wilds: WideString; IgnoreCase, LikeDOS: Boolean): Boolean;
var
  I, L, CWild, MaxWilds, CInputWord, LenHelpWilds, MaxInputWord: Integer;
  HelpWilds: WideString;
begin
  if Wilds = '' then begin
    Result:=False;
    Exit;
  end;
  Result:=True;
  if Wilds = InputStr then
    Exit;
  repeat { delete '**', because '**' = '*' }
    I:=Pos('**', Wilds);
    if I = 0 then
      Break;
    Delete(Wilds, I, 1);
  until False;
  if LikeDOS then begin
    L:=Length(Wilds);
    if Wilds[L] = '.' then begin
      I:=WideCharPos('.', InputStr);
      if (I > 0) and (I < Length(InputStr)) then begin
        Result:=False;
        Exit;
      end;
      if I > 0 then
        SetLength(InputStr, I - 1);
      SetLength(Wilds, L - 1);
    end
    else
      if (L > 2) and EndsWith(Wilds, '.*') then
        if Wilds[L - 2] = '*' then { X*.* -> X* }
          SetLength(Wilds, L - 2)
        else
          Delete(Wilds, L - 1, 1); { X.* -> X* }
  end;
  if Wilds = '*' then { for fast end, if Wilds only '*' }
    Exit;
  MaxWilds:=Length(Wilds);
  MaxInputWord:=Length(InputStr);
  if (MaxWilds = 0) or (MaxInputWord = 0) then begin
    Result:=False;
    Exit;
  end;
  if IgnoreCase then begin
    InputStr:=WideUpperCase(InputStr);
    Wilds:=WideUpperCase(Wilds);
  end;
  CWild:=1;
  CInputWord:=1;
  repeat
    if (InputStr[CInputWord] = Wilds[CWild]) or (Wilds[CWild] = '?') then begin
      { goto next letter }
      Inc(CWild);
      Inc(CInputWord);
    end
    else
      if Wilds[CWild] = '*' then begin { handling of '*' }
        HelpWilds:=Copy(Wilds, CWild + 1, MaxWilds);
        I:=WideCharPos('*', HelpWilds);
        if I > 0 then
          SetLength(HelpWilds, I - 1);
        LenHelpWilds:=Length(HelpWilds);
        if I = 0 then begin
          { no '*' in the rest, compare the ends }
          if HelpWilds = '' then
            Exit; { '*' is the last letter }
          { check the rest for equal Length and no '?' }
          for I:=0 to LenHelpWilds - 1 do begin
            if (HelpWilds[LenHelpWilds - I] <> InputStr[MaxInputWord - I]) and
              (HelpWilds[LenHelpWilds - I] <> '?') then
            begin
              Result:=False;
              Exit;
            end;
          end;
          Exit;
        end;
        { handle all to the next '*' }
        Inc(CWild, 1 + LenHelpWilds);
        I:=FindPart(HelpWilds, Copy(InputStr, CInputWord, MaxInt));
        if I = 0 then begin
          Result:=False;
          Exit;
        end;
        CInputWord:=I + LenHelpWilds;
      end
      else begin
        Result:=False;
        Exit;
      end;
  until (CInputWord > MaxInputWord) or (CWild > MaxWilds);
  { no completed evaluation }
  if (CInputWord <= MaxInputWord) or
    ((CWild <= MaxWilds) and (Wilds[MaxWilds] <> '*'))
  then
    Result:=False;
end;

function IsWilds(const FileName: WideString; Masks: TWideStrLst): Boolean;
var
  I: Integer;
  Name: WideString;
begin
  if (Masks = nil) or (Masks.Count = 0) or
    (Masks.IndexOf({$IFDEF V_WIN}'*.*'{$ENDIF}{$IFDEF LINUX}'*'{$ENDIF}) >= 0)
  then
    Result:=True
  else begin
    I:=LastDelimiterW('|' + PathDelim + DriveDelim, FileName);
    Name:=Copy(FileName, I + 1, MaxInt);
    for I:=0 to Masks.Count - 1 do
      if IsWild(Name, Masks[I],
        {$IFDEF V_WIN}True, True{$ENDIF}
        {$IFDEF LINUX}False, False{$ENDIF}) then
      begin
        Result:=True;
        Exit;
      end;
    Result:=False;
  end;
end;

function GetStdFileExtW(const FileName: WideString): WideString;
begin
  Result:=WideLowerCase(Copy(ExtractFileExtW(FileName), 2, MaxInt));
end;

end.
