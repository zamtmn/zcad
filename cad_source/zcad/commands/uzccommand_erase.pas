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
  zcmultiobjectcreateundocommand,uzcinterface,uzcutils,
  UGDBSelectedObjArray,gzctnrSTL,uzeentsubordinated;

function Erase_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

(*
//Старый вариант без удаления в дингамической части устройств
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
end;*)

procedure MySetObjCreateManipulator(Owner:PGDBObjGenericWithSubordinated;out domethod,undomethod:tmethod);
begin
     domethod.Code:=pointer(Owner^.GoodAddObjectToObjArray);
     domethod.Data:=Owner;
     undomethod.Code:=pointer(Owner^.GoodRemoveMiFromArray);
     undomethod.Data:=Owner;
end;


function Erase_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  Pair:TMyMapCounter<PGDBObjGenericWithSubordinated>.TDictionaryPair;
  ir:itrec;
  Count:integer;
  domethod,undomethod:tmethod;
  psd:PSelectedObjDesc;
  Counter:TMyMapCounter<PGDBObjGenericWithSubordinated>;
begin
  if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then exit;
  Counter:=TMyMapCounter<PGDBObjGenericWithSubordinated>.Create;
  Count:=0;
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then repeat
    pv:=psd^.objaddr;
    Counter.CountKey(pv^.bp.ListPos.Owner);
    inc(Count);
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;
  if Count>0 then begin
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Erase');
    for Pair in Counter do begin
      MySetObjCreateManipulator(Pair.key,undomethod,domethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),Pair.Value) do begin
        psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
        if psd<>nil then repeat
          pv:=psd^.objaddr;
          if pv^.bp.ListPos.Owner=Pair.key then begin
            AddObject(pv);
            pv^.Selected:=false;
          end;

          psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
        until psd=nil;
        FreeArray:=false;
        comit;
      end;
    end;
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;

    drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=0;
    drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
    drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
    drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
    clearcp;
    zcRedrawCurrentDrawing;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Erase_com,'Erase',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
