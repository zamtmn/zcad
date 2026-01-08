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
{$Mode delphi}
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
  //нужно для определения наличия файлов данных дистрибутива и конфигов рядом
  //с бинарником (удобно для разработки) или в местах спецефичных для ОС
  TDataFilesExistChecFunc=function(const ACheckedPath:string):boolean;


//**Получает части текста разделеные разделителем.
//**path - текст в котором идет поиск.
//**separator - разделитель.
//**part - переменная которая возвращает куски текста
function GetPartOfPath(out part:String;
                       var path:String;const separator:String):String;

//перебор файлов в папке/папках по маске, выполнение AProc и AMethod
//с подходящими файлами
procedure FromDirIterator(const APath,AMask,AFirstLoadFileName:String;
                          AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;
                          APData:pointer=nil;AIgnoreDoubles:Boolean=False);
procedure FromDirsIterator(const APath,AMask,AFirstLoadFileName:String;
                           AProc:TFromDirIterator;AMethod:TFromDirIteratorObj;
                           APData:pointer=nil;AIgnoreDoubles:Boolean=False);

//подстановка макросов в APath
function ExpandPath(APath:String):String;

//поиск файла по списку путей разделенных ';'
function FindInPaths(const APaths:String; const AFileName:String):String;

//RoCfgsPath - путь к конфигам программы, это /etc/zcad/ или
//ExtractFilePath(paramstr(0))+'../../cfg' в зависимости где фактически лежат
//файлы дистрибутива и что найдет FindConfigsPath

//WrCfgsPath - путь к конфигам пользователя, это результат GetAppConfigDir(false)
//обычно /home/%user%/.config/zcad/

//CfgsPaths - пути данных программы, сейчас их 2, разделены ';'
//1: WrCfgsPath
//2: RoCfgsPath
//конфиги ищутся сначала в 1, потом в 2
//запись производится в 1

//поиск файла в подпапке в директориях конфигов
function FindFileInCfgsPaths(const ASubFolder:String;
                             const AFileName:String):String;
//пути к подпапке в директориях конфигов
function GetPathsInCfgsPaths(const ASubFolder:String):String;
//путь к файлу в WrCfgsPath
function GetWritableFilePath(const ASubFolder:String;
                             const AFileName:String):String;

//DistribPath - путь к дистрибутиву программы, это /var/lib/zcad/ или
//ExtractFilePath(paramstr(0))+'../../data' в зависимости где фактически лежат
//файлы дистрибутива и что найдет FindDistribPath

//пути к подпапке в DistribPath
function GetPathsInDistribPath(const ASubFolder:String):String;

//геттеры/сеттеры соответствующих путей

//путь к дистрибутиву
function GetDistribPath:String;
//сеттер для возможность установить путь к дистрибутиву из конфигов, работает
//только если дистрибктив не был обнаружен рядом с бинарником, см. выше
//описание DistribPath
procedure SetDistribPath(const APath:String);

//разные пути с файлами поддержки, почти всегда поиск файлов осуществляется
//по этим путям. пути поддержки моджет настроить юзер в настройках программы
function GetSupportPaths:String;

//дополнительные пути с файлами поддержки, сюда пути добавляются скриптами при
//запуске программы, при загрузке preload, не сохраняются и не редактируются
function GetAdditionalSupportPaths:String;
//добавить путь в AdditionalSupportPaths
procedure AddToAdditionalSupportPaths(const APath:String);

//путь к бинарнику
function GetBinaryPath:String;

//путь к RO конфигам программы
function GetRoCfgsPath:String;

//путь к WR конфигам юзера
function GetWrCfgsPath:String;

//путь к папке временных файлов
function GetTempPath:String;
//файл в папке временных файлов
function GetTempFileName(const APath,APrefix,AExt:String):String;

//поиск расположения дистрибутива
function FindDistribPath(const CF:TDataFilesExistChecFunc):string;

//поиск расположения конфигов
function FindConfigsPath(const CF:TDataFilesExistChecFunc):string;

var
  //SupportPath сохраняется и настраивается, поэтому в интерфейсе с доступом
  //геттером и прямым
  SupportPaths:String;

implementation

