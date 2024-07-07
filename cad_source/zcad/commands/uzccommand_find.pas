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
{$IFDEF FPC}
  {$CODEPAGE UTF8}
  {$MODE DELPHI}
{$ENDIF}
unit uzcCommand_Find;
{$INCLUDE zengineconfig.inc}

interface
uses
  CsvDocument,
  uzcLog,
  SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager,
  uzeentlwpolyline,uzeentpolyline,uzeentityfactory,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzegeometry,
  uzeentity,uzeenttext,
  URecordDescriptor,typedescriptors,Varman,gzctnrVectorTypes,
  uzeparserenttypefilter,uzeparserentpropfilter,uzeentitiestypefilter,
  uzelongprocesssupport,uzeparser,uzcoimultiproperties,uzedimensionaltypes,
  uzcoimultipropertiesutil,varmandef,uzcvariablesutils,Masks,uzcregother,
  uzeparsercmdprompt,uzcinterface,uzcdialogsfiles;

resourcestring
  RSFCPOptions='Options';
  RSFCPArea='Area';
  RSFCPAction='Action';
type
  //** Тип данных для отображения в инспекторе опций
  TCompareOptions=record
    CaseSensitive:boolean;
    WholeWords:boolean;
  end;
  TSearhArea=record
    InSelection:boolean;
    InTextContent:boolean;
    InTextTemplate:boolean;
    InVariables:boolean;
    Variables:string;
  end;
  TFindAction=record
    SelectResult:Boolean;
  end;
  TFindCommandParam=record
    Options:TCompareOptions;
    Area:TSearhArea;
    Action:TFindAction;
  end;

var
  FindCommandParam:TFindCommandParam; //**<  Переменная содержащая опции команды

implementation

function GetFindCommandParam:PUserTypeDescriptor;
begin
  result:=SysUnit^.TypeName2PTD('TFindCommandParam');
  if result=nil then begin
    result:=SysUnit^.RegisterType(TypeInfo(FindCommandParam));//регистрируем тип данных в зкадном RTTI
    SysUnit^.SetTypeDesk(TypeInfo(FindCommandParam),[RSFCPOptions,RSFCPArea,RSFCPAction],[FNProgram]);//Даем програмные имена параметрам, по идее это должно быть в ртти, но ненашел
  end;
end;

function FindCommandParam_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  zcShowCommandParams(GetFindCommandParam,@FindCommandParam);
  result:=cmd_ok;
end;

function Find_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  zcShowCommandParams(GetFindCommandParam,@FindCommandParam);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  FindCommandParam.Options.CaseSensitive:=False;
  FindCommandParam.Options.WholeWords:=False;
  FindCommandParam.Area.InSelection:=True;
  FindCommandParam.Area.InTextContent:=True;
  FindCommandParam.Area.InTextTemplate:=false;
  FindCommandParam.Area.InVariables:=false;
  FindCommandParam.Area.Variables:='NMO_Name';
  FindCommandParam.Action.SelectResult:=False;

  CreateZCADCommand(@FindCommandParam_com,'FindParams',0,0);
  CreateZCADCommand(@Find_com,'Find',CADWG,0);
  CreateZCADCommand(@Find_com,'FindNext',CADWG,0);
  CreateZCADCommand(@Find_com,'FindPrev',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
