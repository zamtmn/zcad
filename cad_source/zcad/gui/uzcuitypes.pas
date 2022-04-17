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

unit uzcuitypes;

{$INCLUDE zengineconfig.inc}

interface

uses Generics.Collections;

resourcestring
  rsMsgWndTitle='ZCAD';
  rsDontShowThisNextTime='Don''t show this next time (for task "%s")';
  rsMsgKeepChoice='Keep choice (for task "%s")';

const
  ZCmrNone = 0;
  ZCmrOK = ZCmrNone + 1;
  ZCmrCancel = ZCmrNone + 2;
  ZCmrAbort = ZCmrNone + 3;
  ZCmrRetry = ZCmrNone + 4;
  ZCmrIgnore = ZCmrNone + 5;
  ZCmrYes = ZCmrNone + 6;
  ZCmrNo = ZCmrNone + 7;
  ZCmrAll = ZCmrNone + 8;
  ZCmrNoToAll = ZCmrNone + 9;
  ZCmrYesToAll = ZCmrNone + 10;
  ZCmrClose = ZCmrNone + 11;
  ZCmrLast = ZCmrClose;

type
  TZCTaskStr=string;
  TZCMsgId=string;
  TZCMsgStr=string;
  TZCMsgCommonButton=(zccbOK,zccbYes,zccbNo,zccbCancel,zccbRetry,zccbClose);
  TZCMsgCommonButtons=set of TZCMsgCommonButton;

  TZCMsgModalResult=Integer{(zcmrNone,zcmrOK,zcmrCancel,zcmrAbort,zcmrRetry,zcmrIgnore,
                     zcmrYes,zcmrNo,zcmrAll,zcmrNoToAll,zcmrYesToAll,zcmrClose)};

  TZCMsgDlgIcon=(zcdiWarning, zcdiQuestion, zcdiError, zcdiInformation, zcdiNotUsed);

  TZCMsgDialogResult=record
    ModalResult:TZCMsgModalResult;
    RadioRes: integer;
    SelectionRes: integer;
    VerifyChecked: Boolean;
  end;

  TMessagesContext=class(TDictionary<TZCMsgId,TZCMsgDialogResult>)
    TaskName:TZCTaskStr;
    constructor Create(TN:TZCTaskStr);
  end;

implementation

constructor TMessagesContext.Create(TN:TZCTaskStr);
begin
  TaskName:=TN;
  inherited create;
end;

begin
end.
