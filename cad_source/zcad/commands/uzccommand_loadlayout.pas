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
{$mode delphi}
unit uzccommand_loadlayout;

{$INCLUDE zcadconfig.inc}

interface
uses
  SysUtils,
  LazLogger,Forms,
  AnchorDocking,
  Dialogs,
  XMLPropStorage,
  uzcsysvars,
  uzbpaths,
  uztoolbarsmanager,
  uzcinterface,
  uzcstrconsts,
  uzccommandsabstract,uzccommandsimpl;

procedure LoadLayoutFromFile(Filename: string);
function LoadLayout_com(operands:TCommandOperands):TCommandResult;

implementation

procedure LoadLayoutFromFile(Filename: string);
var
  XMLConfig: TXMLConfigStorage;
begin
  try
    // load the xml config file
    XMLConfig:=TXMLConfigStorage.Create(Filename,True);
    try
      // restore the layout
      // this will close unneeded forms and call OnCreateControl for all needed

      {if assigned(ZCADMainWindow.updatesbytton) then
        ZCADMainWindow.updatesbytton.Clear;
      if assigned(ZCADMainWindow.updatescontrols) then
        ZCADMainWindow.updatescontrols.Clear;}

      ToolBarsManager.RestoreToolBarsFromConfig(XMLConfig);
      Application.Processmessages;
      DockMaster.LoadSettingsFromConfig(XMLConfig);
      DockMaster.LoadLayoutFromConfig(XMLConfig,false);
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',
        'Error loading layout from file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);
    end;
  end;
end;

function LoadLayout_com(operands:TCommandOperands):TCommandResult;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
  s:string;
begin
  if Operands='' then
                     filename:=sysvar.PATH.LayoutFile^
                 else
                     begin
                     s:=Operands;
                     filename:={utf8tosys}(ProgramPath+'components/'+s);
                     end;
  if not fileexists(filename) then
                              filename:={utf8tosys}(ProgramPath+'components/defaultlayout.xml');
  LoadLayoutFromFile(Filename);
  exit;
  try
    // load the xml config file
    XMLConfig:=TXMLConfigStorage.Create(Filename,True);
    try
      // restore the layout
      // this will close unneeded forms and call OnCreateControl for all needed
      DockMaster.LoadLayoutFromConfig(XMLConfig,true);
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
                            ZCMsgCallBackInterface.TextMessage(rsLayoutLoad+' '+Filename+':'#13+E.Message,TMWOShowError);
      //MessageDlg('Error',
      //  'Error loading layout from file '+Filename+':'#13+E.Message,mtError,
      //  [mbCancel],0);
    end;
  end;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@LoadLayout_com,'LoadLayout',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
