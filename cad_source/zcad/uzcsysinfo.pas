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

unit uzcsysinfo;
{$INCLUDE zengineconfig.inc}
interface
uses
  MacroDefIntf,uzmacros,uzcsysparams,LCLProc,uzclog,uzblog,uzbpaths,Forms,
  {$IFDEF WINDOWS}ShlObj,{$ENDIF}{$IFNDEF DELPHI}LazUTF8,{$ENDIF}sysutils,uzcsysvars;
const
  zcaduniqueinstanceid='zcad unique instance';
  zcadgitversion = {$include zcadversion.inc};
type
  TZCADPathsMacroMethods=class
    class function MacroFuncZCADPath       (const {%H-}Param: string; const Data: PtrInt;
                                              var {%H-}Abort: boolean): string;
    class function MacroFuncZCADAutoSaveFilePath(const {%H-}Param: string; const Data: PtrInt;
                                                 var {%H-}Abort: boolean): string;
    class function MacroFuncTEMPPath       (const {%H-}Param: string; const Data: PtrInt;
                                              var {%H-}Abort: boolean): string;
    class function MacroFuncSystemFontsPath(const {%H-}Param: string; const Data: PtrInt;
                                              var {%H-}Abort: boolean): string;
    class function MacroFuncsUserFontsPath (const {%H-}Param: string; const Data: PtrInt;
                                              var {%H-}Abort: boolean): string;
  end;
var
  SysDefaultFormatSettings:TFormatSettings;
  disabledefaultmodule:boolean;

Procedure GetSysInfo;
implementation
function GetVersion:TmyFileVersionInfo;
var
  Major,Minor,Micro,Release:AnsiString;
  CommitsAfter,AbbreviatedName:AnsiString;
begin
  result.Major:=0;
  result.Minor:=0;
  result.Micro:=0;
  result.Release:=0;
  result.AbbreviatedName:='Unknown';

  AbbreviatedName:=zcadgitversion;
  GetPartOfPath(Major,AbbreviatedName,'.');
  GetPartOfPath(Minor,AbbreviatedName,'.');
  GetPartOfPath(Micro,AbbreviatedName,'.');
  GetPartOfPath(Release,AbbreviatedName,'-');
  GetPartOfPath(CommitsAfter,AbbreviatedName,'-');

  TryStrToInt(Major,result.major);
  TryStrToInt(Minor,result.Minor);
  TryStrToInt(Micro,result.Micro);
  TryStrToInt(Release,result.Release);
  TryStrToInt(CommitsAfter,result.CommitsAfter);
  if AbbreviatedName<>'' then
    result.AbbreviatedName:=AbbreviatedName;

  result.versionstring:=inttostr(result.Major)+'.'+inttostr(result.Minor)+'.'+inttostr(result.Micro)+'.'+inttostr(result.Release)+'-'+inttostr(result.CommitsAfter)+'-'+result.AbbreviatedName;
end;

procedure ProcessParamStr;
var
   i:integer;
   param,paramUC:String;
   ll:TLogLevel;
const
  LogEnableModulePrefix='LEM_';
  LogDisableModulePrefix='LDM_';
