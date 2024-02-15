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
unit uzccommand_regen;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,uzbtypes,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,uzeentconnected,
  gzctnrVectorTypes,
  uzedrawingsimple,uzcdrawings,
  uzcinterface,
  uzgldrawcontext,
  uzelongprocesssupport,
  uzeroot;

function Regen_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function Regen_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  drawing:PTSimpleDrawing;
  DC:TDrawContext;
  lpsh:TLPSHandle;
  c:integer;
begin
  c:=drawings.GetCurrentROOT.ObjArray.count;
  lpsh:=lps.StartLongProcess('Regenerate drawing',nil,c*2);
  drawing:=drawings.GetCurrentDwg;
  drawing.wa.CalcOptimalMatrix;
  dc:=drawings.GetCurrentDwg^.CreateDrawingRC;

  DoFormat(drawings.GetCurrentROOT^,drawings.GetCurrentROOT.ObjArray,drawings.GetCurrentROOT.ObjToConnectedArray,drawing^,DC,lpsh,[]);
  drawings.GetCurrentROOT.getoutbound(dc);

  lps.EndLongProcess(lpsh);

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
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Regen_com,'Regen',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
