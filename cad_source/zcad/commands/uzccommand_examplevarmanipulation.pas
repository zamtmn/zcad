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
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
{$mode delphi}
unit uzccommand_ExampleVarManipulation;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzcenitiesvariablesextender,
  varmandef,
  uzcstrconsts,uzeentity;

implementation

function ExampleVarManipulation_com(operands:TCommandOperands):TCommandResult;
var
  Varext:TVariablesExtender;
  pe:PGDBObjEntity;
  pvd:pvardesk;
  vd:vardesk;
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
    end;
  end;
    result:=cmd_ok;
end;


initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@ExampleVarManipulation_com,'ExampleVarManipulation',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
