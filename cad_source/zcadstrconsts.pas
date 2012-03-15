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

  rsRunCommand='Running command';
  rsUnknownCommand='Unknown command';
  rsCommandNRInC='Command can not run';
  rsRunScript='Running script "%s";';

  rsunknownFileExt='Unknown file format "%s". Saving failed.';

  rsfardeffilenotfounf='File definition of the variables can not be found for the device "%s";';

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
  rscmCantGetBlockToReplace='Режим не позволяет получить искомый блок для замены';
  rscmInDwgTxtStyleNotDeffined='In drawing not defined any textstyle!';
  rscmNotCutHere='Do not cut off here';
  rscmNoCTU='No comands to undo. Complete the current command';
  rscmNoCTUSE='No comands to undo. UNDO stack is empty';
  rscmNoCTR='No comands to redo';

  {messages}
  rsNotYetImplemented='Not yet implemented';
  rsLayerDefpaontsCanNotBePrinted='Layer DEFPOINTS can not be printed';
  rsQuitQuery='Do yo want to quit ZCAD?';
  rsCloseDWGQuery='Drawing not saved. Close?';
  rsSaveEmptyDWG='Drawing is empty. Sure?';

  {window names}
  rsQuitCaption='Quit';
  rsWarningCaption='Warning!';
  rsAboutWndCaption = 'About ZCAD';

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
  rsEmpty='Empty';
  rsmm='mm';
  rscompiledtimemsg='Done.  %s second';

  rsncOGLc='OpenGL context is not created';
implementation

end.
