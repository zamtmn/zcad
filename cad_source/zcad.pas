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

program zcad;
//файл с объявлениями директив компилятора - должен быть подключен во все файлы проекта
{$INCLUDE zengineconfig.inc}

{$IFDEF FPC}
  {$CODEPAGE UTF8}
{$endif}

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
  //first, setup crash report file path (uzcregexceptionsfile) and instll exceptions handler for console and gui
  uzcregexceptionsfile,uzbexceptionscl,uzbexceptionsgui,
  //second, install data providers for crash report
  uzcregexceptions,

  Interfaces,forms, classes,LCLVersion,
  uzclog,uzcreglog,
  uzcfsplash,
  uzcsysvars,

  uzcsysparams,uzcSysInfo,uzcPathMacros,
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
  uzcregenginefeatures,
  uzcreginterface,
  uzcregnavigatorentities,
  {$IFDEF ELECTROTECH}
  uzcregnavigatordevices,
  {$ENDIF}
  //
  //next line load system.pas
  //
  uzcregsystempas,//loading rtl/system.pas
  {$INCLUDE allgeneratedfiles.inc}//correct defs in system.pas
  uzcregother,//setup SysVar
  UUnitManager,
  uzefontmanager,
  uzeffshx,uzeffttf,uzeffLibreDWG,uzeffLibreDWG2Ents,


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
  uzccommand_blocksinbasepreviewexport,
  uzccommand_layoff,
  uzccommand_insertlayersfrombase,
  uzccommand_LayerOn,uzccommand_LayerOff,
  uzccommand_loadmenus,
  uzccommand_loadpalettes,
  uzccommand_loadtoolbars,
  uzccommand_loadactions,
  uzccommand_DWGNew,
  uzccommand_DWGNext,uzccommand_DWGPrev,
  uzccommand_DWGClose,
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
  uzccommand_VarsEdSel,uzccommand_VarsED,uzccommand_VarsEdBD,
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
  uzccommand_dbgmemsummary,
  uzccommand_executefile,
  uzccommand_dbgClipboard,
  uzccommand_import,
  uzccommand_dbgCmdList,uzccommand_entslist,
  uzccommand_saveoptions,
  uzccommand_showpage,
  uzccommand_options,
  uzccommand_about,uzccommand_help,
  uzccommand_get3dpoint,uzccommand_get3dpoint_drawrect,uzccommand_getrect,
  uzccommand_dist,

  uzccommand_line,uzccommand_circle,uzccommand_arc,

  uzccommand_line2,uzccommand_circle2,//old commands

  uzccommand_scale,uzccommand_rotate,uzccommand_rotateents,uzccommand_erase,
  uzccommand_inverseselected,uzccommand_cutclip,

  uzccommand_polyed,

  uzccommand_polygon,uzccommand_rectangle,
  uzccommand_matchprop,
  uzccommand_dimlinear,uzccommand_dimaligned,uzccommand_dimdiameter,
  uzccommand_dimradius,

  uzccommand_exampleinsertdevice,uzccommand_examplecreatelayer,
  uzccommand_ExampleVarManipulation,

  uzccommand_VarsLink,

  uzccommand_text,
  uzccommand_exporttexttocsv,
  uzccommand_dataexport,uzccommand_dataimport,
  uzccommand_extdrentslist,uzccommand_extdralllist,uzccommand_extdradd,
  uzccommand_DevDefSync,
  uzccommand_VariablesAdd,

  uzcenitiesvariablesextender,uzcExtdrLayerControl,uzcExtdrSmartTextEnt,

  {$IFNDEF DARWIN}
  {$IFDEF ELECTROTECH}
  //**for velec func**//
  uzccommand_drawsuperline,
  uzvslagcab, //автопрокладка кабелей по именным суперлиниям
  uzvagslcom, //создания именных суперлиний в комнате между извещателями
  uzvstripmtext, //очистка мтекста, сделано плохо, в будущем надо переделывать мтекст и механизм.
  uzvcabmountmethod,
  uzvelscheme, //создание электрической схемы
  uzvaddconnection, //добавить подключение к устройству
  uzvremoveconnection, //удаление подключения к устройству
  //**//
  {$ENDIF}
  {$ENDIF}

  //uzccomexample2,
  uzventsuperline,
  uzccomobjectinspector,
  //uzccomexperimental,

  {$IFDEF ELECTROTECH}
  uzcregelectrotechfeatures,
  uzccomelectrical,
  uzccomops,
  //uzccommaps,
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
  {$IF not((DEFINED(WINDOWS))and(DEFINED(LCLQT5)))}uzglviewareaogl,{$ENDIF}uzglviewareagdi,uzglviewareacanvas,
  {$IFDEF WINDOWS}{uzglviewareadx,}{$ENDIF}

  uzctbexttoolbars, uzctbextmenus, uzctbextpalettes,

  uzcinterface,
  uzccommand_dbgappexplorer,
  {$IFDEF WINDOWS}{$IFDEF LCLQT5}uDarkStyle,{$ENDIF}{$ENDIF}
  uzelongprocesssupport;

resourcestring
 rsStartAutorun='Execute *components\autorun.cmd';

var
  lpsh:TLPSHandle;


{$R *.res}

begin
  programlog.logoutstr('<<<<<<<<<<<<<<<End units initialization',0,LM_Debug);
     if sysparam.notsaved.otherinstancerun then
                                      exit;
  lpsh:=LPS.StartLongProcess('Start program',@lpsh,0);
{$IFDEF REPORTMMEMORYLEAKS}printleakedblock:=true;{$ENDIF}
{$IFDEF REPORTMMEMORYLEAKS}
       SetHeapTraceOutput(sysvar.PATH.Program_Run^+'log/memory-heaptrace.txt');
       keepreleased:=true;
{$ENDIF}
  //Application_Initialize перемещен в инициализацию uzcfsplash чтоб показать сплэш пораньше
  //Application.Initialize;

  //инициализация drawings
  FontManager.EnumerateFontFiles;
  uzcdrawings.startup('*rtl/dwg/DrawingVars.pas','');
  uzcdevicebase.startup;
  {$IF lcl_fullversion>2001200}
  {$ELSE}
    Application.MainFormOnTaskBar:=true;
  {$ENDIF}
  //создание окна программы
  {$IFDEF WINDOWS}{$IFDEF LCLQT5}uDarkStyle.ApplyDarkStyle;{$ENDIF}{$ENDIF}
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

  TZGuiExceptionsHandler.EnableLCLCaptureExceptions;
  LPS.EndLongProcess(lpsh);
  Application.run;

  sysvar.SYS.SYS_RunTime:=nil;

  createsplash(false);

  //SplashWindow.TXTOut('GDBCommandsOPS.finalize;');GDBCommandsOPS.finalize;
  //SplashWindow.TXTOut('GDBCommandsElectrical.finalize;');GDBCommandsElectrical.finalize;

  SplashForm.TXTOut('ugdbdescriptor.finalize;',false);uzcdrawings.finalize;

  programlog.logoutstr('END.',0,LM_Necessarily);
  programlog.logoutstr('<<<<<<<<<<<<<<<Start units finalization',0,LM_Debug);
end.



