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
unit uzccommand_memsummary;

{$INCLUDE def.inc}

interface
uses
  SysUtils,
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  UGDBNumerator,
  gzctnrvectortypes,
  uzcinfoform,
  uzbmemman,
  uzcinterface;

implementation

function MemSummary_com(operands:TCommandOperands):TCommandResult;
var
    memcount:GDBNumerator;
    pmemcounter:PGDBNumItem;
    ir:itrec;
    s:AnsiString;
    I:Integer;
    InfoForm:TInfoForm;
begin

     InfoForm:=TInfoForm.create(nil);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Memory is used to:');
     memcount.init(100);
     for i := 0 to memdesktotal do
     begin
          if not(memdeskarr[i].free) then
          begin
               pmemcounter:=memcount.addnumerator(memdeskarr[i].getmemguid);
               inc(pmemcounter^.Nymber,memdeskarr[i].size);
           end;
     end;
     memcount.sort;

     pmemcounter:=memcount.beginiterate(ir);
     if pmemcounter<>nil then
     repeat

           s:=pmemcounter^.Name+' '+inttostr(pmemcounter^.Nymber);
           InfoForm.Memo.lines.Add(s);
           pmemcounter:=memcount.iterate(ir);
     until pmemcounter=nil;


     ZCMsgCallBackInterface.DOShowModal(InfoForm);
     InfoForm.Free;
     memcount.Done;
    result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@MemSummary_com,'MeMSummary',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
