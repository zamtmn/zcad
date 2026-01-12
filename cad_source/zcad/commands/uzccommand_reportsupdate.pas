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
  uzcstrconsts,uzcinterface,uzeconsts;

implementation

const
  cmdName='ReportsUpdate';

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
