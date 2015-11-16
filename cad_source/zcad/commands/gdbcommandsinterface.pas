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
 paths,fileformatsmanager,backendmanager,uzglabstractviewarea,uzglopengldrawer,
 colorwnd,dswnd,ltwnd,tswnd,uinfoform,UGDBFontManager,ugdbsimpledrawing,GDBCommandsBase,
 zcadsysvars,commandline,TypeDescriptors,GDBManager,zcadstrconsts,UGDBStringArray,ucxmenumgr,
 {$IFNDEF DELPHI}intftranslations,{$ENDIF}layerwnd,unitswnd,strproc,umytreenode,menus,
 {$IFDEF FPC}lcltype,{$ENDIF}
 LCLProc,Classes,{ SysUtils,} FileUtil,{ LResources,} Forms, {stdctrls,} Controls, {Graphics, Dialogs,}ComCtrls,Clipbrd,lclintf,
  plugins,
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
  iodxf,
  //optionswnd,
  {objinsp,}
   zcadinterface,
  //cmdline,
  //UGDBVisibleOpenArray,
  //gdbobjectsconstdef,
  GDBEntity,
 shared,
 ugdbdrawing,
  {zmenus,}projecttreewnd,gdbasetypes,{optionswnd,}AboutWnd,HelpWnd,memman,WindowsSpecific,{txteditwnd,}
 {messages,}UUnitManager,{zguisct,}log,Varman,UGDBNumerator,cmdline,
 AnchorDocking,dialogs,XMLPropStorage,xmlconf,uzglopenglviewarea{,
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
   function quit_com(operands:TCommandOperands):TCommandResult;
   function layer_cmd:GDBInteger;
   function Colors_cmd:GDBInteger;
   //function Regen_com(Operands:pansichar):GDBInteger;
//var DWGPageCxMenu:pzpopupmenu;
implementation
uses mainwindow,
     geometry;
function CloseDWG_com(operands:TCommandOperands):TCommandResult;
var
   //poglwnd:toglwnd;
   CurrentDWG:PTDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=PTDrawing(gdb.GetCurrentDWG);
  _CloseDWGPage(CurrentDWG,mainformn.PageControl.ActivePage);
  result:=cmd_ok;
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
function NextDrawint_com(operands:TCommandOperands):TCommandResult;
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
     result:=cmd_ok;
end;
function PrevDrawint_com(operands:TCommandOperands):TCommandResult;
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
     result:=cmd_ok;
end;
function newdwg_com(operands:TCommandOperands):TCommandResult;
var
   ptd:PTDrawing;
   myts:TTabSheet;
   oglwnd:TCADControl;
   wpowner:{TOpenGLViewArea}{TGeneralViewArea}TAbstractViewArea;
   tn:GDBString;
   dwgname:GDBString;
begin
     ptd:=gdb.CreateDWG('*rtl/dwg/DrawingDeviceBase.pas','*rtl/dwg/DrawingVars.pas');

     gdb.AddRef(ptd^);

     if length(operands)=0 then
                               begin
                                    dwgname:=gdb.GetDefaultDrawingName;
                                    operands:=@dwgname[1];
                                    ptd^.FileName:=dwgname;
                               end
                            else
                                ptd^.FileName:=operands;

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

     //wpowner:=TOpenGLViewArea{TCanvasViewArea}.Create(myts);
     //wpowner:={TOpenGLViewArea}TCanvasViewArea.Create(myts);
     wpowner:=GetCurrentBackEnd.Create(myts);
     wpowner.onCameraChanged:=MainFormN.correctscrollbars;
     wpowner.OnWaMouseDown:=MainFormN.wamd;
     wpowner.OnWaMouseMove:=MainFormN.wamm;
     wpowner.OnWaKeyPress:=MainFormN.wakp;
     wpowner.OnWaMouseSelect:=MainFormN.wams;
     wpowner.OnGetEntsDesc:=MainFormN.GetEntsDesc;
     wpowner.ShowCXMenu:=MainFormN.ShowCXMenu;
     wpowner.MainMouseMove:=MainFormN.MainMouseMove;
     wpowner.MainMouseDown:=MainFormN.MainMouseDown;
     wpowner.MainMouseUp:=MainFormN.MainMouseUp;
     wpowner.OnSetObjInsp:=MainFormN.waSetObjInsp;
     oglwnd:=wpowner.getviewcontrol;// TOGLWnd.Create(myts);




     //--------------------------------------------------------------oglwnd.BevelOuter:=bvnone;
     ptd.wa:=wpowner;
     gdb.SetCurrentDWG(ptd);
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


     MainFormN.PageControl.ActivePage:=myts;
     //programlog.logoutstr('MainFormN.PageControl.ActivePage:=myts;',0);
     if assigned(UpdateVisibleProc) then UpdateVisibleProc;
     //programlog.logoutstr('sharedgdb.updatevisible;',0);
     operands:=operands;
     //programlog.logoutstr('operands:=operands;???????????????',0);
     if not fileexists(operands) then
     begin
     tn:=expandpath(sysvar.PATH.Template_Path^)+sysvar.PATH.Template_File^;
     if fileExists(utf8tosys(tn)) then
                           {merge_com(@tn[1])}Load_merge(@tn[1],TLOLoad)
                       else
                           shared.ShowError(format(rsTemplateNotFound,[tn]));
                           //shared.ShowError('Не найден файл шаблона "'+tn+'"');
     end;
     wpowner.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                //создания или загрузки
     redrawoglwnd;
     result:=cmd_ok;
     //programlog.logoutstr('result:=cmd_ok;',0);
     //application.ProcessMessages;
     //programlog.logoutstr(' application.ProcessMessages;',0);
     //oglwnd._onresize(nil);
     //programlog.logoutstr('oglwnd._onresize(nil);',0);

     //GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_TEST');
     //addblockinsert(gdb.GetCurrentROOT,@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray, nulvertex, 1, 0, 'DEVICE_TEST');
     //gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
end;
function Import_com(operands:TCommandOperands):TCommandResult;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
begin
  if length(operands)=0 then
                     begin
                          if assigned(Showallcursorsproc) then Showallcursorsproc;
                          //mainformn.ShowAllCursors;
                          isload:=OpenFileDialog(s,1,'svg',ImportFileFilter,'','Import...');
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
                   s:=FindInSupportPath(SupportPath,operands);
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
function Load_com(operands:TCommandOperands):TCommandResult;
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
                             isload:=OpenFileDialog(s,Ext2LoadProcMap.GetDefaultFileFilterIndex,{'dxf'}Ext2LoadProcMap.GetDefaultFileExt,{ProjectFileFilter}Ext2LoadProcMap.GetCurrentFileFilter,'',rsOpenFile);
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
                                                   s:=FindInSupportPath(SupportPath,operands);
                                                   if s='' then
                                                               s:=ExpandPath(operands);
                                              end;
                    end;
     isload:=FileExists(utf8tosys(s));
     if isload then
     begin
          newdwg_com(@s[1]);
          //if operands<>'QS' then
                                gdb.GetCurrentDWG.SetFileName(s);
          //programlog.logoutstr('gdb.GetCurrentDWG.FileName:=s;',0);
          load_merge(@s[1],tloload);
          gdb.GetCurrentDWG.wa.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                                  //создания или загрузки
          redrawoglwnd;
          //programlog.logoutstr('load_merge(@s[1],tloload);',0);
          if assigned(ProcessFilehistoryProc) then
           ProcessFilehistoryProc(s);
          result:=cmd_ok;
     end
               else
               begin
                    shared.ShowError('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']));
                    result:=cmd_error;
               end;
        //shared.ShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function units_cmd:GDBInteger;
