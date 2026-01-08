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

unit uzgprimitivessarray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses gzctnrAlignedVectorObjects,uzbtypes;
type

  PTLLPrimitivesArray=^TLLPrimitivesArray;
  TLLPrimitivesArray= object(GZAlignedVectorObjects<PGDBaseObject>)
  end;

{ #todo : Убрать PGDBaseObject, сделать абстрактный примитив }
implementation
begin
end.

