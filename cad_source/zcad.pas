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
  uzcexceptions,
  Interfaces,forms, classes,
  uzcfsplash,
  uzcsysvars,

  uzbmemman,uzclog,uzcregexceptions,
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
  uzccommand_newdwg,
  uzccommand_nextdrawing,uzccommand_prevdrawing,
  uzccommand_closedwg,
  uzccommand_load,
  uzccommand_mergeblocks,
  uzccommand_merge,
  uzccommand_saveas,
  uzccommand_qsave,
  uzccommand_cancel,
  uzccommand_zoom,
  uzccommand_zoomwindow,
  uzccommand_pan,
  uzccommand_view,
  uzccommand_camreset,
  uzccommand_undo,uzccommand_redo,
  uzccommand_selectall,uzccommand_deselectall,
  uzccommand_regen,
  uzccommand_updatepo,
  uzccommand_treestat,
  uzccommand_copyclip,
  uzccommand_multiselect2objinsp,
  uzccommand_selobjchangelayertocurrent,uzccommand_selobjchangelwtocurrent,
  uzccommand_selobjchangecolortocurrent,uzccommand_selobjchangeltypetocurrent,
  uzccommand_selobjchangetstyletocurrent,uzccommand_selobjchangedimstyletocurrent,
  uzccommand_polydiv,
  uzccommand_selectobjectbyaddres,
  uzccommand_selectonmouseobjects,
  uzccommand_multiobjvarman,uzccommand_objvarman,uzccommand_blockdefvarman,
  uzccommand_unitsman,
  uzccommand_rebuildtree,
  uzccommand_changeprojtype,
  uzccommand_storefrustum,
  uzccommand_snapproperties,
  uzccommand_polytest,

  uzccommand_loadlayout,uzccommand_savelayout,
  uzccommand_quit,
  uzccommand_units,uzccommand_layer,uzccommand_textstyles,uzccommand_dimstyles,
  uzccommand_linetypes,uzccommand_colors,

  uzccommand_clearfilehistory,

  uzccommand_show,uzccommand_showtoolbar,

  uzccommand_setobjinsp,
  uzccommand_memsummary,
  uzccommand_executefile,
  uzccommand_debclip,
  uzccommand_import,
  uzccommand_commandlist,
  uzccommand_saveoptions,
  uzccommand_showpage,
  uzccommand_options,
  uzccommand_about,uzccommand_help,
  uzccommand_get3dpoint,uzccommand_get3dpoint_drawrect,uzccommand_getrect,
  uzccommand_dist,

  uzccommand_line,uzccommand_line2,uzccommand_circle,uzccommand_arc,
  uzccommand_polygon,uzccommand_rectangle,
  uzccommand_matchprop,
  uzccommand_dimlinear,uzccommand_dimaligned,uzccommand_dimdiameter,
  uzccommand_dimradius,

  uzccommand_exampleinsertdevice,uzccommand_examplecreatelayer,

  uzccommand_ld,

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
  uzccomobjectinspector,
  //uzccomexperimental,

  {$IFDEF ELECTROTECH}
  uzcregelectrotechfeatures,
  uzccomelectrical,
  uzccomops,
  uzccommaps,
  {$ENDIF}
  uzcplugins,
  //zcregisterobjectinspector,
  uzcmainwindow,
  uzcuidialogs,
  uzcstrconsts,
  uzeiopalette,
  uzctextpreprocessorimpl,
  uzcregisterenitiesfeatures,
  uzcregisterenitiesextenders,
  uzcoiregistermultiproperties,
  uzclibraryblocksregister,
  uzglviewareaogl,uzglviewareagdi,uzglviewareacanvas,
  {$IFDEF WINDOWS}{uzglviewareadx,}{$ENDIF}

  uzctbexttoolbars, uzctbextmenus, uzctbextpalettes,

  uzcinterface,
  uzccommand_dbgappexplorer;

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


