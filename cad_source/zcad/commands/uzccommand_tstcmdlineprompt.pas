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
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzeparsercmdprompt,
  uzcinterface,uzcdialogsfiles;

{resourcestring}//чтоб не засирать локализацию просто const
const
  RSCLParam='Нажми ${"э&[т]у",Keys[n],StrId[CLPIdUser1]} кнопку или вызови ${"&[ф]айловый",Keys[a],StrId[CLPIdFileDialog]} диалог';

implementation

var
  clFileParam:CMDLinePromptParser.TGeneralParsedText=nil;

function CmdLinePrompt_com(operands:TCommandOperands):TCommandResult;
var
  inpt:String;
  gr:TGetResult;
  filename:string;
begin
  if clFileParam=nil then
    clFileParam:=CMDLinePromptParser.GetTokens(RSCLParam);
  commandmanager.ChangeInputMode([IPEmpty,IPShortCuts],[]);
  commandmanager.SetPrompt(clFileParam);
  repeat
    gr:=commandmanager.GetInput('',inpt);
    case gr of
      GRId:case commandmanager.GetLastId of
             CLPIdUser1:ZCMsgCallBackInterface.TextMessage('GRId:CLPIdUser1',TMWOHistoryOut);
             CLPIdFileDialog:begin
               ZCMsgCallBackInterface.TextMessage('GRId:CLPIdFileDialog',TMWOHistoryOut);
               if SaveFileDialog(filename,'CSV',CSVFileFilter,'','Export data...') then begin
                 system.break;
               end;
             end;
          end;
    end;
  until gr=GRCancel;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandFastObjectPlugin(@CmdLinePrompt_com,'tstCmdLinePrompt',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  if clFileParam<>nil then
    clFileParam.Free;
end.
