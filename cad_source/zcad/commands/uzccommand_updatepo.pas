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
unit uzccommand_updatepo;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  sysutils,
  LCLType,
  uzbpaths,
  uzcuitypes,
  uzccommandsabstract,uzccommandsimpl,
  uzcsysparams,
  uzcinterface,
  uzctranslations;

resourcestring
  rsAboutCLSwithUpdatePO='Command line swith "UpdatePO" must be set. (or not the first time running this command)';

implementation

function UpdatePO_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   cleaned:integer;
   s:string;
begin
     if sysparam.saved.updatepo then
     begin
          begin
               cleaned:=RunTimePO.exportcompileritems(actualypo);
               s:='Cleaned items: '+inttostr(cleaned)
           +#13#10'Added items: '+inttostr(_UpdatePO)
           +#13#10'File zcadrt.po must be rewriten. Confirm?';
               if ZCMsgCallBackInterface.TextQuestion('UpdatePO',s)=zccbNo then
                 exit;
               RunTimePO.SaveToFile(expandpath(PODirectory + ZCADRTBackupPOFileName));
               actualypo.SaveToFile(expandpath(PODirectory + ZCADRTPOFileName));
               sysparam.saved.updatepo:=false
          end;
     end
        else ZCMsgCallBackInterface.TextMessage(rsAboutCLSwithUpdatePO,TMWOShowError);
     result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@UpdatePO_com,'UpdatePO',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
