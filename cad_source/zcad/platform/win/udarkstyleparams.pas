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

unit uDarkStyleParams;

interface

type
  // Insider 18334
  TPreferredAppMode =
  (
    pamDefault,
    pamAllowDark,
    pamForceDark,
    pamForceLight
  );

var
  PreferredAppMode:TPreferredAppMode={pamAllowDark}pamForceLight;
  IsDarkModeEnabled: Boolean = False;

implementation

end.
