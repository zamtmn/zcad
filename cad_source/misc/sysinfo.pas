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

unit SysInfo;
{$INCLUDE def.inc}
interface
uses paths,zcadstrconsts,gdbasetypes,Forms,gdbase{$IFNDEF DELPHI},fileutil{$ENDIF},zcadsysvars,sysutils;
{$INCLUDE revision.inc}
type
  tsysparam=record
                     programpath: GDBString;
                     temppath: GDBString;
                     screenx,screeny:GDBInteger;
                     defaultheight:GDBInteger;
                     ver:TmyFileVersionInfo;
                     nosplash,noloadlayout,updatepo,standartinterface,otherinstancerun:GDBBoolean;
                     preloadedfile:GDBString;
              end;
var
  sysparam: tsysparam;
  SysDefaultFormatSettings:TFormatSettings;

Procedure getsysinfo;
implementation
uses {WindowsSpecific,}log;
function GetVersion(_file:pchar):TmyFileVersionInfo;
var
 (*VerInfoSize, Dummy: DWord;
 PVerBbuff, PFixed : GDBPointer;
 FixLength : UINT;*)

  i: Integer;
  //Version: TFileVersionInfo;
  {MyFile,} MyVersion,ts: GDBString;

begin
     result.build:=0;
     result.major:=0;
     result.minor:=0;
     result.release:=0;

     {Version:=TFileVersionInfo.create(Nil);
     Version.fileName:=_file;

     With Version do begin
       For i:=0 to VersionStrings.Count-1 do begin
         If VersionCategories[I]='FileVersion' then
         begin
           MyVersion := VersionStrings[i];
           break;
         end;
       end;
     end;}

     result.major:=0;
     result.minor:=9;
     result.release:=8;

     MyVersion:=inttostr(result.major)+'.'+inttostr(result.minor)+'.'+inttostr(result.release)+' '+rsRevStr+RevisionStr;
     result.versionstring:=MyVersion;

     val(RevisionStr,result.revision,i);


(* fillchar(result,sizeof(result),0);
 VerInfoSize := GetFileVersionInfoSize(_file, Dummy);
 if VerInfoSize = 0 then Exit;
 GetMem(PVerBbuff, VerInfoSize);
 try
   if GetFileVersionInfo(_file,0,VerInfoSize,PVerBbuff) then
   begin
     if VerQueryValue(PVerBbuff,'\',PFixed,FixLength) then
     begin
       result.major:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionMS).Hi;
       result.minor:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionMS).Lo;
       result.release:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionLS).Hi;
       result.build:=LongRec(PVSFixedFileInfo(PFixed)^.dwFileVersionLS).Lo;
     end;
   end;
 finally
   FreeMem(PVerBbuff);
 end;*)
end;

procedure ProcessParanstr;
var
   i:integer;
   param,paramUC:GDBString;
begin
     sysparam.otherinstancerun:=false;
     sysparam.preloadedfile:='';
     i:=paramcount;
     for i:=1 to paramcount do
       begin
            {$ifdef windows}param:={Tria_AnsiToUtf8}SysToUTF8(paramstr(i));{$endif}
            {$ifndef windows}param:=paramstr(i);{$endif}
            paramUC:=uppercase(param);

            if fileexists(UTF8toSys(param)) then
                                     sysparam.preloadedfile:=param;
            if (paramUC='NOSPLASH')or(paramUC='NS')then
                                                   sysparam.nosplash:=true;
            if (paramUC='NOLOADLAYOUT')or(paramUC='NLL')then
                                                               sysparam.noloadlayout:=true;
            if (paramUC='STANDARTINTERFACE')or(paramUC='SI')then
                                                               sysparam.standartinterface:=true;
            if (paramUC='UPDATEPO')then
                                                               sysparam.updatepo:=true;
       end;
end;
Procedure getsysinfo;
begin
     SysDefaultFormatSettings:=DefaultFormatSettings;
     {$IFDEF DEBUGINITSECTION}log.LogOut('sysinfo.getsysinfo');{$ENDIF}
     sysparam.programpath:=programpath;
     sysparam.screenx:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     sysparam.screeny:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;
     sysparam.temppath:=GetEnvironmentVariable('TEMP');
     {$IFNDEF DELPHI}sysparam.temppath:=gettempdir;{$ENDIF}
     if (sysparam.temppath[length(sysparam.temppath)]<>PathDelim)
      then
          sysparam.temppath:=sysparam.temppath+PathDelim;


     {sysparam.screenx:=800;
     sysparam.screeny:=800;}



     {$IFDEF FPC}
                 sysparam.ver:=GetVersion('zcad.exe');
     {$ELSE}
                 sysparam.ver:=GetVersion('ZCAD.exe');
     {$ENDIF}
     ProcessParanstr;
     //sysparam.verstr:=Format('%d.%d.%d.%d SVN: %s',[sysparam.ver.major,sysparam.ver.minor,sysparam.ver.release,sysparam.ver.build,RevisionStr]);
end;
end.
