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
uses
  SysUtils,
  Masks,LazUTF8,
  uzctnrVectorStrings,
  uzmacros,uzbLogIntf;
type
  //калбэки для процедур/методов перебора [суб]директорий
  TFromDirIterator=procedure(const AFileName:String;PData:pointer);
  TFromDirIteratorObj=procedure(const AFileName:String;PData:pointer)of object;

  //функция проверки наличия файлов дистрибутива программы по ACheckedPath
  //нужно для определения наличия файлов данных дистрибутива рядом с бинарем
  //или в местах спецефичных для ОС
  TDataFilesExistChecFunc=function(const ACheckedPath:string):boolean;

//подстановка макросов в APath
function ExpandPath(APath:String;AItDirectory:boolean=false):String;

//поиск файла по списку путей разделенных ';'
function FindInPaths(const APaths:String; const AFileName:String):String;

//DistroPath - путь к дистрибутиву программы, это /etc/zcad/ или
//ExtractFilePath(paramstr(0))+'../..' в зависимости где фактически лежат
//файлы дистрибутива и что найдет FindDistroPath

//DataPaths - пути данных программы, сейчас их 2, разделены ';'
//1: /home/user/.config/zcad/
//2: DistroPath
//всё ищется сначала в 1, потом в 2
//запись производится в 1

//поиск файла в подпапке в DataPaths
function FindFileInDataPaths(const ASubFolder:String;
                             const AFileName:String):String;
//пути к подпапке в DataPaths
function GetPathsInDataPaths(const ASubFolder:String):String;
//путь к подпапке в /home/user/.config/zcad/
function GetWritableFilePath(const ASubFolder:String;
                             const AFileName:String):String;

//**Получает части текста разделеные разделителем.
//**path - текст в котором идет поиск.
//**separator - разделитель.
//**part - переменная которая возвращает куски текста
function GetPartOfPath(out part:String;
                       var path:String;const separator:String):String;

//геттеры соответствующих переменных

//разные пути с файлами поддержки, почти всегда поиск файлов осуществляется
//по этим путям. пути соджет настроить юзер в настройках программы
function GetSupportPaths:String;
//путь к бинарнику
function GetBinPath:String;
//путь к дистрибутиву
function GetDistroPath:String;
//путь к папке временных файлов
function GetTempPath:String;
//дополнительные пути с файлами поддержки, сюда рути добавляются скриптами при
//запуске программы, при загрузке preload, не сохраняются и не редактируются
function GetAdditionalSupportPaths:String;

function GetTempFileName(const APath,APrefix,AExt:String):String;

//добавить путь в AdditionalSupportPaths
procedure AddToAdditionalSupportPaths(const APath:String);

//перебор файлов в папке/папках по маске, выполнение AProc и AMethod
//с подходящими файлами
procedure FromDirIterator(const APath,AMask,AFirstLoadFileName:String;
                          AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;
                          APData:pointer=nil;AIgnoreDoubles:Boolean=False);
procedure FromDirsIterator(const APath,AMask,AFirstLoadFileName:String;
                           AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;
                           APData:pointer=nil;AIgnoreDoubles:Boolean=False);

//поиск расположения дистрибутива, см. вариант 2 выше про DataPaths
function FindDistroPath(const CF:TDataFilesExistChecFunc):string;

var
  //SupportPath сохраняется и настраивается, поэтому в интерфейсе с доступом
  //геттером и прямым
  SupportPaths:String;

implementation

var
//остальные переменные с доступом только по геттеру
  AdditionalSupportPaths,DistroPath,BinPath,WriteDataPath,TempPath:String;

procedure AddToAdditionalSupportPaths(const APath:String);
begin
  if APath=''then exit;
  if AdditionalSupportPaths='' then
    AdditionalSupportPaths:=APath
  else
    if (AdditionalSupportPaths[Length(AdditionalSupportPaths)]=';')or
       (APath[1]=';') then
      AdditionalSupportPaths:=AdditionalSupportPaths+APath
    else
      AdditionalSupportPaths:=AdditionalSupportPaths+';'+APath;
end;

function GetSupportPaths:String;
begin
  if AdditionalSupportPaths='' then
    result:=SupportPaths
  else
    if SupportPaths='' then
      result:=AdditionalSupportPaths
    else
      if SupportPaths[Length(SupportPaths)]=DirectorySeparator then
        result:=SupportPaths+AdditionalSupportPaths
      else
        result:=SupportPaths+';'+AdditionalSupportPaths
