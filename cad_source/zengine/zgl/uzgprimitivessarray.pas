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

unit uzgprimitivessarray;
{$INCLUDE zcadconfig.inc}
interface
uses gzctnrAlignedVectorObjects,uzbtypes;
type
{Export+}
PTLLPrimitivesArray=^TLLPrimitivesArray;
{REGISTEROBJECTTYPE TLLPrimitivesArray}
TLLPrimitivesArray= object(GZAlignedVectorObjects{-}<PGDBaseObject>{//})(*OpenArrayOfData=Byte*)
             end;
{Export-}
{ #todo : Убрать PGDBaseObject, сделать абстрактный примитив }
implementation
begin
end.

