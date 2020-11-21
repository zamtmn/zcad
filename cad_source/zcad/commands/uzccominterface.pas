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
 uzcfcolors,uzcfdimstyles,uzcflinetypes,uzcftextstyles,uzcinfoform,uzefontmanager,uzedrawingsimple,
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
 uzegeometry,
 uzccommand_newdwg;



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
   //function Regen_com(Operands:pansichar):GDBInteger;
//var DWGPageCxMenu:pzpopupmenu;
implementation
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
function ShowPage_com(operands:TCommandOperands):TCommandResult;
begin
  if assigned(ZCADMainWindow)then
  if assigned(ZCADMainWindow.PageControl)then
  ZCADMainWindow.PageControl.ActivePageIndex:=strtoint(Operands);
  result:=cmd_ok;
end;
procedure startup;
begin
  CreateCommandFastObjectPlugin(@About_com,'About',0,0);
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0);
  CreateCommandFastObjectPlugin(@Options_com,'Options',0,0);
  CreateCommandFastObjectPlugin(@SaveOptions_com,'SaveOptions',0,0);
  CreateCommandFastObjectPlugin(@ShowPage_com,'ShowPage',0,0);
  AboutForm:=nil;
  HelpForm:=nil;
end;
initialization
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
