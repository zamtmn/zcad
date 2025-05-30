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

unit uzcuilcl2zc;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
interface
uses
    Controls,{LCLTaskDialog,}Dialogs,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcuitypes,uzcuiutils;
type
  TZCMsgCommonButton2TCommonButton_Converter=class
    class function TryConvert(valueIn:TZCMsgCommonButton;out valueOut:TTaskDialogCommonButton):boolean;
  end;

  TLCLModalResult2TZCMsgModalResult_Converter=class
    class function TryConvert(valueIn:Integer;out valueOut:TZCMsgModalResult):boolean;
  end;

  TZCMsgCommonButtons2TCommonButtons=TGSetConverter<TZCMsgCommonButton,TZCMsgCommonButtons,TTaskDialogCommonButton,TTaskDialogCommonButtons,TZCMsgCommonButton2TCommonButton_Converter>;
  TLCLModalResult2TZCMsgModalResult=TGConverter<Integer,TZCMsgModalResult,TLCLModalResult2TZCMsgModalResult_Converter>;

function ID2TZCMsgCommonButton(ID:Integer):TZCMsgCommonButton;
function TZCMsgModalResult2TZCMsgCommonButton(MR:TZCMsgModalResult):TZCMsgCommonButton;

implementation

class function TZCMsgCommonButton2TCommonButton_Converter.TryConvert(valueIn:TZCMsgCommonButton;out valueOut:TTaskDialogCommonButton):boolean;
begin
  if valueIn in [zccbOK..zccbClose] then begin
    case valueIn of
      zccbOK:valueOut:=tcbOK;
      zccbYes:valueOut:=tcbYes;
      zccbNo:valueOut:=tcbNo;
      zccbCancel:valueOut:=tcbCancel;
      zccbRetry:valueOut:=tcbRetry;
      zccbClose:valueOut:=tcbClose;
    end;
    result:=true;
  end else begin
    valueOut:=tcbCancel;
    result:=false;
  end;
end;

class function TLCLModalResult2TZCMsgModalResult_Converter.TryConvert(valueIn:Integer;out valueOut:TZCMsgModalResult):boolean;
begin
  result:=true;
  if valueIn in [mrNone..mrLast] then
    case valueIn of
      mrNone:    valueOut:=ZCmrNone;
      mrOK:      valueOut:=ZCmrOK;
      mrCancel:  valueOut:=ZCmrCancel;
      mrAbort:   valueOut:=ZCmrAbort;
      mrRetry:   valueOut:=ZCmrRetry;
      mrIgnore:  valueOut:=ZCmrIgnore;
      mrYes:     valueOut:=ZCmrYes;
      mrNo:      valueOut:=ZCmrNo;
      mrAll:     valueOut:=ZCmrAll;
      mrNoToAll: valueOut:=ZCmrNoToAll;
      mrYesToAll:valueOut:=ZCmrYesToAll;
      mrClose:   valueOut:=ZCmrClose;
      else begin
        result:=false;
        valueOut:=ZCmrNone;
      end;
    end
  else
    valueOut:=valueIn;
end;

function ID2TZCMsgCommonButton(ID:Integer):TZCMsgCommonButton;
begin
  case ID of
    IDOK:Result:=zccbOK;
    IDCANCEL:Result:=zccbCancel;
    //-IDABORT = 3;  ID_ABORT = IDABORT;
    IDRETRY:Result:=zccbRetry;
    //-IDIGNORE = 5; ID_IGNORE = IDIGNORE;
    IDYES:Result:=zccbYes;
    IDNO:Result:=zccbNo;
    IDCLOSE:Result:=zccbClose;
    //IDHELP = 9;   ID_HELP = IDHELP;
  else
    raise Exception.CreateFmt('Unknown button ID : "%d"', [ID]);
  end;
end;

function TZCMsgModalResult2TZCMsgCommonButton(MR:TZCMsgModalResult):TZCMsgCommonButton;
begin
  case MR of
    ZCmrOK:Result:=zccbOK;
    ZCmrCancel:Result:=zccbCancel;
    //ZCmrAbort = ZCmrNone + 3;
    ZCmrRetry:Result:=zccbRetry;
    //ZCmrIgnore = ZCmrNone + 5;
    ZCmrYes:Result:=zccbYes;
    ZCmrNo:Result:=zccbNo;
    //ZCmrAll = ZCmrNone + 8;
    //ZCmrNoToAll = ZCmrNone + 9;
    //ZCmrYesToAll = ZCmrNone + 10;
    ZCmrClose:Result:=zccbClose;
    //ZCmrLast = ZCmrClose;
  else
    raise Exception.CreateFmt('Unknown modal result : "%d"', [MR]);
  end;
end;

initialization
finalization
end.
