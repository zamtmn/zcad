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
unit uzccommand_l2sl;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,uzeentline,gzctnrVectorTypes,uzcdrawings,uzcdrawing,
  zcmultiobjectcreateundocommand,uzcinterface,uzcutils,
  UGDBSelectedObjArray,gzctnrSTL,uzeentsubordinated,uzeconsts,
  uzventsuperline,uzcEnitiesVariablesExtender,uzeentityfactory,
  UUnitManager,Varman,uzbPaths,uzcTranslations;

implementation

procedure MySetObjCreateManipulator(Owner:PGDBObjGenericWithSubordinated;out domethod,undomethod:tmethod);
begin
     domethod.Code:=pointer(Owner^.GoodAddObjectToObjArray);
     domethod.Data:=Owner;
     undomethod.Code:=pointer(Owner^.GoodRemoveMiFromArray);
     undomethod.Data:=Owner;
end;


function L2SL_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pv:PGDBObjLine;
  Pair:TMyMapCounter<PGDBObjGenericWithSubordinated>.TDictionaryPair;
  ir:itrec;
  Count:integer;
  domethod,undomethod:tmethod;
  psd:PSelectedObjDesc;
  Counter:TMyMapCounter<PGDBObjGenericWithSubordinated>;
  psuperline:PGDBObjSuperLine;
  pvarext:TVariablesExtender;
  psu:ptunit;
begin
  if (drawings.GetCurrentROOT^.ObjArray.count = 0)or(drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount=0) then exit;
  //счетчик владельцев выделеных примитивов
  Counter:=TMyMapCounter<PGDBObjGenericWithSubordinated>.Create;
  Count:=0;
  //считаем владельцев выделеных линий
  //считаем выделеные линии
  psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
  if psd<>nil then repeat
    pv:=pointer(psd^.objaddr);
    if pv^.GetObjType=GDBLineID then begin
      Counter.CountKey(pv^.bp.ListPos.Owner);
      inc(Count);
    end;
    psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
  until psd=nil;
  //если нашли что конвертировать то
  if Count>0 then begin
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('L2SL');
    //создаем суперлинии
    psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
    if psd<>nil then repeat
      pv:=pointer(psd^.objaddr);
      if pv^.GetObjType=GDBLineID then begin
        psuperline := AllocEnt(GDBSuperLineID);
        psuperline^.init(nil,nil,0,pv^.CoordInWCS.lBegin,pv^.CoordInWCS.lEnd);
        pvarext:=psuperline^.GetExtension<TVariablesExtender>;
        if pvarext<>nil then begin
          psu:=units.findunit(GetSupportPath,InterfaceTranslate,'superline');
          if psu<>nil then
            pvarext.entityunit.copyfrom(psu);
        end;
        zcSetEntPropFromCurrentDrawingProp(psuperline);
        psuperline^.vp:=pv^.vp;
        zcAddEntToCurrentDrawingWithUndo(psuperline);
      end;
      psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
    until psd=nil;
    //удаляем оригинальные линии
    for Pair in Counter do begin
      MySetObjCreateManipulator(Pair.key,undomethod,domethod);
      with PushMultiObjectCreateCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),tmethod(undomethod),Pair.Value) do begin
        psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);
        if psd<>nil then repeat
          pv:=pointer(psd^.objaddr);
          if (pv^.GetObjType=GDBLineID)and(pv^.bp.ListPos.Owner=Pair.key) then begin
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
  CreateZCADCommand(@L2SL_com,'L2SL',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
