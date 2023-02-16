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
unit uzccommand_erase;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,uzcdrawings,uzcdrawing,
  zcmultiobjectcreateundocommand,uzcinterface,uzcutils;

function Erase_com(operands:TCommandOperands):TCommandResult;

implementation

function Erase_com(operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    domethod,undomethod:tmethod;
begin
  if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             //pv^.YouDeleted;
                             inc(count);
                        end
                    else
                        pv^.DelSelectedSubitem(drawings.GetCurrentDWG^);

  pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  if count>0 then
  begin
  SetObjCreateManipulator(undomethod,domethod);
  with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),count) do
  begin
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then
                          begin
                               AddObject(pv);
                               pv^.Selected:=false;
                          end;
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
       //AddObject(pc);
       FreeArray:=false;
       comit;
       //UnDo;
  end;
  end;
  drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandFastObjectPlugin(@Erase_com,'Erase',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