var
  //доступ геттером и сеттером
  DistribPath:String;
  //DistribPath переопределен (FindDistribPath нашел дистрибутив рядом с бинарем)
  DistribPathOverride:boolean;
  //остальные переменные с доступом только по геттеру
  BinaryPath,TempPath,AdditionalSupportPaths,RoCfgsPath,WrCfgsPath:String;

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
      if (SupportPaths[Length(SupportPaths)]=';')or
         (AdditionalSupportPaths[1]=';') then
        result:=SupportPaths+AdditionalSupportPaths
      else
        result:=SupportPaths+';'+AdditionalSupportPaths
end;
function GetBinaryPath:String;
begin
  result:=BinaryPath;
end;
function GetDistribPath:String;
begin
  result:=DistribPath;
end;
procedure SetDistribPath(const APath:String);
begin
  if not DistribPathOverride then
    DistribPath:=APath;
end;
function GetRoCfgsPath:String;
begin
  result:=RoCfgsPath;
end;
function GetWrCfgsPath:String;
begin
  result:=WrCfgsPath;
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

function FindFileInCfgsPaths(const ASubFolder:String;const AFileName:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(WrCfgsPath)+ASubFolder)+AFileName;
  if FileExists(result)then
    exit;
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(RoCfgsPath)+ASubFolder)+AFileName;
  if not FileExists(result)then
    exit('');
end;
function GetPathsInCfgsPaths(const ASubFolder:String):String;
begin
  result:=ConcatPaths([WrCfgsPath,ASubFolder])+';'
         +ConcatPaths([RoCfgsPath,ASubFolder]);
end;

function GetWritableFilePath(const ASubFolder:String;const AFileName:String):String;
begin
  result:=ConcatPaths([WrCfgsPath,ASubFolder]);
  ForceDirectories(result);
  result:=ConcatPaths([result,AFileName]);
end;

function GetPathsInDistribPath(const ASubFolder:String):String;
 begin
  result:=ConcatPaths([DistribPath,ASubFolder]);
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
    ts2:=ConcatPaths([ts,ExpandedFileName]);
    if FileExists(UTF8ToSys(ts2))then begin
      zTraceLn(cFindInPaths,[UTF8ToSys(ts2)]);
      exit(ts2);
    end;
   {$IFDEF LINUX}
    ts2:=ConcatPaths([ts,lfn]);
    if FileExists(ts2) then begin
      zTraceLn(cFindInPaths,[UTF8ToSys(ts2)]);
      exit(ts2);
    end;
   {$ENDIF}
  until s='';
  result:='';
  zDebugLn(sysutils.Format('{E}FindInPaths: file not found:"%s"',[UTF8ToSys(ExpandedFileName)]));
end;
function ExpandPath(APath:String):String;
begin
  DefaultMacros.SubstituteMacros(APath);
  if APath='' then
    result:=RoCfgsPath
  else
    result:=APath;
  DoDirSeparators(result);
  result:=StringReplace(result,'/',PathDelim,[rfReplaceAll, rfIgnoreCase]);
  {if AItDirectory or DirectoryExists(UTF8ToSys(result)) then
    result:=IncludeTrailingPathDelimiter(result);}
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
    if fileexists(ConcatPaths([path,firstloadfilename])) then
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
function FindConfigsPath(const CF:TDataFilesExistChecFunc):string;
var
  ts:string;
begin
  try
    if @cf<>nil then begin
      if cf(RoCfgsPath) then
        exit(RoCfgsPath);
      ts:=GetAppConfigDir(true);
      if cf(ts) then
        exit(ts);
    end;
    Result:='';
  finally
    if result<>''then
      RoCfgsPath:=Result;
  end;
end;

function FindDistribPath(const CF:TDataFilesExistChecFunc):string;
var
  ts:string;
begin
  try
    if @cf<>nil then begin
      if cf(DistribPath) then
        exit(DistribPath);
    end;
    Result:='';
  finally
    if result<>''then
      DistribPathOverride:=True;
  end;
end;

initialization
  BinaryPath:=ExcludeTrailingPathDelimiter(ExtractFilePath(paramstr(0)));
  DistribPath:=ExpandFileName(ConcatPaths([BinaryPath,'..','data']));
  DistribPathOverride:=false;
  RoCfgsPath:=ExpandFileName(ConcatPaths([BinaryPath,'..','cfg']));
  WrCfgsPath:=ExcludeTrailingPathDelimiter(GetAppConfigDir(false));
  TempPath:=ExcludeTrailingPathDelimiter(GetTempDir);
end.
