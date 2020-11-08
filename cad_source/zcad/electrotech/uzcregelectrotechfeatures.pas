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

unit uzcregelectrotechfeatures;
{$INCLUDE def.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}
     uzbstrproc,Varman,languade,SysUtils,
     UBaseTypeDescriptor,uzbtypes,UGDBOpenArrayOfByte, strmy, varmandef,
     uzcsysparams,uzcsysinfo,TypeDescriptors,URecordDescriptor,
     uzclog,uzbmemman,LazLogger,uzceltechtreeprop,uzcefstringstreeselector,
     uzccommandsimpl,uzccommandsabstract,uzctypesdecorations,zcobjectinspectorui,
     uzcoidecorations,uzbtypesbase,
     Forms,Controls,
     uzcinterface;
var
  StringsTreeSelector:TStringsTreeSelector=nil;
implementation

function FunctionsTest_com(operands:TCommandOperands):TCommandResult;
begin
  StringsTreeSelector:=TStringsTreeSelector.Create(nil);
  StringsTreeSelector.fill(FunctionsTree.BlobTree);
  StringsTreeSelector.ShowModal;
  freeandnil(StringsTreeSelector);
  result:=cmd_ok;
end;

function RepresentationsTest_com(operands:TCommandOperands):TCommandResult;
begin
  StringsTreeSelector:=TStringsTreeSelector.Create(nil);
  StringsTreeSelector.fill(RepresentationsTree.BlobTree);
  StringsTreeSelector.ShowModal;
  freeandnil(StringsTreeSelector);
  result:=cmd_ok;
end;

procedure RunEentityRepresentationEditor(PInstance:GDBPointer);
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
     if modalresult=MrOk then
       PStringTreeType(PInstance)^:=StringsTreeSelector.TreeResult;
end;

procedure RunEentityFunctionEditor(PInstance:GDBPointer);
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
     if modalresult=MrOk then
       PStringTreeType(PInstance)^:=StringsTreeSelector.TreeResult;
end;



initialization;
  FunctionsTree.LoadTree(expandpath('*rtl/functions.xml'),InterfaceTranslate);
  RepresentationsTree.LoadTree(expandpath('*rtl/representations.xml'),InterfaceTranslate);

  CreateCommandFastObjectPlugin(@FunctionsTest_com,'ft',CADWG,0);
  CreateCommandFastObjectPlugin(@RepresentationsTest_com,'rt',CADWG,0);

  //AddEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),TBaseTypesEditors.BaseCreateEditor);
  //AddEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),TBaseTypesEditors.BaseCreateEditor);

  AddFastEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunEentityRepresentationEditor);
  AddFastEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunEentityFunctionEditor);

finalization;
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization')
end.
