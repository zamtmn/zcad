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
unit zUndoCmdChgBaseTypes;
{$INCLUDE zengineconfig.inc}
interface
uses zeundostack,zebaseundocommands,
     uzeentity,{gzUndoCmdChgData,}
     gzUndoCmdChgData2,zUndoCmdChgTypes;
type
  //команда изменения строки, только меняет строку, ничего больше
  TChangedString=specialize GChangedData<String,TSharedEmpty,TAfterChangeEmpty>;
  TStringChangeCommand=specialize GUCmdChgData2<TChangedString,TSharedEmpty,TAfterChangeEmpty>;

  //команда изменения указателя, ничего больше
  TChangedPointer=specialize GChangedData<Pointer,TSharedEmpty,TAfterChangeEmpty>;
  TPoinerChangeCommand=specialize GUCmdChgData2<TChangedPointer,TSharedEmpty,TAfterChangeEmpty>;

  //команда изменения булен, ничего больше
  TChangedBoolean=specialize GChangedData<Boolean,TSharedEmpty,TAfterChangeEmpty>;
  TBooleanChangeCommand=specialize GUCmdChgData2<TChangedBoolean,TSharedEmpty,TAfterChangeEmpty>;

  //команда изменения цвета слоя, ничего больше
  TChangedByte=specialize GChangedData<Byte,TSharedEmpty,TAfterChangeEmpty>;
  TByteChangeCommand=specialize GUCmdChgData2<TChangedByte,TSharedEmpty,TAfterChangeEmpty>;
implementation
end.y

