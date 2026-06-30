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
unit uzccommand_ReportsUpdate;

interface

uses
  SysUtils,
  gzctnrVectorTypes,
  uzcdrawings,
  uzcLog,
  UGDBSelectedObjArray,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,uzeentdevice,
  uzcExtdrReport,
  uzeentsubordinated,
  uzcstrconsts,uzcinterface,uzeconsts,
  uzeentgenericsubentry,uzcdrawing,zcmultiobjectcreateundocommand;

implementation

const
  cmdName='ReportsUpdate';

procedure MySetObjCreateManipulator(Owner:pGDBObjEntity;
  out domethod,undomethod:tmethod);
begin
  domethod.Code:=pointer(PGDBObjGenericSubEntry(Owner)^.GoodAddObjectToObjArray);
  domethod.Data:=Owner;
  undomethod.Code:=pointer(PGDBObjGenericSubEntry(Owner)^.GoodRemoveMiFromArray);
  undomethod.Data:=Owner;
end;

procedure Erase_old(const Context:TZCADCommandContext;pdev:PGDBObjDevice);
var
  pv:pGDBObjEntity;
  ir:itrec;
  Count:integer;
  domethod,undomethod:tmethod;
begin
  Count:=0;
  pv:=pdev.VarObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      Inc(Count);
      pv:=pdev.VarObjArray.iterate(ir);
    until pv=nil;
  if Count>0 then begin
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Erase_old');
      MySetObjCreateManipulator(pdev,undomethod,domethod);
      with PushMultiObjectCreateCommand(
          PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,tmethod(domethod),
          tmethod(undomethod),pdev.VarObjArray.Count) do begin

              pv:=pdev.VarObjArray.beginiterate(ir);
              if pv<>nil then
              repeat
                AddObject(pv);
                pv^.Selected:=False;

                pv:=pdev.VarObjArray.iterate(ir);
              until pv=nil;

        FreeArray:=False;
        comit;
      end;
    PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;
  end;
end;


function ReportsUpdate_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pEntity:PGDBObjEntity;
  ir:itrec;
  Count:integer;
  DoMethod,UndoMethod:TMethod;
  ext:TReportExtender;
  psd:PSelectedObjDesc;
  RepE:TReportExtender;
  tmpCtx:TZCADCommandContext;
begin
  try
      Count:=0;
      tmpCtx:=Context;
      psd:=drawings.GetCurrentDWG.SelObjArray.beginiterate(ir);

      if psd<>nil then
        repeat
          RepE:=psd^.objaddr^.GetExtension<TReportExtender>;
            if RepE<>nil then begin
              pEntity:=psd^.objaddr;
              if pEntity^.GetObjType=GDBDeviceID then begin
                Erase_old(Context,PGDBObjDevice(pEntity));
                tmpCtx.POwner:=pEntity;
                //tmpCtx.PArr:=@PGDBObjDevice(pEntity).VarObjArray;
              end else begin
                tmpCtx.POwner:=nil;
                //tmpCtx.PArr:=nil;
              end;
              RepE.Execute(tmpCtx);
              Inc(Count);
            end;
          psd:=drawings.GetCurrentDWG.SelObjArray.iterate(ir);
        until psd=nil;
      zcUI.TextMessage(format(rscmNEntitiesProcessed,[Count]),TMWOHistoryOut);
  finally
    Result:=cmd_ok;
  end;
end;


initialization
programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
  LM_Info,UnitsInitializeLMId);
CreateZCADCommand(@ReportsUpdate_com,cmdName,CADWG or CASelEnts,0);

finalization
ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
  LM_Info,UnitsFinalizeLMId);
end.
