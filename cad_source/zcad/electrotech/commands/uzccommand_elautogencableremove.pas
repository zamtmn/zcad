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
unit uzcCommand_ElAutoGenCableRemove;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzeentity,
  uzcvariablesutils,
  uzcdrawings,uzeconsts;

implementation

function _AutoGenCableRemove_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir:itrec;
  pvd:pvardesk;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if (pv^.GetObjType=GDBCableID) then begin
        pvd:=FindVariableInEnt(pv,'CABLE_AutoGen');
        if pvd<>nil then begin
          if pBoolean(pvd^.Data.Addr.Instance)^ then begin
            pv^.YouDeleted(drawings.GetCurrentDWG^);
          end;
        end;
      end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  drawings.GetCurrentDWG.SelObjArray.Clear;
  zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  clearcp;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@_AutoGenCableRemove_com,'EL_AutoGen_Cable_Remove',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
