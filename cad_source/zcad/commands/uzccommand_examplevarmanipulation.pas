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
unit uzccommand_ExampleVarManipulation;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzcenitiesvariablesextender,
  varmandef,Varman,UUnitManager,
  uzctranslations,
  uzbpaths,
  gzctnrVectorTypes,
  uzcstrconsts,uzeentity;

implementation

function ExampleVarManipulation_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  Varext:TVariablesExtender;
  pe:PGDBObjEntity;
  pvd,pvd2:pvardesk;
  vd:vardesk;
  pu:PTSimpleUnit;
  ir:itrec;
  test:string;
const
  VarName='TST_Test';
  VarType='String';
begin
  //выбираем примитив
  if commandmanager.getentity(rscmSelectSourceEntity,pe) then begin
    //получаем расширение с переменными у выбранного примитива
    Varext:=pe^.GetExtension<TVariablesExtender>;
    //ищем в нем переменную
    if Varext=nil then //незабываем что самого расширения у примитива может неоказаться
      pvd:=nil
    else
      pvd:=Varext.entityunit.FindVariable(VarName);

    if pvd<>nil then
      //переменная у примитива найдена, будем удалять
      Varext.entityunit.InterfaceVariables.RemoveVariable(pvd)
    else begin
      //переменная у примитива не найдена, будем создавать
      //создаем расширение если его нет
      if Varext=nil then begin
        Varext:=TVariablesExtender.Create(pe);//создаем расширение
        pe^.AddExtension(Varext);//добавляем его к примитиву
      end;
      vd:=Varext.entityunit.CreateVariable(VarName,VarType);//в vd вернется копия созданного описателя переменной
      pstring(vd.data.Addr.GetInstance)^:='тест';//можно работать с ним, помня что он всеголишь копия
      pvd:=Varext.entityunit.FindVariable(VarName);//а тут уже указатель на настоящий описатель переменной
      pvd^.username:='страшноеИмя';
      ProcessVariableAttributes(pvd^.attrib,vda_RO,0);//ставим ридонли для инспектора

      //пытаемся найти или загрузить модуль
      pu:=units.findunit(GetSupportPath,//пути по которым будет искаться юнит если он еще небыл загружен
                         InterfaceTranslate,//процедура локализации которая будет пытаться перевести на русский все что можно при загрузке
                         'uentrepresentation');//имя модуля
      if pu<>nil then begin //если нашли
        pvd2:=pu^.InterfaceVariables.vardescarray.beginiterate(ir); //пробуем перебрать все определения переменных в интерфейсной части
        if pvd2<>nil then //переменные есть
          repeat
            //работаем с очередной переменной
            test:=pvd2^.name; //имя переменной
            test:=pvd2^.username; //пользовательское имя переменной
            test:=pvd2^.data.PTD.TypeName; //имя имя типа; pvd2^.data.PTD - указатель на тип


            vd:=Varext.entityunit.CreateVariable(pvd2^.name,pvd2^.data.PTD.TypeName);//создаем такуюже переменную
            pvd:=Varext.entityunit.FindVariable(VarName);//находим описатель созданой переменной
            pvd^.username:=pvd2^.username;//пользовательское имя устанавливаем отдлельно

            pvd2^.data.PTD.CopyInstanceTo(pvd2^.data.Addr.Instance,pvd.data.Addr.Instance);//копируем значение из старой переменной в новую

            pvd2:=pu^.InterfaceVariables.vardescarray.iterate(ir); //следующая переменная
          until pvd2=nil;
      end;

    end;
  end;
    result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ExampleVarManipulation_com,'ExampleVarManipulation',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
