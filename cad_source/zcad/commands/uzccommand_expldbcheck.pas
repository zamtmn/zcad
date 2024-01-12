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
unit uzccommand_explDbCheck;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzcdrawings,
  uzegeometry,
  uzeentity,uzeenttext,uzeconsts,
  uzbPaths,uzcTranslations,
  URecordDescriptor,typedescriptors,Varman,varmandef,UUnitManager,
  uzcdevicebase,uzcdevicebaseabstract,
  uzcinterface,
  uzbtypes,
  uzcenitiesvariablesextender;

implementation

const
    CommandName='explDbCheck';

function explDbCheck_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pEntity:PGDBObjEntity;
  EntVarExt:TVariablesExtender;
  pdbu:ptunit;
  pum:PTUnitManager;
  pvn,pvnDB:pvardesk;
  PBaseObject:PDbBaseObject;
begin
  pum:=drawings.GetCurrentDWG^.GetDWGUnits;//получаем модули подключеные к чертежу
  if pum<>nil then begin
    pdbu:=pum^.findunit(GetSupportPath,InterfaceTranslate,DrawingDeviceBaseUnitName);//получаем модуль БД чертежа
    if pdbu<>nil then
      while commandmanager.getentity(rscmSelectDestinationEntity,pEntity) do begin
        EntVarExt:=pEntity^.GetExtension<TVariablesExtender>;
        if EntVarExt<>nil then begin
          pvn:=EntVarExt.entityunit.FindVariable('DB_link');//ищем у примитива переменную в которой хранится
                                                            //имя связанной переменной из модуля БД чертежа
          if pvn<>nil then begin
            pvnDB:=pdbu.FindVariable(pvn.data.PTD.GetValueAsString(pvn.data.Addr.Instance));
            if pvnDB<>nil then begin
              //если нашли, то доступ как к базовому объекту БД можно получить так
              PBaseObject:=pvnDB.data.Addr.Instance;
              ZCMsgCallBackInterface.TextMessage(format('DbBaseObject.Name=%s',[PDeviceDbBaseObject(PBaseObject)^.Name]),TMWOHistoryOut);
              //проверяем явлляется ли то что нашли наследником от DeviceDbBaseObject, если является, получаем доступ как к кабелю
              if IsIt(TypeOf(PBaseObject^),typeof(DeviceDbBaseObject)) then begin
                ZCMsgCallBackInterface.TextMessage(format('DeviceDbBaseObject.UID=%s',[PDeviceDbBaseObject(PBaseObject)^.UID]),TMWOHistoryOut);
                ZCMsgCallBackInterface.TextMessage(format('DeviceDbBaseObject.NameShortTemplate=%s',[PDeviceDbBaseObject(PBaseObject)^.NameShortTemplate]),TMWOHistoryOut);
              end;
              //проверяем явлляется ли то что нашли наследником от кабеля, если является, получаем доступ как к кабелю
              if IsIt(TypeOf(PBaseObject^),typeof(CableDeviceBaseObject)) then begin
                ZCMsgCallBackInterface.TextMessage(format('CableDeviceBaseObject.CoreCrossSection=%g',[PCableDeviceBaseObject(PBaseObject)^.CoreCrossSection]),TMWOHistoryOut);
                ZCMsgCallBackInterface.TextMessage(format('CableDeviceBaseObject.NumberOfCores=%g',[PCableDeviceBaseObject(PBaseObject)^.NumberOfCores]),TMWOHistoryOut);
              end;
            end;
          end;
        end;
      end;
  end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@explDbCheck_com,CommandName,  CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
