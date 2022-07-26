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

unit uzestrconsts;
{$INCLUDE zengineconfig.inc}

interface
resourcestring

  fontnotfoundandreplace='For text style "%s" not found font "%s" ("%s" fontfamily), is replaced by an alternative';
  fontnotfound='For text style "%s" not found font "%s" ("%s" fontfamily)';

  {files}
  rsAlternateFontNotFoundIn='Alternate font "%s" is not found in "%s"';
  rsReserveFontNotLoad='Can not load reserve font';
  rsReserveFontNotFound='Reserve font is not found in the resources';

  {messages}
  rsGridTooDensity='Grid too dense';
  rsBlockIgnored='Ignored block "%s"';
  rsDoubleBlockIgnored='Ignored double definition block "%s"';
  rsWrongBlockDefIndex='Wrong blockdef index';

  {files}
  rsLoadingFile='Loading file "%s"';
  rsFileFormat='%s file format';
  rsUnknownFileFormat='Unknown file format';
  rsUnableRenameFileToBak='Could not rename file "%s" into "*.bak"';
  rsUnableToWriteFile='Unable to write file "%s"';

implementation
end.
