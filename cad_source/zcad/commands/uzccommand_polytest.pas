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
unit uzccommand_polytest;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsimpl,
  uzglviewareadata,
  uzegeometrytypes,
  uzeentlwpolyline,
  uzcdrawings,
  uzeconsts,
  uzccommandsmanager,uzccommandsabstract,
  uzcinterface;

implementation

procedure polytest_com_CommandStart(const Context:TZCADCommandContext;
  Operands:pansichar);
begin
  if drawings.GetCurrentDWG.GetLastSelected<>nil then
    if drawings.GetCurrentDWG.GetLastSelected.GetObjType=GDBlwPolylineID then begin
      drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPointWOOP) or
        (MMoveCamera) or (MRotateCamera) or (MGet3DPoint));
      //drawings.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameON := true;
      zcUI.TextMessage('Click and test inside/outside of a 2D polyline:',TMWOHistoryOut);
      exit;
    end;
  //else
  begin
    zcUI.TextMessage('Before run 2DPolyline must be selected',TMWOHistoryOut);
    commandmanager.executecommandend;
  end;
end;

function polytest_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
  //var tb:PGDBObjSubordinated;
begin
  Result:=mclick+1;
  if (button and MZW_LBUTTON)<>0 then begin
    if pgdbobjlwpolyline(drawings.GetCurrentDWG.GetLastSelected).
      isPointInside(wc) then
      zcUI.TextMessage('Inside!',TMWOHistoryOut)
    else
      zcUI.TextMessage('Outside!',TMWOHistoryOut);
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@polytest_com_CommandStart,nil,nil,
    nil,@polytest_com_BeforeClick,@polytest_com_BeforeClick,nil,nil,'PolyTest',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
