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

unit uzcFileStructure;
{$Mode objfpc}{$H+}
{$INCLUDE zengineconfig.inc}
interface
const
  CFSrtlDir='rtl';
  CFSsystempasFile='system.pas';

  CFScomponentsDir='components';
  CFSdefaultlayoutxmlFile='defaultlayout.xml';
  CFSemptydxfFile='empty.dxf';
  CFSsuppressedshortcutsxmlFile='suppressedshortcuts.xml';
  CFSlogopngFile='logo.png';

  CFSconfigsDir='configs';
  CFSconfigxmlFile='config.xml';
  CFSsysvarpasFile='sysvar.pas';
  CFSsavedvarpasFile='savedvar.pas';

  CFSnavigatorsDir='navigators';

  CFSdictionariesDir='dictionaries';

  CFSlanguagesDir='languages';
  CFSzcadpoFile='zcad.po';

  CFShelpDir='help';
  CFSuserguide_shtmlFile='userguide.%s.html';

  CFSimagesDir='images';
  CFSnavigatorimaFile='navigator.ima';

  CFSmenuDir='menu';
  CFSdefaultclaFile='default.cla';

  CFSexamplesDir='examples';
  CFSerrorsDir='errors';
implementation
end.
