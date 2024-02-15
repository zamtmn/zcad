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
unit uzccommand_camreset;

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  gzundoCmdChgData,
  uzcutils,uzecamera,
  uzedrawingsimple,uzcdrawings,uzcdrawing;

implementation

function Cam_reset_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  cdwg:PTSimpleDrawing;
  pcamera:PGDBObjCamera;
begin
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    pcamera:=cdwg.pcamera;
    if pcamera<>nil then begin
      PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStartMarker('Reset camera');
      with TGDBCameraBasePropChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,drawings.GetCurrentDWG.pcamera^.prop,nil,nil) do begin
        pcamera^.prop.point.x := 0;
        pcamera^.prop.point.y := 0;
        pcamera^.prop.point.z := 50;
        pcamera^.prop.look.x := 0;
        pcamera^.prop.look.y := 0;
        pcamera^.prop.look.z := -1;
        pcamera^.prop.ydir.x := 0;
        pcamera^.prop.ydir.y := 1;
        pcamera^.prop.ydir.z := 0;
        pcamera^.prop.xdir.x := -1;
        pcamera^.prop.xdir.y := 0;
        pcamera^.prop.xdir.z := 0;
        pcamera^.anglx := -pi;
        pcamera^.angly := -pi / 2;
        pcamera^.zmin := 1;
        pcamera^.zmax := 100000;
        pcamera^.fovy := 35;
        pcamera^.prop.zoom := 0.1;
        ComitFromObj;
      end;
    end;
    PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushEndMarker;
    zcRedrawCurrentDrawing;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Cam_reset_com,'Cam_Reset',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
