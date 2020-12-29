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
{$INCLUDE def.inc}
interface
uses uzctnrobjectschunk;
type
{Export+}
PTLLPrimitivesArray=^TLLPrimitivesArray;
{REGISTEROBJECTTYPE TLLPrimitivesArray}
TLLPrimitivesArray= object(TObjectsChunk)(*OpenArrayOfData=GDBByte*)
             end;
{Export-}
implementation
begin
end.

