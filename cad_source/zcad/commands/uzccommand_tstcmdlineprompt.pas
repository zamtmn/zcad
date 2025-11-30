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
{$IFDEF FPC}
  {$CODEPAGE UTF8}
  {$MODE DELPHI}
{$ENDIF}
unit uzccommand_tstCmdLinePrompt;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzeparsercmdprompt,uzegeometrytypes,
  uzcinterface,uzcdialogsfiles;

  {resourcestring}//чтоб не засирать локализацию просто const
const
  RSCLParam=
    'Нажми ${"э&[т]у",Keys[n],StrId[CLPIdUser1]} кнопку, ${"эт&[у]",Keys[e],100} или запусти ${"&[ф]айловый",Keys[a],StrId[CLPIdFileDialog]} диалог';

implementation

var
  clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;

function CmdLinePrompt_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  //inpt:String;
  gr:TzcInteractiveResult;
  filename:string='';
  p:TzePoint3d;
begin
  if clFileParam=nil then
    clFileParam:=CMDLinePromptParser.GetTokens(RSCLParam);
  commandmanager.ChangeInputMode([IPEmpty,IPShortCuts],[]);
  commandmanager.SetPrompt(clFileParam);
  repeat
    //gr:=commandmanager.GetInput('',inpt);
    gr:=commandmanager.Get3DPoint('',p);
    case gr of
      IRId:case commandmanager.GetLastId of
          CLPIdUser1:zcUI.TextMessage('GRId: CLPIdUser1',TMWOHistoryOut);
          CLPIdFileDialog:begin
            zcUI.TextMessage('GRId: CLPIdFileDialog',TMWOHistoryOut);
            if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Export data...') then
            begin
              system.break;
            end;
          end;
          else
            zcUI.TextMessage(format('GRId: %d',[commandmanager.GetLastId]),TMWOHistoryOut);
        end;
      IRNormal:zcUI.TextMessage(format('GRNormal: %g,%g,%g',[p.x,p.y,p.z]),
          TMWOHistoryOut);
      IRInput:zcUI.TextMessage(format('You enter: %s',[commandmanager.GetLastInput]),
          TMWOHistoryOut);
      IRCancel:zcUI.TextMessage('You cancel',TMWOHistoryOut);
    end;
  until gr=IRCancel;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@CmdLinePrompt_com,'tstCmdLinePrompt',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  if clFileParam<>nil then
    clFileParam.Free;
end.
