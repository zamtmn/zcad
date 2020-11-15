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

unit uzccommand_newdwg;
{$INCLUDE def.inc}

interface
uses
  ComCtrls,Controls,LazUTF8,LCLProc,AnchorDocking,
  sysutils,
  uzbtypes,uzbpaths,
  uzglbackendmanager,uzglviewareaabstract,

  uzccombase,uzccommandsimpl,uzccommandsabstract,
  uzcsysvars,
  uzcstrconsts,
  uzcdrawing,uzcdrawings,
  uzcinterface,uzcmainwindow;

function newdwg_com(operands:TCommandOperands):TCommandResult;

implementation

function newdwg_com(operands:TCommandOperands):TCommandResult;
var
   ptd:PTZCADDrawing;
   myts:TTabSheet;
   oglwnd:TCADControl;
   wpowner:TAbstractViewArea;
   tn:ansistring;
   dwgname:ansistring;
begin
     ptd:=drawings.CreateDWG('*rtl/dwg/DrawingDeviceBase.pas','*rtl/dwg/DrawingVars.pas');

     drawings.PushBackData(ptd);

     if length(operands)=0 then
                               begin
                                    dwgname:=drawings.GetDefaultDrawingName;
                                    operands:=dwgname;
                                    ptd^.FileName:=dwgname;
                               end
                            else
                                ptd^.FileName:=operands;

     {tf:=mainform.PageControl.addpage(Operands);
     mainform.PageControl.selpage(mainform.PageControl.lastcreated);
     mainform.PageControl.CxMenu:=DWGPageCxMenu;}

     myts:=nil;

     if not assigned(ZCADMainWindow.PageControl)then
     begin
          DockMaster.ShowControl('PageControl',true);
          //DockMaster.ShowControl('PageControl',true);
     end;


     myts:=TTabSheet.create(ZCADMainWindow.PageControl);
     myts.Caption:=(Operands);
     //mainformn.DisableAutoSizing;
     myts.Parent:=ZCADMainWindow.PageControl;
     //mainformn.EnableAutoSizing;

     //tf.align:=al_client;

     //wpowner:=TOpenGLViewArea{TCanvasViewArea}.Create(myts);
     //wpowner:={TOpenGLViewArea}TCanvasViewArea.Create(myts);
     wpowner:=GetCurrentBackEnd.Create(myts);
     wpowner.onCameraChanged:=ZCADMainWindow.correctscrollbars;
     wpowner.OnWaMouseDown:=ZCADMainWindow.wamd;
     wpowner.OnWaMouseMove:=ZCADMainWindow.wamm;
     wpowner.OnWaKeyPress:=ZCADMainWindow.wakp;
     wpowner.OnWaMouseSelect:=ZCADMainWindow.wams;
     wpowner.OnGetEntsDesc:=ZCADMainWindow.GetEntsDesc;
     wpowner.ShowCXMenu:=ZCADMainWindow.ShowCXMenu;
     wpowner.MainMouseMove:=ZCADMainWindow.MainMouseMove;
     wpowner.MainMouseDown:=ZCADMainWindow.MainMouseDown;
     wpowner.MainMouseUp:=ZCADMainWindow.MainMouseUp;
     //wpowner.OnSetObjInsp:=ZCADMainWindow.waSetObjInsp;
     wpowner.OnWaShowCursor:=ZCADMainWindow.WaShowCursor;
     oglwnd:=wpowner.getviewcontrol;// TOGLWnd.Create(myts);




     //--------------------------------------------------------------oglwnd.BevelOuter:=bvnone;
     ptd.wa:=wpowner;
     drawings.SetCurrentDWG(ptd);
 wpowner.PDWG:=ptd;
     wpowner.getviewcontrol.align:=alClient;
     wpowner.getviewcontrol.Parent:=myts;
     wpowner.getviewcontrol.Visible:=true;
     wpowner.PDWG:=ptd;
     //programlog.logoutstr('oglwnd.PDWG:=ptd;',0);
     wpowner.getareacaps;

     wpowner.WaResize(nil);
     //programlog.logoutstr('wpowner.WaResize(nil);',0);
     oglwnd.show;
     //programlog.logoutstr('oglwnd.show;',0);


     ZCADMainWindow.PageControl.ActivePage:=myts;
     //programlog.logoutstr('MainFormN.PageControl.ActivePage:=myts;',0);
     //ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);//после lazarus r63888 это вызывает вис на показе мессагебокса при загрузке файла
     //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
     //programlog.logoutstr('sharedgdb.updatevisible;',0);
     operands:=operands;
     //programlog.logoutstr('operands:=operands;???????????????',0);
     if not fileexists(operands) then
     begin
     tn:=expandpath(sysvar.PATH.Template_Path^)+sysvar.PATH.Template_File^;
     if fileExists(utf8tosys(tn)) then
                           {merge_com(@tn[1])}Load_merge(tn,TLOLoad)
                       else
                           ZCMsgCallBackInterface.TextMessage(format(rsTemplateNotFound,[tn]),TMWOShowError);
     end;
     wpowner.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                //создания или загрузки
     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedrawContent);
     result:=cmd_ok;
     //programlog.logoutstr('result:=cmd_ok;',0);
     //application.ProcessMessages;
     //programlog.logoutstr(' application.ProcessMessages;',0);
     //oglwnd._onresize(nil);
     //programlog.logoutstr('oglwnd._onresize(nil);',0);

     //drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_TEST');
     //addblockinsert(drawings.GetCurrentROOT,@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray, nulvertex, 1, 0, 'DEVICE_TEST');
     //drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
end;
procedure startup;
begin
  CreateCommandFastObjectPlugin(@newdwg_com,'NewDWG',0,0).CEndActionAttr:=CEDWGNChanged;
end;
procedure finalize;
begin
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
