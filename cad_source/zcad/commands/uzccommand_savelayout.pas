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
{$mode delphi}
unit uzccommand_savelayout;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,Forms,
  AnchorDocking,XMLConf,LazUTF8,
  Dialogs,
  XMLPropStorage,
  uzcsysvars,
  uzbpaths,
  uztoolbarsmanager,
  uzcinterface,
  uzccommandsabstract,uzccommandsimpl;

implementation

procedure SaveLayoutToFile(Filename: string);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:=Filename;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      DockMaster.SaveLayoutToConfig(Config);
      DockMaster.SaveSettingsToConfig(Config);
      ToolBarsManager.SaveToolBarsToConfig(Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
function SaveLayout_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
begin
  try
    // create a new xml config file
    filename:=utf8tosys(ProgramPath+'components/defaultlayout.xml');
    SaveLayoutToFile(filename);
    exit;
    XMLConfig:=TXMLConfigStorage.Create(filename,false);
    try
      // save the current layout of all forms
      DockMaster.SaveLayoutToConfig(XMLConfig);
      XMLConfig.WriteToDisk;
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',
        'Error saving layout to file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);
    end;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SaveLayout_com,'SaveLayout',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
