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
{$mode delphi}
unit uzvremoveconnection;

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
  gzctnrVectorTypes,
  uzeentdevice,
  uzcdrawings,
  uzeconsts,
  uzvconsts,
  uzeentity,Varman;

implementation

function uzvremoveconnection_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  Varext:TVariablesExtender;
  //pe:PGDBObjEntity;
  pvd,pvdadd:pvardesk;
  pu:PTSimpleUnit;
  vd:vardesk;
  ir,iradd:itrec;
  varName:string;
  countEnt,countDev,numConnect:integer;
  pobj:pGDBObjEntity;   //выделеные объекты в пространстве листа
  pObjDevice:PGDBObjDevice;

begin
    //Ищем модуль и загружаем его
  pu:=units.findunit(GetSupportPath,//пути по которым будет искаться юнит если он еще небыл загружен
                     InterfaceTranslate,//процедура локализации которая будет пытаться перевести на русский все что можно при загрузке
                     'slcabagenmodul');//имя модуля
  if pu<>nil then begin //если нашли

    countEnt:=0;
    countDev:=0;
    //+++Выбираем примитивы/устройства к которым будет добавляться подключение+++//
    pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
    if pobj<>nil then
      repeat

        if pobj^.selected then
          begin
            // Заполняем список всех GDBDeviceID
            if pobj^.GetObjType=GDBDeviceID then
              begin
                pObjDevice:= PGDBObjDevice(pobj);
                numConnect:=0;
                //получаем расширение с переменными у выбранного примитива
                Varext:=pObjDevice^.GetExtension<TVariablesExtender>;
                //ищем в нем переменную
                if Varext=nil then //незабываем что самого расширения у примитива может неоказаться
                   pvd:=nil
                else
                  repeat
                    inc(numConnect);
                    pvd:=Varext.entityunit.FindVariable(velec_VarNameForConnectBefore+IntToStr(numConnect)+'_'+velec_VarNameForConnectAfter_SLTypeagen);
                  until pvd=nil;
                  //ZCMsgCallBackInterface.TextMessage('numConnect = ' + inttostr(numConnect),TMWOHistoryOut);
                  //удаляем подключение
                  //ZCMsgCallBackInterface.TextMessage('numConnect = ' + inttostr(numConnect),TMWOHistoryOut);
                  if (numConnect-1 > 0) then begin
                    pvdadd:=pu^.InterfaceVariables.vardescarray.beginiterate(iradd); //пробуем перебрать все определения переменных в интерфейсной части
                    if pvdadd<>nil then //переменные есть
                      repeat
                        varName:=pvdadd^.name; //имя переменной
                        //ZCMsgCallBackInterface.TextMessage('numConnect = ' + inttostr(numConnect),TMWOHistoryOut);
                        varName:=StringReplace(varName,velec_VarNameForConnectBefore+'1',velec_VarNameForConnectBefore+inttostr(numConnect-1),[rfReplaceAll, rfIgnoreCase]);
                        //ZCMsgCallBackInterface.TextMessage('varName = ' + varName,TMWOHistoryOut);
                        pvd:=Varext.entityunit.FindVariable(varName);//а тут уже указатель на настоящий описатель переменной
                        if pvd<>nil then
                          //переменная у примитива найдена, будем удалять
                          Varext.entityunit.InterfaceVariables.RemoveVariable(pvd);
                        pvdadd:=pu^.InterfaceVariables.vardescarray.iterate(iradd); //следующая переменная
                      until pvdadd=nil;
                  end;
                inc(countDev);
              end;
          inc(countEnt);
          end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    ZCMsgCallBackInterface.TextMessage('Кол-во ввыбранных элементов = ' + IntToStr(countEnt),TMWOHistoryOut);
    ZCMsgCallBackInterface.TextMessage('Устройство. Удалено подключение = ' + IntToStr(countDev) + 'шт',TMWOHistoryOut);

  end;
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@uzvremoveconnection_com,'uzvremoveconnection',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
