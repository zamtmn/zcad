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

unit uzctextenteditor;
{$INCLUDE def.inc}
interface
uses
     uzcsysparams,uzcutils,uzcsysvars,uzbtypesbase,uzbtypes,uzcsysinfo,
     uzcinfoform,Varman,uzcinterface,
     uzedrawingdef,uzbstrproc,uzeenttext,uzeconsts,uzcstrconsts,uzcfsinglelinetexteditor,
     Controls,Classes,Forms,uzccommandsmanager,uzcuitypes;
var
    InfoForm:TInfoForm=nil;
procedure RunTextEditor(Pobj:GDBPointer;var drawing:TDrawingDef);
implementation
procedure RunTextEditor(Pobj:GDBPointer;var drawing:TDrawingDef);
var
   modalresult:integer;
   astring:ansistring;
begin
     astring:=ConvertFromDxfString(PGDBObjText(pobj)^.Template);


     if PGDBObjText(pobj)^.GetObjType=GDBMTextID then
     begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     InfoForm.BoundsRect:=GetBoundsFromSavedUnit('TEdWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny);
     end;
     //InfoForm.DialogPanel.ShowButtons:=[pbOK, pbCancel{, pbClose, pbHelp}];
     InfoForm.caption:=(rsMTextEditor);

     InfoForm.memo.text:=astring;
     if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
        InfoForm.memo.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;
     modalresult:=ZCMsgCallBackInterface.DOShowModal(InfoForm);
     if modalresult=ZCMrOk then
                         begin
                              PGDBObjText(pobj)^.Template:=ConvertToDxfString(InfoForm.memo.text);
                              StoreBoundsToSavedUnit('TEdWND',InfoForm.BoundsRect);
                         end;
     end
     else
     begin
     if not assigned(SingleLineTextEditorForm) then
     Application.CreateForm(TSingleLineTextEditorForm, SingleLineTextEditorForm);
     SingleLineTextEditorForm.caption:=(rsTextEditor);

     SingleLineTextEditorForm.helptext.Caption:=rsTextEdCaption;
     SingleLineTextEditorForm.EditField.TEXT:=astring;
     if assigned(SysVar.INTF.INTF_DefaultEditorFontHeight) then
        SingleLineTextEditorForm.EditField.Font.Height:=SysVar.INTF.INTF_DefaultEditorFontHeight^;

     modalresult:=ZCMsgCallBackInterface.DOShowModal(SingleLineTextEditorForm);

     if modalresult=ZCMrOk then
                         begin
                              PGDBObjText(pobj)^.Template:=ConvertToDxfString(SingleLineTextEditorForm.EditField.text);
                         end;
     end;
     if modalresult=ZCMrOk then
                         begin
                              PGDBObjText(pobj)^.YouChanged(drawing);
                              zcRedrawCurrentDrawing;
                         end;

end;
begin
end.
