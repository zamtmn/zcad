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
{$MODE OBJFPC}{$H+}
unit zUndoCmdChgExtTypes;
{$INCLUDE zengineconfig.inc}
interface
uses zeundostack,zebaseundocommands,
     gzUndoCmdChgData2,zUndoCmdChgTypes;
type
  TChangedPointerInEnt=specialize GChangedData<Pointer,TSharedPEntityData,TAfterChangePDrawing>;
  TPoinerInEntChangeCommand=specialize GUCmdChgData2<TChangedPointerInEnt,TSharedPEntityData,TAfterChangePDrawing>;

  TChangedDoubleInEnt=specialize GChangedData<Double,TSharedPEntityData,TAfterChangePDrawing>;
  TDoubleInEntChangeCommand=specialize GUCmdChgData2<TChangedDoubleInEnt,TSharedPEntityData,TAfterChangePDrawing>;
implementation
end.

