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

unit uzcPathMacros;
{$INCLUDE zengineconfig.inc}
interface
uses
  MacroDefIntf,uzmacros,
  uzclog,uzblog,uzbpaths,Forms,uzcstrconsts,
  {$IFDEF WINDOWS}ShlObj,{$ENDIF}{$IFNDEF DELPHI}LazUTF8,{$ENDIF}sysutils,uzcsysvars;
type
  TZCADPathsMacroMethods=class
    class function MacroFuncZDataPath(const {%H-}Param: string; const Data: PtrInt;
                                        var {%H-}Abort: boolean): string;
    class function MacroFuncZBinPath(const {%H-}Param: string; const Data: PtrInt;
                                       var {%H-}Abort: boolean): string;
    class function MacroFuncDataSearhPrefixes(const {%H-}Param: string; const Data: PtrInt;
                                       var {%H-}Abort: boolean): string;
    class function MacroFuncZCADDictionariesPath(const {%H-}Param: string; const Data: PtrInt;
                                                 var {%H-}Abort: boolean): string;
    class function MacroFuncTEMPPath(const {%H-}Param: string; const Data: PtrInt;
                                       var {%H-}Abort: boolean): string;
    class function MacroFuncSystemFontsPath(const {%H-}Param: string; const Data: PtrInt;
                                              var {%H-}Abort: boolean): string;
    class function MacroFuncsUserFontsPath (const {%H-}Param: string; const Data: PtrInt;
                                              var {%H-}Abort: boolean): string;
    class function MacroFuncEnv(const Param: string; const {%H-}Data: PtrInt;
                                var {%H-}Abort: boolean): string;
    class function MacroFuncUserDir(const Param: string; const {%H-}Data: PtrInt;
                                    var {%H-}Abort: boolean): string;
    class function MacroFuncLocalConfigDir(const Param: string; const {%H-}Data: PtrInt;
                                           var {%H-}Abort: boolean): string;
    class function MacroFuncGlobalConfigDir(const Param: string; const {%H-}Data: PtrInt;
                                            var {%H-}Abort: boolean): string;
    class function MacroFuncAppName(const Param: string; const {%H-}Data: PtrInt;
                                    var {%H-}Abort: boolean): string;
    class function MacroFuncDirectorySeparator(const Param: string; const {%H-}Data: PtrInt;
                                               var {%H-}Abort: boolean): string;
  end;
implementation
class function TZCADPathsMacroMethods.MacroFuncZDataPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=DataPath;
end;
class function TZCADPathsMacroMethods.MacroFuncZBinPath(const {%H-}Param: string; const Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  result:=BinPath;
end;
class function TZCADPathsMacroMethods.MacroFuncZCADDictionariesPath(const {%H-}Param: string; const Data: PtrInt;
                                             var {%H-}Abort: boolean): string;
begin
  result:=DataPath+'/dictionaries';
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
class function TZCADPathsMacroMethods.MacroFuncEnv(const Param: string; const Data: PtrInt;var Abort: boolean): string;
begin
  Result:=GetEnvironmentVariableUTF8(Param);
end;
class function TZCADPathsMacroMethods.MacroFuncDataSearhPrefixes(const {%H-}Param: string; const Data: PtrInt;
                                   var {%H-}Abort: boolean): string;
begin
  Result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+Param)+';'+IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DataPath)+Param);
end;
class function TZCADPathsMacroMethods.MacroFuncUserDir(const Param: string; const {%H-}Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  Result:=GetUserDir;
end;
class function TZCADPathsMacroMethods.MacroFuncLocalConfigDir(const Param: string; const {%H-}Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  Result:=GetAppConfigDir(false);
end;
class function TZCADPathsMacroMethods.MacroFuncGlobalConfigDir(const Param: string; const {%H-}Data: PtrInt; var {%H-}Abort: boolean): string;
begin
  Result:=GetAppConfigDir(true);
end;
class function TZCADPathsMacroMethods.MacroFuncAppName(const Param: string; const {%H-}Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  Result:=programname;
end;
class function TZCADPathsMacroMethods.MacroFuncDirectorySeparator(const Param: string; const {%H-}Data: PtrInt;var {%H-}Abort: boolean): string;
begin
  Result:=DirectorySeparator;
end;

initialization
DefaultMacros.AddMacro(TTransferMacro.Create('ZBinPath','',
                       'Path to ZCAD binary',TZCADPathsMacroMethods.MacroFuncZBinPath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('ZDataPath','',
                       'Path to ZCAD data',TZCADPathsMacroMethods.MacroFuncZDataPath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('TEMP','',
                       'TEMP path',TZCADPathsMacroMethods.MacroFuncTEMPPath,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('ZCADDictionariesPath','',
                       'Dictionaries path',TZCADPathsMacroMethods.MacroFuncZCADDictionariesPath(),[]));
DefaultMacros.AddMacro(TTransferMacro.Create('SystemFontsPath','',
                       'System fonts path',TZCADPathsMacroMethods.MacroFuncSystemFontsPath(),[]));
DefaultMacros.AddMacro(TTransferMacro.Create('UserFontsPath','',
                       'User fonts path',TZCADPathsMacroMethods.MacroFuncsUserFontsPath(),[]));
DefaultMacros.AddMacro(TTransferMacro.Create('Env','',
                       'Environment variable, name as parameter',TZCADPathsMacroMethods.MacroFuncEnv,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('UserDir','',
                       'User directory',TZCADPathsMacroMethods.MacroFuncUserDir,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('LocalConfigDir','',
                       'Local config dir',TZCADPathsMacroMethods.MacroFuncLocalConfigDir,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('GlobalConfigDir','',
                       'Global config dir',TZCADPathsMacroMethods.MacroFuncGlobalConfigDir,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('DataSearhPrefixes','',
                       'Expand to data searh paths',TZCADPathsMacroMethods.MacroFuncDataSearhPrefixes,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('AppName','',
                       'Application name',TZCADPathsMacroMethods.MacroFuncAppName,[]));
DefaultMacros.AddMacro(TTransferMacro.Create('DirectorySeparator','',
                       'Directory separator',TZCADPathsMacroMethods.MacroFuncDirectorySeparator,[]));
end.
