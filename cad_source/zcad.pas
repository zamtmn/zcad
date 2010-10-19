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

program zcad;
{$INCLUDE def.inc}
{$IFNDEF LINUX}
  {$APPTYPE GUI}
{$ENDIF}
uses
  {$IFDEF REPORTMMEMORYLEAKS}heaptrc,{$ENDIF}
  Interfaces,
  forms,
  splashwnd,


  memman,

  sysinfo,
  log,

  varmandef,
  varman,
  UUnitManager,
  URegisterObjects,

  UGDBDescriptor,

  //varman,
  GDBHelpObj,
  GDBManager,
  //UGDBDescriptor,
  mainwindow,
  oglwindow,
  shared,
  sharedgdb,
  DeviceBase,
  URecordDescriptor,
  //gdbase,
  //splashwnd,
  projecttreewnd,
  UGDBDrawingdef,
  sysutils,



  commandline,

  GDBCommandsBase,
  GDBCommandsDB,
  GDBCommandsDraw,

  GDBCommandsElectrical,
  GDBCommandsOPS,
  cmdline,
  plugins,
  layerwnd;
  //RegCnownTypes,URegisterObjects;

//exports HistoryOut,redrawoglwnd,updatevisible,reloadlayer; {shared}
//exports getoglwndparam; {mygl}
//exports getcommandmanager; {commandline}
//exports GDBObjLineInit,GDBObjCircleInit,getgdb,addblockinsert,CreateInitObjFree,CreateObjFree; {GDBManager}
//exports getpsysvar,GetPVarMan; {varman}
//exports Vertexmorph,Vertexlength,Vertexangle,VertexAdd,VertexDmorph,Vertexdmorphabs,Vertexmorphabs,intercept2d2,pointinquad2d; {geometry}
//exports CreateCommandRTEdObjectPlugin,CreateCommandFastObjectPlugin; {commanddefinternal}
//exports getprogramlog; {log}
//exports GDBGetMem,GDBFreeMem; {memman}
//exports GetPZWinManager; {ZWinMan}

{R *.res}

{$R *.res}

begin
{$IFDEF REPORTMMEMORYLEAKS}
       SetHeapTraceOutput('log/memory-heaptrace.txt');
       keepreleased:=true;
{$ENDIF}
programlog.logoutstr('ZCAD log v'+sysparam.ver.versionstring+' started',0);
{$IFDEF FPC}   programlog.logoutstr('Program compiled on Free Pascal Compiler',0); {$ENDIF}
{$IFDEF DEBUGBUILD}programlog.LogOutStr('Program compiled with {$DEFINE DEBUGDUILD}',0); {$ENDIF}
{$IFDEF TOTALYLOG}programlog.logoutstr('Program compiled with {$DEFINE TOTALYLOG}',0); {$ENDIF}
{$IFDEF PERFOMANCELOG}programlog.logoutstr('Program compiled with {$DEFINE PERFOMANCELOG}',0); {$ENDIF}
{$IFDEF BREACKPOINTSONERRORS}programlog.logoutstr('Program compiled with {$DEFINE BREACKPOINTSONERRORS}',0); {$ENDIF}

  //{перемещен в splashwnd}Application.Initialize;

  //инициализация GDB
  ugdbdescriptor.startup;

  //создание окна программы
  Application.CreateForm(TMainFormN, MainFormN);
  MainFormN.show;
  //MainFormN.Repaint;

  if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
                                                  sysvar.SYS.SYS_IsHistoryLineCreated^:=true;

  historyoutstr('ZCAD v'+sysvar.SYS.SYS_Version^+' started');
  gdbplugins.loadplugins(sysparam.programpath+'PLUGINS\');

  historyoutstr('Run file ''*components\autorun.cmd''');
  SplashWindow.TXTOut('Выполнение *components\autorun.cmd');commandmanager.executefile('*components/autorun.cmd');

//updatevisible;

//  SplashWindow.TXTOut('Построение дерева блоков');
//                                                  ProjectTreeWindow:=TProjectTreeWnd.create(application.mainform);

  removesplash;//SplashWindow.TXTOut('SplashWnd^.done;');SplashWindow.Free;


  Application.run;

  sysvar.SYS.SYS_RunTime:=nil;

  createsplash;

  //SplashWindow.TXTOut('GDBCommandsOPS.finalize;');GDBCommandsOPS.finalize;
  //SplashWindow.TXTOut('GDBCommandsElectrical.finalize;');GDBCommandsElectrical.finalize;

  SplashWindow.TXTOut('ugdbdescriptor.finalize;');ugdbdescriptor.finalize;

  programlog.logoutstr('END.',0);
  programlog.done;

end.