var
    _UnitsFormat:TzeUnitsFormat;
begin
   if not assigned(UnitsWindow)then
   begin
       UnitsWindow:=TUnitsWindow.Create(nil);
       SetHeightControl(UnitsWindow,sysvar.INTF.INTF_DefaultControlHeight^);
       UnitsWindow.BoundsRect:=GetBoundsFromSavedUnit('UnitsWND',SysParam.ScreenX,SysParam.Screeny)
   end;

   _UnitsFormat:=gdb.GetUnitsFormat;

   if assigned(ShowAllCursorsProc) then
                                       ShowAllCursorsProc;
   result:=UnitsWindow.runmodal(_UnitsFormat,sysvar.DWG.DWG_InsUnits^);
   if result=mrok then
                      begin
                        gdb.SetUnitsFormat(_UnitsFormat);
                        if assigned(ReturnToDefaultProc)then
                                                            ReturnToDefaultProc(gdb.GetUnitsFormat);
                      end;
   if assigned(RestoreAllCursorsProc) then
                                       RestoreAllCursorsProc;
   StoreBoundsToSavedUnit('UnitsWND',UnitsWindow.BoundsRect);
   Freeandnil(UnitsWindow);
   result:=cmd_ok;
end;
function layer_cmd:GDBInteger;
begin
  LayerWindow:=TLayerWindow.Create(nil);
  SetHeightControl(LayerWindow,sysvar.INTF.INTF_DefaultControlHeight^);
  DOShowModal(LayerWindow);
  Freeandnil(LayerWindow);
  result:=cmd_ok;
