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

unit log;
{$INCLUDE def.inc}
interface
uses gdbasetypes,LazLoggerBase,LazLogger;
const {$IFDEF DELPHI}filelog='log/zcad_delphi.log';{$ENDIF}
      {$IFDEF FPC}
                  {$IFDEF LINUX}filelog='log/zcad_linux.log';{$ENDIF}
                  {$IFDEF WINDOWS}filelog='log/zcad_windows.log';{$ENDIF}
      {$ENDIF}
      lp_IncPos=1;
      lp_DecPos=-lp_IncPos;
      lp_OldPos=0;

      tsc2ms=2000;
const
      MaxLatestLogStrings=99;
type
TLogMode=(
          LM_Trace,  // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
          LM_Debug,  // — журналирование моментов вызова «крупных» операций.
          LM_Info,   // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
          LM_Warning,// — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
          LM_Error,  // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
          LM_Fatal,   // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
          LM_Necessarily   // — Вывод в любом случае
         );
//SplashWnd
TSplashTextOutProc=procedure (s:string;pm:boolean);
THistoryTextOutProc=procedure (s:string);
PTMyTimeStamp=^TMyTimeStamp;
TMyTimeStamp=record
                   time:TDateTime;
                   rdtsc:int64;
end;
TLatestLogStrings=array of GDBSTring;

//PTDateTime=^TDateTime;
{EXPORT+}
ptlog=^tlog;
tlog={$IFNDEF DELPHI}packed{$ENDIF} object
           LogFileName:GDBString;
           FileHandle:cardinal;
           Indent:GDBInteger;
           LatestLogStrings:TLatestLogStrings;
           LatestLogStringsCount,TotalLogStringsCount:GDBInteger;
           CurrentLogMode:TLogMode;
           constructor init(fn:GDBString;LogMode:TLogMode);
           procedure SetLogMode(LogMode:TLogMode);
           destructor done;
           procedure ProcessStrToLog(str:GDBString;IncIndent:GDBInteger;todisk:boolean);virtual;
           procedure ProcessStr(str:GDBString;IncIndent:GDBInteger);virtual;
           procedure LogOutStr(str:GDBString;IncIndent:GDBInteger;LogMode:TLogMode{=LM_Trace});virtual;
           procedure LogOutFormatStr(Const Fmt:GDBString;const Args :Array of const;IncIndent:GDBInteger;LogMode:TLogMode=LM_Trace);virtual;
           function IsNeedToLog(LogMode:TLogMode):boolean;
           procedure AddStrToLatest(str:GDBString);
           procedure WriteLatestToFile(var f:system.text);
           procedure LogOutStrFast(str:GDBString;IncIndent:GDBInteger);virtual;
           procedure WriteToLog(s:GDBString;todisk:boolean;t,dt:TDateTime;tick,dtick:int64;IncIndent:GDBInteger);virtual;
           procedure OpenLog;
           procedure CloseLog;
           procedure CreateLog;

           procedure ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
    end;
{EXPORT-}
function getprogramlog:GDBPointer;export;
//procedure startup(s:GDBString);
procedure LogOut(s:GDBString);
var programlog:tlog;
   //SplashWnd
   SplashTextOut:TSplashTextOutProc;
   HistoryTextOut:THistoryTextOutProc;
implementation
uses
    UGDBOpenArrayOfByte,UGDBOpenArrayOfData,strutils,sysutils{$IFNDEF DELPHI},fileutil{$ENDIF};
var
    PerfomaneBuf:GDBOpenArrayOfByte;
    TimeBuf:GDBOpenArrayOfData;
    function LogMode2string(LogMode:TLogMode):GDBString;
    begin
      case LogMode of
                     LM_Trace:result:='LM_Trace';
                     LM_Debug:result:='LM_Debug';
                     LM_Info:result:='LM_Info';
                     LM_Warning:result:='LM_Warning';
                     LM_Error:result:='LM_Error';
                     LM_Fatal:result:='LM_Fatal';
                     else
                         result:='LM_Unknown';
      end;
    end;
