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

unit gdbcommandsinterface;
{$INCLUDE def.inc}

interface
uses
 ugdbsimpledrawing,GDBCommandsBase,zcadsysvars,commandline,TypeDescriptors,GDBManager,zcadstrconsts,UGDBStringArray,ucxmenumgr,{$IFNDEF DELPHI}intftranslations,{$ENDIF}layerwnd,{strutils,}strproc,umytreenode,menus, {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,{ SysUtils,} FileUtil,{ LResources,} Forms, {stdctrls,} Controls, {Graphics, Dialogs,}ComCtrls,Clipbrd,lclintf,
  plugins,OGLSpecFunc,
  sysinfo,
  //commandline,
  commandlinedef,
  commanddefinternal,
  gdbase,
  UGDBDescriptor,
  sysutils,
  varmandef,
  //oglwindowdef,
  //OGLtypes,
  UGDBOpenArrayOfByte,
  iodxf,iodwg,
  //optionswnd,
  {objinsp,}
   zcadinterface,
  //cmdline,
  //UGDBVisibleOpenArray,
  //gdbobjectsconstdef,
  GDBEntity,
 shared,
 UGDBEntTree,
  {zmenus,}projecttreewnd,gdbasetypes,{optionswnd,}AboutWnd,HelpWnd,memman,WindowsSpecific,{txteditwnd,}
 {messages,}UUnitManager,{zguisct,}log,Varman,UGDBNumerator,cmdline,
 AnchorDocking,dialogs,XMLPropStorage,xmlconf{,
   uPSCompiler,
  uPSRuntime,
  uPSC_std,
  uPSC_controls,
  uPSC_stdctrls,
  uPSC_forms,
  uPSR_std,
  uPSR_controls,
  uPSR_stdctrls,
  uPSR_forms,
  uPSUtils};



   {procedure startup;
   procedure finalize;}
   {var selframecommand:PCommandObjectDef;
       ms2objinsp:PCommandObjectDef;
       deselall,selall:pCommandFastObjectPlugin;

       MSEditor:TMSEditor;

       InfoFormVar:TInfoForm=nil;

       MSelectCXMenu:TmyPopupMenu=nil;

   function SaveAs_com(Operands:pansichar):GDBInteger;
   procedure CopyToClipboard;}
   function quit_com(Operands:pansichar):GDBInteger;
   //function Regen_com(Operands:pansichar):GDBInteger;
//var DWGPageCxMenu:pzpopupmenu;
implementation
uses GDBPolyLine,UGDBPolyLine2DArray,GDBLWPolyLine,mainwindow,UGDBSelectedObjArray,
     oglwindow,geometry;
function CloseDWG_com(Operands:pansichar):GDBInteger;
var
   poglwnd:toglwnd;
   CurrentDWG:PTDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=PTDrawing(gdb.GetCurrentDWG);
  _CloseDWGPage(CurrentDWG,mainformn.PageControl.ActivePage);
  (*if CurrentDWG<>nil then
  begin
       if CurrentDWG.Changed then
                                 begin
                                      if MainFormN.MessageBox(@rsCloseDWGQuery[1],@rsWarningCaption[1],MB_YESNO)<>IDYES then exit;
                                 end;
       poglwnd:=CurrentDWG.OGLwindow1;
       //mainform.PageControl.delpage(mainform.PageControl.onmouse);
       gdb.eraseobj(CurrentDWG);
       gdb.pack;
       poglwnd.PDWG:=nil;
       gdb.CurrentDWG:=nil;

       poglwnd.free;

       mainformn.PageControl.ActivePage.Free;
       tobject(poglwnd):=mainformn.PageControl.ActivePage;

       if poglwnd<>nil then
       begin
            tobject(poglwnd):=FindControlByType(poglwnd,TOGLWnd);
            //pointer(poglwnd):=poglwnd^.FindKidsByType(typeof(TOGLWnd));
            gdb.CurrentDWG:=poglwnd.PDWG;
            poglwnd.GDBActivate;
       end;
       shared.SBTextOut('Закрыто');
       GDBobjinsp.ReturnToDefault;
       sharedgdb.updatevisible;
  end;*)
end;
function NextDrawint_com(Operands:pansichar):GDBInteger;
var
   i:integer;
begin
     if assigned(MainFormN.PageControl)then
     if MainFormN.PageControl.PageCount>1 then
     begin
          i:=MainFormN.PageControl.ActivePageIndex+1;
          if i=MainFormN.PageControl.PageCount
                                              then
                                                  i:=0;
             MainFormN.PageControl.ActivePageIndex:=i;
     end;
end;
function PrevDrawint_com(Operands:pansichar):GDBInteger;
var
   i:integer;
begin
     if assigned(MainFormN.PageControl)then
     if MainFormN.PageControl.PageCount>1 then
     begin
          i:=MainFormN.PageControl.ActivePageIndex-1;
          if i<0
                                            then
                                                  i:=MainFormN.PageControl.PageCount-1;
             MainFormN.PageControl.ActivePageIndex:=i;
     end;
end;
function newdwg_com(Operands:pansichar):GDBInteger;
var
   ptd:PTDrawing;
   myts:TTabSheet;
   oglwnd:TOGLWND;
   tn:GDBString;
begin
     ptd:=gdb.CreateDWG;

     gdb.AddRef(ptd^);

     gdb.SetCurrentDWG(ptd);

     if length(operands)=0 then
                               operands:=@rsUnnamedWindowTitle[1];

     {tf:=mainform.PageControl.addpage(Operands);
     mainform.PageControl.selpage(mainform.PageControl.lastcreated);
     mainform.PageControl.CxMenu:=DWGPageCxMenu;}

     myts:=nil;

     if not assigned(MainFormN.PageControl)then
     begin
          DockMaster.ShowControl('PageControl',true);
          //DockMaster.ShowControl('PageControl',true);
     end;


     myts:=TTabSheet.create(MainFormN.PageControl);
     myts.Caption:=(Operands);
     //mainformn.DisableAutoSizing;
     myts.Parent:=MainFormN.PageControl;
     //mainformn.EnableAutoSizing;

     //tf.align:=al_client;

     oglwnd:=TOGLWnd.Create(myts);
     oglwnd.onCameraChanged:=MainFormN.correctscrollbars;
     oglwnd.ShowCXMenu:=MainFormN.ShowCXMenu;
     oglwnd.MainMouseMove:=MainFormN.MainMouseMove;
     oglwnd.MainMouseDown:=MainFormN.MainMouseDown;
     {$if FPC_FULlVERSION>=20701}
     oglwnd.AuxBuffers:=0;
     oglwnd.StencilBits:=8;
     //oglwnd.ColorBits:=24;
     oglwnd.DepthBits:=24;
     {$ENDIF}



     //--------------------------------------------------------------oglwnd.BevelOuter:=bvnone;

     gdb.GetCurrentDWG.OGLwindow1:=oglwnd;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.PDWG:=ptd;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.align:=alClient;
          //gdb.GetCurrentDWG.OGLwindow1.align:=al_client;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.Parent:=myts;
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.init;{переделать из инита нужно убрать обнуление pdwg}
     {gdb.GetCurrentDWG.OGLwindow1}oglwnd.PDWG:=ptd;
     programlog.logoutstr('oglwnd.PDWG:=ptd;',0);
     oglwnd.GDBActivate;
     oglwnd._onresize(nil);
     programlog.logoutstr('oglwnd._onresize(nil);',0);
     oglwnd.MakeCurrent(false);
     programlog.logoutstr('oglwnd.MakeCurrent(false);',0);
     isOpenGLError;
     programlog.logoutstr('isOpenGLError;',0);
     //oglwnd.DoubleBuffered:=false;
     oglwnd.show;
     programlog.logoutstr('oglwnd.show;',0);
     isOpenGLError;
     programlog.logoutstr('isOpenGLError;',0);
     //oglwnd.Repaint;
     //gdb.GetCurrentDWG.OGLwindow1.initxywh('oglwnd',tf,200,72,768,596,false);

     //tf.size;

     //gdb.GetCurrentDWG.OGLwindow1.Show;

     //GDBGetMem({$IFDEF DEBUGBUILD}'{E197C531-C543-4FAF-AF4A-37B8F278E8A2}',{$ENDIF}GDBPointer(gdb.GetCurrentDWG),sizeof(UGDBDescriptor.TDrawing));
     //gdb.GetCurrentDWG^.init(@gdb.ProjectUnits);
     //addfromdxf(sysvar.path.Program_Run^+'blocks\el\general\_nok.dxf',@gdb.GetCurrentDWG.ObjRoot);

     MainFormN.PageControl.ActivePage:=myts;
     programlog.logoutstr('MainFormN.PageControl.ActivePage:=myts;',0);
     if assigned(UpdateVisibleProc) then UpdateVisibleProc;
     programlog.logoutstr('sharedgdb.updatevisible;',0);
     operands:=operands;
     programlog.logoutstr('operands:=operands;???????????????',0);
     if not fileexists(operands) then
     begin
     tn:=expandpath(sysvar.PATH.Template_Path^)+sysvar.PATH.Template_File^;
     if fileExists(utf8tosys(tn)) then
                           merge_com(@tn[1])
                       else
                           shared.ShowError(format(rsTemplateNotFound,[tn]));
                           //shared.ShowError('Не найден файл шаблона "'+tn+'"');
     end;
     //redrawoglwnd;
     result:=cmd_ok;
     programlog.logoutstr('result:=cmd_ok;',0);
     application.ProcessMessages;
     programlog.logoutstr(' application.ProcessMessages;',0);
     oglwnd._onresize(nil);
     programlog.logoutstr('oglwnd._onresize(nil);',0);

     //GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_TEST');
     //addblockinsert(gdb.GetCurrentROOT,@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray, nulvertex, 1, 0, 'DEVICE_TEST');
     //gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
end;
function Import_com(Operands:pansichar):GDBInteger;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
begin
  if length(operands)=0 then
                     begin
                          if assigned(Showallcursorsproc) then Showallcursorsproc;
                          //mainformn.ShowAllCursors;
                          isload:=OpenFileDialog(s,'svg',ImportFileFilter,'','Import...');
                          if assigned(RestoreAllCursorsproc) then RestoreAllCursorsproc;
                          //mainformn.RestoreCursors;
                          //s:=utf8tosys(s);
                          if not isload then
                                            begin
                                                 result:=cmd_cancel;
                                                 exit;
                                            end
                     end
                 else
                 begin
                   s:=ExpandPath(operands);
                   s:=FindInSupportPath(operands);
                 end;
  isload:=FileExists(utf8tosys(s));
  if isload then
  begin
       newdwg_com(@s[1]);
       gdb.GetCurrentDWG.SetFileName(s);
       import(s,gdb.GetCurrentDWG^);
  end
            else
     shared.ShowError('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']));
     //shared.ShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function Load_com(Operands:pansichar):GDBInteger;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
   //mem:GDBOpenArrayOfByte;
   //pu:ptunit;
