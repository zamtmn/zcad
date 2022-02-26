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
unit uzccommand_polytest;

{$INCLUDE zcadconfig.inc}

interface
uses
  LazLogger,
  uzccommandsimpl,
  
  uzglviewareadata,
  uzegeometrytypes,
  uzeentlwpolyline,
  uzcdrawings,
  uzeconsts,
  uzccommandsmanager,
  uzcinterface;

implementation

procedure polytest_com_CommandStart(Operands:pansichar);
begin
  if drawings.GetCurrentDWG.GetLastSelected<>nil then
  if drawings.GetCurrentDWG.GetLastSelected.GetObjType=GDBlwPolylineID then
  begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or (MMoveCamera) or (MRotateCamera) or (MGet3DPoint));
  //drawings.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
  ZCMsgCallBackInterface.TextMessage('Click and test inside/outside of a 2D polyline:',TMWOHistoryOut);
  exit;
  end;
  //else
  begin
       ZCMsgCallBackInterface.TextMessage('Before run 2DPolyline must be selected',TMWOHistoryOut);
       commandmanager.executecommandend;
  end;
end;
function polytest_com_BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
//var tb:PGDBObjSubordinated;
begin
  result:=mclick+1;
  if (button and MZW_LBUTTON)<>0 then
  begin
       if pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).isPointInside(wc) then
       ZCMsgCallBackInterface.TextMessage('Inside!',TMWOHistoryOut)
       else
       ZCMsgCallBackInterface.TextMessage('Outside!',TMWOHistoryOut)
  end;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandRTEdObjectPlugin(@polytest_com_CommandStart,nil,nil,nil,@polytest_com_BeforeClick,@polytest_com_BeforeClick,nil,nil,'PolyTest',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