begin
     //programlog.LogOutStr('ProcessParamStr',lp_IncPos,LM_Necessarily);
     debugln('{N+}ProcessParamStr');
     SysParam.notsaved.otherinstancerun:=false;
     SysParam.saved.UniqueInstance:=true;
     LoadParams(expandpath(ProgramPath+'rtl/config.xml'),SysParam.saved);
     SysParam.notsaved.PreloadedFile:='';
     i:=paramcount;
     for i:=1 to paramcount do
       begin
            {$ifdef windows}param:={Tria_AnsiToUtf8}SysToUTF8(paramstr(i));{$endif}
            {$ifndef windows}param:=paramstr(i);{$endif}
            paramUC:=uppercase(param);

            debugln('{N}Found param command line parameter "%s"',[paramUC]);
            //programlog.LogOutStr(format('Found param command line parameter "%s"',[paramUC]),lp_OldPos,LM_Necessarily);

            if fileexists(UTF8toSys(param)) then
                                     SysParam.notsaved.PreloadedFile:=param
       else if (paramUC='NOTCHECKUNIQUEINSTANCE')or(paramUC='NCUI')then
                                                   SysParam.saved.UniqueInstance:=false
       else if (paramUC='NOSPLASH')or(paramUC='NS')then
                                                   SysParam.saved.NoSplash:=true
       else if (paramUC='VERBOSELOG')or(paramUC='VL')then
                                                          uzclog.VerboseLog:=true
       else if (paramUC='NOLOADLAYOUT')or(paramUC='NLL')then
                                                               SysParam.saved.NoLoadLayout:=true
       else if (paramUC='UPDATEPO')then
                                                               SysParam.saved.UpdatePO:=true
       else if (paramUC='LEAM')then
                                   programlog.EnableAllModules
       else if pos(LogEnableModulePrefix,paramUC)=1 then
                                       begin
                                         paramUC:=copy(paramUC,
                                                      length(LogEnableModulePrefix)+1,
                                                      length(paramUC)-length(LogEnableModulePrefix)+1);
                                         programlog.EnableModule(paramUC);
                                       end
       else if pos(LogDisableModulePrefix,paramUC)=1 then
                                       begin
                                         paramUC:=copy(paramUC,
                                                      length(LogEnableModulePrefix)+1,
                                                      length(paramUC)-length(LogEnableModulePrefix)+1);
                                         if paramUC<>'DEFAULT'then
                                           programlog.DisableModule(paramUC)
                                         else
                                           disabledefaultmodule:=true;
                                       end
       else if programlog.TryGetLogLevelHandle(param,ll)then
                                       programlog.SetCurrentLogLevel(ll);
       end;
     debugln('{N-}end;{ProcessParamStr}');
     //programlog.LogOutStr('end;{ProcessParamStr}',lp_DecPos,LM_Necessarily);
