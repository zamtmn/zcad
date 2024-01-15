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

unit uzcregelectrotechfeatures;
{$INCLUDE zengineconfig.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,uzctranslations,
     uzbstrproc,Varman,SysUtils,
     UBaseTypeDescriptor,uzbtypes,uzctnrVectorBytes,strmy,varmandef,
     uzcsysparams,TypeDescriptors,URecordDescriptor,
     uzcLog,uzceltechtreeprop,uzcefstringstreeselector,
     uzccommandsimpl,uzccommandsabstract,uzctypesdecorations,zcobjectinspectorui,
     uzcoidecorations,
     Forms,Controls,
     uzcinterface,uzcuitypes;
var
  StringsTreeSelector:TStringsTreeSelector=nil;
implementation

function FunctionsTest_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  StringsTreeSelector:=TStringsTreeSelector.Create(nil);
  StringsTreeSelector.fill(FunctionsTree.BlobTree);
  StringsTreeSelector.ShowModal;
  freeandnil(StringsTreeSelector);
  result:=cmd_ok;
end;

function RepresentationsTest_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  StringsTreeSelector:=TStringsTreeSelector.Create(nil);
  StringsTreeSelector.fill(RepresentationsTree.BlobTree);
  StringsTreeSelector.ShowModal;
  freeandnil(StringsTreeSelector);
  result:=cmd_ok;
end;

procedure RunEentityRepresentationEditor(PInstance:Pointer);
var
   modalresult:integer;
begin
     if not assigned(StringsTreeSelector) then
     begin
     StringsTreeSelector:=TStringsTreeSelector.create(application.MainForm);
     StringsTreeSelector.BoundsRect:=GetBoundsFromSavedUnit('StringsTreeSelectorWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
     end;
     StringsTreeSelector.clear;
     StringsTreeSelector.fill(RepresentationsTree.BlobTree);
     StringsTreeSelector.setValue(PStringTreeType(PInstance)^);
     StringsTreeSelector.caption:=('EentityRepresentationEditor');
     StringsTreeSelector.ActiveControl:=StringsTreeSelector.StringsTree;
     modalresult:=ZCMsgCallBackInterface.DOShowModal(StringsTreeSelector);
     if modalresult=ZCMrOk then
       PStringTreeType(PInstance)^:=StringsTreeSelector.TreeResult;
end;

procedure RunEentityFunctionEditor(PInstance:Pointer);
var
   modalresult:integer;
begin
     if not assigned(StringsTreeSelector) then
     begin
     StringsTreeSelector:=TStringsTreeSelector.create(application.MainForm);
     StringsTreeSelector.BoundsRect:=GetBoundsFromSavedUnit('StringsTreeSelectorWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
     end;
     StringsTreeSelector.clear;
     StringsTreeSelector.fill(FunctionsTree.BlobTree);
     StringsTreeSelector.setValue(PStringTreeType(PInstance)^);
     StringsTreeSelector.caption:=('EentityFunctionEditor');
     StringsTreeSelector.ActiveControl:=StringsTreeSelector.StringsTree;
     modalresult:=ZCMsgCallBackInterface.DOShowModal(StringsTreeSelector);
     if modalresult=ZCMrOk then
       PStringTreeType(PInstance)^:=StringsTreeSelector.TreeResult;
end;



initialization;
  FunctionsTree.LoadTree(expandpath('*rtl/functions.xml'),InterfaceTranslate);
  RepresentationsTree.LoadTree(expandpath('*rtl/representations.xml'),InterfaceTranslate);

  CreateZCADCommand(@FunctionsTest_com,'ft',CADWG,0);
  CreateZCADCommand(@RepresentationsTest_com,'rt',CADWG,0);

  //AddEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),TBaseTypesEditors.BaseCreateEditor);
  //AddEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),TBaseTypesEditors.BaseCreateEditor);

  AddFastEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunEentityRepresentationEditor);
  AddFastEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunEentityFunctionEditor);

finalization;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
