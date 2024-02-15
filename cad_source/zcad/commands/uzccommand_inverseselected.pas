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
  gzctnrVectorTypes;

var
  selall:pCommandFastObjectPlugin;

implementation

function InverseSelected_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var pv:pGDBObjEntity;
    ir:itrec;
    count:integer;
    //domethod,undomethod:tmethod;
begin
  //if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.OGLwindow1.param.seldesc.Selectedobjcount=0) then exit;
  count:=0;
  pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pv<>nil then
  repeat
    if pv^.Selected then
                        begin
                             pv^.deselect(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.DeSelector);
                             inc(count);
                        end
                    else
                        begin
                          pv^.select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,drawings.CurrentDWG^.selector);
                          inc(count);
                        end;

  pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pv=nil;
  drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount:=count;
  drawings.GetCurrentDWG^.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG^.wa.param.seldesc.LastSelectedObject:=nil;
  drawings.GetCurrentDWG^.wa.param.lastonmouseobject:=nil;
  //{objinsp.GDBobjinsp.}ReturnToDefault;
  //clearcp;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@InverseSelected_com,'InverseSelected',CADWG or CASelEnts,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
