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

unit uzccominterface;
{$INCLUDE def.inc}

interface
uses
 uzcutils,uzccomimport,uzbpaths,uzeffmanager,uzglbackendmanager,uzglviewareaabstract,
 uzcfcolors,uzcfdimstyles,uzcflinetypes,uzcftextstyles,uzcinfoform,uzefontmanager,uzedrawingsimple,uzccombase,
 uzcsysvars,uzccommandsmanager,TypeDescriptors,uzcstrconsts,uzctnrvectorgdbstring,uzcctrlcontextmenu,
 {$IFNDEF DELPHI}uzctranslations,{$ENDIF}uzcflayers,uzcfunits,uzbstrproc,uzctreenode,menus,
 {$IFDEF FPC}lcltype,{$ENDIF}
 uzcguimenuextensions,
 LCLProc,Classes,{ SysUtils,} {fileutil}LazUTF8,{ LResources,} Forms, {stdctrls,} Controls, {Graphics, Dialogs,}ComCtrls,Clipbrd,lclintf,
 uzedimensionaltypes,
 uzcsysparams,uzcsysinfo,
  gzctnrvectortypes,uzccommandsabstract,uzmenusmanager,
  uzccommandsimpl,
  uzbtypes,
  uzcdrawings,
  sysutils,
  varmandef,
  //oglwindowdef,
  //OGLtypes,
  UGDBOpenArrayOfByte,
  uzeffdxf,
  //optionswnd,
  {objinsp,}
   uzcinterface,
  //cmdline,
  //UGDBVisibleOpenArray,
  //gdbobjectsconstdef,
  uzeentity,
 uzcdrawing,
  {zmenus,}uzcfprojecttree,uzbtypesbase,{optionswnd,}uzcfabout,uzcfhelp,uzbmemman,uzcdialogsfiles,{txteditwnd,}
 {messages,}UUnitManager,{zguisct,}uzclog,Varman,UGDBNumerator,uzcfcommandline,uzcfhistorywindow,
 AnchorDocking,dialogs,XMLPropStorage,xmlconf,{uzglviewareaogl,}
 {,uPSCompiler,
  uPSRuntime,
  uPSC_std,
  uPSC_controls,
  uPSC_stdctrls,
  uPSC_forms,
  uPSR_std,
  uPSR_controls,
  uPSR_stdctrls,
  uPSR_forms,
  uPSUtils}
 uzcmainwindow,uztoolbarsmanager,
 uzegeometry;



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
   function layer_cmd(operands:TCommandOperands):TCommandResult;
   function Colors_cmd(operands:TCommandOperands):TCommandResult;
   //function Regen_com(Operands:pansichar):GDBInteger;
//var DWGPageCxMenu:pzpopupmenu;
implementation
function CloseDWG_com(operands:TCommandOperands):TCommandResult;
var
   //poglwnd:toglwnd;
   CurrentDWG:PTZCADDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=PTZCADDrawing(drawings.GetCurrentDWG);
  _CloseDWGPage(CurrentDWG,ZCADMainWindow.PageControl.ActivePage);
  result:=cmd_ok;
end;
function NextDrawint_com(operands:TCommandOperands):TCommandResult;
var
   i:integer;
begin
     if assigned(ZCADMainWindow.PageControl)then
     if ZCADMainWindow.PageControl.PageCount>1 then
     begin
          i:=ZCADMainWindow.PageControl.ActivePageIndex+1;
          if i=ZCADMainWindow.PageControl.PageCount
                                              then
                                                  i:=0;
             ZCADMainWindow.PageControl.ActivePageIndex:=i;
     end;
     zcRedrawCurrentDrawing;
     result:=cmd_ok;
end;
function PrevDrawint_com(operands:TCommandOperands):TCommandResult;
var
   i:integer;
begin
     if assigned(ZCADMainWindow.PageControl)then
     if ZCADMainWindow.PageControl.PageCount>1 then
     begin
          i:=ZCADMainWindow.PageControl.ActivePageIndex-1;
          if i<0
                                            then
                                                  i:=ZCADMainWindow.PageControl.PageCount-1;
             ZCADMainWindow.PageControl.ActivePageIndex:=i;
     end;
     zcRedrawCurrentDrawing;
     result:=cmd_ok;