procedure LogOut(s:GDBString);
var
   FileHandle:cardinal;
   logname:string;
begin
     if assigned(SplashTextOut) then
                                   SplashTextOut(s,true);
     logname:={$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)))+filelog+'hard';
     FileHandle:=0;
     if not fileexists({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logname)) then
                                   FileHandle:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logname))
                                else
                                    FileHandle := FileOpen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logname), fmOpenWrite);
     FileSeek(FileHandle, 0, 2);

        s:=s+#13#10;
        FileWrite(FileHandle,s[1],length(s));

     fileclose(FileHandle);
     FileHandle:=0;
end;
function getprogramlog:GDBPointer;
begin
     result:=@programlog;
end;
function MyTimeToStr(MyTime:TDateTime):string;
var
    Hour,Minute,Second,MilliSecond:word;
begin
     decodetime(MyTime,Hour,Minute,Second,MilliSecond);
     if hour<>0 then
                    result:=Format('%.2d:', [hour]);
                            // inttostr(hour)+':';
     if Minute<>0 then
                    result:=result+Format('%.2d:', [minute]);
                                   //inttostr(minute,2)+':';
     if Second<>0 then
                    result:=result+Format('%.2d.', [Second]);
                                  //inttostr(Second,2)+'.';
     //if MilliSecond<>0 then
                    result:=result+Format('%.3d', [MilliSecond]);
                                   //inttostr(MilliSecond,3);

end;

procedure tlog.WriteToLog;
var ts:gdbstring;
begin
  ts:=TimeToStr(Time)+{'|'+}DupeString(' ',Indent*2);
  if todisk then ts :='!!!! '+ts +s
            else ts :=IntToHex(PerfomaneBuf.Count,4)+' '+ts +s;
  ts:=ts+DupeString('-',80-length(ts));
  //decodetime(t,Hour,Minute,Second,MilliSecond);
  ts := ts +' t:=' + {inttostr(round(t*10e7))}MyTimeToStr(t) + ', dt:=' + {inttostr(round(dt*10e7))}MyTimeToStr(dt) {+#13+#10};
  ts := ts +' tick:=' + inttostr(tick div tsc2ms) + ', dtick:=' + inttostr(dtick div tsc2ms)+#13+#10;
  if (Indent=1)and(IncIndent<0) then ts:=ts+#13+#10;
  PerfomaneBuf.TXTAddGDBString(ts);
  //FileWrite(FileHandle,ts[1],length(ts));
  if todisk then
  begin
        OpenLog;
        FileWrite(FileHandle,PerfomaneBuf.parray^,PerfomaneBuf.count);
        PerfomaneBuf.Clear;
        CloseLog;
  end;
end;
procedure tlog.OpenLog;
begin
  FileHandle := FileOpen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename), fmOpenWrite);
  FileSeek(FileHandle, 0, 2);
end;

procedure tlog.CloseLog;
begin
  fileclose(FileHandle);
  FileHandle:=0;
end;
procedure tlog.CreateLog;
begin
  FileHandle:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename){,fmOpenWrite});
  CloseLog;
end;
{procedure tlog.logout;
begin
     logoutstr(str,IncIndent);
end;}
(*function RDTSC: comp;
var
  TimeStamp: record
    case byte of
      1: (Whole: comp);
      2: (Lo, Hi: Longint);
  end;
begin
  asm
    db $0F; db $31;
  {$ifdef Cpu386}
    mov [TimeStamp.Lo], eax
    mov [TimeStamp.Hi], edx
  {$else}
    db D32
    mov word ptr TimeStamp.Lo, AX   dfg
    db D32
    mov word ptr TimeStamp.Hi, DX
  {$endif}
  end;
  Result := TimeStamp.Whole;
end;*)
function mynow:TMyTimeStamp;
var a:int64;
begin
     result.time:=now();
     asm
        rdtsc
        mov dword ptr [a],eax
        mov dword ptr [a+4],edx
     end;
     result.rdtsc:=a;
