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
unit uzccommand_selectall;

{$INCLUDE zcadconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcdrawings,
  uzcinterface,
  gzctnrVectorTypes;

var
  selall:pCommandFastObjectPlugin;

implementation

function SelectAll_com(operands:TCommandOperands):TCommandResult;
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  selall:=CreateCommandFastObjectPlugin(@SelectAll_com,'SelectAll',CADWG,0);
  selall^.overlay:=true;
  selall.CEndActionAttr:=0;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