end;
function newdwg_com(operands:TCommandOperands):TCommandResult;
var
   ptd:PTZCADDrawing;
   myts:TTabSheet;
   oglwnd:TCADControl;
   wpowner:{TOpenGLViewArea}{TGeneralViewArea}TAbstractViewArea;
   tn:GDBString;
   dwgname:GDBString;
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
function Import_com(operands:TCommandOperands):TCommandResult;
var
   s: GDBString;
   //fileext:GDBString;
   isload:boolean;
begin
  if length(operands)=0 then
                     begin
                          ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
                          //mainformn.ShowAllCursors;
                          isload:=OpenFileDialog(s,1,'svg',ImportFileFilter,'','Import...');
                          ZCMsgCallBackInterface.Do_AfterShowModal(nil);
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
       newdwg_com(s);
       drawings.GetCurrentDWG.SetFileName(s);
       import(s,drawings.GetCurrentDWG^);
  end
            else
     ZCMsgCallBackInterface.TextMessage('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']),TMWOShowError);
     //TMWOShowError('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
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
                             ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
                             isload:=OpenFileDialog(s,Ext2LoadProcMap.GetDefaultFileFilterIndex,{'dxf'}Ext2LoadProcMap.GetDefaultFileExt,{ProjectFileFilter}Ext2LoadProcMap.GetCurrentFileFilter,'',rsOpenFile);
                             ZCMsgCallBackInterface.Do_AfterShowModal(nil);
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
          newdwg_com(s);
          //if operands<>'QS' then
                                drawings.GetCurrentDWG.SetFileName(s);
          //programlog.logoutstr('gdb.GetCurrentDWG.FileName:=s;',0);
          load_merge(s,tloload);
          drawings.GetCurrentDWG.wa.Drawer.delmyscrbuf;//буфер чистить, потому что он может оказаться невалидным в случае отрисовки во время
                                                  //создания или загрузки
          ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedrawContent);
          //programlog.logoutstr('load_merge(@s[1],tloload);',0);
          if assigned(ProcessFilehistoryProc) then
           ProcessFilehistoryProc(s);
          result:=cmd_ok;
     end
               else
               begin
                    ZCMsgCallBackInterface.TextMessage('LOAD:'+format(rsUnableToOpenFile,[s+'('+Operands+')']),TMWOShowError);
                    result:=cmd_error;
               end;
        //ZCMsgCallBackInterface.TextMessage('GDBCommandsBase.LOAD: Не могу открыть файл: '+s+'('+Operands+')');
end;
function ExecuteFile_com(operands:TCommandOperands):TCommandResult;
begin
  commandmanager.executefile(ExpandPath(operands),drawings.GetCurrentDWG,nil);
  result:=cmd_ok;
end;
function units_cmd(operands:TCommandOperands):TCommandResult;
var
    _UnitsFormat:TzeUnitsFormat;
