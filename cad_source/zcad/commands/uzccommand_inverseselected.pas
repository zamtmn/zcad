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
unit uzccommand_inverseselected;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcdrawings,
  uzcinterface,uzcutils,
  gzctnrVectorTypes,uzCtnrVectorPBaseEntity;

implementation

var
  InvSel:pCommandFastObjectPlugin;

function InverseSelected_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir:itrec;
  count:integer;
  Ents:TZctnrVectorPGDBaseEntity;
begin

  count:=0;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if not pv^.Selected then
      inc(count);
    pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;

  if count>0 then begin
    Ents.init(count);
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if not pv^.Selected then
        Ents.PushBackData(pv);
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    drawings.GetCurrentDWG.DeSelectAll;
    drawings.GetCurrentDWG.SelectEnts(Ents);
    Ents.Clear;
    Ents.done;
    drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=count;
    drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
    drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
    drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
    zcRedrawCurrentDrawing;
  end;
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  InvSel:=CreateZCADCommand(@InverseSelected_com,'InverseSelected',CADWG or CASelEnts,0);
  InvSel^.CEndActionAttr:=[CEGUIRePrepare];
  InvSel^.overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
