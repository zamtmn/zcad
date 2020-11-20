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
unit uzccommand_camreset;

{$INCLUDE def.inc}

interface
uses
  sysutils,
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  zcchangeundocommand,
  uzcutils,uzecamera,
  uzedrawingsimple,uzcdrawings,uzcdrawing;

implementation

function Cam_reset_com(operands:TCommandOperands):TCommandResult;
var
  cdwg:PTSimpleDrawing;
  pcamera:PGDBObjCamera;
begin
  cdwg:=drawings.GetCurrentDWG;
  if cdwg<>nil then begin
    pcamera:=cdwg.pcamera;
    if pcamera<>nil then begin
      PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.PushStartMarker('Reset camera');
      with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG).UndoStack,drawings.GetCurrentDWG.pcamera^.prop)^ do begin
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Cam_reset_com,'Cam_Reset',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
