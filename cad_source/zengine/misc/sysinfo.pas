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
uses LCLProc,paths,zcadstrconsts,gdbasetypes,Forms,gdbase{$IFNDEF DELPHI},fileutil{$ENDIF},sysutils;
{$INCLUDE revision.inc}
type
  tsysparam=record
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
     //programlog.LogOutStr('ProcessParamStr',lp_IncPos,LM_Necessarily);
     debugln('{N+}ProcessParamStr');
     SysParam.otherinstancerun:=false;
     SysParam.PreloadedFile:='';
     i:=paramcount;
     for i:=1 to paramcount do
       begin
            {$ifdef windows}param:={Tria_AnsiToUtf8}SysToUTF8(paramstr(i));{$endif}
            {$ifndef windows}param:=paramstr(i);{$endif}
            paramUC:=uppercase(param);

            debugln('{N}Found param command line parameter "%s"',[paramUC]);
            //programlog.LogOutStr(format('Found param command line parameter "%s"',[paramUC]),lp_OldPos,LM_Necessarily);

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
     debugln('{N-}end;{ProcessParamStr}');
     programlog.LogOutStr('end;{ProcessParamStr}',lp_DecPos,LM_Necessarily);
end;
Procedure GetSysInfo;
begin
     //programlog.LogOutStr('GetSysInfo',lp_IncPos,LM_Necessarily);
     debugln('{N+}GetSysInfo');
     SysDefaultFormatSettings:=DefaultFormatSettings;
     {$IFDEF DEBUGINITSECTION}log.LogOut('sysinfo.getsysinfo');{$ENDIF}
     //SysParam.ProgramPath:=programpath;
     SysParam.ScreenX:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     SysParam.ScreenY:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;


     {SysParam.ScreenX:=800;
     SysParam.ScreenY:=800;}



     {$IFDEF FPC}
                 SysParam.Ver:=GetVersion('zcad.exe');
     {$ELSE}
                 sysparam.ver:=GetVersion('ZCAD.exe');
     {$ENDIF}

     ProcessParamStr;
     //SysParam.verstr:=Format('%d.%d.%d.%d SVN: %s',[SysParam.Ver.major,SysParam.Ver.minor,SysParam.Ver.release,SysParam.Ver.build,RevisionStr]);
     debugln('{N}ZCAD log v'+sysparam.ver.versionstring+' started');
     //programlog.logoutstr('ZCAD log v'+sysparam.ver.versionstring+' started',0,LM_Necessarily);
{$IFDEF FPC}                 debugln('{N}Program compiled on Free Pascal Compiler');{$ENDIF}
{$IFDEF DEBUGBUILD}          debugln('{N}Program compiled with {$DEFINE DEBUGDUILD}');{$ENDIF}
{$IFDEF PERFOMANCELOG}       debugln('{N}Program compiled with {$DEFINE PERFOMANCELOG}'){$ENDIF}
{$IFDEF BREACKPOINTSONERRORS}debugln('{N}Program compiled with {$DEFINE BREACKPOINTSONERRORS}');{$ENDIF}
                             {$if FPC_FULlVERSION>=20701}
                             debugln('{N}DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage));
                             //programlog.logoutstr('DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage),0,LM_Necessarily);
                             debugln('{N}DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage));
                             //programlog.logoutstr('DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage),0,LM_Necessarily);
                             debugln('{N}UTF8CompareLocale:='+inttostr(UTF8CompareLocale));
                             //programlog.logoutstr('UTF8CompareLocale:='+inttostr(UTF8CompareLocale),0,LM_Necessarily);
                             {modeswitch systemcodepage}
                             {$ENDIF}
     debugln('{N}SysParam.ProgramPath="%s"',[ProgramPath]);
     //programlog.LogOutStr(format('SysParam.ProgramPath="%s"',[ProgramPath]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.TempPath="%s"',[TempPath]);
     //programlog.LogOutStr(format('SysParam.TempPath="%s"',[TempPath]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.ScreenX=%d',[SysParam.ScreenX]);
     //programlog.LogOutStr(format('SysParam.ScreenX=%d',[SysParam.ScreenX]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.ScreenY=%d',[SysParam.ScreenY]);
     //programlog.LogOutStr(format('SysParam.ScreenY=%d',[SysParam.ScreenY]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.NoSplash=%s',[BoolToStr(SysParam.NoSplash,true)]);
     //programlog.LogOutStr(format('SysParam.NoSplash=%s',[BoolToStr(SysParam.NoSplash,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.NoLoadLayout,true)]);
     //programlog.LogOutStr(format('SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.NoLoadLayout,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.UpdatePO=%s',[BoolToStr(SysParam.UpdatePO,true)]);
     //programlog.LogOutStr(format('SysParam.UpdatePO=%s',[BoolToStr(SysParam.UpdatePO,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.StandartInterface=%s',[BoolToStr(SysParam.StandartInterface,true)]);
     //programlog.LogOutStr(format('SysParam.StandartInterface=%s',[BoolToStr(SysParam.StandartInterface,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.PreloadedFile="%s"',[SysParam.PreloadedFile]);
     //programlog.LogOutStr(format('SysParam.PreloadedFile="%s"',[SysParam.PreloadedFile]),lp_OldPos,LM_Necessarily);

     debugln('{N-}end;{GetSysInfo}');
     //programlog.LogOutStr('end;{GetSysInfo}',lp_DecPos,LM_Necessarily);
end;
initialization
GetSysInfo;
end.
