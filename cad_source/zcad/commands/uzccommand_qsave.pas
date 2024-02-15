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

unit uzccommand_qsave;
{$INCLUDE zengineconfig.inc}

interface
uses
  LazUTF8,uzcLog,
  uzcdialogsfiles,
  sysutils,
  uzbpaths,

  uzeffmanager,
  uzccommand_DWGNew,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawings,
  uzcinterface,
  uzccommand_saveas;

implementation

function QSave_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var s,s1:AnsiString;
    itautoseve:boolean;
begin
  itautoseve:=false;
  if operands='QS' then begin
    s1:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^);
    s:=rsAutoSave+': '''+s1+'''';
    ZCMsgCallBackInterface.TextMessage(s,TMWOHistoryOut);
    itautoseve:=true;
  end else begin
    if extractfilepath(drawings.GetCurrentDWG.GetFileName)='' then begin
      SaveAs_com(Context,EmptyCommandOperands);
      exit;
    end;
      s1:=drawings.GetCurrentDWG.GetFileName;
  end;
    result:=SaveDXFDPAS(s1);
    if (not itautoseve)and(result=cmd_ok) then
      drawings.GetCurrentDWG.ChangeStampt(false);
    SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@QSave_com,'QSave',CADWG or CADWGChanged,0).CEndActionAttr:=[CEDWGNChanged];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
