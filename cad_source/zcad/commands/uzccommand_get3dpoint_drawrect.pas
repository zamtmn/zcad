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
unit uzccommand_get3dpoint_drawrect;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,uzeconsts,uzcinterface,
  uzcstrconsts,uzegeometrytypes,
  uzglviewareadata,uzccommandsmanager,
  uzsbVarmanDef,uzegeometry;

implementation

var
  point:TzePoint3d;

function Line_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or
    (MRotateCamera));
  if operands='' then
    zcUI.TextMessage(rscmPoint,TMWOHistoryOut)
  else
    zcUI.TextMessage(operands,TMWOHistoryOut);
  Result:=cmd_ok;
end;

function Line_com_BeforeClick(const Context:TZCADCommandContext;wc:TzePoint3d;
  mc:TzePoint2i;var button:byte;osp:pos_record;mclick:integer):integer;
begin
  point:=wc;
  if (button and MZW_LBUTTON)<>0 then begin
    commandmanager.PushValue('','TzePoint3d',@wc);
    commandmanager.executecommandend;
    Result:=1;
  end;
end;

function DrawRect(mclick:integer):integer;
var
  vd:vardesk;
  p1,p2,p4:TzePoint3d;
  matrixs:tmatrixs;
begin
  vd:=commandmanager.GetValue;
  p1:=PzePoint3d(vd.Data.Addr.Instance)^;

  p2:=createvertex(p1.x,point.y,p1.z);
  p4:=createvertex(point.x,p1.y,point.z);

  matrixs.pmodelMatrix:=@drawings.GetCurrentDWG.GetPcamera.modelMatrix;
  matrixs.pprojMatrix:=@drawings.GetCurrentDWG.GetPcamera.projMatrix;
  matrixs.pviewport:=@drawings.GetCurrentDWG.GetPcamera.viewport;

  drawings.GetCurrentDWG.wa.Drawer.DrawLine3DInModelSpace(p1,p2,matrixs);
  drawings.GetCurrentDWG.wa.Drawer.DrawLine3DInModelSpace(p2,point,matrixs);
  drawings.GetCurrentDWG.wa.Drawer.DrawLine3DInModelSpace(point,p4,matrixs);
  drawings.GetCurrentDWG.wa.Drawer.DrawLine3DInModelSpace(p4,p1,matrixs);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,nil,nil,nil,@Line_com_BeforeClick,nil,@DrawRect,nil,'Get3DPoint_DrawRect',0,0).overlay:=True;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
