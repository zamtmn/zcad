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

unit uzcSysParams;
{$INCLUDE zengineconfig.inc}
interface
uses
  SysUtils,
  XMLConf,XMLPropStorage,LazConfigStorage,DOM,
  FileUtil,
  LCLProc,Forms{$IFNDEF DELPHI},LazUTF8{$ENDIF},
  uzcLog,uzbPaths;
type

  TmyFileVersionInfo=record
    Major,Minor,Micro,Release,CommitsAfter:Integer;
    AbbreviatedName:AnsiString;
    VersionString:AnsiString;
    ShortVersionString:AnsiString;
  end;

  TZCSavedParams=record
    UniqueInstance:Boolean;(*'Unique instance'*)
    NoSplash:Boolean;(*'No splash screen'*)
    NoLoadLayout:Boolean;(*'No load layout'*)
    UpdatePO:Boolean;(*'Update PO file'*)
    MemProfiling:Boolean;(*'Internal memory profiler'*)
    LangOverride:string;(*'Language override'*)
    DictionariesPath:string;(*'Dictionaries path'*)
    LastAutoSaveFile:string;(*'Last autosave file'*)
    PreferredDistribPath:String;(*'Path to distributive'*)
  end;

  TZCNotSavedParams=record
    ScreenX:Integer;(*'Screen X'*)(*oi_readonly*)
    ScreenY:Integer;(*'Screen Y'*)(*oi_readonly*)
    OtherInstanceRun:Boolean;(*'Other instance run'*)(*oi_readonly*)
    PreloadedFile:String;(*'Preloaded file'*)(*oi_readonly*)
    Ver:TmyFileVersionInfo;(*'Version'*)(*oi_readonly*)
    DefaultHeight:Integer;(*'Default controls height'*)(*oi_readonly*)
  end;

  TZCSysParams=record
    saved:TZCSavedParams;(*'Saved params'*)
    notsaved:TZCNotSavedParams;(*'Not saved params'*)(*oi_readonly*)
  end;
  PZCSysParams=^TZCSysParams;



const
  DefaultSavedParams:TZCSavedParams=(UniqueInstance:true;
                                   NoSplash:false;
                                   NoLoadLayout:false;
                                   UpdatePO:false;
                                   MemProfiling:false;
                                   LangOverride:'';
                                   DictionariesPath:'ru=$(ZCADDictionariesPath)/ru_RU.dic|en=$(ZCADDictionariesPath)/en_US.dic;$(ZCADDictionariesPath)/en_US_interface.dic|abbrv=$(ZCADDictionariesPath)/abbrv.dic';
                                   LastAutoSaveFile:'noAutoSaveFile';
                                   PreferredDistribPath:'sss');
  zcaduniqueinstanceid='zcad unique instance';
var
  ZCSysParams: TZCSysParams;

procedure SaveParams(xmlfile:string;var Params:TZCSavedParams);
procedure LoadParams(xmlfile:string;out Params:TZCSavedParams);
implementation
type
  TXMLConfigHelper=class helper for TXMLConfig
    function  GetAnsiValue(const APath: DOMString; const ADefault: AnsiString): AnsiString;
  end;

procedure SaveParamToConfig(Config: TConfigStorage; var Params:TZCSavedParams);
begin
  Config.AppendBasePath('Stage0Params/');
  Config.SetDeleteValue('UniqueInstance',Params.UniqueInstance,DefaultSavedParams.UniqueInstance);
  Config.SetDeleteValue('NoSplash',Params.NoSplash,DefaultSavedParams.NoSplash);
  Config.SetDeleteValue('NoLoadLayout',Params.NoLoadLayout,DefaultSavedParams.NoLoadLayout);
  Config.SetDeleteValue('UpdatePO',Params.UpdatePO,DefaultSavedParams.UpdatePO);
  Config.SetDeleteValue('MemProfiling',Params.MemProfiling,DefaultSavedParams.MemProfiling);
  Config.SetDeleteValue('LangOverride',Params.LangOverride,DefaultSavedParams.LangOverride);
  Config.SetDeleteValue('DictionariesPath',Params.DictionariesPath,DefaultSavedParams.DictionariesPath);
  Config.SetDeleteValue('LastAutoSaveFile',Params.LastAutoSaveFile,DefaultSavedParams.LastAutoSaveFile);
  Config.SetDeleteValue('PreferredDistribPath',Params.PreferredDistribPath,DefaultSavedParams.PreferredDistribPath);
  Config.UndoAppendBasePath;
end;

procedure SaveParams(xmlfile:string;var Params:TZCSavedParams);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  If FileExists(xmlfile) then
    DeleteFile(xmlfile);
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:=xmlfile;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      SaveParamToConfig(Config,Params);
    finally
      Config.Free;
    end;
    //не писать файл нельзя(когда все значения по умолчанию)
    //т.к. при не нахождении конфиг "по умолчанию" создан не будет,
    //но будет взят конфиг из дитрибутива
    XMLConfig.SaveToFile(xmlfile);
    //XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
function TXMLConfigHelper.GetAnsiValue(const APath: DOMString; const ADefault: AnsiString): AnsiString;
begin
  result:=AnsiString(GetValue(APath,DOMString(ADefault)));
end;

procedure LoadParams(xmlfile:string;out Params:TZCSavedParams);
var
  XMLConfig:TXMLConfig;
begin
  Params:=DefaultSavedParams;
  XMLConfig:=TXMLConfig.Create(nil);
  try
    try
    XMLConfig.Filename:=xmlfile;
    XMLConfig.OpenKey('Stage0Params');
    Params.UniqueInstance:=XMLConfig.GetValue('UniqueInstance',DefaultSavedParams.UniqueInstance);
    Params.NoSplash:=XMLConfig.GetValue('NoSplash',DefaultSavedParams.NoSplash);
    Params.NoLoadLayout:=XMLConfig.GetValue('NoLoadLayout',DefaultSavedParams.NoLoadLayout);
    Params.UpdatePO:=XMLConfig.GetValue('UpdatePO',DefaultSavedParams.UpdatePO);
    Params.MemProfiling:=XMLConfig.GetValue('MemProfiling',DefaultSavedParams.MemProfiling);
    Params.LangOverride:=XMLConfig.GetAnsiValue('LangOverride',DefaultSavedParams.LangOverride);
    Params.DictionariesPath:=XMLConfig.GetAnsiValue('DictionariesPath',DefaultSavedParams.DictionariesPath);
    Params.LastAutoSaveFile:=XMLConfig.GetAnsiValue('LastAutoSaveFile',DefaultSavedParams.LastAutoSaveFile);
    Params.PreferredDistribPath:=XMLConfig.GetAnsiValue('PreferredDistribPath',DefaultSavedParams.PreferredDistribPath);
    XMLConfig.CloseKey;
    except
      on E:Exception do
        ProgramLog.LogOutFormatStr('LoadParams: problem with load Stage0Params msg:"%s"',
          [E.Message],LM_Error,1,MO_SM or MO_SH);
    end;
  finally
  end;
  SetDistribPath(Params.PreferredDistribPath);
  XMLConfig.free;
end;



end.
