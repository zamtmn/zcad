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
unit uzcCommand_Hatch2Line;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,
  uzcinterface,uzcutils,
  UGDBSelectedObjArray,uzeconsts,
  uzeentblockinsert,uzcentcable,uzcentnet,uzeentline,uzeEntHatch,uzcstrconsts,
  uzegeometrytypes,uzegeometry,UGDBPolyLine2DArray,uzeentityfactory,uzCtnrVectorPBaseEntity;


implementation

//GDBPolyline2DArray

function TryConvertGDBPolyline2DArrayToLine(var APolyLine:GDBPolyline2DArray;out p1,p2:TzePoint2d):boolean;
var
  l01,l12:double;
  v01,v12:TzeVector2d;
begin
  case APolyLine.Count of
    4:if APolyLine.closed and (IsPoint2DEqual(APolyLine.getDataMutable(3)^,APolyLine.getDataMutable(0)^)) then
      exit(false);
    5:if (not APolyLine.closed) and (not IsPoint2DEqual(APolyLine.getDataMutable(4)^,APolyLine.getDataMutable(0)^)) then
      exit(false);
    else
      exit(false);
  end;
  v01:=(APolyLine.getDataMutable(1)^-APolyLine.getDataMutable(0)^).asVector2d;
  v12:=(APolyLine.getDataMutable(2)^-APolyLine.getDataMutable(1)^).asVector2d;
  l01:=v01.Length;
  l12:=v12.Length;
  if l01>l12 then begin
    v12:=v12/2;
    p1:=APolyLine.getPFirst^+v12;
    p2:=APolyLine.getDataMutable(1)^+v12;
  end else begin
    v01:=v01/2;
    p1:=APolyLine.getPFirst^+v01;
    p2:=APolyLine.getDataMutable(2)^-v01;
  end;
  result:=true;
end;

function TryConvertHatchToLine(var AHatch:GDBObjHatch;out p1,p2:TzePoint2d):boolean;
begin
  if AHatch.Path.paths.Count<>1 then
    exit(false);
  result:=TryConvertGDBPolyline2DArrayToLine(AHatch.Path.paths.getDataMutable(0)^,p1,p2);
end;

function Hatch2line_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count:integer;
  pline:PGDBObjLine;
  psd:PSelectedObjDesc;
  p1,p2:TzePoint2d;
  UndoStartMarkerPlaced:boolean;
  processed:TZctnrVectorPGDBaseEntity;
begin
  if (Context.PDWG^.wa.param.seldesc.Selectedobjcount=0) then
    exit;
  Count:=0;
  psd:=Context.PDWG^.SelObjArray.beginiterate(ir);
  if psd<>nil then
    repeat
      pv:=psd^.objaddr;
      case pv^.GetObjType of
        GDBHatchID:begin
          if TryConvertHatchToLine(PGDBObjHatch(pv)^,p1,p2) then begin
            if count=0 then
              processed.init(Context.PDWG^.SelObjArray.Count);
            inc(Count);
            processed.PushBackData(pv);

            pline:=AllocEnt(GDBLineID);
            pline^.init(nil,nil,LnWtByLayer,VectorTransform3d(p1.asPoint3d,PGDBObjHatch(pv)^.GetMatrix^),VectorTransform3d(p2.asPoint3d,PGDBObjHatch(pv)^.GetMatrix^));

            //присваиваем текущие цвет, толщину, и т.д. от настроек чертежа
            zcSetEntPropFromCurrentDrawingProp(pline);

            //добавляем в чертеж
            zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'Hatch2line');
            zcAddEntToDrawingWithUndo(pline,Context.PDWG^);
          end;
        end
      end;
      psd:=Context.PDWG^.SelObjArray.iterate(ir);
    until psd=nil;
  if Count>0 then begin
    Context.PDWG^.DeSelectAll;
    Context.PDWG^.SelectEnts(processed);
    processed.Clear;
    processed.done;
    zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
    zcUI.TextMessage(Format(rscmNEntitiesProcessed,[Count]),TMWOHistoryOut);
    zcUI.Do_GUIaction(nil,zcMsgUIRePrepareObject);
    zcRedrawCurrentDrawing;
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  with CreateZCADCommand(@Hatch2line_com,'Hatch2Line',CADWG,0)^ do begin
    //CEndActionAttr:=CEndActionAttr+[CEDeSelect];
  end;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
