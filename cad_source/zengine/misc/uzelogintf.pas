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

unit uzeLogIntf;{$Mode objfpc}{$H+}
{$modeswitch typehelpers}
{$modeswitch advancedrecords}
{$INCLUDE zengineconfig.inc}

interface

type

  TZEMsgType=(ZEMsgInfo,ZEMsgCriticalInfo,ZEMsgWarning,ZEMsgError);
  TZEStage=(ZESGeneral);
  TZEMsg=string;

  TZELogProc=procedure(Stage:TZEStage;MsgType:TZEMsgType;Msg:TZEMsg);

procedure Log(LogProc:TZELogProc;Stage:TZEStage;MsgType:TZEMsgType;Msg:TZEMsg);//inline;
implementation
procedure Log(LogProc:TZELogProc;Stage:TZEStage;MsgType:TZEMsgType;Msg:TZEMsg);//inline;
begin
  if LogProc<>nil then

    LogProc(Stage,MsgType,Msg);
end;

end.

