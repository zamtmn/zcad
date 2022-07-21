{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit uzbpaths;

interface
uses uzbtypes,Masks,LCLProc,{$IFNDEF DELPHI}LazUTF8,{$ENDIF}sysutils,
     uzmacros,uzbLogIntf;
type
  TFromDirIterator=procedure (filename:String;pdata:pointer);
  TFromDirIteratorObj=procedure (filename:String;pdata:pointer) of object;
function ExpandPath(path:String):String;
function FindInSupportPath(PPaths:String;FileName:String):String;
function FindInPaths(Paths,FileName:String):String;

//**Получает части текста разделеные разделителем.
//**path - текст в котором идет поиск.
//**separator - разделитель.
//**part - переменная которая возвращает куски текста
function GetPartOfPath(out part:String;var path:String;const separator:String):String;

procedure FromDirIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer=nil);
procedure FromDirsIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer=nil);
var ProgramPath,SupportPath,TempPath:String;
implementation
//uses log;
function FindInPaths(Paths,FileName:String):String;
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
     {if gdb.GetCurrentDWG<>nil then
     begin
                                   s:=ExtractFilePath(gdb.GetCurrentDWG.FileName)+filename;
     if FileExists(s) then
                                 begin
                                      result:=s;
                                      exit;
                                 end;
     end;}

     s:=Paths;
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
function FindInSupportPath(PPaths:String;FileName:String):String;
const
     cFindInSupportPath='[FILEOPS]FindInSupportPath: found file:"%s"';
var
   s,ts:String;
begin
     zTraceLn(sysutils.Format('[FILEOPS]FindInSupportPath: searh file:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
     FileName:=ExpandPath(FileName);
     zTraceLn(sysutils.Format('[FILEOPS]FindInSupportPath: file name expand to:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
     if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)) then
                                 begin
                                      result:=FileName;
                                      //programlog.LogOutStr(format(FindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)]),0,LM_Info);
                                      zTraceLn(sysutils.Format(cFindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
                                      exit;
                                 end;
     //if PPaths<>nil then
     begin
     s:=PPaths;
     repeat
           GetPartOfPath(ts,s,';');
           ts:=ExpandPath(ts);
           zTraceLn(sysutils.Format('[FILEOPS]FindInSupportPath: searh in "%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)]));
           ts:=ts+FileName;
           if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then
                                 begin
                                      result:=ts;
                                      zTraceLn(sysutils.Format(cFindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)]));
                                      exit;
                                 end;
     until s='';
     end;
     result:='';
     DebugLn(sysutils.Format('{E}FindInSupportPath: file not found:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
end;
function ExpandPath(path:String):String;
begin
  DefaultMacros.SubstituteMacros(path);
     if path='' then
                    result:=programpath
else if path[1]='*' then
                    result:=programpath+copy(path,2,length(path)-1)
else result:=path;
result:=StringReplace(result,'/', PathDelim,[rfReplaceAll, rfIgnoreCase]);
if DirectoryExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)) then
  if (result[length(result)]<>{'/'}PathDelim)
  //or (result[length(result)]<>'\')
  then
                                     result:=result+PathDelim;
end;
procedure FromDirsIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer);
var
   s,ts:String;
begin
     s:=path;
     repeat
           GetPartOfPath(ts,s,';');
           ts:=ExpandPath(ts);
           FromDirIterator(ts,mask,firstloadfilename,proc,method,pdata);
     until s='';
end;

procedure FromDirIterator(const path,mask,firstloadfilename:String;proc:TFromDirIterator;method:TFromDirIteratorObj;pdata:pointer);
var sr: TSearchRec;
    s:String;
procedure processfile(s:String);
var
   fn:String;
function IsASCII(const s: string): boolean; inline;
   var
     i: Integer;
   begin
     for i:=1 to length(s) do if ord(s[i])>127 then exit(false);
     Result:=true;
   end;
begin
     (*РАботало на xp,lin, перестало на 7х64*)
     fn:={systoutf8}({$IFNDEF DELPHI}systoutf8{$ENDIF}{Tria_AnsiToUtf8}(path)+{$IFNDEF DELPHI}systoutf8{$ENDIF}(s));

     (*попытка закостылить*
     {$IFNDEF DELPHI}if NeedRTLAnsi and (not IsASCII(path)) then{$ENDIF}
        fn:=Tria_AnsiToUtf8(path){$IFNDEF DELPHI}+systoutf8(s){$ELSE};{$ENDIF}
     {$IFNDEF DELPHI}else
         fn:=path+systoutf8(s);{$ENDIF}
     //fn:=fn+systoutf8(s);
     *конец попытки*)
     zTraceLn(sysutils.Format('{D}[FILEOPS]Process file %s',[fn]));
     //programlog.LogOutFormatStr('Process file %s',[fn],lp_OldPos,LM_Trace);
     if @method<>nil then
                         method(fn,pdata);
     if @proc<>nil then
                         proc(fn,pdata);

end;
begin
  zTraceLn('{D+}[FILEOPS]FromDirIterator start');
  //programlog.LogOutStr('FromDirIterator start',lp_IncPos,LM_Debug);
  if firstloadfilename<>'' then
  if fileexists(path+firstloadfilename) then
                                            processfile(firstloadfilename);
  if FindFirst(path + '*', faDirectory, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if DirectoryExists(path + sr.Name) then FromDirIterator(path + sr.Name + '/',mask,firstloadfilename,proc,method,pdata)
        else
        begin
          s:=lowercase(sr.Name);
          if s<>firstloadfilename then
          if MatchesMask(s,mask) then
                                        begin
                                             processfile(sr.Name);
                                        end;
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  zTraceLn('{D-}[FILEOPS]end; {FromDirIterator}');
  //programlog.LogOutStr('FromDirIterator....{end}',lp_DecPos,LM_Debug);
end;
initialization
  programpath:={$IFNDEF DELPHI}SysToUTF8{$ENDIF}(SysUtils.ExpandFileName(ExtractFilePath(paramstr(0))+'..\..\'));
  {$IfNDef DELPHI}
    TempPath:=GetTempDir;
  {$Else}
    TempPath:=GetEnvironmentVariable('TEMP');
  {$EndIf}
  if (TempPath[length(TempPath)]<>PathDelim)
   then
       TempPath:=TempPath+PathDelim;
end.