begin
   if not assigned(UnitsForm)then
   begin
       UnitsForm:=TUnitsForm.Create(nil);
       SetHeightControl(UnitsForm,sysvar.INTF.INTF_DefaultControlHeight^);
       UnitsForm.BoundsRect:=GetBoundsFromSavedUnit('UnitsWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny)
   end;

   _UnitsFormat:=drawings.GetUnitsFormat;

   ZCMsgCallBackInterface.Do_BeforeShowModal(UnitsForm);
   result:=UnitsForm.runmodal(_UnitsFormat,sysvar.DWG.DWG_InsUnits^);
   if result=mrok then
                      begin
                        drawings.SetUnitsFormat(_UnitsFormat);
                        ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
                      end;
   ZCMsgCallBackInterface.Do_AfterShowModal(UnitsForm);
   StoreBoundsToSavedUnit('UnitsWND',UnitsForm.BoundsRect);
   Freeandnil(UnitsForm);
   result:=cmd_ok;
end;
function layer_cmd(operands:TCommandOperands):TCommandResult;
begin
  LayersForm:=TLayersForm.Create(nil);
  SetHeightControl(LayersForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(LayersForm);
  Freeandnil(LayersForm);
  result:=cmd_ok;
end;
function TextStyles_cmd(operands:TCommandOperands):TCommandResult;
begin
  TextStylesForm:=TTextStylesForm.Create(nil);
  SetHeightControl(TextStylesForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(TextStylesForm);
  Freeandnil(TextStylesForm);
  result:=cmd_ok;
end;
function DimStyles_cmd(operands:TCommandOperands):TCommandResult;
begin
  DimStylesForm:=TDimStylesForm.Create(nil);
  SetHeightControl(DimStylesForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(DimStylesForm);
  Freeandnil(DimStylesForm);
  result:=cmd_ok;
end;
 function LineTypes_cmd(operands:TCommandOperands):TCommandResult;
begin
  LineTypesForm:=TLineTypesForm.Create(nil);
  SetHeightControl(LineTypesForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(LineTypesForm);
  Freeandnil(LineTypesForm);
  result:=cmd_ok;
end;
function Colors_cmd(operands:TCommandOperands):TCommandResult;
var
   mr:integer;
begin
     if not assigned(ColorSelectForm)then
     Application.CreateForm(TColorSelectForm, ColorSelectForm);
     SetHeightControl(ColorSelectForm,sysvar.INTF.INTF_DefaultControlHeight^);
     ZCMsgCallBackInterface.Do_BeforeShowModal(ColorSelectForm);
     mr:=ColorSelectForm.run(SysVar.dwg.DWG_CColor^,true){showmodal};
     if mr=mrOk then
                    begin
                    SysVar.dwg.DWG_CColor^:=ColorSelectForm.ColorInfex;
                    end;
     ZCMsgCallBackInterface.Do_AfterShowModal(ColorSelectForm);
     freeandnil(ColorSelectForm);
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
      ToolBarsManager.SaveToolBarsToConfig(Config);
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
                                                                              ZCMsgCallBackInterface.TextMessage('Show: invalid identificator!',TMWOShowError);
                                           end;
                      end
                  else
                      ZCMsgCallBackInterface.TextMessage('Show command must have one operand!',TMWOShowError);
  result:=cmd_ok;
end;
function ShowToolBar_com(operands:TCommandOperands):TCommandResult;
begin
  if Operands<>'' then
                      begin
                        ToolBarsManager.ShowFloatToolbar(operands,rect(0,0,300,50));
                      end
                  else
                      ZCMsgCallBackInterface.TextMessage('Show command must have one operand!',TMWOShowError);
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
  if not assigned(AboutForm) then
                                  AboutForm:=TAboutForm.mycreate(Application,@AboutForm);
  ZCMsgCallBackInterface.DOShowModal(AboutForm);
  result:=cmd_ok;
end;
function Help_com(operands:TCommandOperands):TCommandResult;
begin
  if not assigned(HelpForm) then
                                  HelpForm:=THelpForm.mycreate(Application,@HelpForm);
  ZCMsgCallBackInterface.DOShowModal(HelpForm);
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
          if assigned(FileHistory[i]) then
          begin
              FileHistory[i].Caption:='';
              FileHistory[i].command:='';
              FileHistory[i].Visible:=false;
          end;
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
                              ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,drawings.GetCurrentDWG);
                            end
else if Operands='CAMERA' then
                            begin
                              ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBObjCamera'),drawings.GetCurrentDWG.pcamera,drawings.GetCurrentDWG);
                            end
else if Operands='CURRENT' then
                            begin

                                 if (drawings.GetCurrentDWG.GetLastSelected <> nil)
                                 then
                                     begin
                                          obj:=pGDBObjEntity(drawings.GetCurrentDWG.GetLastSelected)^.GetObjTypeName;
                                          objt:=SysUnit.TypeName2PTD(obj);
                                          ZCMsgCallBackInterface.Do_PrepareObject(drawings.GetUndoStack,drawings.GetUnitsFormat,objt,drawings.GetCurrentDWG.GetLastSelected,drawings.GetCurrentDWG);
                                     end
                                 else
                                     begin
                                          ZCMsgCallBackInterface.TextMessage('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try SetObjInsp(SELECTED)...',TMWOShowError);
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='SELECTED' then
                            begin
                                     begin
                                          //ZCMsgCallBackInterface.TextMessage('ugdbdescriptor.poglwnd^.SelDesc.LastSelectedObject=NIL, try find selected in DRAWING...');
                                          pp:=drawings.GetCurrentROOT.objarray.beginiterate(ir);
                                          if pp<>nil then
                                         begin
                                              repeat
                                              if pp^.Selected then
                                                              begin
                                                                   obj:=pp^.GetObjTypeName;
                                                                   objt:=SysUnit.TypeName2PTD(obj);
                                                                   ZCMsgCallBackInterface.Do_PrepareObject(drawings.GetUndoStack,drawings.GetUnitsFormat,objt,pp,drawings.GetCurrentDWG);
                                                                   exit;
                                                              end;
                                              pp:=drawings.GetCurrentROOT.objarray.iterate(ir);
                                              until pp=nil;
                                         end;
                                     end;
                                 SysVar.DWG.DWG_SelectedObjToInsp^:=false;
                            end
else if Operands='OGLWND_DEBUG' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('OGLWndtype'),@drawings.GetCurrentDWG.wa.param,drawings.GetCurrentDWG);
                            end
else if Operands='GDBDescriptor' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBDescriptor'),@drawings,drawings.GetCurrentDWG);
                            end
else if Operands='RELE_DEBUG' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('vardesk'),dbunit.FindVariable('SEVCABLEkvvg'),drawings.GetCurrentDWG);
                            end
else if Operands='LAYERS' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('GDBLayerArray'),@drawings.GetCurrentDWG.LayerTable,drawings.GetCurrentDWG);
                            end
else if Operands='TSTYLES' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('GDBTextStyleArray'),@drawings.GetCurrentDWG.TextStyleTable,drawings.GetCurrentDWG);
                            end
