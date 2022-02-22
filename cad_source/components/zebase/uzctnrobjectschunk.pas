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

unit uzctnrobjectschunk;

interface
uses gzctnrAlignedVector,uzbtypes;
type
{Export+}
PTObjectsChunk=^TObjectsChunk;
TObjectsChunk=object(GZAlignedVectorObjects{-}<PGDBaseObject>{//})
              end;
{Export-}
implementation
begin
end.

