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
unit uzcCommand_ElCableJoin;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,uzsbVarmanDef,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzgldrawcontext,
  uzcinterface,
  uzeentity,uzcentcable,
  uzcdrawings,uzeconsts,
  uzeGeometryTypes;

implementation

function _Cable_com_Join(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  pc1,pc2:PGDBObjCable;
  pv11,pv12,pv21,pv22:PzePoint3d;
  ir:itrec;
  DC:TDrawContext;
begin
  pc1:=nil;
  pc2:=nil;
  pv:=drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      if pv^.Selected then
        if pv^.GetObjType=GDBCableID then begin
          if pc1=nil then
            pc1:=pointer(pv)
          else if pc2=nil then
            pc2:=pointer(pv)
          else begin
            zcUI.TextMessage('Выбрано больше 2х кабелей!',TMWOHistoryOut);
            exit;
          end;
        end;
      pv:=drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pv=nil;
  if pc2=nil then begin
    zcUI.TextMessage('Выбери 2 кабеля!',TMWOHistoryOut);
    exit;
  end;
  pv11:=pc1.VertexArrayInWCS.getDataMutable(0);
  pv12:=pc1.VertexArrayInWCS.getDataMutable(pc1.VertexArrayInWCS.Count-1);
  pv21:=pc2.VertexArrayInWCS.getDataMutable(0);
  pv22:=pc2.VertexArrayInWCS.getDataMutable(pc2.VertexArrayInWCS.Count-1);

  if pv11^.LengthTo(pv21^)<eps then begin
    pc1.VertexArrayInOCS.Invert;
    pc2.VertexArrayInOCS.deleteelement(0);
    pc2.VertexArrayInOCS.copyto(pc1.VertexArrayInOCS);
    pc2.YouDeleted(drawings.GetCurrentDWG^);
  end else if pv12^.LengthTo(pv21^)<eps then begin
    pc2.VertexArrayInOCS.deleteelement(0);
    pc2.VertexArrayInOCS.copyto(pc1.VertexArrayInOCS);
    pc2.YouDeleted(drawings.GetCurrentDWG^);
  end else if pv11^.LengthTo(pv22^)<eps then begin
    pc1.VertexArrayInOCS.deleteelement(0);
    pc1.VertexArrayInOCS.copyto(pc2.VertexArrayInOCS);
    pc1.YouDeleted(drawings.GetCurrentDWG^);
    pc1:=pc2;
  end else if pv12^.LengthTo(pv22^)<eps then begin
    pc2.VertexArrayInOCS.Invert;
    pc2.VertexArrayInOCS.deleteelement(0);
    pc2.VertexArrayInOCS.copyto(pc1.VertexArrayInOCS);
    pc2.YouDeleted(drawings.GetCurrentDWG^);
  end else begin
    zcUI.TextMessage('Кабели не соединены!',TMWOHistoryOut);
    exit;
  end;

  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  pc1.formatentity(drawings.GetCurrentDWG^,dc);
  drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
  drawings.GetCurrentDWG.wa.param.seldesc.OnMouseObject:=nil;
  drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject:=nil;
  zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  clearcp;

  Result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@_Cable_com_Join,'El_Cable_Join',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
