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
unit uzcCommand_RegenZEnts;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzeentity,
  uzcdrawings,uzeconsts,
  uzedrawingdef,uzgldrawcontext,uzelongprocesssupport;

implementation

function RegenZEnts_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir:itrec;
  drawing:PTDrawingDef;
  DC:TDrawContext;
  lph:TLPSHandle;
begin
  lph:=lps.StartLongProcess('Regenerate ZCAD entities',nil,drawings.GetCurrentROOT.ObjArray.Count);
  drawing:=drawings.GetCurrentDwg;
  dc:=drawings.GetCurrentDwg^.CreateDrawingRC;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if (pv^.GetObjType>=GDBZCadEntsMinID)and(pv^.GetObjType<=GDBZCadEntsMaxID) then
        pv^.FormatEntity(drawing^,dc);
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
      lps.ProgressLongProcess(lph,ir.itc);
    until pv=nil;
  drawings.GetCurrentROOT.getoutbound(dc);
  lps.EndLongProcess(lph);

  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  clearcp;
  //redrawoglwnd;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@RegenZEnts_com,'RegenZEnts',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
