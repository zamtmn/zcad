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
{$Codepage UTF8}
{$INCLUDE zengineconfig.inc}
interface
uses uzbpaths,UUnitManager,uzcsysvars,uzctranslations,
     uzbstrproc,Varman,SysUtils,
     UBaseTypeDescriptor,uzeTypes,uzctnrVectorBytesStream,varmandef,
     uzcsysparams,TypeDescriptors,URecordDescriptor,
     uzcLog,uzceltechtreeprop,uzcefstringstreeselector,
     uzccommandsimpl,uzccommandsabstract,uzOIDecorations,uzOIUI,
     uzcoidecorations,
     Forms,Controls,
     uzcinterface,uzcuitypes,uzcTypeDescriprors;
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
     StringsTreeSelector.BoundsRect:=GetBoundsFromSavedUnit('StringsTreeSelectorWND',ZCSysParams.notsaved.ScreenX,ZCSysParams.notsaved.Screeny);
     end;
     StringsTreeSelector.clear;
     StringsTreeSelector.fill(RepresentationsTree.BlobTree);
     StringsTreeSelector.setValue(PStringTreeType(PInstance)^);
     StringsTreeSelector.caption:=('EentityRepresentationEditor');
     StringsTreeSelector.ActiveControl:=StringsTreeSelector.StringsTree;
     modalresult:=zcUI.DOShowModal(StringsTreeSelector);
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
     StringsTreeSelector.BoundsRect:=GetBoundsFromSavedUnit('StringsTreeSelectorWND',ZCSysParams.notsaved.ScreenX,ZCSysParams.notsaved.Screeny);
     end;
     StringsTreeSelector.clear;
     StringsTreeSelector.fill(FunctionsTree.BlobTree);
     StringsTreeSelector.setValue(PStringTreeType(PInstance)^);
     StringsTreeSelector.caption:=('EentityFunctionEditor');
     StringsTreeSelector.ActiveControl:=StringsTreeSelector.StringsTree;
     modalresult:=zcUI.DOShowModal(StringsTreeSelector);
     if modalresult=ZCMrOk then
       PStringTreeType(PInstance)^:=StringsTreeSelector.TreeResult;
end;

function DecorateTEentityFunction(PInstance:Pointer):String;
begin
  result:=FunctionsTree.GetDecaratedPard(PStringTreeType(PInstance)^);
end;

var
  pttd:PUserTypeDescriptor;

initialization;
  FunctionsTree.LoadTree(expandpath('$(DistribPath)/rtl/functions.xml'),InterfaceTranslate);
  RepresentationsTree.LoadTree(expandpath('$(DistribPath)/rtl/representations.xml'),InterfaceTranslate);

  CreateZCADCommand(@FunctionsTest_com,'ft',CADWG,0);
  CreateZCADCommand(@RepresentationsTest_com,'rt',CADWG,0);

  //AddEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),TBaseTypesEditors.BaseCreateEditor);
  //AddEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),TBaseTypesEditors.BaseCreateEditor);

  pttd:=SysUnit.TypeName2PTD('TEentityRepresentation');
  if pttd<>nil then begin
    AddFastEditorToType(pttd,@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunEentityRepresentationEditor);
  end;
  pttd:=SysUnit.TypeName2PTD('TEentityFunction');
  if pttd<>nil then begin
    AddFastEditorToType(pttd,@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunEentityFunctionEditor);
    DecorateType(pttd,DecorateTEentityFunction,nil,nil);
  end;
  with SysUnit.TypeName2PTD('TCalculatedString')^ do begin
    onGetValueAsString:=CalculatedStringDescriptor.GetValueAsString;
    onGetEditableAsString:=CalculatedStringDescriptor.GetEditableAsString;
    onSetEditableFromString:=CalculatedStringDescriptor.SetEditableFromString;
  end;

finalization;
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
