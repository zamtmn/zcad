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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}
{**Модуль описания базового генерика обьекта-массива}
unit gzctnrvectortypes;
{$INCLUDE def.inc}
interface
uses uzbmemman,{uzbtypesbase,}sysutils,{uzbtypes,}typinfo;
type
{Export+}
  {REGISTERRECORDTYPE itrec}
  itrec=record
              itp:{-}PPointer{/Pointer/};
              itc:Integer;
        end;
  PTArrayIndex=^TArrayIndex;
  TArrayIndex=Integer;
{Export-}
implementation
begin
end.
