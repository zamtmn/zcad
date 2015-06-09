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
                     ProgramPath: GDBString;
                     TempPath: GDBString;
                     ScreenX,ScreenY:GDBInteger;
                     DefaultHeight:GDBInteger;
                     Ver:TmyFileVersionInfo;
                     NoSplash,NoLoadLayout,UpdatePO,StandartInterface,otherinstancerun:GDBBoolean;
                     PreloadedFile:GDBString;
              end;
var
  SysParam: tsysparam;
  SysDefaultFormatSettings:TFormatSettings;

Procedure GetSysInfo;
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

procedure ProcessParamStr;
var
   i:integer;
   param,paramUC:GDBString;
begin
     programlog.LogOutStr('ProcessParamStr',lp_IncPos,LM_Necessarily);
     SysParam.otherinstancerun:=false;
     SysParam.PreloadedFile:='';
     i:=paramcount;
     for i:=1 to paramcount do
       begin
            {$ifdef windows}param:={Tria_AnsiToUtf8}SysToUTF8(paramstr(i));{$endif}
            {$ifndef windows}param:=paramstr(i);{$endif}
            paramUC:=uppercase(param);

            programlog.LogOutStr(format('Found param command line parameter "%s"',[paramUC]),lp_OldPos,LM_Necessarily);

            if fileexists(UTF8toSys(param)) then
                                     SysParam.PreloadedFile:=param
       else if (paramUC='NOSPLASH')or(paramUC='NS')then
                                                   SysParam.NoSplash:=true
       else if (paramUC='NOLOADLAYOUT')or(paramUC='NLL')then
                                                               SysParam.NoLoadLayout:=true
       else if (paramUC='STANDARTINTERFACE')or(paramUC='SI')then
                                                               SysParam.StandartInterface:=true
       else if (paramUC='UPDATEPO')then
                                                               SysParam.UpdatePO:=true
       else if (paramUC='LM_TRACE')then
                                       programlog.SetLogMode(LM_Trace)
       else if (paramUC='LM_DEBUG')then
                                       programlog.SetLogMode(LM_Debug)
       else if (paramUC='LM_INFO')then
                                       programlog.SetLogMode(LM_Info)
       else if (paramUC='LM_WARNING')then
                                       programlog.SetLogMode(LM_Warning)
       else if (paramUC='LM_ERROR')then
                                       programlog.SetLogMode(LM_Error)
       else if (paramUC='LM_FATAL')then
                                       programlog.SetLogMode(LM_Fatal)
       end;
     programlog.LogOutStr('end;{ProcessParamStr}',lp_DecPos,LM_Necessarily);
end;
Procedure GetSysInfo;
begin
     programlog.LogOutStr('GetSysInfo',lp_IncPos,LM_Necessarily);
     SysDefaultFormatSettings:=DefaultFormatSettings;
     {$IFDEF DEBUGINITSECTION}log.LogOut('sysinfo.getsysinfo');{$ENDIF}
     SysParam.ProgramPath:=programpath;
     SysParam.ScreenX:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     SysParam.ScreenY:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;
     SysParam.TempPath:=GetEnvironmentVariable('TEMP');
     {$IFNDEF DELPHI}SysParam.TempPath:=gettempdir;{$ENDIF}
     if (SysParam.TempPath[length(SysParam.TempPath)]<>PathDelim)
      then
          SysParam.TempPath:=SysParam.TempPath+PathDelim;


     {SysParam.ScreenX:=800;
     SysParam.ScreenY:=800;}



     {$IFDEF FPC}
                 SysParam.Ver:=GetVersion('zcad.exe');
     {$ELSE}
                 sysparam.ver:=GetVersion('ZCAD.exe');
     {$ENDIF}

     ProcessParamStr;
     //SysParam.verstr:=Format('%d.%d.%d.%d SVN: %s',[SysParam.Ver.major,SysParam.Ver.minor,SysParam.Ver.release,SysParam.Ver.build,RevisionStr]);
     programlog.logoutstr('ZCAD log v'+sysparam.ver.versionstring+' started',0,LM_Necessarily);
{$IFDEF FPC}                 programlog.logoutstr('Program compiled on Free Pascal Compiler',0,LM_Necessarily); {$ENDIF}
{$IFDEF DEBUGBUILD}          programlog.LogOutStr('Program compiled with {$DEFINE DEBUGDUILD}',0,LM_Necessarily); {$ENDIF}
{$IFDEF PERFOMANCELOG}       programlog.logoutstr('Program compiled with {$DEFINE PERFOMANCELOG}',0,LM_Necessarily); {$ENDIF}
{$IFDEF BREACKPOINTSONERRORS}programlog.logoutstr('Program compiled with {$DEFINE BREACKPOINTSONERRORS}',0,LM_Necessarily); {$ENDIF}
                             {$if FPC_FULlVERSION>=20701}
                             programlog.logoutstr('DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage),0,LM_Necessarily);
                             programlog.logoutstr('DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage),0,LM_Necessarily);
                             programlog.logoutstr('UTF8CompareLocale:='+inttostr(UTF8CompareLocale),0,LM_Necessarily);
                             {modeswitch systemcodepage}
                             {$ENDIF}
     programlog.LogOutStr(format('SysParam.ProgramPath="%s"',[SysParam.ProgramPath]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.TempPath="%s"',[SysParam.TempPath]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.ScreenX=%d',[SysParam.ScreenX]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.ScreenY=%d',[SysParam.ScreenY]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.NoSplash=%s',[BoolToStr(SysParam.NoSplash,true)]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.NoLoadLayout,true)]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.UpdatePO=%s',[BoolToStr(SysParam.UpdatePO,true)]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.StandartInterface=%s',[BoolToStr(SysParam.StandartInterface,true)]),lp_OldPos,LM_Necessarily);
     programlog.LogOutStr(format('SysParam.PreloadedFile="%s"',[SysParam.PreloadedFile]),lp_OldPos,LM_Necessarily);

     programlog.LogOutStr('end;{GetSysInfo}',lp_DecPos,LM_Necessarily);
end;
initialization
GetSysInfo;
end.
