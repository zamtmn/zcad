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
unit uzccommand_dbgClipboard;

{$INCLUDE zengineconfig.inc}

interface
uses
  Classes,SysUtils,
  uzcLog,LCLType,LCLIntf,Clipbrd,
  uzcinfoform,
  uzcinterface,
  uzccommandsabstract,uzccommandsimpl;

implementation

function dbgClipboard_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   pbuf:pansichar;
   i:integer;
   cf:TClipboardFormat;
   ts:string;

   memsubstr:TMemoryStream;
   InfoForm:TInfoForm;
begin
     InfoForm:=TInfoForm.create(nil);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Clipboard:');

     memsubstr:=TMemoryStream.Create;
     ts:=Clipboard.AsText;
     i:=Clipboard.FormatCount;
     for i:=0 to Clipboard.FormatCount-1 do
     begin
          cf:=Clipboard.Formats[i];
          ts:=ClipboardFormatToMimeType(cf);
          if ts='' then
                       ts:=inttostr(cf);
          InfoForm.Memo.lines.Add(ts);
          Clipboard.GetFormat(cf,memsubstr);
          pbuf:=memsubstr.Memory;
          InfoForm.Memo.lines.Add('  ANSI: '+pbuf);
          memsubstr.Clear;
     end;
     memsubstr.Free;

     ZCMsgCallBackInterface.DOShowModal(InfoForm);
     InfoForm.Free;

     result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@dbgClipboard_com,'dbgClipboard',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