end;
Procedure GetSysInfo;
begin
     //programlog.LogOutStr('GetSysInfo',lp_IncPos,LM_Necessarily);
     debugln('{N+}GetSysInfo');
     SysDefaultFormatSettings:=DefaultFormatSettings;
     SysParam.notsaved.ScreenX:={GetSystemMetrics(SM_CXSCREEN)}Screen.Width;
     SysParam.notsaved.ScreenY:={GetSystemMetrics(SM_CYSCREEN)}Screen.Height;


     {SysParam.ScreenX:=800;
     SysParam.ScreenY:=800;}



     {$IFDEF FPC}
                 SysParam.notsaved.Ver:=GetVersion({'zcad.exe'});
     {$ELSE}
                 sysparam.ver:=GetVersion({'ZCAD.exe'});
     {$ENDIF}

     ProcessParamStr;
     //SysParam.verstr:=Format('%d.%d.%d.%d SVN: %s',[SysParam.Ver.major,SysParam.Ver.minor,SysParam.Ver.release,SysParam.Ver.build,RevisionStr]);
     debugln('{N}ZCAD log v'+sysparam.notsaved.ver.versionstring+' started');
{$IFDEF FPC}                 debugln('{N}Program compiled on Free Pascal Compiler');{$ENDIF}
{$IFDEF PERFOMANCELOG}       debugln('{N}Program compiled with {$DEFINE PERFOMANCELOG}');{$ENDIF}
{$IFDEF LOUDERRORS}debugln('{N}Program compiled with {$DEFINE LOUDERRORS}');{$ENDIF}
                             debugln('{N}DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage));
                             //programlog.logoutstr('DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage),0,LM_Necessarily);
                             debugln('{N}DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage));
                             //programlog.logoutstr('DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage),0,LM_Necessarily);
                             debugln('{N}UTF8CompareLocale:='+inttostr(UTF8CompareLocale));
                             //programlog.logoutstr('UTF8CompareLocale:='+inttostr(UTF8CompareLocale),0,LM_Necessarily);
                             {modeswitch systemcodepage}
     debugln('{N}SysParam.ProgramPath="%s"',[ProgramPath]);
     //programlog.LogOutStr(format('SysParam.ProgramPath="%s"',[ProgramPath]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.TempPath="%s"',[TempPath]);
     //programlog.LogOutStr(format('SysParam.TempPath="%s"',[TempPath]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.ScreenX=%d',[SysParam.notsaved.ScreenX]);
     //programlog.LogOutStr(format('SysParam.ScreenX=%d',[SysParam.ScreenX]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.ScreenY=%d',[SysParam.notsaved.ScreenY]);
     //programlog.LogOutStr(format('SysParam.ScreenY=%d',[SysParam.ScreenY]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.NoSplash=%s',[BoolToStr(SysParam.saved.NoSplash,true)]);
     //programlog.LogOutStr(format('SysParam.NoSplash=%s',[BoolToStr(SysParam.NoSplash,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.saved.NoLoadLayout,true)]);
     //programlog.LogOutStr(format('SysParam.NoLoadLayout=%s',[BoolToStr(SysParam.NoLoadLayout,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.UpdatePO=%s',[BoolToStr(SysParam.saved.UpdatePO,true)]);
     //programlog.LogOutStr(format('SysParam.UpdatePO=%s',[BoolToStr(SysParam.UpdatePO,true)]),lp_OldPos,LM_Necessarily);
     debugln('{N}SysParam.PreloadedFile="%s"',[SysParam.notsaved.PreloadedFile]);
     //programlog.LogOutStr(format('SysParam.PreloadedFile="%s"',[SysParam.PreloadedFile]),lp_OldPos,LM_Necessarily);

     debugln('{N-}end;{GetSysInfo}');
     //programlog.LogOutStr('end;{GetSysInfo}',lp_DecPos,LM_Necessarily);
     if disabledefaultmodule then programlog.DisableModule('DEFAULT');
end;
class function TZCADPathsMacroMethods.MacroFuncZCADPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=ProgramPath;
end;
class function TZCADPathsMacroMethods.MacroFuncZCADAutoSaveFilePath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^);
end;
class function TZCADPathsMacroMethods.MacroFuncTEMPPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=TempPath;
end;
class function TZCADPathsMacroMethods.MacroFuncSystemFontsPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
{$IF defined(WINDOWS)}
var
  s:string;
begin
  s:='';
  SetLength(s,MAX_PATH );
  if not SHGetSpecialFolderPath(0,PChar(s),CSIDL_FONTS,false) then
    s:='';
  Result:=PChar(s);
end;
{$ELSEIF (defined(LINUX))or(defined(DARWIN))}
begin
   Result:='/todo/';
end;
{$ENDIF}
class function TZCADPathsMacroMethods.MacroFuncsUserFontsPath (const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
{$IF defined(WINDOWS)}
var
  s: string;
begin
  s:='';
  SetLength(s,MAX_PATH );
  if not SHGetSpecialFolderPath(0,PChar(s),CSIDL_LOCAL_APPDATA,false) then
    s:='';
  Result:=PChar(s)+'\Microsoft\Windows\Fonts';
end;
{$ELSEIF (defined(LINUX))or(defined(DARWIN))}
begin
   Result:='/todo/';
end;
{$ENDIF}
initialization
GetSysInfo;
DefaultMacros.AddMacro(TTransferMacro.Create('ZCADPath','',
                       'Path to ZCAD',TZCADPathsMacroMethods.MacroFuncZCADPath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('ZCADAutoSaveFilePath','',
                       'Path to auto save file',TZCADPathsMacroMethods.MacroFuncZCADAutoSaveFilePath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('TEMP','',
                       'TEMP path',TZCADPathsMacroMethods.MacroFuncTEMPPath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('SystemFontsPath','',
                       'System fonts path',TZCADPathsMacroMethods.MacroFuncSystemFontsPath(),[]));
DefaultMacros.AddMacro(TTransferMacro.Create('UserFontsPath','',
                       'User fonts path',TZCADPathsMacroMethods.MacroFuncsUserFontsPath(),[]));
disabledefaultmodule:=false;
end.
