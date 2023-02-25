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
unit uzccommand_extdrRemove;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,uzcdrawings,uzcstrconsts,uzeentityextender,
  uzcinterface;

implementation

function extdrRemove_com(operands:TCommandOperands):TCommandResult;
var
  extdr:TMetaEntityExtender;
  pEntity,pLastSelectedEntity:PGDBObjEntity;
  ir:itrec;
  count:Integer;
begin
  try
    if EntityExtenders.tryGetValue(uppercase(operands),extdr) then begin
      count:=0;

      //обрабатываем последний выбраный примитив
      //на данный момент только так можно работать с примитивами в динамической части устройств
      pLastSelectedEntity:=drawings.GetCurrentOGLWParam.SelDesc.LastSelectedObject;
      if pLastSelectedEntity<>nil then begin
        if pLastSelectedEntity^.GetExtension(extdr)<>nil then begin
          pLastSelectedEntity^.RemoveExtension(extdr);
          inc(count);
        end;
      end;

      pEntity:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
      if pEntity<>nil then
      repeat
        if (pEntity^.Selected)and(pEntity<>pLastSelectedEntity) then
          if pEntity^.GetExtension(extdr)<>nil then begin
            pEntity^.RemoveExtension(extdr);
            inc(count);
          end;
        pEntity:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pEntity=nil;
      ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
    end else
      ZCMsgCallBackInterface.TextMessage(format(rscmExtenderNotFound,[operands]),TMWOHistoryOut);
  finally
    result:=cmd_ok;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandFastObjectPlugin(@extdrRemove_com,'extdrRemove',CADWG or CASelEnts,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
