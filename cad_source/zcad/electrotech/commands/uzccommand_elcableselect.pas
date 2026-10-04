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
unit uzcCommand_ElCableSelect;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzcutils,
  uzeentity,uzeentdevice,uzcentcable,
  uzcdrawings,uzeconsts;

implementation

function _Cable_com_Select(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir,irnpa:itrec;
  ptn:PTNodeProp;
  currentobj:PGDBObjDevice;
begin
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if pv^.GetObjType=GDBCableID then begin
          ptn:=PGDBObjCable(pv)^.NodePropArray.beginiterate(irnpa);
          if ptn<>nil then
            repeat
              if ptn^.DevLink<>nil then begin
                CurrentObj:=pointer(ptn^.DevLink^.bp.ListPos.owner);
                if CurrentObj<>nil then
                  CurrentObj^.select(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,
                    drawings.CurrentDWG^.selector);
              end;

              ptn:=PGDBObjCable(pv)^.NodePropArray.iterate(irnpa);
            until ptn=nil;
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  zcRedrawCurrentDrawing;
  Result:=cmd_ok;
end;

var
  csel:pCommandFastObjectPlugin;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  csel:=CreateZCADCommand(@_Cable_com_Select,'El_Cable_Select',CADWG,0);
  csel.CEndActionAttr:=[];

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
