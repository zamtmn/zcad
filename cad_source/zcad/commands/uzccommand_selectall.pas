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
unit uzccommand_selectall;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcdrawings,
  uzcinterface,
  gzctnrVectorTypes;

var
  selall:pCommandFastObjectPlugin;

implementation

function SelectAll_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
begin
  if drawings.GetCurrentROOT.ObjArray.Count = 0 then exit;
  drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount:=0;

  count:=0;

  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    inc(count);
  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;


  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if count>10000 then
      pv^.SelectQuik//:=true
    else
      pv^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);

  pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
  until pv=nil;

  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  //if assigned(updatevisibleproc) then updatevisibleproc(ZMsgID_GUIActionRedraw);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  selall:=CreateZCADCommand(@SelectAll_com,'SelectAll',CADWG,0);
  selall^.overlay:=true;
  selall.CEndActionAttr:=[];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