end;
function TextStyles_cmd:GDBInteger;
begin
  TSWindow:=TTextStylesWindow.Create(nil);
  SetHeightControl(TSWindow,sysvar.INTF.INTF_DefaultControlHeight^);
  DOShowModal(TSWindow);
  Freeandnil(TSWindow);
  result:=cmd_ok;
end;
function DimStyles_cmd:GDBInteger;
begin
  DSWindow:=TDSWindow.Create(nil);
  SetHeightControl(DSWindow,sysvar.INTF.INTF_DefaultControlHeight^);
  DOShowModal(DSWindow);
  Freeandnil(DSWindow);
  result:=cmd_ok;
end;
 function LineTypes_cmd:GDBInteger;
begin
  LTWindow:=TLTWindow.Create(nil);
  SetHeightControl(LTWindow,sysvar.INTF.INTF_DefaultControlHeight^);
  DOShowModal(LTWindow);
  Freeandnil(LTWindow);
  result:=cmd_ok;
end;
function Colors_cmd:GDBInteger;
var
   mr:integer;
begin
     if not assigned(ColorSelectWND)then
     Application.CreateForm(TColorSelectWND, ColorSelectWND);
     SetHeightControl(ColorSelectWND,sysvar.INTF.INTF_DefaultControlHeight^);
     if assigned(ShowAllCursorsProc) then
                                         ShowAllCursorsProc;
     mr:=ColorSelectWND.run(SysVar.dwg.DWG_CColor^,true){showmodal};
     if mr=mrOk then
                    begin
                    SysVar.dwg.DWG_CColor^:=ColorSelectWND.ColorInfex;
                    end;
     if assigned(RestoreAllCursorsProc) then
                                            RestoreAllCursorsProc;
     freeandnil(ColorSelectWND);
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
      DockMaster.SaveSettingsToConfig(Config);
    finally
      Config.Free;
    end;
    XMLConfig.Flush;
  finally
    XMLConfig.Free;
  end;
end;
function SaveLayout_com(operands:TCommandOperands):TCommandResult;
var
  XMLConfig: TXMLConfigStorage;
  filename:string;
begin
  try
    // create a new xml config file
    filename:=utf8tosys(ProgramPath+'components/defaultlayout.xml');
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
function Show_com(operands:TCommandOperands):TCommandResult;
var
   ctrl:TControl;
begin
  if Operands<>'' then
                      begin
                           ctrl:=DockMaster.FindControl(Operands);
                           if (ctrl<>nil)and(ctrl.IsVisible) then
                                           begin
                                                DockMaster.ManualFloat(ctrl);
                                                DockMaster.GetAnchorSite(ctrl).Close;
                                           end
                                       else
                                           begin
                                                If IsValidIdent(Operands) then
                                                                              DockMaster.ShowControl(Operands,true)
                                                                          else
                                                                              shared.ShowError('Show: invalid identificator!');
                                           end;
                      end
                  else
                      shared.ShowError('Show command must have one operand!');
  result:=cmd_ok;
end;
function quit_com(operands:TCommandOperands):TCommandResult;
begin
     //Application.QueueAsyncCall(MainFormN.asynccloseapp, 0);
     CloseApp;
     result:=cmd_ok;
