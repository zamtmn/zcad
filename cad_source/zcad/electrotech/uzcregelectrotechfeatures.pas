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
     UBaseTypeDescriptor,uzcshared,uzbtypes,UGDBOpenArrayOfByte, strmy, varmandef,
     uzcsysparams,uzcsysinfo,TypeDescriptors,URecordDescriptor,
     uzclog,uzbmemman,LazLogger,uzceltechtreeprop,uzcefstringstreeselector,
     uzccommandsimpl,uzccommandsabstract,uzctypesdecorations,zcobjectinspectorui,
     uzcoidecorations;
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

initialization;
  FunctionsTree.LoadTree(expandpath('*rtl/functions.xml'),InterfaceTranslate);
  RepresentationsTree.LoadTree(expandpath('*rtl/representations.xml'),InterfaceTranslate);

  CreateCommandFastObjectPlugin(@FunctionsTest_com,'ft',CADWG,0);
  CreateCommandFastObjectPlugin(@RepresentationsTest_com,'rt',CADWG,0);

  //AddEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),TBaseTypesEditors.BaseCreateEditor);
  //AddEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),TBaseTypesEditors.BaseCreateEditor);

  AddFastEditorToType(SysUnit.TypeName2PTD('TEentityRepresentation'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunAnsiStringEditor);
  AddFastEditorToType(SysUnit.TypeName2PTD('TEentityFunction'),@OIUI_FE_ButtonGetPrefferedSize,@ButtonTxtDrawFastEditor,@RunAnsiStringEditor);

finalization;
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization')
end.
