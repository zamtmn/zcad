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

unit uzctextenteditor;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzcsysparams,uzcutils,uzcsysvars,uzcinfoform,Varman,uzcinterface,uzedrawingdef,
  uzbstrproc,uzeenttext,uzeconsts,uzcstrconsts,uzcfsinglelinetexteditor,
  Controls,Classes,Forms,uzccommandsmanager,uzcuitypes,zUndoCmdChgTypes,
  zUndoCmdChgVariable,uzcdrawing,uzcdrawings,uzeTypes,uzeBaseUtils;

const
  MTextWndSaveParamName='MTEdWND';
  TextWndSaveParamName='TEdWND';

var
  InfoForm:TInfoForm=nil;

procedure RunTextEditor(Pobj:Pointer;var drawing:TDrawingDef);

implementation

procedure RunTextEditor(Pobj:Pointer;var drawing:TDrawingDef);
var
  ModalResult:integer;
  AString:ansistring;
  UString:TDXFEntsInternalStringType;
begin
  AString:=ConvertFromDxfString(PGDBObjText(pobj)^.Template);
  if PGDBObjText(pobj)^.GetObjType=GDBMTextID then begin
    if not assigned(InfoForm) then
      InfoForm:=TInfoForm.createnew(application.MainForm);
    InfoForm.BoundsRect:=GetBoundsFromSavedUnit(MTextWndSaveParamName,ZCSysParams.notsaved.ScreenX,ZCSysParams.notsaved.Screeny);
    InfoForm.caption:=rsMTextEditor;

    InfoForm.memo.text:=AString;
    if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
      InfoForm.memo.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;
    ModalResult:=zcUI.DOShowModal(InfoForm);

    if ModalResult=ZCMrOk then begin
      UString:=ConvertToDxfString(InfoForm.memo.text);
      StoreBoundsToSavedUnit(MTextWndSaveParamName,InfoForm.BoundsRect);
    end;
  end else begin
    if not assigned(SingleLineTextEditorForm) then
      Application.CreateForm(TSingleLineTextEditorForm,SingleLineTextEditorForm);
    SingleLineTextEditorForm.BoundsRect:=GetBoundsFromSavedUnit(TextWndSaveParamName,ZCSysParams.notsaved.ScreenX,ZCSysParams.notsaved.Screeny);
    SingleLineTextEditorForm.caption:=rsTextEditor;

    SingleLineTextEditorForm.HelpText.Caption:=rsTextEdCaption;
    SingleLineTextEditorForm.EditField.TEXT:=AString;
    if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
      SingleLineTextEditorForm.EditField.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;

    ModalResult:=zcUI.DOShowModal(SingleLineTextEditorForm);

    if ModalResult=ZCMrOk then begin
      UString:=ConvertToDxfString(SingleLineTextEditorForm.EditField.text);
      StoreBoundsToSavedUnit(TextWndSaveParamName,SingleLineTextEditorForm.BoundsRect);
    end;
  end;

  if ModalResult=ZCMrOk then begin
    if UString<>PGDBObjText(pobj)^.Template then begin
      UCmdChgField.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                                 TChangedFieldDesc.CreateRec(SysUnit^.TypeName2PTD('TDXFEntsInternalStringType'),
                                                             @PGDBObjText(pobj)^.Template,
                                                             @PGDBObjText(pobj)^.Template),
                                 TSharedPEntityData.CreateRec(pobj),
                                 TAfterChangePDrawing.CreateRec(@drawing));
      PGDBObjText(pobj)^.Template:=UString;
    end;
    PGDBObjText(pobj)^.YouChanged(drawing);
    zcRedrawCurrentDrawing;
  end;
end;
begin
end.
