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
initialization
finalization
end.