end;
function GetBinPath:String;
begin
  result:=BinPath;
end;
function GetDistroPath:String;
begin
  result:=DistroPath;
end;
function GetTempPath:String;
begin
  result:=TempPath;
end;
function GetAdditionalSupportPaths:String;
begin
  result:=AdditionalSupportPaths;
end;
function GetTempFileName(const APath,APrefix,AExt:String):String;
//модифицированная копипаста из sysutils
Var
  I:LongWord;
  Start:String;
begin
  If (APath='') then
    Start:=GetTempPath
  else
    Start:=IncludeTrailingPathDelimiter(APath);
  Start:=Start+APrefix;
  I:=Random(high(LongWord));
  Repeat
    Result:=Format('%s%.8x.%s',[Start,I,AExt]);
    Inc(I);
  Until not (FileExists(Result) or DirectoryExists(Result));
end;

function FindFileInDataPaths(const ASubFolder:String;const AFileName:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASubFolder)+AFileName;
  if FileExists(result)then
    exit;
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DistroPath)+ASubFolder)+AFileName;
  if not FileExists(result)then
    exit('');
end;
function GetPathsInDataPaths(const ASubFolder:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASubFolder)+';'
         +IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DistroPath)+ASubFolder);
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
  {$IFDEF LINUX}lfn:=lowercase(AFileName);{$ENDIF}
  zTraceLn('[FILEOPS]FindInPaths: searh file:"%s"',[UTF8ToSys(AFileName)]);
  ExpandedFileName:=ExpandPath(AFileName);
  zTraceLn('[FILEOPS]FindInPaths: file name expand to:"%s"',[UTF8ToSys(ExpandedFileName)]);
  if FileExists(UTF8ToSys(ExpandedFileName)) then begin
    zTraceLn(cFindInPaths,[UTF8ToSys(ExpandedFileName)]);
    exit(ExpandedFileName);
  end;
  s:=ExpandPath(APaths);
  repeat
    GetPartOfPath(ts,s,';');
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
    result:=DistroPath
  else
    result:=APath;
  result:=StringReplace(result,'/',PathDelim,[rfReplaceAll, rfIgnoreCase]);
  if AItDirectory or DirectoryExists(UTF8ToSys(result)) then
    result:=IncludeTrailingPathDelimiter(result);
end;

procedure FromDirIteratorInternal(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer;pvs:PTZctnrVectorStrings);
var sr: TSearchRec;
    s:String;
    tpath:string;

  procedure processfile(const AFilename:String);
  var
    fn:String;
  begin
    //todo: убрать лишние операйии с именем файла
    fn:=ConcatPaths([SysToUTF8(path),SysToUTF8(AFilename)]);
    //fn:=SysToUTF8(tpath);
    zTraceLn(sysutils.Format('{D}[FILEOPS]Process file %AFilename',[fn]));
    if @method<>nil then
      method(fn,pdata);
    if @proc<>nil then
      proc(fn,pdata);
  end;

begin
  zTraceLn('{D+}[FILEOPS]FromDirIteratorInternal start');
  if firstloadfilename<>'' then
    if fileexists(path+firstloadfilename) then
      processfile(firstloadfilename);
  if FindFirst(IncludeTrailingPathDelimiter(path)+'*', faDirectory, sr) = 0 then begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        tpath:=ConcatPaths([path,sr.Name]);
        if DirectoryExists(tpath) then
          FromDirIteratorInternal(IncludeTrailingPathDelimiter(tpath),mask,firstloadfilename,proc,method,pdata,pvs)
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
    GetPartOfPath(ts,s,';');
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
function FindDistroPath(const CF:TDataFilesExistChecFunc):string;
var
  ts:string;
begin
  try
    if @cf<>nil then begin
      if cf(DistroPath) then
        exit(DistroPath);
      ts:=GetAppConfigDir(true);
      if cf(ts) then
        exit(ts);
    end;
    Result:='';
  finally
    if result<>''then
      DistroPath:=Result;
  end;
end;
initialization
  BinPath:=SysToUTF8(ExtractFilePath(paramstr(0)));
  DistroPath:=IncludeTrailingPathDelimiter(SysToUTF8(ExpandFileName(ExtractFilePath(paramstr(0))+'../..')));
  WriteDataPath:=IncludeTrailingPathDelimiter(GetAppConfigDir(false));
  TempPath:=IncludeTrailingPathDelimiter(GetTempDir);
end.
