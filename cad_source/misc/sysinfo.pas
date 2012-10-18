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
uses gdbasetypes,Forms,gdbase,fileutil;
{$INCLUDE revision.inc}
type tsysparam=record
                     programpath: GDBString;
                     temppath: GDBString;
                     screenx,screeny:GDBInteger;
                     ver:TmyFileVersionInfo;
                     nosplash,noloadlayout,updatepo,standartinterface:GDBBoolean;
              end;
var
  sysparam: tsysparam;

Procedure getsysinfo;
implementation

uses {shared,varmandef,} sysutils,WindowsSpecific,log;
procedure ProcessParanstr;
var
   i:integer;
   param:GDBString;
begin
     i:=paramcount;
     for i:=1 to paramcount do
       begin
            param:=uppercase(paramstr(i));

            if (param='NOSPLASH')or(param='NS')then
                                                   sysparam.nosplash:=true;
            if (param='NOLOADLAYOUT')or(param='NLL')then
                                                               sysparam.noloadlayout:=true;
            if (param='STANDARTINTERFACE')or(param='SI')then
                                                               sysparam.standartinterface:=true;
            if (param='UPDATEPO')then
                                                               sysparam.updatepo:=true;
       end;
end;
Procedure getsysinfo;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('sysinfo.getsysinfo');{$ENDIF}
     sysparam.programpath:=SysToUTF8(ExtractFilePath(paramstr(0)));
     sysparam.screenx:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     sysparam.screeny:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;
     //sysparam.temppath:=GetEnvironmentVariable('TEMP');
     sysparam.temppath:=gettempdir;
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