begin
     if length(operands)=0 then
                        begin
                             if assigned(Showallcursorsproc) then Showallcursorsproc;
                             isload:=OpenFileDialog(s,'dxf',ProjectFileFilter,'',rsOpenFile);
                             if assigned(RestoreAllCursorsproc) then RestoreAllCursorsproc;
                             //s:=utf8tosys(s);
                             if not isload then
                                               begin
                                                    result:=cmd_cancel;
                                                    exit;
                                               end
                                           else
                                               begin

                                               end;    

                        end
                    else
                    begin
                         if operands='QS' then
                                              s:=ExpandPath(sysvar.SAVE.SAVE_Auto_FileName^)
                                          else
                                              begin
                                              s:=ExpandPath(operands);
                                              s:=FindInSupportPath(operands);
                                              end;
                    end;
     isload:=FileExists(utf8tosys(s));
     if isload then
     begin
          newdwg_com(@s[1]);
          //if operands<>'QS' then
                                gdb.GetCurrentDWG.SetFileName(s);
          programlog.logoutstr('gdb.GetCurrentDWG.FileName:=s;',0);
          load_merge(@s[1],tloload);
          programlog.logoutstr('load_merge(@s[1],tloload);',0);
          if assigned(ProcessFilehistoryProc) then
           ProcessFilehistoryProc(s);
     end
               else
        shared.ShowError('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']));
        //shared.ShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function layer_cmd:GDBInteger;
