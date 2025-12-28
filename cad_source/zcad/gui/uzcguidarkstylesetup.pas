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

unit uzcguiDarkStyleSetup;

interface

uses
  uDarkStyleParams,uzcsysvars,uzeTypes;

implementation
initialization
  if sysvar.INTF.INTF_AppMode<>nil then
    case sysvar.INTF.INTF_AppMode^ of
       TAMAllowDark:PreferredAppMode:=pamAllowDark;
       TAMForceDark:PreferredAppMode:=pamForceDark;
      TAMForceLight:PreferredAppMode:=pamForceLight;
    end;
end.
