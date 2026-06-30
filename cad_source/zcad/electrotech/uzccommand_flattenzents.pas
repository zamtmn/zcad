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
unit uzcCommand_FlattenZEnts;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,uzcdrawings,
  uzcinterface,uzcutils,
  UGDBSelectedObjArray,uzeentgenericsubentry,uzeconsts,
  uzeentblockinsert,uzcentcable,uzcentnet,uzeentline,uzcstrconsts;


implementation

function FlattanZEnts_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir:itrec;
  i:integer;
  Count:integer;
  pline:PGDBObjLine;
  psd:PSelectedObjDesc;
begin
  if (drawings.GetCurrentROOT^.ObjArray.Count=0)
   or(drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then
    exit;
  Count:=0;
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then
    repeat
      pv:=psd^.objaddr;
      case pv^.GetObjType of
        GDBDeviceID:begin
          PGDBObjBlockInsert(pv)^.Local.P_insert.z:=0;
          pv^.YouChanged(Context.PDWG^);
          inc(count);
        end;
        GDBCableID:begin
          for i:=0 to PGDBObjCable(pv)^.VertexArrayInOCS.Count-1 do
            PGDBObjCable(pv)^.VertexArrayInOCS.getDataMutable(i)^.z:=0;
          pv^.YouChanged(Context.PDWG^);
          inc(count);
        end;
        GDBNetID:begin
          for i:=0 to PGDBObjNet(pv)^.ObjArray.Count-1 do begin
            pline:=pointer(PGDBObjNet(pv)^.ObjArray.getData(i));
            if pline<>nil then
              if pline^.GetObjType=GDBLineID then begin
                pline^.CoordInOCS.lBegin.z:=0;
                pline^.CoordInOCS.lEnd.z:=0;
              end;
          end;
          pv^.YouChanged(Context.PDWG^);
          inc(count);
        end;
      end;
      psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
    until psd=nil;
  if Count>0 then begin
    zcUI.TextMessage(Format(rscmNEntitiesProcessed,[Count]),TMWOHistoryOut);
    zcRedrawCurrentDrawing;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@FlattanZEnts_com,'FlattanZEnts',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