begin
  LayerWindow:=TLayerWindow.Create(nil);
  SetHeightControl(LayerWindow,22);
  DOShowModal(LayerWindow);
  Freeandnil(LayerWindow);
  result:=cmd_ok;
end;

procedure finalize;
begin
end;
procedure SaveLayoutToFile(Filename: string);
var
  XMLConfig: TXMLConfig;
  Config: TXMLConfigStorage;
begin
  XMLConfig:=TXMLConfig.Create(nil);
  try
    XMLConfig.StartEmpty:=true;
    XMLConfig.Filename:=Filename;
    Config:=TXMLConfigStorage.Create(XMLConfig);
    try
      DockMaster.SaveLayoutToConfig(Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
function SaveLayout_com:GDBInteger;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
begin
  try
    // create a new xml config file
    filename:=utf8tosys(sysparam.programpath+'components/defaultlayout.xml');
    SaveLayoutToFile(filename);
    exit;
    XMLConfig:=TXMLConfigStorage.Create(filename,false);
    try
      // save the current layout of all forms
      DockMaster.SaveLayoutToConfig(XMLConfig);
      XMLConfig.WriteToDisk;
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      MessageDlg('Error',
        'Error saving layout to file '+Filename+':'#13+E.Message,mtError,
        [mbCancel],0);
    end;
  end;
  result:=cmd_ok;
end;
function Show_com(Operands:pansichar):GDBInteger;
var
   obj:gdbstring;
   objt:PUserTypeDescriptor;
begin
  DockMaster.ShowControl(Operands,true);
{     if Operands='ObjInsp' then
                            begin
                                 DockMaster.ShowControl('ObjectInspector',true);
                            end
else if Operands='CommandLine' then
                            begin
                                 DockMaster.ShowControl('CommandLine',true);
                            end
else if Operands='PageControl' then
                            begin
                                 DockMaster.ShowControl('PageControl',true);
                            end
else if Operands='ToolBarR' then
                            begin
                                 DockMaster.ShowControl('ToolBarR',true);
                            end;}
end;
function quit_com(Operands:pansichar):GDBInteger;
begin
     //Application.QueueAsyncCall(MainFormN.asynccloseapp, 0);


     CloseApp;
end;
function About_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(Aboutwindow) then
                                  Aboutwindow:=TAboutWnd.mycreate(Application,@Aboutwindow);
  DOShowModal(Aboutwindow);
end;
function Help_com(Operands:pansichar):GDBInteger;
begin
  if not assigned(Helpwindow) then
                                  Helpwindow:=THelpWnd.mycreate(Application,@Helpwindow);
  DOShowModal(Helpwindow);
end;
procedure startup;
//var
   //pmenuitem:pzmenuitem;
begin
  CreateCommandFastObjectPlugin(@newdwg_com,'NewDWG',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@NextDrawint_com,'NextDrawing',0,0);
  CreateCommandFastObjectPlugin(@PrevDrawint_com,'PrevDrawing',0,0);
  CreateCommandFastObjectPlugin(@CloseDWG_com,'CloseDWG',CADWG,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Load_com,'Load',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Import_com,'Import',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@LoadLayout_com,'LoadLayout',0,0);
  CreateCommandFastObjectPlugin(@quit_com,'Quit',0,0);
  CreateCommandFastObjectPlugin(@layer_cmd,'Layer',CADWG,0);
  CreateCommandFastObjectPlugin(@SaveLayout_com,'SaveLayout',0,0);
  CreateCommandFastObjectPlugin(@Show_com,'Show',0,0);
  CreateCommandFastObjectPlugin(@About_com,'About',0,0);
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0);

  Aboutwindow:=nil;
  Helpwindow:=nil;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('GDBCommandsBase.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.
