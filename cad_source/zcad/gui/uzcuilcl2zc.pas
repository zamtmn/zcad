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

unit uzcuilcl2zc;
{$INCLUDE def.inc}
interface
uses
    Controls,LCLTaskDialog,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcuitypes,uzcuiutils;
type
  TZCMsgCommonButton2TCommonButton_Converter=class
    class function Convert(valueIn:TZCMsgCommonButton;out valueOut:TCommonButton):boolean;
  end;

  TLCLModalResult2TZCMsgModalResult_Converter=class
    class function Convert(valueIn:Integer;out valueOut:TZCMsgModalResult):boolean;
  end;

  TZCMsgCommonButtons2TCommonButtons=TGSetConverter<TZCMsgCommonButton,TZCMsgCommonButtons,TCommonButton,TCommonButtons,TZCMsgCommonButton2TCommonButton_Converter>;
  TLCLModalResult2TZCMsgModalResult=TGConverter<Integer,TZCMsgModalResult,TLCLModalResult2TZCMsgModalResult_Converter>;

function ID2TZCMsgCommonButton(ID:Integer):TZCMsgCommonButton;
function TZCMsgModalResult2TZCMsgCommonButton(MR:TZCMsgModalResult):TZCMsgCommonButton;

implementation

class function TZCMsgCommonButton2TCommonButton_Converter.Convert(valueIn:TZCMsgCommonButton;out valueOut:TCommonButton):boolean;
begin
  result:=true;
  case valueIn of
    zccbOK:valueOut:=cbOK;
    zccbYes:valueOut:=cbYes;
    zccbNo:valueOut:=cbNo;
    zccbCancel:valueOut:=cbCancel;
    zccbRetry:valueOut:=cbRetry;
    zccbClose:valueOut:=cbClose;
    else result:=false;
  end;
end;

class function TLCLModalResult2TZCMsgModalResult_Converter.Convert(valueIn:Integer;out valueOut:TZCMsgModalResult):boolean;
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

type
TZCTaskStr=string;
TZCMsgId=string;
TZCMsgStr=string;
TZCMsgCommonButton=(zccbOK,zccbYes,zccbNo,zccbCancel,zccbRetry,zccbClose);
TZCMsgCommonButtons=set of TZCMsgCommonButton;

initialization
finalization
end.
