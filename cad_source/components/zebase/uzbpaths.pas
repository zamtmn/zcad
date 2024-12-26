{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzbPaths;

interface
uses SysUtils,
     Masks,LazUTF8,
     uzctnrVectorStrings,
     uzmacros,uzbLogIntf;
type
  //калбэки для перебора [суб]директорий
  TFromDirIterator=procedure(const AFileName:String;PData:pointer);
  TFromDirIteratorObj=procedure(const AFileName:String;PData:pointer)of object;

  //функция проверки наличия файлов дистрибутива программы по ACheckedPath
  //нужно для определения наличия файлов данных дистрибутива рядом с бинарем
  //или в местах спецефичных для ОС
  TDataFilesExistChecFunc=function(const ACheckedPath:string):boolean;

//подстановка макросов в APath
function ExpandPath(APath:String;AItDirectory:boolean=false):String;

function FindInPaths(const APaths:String; const AFileName:String):String;
function FindFileInDataPaths(const ASubFolder:String;const AFileName:String):String;
function GetPathsInDataPaths(const ASubFolder:String):String;
function GetWritableFilePath(const ASubFolder:String;const AFileName:String):String;

//**Получает части текста разделеные разделителем.
//**path - текст в котором идет поиск.
//**separator - разделитель.
//**part - переменная которая возвращает куски текста
function GetPartOfPath(out part:String;var path:String;const separator:String):String;
function GetSupportPath:String;
{TODO: костыли))}
function GeAddrSupportPath:PString;
procedure AddSupportPath(const APath:String);

procedure FromDirIterator(const APath,AMask,AFirstLoadFileName:String;AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;APData:pointer=nil;AIgnoreDoubles:Boolean=False);
procedure FromDirsIterator(const APath,AMask,AFirstLoadFileName:String;AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;APData:pointer=nil;AIgnoreDoubles:Boolean=False);
function FindDataPath(const CF:TDataFilesExistChecFunc):string;
var DataPath,BinPath,AdditionalSupportPath,TempPath:String;
implementation
var WriteDataPath,SupportPath:String;

procedure AddSupportPath(const APath:String);
begin
  if APath=''then exit;
  if AdditionalSupportPath='' then
    AdditionalSupportPath:=APath
  else
    if (AdditionalSupportPath[Length(AdditionalSupportPath)]=PathSeparator)or(APath[1]=PathSeparator) then
      AdditionalSupportPath:=AdditionalSupportPath+APath
    else
      AdditionalSupportPath:=AdditionalSupportPath+PathSeparator+APath;
end;

function GetSupportPath:String;
begin
  if AdditionalSupportPath='' then
    result:=SupportPath
  else
    if SupportPath='' then
      result:=AdditionalSupportPath
    else
      if SupportPath[Length(SupportPath)]=DirectorySeparator then
        result:=SupportPath+AdditionalSupportPath
      else
        result:=SupportPath+PathSeparator+AdditionalSupportPath
end;
function GeAddrSupportPath:PString;
begin
  result:=@SupportPath;
end;
function FindFileInDataPaths(const ASubFolder:String;const AFileName:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASubFolder)+AFileName;
  if FileExists(result)then
    exit;
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DataPath)+ASubFolder)+AFileName;
  if not FileExists(result)then
    exit('');
end;
function GetPathsInDataPaths(const ASubFolder:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASubFolder)+PathSeparator
         +IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DataPath)+ASubFolder);
end;

function GetWritableFilePath(const ASubFolder:String;const AFileName:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASubFolder)+AFileName;
end;

function GetPartOfPath(out part:String;var path:String;const separator:String):String;
var
  i:Integer;
begin
  i:=pos(separator,path);
  if i<>0 then begin
    part:=copy(path,1,i-1);
    path:=copy(path,i+1,length(path)-i);
  end else begin
    part:=path;
    path:='';
  end;
  result:=part;
end;

function FindInPaths(const APaths:String; const AFileName:String):String;
const
  cFindInPaths='[FILEOPS]FindInPaths: found file:"%s"';
var
  ExpandedFileName,s,ts,ts2{$IFDEF LINUX},lfn{$ENDIF}:String;