end;

procedure tlog.processstrtolog;
var
   CurrentTime:TMyTimeStamp;
   DeltaTime,FromStartTime:TDateTime;
   tick,dtick:int64;

begin
     CurrentTime:=mynow();

     if timebuf.Count>0 then
                            begin
                                 FromStartTime:=CurrentTime.time-PTMyTimeStamp(TimeBuf.getelement(0))^.time;
                                 DeltaTime:=CurrentTime.time-PTMyTimeStamp(TimeBuf.getelement(timebuf.Count-1))^.time;
                                 tick:=CurrentTime.rdtsc-PTMyTimeStamp(TimeBuf.getelement(0))^.rdtsc;
                                 dtick:=CurrentTime.rdtsc-PTMyTimeStamp(TimeBuf.getelement(timebuf.Count-1))^.rdtsc;
                            end
                        else
                            begin
                                  FromStartTime:=0;
                                  DeltaTime:=0;
                                  tick:=0;
                                  dtick:=0;
                            end;
     if IncIndent=0 then
                      begin
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,tick,dtick,IncIndent);
                      end
else if IncIndent>0 then
                      begin
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,tick,dtick,IncIndent);
                           inc(Indent,IncIndent);

                           timebuf.Add(@CurrentTime);
                      end
                  else
                      begin
                           inc(Indent,IncIndent);
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,tick,dtick,IncIndent);

                           dec(timebuf.Count);
                      end;
end;
procedure tlog.WriteLatestToFile(var f:system.text);
var
   currentindex,LatestLogArraySize:integer;
begin
     if TotalLogStringsCount=0 then exit;
     LatestLogArraySize:=Low(LatestLogStrings);
     LatestLogArraySize:=High(LatestLogStrings);
     LatestLogArraySize:=High(LatestLogStrings)-Low(LatestLogStrings)+1;
     if TotalLogStringsCount>LatestLogArraySize then
                                                    currentindex:=LatestLogStringsCount
                                                else
                                                    currentindex:=Low(LatestLogStrings);
     if TotalLogStringsCount<LatestLogArraySize then
                                                    LatestLogArraySize:=TotalLogStringsCount;
     repeat
       if currentindex>High(LatestLogStrings) then
                                                  currentindex:=Low(LatestLogStrings);
       WriteLn(f,pchar(@programlog.LatestLogStrings[currentindex][1]));
       inc(currentindex);
       dec(LatestLogArraySize);
     until LatestLogArraySize=0;
end;

procedure tlog.AddStrToLatest(str:GDBString);
var
   i:integer;
begin
     if LatestLogStringsCount>High(LatestLogStrings) then
                                                         LatestLogStringsCount:=Low(LatestLogStrings);
     LatestLogStrings[LatestLogStringsCount]:=str;
     inc(TotalLogStringsCount);
     inc(LatestLogStringsCount);
end;
function tlog.IsNeedToLog(LogMode:TLogMode):boolean;
begin
     if LogMode<CurrentLogMode then
                                   result:=false
                               else
                                   result:=true;
end;
procedure tlog.LogOutFormatStr(Const Fmt:GDBString;const Args :Array of const;IncIndent:GDBInteger;LogMode:TLogMode=LM_Trace);
begin
     if IsNeedToLog(LogMode) then
                                 ProcessStr(format(fmt,args),IncIndent);
end;
procedure tlog.ProcessStr(str:GDBString;IncIndent:GDBInteger);
begin
     if (Indent=0) then
                    if assigned(SplashTextOut) then
                                                  SplashTextOut(str,false);
     ProcessStrToLog(str,IncIndent,true);
     AddStrToLatest('  '+str);
