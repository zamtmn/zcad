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
uses gdbasetypes,Forms,gdbase;
{$INCLUDE revision.inc}
type tsysparam=record
                     programpath: GDBString;
                     temppath: GDBString;
                     screenx,screeny:GDBInteger;
                     ver:TmyFileVersionInfo;
              end;
var
  sysparam: tsysparam;
implementation
uses {shared,varmandef,} sysutils,WindowsSpecific,log;
begin
     {$IFDEF DEBUGINITSECTION}log.LogOut('sysinfo.initialization');{$ENDIF}
     sysparam.programpath := ExtractFilePath(paramstr(0));
     sysparam.screenx:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     sysparam.screeny:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;
     //sysparam.temppath:=GetEnvironmentVariable('TEMP');
     sysparam.temppath:=sysutils.GetEnvironmentVariable('TEMP');
     //setlength(sysparam.temppath,GetEnvironmentVariable('TEMP',nil,0)-1);
     if sysparam.temppath='' then
                                 begin
                                      sysparam.temppath:=sysutils.GetEnvironmentVariable('TMP');
                                      if sysparam.temppath='' then
                                                                  sysparam.temppath:=sysparam.programpath+'autosave'+PathDelim;
                                 end;
     if (sysparam.temppath[length(sysparam.temppath)]<>{'/'}PathDelim)
     {or (sysparam.temppath[length(sysparam.temppath)]<>'\')} then
                                                              sysparam.temppath:=sysparam.temppath+PathDelim;


     {sysparam.screenx:=800;
     sysparam.screeny:=800;}



     {$IFDEF FPC}
                 sysparam.ver:=GetVersion('zcad_fpc.exe');
     {$ELSE}
                 sysparam.ver:=GetVersion('ZCAD.exe');
     {$ENDIF}
     //sysparam.verstr:=Format('%d.%d.%d.%d SVN: %s',[sysparam.ver.major,sysparam.ver.minor,sysparam.ver.release,sysparam.ver.build,RevisionStr]);
end.