begin
  {$IFDEF LINUX}lfn:=lowercase(FileName);{$ENDIF}
  zTraceLn('[FILEOPS]FindInPaths: searh file:"%s"',[UTF8ToSys(AFileName)]);
  ExpandedFileName:=ExpandPath(AFileName);
  zTraceLn('[FILEOPS]FindInPaths: file name expand to:"%s"',[UTF8ToSys(ExpandedFileName)]);
  if FileExists(UTF8ToSys(ExpandedFileName)) then begin
    zTraceLn(cFindInPaths,[UTF8ToSys(ExpandedFileName)]);
    exit(ExpandedFileName);
  end;
  s:=ExpandPath(APaths);
  repeat
    GetPartOfPath(ts,s,PathSeparator);
    zTraceLn('[FILEOPS]FindInPaths: searh in "%s"',[UTF8ToSys(ts)]);
    ts2:=ts+ExpandedFileName;
    if FileExists(UTF8ToSys(ts2))then begin
      zTraceLn(cFindInPaths,[UTF8ToSys(result)]);
      exit(ts2);
    end;
   {$IFDEF LINUX}
    ts2:=ts+lfn;
    if FileExists(ts2) then
      exit(ts2);
   {$ENDIF}
  until s='';
  result:='';
  zDebugLn(sysutils.Format('{E}FindInPaths: file not found:"%s"',[UTF8ToSys(ExpandedFileName)]));
end;
function ExpandPath(APath:String;AItDirectory:boolean=false):String;
begin
  DefaultMacros.SubstituteMacros(APath);
  if APath='' then
    result:=DataPath
  else
    result:=APath;
  result:=StringReplace(result,'/',PathDelim,[rfReplaceAll, rfIgnoreCase]);
  if AItDirectory or DirectoryExists(UTF8ToSys(result)) then
    result:=IncludeTrailingPathDelimiter(result);
end;

procedure FromDirIteratorInternal(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer;pvs:PTZctnrVectorStrings);
  procedure processfile(const s:String);
  var
    fn:String;
  begin
    fn:=SysToUTF8(path)+SysToUTF8(s);
    zTraceLn(sysutils.Format('{D}[FILEOPS]Process file %s',[fn]));
    if @method<>nil then
      method(fn,pdata);
    if @proc<>nil then
      proc(fn,pdata);
  end;

var sr: TSearchRec;
    s:String;
begin
  zTraceLn('{D+}[FILEOPS]FromDirIteratorInternal start');
  if firstloadfilename<>'' then
    if fileexists(path+firstloadfilename) then
      processfile(firstloadfilename);
  if FindFirst(path + '*', faDirectory, sr) = 0 then begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if DirectoryExists(path + sr.Name) then
          FromDirIteratorInternal(path + sr.Name + '/',mask,firstloadfilename,proc,method,pdata,pvs)
        else begin
          s:=lowercase(sr.Name);
          if s<>firstloadfilename then
            if ((pvs<>nil)and(pvs^.findstring(s,false)<0))or(pvs=nil)then
              if MatchesMask(s,mask) then begin
                if pvs<>nil then
                  pvs^.PushBackData(s);
                processfile(sr.Name);
              end;
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  zTraceLn('{D-}[FILEOPS]end; {FromDirIterator}');
end;
procedure FromDirsIterator(const APath,AMask,AFirstLoadFileName:String;AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;APData:pointer;AIgnoreDoubles:Boolean=False);
var
  s,ts:String;
  pvs:PTZctnrVectorStrings;
  vs:TZctnrVectorStrings;
begin
  if AIgnoreDoubles then begin
    vs.init(100);
    pvs:=@vs;
  end else
    pvs:=nil;
  s:=APath;
  repeat
    GetPartOfPath(ts,s,PathSeparator);
    ts:=ExpandPath(ts);
    FromDirIteratorInternal(ts,AMask,AFirstLoadFileName,AProc,AMethod,APData,pvs);
  until s='';
  if AIgnoreDoubles then
    vs.done;
end;
procedure FromDirIterator(const APath,AMask,AFirstLoadFileName:String;AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;APData:pointer;AIgnoreDoubles:Boolean=False);
var
  pvs:PTZctnrVectorStrings;
  vs:TZctnrVectorStrings;
begin
  if AIgnoreDoubles then begin
    vs.init(100);
    pvs:=@vs;
  end else
    pvs:=nil;
  FromDirIteratorInternal(APath,AMask,AFirstLoadFileName,AProc,AMethod,APData,pvs);
  if AIgnoreDoubles then
    vs.done;
end;
function FindDataPath(const CF:TDataFilesExistChecFunc):string;
var
  ts:string;
begin
  if @cf<>nil then begin
    if cf(DataPath) then
      exit(DataPath);
    ts:=GetAppConfigDir(true);
    if cf(ts) then
      exit(ts);
  end;
  result:='';
end;
initialization
  BinPath:=SysToUTF8(ExtractFilePath(paramstr(0)));
  DataPath:=SysToUTF8(ExpandFileName(ExtractFilePath(paramstr(0))+'../..'));;
  WriteDataPath:=GetAppConfigDir(false);
  TempPath:=IncludeTrailingPathDelimiter(GetTempDir);
end.
