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
unit uzccommand_updatepo;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
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

function UpdatePO_com(operands:TCommandOperands):TCommandResult;
var
   cleaned:integer;
   s:string;
begin
     if sysparam.saved.updatepo then
     begin
          begin
               cleaned:=po.exportcompileritems(actualypo);
               s:='Cleaned items: '+inttostr(cleaned)
           +#13#10'Added items: '+inttostr(_UpdatePO)
           +#13#10'File zcadrt.po must be rewriten. Confirm?';
               if ZCMsgCallBackInterface.TextQuestion('UpdatePO',s)=zccbNo then
                 exit;
               po.SaveToFile(expandpath(PODirectory + ZCADRTBackupPOFileName));
               actualypo.SaveToFile(expandpath(PODirectory + ZCADRTPOFileName));
               sysparam.saved.updatepo:=false
          end;
     end
        else ZCMsgCallBackInterface.TextMessage(rsAboutCLSwithUpdatePO,TMWOShowError);
     result:=cmd_ok;
end;


initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@UpdatePO_com,'UpdatePO',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
