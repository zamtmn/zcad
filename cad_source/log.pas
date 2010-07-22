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
uses gdbasetypes;
const {$IFDEF DELPHI}filelog='log/zcad_delphi.log';{$ENDIF}
      {$IFDEF FPC}
                  {$IFDEF LINUX}filelog='log/zcad_fpc_linux.log';{$ENDIF}
                  {$IFDEF WINDOWS}filelog='log/zcad_fpc_windows.log';{$ENDIF}
      {$ENDIF}
      lp_IncPos=1;
      lp_DecPos=-lp_IncPos;
      lp_OldPos=0;
type
PTDateTime=^TDateTime;
{EXPORT+}
ptlog=^tlog;
tlog=object
           LogFileName:GDBString;
           FileHandle:cardinal;
           Indent:GDBInteger;
           constructor init(fn:GDBString);
           destructor done;
           procedure ProcessStr(str:GDBString;IncIndent:GDBInteger;todisk:boolean);virtual;
           procedure LogOutStr(str:GDBString;IncIndent:GDBInteger);virtual;
           procedure LogOutStrFast(str:GDBString;IncIndent:GDBInteger);virtual;
           procedure WriteToLog(s:GDBString;todisk:boolean;t,dt:TDateTime;IncIndent:GDBInteger);virtual;
           procedure OpenLog;
           procedure CloseLog;
           procedure CreateLog;
    end;
{EXPORT-}
function getprogramlog:GDBPointer;export;
//procedure startup(s:GDBString);
procedure LogOut(s:GDBString);
var programlog:tlog;
implementation
uses
    splashwnd,sysinfo,UGDBOpenArrayOfByte,UGDBOpenArrayOfData,strutils,sysutils;
var
    PerfomaneBuf:GDBOpenArrayOfByte;
    TimeBuf:GDBOpenArrayOfData;
procedure LogOut(s:GDBString);
var
   FileHandle:cardinal;
begin
     FileHandle:=0;
     FileHandle := FileOpen(filelog, fmOpenWrite);
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
  ts := ts +s;
  ts:=ts+DupeString(' ',80-length(ts));
  //decodetime(t,Hour,Minute,Second,MilliSecond);
  ts := ts +' t:=' + {inttostr(round(t*10e7))}MyTimeToStr(t) + ', dt:=' + {inttostr(round(dt*10e7))}MyTimeToStr(dt) +#13+#10;
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
  FileHandle := FileOpen(logfilename, fmOpenWrite);
  FileSeek(FileHandle, 0, 2);
end;

procedure tlog.CloseLog;
begin
  fileclose(FileHandle);
  FileHandle:=0;
end;
procedure tlog.CreateLog;
begin
  //FileHandle:=FileCreate(logfilename,fmOpenWrite);
  //CloseLog;
end;
{procedure tlog.logout;
begin
     logoutstr(str,IncIndent);
end;}
procedure tlog.processstr;
var
   CurrentTime,DeltaTime,FromStartTime:TDateTime;

begin
     CurrentTime:=now();

     if timebuf.Count>0 then
                            begin
                                 FromStartTime:=CurrentTime-PTDateTime(TimeBuf.getelement(0))^;
                                 DeltaTime:=CurrentTime-PTDateTime(TimeBuf.getelement(timebuf.Count-1))^;
                            end
                        else
                            begin
                                  FromStartTime:=0;
                                  DeltaTime:=0;
                            end;
     if IncIndent=0 then
                      begin
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,IncIndent);
                      end
else if IncIndent>0 then
                      begin
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,IncIndent);
                           inc(Indent,IncIndent);

                           timebuf.Add(@CurrentTime);
                      end
                  else
                      begin
                           inc(Indent,IncIndent);
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,IncIndent);

                           dec(timebuf.Count);
                      end;
end;
procedure tlog.logoutstr;
begin
     if incindent>0 then
                    if assigned(SplashWindow) then
                                   SplashWindow.TXTOut(str);
     processstr(str,IncIndent,true);
end;
procedure tlog.LogOutStrFast;
begin
     processstr(str,IncIndent,false);
end;
constructor tlog.init;
var
   CurrentTime:TDateTime;
begin
     CurrentTime:=now();
     logfilename:=fn;
     PerfomaneBuf.init({$IFDEF DEBUGBUILD}'{39063C66-9D18-4707-8AD3-97DFBCB23185}',{$ENDIF}5*1024);
     TimeBuf.init({$IFDEF DEBUGBUILD}'{6EE1BC6B-1177-40B0-B4A5-793D66BF8BC8}',{$ENDIF}50,sizeof(TDateTime));
     Indent:=1;
     CreateLog;
     WriteToLog('------------------------Log started------------------------',false,CurrentTime,0,0);
     timebuf.Add(@CurrentTime);
end;
destructor tlog.done;
var
   CurrentTime:TDateTime;
begin
     CurrentTime:=now();
     WriteToLog('-------------------------Log ended-------------------------',true,CurrentTime,0,0);
     PerfomaneBuf.done;
     TimeBuf.done;
end;
initialization
begin
    {$IFDEF DEBUGINITSECTION}LogOut('log.initialization');{$ENDIF}
    programlog.init(sysparam.programpath+filelog);
end;
end.

