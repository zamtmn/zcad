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

unit paths;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses Masks,LCLProc,gdbasetypes{$IFNDEF DELPHI},fileutil{$ENDIF},sysutils;
type
  TFromDirIterator=procedure (filename:GDBString);
  TFromDirIteratorObj=procedure (filename:GDBString) of object;
function ExpandPath(path:GDBString):GDBString;
function FindInSupportPath(PPaths:GDBString;FileName:GDBString):GDBString;
function FindInPaths(Paths,FileName:GDBString):GDBString;
function GetPartOfPath(out part:GDBString;var path:GDBString;const separator:GDBString):GDBString;
procedure FromDirIterator(const path,mask,firstloadfilename:GDBSTring;proc:TFromDirIterator;method:TFromDirIteratorObj);
procedure FromDirsIterator(const path,mask,firstloadfilename:GDBString;proc:TFromDirIterator;method:TFromDirIteratorObj);
var ProgramPath,SupportPath,TempPath:gdbstring;
implementation
//uses log;
function FindInPaths(Paths,FileName:GDBString):GDBString;
var
   s,ts,ts2:gdbstring;
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
           GetPartOfPath(ts,s,'|');
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
function GetPartOfPath(out part:GDBString;var path:GDBString;const separator:GDBString):GDBString;
var
   i:GDBInteger;
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
function FindInSupportPath(PPaths:GDBString;FileName:GDBString):GDBString;
const
     FindInSupportPath='FindInSupportPath: found file:"%s"';
var
   s,ts:gdbstring;
begin
     {$IFDEF TOTALYLOG}
     DebugLn(sysutils.Format('FindInSupportPath: searh file:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
     {$ENDIF}
     //programlog.LogOutFormatStr('FindInSupportPath: searh file:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)],0,LM_Debug);
     FileName:=ExpandPath(FileName);
     {$IFDEF TOTALYLOG}
     DebugLn(sysutils.Format('FindInSupportPath: file name expand to:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
     {$ENDIF}
     //programlog.LogOutFormatStr('FindInSupportPath: file name expand to:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)],0,LM_Debug);
     if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)) then
                                 begin
                                      result:=FileName;
                                      //programlog.LogOutStr(format(FindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)]),0,LM_Info);
                                      {$IFDEF TOTALYLOG}
                                      DebugLn(sysutils.Format(FindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)]));
                                      {$ENDIF}
                                      exit;
                                 end;
     //if PPaths<>nil then
     begin
     s:=PPaths;
     repeat
           GetPartOfPath(ts,s,'|');
           ts:=ExpandPath(ts);
           {$IFDEF TOTALYLOG}
           DebugLn(sysutils.Format('FindInSupportPath: searh in "%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)]));
           {$ENDIF}
           //programlog.LogOutFormatStr('FindInSupportPath: searh in "%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)],0,LM_Debug);
           ts:=ts+FileName;
           if FileExists({$IFNDEF DELPHI}utf8tosys{$ENDIF}(ts)) then
                                 begin
                                      result:=ts;
                                      {$IFDEF TOTALYLOG}
                                      DebugLn(sysutils.Format(FindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)]));
                                      {$ENDIF}
                                      //programlog.LogOutStr(format(FindInSupportPath,[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(result)]),0,LM_Info);
                                      exit;
                                 end;
     until s='';
     end;
     result:='';
     {$IFDEF TOTALYLOG}
     DebugLn(sysutils.Format('FindInSupportPath: file not found:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]));
     {$ENDIF}
     //programlog.LogOutStr(format('FindInSupportPath: file not found:"%s"',[{$IFNDEF DELPHI}utf8tosys{$ENDIF}(FileName)]),0,LM_Warning);
end;
function ExpandPath(path:GDBString):GDBString;
begin
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
procedure FromDirsIterator(const path,mask,firstloadfilename:GDBString;proc:TFromDirIterator;method:TFromDirIteratorObj);
var
   s,ts:gdbstring;
begin
     s:=path;
     repeat
           GetPartOfPath(ts,s,'|');
           ts:=ExpandPath(ts);
           FromDirIterator(ts,mask,firstloadfilename,proc,method);
     until s='';
end;

procedure FromDirIterator(const path,mask,firstloadfilename:GDBSTring;proc:TFromDirIterator;method:TFromDirIteratorObj);
var sr: TSearchRec;
    s:gdbstring;
procedure processfile(s:gdbstring);
var
   fn:gdbstring;
function IsASCII(const s: string): boolean; inline;
   var
     i: Integer;
   begin
     for i:=1 to length(s) do if ord(s[i])>127 then exit(false);
     Result:=true;
   end;
begin
     (*РАботало на xp,lin, перестало на 7х64*)
     fn:={systoutf8}(systoutf8{Tria_AnsiToUtf8}(path)+systoutf8(s));

     (*попытка закостылить*
     {$IFNDEF DELPHI}if NeedRTLAnsi and (not IsASCII(path)) then{$ENDIF}
        fn:=Tria_AnsiToUtf8(path){$IFNDEF DELPHI}+systoutf8(s){$ELSE};{$ENDIF}
     {$IFNDEF DELPHI}else
         fn:=path+systoutf8(s);{$ENDIF}
     //fn:=fn+systoutf8(s);
     *конец попытки*)
     DebugLn(sysutils.Format('Process file %s',[fn]));
     //programlog.LogOutFormatStr('Process file %s',[fn],lp_OldPos,LM_Trace);
     if @method<>nil then
                         method(fn);
     if @proc<>nil then
                         proc(fn);

end;
begin
  DebugLn('FromDirIterator start');
  //programlog.LogOutStr('FromDirIterator start',lp_IncPos,LM_Debug);
  if firstloadfilename<>'' then
  if fileexists(path+firstloadfilename) then
                                            processfile(firstloadfilename);
  if FindFirst(path + '*', faDirectory, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if DirectoryExists(path + sr.Name) then FromDirIterator(path + sr.Name + '/',mask,firstloadfilename,proc,method)
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
  DebugLn('FromDirIterator....{end}');
  //programlog.LogOutStr('FromDirIterator....{end}',lp_DecPos,LM_Debug);
end;
initialization
  programpath:={$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)));
  TempPath:=GetEnvironmentVariable('TEMP');
  {$IFNDEF DELPHI}TempPath:=gettempdir;{$ENDIF}
  if (TempPath[length(TempPath)]<>PathDelim)
   then
       TempPath:=TempPath+PathDelim;
end.
