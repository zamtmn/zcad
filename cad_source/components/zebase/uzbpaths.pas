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
uses Masks,LazUTF8,sysutils,
     uzctnrVectorStrings,
     uzmacros,uzbLogIntf;
type
  TFromDirIterator=procedure (const filename:String;pdata:pointer);
  TFromDirIteratorObj=procedure (const filename:String;pdata:pointer) of object;
  TDataFilesExistChecFunc=function(ACheckedPath:string):boolean;
function ExpandPath(APath:String;AItDirectory:boolean=false):String;
function FindInSupportPath(const APaths:String; FileName:String):String;
function FindInPaths(const APaths:String; FileName:String):String;
function FindInDataPaths(const ASuffix:String;const FileName:String):String;
function DirInDataPaths(const ASuffix:String):String;
function GetWritablePath(const ASuffix:String;const FileName:String):String;

//**Получает части текста разделеные разделителем.
//**path - текст в котором идет поиск.
//**separator - разделитель.
//**part - переменная которая возвращает куски текста
function GetPartOfPath(out part:String;var path:String;const separator:String):String;
function GetSupportPath:String;
{TODO: костыли))}
function GeAddrSupportPath:PString;
procedure AddSupportPath(const APath:String);

procedure FromDirIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer=nil;IgnoreDoubles:Boolean=False);
procedure FromDirsIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer=nil;IgnoreDoubles:Boolean=False);
function FindDataPath(CF:TDataFilesExistChecFunc):string;
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
function FindInDataPaths(const ASuffix:String;const FileName:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASuffix)+FileName;
  if FileExists(result)then
    exit;
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DataPath)+ASuffix)+FileName;
  if not FileExists(result)then
    exit('');
end;
function DirInDataPaths(const ASuffix:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASuffix)+';'
         +IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DataPath)+ASuffix);
end;

function GetWritablePath(const ASuffix:String;const FileName:String):String;
begin
  result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+ASuffix)+FileName;
end;

function FindInPaths(const APaths:String; FileName:String):String;
var
   s,ts,ts2:String;
begin
     FileName:=ExpandPath(FileName);
     ts:={$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName);
     if FileExists(ts)  then
                            begin
                                 result:=FileName;
                                 exit;
                            end;
     {$IFDEF LINUX}
     ts:=lowercase(ts);
     if FileExists(ts)  then
                            begin
                                 result:=lowercase(FileName);
                                 exit;
                            end;
     {$ENDIF}
     s:=APaths;
     repeat
           GetPartOfPath(ts,s,';');
           ts:=ExpandPath(ts)+FileName;
           ts2:={$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts);
           if FileExists(ts2) then
                                 begin
                                      result:=ts;
                                      exit;
                                 end;
           {$IFDEF LINUX}
           ts2:=lowercase(ts2);
           if FileExists(ts2)  then
                                  begin
                                       result:=lowercase(ts);
                                       exit;
                                  end;
           {$ENDIF}
     until s='';
     result:='';
end;
function GetPartOfPath(out part:String;var path:String;const separator:String):String;
var
   i:Integer;
begin
           i:=pos(separator,path);
           if i<>0 then
                       begin
                            part:=copy(path,1,i-1);
                            path:=copy(path,i+1,length(path)-i);
                       end
                   else
                       begin
                            part:=path;
                            path:='';
                       end;
     result:=part;
end;
function FindInSupportPath(const APaths:String; FileName:String):String;
const
  cFindInSupportPath='[FILEOPS]FindInSupportPath: found file:"%s"';
var
  s,ts:String;
begin
  zTraceLn('[FILEOPS]FindInSupportPath: searh file:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]);
  FileName:=ExpandPath(FileName);
  zTraceLn('[FILEOPS]FindInSupportPath: file name expand to:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]);
  if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)) then begin
    zTraceLn(cFindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]);
    exit(FileName);
  end;
  s:=APaths;
  s:=ExpandPath(s);
  repeat
    GetPartOfPath(ts,s,';');
    zTraceLn('[FILEOPS]FindInSupportPath: searh in "%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)]);
    ts:=ts+FileName;
    if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then begin
      zTraceLn(cFindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)]);
      exit(ts);
    end;
  until s='';
  result:='';
  zDebugLn(sysutils.Format('{E}FindInSupportPath: file not found:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
end;
function ExpandPath(APath:String;AItDirectory:boolean=false):String;
begin
  DefaultMacros.SubstituteMacros(APath);
  if APath='' then
    result:=DataPath
  else
    result:=APath;
  result:=StringReplace(result,'/', PathDelim,[rfReplaceAll, rfIgnoreCase]);
  if AItDirectory or DirectoryExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)) then
    if (result[length(result)]<>PathDelim)
    then
      result:=result+PathDelim;
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
procedure FromDirsIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer;IgnoreDoubles:Boolean=False);
var
  s,ts:String;
  pvs:PTZctnrVectorStrings;
  vs:TZctnrVectorStrings;
begin
  if IgnoreDoubles then begin
    vs.init(100);
    pvs:=@vs;
  end else
    pvs:=nil;
  s:=path;
  repeat
    GetPartOfPath(ts,s,';');
    ts:=ExpandPath(ts);
    FromDirIteratorInternal(ts,mask,firstloadfilename,proc,method,pdata,pvs);
  until s='';
  if IgnoreDoubles then
    vs.done;
end;
procedure FromDirIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer;IgnoreDoubles:Boolean=False);
var
  pvs:PTZctnrVectorStrings;
  vs:TZctnrVectorStrings;
begin
  if IgnoreDoubles then begin
    vs.init(100);
    pvs:=@vs;
  end else
    pvs:=nil;
  FromDirIteratorInternal(path,mask,firstloadfilename,proc,method,pdata,pvs);
  if IgnoreDoubles then
    vs.done;
end;
function FindDataPath(CF:TDataFilesExistChecFunc):string;
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
  BinPath:={$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)));
  DataPath:={$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExpandFileName(ExtractFilePath(paramstr(0))+'../..'));;
  WriteDataPath:=GetAppConfigDir(false);
  {$IfNDef DELPHI}
    TempPath:=GetTempDir;
  {$Else}
    TempPath:=GetEnvironmentVariable('TEMP');
  {$EndIf}
  if (TempPath[length(TempPath)]<>PathDelim)
   then
       TempPath:=TempPath+PathDelim;
end.
