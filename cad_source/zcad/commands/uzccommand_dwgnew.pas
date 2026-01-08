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

unit uzccommand_DWGNew;
{$INCLUDE zengineconfig.inc}

interface

uses
  ComCtrls,Controls,LazUTF8,uzcLog,AnchorDocking,
  SysUtils,
  uzeTypes,uzbpaths,
  uzglbackendmanager,uzglviewareaabstract,
  uzccmdload,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawing,uzcdrawings,
  uzcinterface,uzcMainForm;

function DWGNew_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;

implementation

function DWGNew_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  PDrawing:PTZCADDrawing;
  TabSheet:TTabSheet;
  ViewControl:TCADControl;
  ViewArea:TAbstractViewArea;
  FileName:ansistring;
  dwgname:ansistring;
begin
  PDrawing:=drawings.CreateDWG('$(DistribPath)/rtl/dwg/DrawingDeviceBase.pas',
    '$(DistribPath)/rtl/dwg/DrawingVars.pas');
  drawings.PushBackData(PDrawing);
  FileName:=operands;

  if length(operands)=0 then begin
    dwgname:=drawings.GetDefaultDrawingName;
    operands:=dwgname;
    PDrawing^.FileName:=dwgname;
  end else

    PDrawing^.FileName:=operands;

  if not assigned(zcMainForm.PageControl) then
    DockMaster.ShowControl('PageControl',True);


  TabSheet:=TTabSheet.Create(zcMainForm.PageControl);
  TabSheet.Caption:=(Operands);
  TabSheet.Parent:=zcMainForm.PageControl;

  ViewArea:=GetCurrentBackEnd.Create(TabSheet);
  ViewArea.onCameraChanged:=zcMainForm.correctscrollbars;
  ViewArea.OnWaMouseUp:=zcMainForm.wamu;
  ViewArea.OnWaMouseDown:=zcMainForm.wamd;
  ViewArea.OnWaMouseMove:=zcMainForm.wamm;
  ViewArea.OnWaKeyPress:=zcMainForm.wakp;
  ViewArea.OnWaMouseSelect:=zcMainForm.wams;
  ViewArea.OnGetEntsDesc:=zcMainForm.GetEntsDesc;
  ViewArea.ShowCXMenu:=zcMainForm.ShowCXMenu;
  ViewArea.MainMouseMove:=zcMainForm.MainMouseMove;
  ViewArea.MainMouseDown:=zcMainForm.MainMouseDown;
  ViewArea.MainMouseUp:=zcMainForm.MainMouseUp;
  ViewArea.OnWaShowCursor:=zcMainForm.WaShowCursor;
  PDrawing.wa:=ViewArea;

  drawings.SetCurrentDWG(PDrawing);
  ViewArea.PDWG:=PDrawing;
  ViewControl:=ViewArea.getviewcontrol;
  ViewControl.align:=alClient;
  ViewControl.Parent:=TabSheet;
  ViewControl.Visible:=True;
  ViewArea.getareacaps;
  ViewArea.WaResize(nil);
  ViewControl.Show;
  zcMainForm.PageControl.ActivePage:=TabSheet;

  if not fileexists(FileName) then begin
    FileName:=ConcatPaths([ExpandPath(sysvar.PATH.Template_Path^),
      ExpandPath(sysvar.PATH.Template_File^)]);
    if fileExists(UTF8ToSys(FileName)) then
      Load_merge(FileName,TLOLoad)
    else
      zcUI.TextMessage(format(rsTemplateNotFound,[FileName]),TMWOShowError);
  end;
  ViewArea.Drawer.delmyscrbuf;
  //буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
  //создания или загрузки
  zcUI.Do_GUIaction(nil,zcMsgUIActionRedrawContent);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DWGNew_com,'DWGNew',0,0).CEndActionAttr:=[CEDWGNChanged];

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
