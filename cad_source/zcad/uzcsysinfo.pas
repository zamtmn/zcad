{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit uzcSysInfo;
{$INCLUDE zengineconfig.inc}
interface
uses
  uzbCommandLineParser,uzcCommandLineParser,
  uzeSysParams,uzcSysParams,uzcsysvars,
  {uzbLogTypes,}uzbLog,uzcLog,
  uzbPaths,uzcPathMacros,uzcFileStructure,
  Forms,{$IFNDEF DELPHI}LazUTF8,{$ENDIF}sysutils;
resourcestring
  rsCommandLine='Command line "%s"';
  rsFoundCLOption='Found command line option "%s"';
  rsFoundCLOperand='Found command line operand "%s"';
const
  zcadgitversion = {$include zcadversion.inc};
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
  result.major:=pos('-',AbbreviatedName);
  if pos('-',AbbreviatedName)>0 then begin
    GetPartOfPath(Release,AbbreviatedName,'-');
    GetPartOfPath(CommitsAfter,AbbreviatedName,'-');
  end else begin
    GetPartOfPath(Release,AbbreviatedName,' ');
    //GetPartOfPath(CommitsAfter,AbbreviatedName,'-');
  end;

  TryStrToInt(Major,result.major);
  TryStrToInt(Minor,result.Minor);
  TryStrToInt(Micro,result.Micro);
  TryStrToInt(Release,result.Release);
  TryStrToInt(CommitsAfter,result.CommitsAfter);
  if AbbreviatedName<>'' then
    result.AbbreviatedName:=AbbreviatedName;

  result.ShortVersionString:=inttostr(result.Major)+'.'+inttostr(result.Minor)+'.'+inttostr(result.Micro)+'.'+inttostr(result.Release);
  result.versionstring:=result.ShortVersionString+'-'+inttostr(result.CommitsAfter)+'-'+result.AbbreviatedName;
end;

procedure ProcessParamStr;
var
   i,prm,operandsc:integer;
   pod:PTCLOptionData;
   mn:String;
   //ll:TLogLevel;
begin
  with programlog.Enter('ProcessParamStr',LM_Info) do try

    //покажем в логе что распарсилось из командной строки
    programlog.LogOutFormatStr(rsCommandLine,[CmdLine],LM_Necessarily);
    for i:=0 to CommandLineParser.ParamsCount-1 do begin
      prm:=CommandLineParser.Param[i];
      if prm>0 then begin
        pod:=CommandLineParser.GetOptionPData(prm);
        case pod.&Type of
          AT_Flag:programlog.LogOutFormatStr(rsFoundCLOption,[CommandLineParser.GetOptionName(prm)],LM_Info);
          AT_WithOperands:begin
            operandsc:=CommandLineParser.OptionOperandsCount(prm);
            case operandsc of
              0:programlog.LogOutFormatStr(rsFoundCLOption,[CommandLineParser.GetOptionName(prm)],LM_Info);
              else programlog.LogOutFormatStr(rsFoundCLOption,[CommandLineParser.GetOptionName(prm)+' '+CommandLineParser.GetAllOptionOperands(prm)],LM_Info);
            end;
          end;
         end;
       end else if prm<0 then
         programlog.LogOutFormatStr(rsFoundCLOperand,[CommandLineParser.Operand[-prm-1]],LM_Info);
    end;

    //начальные значения некоторых параметров и загрузка параметров
    ZCSysParams.notsaved.otherinstancerun:=false;
    ZCSysParams.saved.UniqueInstance:=true;
    LoadParams(FindFileInCfgsPaths(CFSconfigsDir,CFSconfigxmlFile),ZCSysParams.saved);
    ZCSysParams.notsaved.PreloadedFile:='';

    //значения некоторых параметров из комстроки, если есть
    if CommandLineParser.HasOption(EXPERIMENTALFEATURESHDL) then
      ZESysParams.UseExperimentalFeatures:=true;
    if CommandLineParser.HasOption(NOSPLASHHDL) then
      ZCSysParams.saved.NoSplash:=true;
    if CommandLineParser.HasOption(MemProfiling) then
      ZCSysParams.saved.MemProfiling:=true;
    if CommandLineParser.HasOption(UPDATEPOHDL) then
      ZCSysParams.saved.UpdatePO:=true;
    if CommandLineParser.HasOption(NOLOADLAYOUTHDL) then
      ZCSysParams.saved.NoLoadLayout:=true;
    if CommandLineParser.HasOption(NOTCHECKUNIQUEINSTANCEHDL) then
      ZCSysParams.saved.UniqueInstance:=false;
    if CommandLineParser.HasOption(LEAMHDL) then
      programlog.EnableAllModules;
    if CommandLineParser.HasOption(LEMHDL)then
      for i:=0 to CommandLineParser.OptionOperandsCount(LEMHDL)-1 do
        programlog.EnableModule(CommandLineParser.OptionOperand(LEMHDL,i));
    if CommandLineParser.HasOption(LDMHDL)then
      for i:=0 to CommandLineParser.OptionOperandsCount(LDMHDL)-1 do begin
        mn:=CommandLineParser.OptionOperand(LDMHDL,i);
        if uppercase(mn)<>'DEFAULT'then
          programlog.DisableModule(mn)
        else
          disabledefaultmodule:=true;
      end;
    if CommandLineParser.HasOption(LEMMHDL)then
      for i:=0 to CommandLineParser.OptionOperandsCount(LEMMHDL)-1 do
        programlog.AddEnableModuleMask(CommandLineParser.OptionOperand(LEMMHDL,i));
    if CommandLineParser.HasOption(LDMMHDL)then
      for i:=0 to CommandLineParser.OptionOperandsCount(LDMMHDL)-1 do
        programlog.AddDisableModuleMask(CommandLineParser.OptionOperand(LDMMHDL,i));

    //операнды из комстроки, если есть - ищем файл для загрузки
    for i:=0 to CommandLineParser.OperandsCount-1 do begin
      mn:=CommandLineParser.Operand[i];
      if fileexists(UTF8toSys(mn)) then
        ZCSysParams.notsaved.PreloadedFile:=mn;
    end;

  finally programlog.leave(IfEntered);end;
end;
function ConfigsFilesExistChec(const ACheckedPath:string):boolean;
begin
  result:=DirectoryExists(ConcatPaths([ACheckedPath,CFSconfigsDir]))
      and FileExists(ConcatPaths([ACheckedPath,CFSconfigsDir,CFSsysvarpasFile]));
end;
function DistribFilesExistChec(const ACheckedPath:string):boolean;
begin
  result:=DirectoryExists(ConcatPaths([ACheckedPath,CFSrtlDir]))
      and DirectoryExists(ConcatPaths([ACheckedPath,CFSdictionariesDir]))
      and DirectoryExists(ConcatPaths([ACheckedPath,CFSlanguagesDir]))
      and FileExists(ConcatPaths([ACheckedPath,CFSlanguagesDir,CFSzcadpoFile]));
end;

Procedure GetSysInfo;
begin
  with programlog.Enter('GetSysInfo',LM_Info) do try

    SysDefaultFormatSettings:=DefaultFormatSettings;
    ZCSysParams.notsaved.ScreenX:=Screen.Width;
    ZCSysParams.notsaved.ScreenY:=Screen.Height;
    ZCSysParams.notsaved.Ver:=GetVersion;

    programlog.LogOutStr('ZCAD v'+ZCSysParams.notsaved.ver.versionstring,LM_Necessarily);
  {$IFDEF FPC}
    programlog.LogOutStr('Program compiled on Free Pascal Compiler',LM_Info);
  {$ENDIF}
  {$IFDEF LOUDERRORS}
    programlog.LogOutStr('Program compiled with {$DEFINE LOUDERRORS}',LM_Info);
  {$ENDIF}

    ProcessParamStr;

    programlog.LogOutStr('DefaultSystemCodePage:='+inttostr(DefaultSystemCodePage),LM_Info);
    programlog.LogOutStr('DefaultUnicodeCodePage:='+inttostr(DefaultUnicodeCodePage),LM_Info);
    programlog.LogOutStr('UTF8CompareLocale:='+inttostr(UTF8CompareLocale),LM_Info);

    programlog.LogOutFormatStr('SysParam.ScreenX=%d',[ZCSysParams.notsaved.ScreenX],LM_Info);
    programlog.LogOutFormatStr('SysParam.ScreenY=%d',[ZCSysParams.notsaved.ScreenY],LM_Info);
    programlog.LogOutFormatStr('SysParam.NoSplash=%s',[BoolToStr(ZCSysParams.saved.NoSplash,true)],LM_Info);
    programlog.LogOutFormatStr('SysParam.NoLoadLayout=%s',[BoolToStr(ZCSysParams.saved.NoLoadLayout,true)],LM_Info);
    programlog.LogOutFormatStr('SysParam.UpdatePO=%s',[BoolToStr(ZCSysParams.saved.UpdatePO,true)],LM_Info);
    programlog.LogOutFormatStr('SysParam.PreloadedFile="%s"',[ZCSysParams.notsaved.PreloadedFile],LM_Necessarily);

    if disabledefaultmodule then programlog.DisableModule('DEFAULT');

    with programlog.Enter('Macros',LM_Info) do try
      programlog.LogOutFormatStr('$(AppName)="%s"',[ExpandPath('$(AppName)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(BinaryPath)="%s"',[ExpandPath('$(BinaryPath)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(DistribPath)="%s"',[ExpandPath('$(DistribPath)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(RoCfgs)="%s"',[ExpandPath('$(RoCfgs)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(WrCfgs)="%s"',[ExpandPath('$(WrCfgs)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(UserDir)="%s"',[ExpandPath('$(UserDir)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(GlobalConfigDir)="%s"',[ExpandPath('$(GlobalConfigDir)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(LocalConfigDir)="%s"',[ExpandPath('$(LocalConfigDir)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(SystemFontsPath)="%s"',[ExpandPath('$(SystemFontsPath)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(UserFontsPath)="%s"',[ExpandPath('$(UserFontsPath)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(TEMP)="%s"',[ExpandPath('$(TEMP)')],LM_Necessarily);
      programlog.LogOutFormatStr('$(ZCADDictionariesPath)="%s"',[ExpandPath('$(ZCADDictionariesPath)')],LM_Necessarily);
    finally programlog.leave(IfEntered);end;

  finally programlog.leave(IfEntered);end;
end;
procedure FindData;
begin
  FindDistribPath(DistribFilesExistChec);
  FindConfigsPath(ConfigsFilesExistChec);
end;

initialization
  FindData;
  GetSysInfo;
end.
