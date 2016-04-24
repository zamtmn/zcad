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

unit uzctnrvectorgdbpointer;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,gzctnrvectorsimple;
type
{Export+}
PTZctnrVectorGDBPointer=^TZctnrVectorGDBPointer;
TZctnrVectorGDBPointer=packed object(GZVectorSimple{-}<GDBPointer>{//}) //TODO:почемуто не работают синонимы с объектами, приходится наследовать
                    end;
{Export-}
implementation
begin
end.
