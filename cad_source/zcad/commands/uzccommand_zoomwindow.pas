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
unit uzccommand_zoomwindow;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  sysutils,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,
  uzegeometrytypes,
  uzegeometry,
  uzglviewareadata,
  uzccommandsmanager,
  uzccommand_selectframe;

implementation

var
  zoomwindowcommand:PCommandObjectDef;

function ShowWindow_com_AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
begin
  result:=mclick;
  drawings.GetCurrentDWG.wa.param.seldesc.Frame2 := mc;
  drawings.GetCurrentDWG.wa.param.seldesc.Frame23d := wc;
  if (button and MZW_LBUTTON)<>0 then
  begin
    begin
      drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
      drawings.GetCurrentDWG.wa.ZoomToVolume(CreateBBFrom2Point(drawings.GetCurrentDWG.wa.param.seldesc.Frame13d,drawings.GetCurrentDWG.wa.param.seldesc.Frame23d));
      drawings.GetCurrentDWG.wa.param.seldesc.MouseFrameON := false;
      commandmanager.executecommandend;
      result:=cmd_ok;
    end;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  zoomwindowcommand:=CreateCommandRTEdObjectPlugin(@FrameEdit_com_CommandStart,@FrameEdit_com_Command_End,nil,nil,@FrameEdit_com_BeforeClick,@ShowWindow_com_AfterClick,nil,nil,'ZoomWindow',0,0);
  zoomwindowcommand^.overlay:=true;
  zoomwindowcommand.CEndActionAttr:=[];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
