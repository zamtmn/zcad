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
     uzegeometrytypes,uzeentity,gzUndoCmdChgData;
type
  TStringChangeCommand=specialize GUCmdChgData<String,PGDBObjEntity>;
  TGDBPoinerChangeCommand=specialize GUCmdChgData<Pointer,PGDBObjEntity>;
  TBooleanChangeCommand=specialize GUCmdChgData<Boolean,PGDBObjEntity>;
  TGDBByteChangeCommand=specialize GUCmdChgData<Byte,PGDBObjEntity>;
  TDoubleChangeCommand=specialize GUCmdChgData<Double,PGDBObjEntity>;
implementation
end.

