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

unit uzcsysparams;
{$INCLUDE def.inc}
interface
uses XMLConf,XMLPropStorage,LazConfigStorage,fileutil,
  LCLProc,uzclog,uzbpaths,uzbtypesbase,Forms,uzbtypes{$IFNDEF DELPHI},LazUTF8{$ENDIF},sysutils;
{$INCLUDE zcadrev.inc}
type
{EXPORT+}
  {REGISTERRECORDTYPE TmyFileVersionInfo}
  TmyFileVersionInfo=record
    major,minor,release,build,revision:GDBInteger;
    versionstring:GDBstring;
  end;
  {REGISTERRECORDTYPE tsavedparams}
  tsavedparams=record
    UniqueInstance:GDBBoolean;(*'Unique instance'*)
    NoSplash:GDBBoolean;(*'No splash screen'*)
    NoLoadLayout:GDBBoolean;(*'No load layout'*)
    UpdatePO:GDBBoolean;(*'Update PO file'*)
  end;
  {REGISTERRECORDTYPE tnotsavedparams}
  tnotsavedparams=record
    ScreenX:GDBInteger;(*'Screen X'*)(*oi_readonly*)
    ScreenY:GDBInteger;(*'Screen Y'*)(*oi_readonly*)
    otherinstancerun:GDBBoolean;(*'Other instance run'*)(*oi_readonly*)
    PreloadedFile:GDBString;(*'Preloaded file'*)(*oi_readonly*)
    Ver:TmyFileVersionInfo;(*'Version'*)(*oi_readonly*)
    DefaultHeight:GDBInteger;(*'Default controls height'*)(*oi_readonly*)
  end;
  ptsysparam=^tsysparam;
  {REGISTERRECORDTYPE tsysparam}
  tsysparam=record
    saved:tsavedparams;(*'Saved params'*)
    notsaved:tnotsavedparams;(*'Not saved params'*)(*oi_readonly*)
  end;
{EXPORT-}
const
  DefaultSavedParams:tsavedparams=(UniqueInstance:true;
                                   NoSplash:false;
                                   NoLoadLayout:false;
                                   UpdatePO:false);
var
  SysParam: tsysparam;

procedure SaveParams(xmlfile:string;var Params:tsavedparams);
procedure LoadParams(xmlfile:string;out Params:tsavedparams);
implementation
procedure SaveParamToConfig(Config: TConfigStorage; var Params:tsavedparams);
begin
  Config.AppendBasePath('Stage0Params/');
  Config.SetDeleteValue('UniqueInstance',Params.UniqueInstance,DefaultSavedParams.UniqueInstance);
  Config.SetDeleteValue('NoSplash',Params.NoSplash,DefaultSavedParams.NoSplash);
  Config.SetDeleteValue('NoLoadLayout',Params.NoLoadLayout,DefaultSavedParams.NoLoadLayout);
  Config.SetDeleteValue('UpdatePO',Params.UpdatePO,DefaultSavedParams.UpdatePO);
  Config.UndoAppendBasePath;
end;

procedure SaveParams(xmlfile:string;var Params:tsavedparams);
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
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
procedure LoadParams(xmlfile:string;out Params:tsavedparams);
var
  XMLConfig:TXMLConfig;
begin
  Params:=DefaultSavedParams;
  XMLConfig:=TXMLConfig.Create(nil);
  XMLConfig.Filename:=xmlfile;
  XMLConfig.OpenKey('Stage0Params');
  Params.UniqueInstance:=XMLConfig.GetValue('UniqueInstance',DefaultSavedParams.UniqueInstance);
  Params.NoSplash:=XMLConfig.GetValue('NoSplash',DefaultSavedParams.NoSplash);
  Params.NoLoadLayout:=XMLConfig.GetValue('NoLoadLayout',DefaultSavedParams.NoLoadLayout);
  Params.UpdatePO:=XMLConfig.GetValue('UpdatePO',DefaultSavedParams.UpdatePO);
  XMLConfig.CloseKey;
end;



end.