end;
function About_com(operands:TCommandOperands):TCommandResult;
begin
  if not assigned(Aboutwindow) then
                                  Aboutwindow:=TAboutWnd.mycreate(Application,@Aboutwindow);
  DOShowModal(Aboutwindow);
  result:=cmd_ok;
end;
function Help_com(operands:TCommandOperands):TCommandResult;
begin
  if not assigned(Helpwindow) then
                                  Helpwindow:=THelpWnd.mycreate(Application,@Helpwindow);
  DOShowModal(Helpwindow);
  result:=cmd_ok;
end;
function ClearFileHistory_com(operands:TCommandOperands):TCommandResult;
var i:integer;
    pstr:PGDBString;
begin
     for i:=0 to 9 do
     begin
          pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i));
          if assigned(pstr) then
          pstr^:='';
          if assigned(MainFormN.FileHistory[i]) then
          begin
              MainFormN.FileHistory[i].Caption:='';
              MainFormN.FileHistory[i].command:='';
              MainFormN.FileHistory[i].Visible:=false;
          end;
     end;
     result:=cmd_ok;
end;
function tw_com(operands:TCommandOperands):TCommandResult;
begin
  if CWMemo.IsVisible then
                                 CWindow.Hide
                             else
                                 begin
                                 CWindow.Show;
                                 CWindow.SetFocus;
                                 CWMemo.SelStart:=Length(CWMemo.Lines.Text)-1;
                                 //CWMemo.SelLength:=2;
                                 end;
  result:=cmd_ok;
end;
function SetObjInsp_com(operands:TCommandOperands):TCommandResult;
var
   obj:gdbstring;
   objt:PUserTypeDescriptor;
  pp:PGDBObjEntity;
  ir:itrec;
begin
     if Operands='VARS' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,gdb.GetCurrentDWG);
                            end
else if Operands='CAMERA' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('GDBObjCamera'),gdb.GetCurrentDWG.pcamera,gdb.GetCurrentDWG);
                            end
else if Operands='CURRENT' then
                            begin

                                 if (GDB.GetCurrentDWG.GetLastSelected <> nil)
                                 then
                                     begin
                                          obj:=pGDBObjEntity(GDB.GetCurrentDWG.GetLastSelected)^.GetObjTypeName;
                                          objt:=SysUnit.TypeName2PTD(obj);
                                          If assigned(SetGDBObjInspProc)then
                                          SetGDBObjInspProc(gdb.GetUndoStack,gdb.GetUnitsFormat,objt,GDB.GetCurrentDWG.GetLastSelected,gdb.GetCurrentDWG);
                                     end
                                 else
                                     begin
                                          ShowError('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try SetObjInsp(SELECTED)...');
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='SELECTED' then
                            begin
                                     begin
                                          //ShowError('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try find selected in DRAWING...');
                                          pp:=gdb.GetCurrentROOT.objarray.beginiterate(ir);
                                          if pp<>nil then
                                         begin
                                              repeat
                                              if pp^.Selected then
                                                              begin
                                                                   obj:=pp^.GetObjTypeName;
                                                                   objt:=SysUnit.TypeName2PTD(obj);
                                                                   If assigned(SetGDBObjInspProc)then
                                                                   SetGDBObjInspProc(gdb.GetUndoStack,gdb.GetUnitsFormat,objt,pp,gdb.GetCurrentDWG);
                                                                   exit;
                                                              end;
                                              pp:=gdb.GetCurrentROOT.objarray.iterate(ir);
                                              until pp=nil;
                                         end;
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='OGLWND_DEBUG' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('OGLWndtype'),@gdb.GetCurrentDWG.wa.param,gdb.GetCurrentDWG);
                            end
else if Operands='GDBDescriptor' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('GDBDescriptor'),@gdb,gdb.GetCurrentDWG);
                            end
else if Operands='RELE_DEBUG' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,dbunit.TypeName2PTD('vardesk'),dbunit.FindVariable('SEVCABLEkvvg'),gdb.GetCurrentDWG);
                            end