else if Operands='FONTS' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('GDBFontManager'),@FontManager,drawings.GetCurrentDWG);
                            end
else if Operands='OSMODE' then
                            begin
                                 OSModeEditor.GetState;
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,drawings.GetCurrentDWG);
                            end
else if Operands='NUMERATORS' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBNumerator'),@drawings.GetCurrentDWG.Numerator,drawings.GetCurrentDWG);
                            end
else if Operands='LINETYPESTYLES' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBLtypeArray'),@drawings.GetCurrentDWG.LTypeStyleTable,drawings.GetCurrentDWG);
                            end
else if Operands='TABLESTYLES' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBTableStyleArray'),@drawings.GetCurrentDWG.TableStyleTable,drawings.GetCurrentDWG);
                            end
else if Operands='DIMSTYLES' then
                            begin
                                 ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('GDBDimStyleArray'),@drawings.GetCurrentDWG.DimStyleTable,drawings.GetCurrentDWG);
                            end;
     ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUISetDefaultObject);
     result:=cmd_ok;
end;

function Options_com(operands:TCommandOperands):TCommandResult;
begin
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,drawings.GetCurrentDWG);
  ZCMsgCallBackInterface.TextMessage(rscmOptions2OI,TMWOHistoryOut);
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
           SaveParams(expandpath(ProgramPath+'rtl/config.xml'),SysParam.saved);
           result:=cmd_ok;
end;
function CommandList_com(operands:TCommandOperands):TCommandResult;
var
   p:PCommandObjectDef;
   ir:itrec;
   clist:TZctnrVectorGDBString;
begin
   clist.init(200);
   p:=commandmanager.beginiterate(ir);
   if p<>nil then
   repeat
         clist.PushBackData(p^.CommandName);
         p:=commandmanager.iterate(ir);
   until p=nil;
   clist.sort;
   ZCMsgCallBackInterface.TextMessage(clist.GetTextWithEOL,TMWOHistoryOut);
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

     ZCMsgCallBackInterface.DOShowModal(InfoForm);
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


     ZCMsgCallBackInterface.DOShowModal(InfoForm);
     InfoForm.Free;
     memcount.Done;
    result:=cmd_ok;
end;
function ShowPage_com(operands:TCommandOperands):TCommandResult;
begin
  if assigned(ZCADMainWindow)then
  if assigned(ZCADMainWindow.PageControl)then
  ZCADMainWindow.PageControl.ActivePageIndex:=strtoint(Operands);
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
  CreateCommandFastObjectPlugin(@ShowToolBar_com,'ShowToolBar',0,0);
  CreateCommandFastObjectPlugin(@About_com,'About',0,0);
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0);
  CreateCommandFastObjectPlugin(@ClearFileHistory_com,'ClearFileHistory',0,0);
  CreateCommandFastObjectPlugin(@Options_com,'Options',0,0);
  CreateCommandFastObjectPlugin(@SaveOptions_com,'SaveOptions',0,0);
  CreateCommandFastObjectPlugin(@SetObjInsp_com,'SetObjInsp',CADWG,0);
  CreateCommandFastObjectPlugin(@CommandList_com,'CommandList',0,0);
  CreateCommandFastObjectPlugin(@DebClip_com,'DebClip',0,0);
  CreateCommandFastObjectPlugin(@MemSummary_com,'MeMSummary',0,0);
  CreateCommandFastObjectPlugin(@ShowPage_com,'ShowPage',0,0);
  CreateCommandFastObjectPlugin(@ExecuteFile_com,'ExecuteFile',0,0);
  AboutForm:=nil;
  HelpForm:=nil;
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
