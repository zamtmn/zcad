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
//файл с объявлениями директив компилятора - должен быть подключен во все файлы проекта
{$INCLUDE def.inc}
{$IFDEF WINDOWS}
{$IFDEF FPC}
{$ifdef cpu32}
        {$setpeflags $20} //winnt.h:#define IMAGE_FILE_LARGE_ADDRESS_AWARE       0x0020  // App can handle >2gb addresses
{$endif}
{$ENDIF}
{$ENDIF}

{$IFNDEF LINUX}
  {$APPTYPE GUI}
{$ENDIF}
{$ifdef WIN64} {$imagebase $400000} {$endif}
uses
  {$IFDEF REPORTMMEMORYLEAKS}heaptrc,{$ENDIF}
  Interfaces,forms, classes,
  splashwnd,
  uzcsysvars,

  memman,uzclog,
  uzcsysinfo,
  paths,

  varman,
  //
  //if need create variables before system.pas loading, place unit bellow
  //
  zcregisterobjectinspector,
  zcregisterzscript,
  zcregistergeneralwiewarea,
  zcregisterfontmanager,
  zcregisterpaths,
  //
  //next line load system.pas
  //
  urtl,//loading rtl/system.pas and setup SysVar
  UUnitManager,
  UGDBFontManager,
  ioshx,iottf,

  {$INCLUDE allgeneratedfiles.inc}

  UGDBDescriptor,

  (*            //все нужные файлы перечислены в allgeneratedfiles.inc
  {DXF entities}
  GDBLine,
  GDBText,
  GDBMText,
  GDBPolyLine,
  GDBCircle,
  GDBArc,
  GDBLWPolyLine,
  GDBPoint,
  GDBBlockInsert,
  gdbellipse,
  gdbspline,
  GDB3DFace,
  GDBSolid,
  gdbgenericdimension,

  {ZCAD entities}
  GDBCable,
  GDBDevice,
  gdbaligneddimension,
  gdbrotateddimension,
  gdbdiametricdimension,
  gdbradialdimension,
  *)



  //varman,
  GDBManager,
  //UGDBDescriptor,
  commandline,
  DeviceBase,
  URecordDescriptor,
  //gdbase,
  //splashwnd,
  projecttreewnd,
  //ugdbabstractdrawing,
  sysutils,



  //commandline,

  GDBCommandsBase,
  GDBCommandsDB,
  GDBCommandsDraw,
  gdbcommandsexample,
  gdbcommandsinterface,

  GDBCommandsElectrical,
  GDBCommandsOPS,
  plugins,
  //zcregisterobjectinspector,
  mainwindow,
  uzcshared,
  zcadstrconsts,
  iopalette,
  gdbfieldprocessorimpl,
  registerenitiesfeatures,
  registerenitiesextenders,
  zcregistermultiproperties,
  zclibraryblocksregister,
  uzglopenglviewarea,uzglgdiviewarea,uzglcanvasviewarea,

  dbgappexplorercommand;
  //RegCnownTypes,URegisterObjects;

//exports HistoryOut,redrawoglwnd,updatevisible,reloadlayer; {uzcshared}
//exports getoglwndparam; {mygl}
//exports getcommandmanager; {commandline}
//exports GDBObjLineInit,GDBObjCircleInit,getgdb,addblockinsert,CreateInitObjFree,CreateObjFree; {GDBManager}
//exports getpsysvar,GetPVarMan; {varman}
//exports Vertexmorph,Vertexlength,Vertexangle,VertexAdd,VertexDmorph,Vertexdmorphabs,Vertexmorphabs,intercept2d2,pointinquad2d; {geometry}
//exports CreateCommandRTEdObjectPlugin,CreateCommandFastObjectPlugin; {commanddefinternal}
//exports getprogramlog; {log}
//exports GDBGetMem,GDBFreeMem; {memman}
//exports GetPZWinManager; {ZWinMan}

{$R *.res}

begin
  programlog.logoutstr('<<<<<<<<<<<<<<<End units initialization',0,LM_Debug);
     if sysparam.otherinstancerun then
                                      exit;
{$IFDEF REPORTMMEMORYLEAKS}printleakedblock:=true;{$ENDIF}
{$IFDEF REPORTMMEMORYLEAKS}
       SetHeapTraceOutput('log/memory-heaptrace.txt');
       keepreleased:=true;
{$ENDIF}
  //Application_Initialize перемещен в инициализацию splashwnd чтоб показать сплэш пораньше
  //Application.Initialize;

  //инициализация GDB
  FontManager.EnumerateFontFiles;
  ugdbdescriptor.startup('*rtl/dwg/DrawingVars.pas','');

  //создание окна программы
  Application.CreateForm(MainForm, MainFormN);
  MainFormN.show;
  {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
                                                  sysvar.SYS.SYS_IsHistoryLineCreated^:=true;}
  historyoutstr(format(rsZCADStarted,[sysvar.SYS.SYS_Version^]));
  gdbplugins.loadplugins(ProgramPath+'PLUGINS\');

  SplashWindow.TXTOut('Выполнение *components\autorun.cmd',false);commandmanager.executefile('*components/autorun.cmd',gdb.GetCurrentDWG,nil);
  if sysparam.preloadedfile<>'' then
                                    begin
                                         commandmanager.executecommand('Load('+sysparam.preloadedfile+')',gdb.GetCurrentDWG,gdb.GetCurrentOGLWParam);
                                         sysparam.preloadedfile:='';
                                    end;
  //убираем срлэш
  removesplash;

  {MainFormN.show;
  CLine.Show;}

  Application.run;

  sysvar.SYS.SYS_RunTime:=nil;

  createsplash(false);

  //SplashWindow.TXTOut('GDBCommandsOPS.finalize;');GDBCommandsOPS.finalize;
  //SplashWindow.TXTOut('GDBCommandsElectrical.finalize;');GDBCommandsElectrical.finalize;

  SplashWindow.TXTOut('ugdbdescriptor.finalize;',false);ugdbdescriptor.finalize;

  programlog.logoutstr('END.',0,LM_Necessarily);
  programlog.logoutstr('<<<<<<<<<<<<<<<Start units finalization',0,LM_Debug);
end.


