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
unit uzvaddconnection;

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

function uzvaddconnection_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
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
                  //Добавляем подключение
                  pvdadd:=pu^.InterfaceVariables.vardescarray.beginiterate(iradd); //пробуем перебрать все определения переменных в интерфейсной части
                  if pvdadd<>nil then //переменные есть
                    repeat
                      varName:=pvdadd^.name; //имя переменной
                      //ZCMsgCallBackInterface.TextMessage('1 = ' + varName,TMWOHistoryOut);
                      varName:=StringReplace(varName,velec_VarNameForConnectBefore+'1',velec_VarNameForConnectBefore+inttostr(numConnect),[rfReplaceAll, rfIgnoreCase]);
                      //ZCMsgCallBackInterface.TextMessage('3 = ' + varName,TMWOHistoryOut);
                      vd:=Varext.entityunit.CreateVariable(varName,pvdadd^.data.PTD.TypeName);//в vd вернется копия созданного описателя переменной
                      //pstring(vd.data.Addr.GetInstance)^:='тест';//можно работать с ним, помня что он всеголишь копия
                      pvd:=Varext.entityunit.FindVariable(varName);//а тут уже указатель на настоящий описатель переменной
                      pvd^.username:=pvdadd^.username;
                      //ProcessVariableAttributes(pvd^.attrib,vda_RO,0);//ставим ридонли для инспектора

                      pvdadd^.data.PTD.CopyInstanceTo(pvdadd^.data.Addr.Instance,pvd.data.Addr.Instance);//копируем значение из старой переменной в новую

                      RegisterVarCategory(velec_VarNameForConnectBefore+inttostr(numConnect),velec_VarNameForConnectBeforeName+inttostr(numConnect),@InterfaceTranslate);

                      ////работаем с очередной переменной
                      //test:=pvdadd^.name; //имя переменной
                      //ZCMsgCallBackInterface.TextMessage('1-' + test,TMWOHistoryOut);
                      //test:=pvdadd^.username; //пользовательское имя переменной
                      //ZCMsgCallBackInterface.TextMessage('2-' + test,TMWOHistoryOut);
                      //test:=pvdadd^.data.PTD.TypeName; //имя имя типа; pvd^.data.PTD - указатель на тип
                      //ZCMsgCallBackInterface.TextMessage('3-' + test,TMWOHistoryOut);

                      pvdadd:=pu^.InterfaceVariables.vardescarray.iterate(iradd); //следующая переменная
                    until pvdadd=nil;
                inc(countDev);
              end;
          inc(countEnt);
          end;
        pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
      until pobj=nil;

    ZCMsgCallBackInterface.TextMessage('Кол-во ввыбранных элементов = ' + IntToStr(countEnt),TMWOHistoryOut);
    ZCMsgCallBackInterface.TextMessage('Устройство. Добавлено подключение = ' + IntToStr(countDev) + 'шт',TMWOHistoryOut);

  end;
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@uzvaddconnection_com,'uzvaddconnection',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
