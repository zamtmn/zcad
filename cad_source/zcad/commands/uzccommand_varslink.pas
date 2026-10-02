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
unit uzccommand_VarsLink;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcenitiesvariablesextender,
  uzccommandsmanager,uzeentity,
  uzcinterface;

resourcestring
  rscmSelectEntityWithMainFunction='Select entity with main function';
  rscmSelectLinkedEntity='Select linked entity';
  rscmSelectEntityWithextdrVariables='Please select entity with '+VariablesExtenderName;
  rscmCannotBeLinked='Cannot be linked';

implementation

function VarsLink_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pobj:pGDBObjEntity;
  pmainobj:pGDBObjEntity;

  pCentralVarext,pVarext:TVariablesExtender;
begin
  pmainobj:=nil;
  repeat
    //пробуем выбрать примитив главную функцию
    if pmainobj=nil then
      if commandmanager.getentity(rscmSelectEntityWithMainFunction,pmainobj)<>IRNormal then
        exit(cmd_ok);
    //у примитива должно быть расширение переменных
    pCentralVarext:=pmainobj^.GetExtension<TVariablesExtender>;
    if pCentralVarext=nil then begin
      pmainobj:=nil;
      zcUI.TextMessage(rscmSelectEntityWithextdrVariables,TMWOShowError);
    //примитив должен уметь добавлять делегатов (сам не являться делегатом)
    end else if not pCentralVarext.canAddDelegate then begin
      zcUI.TextMessage(rscmSelectEntityWithMainFunction,TMWOShowError);
      pmainobj:=nil;
      pCentralVarext:=nil;
    end;
  until pCentralVarext<>nil;

  repeat
    //пробуем выбрать примитив делегата
    if commandmanager.getentity(rscmSelectLinkedEntity,pobj)<>IRNormal then
      exit(cmd_ok);
    //у примитива должно быть расширение переменных
    pVarext:=pobj^.GetExtension<TVariablesExtender>;
    if pVarext=nil then begin
      zcUI.TextMessage(rscmSelectEntityWithextdrVariables,TMWOShowError);
    //примитив главной функции должен добавить этого делегата
    //(проверки на зацикленгности и добавление самого себя)
    end else if not pCentralVarext.canAddDelegate(pobj,pVarext) then begin
      zcUI.TextMessage(rscmCannotBeLinked,TMWOShowError);
    end else begin
      //все ок, добавляем
      pCentralVarext.addDelegate(pobj,pVarext);
    end;
  until False;

  Result:=cmd_ok;
end;



initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@VarsLink_com,'VarsLink',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