end;
procedure tlog.logoutstr;
begin
     if IsNeedToLog(LogMode) then
                                 ProcessStr(str,IncIndent);
end;
procedure tlog.LogOutStrFast;
begin
     //if (str='TOGLWnd.Pre_MouseMove----{end}')and(Indent=3) then
     //               indent:=3;
     if PerfomaneBuf.Count<1024 then
                                    ProcessStrToLog(str,IncIndent,false)
                                else
                                    ProcessStrToLog(str,IncIndent,true);
end;
procedure tlog.SetLogMode(LogMode:TLogMode);
var
   CurrentTime:TMyTimeStamp;
begin
     if CurrentLogMode<>LogMode then
                                    begin
                                         CurrentTime:=mynow();
                                         CurrentLogMode:=LogMode;
                                         WriteToLog('Log mode changed to: '+LogMode2string(LogMode),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
                                    end;
end;

constructor tlog.init;
var
   CurrentTime:TMyTimeStamp;
   lz:TLazLogger;
begin
     CurrentLogMode:=LogMode;
     CurrentTime:=mynow();
     logfilename:=fn;
     PerfomaneBuf.init({$IFDEF DEBUGBUILD}'{39063C66-9D18-4707-8AD3-97DFBCB23185}',{$ENDIF}5*1024);
     TimeBuf.init({$IFDEF DEBUGBUILD}'{6EE1BC6B-1177-40B0-B4A5-793D66BF8BC8}',{$ENDIF}50,sizeof({TDateTime}TMyTimeStamp));
     Indent:=1;
     CreateLog;
     WriteToLog('------------------------Log started------------------------',true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
     WriteToLog('Log mode: '+LogMode2string(CurrentLogMode),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
     timebuf.Add(@CurrentTime);
     setlength(LatestLogStrings,MaxLatestLogStrings);
     LatestLogStringsCount:=0;
     TotalLogStringsCount:=0;
     lz:=GetDebugLogger;
     if assigned(lz)then
       if lz is TLazLoggerFile then
         begin
              TLazLoggerFile(lz).OnDebugLn:=ZOnDebugLN;
              TLazLoggerFile(lz).OnDbgOut:=ZOnDebugLN;
         end;
end;
procedure tlog.ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
var
   dbgmode:TLogMode;
   _indent:GDBInteger;
   prefixlength:integer;
   needtohistory:boolean;
begin
     dbgmode:=LM_Info;
     _indent:=lp_OldPos;
     needtohistory:=false;
     if s[1]='{' then
     if length(s)>1 then
     begin
        prefixlength:=2;
        while (s[prefixlength]<>'}')and(prefixlength<=length(s)) do
        begin
             case s[prefixlength] of
                'T':dbgmode:=LM_Trace;
                'D':dbgmode:=LM_Debug;
                'I':dbgmode:=LM_Info;
                'W':dbgmode:=LM_Warning;
                'F':dbgmode:=LM_Fatal;
                'N':dbgmode:=LM_Necessarily;
                '+':_indent:=lp_IncPos;
                '-':_indent:=lp_DecPos;
                'H':needtohistory:=true;
             end;
          inc(prefixlength);
        end;
        s:=copy(s,prefixlength+1,length(s)-prefixlength);
     end;
     if needtohistory then
       if assigned(HistoryTextOut) then
         HistoryTextOut(s);
     if IsNeedToLog(dbgmode) then
      LogOutStr(S,_indent,dbgmode);
end;

destructor tlog.done;
var
   CurrentTime:TMyTimeStamp;
begin
     CurrentTime:=mynow();
     WriteToLog('-------------------------Log ended-------------------------',true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
     PerfomaneBuf.done;
     TimeBuf.done;
     setlength(LatestLogStrings,0);
end;
initialization
begin
    programlog.init({$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)))+filelog,LM_Error);
end;
end.