else if Operands='LAYERS' then
                            begin
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,dbunit.TypeName2PTD('GDBLayerArray'),@gdb.GetCurrentDWG.LayerTable,gdb.GetCurrentDWG);
                            end
else if Operands='TSTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,dbunit.TypeName2PTD('GDBTextStyleArray'),@gdb.GetCurrentDWG.TextStyleTable,gdb.GetCurrentDWG);
                            end
else if Operands='FONTS' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,dbunit.TypeName2PTD('GDBFontManager'),@FontManager,gdb.GetCurrentDWG);
                            end
else if Operands='OSMODE' then
                            begin
                                 OSModeEditor.GetState;
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,gdb.GetCurrentDWG);
                            end
else if Operands='NUMERATORS' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('GDBNumerator'),@gdb.GetCurrentDWG.Numerator,gdb.GetCurrentDWG);
                            end
else if Operands='LINETYPESTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('GDBLtypeArray'),@gdb.GetCurrentDWG.LTypeStyleTable,gdb.GetCurrentDWG);
                            end
else if Operands='TABLESTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('GDBTableStyleArray'),@gdb.GetCurrentDWG.TableStyleTable,gdb.GetCurrentDWG);
                            end
else if Operands='DIMSTYLES' then
                            begin
                                 If assigned(SetGDBObjInspProc)then
                                 SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('GDBDimStyleArray'),@gdb.GetCurrentDWG.DimStyleTable,gdb.GetCurrentDWG);
                            end
                            ;
     If assigned(SetCurrentObjDefaultProc)then
                                              SetCurrentObjDefaultProc;
     result:=cmd_ok;
end;

function Options_com(operands:TCommandOperands):TCommandResult;
begin
  if assigned(SetGDBObjInspProc)then
                                    SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,gdb.GetCurrentDWG);
  historyoutstr(rscmOptions2OI);
  result:=cmd_ok;
end;
function SaveOptions_com(operands:TCommandOperands):TCommandResult;
var
   mem:GDBOpenArrayOfByte;
begin
           mem.init({$IFDEF DEBUGBUILD}'{A1891083-67C6-4C21-8012-6D215935F6A6}',{$ENDIF}1024);
           SysVarUnit^.SavePasToMem(mem);
           mem.SaveToFile(expandpath(ProgramPath+'rtl/sysvar.pas'));
           mem.done;
           result:=cmd_ok;
end;
function CommandList_com(operands:TCommandOperands):TCommandResult;
var
   p:PCommandObjectDef;
   ir:itrec;
   clist:GDBGDBStringArray;
begin
   clist.init(200);
   p:=commandmanager.beginiterate(ir);
   if p<>nil then
   repeat
         clist.add(@p^.CommandName);
         p:=commandmanager.iterate(ir);
   until p=nil;
   clist.sort;
   shared.HistoryOutStr(clist.GetTextWithEOL);
   clist.done;
   result:=cmd_ok;
end;
function DebClip_com(operands:TCommandOperands):TCommandResult;
var
   pbuf:pansichar;
   i:gdbinteger;
   cf:TClipboardFormat;
   ts:string;

   memsubstr:TMemoryStream;
   InfoForm:TInfoForm;
begin
     InfoForm:=TInfoForm.create(application.MainForm);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Clipboard:');

     memsubstr:=TMemoryStream.Create;
     ts:=Clipboard.AsText;
     i:=Clipboard.FormatCount;
     for i:=0 to Clipboard.FormatCount-1 do
     begin
          cf:=Clipboard.Formats[i];
          ts:=ClipboardFormatToMimeType(cf);
          if ts='' then
                       ts:=inttostr(cf);
          InfoForm.Memo.lines.Add(ts);
          Clipboard.GetFormat(cf,memsubstr);
          pbuf:=memsubstr.Memory;
          InfoForm.Memo.lines.Add('  ANSI: '+pbuf);
          memsubstr.Clear;
     end;
     memsubstr.Free;

     DOShowModal(InfoForm);
     InfoForm.Free;

     result:=cmd_ok;
