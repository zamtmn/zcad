{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Bobrov Vladimir)
}
{$mode objfpc}{$H+}
unit uzvdeverrors;

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzcenitiesvariablesextender,
  varmandef,
  UUnitManager,
  uzbpaths,
  uzctranslations,
  uzcinterface,
  uzcvariablesutils,
  gzctnrVectorTypes,
  uzeentdevice,
  uzcdrawings,
  uzeconsts,
  uzvconsts,
  uzeentity,Varman;

procedure uzvdeverrorsAllClearDev();  //запуск очистки ошибок во всех устройствах на чертеже
procedure addDevErrors(pObjDevice:PGDBObjDevice;textError:string);        //добавление ошибки в устройство

implementation

procedure addDevErrors(pObjDevice:PGDBObjDevice;textError:string);
var
  pvd:pvardesk;
begin
  //ZCMsgCallBackInterface.TextMessage('Добавляем ошибкку = ' + textError,TMWOHistoryOut);
  pvd:=FindVariableInEnt(pObjDevice,vCADihaveError);
  if pvd<>nil then
    begin
     pBoolean(pvd^.data.Addr.Instance)^:=true;
    end;
  pvd:=FindVariableInEnt(pObjDevice,vCADerrorsText);
  if pvd<>nil then
    if Pos(textError, pString(pvd^.data.Addr.Instance)^) = 0 then
      pString(pvd^.data.Addr.Instance)^:=pString(pvd^.data.Addr.Instance)^ + textError;
end;

procedure uzvdeverrorsAllClearDev();
var
  pvd:pvardesk;
  ir:itrec;
  countDevError,countDev:integer;
  pobj:pGDBObjEntity;   //выделеные объекты в пространстве листа
  pObjDevice:PGDBObjDevice;

begin
    ZCMsgCallBackInterface.TextMessage('Запущена функция очистки ошибок в устройствах!',TMWOHistoryOut);

    countDevError:=0;
    countDev:=0;
    //+++Выбираем примитивы/устройства к которым будет добавляться подключение+++//
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
          // Заполняем список всех GDBDeviceID
          if pobj^.GetObjType=GDBDeviceID then
            begin
              inc(countDev);
              pObjDevice:= PGDBObjDevice(pobj);
              //numConnect:=0;

              pvd:=FindVariableInEnt(pObjDevice,vCADihaveError);
              if pvd<>nil then
                begin
                 pBoolean(pvd^.data.Addr.Instance)^:=false;
                 inc(countDevError);
                end;
              pvd:=FindVariableInEnt(pObjDevice,vCADerrorsText);
              if pvd<>nil then
                 pString(pvd^.data.Addr.Instance)^:='';
            end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    ZCMsgCallBackInterface.TextMessage('Кол-во обработанных устройств (device) = ' + IntToStr(countDev) + 'шт',TMWOHistoryOut);
    ZCMsgCallBackInterface.TextMessage('Кол-во очищенных устройств, у которых есть поле ошибки = ' + IntToStr(countDevError) + 'шт',TMWOHistoryOut);

  //result:=cmd_ok;
end;

function uzvdeverrorsClear_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pvd:pvardesk;
  ir:itrec;
  countDevError,countDev:integer;
  pobj:pGDBObjEntity;   //выделеные объекты в пространстве листа
  pObjDevice:PGDBObjDevice;

begin
    ZCMsgCallBackInterface.TextMessage('Запущена функция очистки ошибок в устройствах!',TMWOHistoryOut);

    countDevError:=0;
    countDev:=0;
    //+++Выбираем примитивы/устройства к которым будет добавляться подключение+++//
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat
          // Заполняем список всех GDBDeviceID
          if pobj^.GetObjType=GDBDeviceID then
            begin
              inc(countDev);
              pObjDevice:= PGDBObjDevice(pobj);
              //numConnect:=0;

              pvd:=FindVariableInEnt(pObjDevice,vCADihaveError);
              if pvd<>nil then
                begin
                 pBoolean(pvd^.data.Addr.Instance)^:=false;
                 inc(countDevError);
                end;
              pvd:=FindVariableInEnt(pObjDevice,vCADerrorsText);
              if pvd<>nil then
                 pString(pvd^.data.Addr.Instance)^:='';
            end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    ZCMsgCallBackInterface.TextMessage('Кол-во обработанных устройств (device) = ' + IntToStr(countDev) + 'шт',TMWOHistoryOut);
    ZCMsgCallBackInterface.TextMessage('Кол-во очищенных устройств, у которых есть поле ошибки = ' + IntToStr(countDevError) + 'шт',TMWOHistoryOut);

  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@uzvdeverrorsClear_com,'uzvdeverrorsclear',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
