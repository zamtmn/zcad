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

unit uzcsysparams;
{$INCLUDE zengineconfig.inc}
interface
uses XMLConf,XMLPropStorage,LazConfigStorage,fileutil,
  LCLProc,uzclog,uzbpaths,Forms{$IFNDEF DELPHI},LazUTF8{$ENDIF},sysutils;
type
{EXPORT+}
  {REGISTERRECORDTYPE TmyFileVersionInfo}
  TmyFileVersionInfo=record
    Major,Minor,Micro,Release,CommitsAfter:Integer;
    AbbreviatedName:AnsiString;
    VersionString:AnsiString;
  end;
  {REGISTERRECORDTYPE tsavedparams}
  tsavedparams=record
    UniqueInstance:Boolean;(*'Unique instance'*)
    NoSplash:Boolean;(*'No splash screen'*)
    NoLoadLayout:Boolean;(*'No load layout'*)
    UpdatePO:Boolean;(*'Update PO file'*)
  end;
  {REGISTERRECORDTYPE tnotsavedparams}
  tnotsavedparams=record
    ScreenX:Integer;(*'Screen X'*)(*oi_readonly*)
    ScreenY:Integer;(*'Screen Y'*)(*oi_readonly*)
    otherinstancerun:Boolean;(*'Other instance run'*)(*oi_readonly*)
    PreloadedFile:String;(*'Preloaded file'*)(*oi_readonly*)
    Ver:TmyFileVersionInfo;(*'Version'*)(*oi_readonly*)
    DefaultHeight:Integer;(*'Default controls height'*)(*oi_readonly*)
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
  zcaduniqueinstanceid='zcad unique instance';
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
  FreeAndNil(XMLConfig);
end;



end.
