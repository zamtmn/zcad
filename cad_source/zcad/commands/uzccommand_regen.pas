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
unit uzccommand_regen;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  gzctnrVectorTypes,
  uzedrawingsimple,uzcdrawings,
  uzcinterface,
  uzgldrawcontext,
  uzelongprocesssupport;

function Regen_com(operands:TCommandOperands):TCommandResult;

implementation

function Regen_com(operands:TCommandOperands):TCommandResult;
var //i: Integer;
    pv:pGDBObjEntity;
        ir:itrec;
    drawing:PTSimpleDrawing;
    DC:TDrawContext;
    lpsh:TLPSHandle;
begin
  lpsh:=lps.StartLongProcess('Regenerate drawing',nil,drawings.GetCurrentROOT.ObjArray.count);
  //if assigned(StartLongProcessProc) then StartLongProcessProc(drawings.GetCurrentROOT.ObjArray.count,'Regenerate drawing');
  drawing:=drawings.GetCurrentDwg;
  drawing.wa.CalcOptimalMatrix;
  dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    pv^.FormatEntity(drawing^,dc);
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  lps.ProgressLongProcess(lpsh,ir.itc);
  //if assigned(ProcessLongProcessProc) then ProcessLongProcessProc(ir.itc);
  until pv=nil;
  drawings.GetCurrentROOT.getoutbound(dc);
  lps.EndLongProcess(lpsh);
  //if assigned(EndLongProcessProc) then EndLongProcessProc;

  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  {objinsp.GDBobjinsp.}
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  //redrawoglwnd;
  result:=cmd_ok;
end;


initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Regen_com,'Regen',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
