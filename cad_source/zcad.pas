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

{$INCLUDE buildmode.inc}
uses
  {$IFDEF REPORTMMEMORYLEAKS}heaptrc,{$ENDIF}
  Interfaces,forms, classes,
  uzcfsplash,
  uzcsysvars,

  uzbmemman,uzclog,
  uzcsysparams,uzcsysinfo,
  uzbpaths,

  varman,
  //
  //if need create variables before system.pas loading, place unit bellow
  //
  uzcregzscript,//this need before other registers
  uzcoiregister,
  uzcreggeneralwiewarea,
  uzcregfontmanager,
  uzcregpaths,
  uzcreglog,
  uzcregenginefeatures,
  uzcreginterface,
  uzcregnavigatorentities,
  {$IFDEF ELECTROTECH}
  uzcregnavigatordevices,
  {$ENDIF}
  //
  //next line load system.pas
  //
  uzcregother,//loading rtl/system.pas and setup SysVar
  UUnitManager,
  uzefontmanager,
  uzeffshx,uzeffttf,

  {$INCLUDE allgeneratedfiles.inc}

  uzcdrawings,

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
  //UGDBDescriptor,
  uzccommandsmanager,
  uzcdevicebase,
  URecordDescriptor,
  //gdbase,
  //splashwnd,
  {$IFDEF ELECTROTECH}
  uzcfprojecttree,
  {$ENDIF}
  //ugdbabstractdrawing,
  sysutils,



  //commandline,

  uzccombase,
  uzccommand_selectframe,
  uzccommand_ondrawinged,
  uzccommand_stretch,
  uzccommand_selsim,
  {$IFDEF ELECTROTECH}
  uzccomdb,
  {$ENDIF}
  uzccomdraw,
  uzccommand_copy,
  uzccommand_move,
  uzccommand_3dpoly,
  uzccommand_print,
  uzccommand_blockpreviewexport,
  uzccommand_layoff,
  uzccommand_loadmenus,
  uzccommand_loadpalettes,
  uzccommand_loadtoolbars,
  uzccommand_loadactions,


  {$IFDEF ELECTROTECH}
  //**for velec func**//
  //uzccomdrawsuperline,
  //uzvslagcab, //автопрокладка кабелей по именным суперлиниям
  //uzvagslcom, //создания именных суперлиний в комнате между извещателями
  //uzvstripmtext, //очистка мтекста, сделано плохо, в будущем надо переделывать мтекст и механизм.
  //**//
  {$ENDIF}

  //uzccomexample2,
  //uzventsuperline,
  uzccomexample,
  uzccomobjectinspector,
  //uzccomexperimental,
  uzccominterface,

  {$IFDEF ELECTROTECH}
  uzcregelectrotechfeatures,
  uzccomelectrical,
  uzccomops,
  uzccommaps,
  {$ENDIF}
  uzcplugins,
  //zcregisterobjectinspector,
  uzcmainwindow,
  uzcmessagedialogs,
  uzcstrconsts,
  uzeiopalette,
  uzctextpreprocessorimpl,
  uzcregisterenitiesfeatures,
  uzcregisterenitiesextenders,
  uzcoiregistermultiproperties,
  uzclibraryblocksregister,
  uzglviewareaogl,uzglviewareagdi,uzglviewareacanvas,
  {$IFDEF WINDOWS}{uzglviewareadx,}{$ENDIF}

  uzcinterface,
  uzccomdbgappexplorer;

resourcestring
 rsStartAutorun='Execute *components\autorun.cmd';


{$R *.res}

begin
  programlog.logoutstr('<<<<<<<<<<<<<<<End units initialization',0,LM_Debug);
     if sysparam.notsaved.otherinstancerun then
                                      exit;
{$IFDEF REPORTMMEMORYLEAKS}printleakedblock:=true;{$ENDIF}
{$IFDEF REPORTMMEMORYLEAKS}
       SetHeapTraceOutput('log/memory-heaptrace.txt');
       keepreleased:=true;
{$ENDIF}
  //Application_Initialize перемещен в инициализацию uzcfsplash чтоб показать сплэш пораньше
  //Application.Initialize;

  //инициализация drawings
  FontManager.EnumerateFontFiles;
  uzcdrawings.startup('*rtl/dwg/DrawingVars.pas','');

  Application.Scaled:=False;
  Application.MainFormOnTaskBar:=true;
  //создание окна программы
  Application.CreateForm(TZCADMainWindow,ZCADMainWindow);
  ZCADMainWindow.show;
  {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
                                                  sysvar.SYS.SYS_IsHistoryLineCreated^:=true;}
  ZCMsgCallBackInterface.TextMessage(format(rsZCADStarted,[programname,sysvar.SYS.SYS_Version^]),TMWOHistoryOut);
  gdbplugins.loadplugins(ProgramPath+'PLUGINS\');

  SplashForm.TXTOut(rsStartAutorun,false);commandmanager.executefile('*components/autorun.cmd',drawings.GetCurrentDWG,nil);
  if sysparam.notsaved.preloadedfile<>'' then
                                    begin
                                         commandmanager.executecommand('Load('+sysparam.notsaved.preloadedfile+')',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
                                         sysparam.notsaved.preloadedfile:='';
                                    end;
  //убираем срлэш
  ZCMsgCallBackInterface.Do_SetNormalFocus;
  removesplash;

  {MainFormN.show;
  CLine.Show;}

  Application.run;

  sysvar.SYS.SYS_RunTime:=nil;

  createsplash(false);

  //SplashWindow.TXTOut('GDBCommandsOPS.finalize;');GDBCommandsOPS.finalize;
  //SplashWindow.TXTOut('GDBCommandsElectrical.finalize;');GDBCommandsElectrical.finalize;

  SplashForm.TXTOut('ugdbdescriptor.finalize;',false);uzcdrawings.finalize;

  programlog.logoutstr('END.',0,LM_Necessarily);
  programlog.logoutstr('<<<<<<<<<<<<<<<Start units finalization',0,LM_Debug);
end.


