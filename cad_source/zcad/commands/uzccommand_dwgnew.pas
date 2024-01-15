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
  sysutils,
  uzbtypes,uzbpaths,
  uzglbackendmanager,uzglviewareaabstract,

  uzccmdload,
  uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawing,uzcdrawings,
  uzcinterface,uzcmainwindow;

function DWGNew_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function DWGNew_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   PDrawing:PTZCADDrawing;
   TabSheet:TTabSheet;
   ViewControl:TCADControl;
   ViewArea:TAbstractViewArea;
   FileName:ansistring;
   dwgname:ansistring;
begin
  PDrawing:=drawings.CreateDWG('*rtl/dwg/DrawingDeviceBase.pas','*rtl/dwg/DrawingVars.pas');
  drawings.PushBackData(PDrawing);
  FileName:=operands;

  if length(operands)=0 then begin
    dwgname:=drawings.GetDefaultDrawingName;
    operands:=dwgname;
    PDrawing^.FileName:=dwgname;
  end else

  PDrawing^.FileName:=operands;

  if not assigned(ZCADMainWindow.PageControl)then
    DockMaster.ShowControl('PageControl',true);


  TabSheet:=TTabSheet.create(ZCADMainWindow.PageControl);
  TabSheet.Caption:=(Operands);
  TabSheet.Parent:=ZCADMainWindow.PageControl;

  ViewArea:=GetCurrentBackEnd.Create(TabSheet);
  ViewArea.onCameraChanged:=ZCADMainWindow.correctscrollbars;
  ViewArea.OnWaMouseUp:=ZCADMainWindow.wamu;
  ViewArea.OnWaMouseDown:=ZCADMainWindow.wamd;
  ViewArea.OnWaMouseMove:=ZCADMainWindow.wamm;
  ViewArea.OnWaKeyPress:=ZCADMainWindow.wakp;
  ViewArea.OnWaMouseSelect:=ZCADMainWindow.wams;
  ViewArea.OnGetEntsDesc:=ZCADMainWindow.GetEntsDesc;
  ViewArea.ShowCXMenu:=ZCADMainWindow.ShowCXMenu;
  ViewArea.MainMouseMove:=ZCADMainWindow.MainMouseMove;
  ViewArea.MainMouseDown:=ZCADMainWindow.MainMouseDown;
  ViewArea.MainMouseUp:=ZCADMainWindow.MainMouseUp;
  ViewArea.OnWaShowCursor:=ZCADMainWindow.WaShowCursor;
  PDrawing.wa:=ViewArea;

  drawings.SetCurrentDWG(PDrawing);
  ViewArea.PDWG:=PDrawing;
  ViewControl:=ViewArea.getviewcontrol;
  ViewControl.align:=alClient;
  ViewControl.Parent:=TabSheet;
  ViewControl.Visible:=true;
  ViewArea.getareacaps;
  ViewArea.WaResize(nil);
  ViewControl.show;
  ZCADMainWindow.PageControl.ActivePage:=TabSheet;

  if not fileexists(FileName) then begin
    FileName:=expandpath(sysvar.PATH.Template_Path^)+sysvar.PATH.Template_File^;
    if fileExists(utf8tosys(FileName)) then
      Load_merge(FileName,TLOLoad)
    else
      ZCMsgCallBackInterface.TextMessage(format(rsTemplateNotFound,[FileName]),TMWOShowError);
  end;
  ViewArea.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                              //создания или загрузки
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedrawContent);
  result:=cmd_ok;
end;
initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DWGNew_com,'DWGNew',0,0).CEndActionAttr:=[CEDWGNChanged];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