end;
function MemSummary_com(operands:TCommandOperands):TCommandResult;
var
    memcount:GDBNumerator;
    pmemcounter:PGDBNumItem;
    ir:itrec;
    s:gdbstring;
    I:gdbinteger;
    InfoForm:TInfoForm;
begin

     InfoForm:=TInfoForm.create(application.MainForm);
     InfoForm.DialogPanel.HelpButton.Hide;
     InfoForm.DialogPanel.CancelButton.Hide;
     InfoForm.DialogPanel.CloseButton.Hide;
     InfoForm.caption:=('Memory is used to:');
     memcount.init(100);
     for i := 0 to memdesktotal do
     begin
          if not(memdeskarr[i].free) then
          begin
               pmemcounter:=memcount.addnumerator(memdeskarr[i].getmemguid);
               inc(pmemcounter^.Nymber,memdeskarr[i].size);
           end;
     end;
     memcount.sort;

     pmemcounter:=memcount.beginiterate(ir);
     if pmemcounter<>nil then
     repeat

           s:=pmemcounter^.Name+' '+inttostr(pmemcounter^.Nymber);
           InfoForm.Memo.lines.Add(s);
           pmemcounter:=memcount.iterate(ir);
     until pmemcounter=nil;


     DOShowModal(InfoForm);
     InfoForm.Free;
     memcount.FreeAndDone;
    result:=cmd_ok;
end;
function ShowPage_com(operands:TCommandOperands):TCommandResult;
begin
  if assigned(mainformn)then
  if assigned(mainformn.PageControl)then
  mainformn.PageControl.ActivePageIndex:=strtoint(Operands);
  result:=cmd_ok;
end;
procedure startup;
begin
  CreateCommandFastObjectPlugin(@newdwg_com,'NewDWG',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@NextDrawint_com,'NextDrawing',0,0);
  CreateCommandFastObjectPlugin(@PrevDrawint_com,'PrevDrawing',0,0);
  CreateCommandFastObjectPlugin(@CloseDWG_com,'CloseDWG',CADWG,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Load_com,'Load',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@Import_com,'Import',0,0).CEndActionAttr:=CEDWGNChanged;
  CreateCommandFastObjectPlugin(@LoadLayout_com,'LoadLayout',0,0);
  CreateCommandFastObjectPlugin(@quit_com,'Quit',0,0);
  CreateCommandFastObjectPlugin(@units_cmd,'Units',CADWG,0);
  CreateCommandFastObjectPlugin(@layer_cmd,'Layer',CADWG,0);
  CreateCommandFastObjectPlugin(@TextStyles_cmd,'TextStyles',CADWG,0);
  CreateCommandFastObjectPlugin(@DimStyles_cmd,'DimStyles',CADWG,0);
  CreateCommandFastObjectPlugin(@LineTypes_cmd,'LineTypes',CADWG,0);
  CreateCommandFastObjectPlugin(@Colors_cmd,'Colors',CADWG,0);
  CreateCommandFastObjectPlugin(@SaveLayout_com,'SaveLayout',0,0);
  CreateCommandFastObjectPlugin(@Show_com,'Show',0,0);
  CreateCommandFastObjectPlugin(@About_com,'About',0,0);
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0);
  CreateCommandFastObjectPlugin(@ClearFileHistory_com,'ClearFileHistory',0,0);
  CreateCommandFastObjectPlugin(@TW_com,'TextWindow',0,0).overlay:=true;
  CreateCommandFastObjectPlugin(@Options_com,'Options',0,0);
  CreateCommandFastObjectPlugin(@SaveOptions_com,'SaveOptions',0,0);
  CreateCommandFastObjectPlugin(@SetObjInsp_com,'SetObjInsp',CADWG,0);
  CreateCommandFastObjectPlugin(@CommandList_com,'CommandList',0,0);
  CreateCommandFastObjectPlugin(@DebClip_com,'DebClip',0,0);
  CreateCommandFastObjectPlugin(@MemSummary_com,'MeMSummary',0,0);
  CreateCommandFastObjectPlugin(@ShowPage_com,'ShowPage',0,0);
  Aboutwindow:=nil;
  Helpwindow:=nil;
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('gdbcommandsinterface.initialization');{$ENDIF}
  startup;
finalization
  finalize;
end.
