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
  uzbCommandLineParser,uzcCommandLineParser,
  MacroDefIntf,uzmacros,uzcsysparams,
  uzclog,uzbLogTypes,uzblog,uzbpaths,Forms,
  {$IFDEF WINDOWS}ShlObj,{$ENDIF}{$IFNDEF DELPHI}LazUTF8,{$ENDIF}sysutils,uzcsysvars;
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
implementation
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
end.
