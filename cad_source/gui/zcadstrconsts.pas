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

unit zcadstrconsts;
{$INCLUDE def.inc}

interface
resourcestring
  fontnotfoundandreplace='For text style "%s" not found font "%s", is replaced by an alternative';

  {errors}
  rsDivByZero='Divide by zero';
  rsErrorPrefix='ERROR: ';



  rsRevStr='Revision SVN:';
  rsInitialization='Initialization:';
  rsVInfoText='Unstable version';
  rsCommEntEeport='Registered commands - %s; supported entities - %s';
  rsReleaseNotes='-UNDO\REDO - yet it is better not to use;'+#13#10+
                 #13#10+
                 '-If you have problems with rendering or selecting entities, run "Regen" and "RebuildTree" in command line;'#13#10+
                 #13#10+
                 '-To disable the display of this window comment out line "About" in the file "components\autorun.cmd". Encoding of all configuration files - UTF8;'#13#10;
  rsAuthor='Writeln by Andrey M. Zubarev';
  rsRunCommand='Running command';
  rsUnknownCommand='Unknown command';
  rsCommandNRInC='Command can not run';
  rsRunScript='Running script "%s";';

  rsUnknownFileExt='Unknown file format "%s". Saving failed.';

  rsfardeffilenotfounf='File definition of the variables can not be found for the device "%s";';
  rsMenuNotFounf='Menu "%s" not found';

  rsUnnamedWindowTitle='unnamed';

  {files}
  rsLoadingFile='Loading file "%s"';
  rsFileFormat='%s file format';
  rsUnknownFileFormat='Unknown file format';
  rsUnableToOpenFile='Unable to open file "%s"';
  rsUnableToWriteFile='Unable to write file "%s"';
  rsUnableToFindFile='Unable to find file "%s"';
  rsTemplateNotFound='Template file "%s" not found';

  {commands messages}
  rscmCantGetBlockToReplace='Unable get block name to replace';
  rscmInDwgTxtStyleNotDeffined='In drawing not defined any textstyle!';
  rscmNotCutHere='Do not cut off here';
  rscmNoCTU='No comands to undo. Complete the current command';
  rscmNoCTUSE='No comands to undo. UNDO stack is empty';
  rscmNoCTR='No comands to redo';
  rscmInStackData='In stack found following data:';
  rscmPoint='Point:';
  rscmFirstPoint='First point:';
  rscmSecondPoint='Second point:';
  rscmBasePoint='Base point:';
  rscmInsertPoint='Insert point:';
  rscmCenterPointCircle='Center point for circle:';
  rscmPointOnCircle='Point on a circle:';

  rscmOptions2OI='Options are available in the Object Inspector';
  rscmSelOrSpecEntity='Select or specify the parameters entity!';
  rscmNEntitiesProcessed='%s entities processed';

  rscmNoBlocksOrDevices='No selected blocks or devices';
  rscmNoBlockDefInDWG='No BlockDef "%s" in the drawing';
  rscmNoBlockDefInDWGCXMenu='No BlockDef "%s" in the drawing. Use context menu';
  rscmInDwgBlockDefNotDeffined='In drawing not defined any BlockDefs!';

  rscmSelEntBeforeComm='Entities must be selected before run the command';
  rscmSelDevBeforeComm='Device must be selected before run the command';
  rscmPolyNotSel='Poly entities not selected';
  rscm2VNotRemove='Only 2 vertex there is nothing to remove';

  rscmCommandOnlyCTXMenu='The command works only from context menu';

  {messages}
  rsNotYetImplemented='Not yet implemented';
  rsLayerDefpaontsCanNotBePrinted='Layer DEFPOINTS can not be printed';
  rsQuitQuery='Do yo want to quit ZCAD?';
  rsCloseDWGQuery='Drawing "%s" not saved. Close?';
  rsCurrentLayerOff='The current layer is turned off';
  rsSaveEmptyDWG='Drawing is empty. Sure?';
  rsBlockIgnored='Ignored block "%s"';
  rsDoubleBlockIgnored='Ignored double definition block "%s"';
  rsZCADStarted='ZCAD v%s started';
  rsGridTooDensity='Grid too density';

  {window names}
  rsOpenFile='Open file...';
  rsSaveFile='Save file...';
  rsAutoSave='Autosave';
  rsQuitCaption='Quit';
  rsWarningCaption='Warning!';
  rsAboutWndCaption = 'About ZCAD';
  rsProjectTree = 'Project Tree';
  rsProgramDB = 'Program DB';
  rsProjectDB = 'Project DB';
  rsBlocks='Blocks';
  rsUncategorized='Uncategorized';
  rsDevices='Devices';
  rsEquipment='Equipment';
  rsTextEditor='Text editor';
  rsTextEdCaption=' TEXT: ';
  rsMTextEditor='MText editor';


  rsdefaultpromot='Command';
  rsexprouttext='Expression %s return %s';

  rsGDBObjinspWndName='Object inspector';
  rsCommandLineWndName='Command line';
  rsDrawingWindowWndName='Drawings window';
  rsReCreating='Re-creating %s!';
  rsLayoutLoad='Error loading layout from file';
  rsToolBarNotFound='Toolbar "%s" is not found! Create a blank window';
  rsDifferent='Different';
  rsByLayer='ByLayer';
  rsByBlock='ByBlock';
  rsDefault='Default';
  rsSelectColor='Select color...';
  rsColorNum='Color %d';
  rsEmpty='Empty';
  rsmm='mm';
  rscompiledtimemsg='Done.  %s second';

  rsncOGLc='OpenGL context is not created';
implementation

end.
