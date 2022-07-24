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
  LazUTF8,LCLProc,
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

function QSave_com(operands:TCommandOperands):TCommandResult;
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
      SaveAs_com(EmptyCommandOperands);
      exit;
    end;
      s1:=drawings.GetCurrentDWG.GetFileName;
  end;
    result:=SaveDXFDPAS(s1);
    if (not itautoseve)and(result=cmd_ok) then
      drawings.GetCurrentDWG.ChangeStampt(false);
    SysVar.SAVE.SAVE_Auto_Current_Interval^:=SysVar.SAVE.SAVE_Auto_Interval^;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@QSave_com,'QSave',CADWG or CADWGChanged,0).CEndActionAttr:=CEDWGNChanged;
end;
procedure finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
